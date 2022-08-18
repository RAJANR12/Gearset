/**
 *      @author       Sarah Kennedy
 *      @date         10/20/2020
 *      @description  Controller to Configure a Program, such as Split a Program, Configure Opportunities
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 10/20/2020         Initial creation
 *		Suresh Kumarasamy			  05/14/2021		 W-003688 defect fix 
 */
public without sharing class PT_ProgCPLSplitConfig {
    
    @AuraEnabled
    public static SplitWrapper programSplitConfig(String dslIdString, String isNewProgram) {
        System.debug('*** programSplitConfig dslIdString ' + dslIdString + ' isNewProgram ' + isNewProgram);
        L2I_DSH__c newDSH;
        Opportunity newOpp;
        List<PT_Program__c> progList = new List<PT_Program__c>();
        List<Opportunity> oldOppList = new List<Opportunity>();
        Opportunity oldOpp;
        SBQQ__Quote__c newClonedQuote;
        List<SBQQ__Quote__c> clonedQuotes;
        Set<Id> dshIds = new Set<Id>();
        String dshId;
        String oppId;
        String dslNames = '';
        String processingObject = '';
        List<L2I_DSL__c> dslList = new List<L2I_DSL__c>();
        splitWrapper sw = new splitWrapper();
        sw.errMsg = '';

// create List from the dslIDs
        List<String> dslToList = dslIdString.split(',');
        System.debug('*** dslToList ' + dslToList);
    
        for (L2I_DSL__c dsl : [
            SELECT Id, Name, 
            PT_Program__c, Line_Number__c, Delivery_Schedule_Header__c, Delivery_Schedule_Header__r.Name, Original_Opportunity__c //Added by Jan Geronga for W-003928
            FROM L2I_DSL__c WHERE Id IN :dslToList AND PT_isActive__c = 'Active'
            //W-003688 Commented AND Aircraft__c = null
        ]) {
            dslList.add(dsl);
            dslNames = dslNames == '' ? dsl.Name : dslNames + ', ' + dsl.Name;
        }
        System.debug('*** dslNames ' + dslNames);
        
        try {
            processingObject = 'Processing Delivery Schedule Lines selection';
            // access the DSLs to get the Program Id and DSH Id for moving the DSLs
			//Removed by Jan Geronga for W-003928: Start - Redundant Query
            /*dslList = [
                  SELECT Id, PT_Program__c, Line_Number__c, Delivery_Schedule_Header__c, Delivery_Schedule_Header__r.Name,
                        Original_Opportunity__c
                  FROM L2I_DSL__c
                  WHERE Id IN :dslToList
               //W-003688 Commented   AND Aircraft__c = null
            ];*/
            //Removed by Jan Geronga for W-003928: End
            
            if (dslList.size() == 0) {
                System.debug('0 Shipsets without Tail #s were found!');
                sw.errMsg = '0 Shipsets without Tail #s were found.';
            } else {
                if (isNewProgram == 'Yes') {
                    sw.programId = null;
                    progList = [SELECT Id, Name FROM PT_Program__c WHERE Id = :dslList[0].PT_Program__c];  // save the original Program of a Split for Chatter
                } else {
                    sw.programId = dslList[0].PT_Program__c;
                }
                
                for (L2I_DSL__c dsl : dslList) {
                    dshIds.add(dsl.Delivery_Schedule_Header__c);
                }
                
                if (dshIds.size() > 1) {
                    System.debug('Shipsets cannot be selected from Multiple CPLs!');
                    sw.errMsg = 'Shipsets cannot be selected from Multiple CPLs.';
                } else {
                    oldOppList = [
                          SELECT Id, SBQQ__PrimaryQuote__c, L2I_Program_Num__c, PT_Part_List_Name__c,
                                Name, L2I_Delivery_Schedule__c, L2I_AircraftQuantity__c, PT_Part_List_Name_Rev__c,
                                PT_PL_Approval_Status__c, L2I_Program_num__r.name,
                                (SELECT Id, Split_Version__c FROM Opportunities__r ORDER BY Split_Version__c DESC NULLS LAST LIMIT 1) // Added by Lipton for W-003360
                          FROM Opportunity
                          WHERE L2I_Delivery_Schedule__c = :dshIds
                          AND PT_Is_CPL__c = true
                          AND StageName = 'Delivery'
                          LIMIT 1
                    ];
                    System.debug('*** oldOppList ' + oldOppList);
                    if (oldOppList.size() == 0) {
                        System.debug('A valid CPL in the Delivery Stage was not found!');
                        sw.errMsg = 'A valid CPL in the Delivery Stage was not found.';
                    } else {
                        if (oldOppList.size() == 1 &&
                              oldOppList[0].PT_PL_Approval_Status__c == 'Pending'
                              ) {
                            System.debug('CPL is pending PL Approval!');
                            sw.errMsg = 'CPL is pending PL Approval.';
                        } else {
            
                            if (oldOppList.size() == 0) {
                                System.debug('No CPL Opportunities exist in Delivery Stage ');
                                sw.errMsg = 'No CPL Opportunities exist in Delivery Stage';
                            } else {
// only get 1 DSH even if there are multiple for the Program
                                dshId = '\'' + oldOppList[0].L2I_Delivery_Schedule__c + '\'';
// only need to get one Sales Opp even if there are multiple for the Program
                                oldOpp = oldOppList[0];
                                oppId = '\'' + oldOpp.Id + '\'';
                                System.debug('*** oppId ' + oppId);
                                System.debug('*** dslList ' + dslList);
// clone DSH
                                processingObject = 'Cloning Delivery Schedule Header';
                                System.debug('*** dshId ' + dshId);
                                newDSH = cloneDSH(dshId);
                                System.debug('*** newDSH ' + newDSH);
                
                                if (newDSH == null) {
                                    System.debug('L2I_DSH__c NOT successfully cloned!');
                                    sw.errMsg = 'Delivery Schedule Header NOT successfully cloned.';
                                } else {
                                    System.debug('L2I_DSH__c successfully cloned!');
                                    insert newDSH;
                                    System.debug('*** newDSH.Id ' + newDSH.Id);
// clone Opportunity
                                    processingObject = 'Cloning Opportunity for Delivery Schedule and IFEC Product Category';
                                    newOpp = cloneOpportunity(oppId);
                                    sw.oppId = oppId;
                                    if (newOpp == null) {
                                        System.debug('Opportunity NOT successfully cloned!');
                                        sw.errMsg = 'Opportunity NOT successfully cloned.';
                                    } else {
                                        System.debug('Opportunity successfully cloned!');
                                        processingObject = 'Cloning Primary Quote';
                                        if (oldOpp.SBQQ__PrimaryQuote__c != null) {
                                            processingObject = 'Cloning Quote for Opportunity';
                                            clonedQuotes = L2I_QuoteCloneUtility.cloneSBQQQuotes(new Set<String>{
                                                  oldOpp.SBQQ__PrimaryQuote__c
                                            });
                                            if (clonedQuotes == null || clonedQuotes.size() == 0) {
                                                System.debug('Quote NOT successfully cloned!');
                                                sw.errMsg = 'Quote NOT successfully cloned.';
                                            } else {
                                                System.debug('Quote successfully cloned ' + clonedQuotes[0].Id);
                                                // uncheck the Revise checkbox on the old Quote
                                                SBQQ__Quote__c oldQuote = [
                                                      SELECT Id, L2I_Revised__c, SBQQ__Primary__c
                                                      FROM SBQQ__Quote__c
                                                      WHERE Id = :oldOpp.SBQQ__PrimaryQuote__c
                                                ];
                                                // the cloning process clears the primary checkbox and sets revised to true
                                                // however, this quote is cloned for another opportunity, so we need to keep this quote active
                                                oldQuote.L2I_Revised__c = false;
                                                oldQuote.SBQQ__Primary__c = true;
                                                update oldQuote;
                                
                                                newClonedQuote = clonedQuotes[0];
                                                if (isNewProgram == 'Yes') {
                                                    //newOpp.StageName = 'Pending Close';   // for Split
//                                                    newOpp.StageName = 'Handoff';   // for Split
                                                    newOpp.StageName = 'Quotation';   // for Split from PAC mtg 3/10
                                                    newOpp.L2I_Program_Num__c = null;
                                                    newOpp.PT_Program_Mgr__c = null;
                                                    newOpp.PT_Parts_List_Revision_Number__c = null;
                                                    newOpp.PT_Price_List__c = null;

                                                    // Added by Lipton for W-003360
                                                    Decimal nextSplitVersion = oldOpp.Opportunities__r.isEmpty() || oldOpp.Opportunities__r[0].Split_Version__c == null ? 1 : oldOpp.Opportunities__r[0].Split_Version__c + 1;
                                                    newOpp.Name = 'Split from ' + oldOpp.PT_Part_List_Name_Rev__c + ' (' + nextSplitVersion + ')';
                                                    newOpp.Split_Version__c = nextSplitVersion;
                                                    // End of W-003360
                                                } else {
                                                    //Added this line per WI 003560
                                                    newOpp.Name = 'New Config from CPL - ' + OldOpp.L2I_Program_num__r.name +' - ' + oldOpp.PT_Part_List_Name_Rev__c;
                                                    newOpp.StageName = 'Delivery';         // from PAC mtg 3/10
                                                    newOpp.L2I_Program_Num__c = sw.programId;
                                                    //                                                    newOpp.PT_Parts_List_Revision_Number__c = 1;
                                                    newOpp.PT_Parts_List_Revision_Number__c = null;
                                                }
                                                newOpp.L2I_Original_Opportunity__c = oldOpp.Id; // Added by Lipton for W-003360 Moved outside of If-Else scoped
                                                newOpp.PT_Part_List_Document_Generated__c = false;
                                                newOpp.PT_PL_Batch_In_Process__c = true;
                                                newOpp.SBQQ__PrimaryQuote__c = null;
//                                newOpp.L2I_Program_Num__c = null;
                                                newOpp.PT_Part_List_Name__c = '';
                                                newOpp.L2I_AircraftQuantity__c = dslToList.size();
                                                newOpp.PT_CPL_Document_Id__c = '';
                                                newOpp.PT_CPL_Document_Name__c = '';
                                                newOpp.PT_Current_Parts_List__c = null;
                                                newOpp.PT_Revised_Parts_List_Version_Trans__c = '';
                                                // clear any approval values
                                                newOpp.PT_PL_Approval_Approver__c = null;
                                                newOpp.PT_PL_Approval_Approver_Comments__c = '';
                                                newOpp.PT_PL_Approval_Date__c = null;
                                                newOpp.PT_PL_Approval_Status__c = null;
                                                newOpp.PT_PL_Approval_Submitted_Date__c = null;
                                                newOpp.PT_PL_Approval_Submitter__c = null;
                                                newOpp.PT_PL_Approval_Submitter_Comments__c = '';
                                                newOpp.PT_PL_Reverted_By__c = null;
                                                newOpp.PT_PL_Reverted_Date__c = null;
                                                insert newOpp;
                                
                                                newClonedQuote.SBQQ__Opportunity2__c = newOpp.Id;
                                                newClonedQuote.SBQQ__Primary__c = true;
                                                newClonedQuote.ApprovalStatus__c = null;
                                                update newClonedQuote;
                                
                                                // get updated newOpp values
                                                newOpp = [
                                                      SELECT Id, SBQQ__PrimaryQuote__c, L2I_Program_Num__c, PT_Part_List_Name__c,
                                                            Name, L2I_Delivery_Schedule__c, L2I_AircraftQuantity__c, PT_Part_List_Name_Rev__c,
                                                            PT_Parts_List_Revision_Number__c
                                                      FROM Opportunity
                                                      WHERE Id = :newOpp.Id
                                                ];
                                
                                                newOpp.SBQQ__PrimaryQuote__c = newClonedQuote.Id;
                                                newOpp.L2I_Delivery_Schedule__c = newDSH.Id;    // need to set after the insert as DSH is cleared on new Opp to prevent DSH on multiple Opps
                                                Integer revNbr = Integer.valueOf(newOpp.PT_Parts_List_Revision_Number__c);
                                                newOpp.PT_Revised_Parts_List_Version_Trans__c = PT_Program_Utils.revisionCharacter(revNbr);
                                                update newOpp;
                                				//Removed by Jan Geronga for W-003928: Start - Redundant Query
                                                /*newOpp = [
                                                      SELECT Id, SBQQ__PrimaryQuote__c, L2I_Program_Num__c, PT_Part_List_Name__c,
                                                            Name, L2I_Delivery_Schedule__c, L2I_AircraftQuantity__c, PT_Part_List_Name_Rev__c,
                                                            PT_Parts_List_Revision_Number__c
                                                      FROM Opportunity
                                                      WHERE Id = :newOpp.Id
                                                ];*/
                                                //Removed by Jan Geronga for W-003928: End

                                                sw.newOppId = newOpp.Id;
//                                sw.newOppName = newOpp.PT_Part_List_Name_Rev__c;
//                                sw.oppName = oldOpp.PT_Part_List_Name_Rev__c;
                                                sw.newOppName = newOpp.PT_Part_List_Name__c;
                                                sw.oppName = oldOpp.PT_Part_List_Name__c;
                                                oldOpp.L2I_AircraftQuantity__c = oldOpp.L2I_AircraftQuantity__c - dslToList.size();
                                                update oldOpp;
                                
                                                // move Shipsets
                                                processingObject = 'Moving ShipSets';
                                                moveShipsets(dslList, newDSH.Id, sw.programId, newOpp.Id);
                                                // platform event not needed per meeting 2/5
                                                // 2/23 - added it back again because no parts list was created for a new config
                                                if (!Test.isRunningTest()) {
                                                    if (isNewProgram != 'Yes') {
                                                        assignPartstoShipsets(newOpp);
                                                    }
                                                }
                                            }
                                        } else {
                                            System.debug('*** Source Opportunity has no Primary Quote!');
                                            sw.errMsg = 'Source Opportunity has no Primary Quote.';
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if (sw.errMsg != '') {
                System.debug('*** throwing error ' + sw.errMsg);
                throw new AuraHandledException(sw.errMsg);
            } else {
                if (isNewProgram == 'Yes' &&
                      progList.size() > 0) {
                    createChats(newOpp, progList[0], dslNames);
                }
            }
        } catch (Exception e) {
            System.debug('Exception error: ' + e);
            System.debug('*** Exception: There was an error: ' + processingObject + ' - ' + sw.errMsg + ' - ' + e.getMessage() +
                  ' StackTrace:' + e.getStackTraceString());
            throw new AuraHandledException('There was an error: ' + processingObject + ' -  ' + sw.errMsg + ' - ' + e.getMessage());
        }
        return sw;
    }
    
    private static L2I_DSH__c cloneDSH(String dshId) {
        L2I_DSH__c newDSH;
        String dshQuery = String.format(
              'SELECT {0} FROM L2I_DSH__c WHERE Id = {1}',
              new String[]{
                    String.join(
                          new List<String>(
                                L2I_DSH__c.SObjectType.getDescribe().fields.getMap().keySet()
                          ),
                          ','
                    ),
                    dshId
              }
        );
        L2I_DSH__c dsh = (L2I_DSH__c) Database.query(dshQuery);
        newDSH = dsh.clone(false, false, false, false);
        return newDSH;
    }
    
    private static Opportunity cloneOpportunity(String oppId) {
        Opportunity newOpp;
        String oppQuery = String.format(
              'SELECT {0} FROM Opportunity WHERE Id= {1}',
              new String[]{
                    String.join(
                          new List<String>(
                                Opportunity.SObjectType.getDescribe().fields.getMap().keySet()
                          ),
                          ','
                    ),
                    oppId
              }
        );
        Opportunity opp = (Opportunity) Database.query(oppQuery);
        newOpp = opp.clone(false, false, false, false);
        return newOpp;
    }
    
    private static void moveShipsets(List<L2I_DSL__c> dslList, String dshId, String programId, String newOppId) {
        Set<Id> splitDSLIds = new Set<Id>();
        System.debug('*** moveShipsets ');
        System.debug('*** dslList.size() ' + dslList.size());
        System.debug('*** dshId ' + dshId);
        System.debug('*** programId ' + programId);
        Integer highLineNumber = 0;
// move the DSLs to be split/configures
        for (L2I_DSL__c dsl : dslList) {
            dsl.Delivery_Schedule_Header__c = dshId;
            dsl.PT_Program__c = programId;
            dsl.Original_Opportunity__c = newOppId;
            // renumber Shipsets if this is a Split (no Program Id)
            if (programId == null){
                splitDSLIds.add(dsl.Id);
                String lineNumber;
                if (highLineNumber + 1 < 10) {
                    lineNumber = '00' + String.valueOf(highLineNumber + 1);
                } else if (highLineNumber + 1 > 9 && highLineNumber + 1 < 100) {
                    lineNumber = '0' + String.valueOf(highLineNumber + 1);
                } else {
                    lineNumber = String.valueOf(highLineNumber + 1);
                }
                String currentLineNumber = String.valueOf(highLineNumber);
                highLineNumber++;
                dsl.Line_Number__c = lineNumber;
                dsl.PT_Line_Number__c = PT_Program_Utils.characterSequencer(currentLineNumber);
            }
            System.debug('*** dsl to update ' + dsl);
        }
        if (!splitDSLIds.isEmpty() && splitDSLIds.size() > 0){
            clearSplitProgramOnAssets(splitDSLIds);
        }
        
        System.debug('*** update dslList.size() ' + dslList.size());
        update dslList;
    }
    
    private static void clearSplitProgramOnAssets(Set<Id> dslIds) {
        System.debug('*** Starting clearSplitProgramOnAssets ' + dslIds);
        List<Asset> assetsToUpdate = new List<Asset>();
        for (Asset ast : [
              SELECT Id, PT_Program__c
              FROM Asset
              WHERE PT_Install_Location__r.ShipSet__c IN :dslIds
        ]) {
            ast.PT_Program__c = null;
            assetsToUpdate.add(ast);
        }
        
        if (!assetsToUpdate.isEmpty() && assetsToUpdate.size() > 0){
            update assetsToUpdate;
        }
        System.debug('*** Exiting clearSplitProgramOnAssets');
    }
    
    private static void assignPartstoShipsets(Opportunity opp) {
        List<Assign_Parts_to_Shipset__e> addEvents = new List<Assign_Parts_to_Shipset__e>();
        Assign_Parts_to_Shipset__e event = new Assign_Parts_to_Shipset__e();
        event.QuoteId__c = opp.SBQQ__PrimaryQuote__c;
        event.DSL_Opportunity__c = 'Opportunity';
        addEvents.add(event);
        
        List<Database.SaveResult> results = EventBus.publish(addEvents);
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('====== Successfully published Assign_Parts_to_Shipset__e event for New Configuration');
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('====== Platform Event Publish Error for Assign_Parts_to_Shipset__e for New Configuration returned: ' +
                          err.getStatusCode() +
                          ' - ' +
                          err.getMessage());
                }
            }
        }
    }
    
    private static void createChats(Opportunity opp, PT_Program__c prog, String dslNames) {
        // add to new Opportunity
        FeedItem fi = new FeedItem();
        fi.ParentId = opp.Id;
        String chatMsg = 'Shipsets ' + dslNames + ' have been Split from Program: ' + prog.Name + ' ';
        chatMsg += URL.getSalesforceBaseUrl().toExternalForm() + '/' + prog.Id;
        chatMsg += ' to CPL: ' + opp.Name + ' ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id;
        fi.Body = chatMsg;
        insert fi;
        
        // add to Program
        fi = new FeedItem();
        fi.ParentId = prog.Id;
        chatMsg = 'Shipsets ' + dslNames + ' have been Split from Program: ' + prog.Name + ' ';
        chatMsg += URL.getSalesforceBaseUrl().toExternalForm() + '/' + prog.Id;
        chatMsg += ' to CPL: ' + opp.Name + ' ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id;
        fi.Body = chatMsg;
        insert fi;
    }
    
    @AuraEnabled
    public static dslWrapper checkActiveShipsets(String dslIdString) {
        dslWrapper dw = new dslWrapper();
        dw.dsls = '';
        dw.dslActiveCount = 0;
        List<String> dslToList = dslIdString.split(',');
        System.debug('*** dslToList ' + dslToList);
        try {
            for (L2I_DSL__c dsl : [
                  SELECT Id
                  FROM L2I_DSL__c
                  WHERE Id IN :dslToList
                  AND PT_isActive__c = 'Active'
               //W-003688 Commented   AND Aircraft__c = null
            ]) {
                dw.dsls = (dw.dsls != '') ? dw.dsls + ',' + dsl.Id : dsl.Id;
                dw.dslActiveCount++;
            }
        } catch (Exception e) {
            System.debug('Exception error: ' + e);
            System.debug('*** Exception: There was an error in checkActiveShipsets: ' + e.getMessage() +
                  ' StackTrace:' + e.getStackTraceString());
            throw new AuraHandledException('There was an error in checkActiveShipsets: ' + e.getMessage());
        }
        return dw;
    }
    
    public class dslWrapper {
        @AuraEnabled public String dsls { get; set; }
        @AuraEnabled public Integer dslActiveCount { get; set; }
        
        public dslWrapper() {
        
        }
    }
    
    public class splitWrapper {
        @AuraEnabled public String programId { get; set; }
        @AuraEnabled public String oppId { get; set; }
        @AuraEnabled public String newOppId { get; set; }
        @AuraEnabled public String oppName { get; set; }
        @AuraEnabled public String newOppName { get; set; }
        @AuraEnabled public String errMsg { get; set; }
        
        public splitWrapper() {
        }
    }
}