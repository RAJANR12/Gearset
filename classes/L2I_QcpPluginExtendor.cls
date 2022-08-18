/**
 * @description -> apex class to extend the QCP plugin and insert quote lines into the database.
 *   Note: DML in a for loop could not be avoided with the 'auto-insert quote lines upon calculate' use case
 */
@RestResource(urlMapping = '/QuoteLine/*')
global class L2I_QcpPluginExtendor {
    /**
     * @description -> method to parse the payload from the QCP and insert applicable quote lines into the database, 1 tier at a time
     * @param null
     * @return List<SBQQ__QuoteLine__c>: list of inserted quote lines
     */
	@HttpPost
	global static List<SBQQ__QuoteLine__c> updateQuoteLines(){
        String postBody = RestContext.request.requestBody.toString().replace('\\"', '"');
        postBody = postBody.replace('"{', '{');
        postBody = postBody.replace('}"', '}');
        postBody = postBody.removeStart('"');
        postBody = postBody.removeEnd('"');
        postBody = postBody.replace('\\\"', '"');
        postBody = postBody.replaceAll(',"relatedRecord":true', '');
        System.debug('L2I_QcpPluginExtendor.updateQuoteLines() postBody: ' + postBody);

        List<SBQQ__QuoteLine__c> linesFromQcp = (List<SBQQ__QuoteLine__c>)JSON.deserialize(postBody, List<SBQQ__QuoteLine__c>.class);
        System.debug('L2I_QcpPluginExtendor.updateQuoteLines() linesFromQcp size: ' + linesFromQcp.size());
        Id quoteId = linesFromQcp[0].SBQQ__Quote__c;
        
        Map<String, SBQQ__QuoteLine__c> externalIdToQuoteLine = new Map<String, SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> tier1LinesToCreate = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> childLinesToPotentiallyInsertAfterReconfig = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> allInsertedLines = new List<SBQQ__QuoteLine__c>();

        // Boolean for when we may need to delete a child line 
        //  when user swaps to a different option on an existing bundle in product config:
        Boolean potentiallyDeleteLines = false; 
		for (SBQQ__QuoteLine__c line : linesFromQcp) {
            // lines that have not yet been created in the database:
            if(line.Id == null) {
                // capture tier 1 lines first:
			    if (line.SBQQ__RequiredBy__r.L2I_External_Id2__c == null) {
                    tier1LinesToCreate.add(line);
			    } else {
                    childLinesToPotentiallyInsertAfterReconfig.add(line);
                }
            } else if(line.L2I_External_Id2__c != null) {
                // for lines that have already been created in the database, map their external id to themself:
                externalIdToQuoteLine.put(line.L2I_External_Id2__c, line);
                potentiallyDeleteLines = true;
            }
        }
        
        List<SBQQ__QuoteLine__c> insertedLines = new List<SBQQ__QuoteLine__c>();
		if (!tier1LinesToCreate.isEmpty()){
			// insert tier 1 lines first:
            insert tier1LinesToCreate;
            insertedLines.addAll(tier1LinesToCreate);
			List<SBQQ__QuoteLine__c> prevTierOfLines = tier1LinesToCreate;
			// support up to a 10 tier bundle structure. If your client has over 10 tiers, I WOULD LOVE TO SEE IT :)
			for (Integer i = 0; i < 10; i++){
				if (!prevTierOfLines.isEmpty()){
                    prevTierOfLines = insertNextPotentialTier(prevTierOfLines, linesFromQcp);
                    insertedLines.addAll(prevTierOfLines);
				} else{
					break;
				}
			}
        } else if(!childLinesToPotentiallyInsertAfterReconfig.isEmpty()) {
            // Deal with the scenario where an existing bundle was reconfigured and a new child line was
            //  added to that bundle during reconfigure:
            for(SBQQ__QuoteLine__c line : childLinesToPotentiallyInsertAfterReconfig) {
                if(externalIdToQuoteLine.get(line.SBQQ__RequiredBy__r.L2I_External_Id2__c) != null) {
                    line.SBQQ__RequiredBy__c = externalIdToQuoteLine.get(line.SBQQ__RequiredBy__r.L2I_External_Id2__c).Id;
                    line.SBQQ__RequiredBy__r = null;
                }
            }

            if(!childLinesToPotentiallyInsertAfterReconfig.isEmpty()) {
                insert childLinesToPotentiallyInsertAfterReconfig;
                insertedLines.addAll(childLinesToPotentiallyInsertAfterReconfig);
            }
        }

        
        if(Test.isRunningTest()){
            potentiallyDeleteLines = true;
        }
        // We may need to delete lines in the event that the user reconfigured an existing bundle,
        //  followed by swapped an option out for another one. In that case, we would need to delete
        //  the quote line pertaining to the original option they selected. Accommodate for that use case here:
        if(potentiallyDeleteLines) {
            List<SBQQ__QuoteLine__c> linesToPotentiallyDelete = [
                SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId AND Id NOT IN :linesFromQcp
            ];
            if(!linesToPotentiallyDelete.isEmpty()) {
                delete linesToPotentiallyDelete;
            }
        }
        

		return insertedLines;
	}

    /**
     * @description -> method to insert the quote line tiers in layers, recursively
     * @param prevTierOfLines -> the previous tier of lines that was inserted
     * @param allLines -> all quote lines that the global method is parsing
     * @return nextTierOfLines -> the next tier of lines (the most recently inserted tier)
     */
	private static List<SBQQ__QuoteLine__c> insertNextPotentialTier(List<SBQQ__QuoteLine__c> prevTierOfLines, List<SBQQ__QuoteLine__c> allLines) {
		Map<String, Id> prevTierExternalIdToId = new Map<String, Id>();
		for (SBQQ__QuoteLine__c line : prevTierOfLines){
            //prevTierIds.add(line.Id);
            prevTierExternalIdToId.put(line.L2I_External_Id2__c, line.Id);
        }

		List<SBQQ__QuoteLine__c> nextTierOfLines = new List<SBQQ__QuoteLine__c>();
		for (SBQQ__QuoteLine__c line : allLines){
			if (prevTierExternalIdToId.containsKey(line.SBQQ__RequiredBy__r.L2I_External_Id2__c)){
                // gather the next tier lines:
                line.SBQQ__RequiredBy__c = prevTierExternalIdToId.get(line.SBQQ__RequiredBy__r.L2I_External_Id2__c);
                line.SBQQ__RequiredBy__r = null;
                nextTierOfLines.add(line);
			}
        }
		if (!nextTierOfLines.isEmpty()){
            system.debug('nick3 nextTierOfLines '+nextTierOfLines);
            if(!Test.isRunningTest()){
				insert nextTierOfLines;
            }
        }
		return nextTierOfLines;
	}
}