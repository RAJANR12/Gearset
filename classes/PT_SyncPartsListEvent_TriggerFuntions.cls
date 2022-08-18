/**
 *      @author       
 *      @date         
 *      @description  PT_SyncPartsListEvent_TriggerFuntions 
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *		--								--					Initial
 *		QOng							Sept-1-2021			W-003749 - Updated to include the new Revision Number for CR PPL Type in Asset
 */
public class PT_SyncPartsListEvent_TriggerFuntions {    
  
   /**
    * @Method Name        : processPartsListEvent
    * @Description        : This method Syncs the back to Quote / DSL when moving parts have been approved
    * @Author             : 
    * @Modification Log   : 
    * Ver       	Date       	  Author              	Modification
    * --			--			  --				    Initial Version
    **/
    public static void processPartsListEvent(List<Synchronize_Parts_List__e> newPartsListEventList) {
        for (Synchronize_Parts_List__e ple : newPartsListEventList) {
            if (ple.Synchronize_To__c == 'Quote') {
                syncPartsListToQuote(ple.OpportunityId__c);
            } else if (ple.Synchronize_To__c == 'DSL') {
                syncPartsListToDSL(ple.OpportunityId__c);
            }
        }
    }

   /**
    * @Method Name        : syncPartsListToQuote
    * @Description        : This method Syncs the back to Quote when moving parts have been approved
    * @Author             : 
    * @Modification Log   : 
    * Ver       	Date       	  	Author              	Modification
    * --			--			  	--				    	Initial Version
    * 				Sept-1-2021		MS Simplus QOng			W-003749 Included the PT_CR_Parts_List_Revision_Number__c for CR PPL Type
    *               Sept-1-2021     MS Simplus Khrisna      W-003786 Sync Proposed Part from Asset to QL for placeholder parts
    **/
    public static void syncPartsListToQuote(Id OpportunityId) {        
        Decimal revisionNumber = 0;
        List<PT_PriceList_Entry__c> insertPLE = new List<PT_PriceList_Entry__c>();
        List<PT_Install_Location__c> addInstallLocations = new List<PT_Install_Location__c>();
        List<PT_Install_Location__c> updateInstallLocations = new List<PT_Install_Location__c>();
        List<SBQQ__QuoteLineGroup__c> deleteQuoteLineGroups = new List<SBQQ__QuoteLineGroup__c>();
        List<Asset> addAssets = new List<Asset>();
        List<Asset> updateAssets = new List<Asset>();
        List<SBQQ__QuoteLine__c> deleteQuoteLines = new List<SBQQ__QuoteLine__c>();
        Set<String> installLocations = new Set<String>();
        Set<String> assets = new Set<String>();
        Set<Id> productIds = new Set<Id>();        
        Map<String, Id> installLocationsWithoutQLG = new Map<String, Id>();        
        Map<String, SBQQ__QuoteLine__c> existingQuoteLinesMap = new Map<String, SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> existingQLProductPriceMap = new Map<Id, SBQQ__QuoteLine__c>();
        Map <String, SBQQ__QuoteLineGroup__c> existingQuoteLineGroupMap = new Map<String, SBQQ__QuoteLineGroup__c>();
        Map<Id, PT_PriceList_Entry__c> productPLEMap = new Map<Id, PT_PriceList_Entry__c>();
        Set<String> sEff = new Set<String>();//Added by Jan Geronga for W-001972
        Set<String> sPDelEff = new Set<String>();//Added by Jan Geronga for W-001972
        List<L2I_DSL__c> listDSL = new List<L2I_DSL__c>();//Added by Jan Geronga for W-001972
        
        Opportunity oppty = [
              SELECT Id, AccountId, PT_Parts_List_Revision_Number__c, PT_Price_List__c,
                    PT_Price_List__r.PT_Program__r.Name, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__PriceBook__c,
                    SBQQ__PrimaryQuote__r.ApprovalStatus__c, PT_Part_List_Document_Generated__c, PT_PL_Batch_In_Process__c, L2I_Program_Num__c, 
                    Effectivity__c, Pending_Effectivity__c, Pending_Delete_Effectivity__c //Added by Jan Geronga for W-001972
            		,PT_PPL_Type__c, PT_CR_Parts_List_Revision_Number__c //W-003749
              FROM Opportunity
              WHERE Id = :OpportunityId
        ];

        revisionNumber = (oppty.PT_PPL_Type__c != NULL && oppty.PT_PPL_Type__c == 'CR') ? oppty.PT_CR_Parts_List_Revision_Number__c : oppty.PT_Parts_List_Revision_Number__c;
        
        List<PT_PriceList_Entry__c> priceListEntries = [
              SELECT Id, PT_Product__c, PT_UnitPrice__c
              FROM PT_PriceList_Entry__c
              WHERE PT_Program_Price_List__c = :oppty.PT_Price_List__c
        ];

        for (PT_PriceList_Entry__c ple : priceListEntries) {
            productPLEMap.put(ple.PT_Product__c, ple);
        }
        //Get Quote Line Group records to be created, updated or deleted

        for (SBQQ__QuoteLineGroup__c existingQuoteLineGroup : [SELECT Id, Name, SBQQ__SolutionGroup__c, PT_Seat_Count__c, PT_Seat_Model__c, PT_Seat_Vendor__c FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c =: oppty.SBQQ__PrimaryQuote__c]) {
            existingQuoteLineGroupMap.put(existingQuoteLineGroup.Name, existingQuoteLineGroup);
        }

        for (PT_Install_Location__c instLoc : [SELECT Id, Status__c, Solution_Group__c, Solution_Group__r.SBQQ__Description__c, Quote_Line_Group__c, Name, PT_Install_Location__c, PT_Seat_Count__c, PT_Seat_Model__c, PT_Seat_Vendor__c
                                               FROM PT_Install_Location__c
                                               WHERE Part_List_Opportunity__c =: OpportunityId AND Status__c = 'Active']) {
                                                   installLocations.add(instLoc.Name);
                                                   if (instLoc.Quote_Line_Group__c == null ) {
                                                       installLocationsWithoutQLG.put(instLoc.Name, instLoc.Id);
                                                   }
                                                   if (existingQuoteLineGroupMap.containsKey(instLoc.Name)) {
                                                       SBQQ__QuoteLineGroup__c qlg = existingQuoteLineGroupMap.get(instLoc.Name);
                                                       if (instLoc.Solution_Group__c != qlg.SBQQ__SolutionGroup__c || instLoc.Name != qlg.Name ||
                                                           instLoc.PT_Seat_Count__c != qlg.PT_Seat_Count__c || instLoc.PT_Seat_Model__c != qlg.PT_Seat_Model__c || instLoc.PT_Seat_Vendor__c != qlg.PT_Seat_Vendor__c) {
                                                               updateInstallLocations.add(instLoc);
                                                           }
                                                   } else {
                                                       addInstallLocations.add(instLoc);
                                                   }
                                               }

        for (SBQQ__QuoteLineGroup__c qlg : existingQuoteLineGroupMap.values()) {
            if (!installLocations.contains(qlg.Name)) {
                deleteQuoteLineGroups.add(qlg);
            }
        }

        //Get Quote Lines records to be created, updated or deleted    
        Id quoteId = [SELECT Name FROM SBQQ__Quote__C WHERE SBQQ__Primary__c = true and SBQQ__Opportunity2__c = :OpportunityId].Id;
       system.debug('>>revisionNumber: '+ revisionNumber);
        for (SBQQ__QuoteLine__c quoteLine : [SELECT Id, PT_Asset__r.PT_Status__c, SBQQ__Group__r.Name, SBQQ__ListPrice__c, SBQQ__Product__r.Name,  SBQQ__Product__c, SBQQ__Quantity__c, PT_Configured_Quantity__c
                                             FROM SBQQ__QuoteLine__c
                                             WHERE SBQQ__Quote__c = :quoteId]) {                                                  
                                                 existingQuoteLinesMap.put(quoteLine.SBQQ__Group__r.Name + '-' + quoteLine.SBQQ__Product__c, quoteLine);
                                                 existingQLProductPriceMap.put(quoteLine.SBQQ__Product__c, quoteLine);
        }

        for (Asset exisingPart : [SELECT Id, Name, Status, SBQQ__QuoteLine__c, PT_Install_Location__c, PT_Install_Location__r.Name, 
                                    Product2Id, Product2.ProductCode, Quantity, PT_Configured_Quantity__c, SBQQ__Discount__c,
                                    Price, // Added by Lipton for W-003670
                                    PT_Is_Placeholder_Part__c, // Added by Khrisna for W-003786
                                    PT_Proposed_Part_Code__c, PT_Proposed_Part_Nomenclature__c // End W-003786
                                  FROM Asset
                                  WHERE PT_Status__c = 'Active' AND PT_Revision_Number__c =: revisionNumber AND PT_Install_Location__r.Part_List_Opportunity__c =: OpportunityId]) {
                                      assets.add(exisingPart.PT_Install_Location__r.Name + '-' + exisingPart.Product2Id);
                                      
                                      System.debug('*****exisingPart ' + exisingPart);
                                      if (existingQuoteLinesMap.containsKey(exisingPart.PT_Install_Location__r.Name + '-' + exisingPart.Product2Id)) {
                                          SBQQ__QuoteLine__c ql = existingQuoteLinesMap.get(exisingPart.PT_Install_Location__r.Name + '-' + exisingPart.Product2Id);
                                          if (exisingPart.Quantity != ql.SBQQ__Quantity__c || exisingPart.PT_Configured_Quantity__c != ql.PT_Configured_Quantity__c) {
                                              updateAssets.add(exisingPart);
                                          }
                                      } else {
                                          addAssets.add(exisingPart);
                                      }
                                      productIds.add(exisingPart.Product2Id);
                                  }

        for (SBQQ__QuoteLine__c ql : existingQuoteLinesMap.values()) {
            if (ql.PT_Asset__r.PT_Status__c == 'Removed') {
                deleteQuoteLines.add(ql);
            }
        }

        System.debug('*****addAssets ' + addAssets);
        System.debug('*****updateAssets ' + updateAssets);

        if (addAssets.size() > 0 || updateAssets.size() > 0 || deleteQuoteLines.size() > 0) {
            List<SBQQ__QuoteLineGroup__c> newQuoteLineGroupList = new List<SBQQ__QuoteLineGroup__c>();            
            List<SBQQ__QuoteLineGroup__c> updateQuoteLineGroupList = new List<SBQQ__QuoteLineGroup__c>();            
            List<PT_Install_Location__c> instLocUpdateWithQLG = new List<PT_Install_Location__c>();            
            List<SBQQ__QuoteLine__c> newQuoteLineList = new List<SBQQ__QuoteLine__c>();  
            List<SBQQ__QuoteLine__c> updateQuoteLineList = new List<SBQQ__QuoteLine__c>();
            Set<Id> assetsToBeLinkedToQuoteLines = new Set<Id>();
            Map<String, Id> groupNameIdMap = new  Map<String, Id>();
            Map<String, SBQQ__QuoteLineGroup__c> groupMap = new  Map<String, SBQQ__QuoteLineGroup__c>();
            Map<Id,PricebookEntry> pbeProdMap = new Map<Id,PricebookEntry>();
            Map<Id, SBQQ__Cost__c> mCost = new Map<Id, SBQQ__Cost__c>();            
            Map<Id,Id> productNewPLEMap = new Map<Id,Id>(); 
            Map<String, Id> cloneQLProductGroupMap = new Map<String, Id>();
            
            List<SBQQ__Quote__c> quotes = [SELECT Id,ApprovalStatus__c 
                                           FROM SBQQ__Quote__C
                                           WHERE SBQQ__Primary__c = true and SBQQ__Opportunity2__c = :OpportunityId];
            
            List<SBQQ__Quote__c> clonedQuotes = null; // Lipton Abillar - Moved outside of the if clause for reusability
            
            for(SBQQ__Quote__c q : quotes){
                if (q.ApprovalStatus__c == 'Approved') {                    
                    clonedQuotes = L2I_QuoteCloneUtility.cloneSBQQQuotes(new Set<String>{quoteId});
                    quoteId = clonedQuotes[0].Id;
                }
                
            }            
            //Create quote line group            
            Integer newQLGSequence = existingQuoteLineGroupMap.size() + 1;
            for (PT_Install_Location__c addedIL : addInstallLocations) {
                SBQQ__QuoteLineGroup__c newQLG = new SBQQ__QuoteLineGroup__c();
                newQLG.SBQQ__Quote__c = quoteId;
                newQLG.SBQQ__SolutionGroup__c = addedIL.Solution_Group__c;
                newQLG.Name = addedIL.Name;
                newQLG.SBQQ__Description__c = addedIL.Solution_Group__r.SBQQ__Description__c;
                newQLG.SBQQ__ListTotal__c = 0.0;
                newQLG.SBQQ__CustomerTotal__c = 0.0;
                newQLG.SBQQ__NetTotal__c = 0.0;
                newQLG.SBQQ__Account__c = oppty.AccountId;
                newQLG.PT_Seat_Count__c = addedIL.PT_Seat_Count__c;
                newQLG.PT_Seat_Model__c = addedIL.PT_Seat_Model__c;
                newQLG.PT_Seat_Vendor__c = addedIL.PT_Seat_Vendor__c;
                newQLG.SBQQ__Number__c = newQLGSequence;
                newQuoteLineGroupList.add(newQLG);
                newQLGSequence++;
            }

            //update quote line group
            for (PT_Install_Location__c updatedIL : updateInstallLocations) {
                SBQQ__QuoteLineGroup__c updateQLG = new SBQQ__QuoteLineGroup__c();
                updateQLG.Id = updatedIL.Quote_Line_Group__c;
                updateQLG.SBQQ__SolutionGroup__c = updatedIL.Solution_Group__c;
                updateQLG.Name = updatedIL.Name;
                updateQLG.SBQQ__Description__c = updatedIL.Solution_Group__r.SBQQ__Description__c;
                updateQLG.PT_Seat_Count__c = updatedIL.PT_Seat_Count__c;
                updateQLG.PT_Seat_Model__c = updatedIL.PT_Seat_Model__c;
                updateQLG.PT_Seat_Vendor__c = updatedIL.PT_Seat_Vendor__c;
                updateQuoteLineGroupList.add(updateQLG);
            }

            if (newQuoteLineGroupList.size() > 0) {
                insert newQuoteLineGroupList;
            }

            if (updateQuoteLineGroupList.size() > 0) {
                update updateQuoteLineGroupList;
            }

            if (deleteQuoteLineGroups.size() > 0) {
                delete deleteQuoteLineGroups;
            }
           
            for (SBQQ__QuoteLineGroup__c qlg : [SELECT Id, Name, SBQQ__AdditionalDiscountRate__c FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :quoteId]) {
                groupNameIdMap.put(qlg.Name, qlg.Id);
                groupMap.put(qlg.Name, qlg);
            }
            
            // link quote line groups with New Install Location (Quotelinegroup = null)
            for (String instLocName : installLocationsWithoutQLG.keySet()) {
                if (groupNameIdMap.containsKey(instLocName)) {
                    instLocUpdateWithQLG.add(new PT_Install_Location__c (Id = installLocationsWithoutQLG.get(instLocName),
                                                                         Quote_Line_Group__c = groupNameIdMap.get(instLocName)));
                }
            }
            
            if (instLocUpdateWithQLG.size() > 0) {
                update instLocUpdateWithQLG;
            }

            for (PriceBookEntry pbe: [SELECT Id, Name, IsActive, UnitPrice, L2I_PART_DESCRIPTION__c,ProductCode, Product2Id, UseStandardPrice
                                      FROM PriceBookEntry
                                      WHERE Product2Id IN :productIds
                                      AND Pricebook2Id = :oppty.SBQQ__PrimaryQuote__r.SBQQ__PriceBook__c]) {
                                          pbeProdMap.put(pbe.Product2Id, pbe);
                                      }
            
            //Create Quote Lines
            System.debug('*** addAssets ='+ addAssets);
            
            //Added by Jan Geronga for W-003833: Moved Query outside for loop : Start            
            for(SBQQ__Cost__c c : [SELECT ID, SBQQ__Product__c, SBQQ__UnitCost__c FROM SBQQ__Cost__c WHERE SBQQ__Product__c IN: productIds]){
                mCost.put(c.SBQQ__Product__c, c);
            }
            //Added by Jan Geronga for W-003833: Moved Query outside for loop : End

            for (Asset addedAst : addAssets) {
                Decimal listPrice;
                // if the product exist in Program Price List, then take the list price from the Price List Entry.
                if (productPLEMap.containsKey(addedAst.Product2Id)) {
                    listPrice = productPLEMap.get(addedAst.Product2Id).PT_UnitPrice__c;
                    System.debug('*** List price on if ='+ listPrice);
                } else {
                    // if the product exist in quote, then take the list price from the quote line.
                    if (existingQLProductPriceMap.containsKey(addedAst.Product2Id)) {
                        listPrice = existingQLProductPriceMap.get(addedAst.Product2Id).SBQQ__ListPrice__c;
                        System.debug('*** List price on else ='+ listPrice);
                    } else {
                        listPrice = pbeProdMap.get(addedAst.Product2Id) != null ? (pbeProdMap.get(addedAst.Product2Id)).UnitPrice : 0;
                        System.debug('*** List price on last ='+ listPrice);
                    }
                    // Added by Lipton Abillar for W-003670
                    Double pbeUnitPrice = pbeProdMap.get(addedAst.Product2Id) != null ? (pbeProdMap.get(addedAst.Product2Id)).UnitPrice : 0;
                    Double discountValue = groupMap.get(addedAst.PT_Install_Location__r.Name).SBQQ__AdditionalDiscountRate__c != null ? groupMap.get(addedAst.PT_Install_Location__r.Name).SBQQ__AdditionalDiscountRate__c / 100 : 0;
                    Double UnitPrice = pbeUnitPrice - (pbeUnitPrice * discountValue);
                    // END of W-003670
                    insertPLE.add(new PT_PriceList_Entry__c(
                        PT_Program_Price_List__c = oppty.PT_Price_List__c,
                        PT_CanEscalate__c = TRUE,
                        PT_isActive__c = TRUE,
                        PT_StartDate__c = Date.today(),
                        PT_Status__c = 'Added',
                        PT_Product__c = addedAst.Product2Id,
                        PT_UnitPrice__c =  UnitPrice, // Added by Lipton Abillar for W-003670
                        Name = addedAst.Product2.ProductCode
                    ));
                }
                
                if(mCost.keySet().contains(addedAst.Product2Id)){//Added by Jan Geronga for W-003833
                    SBQQ__Cost__c cost = mCost.get(addedAst.Product2Id);//Added by Jan Geronga for W-003833
                    
                    // Added by Ashish for W-003592
                    //SBQQ__Cost__c cost = [select id,SBQQ__UnitCost__c from SBQQ__Cost__c
                    //where SBQQ__Product__c = :addedAst.Product2Id];
                    // Added by Ashish for W-003592 - End
                    
                    SBQQ__QuoteLine__c newQL = new SBQQ__QuoteLine__c();
                    newQL.SBQQ__Product__c = addedAst.Product2Id;
                    newQL.SBQQ__Group__c = groupNameIdMap.get(addedAst.PT_Install_Location__r.Name);
                    newQL.SBQQ__Quantity__c = addedAst.quantity;
                    newQL.PT_Configured_Quantity__c = addedAst.PT_Configured_Quantity__c;
                    newQL.SBQQ__Quote__c = quoteId;
                    newQL.PT_Asset__c = addedAst.Id;
                    newQL.SBQQ__ListPrice__c = listPrice;
                    //Added by Ashish :: W-003592
                    newQL.SBQQ__UnitCost__c = cost.SBQQ__UnitCost__c;
                    //Added by Ashish :: W-003592 - End
                    newQL.isNew__c = true; //Added by Jan Geronga for W-003812 
                    //newQL.SBQQ__PricebookEntryId__c = pbeProdMap.get(addedAst.Product2Id) != null ? (pbeProdMap.get(addedAst.Product2Id)).Id : null;
                    //newQL.SBQQ__Discount__c = null;
                    //newQL.SBQQ__AdditionalDiscountAmount__c = null;
                    //newQL.SBQQ__OptionDiscount__c = null;
                    //newQL.SBQQ__OptionDiscountAmount__c = null;
                    //newQL.SBQQ__PartnerDiscount__c = null;
                    //newQL.SBQQ__SpecialPrice__c = listPrice;
                    //newQL.SBQQ__SpecialPriceDescription__c = 'Program Price List Pricing - ' + oppty.PT_Price_List__r.PT_Program__r.Name;
                    //newQL.SBQQ__SpecialPriceType__c = 'Custom';
                    // Added by Khrisna for W-003786
                    newQL.PT_Proposed_Part_Code__c = addedAst.PT_Proposed_Part_Code__c;
                    newQL.PT_Proposed_Part_Nomenclature__c = addedAst.PT_Proposed_Part_Nomenclature__c;
                    // End W-003786
                    newQuoteLineList.add(newQL);
                    assetsToBeLinkedToQuoteLines.add(addedAst.Id);
                }
            }
            
            //Update Quote Lines
            for (SBQQ__QuoteLine__c cloneQL : [SELECT Id, SBQQ__Group__r.Name, SBQQ__Product__c, SBQQ__Quantity__c,  
                                                PT_Configured_Quantity__c,
                                                PT_Proposed_Part_Code__c, PT_Proposed_Part_Nomenclature__c // Added by Khrisna for W-003786
                                                FROM SBQQ__QuoteLine__c
                                                WHERE SBQQ__Quote__c = :quoteId]) {
                cloneQLProductGroupMap.put(cloneQL.SBQQ__Group__r.Name + '-' + cloneQL.SBQQ__Product__c, cloneQL.Id);
            }

            for (Asset updatedAst : updateAssets) {
                if (cloneQLProductGroupMap.containsKey(updatedAst.PT_Install_Location__r.Name + '-' + updatedAst.Product2Id)) {
                    SBQQ__QuoteLine__c updateQL = new SBQQ__QuoteLine__c();
                    updateQL.Id = cloneQLProductGroupMap.get(updatedAst.PT_Install_Location__r.Name + '-' + updatedAst.Product2Id);
                    updateQL.SBQQ__Quantity__c = updatedAst.quantity;
                    updateQL.PT_Configured_Quantity__c = updatedAst.PT_Configured_Quantity__c;
                    updateQL.isNew__c = true; //Added by Jan Geronga for W-003812 
                    // Added by Khrisna for W-003786
                    updateQL.PT_Proposed_Part_Code__c = updatedAst.PT_Proposed_Part_Code__c;
                    updateQL.PT_Proposed_Part_Nomenclature__c = updatedAst.PT_Proposed_Part_Nomenclature__c;
                    // End W-003786
                    updateQuoteLineList.add(updateQL);
                }
            }

            if (insertPLE.size() > 0) {
                insert insertPLE;
                for (PT_PriceList_Entry__c ple : insertPLE) {
                    productNewPLEMap.put(ple.PT_Product__c, ple.Id);
                }
                //PT_PriceList__c updatePriceList = new PT_PriceList__c(Id = oppty.PT_Price_List__c, PT_Status__c = 'Integration Pending');
                //update updatePriceList;
            }

            if (newQuoteLineList.size() > 0) {
                for (SBQQ__QuoteLine__c newQL : newQuoteLineList) {
                    if(productNewPLEMap.containsKey(newQL.SBQQ__Product__c)) {
                        newQL.PT_Price_List_Entry__c = productNewPLEMap.get(newQL.SBQQ__Product__c);
                    }
                }
                if(!Test.isRunningTest()){
                    insert newQuoteLineList;  
                }           
            }

            if (updateQuoteLineList.size() > 0) {
                system.debug('>>>>>>> updateQuoteLines List: ' +updateQuoteLineList);
                update updateQuoteLineList;
            }

            if (deleteQuoteLines.size() > 0) {
                List<SBQQ__QuoteLine__c> deleteQLsFromClonedQuote = [SELECT Id FROM SBQQ__QuoteLine__c WHERE PT_Asset__r.PT_Status__c = 'Removed' AND SBQQ__Quote__c = :quoteId];
                delete deleteQLsFromClonedQuote;
            }

            // Get all list of quote line for which assets to be needed.
            if(assetsToBeLinkedToQuoteLines.size() > 0){ //Added for checking by Jan Geronga W-003639
                List<Asset> assetsToBeUpdatedWithQL = new List<Asset>();
                //Added by Jan Geronga W-003639: Start
                List<SBQQ__QuoteLine__c> qlToBeDeleted = new List<SBQQ__QuoteLine__c>();
                Map<Id, Asset> mapAsset = new Map<Id, Asset>();
                Map<Id, SBQQ__QuoteLine__c> mapQL = new Map<Id, SBQQ__QuoteLine__c>();
                //Added by Jan Geronga W-003639: End
                
                for (SBQQ__QuoteLine__c ql : [SELECT Id, PT_Asset__c, SBQQ__ListPrice__c, SBQQ__Netprice__c, SBQQ__Group__r.Name FROM SBQQ__QuoteLine__c WHERE PT_Asset__c IN :assetsToBeLinkedToQuoteLines AND SBQQ__Quote__c = :quoteId]) {
                    //assetsToBeUpdatedWithQL.add(new Asset (Id = ql.PT_Asset__c, SBQQ__QuoteLine__c = ql.Id, SBQQ__ListPrice__c = ql.SBQQ__ListPrice__c, Price = ql.SBQQ__Netprice__c)); //Commented out by Jan Geronga for W-003639.
                    //Added by Jan Geronga W-003639: Start
                    mapQL.put(ql.PT_Asset__c, ql);
                }
                
                if(!mapQL.isEmpty()){
                    for(Asset newAsset : [SELECT Id, SBQQ__QuoteLine__c, SBQQ__ListPrice__c, Price, PT_Install_Location__c, PT_Install_Location__r.Name FROM Asset WHERE Id IN: mapQL.keySet()]){
                        newAsset.SBQQ__QuoteLine__c = mapQL.get(newAsset.Id).Id;
                        newAsset.SBQQ__ListPrice__c = mapQL.get(newAsset.Id).SBQQ__ListPrice__c;
                        newAsset.Price = mapQL.get(newAsset.Id).SBQQ__Netprice__c;
                        assetsToBeUpdatedWithQL.add(newAsset);
                        mapAsset.put(newAsset.Id, newAsset);
                    }
                }
                
                //Added by Jan Geronga W-003639: End
                if(assetsToBeUpdatedWithQL.size() > 0) {
                    update assetsToBeUpdatedWithQL;
                }
                
                //Added by Jan Geronga W-003639: Start
                for (SBQQ__QuoteLine__c quoteline : [SELECT Id, PT_Asset__c, SBQQ__Group__r.Name FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId AND PT_Asset__c IN: mapAsset.keySet()]){
                    if(mapAsset.get(quoteline.PT_Asset__c).PT_Install_Location__r.Name != quoteline.SBQQ__Group__r.Name){
                        quoteline.PT_Asset__c = null;
                        update quoteline;
                        qlToBeDeleted.add(quoteline);
                    }
                }
                if(qlToBeDeleted.size() > 0){
                    delete qlToBeDeleted;
                }
				//Added by Jan Geronga W-003639: End                
            }
        }
        //PT_ProgramPriceList_Utils.createUpdatePriceListEntries(quoteId, oppty.PT_Price_List__c);
        
        system.debug('>>>>>>>>>>>>>' +quoteId);
        syncPartsListToDSL(quoteId);

        // flag to allow the PL document to be generated
        oppty.SBQQ__PrimaryQuote__c = quoteId; // Updated by Jan Geronga for W-003441.
        oppty.PT_PL_Batch_In_Process__c = false;

        //Added by Jan Geronga for W-001972: Start
        if(oppty.Pending_Effectivity__c != null){
            oppty.Effectivity__c = !String.isBlank(oppty.Effectivity__c) ? oppty.Effectivity__c + ';' + oppty.Pending_Effectivity__c : oppty.Pending_Effectivity__c;
            oppty.Pending_Effectivity__c = null;
        }
        
        if(oppty.Pending_Delete_Effectivity__c != null){
            sEff.addAll(oppty.Effectivity__c.split(';'));
            sPDelEff.addAll(oppty.Pending_Delete_Effectivity__c.split(';'));
            
            sEff.removeAll(sPDelEff);
            oppty.Effectivity__c = String.join(new List<String>(sEff), ';');
            oppty.Pending_Delete_Effectivity__c = null;
            
            for(L2I_DSL__c dsl : [SELECT Id, Original_Opportunity__c, Aircraft__c FROM L2I_DSL__c WHERE Original_Opportunity__c =: oppty.Id AND PT_Tail_Number__c IN: sPDelEff]){
                dsl.Aircraft__c = null;
                listDSL.add(dsl);
            }
            
            if(listDSL.size() > 0){
                update listDSL;
            }
        }
        //Added by Jan Geronga for W-001972: End
        
        update oppty;
        
        //Added by Jan Geronga on 11/12/21 for W-003548: Start
        notifyOpptyOwner(oppty.Id);
        //Added by Jan Geronga on 11/12/21 for W-003548: End

        // generate CPL doc
        //        System.debug('*** Generating CPL Document via flow');
        //        Map<String, Object> flowParams = new Map<String, Object>();
        //        flowParams.put('oppId', oppty.Id);
        //        Flow.Interview.PT_Generate_Quote_Doc  genDocFlow = new Flow.Interview.PT_Generate_Quote_Doc (flowParams);
        //        genDocFlow.start();
    }

   /**
    * @Method Name        : syncPartsListToDSL
    * @Description        : This method Syncs the back to DSL when moving parts have been approved
    * @Author             : 
    * @Modification Log   : 
    * Ver       	Date       	  	Author              	Modification
    * --			--			  	--				    	Initial Version
    **/
    public static void syncPartsListToDSL(Id quoteId) {
        // Invoke flow for Calculating the Quote using CPQ API
        Map<String, Object> params = new Map<String, Object>();
        params.put('quoteId', quoteId);
        Flow.Interview.Calculate_Quote myFlow = new Flow.Interview.Calculate_Quote(params);
        myFlow.start();

        // Sync Parts List with DSL Assets
        PT_UpdateDSLWIthPartsListBatch batch = new PT_UpdateDSLWIthPartsListBatch(quoteId);
        Id batchId = Database.executeBatch(batch, 1);
    }
    
    /**
    * @Method Name        : notifyOpptyOwner
    * @Description        : sendNotificationTo Oppty Owner
    * @Author             : Jan Denrick Geronga / Managed Services Simplus
    * @Modification Log   :
    * Ver       	Date       	  Author              Modification
    * W-003548    	Nov-12-2021   MS Simplus Jan      Initial Version
    **/
    public static void notifyOpptyOwner(Id sOppId){
        Set<String> sOppCreatedBy = new Set<String>();
        
        // Get the Id for our custom notification type
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Post_Award_Price_List_Change'];
        EmailTemplate emailTemplate = [
                SELECT Id, Subject, Description, HtmlValue, DeveloperName,Body
                FROM EmailTemplate
                WHERE DeveloperName = 'Post_Award_Price_List_Change'];
        for(Opportunity opp : [SELECT Id, CreatedById, CreatedBy.Email, CreatedBy.Name, L2I_Program_Num__c, L2I_Program_Num__r.Name FROM Opportunity WHERE ID =: sOppId]){
            if(opp.L2I_Program_Num__c != null){
                String templateId = emailTemplate.Id;
                String opptyId = opp.CreatedById;
                String emailAddr = opp.CreatedBy.Email;
                String whatId = opp.Id;
                
                sOppCreatedBy.add(opp.CreatedById);
                
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, opptyId, whatId);
                
                String emailSubject = email.getSubject();
                String emailHTMLBody = email.getHtmlBody();

                email.setWhatId(whatId);
                
                List<String> sendTo = new List<String>();
                sendTo.add(emailAddr);
                email.setToAddresses(sendTo);
                
                email.setSubject(emailSubject);
                email.setHtmlBody(emailHTMLBody);
                email.saveAsActivity = false;
                
                if (!Test.isRunningTest()) {
                    Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        email
                            });
                    
                    for (Messaging.SendEmailResult rr : r) {
                        if (rr.isSuccess()) {
                            System.debug('Email result ' + rr.IsSuccess());
                        } else {
                            System.debug('Error Email result ' + rr.getErrors());
                        }
                    }
                }
                
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                
                notification.setTitle('Hi '+ opp.CreatedBy.Name + '!');
                notification.setBody('The Program: ' + opp.L2I_Program_Num__r.Name + ' ' + Label.Post_Award_Price_List_Change);            
                notification.setNotificationTypeId(notificationType.id);
                notification.setTargetId(opp.Id); // target object id
                try {
                    notification.send(sOppCreatedBy);
                }
                catch (Exception e) {
                    System.debug('Problem sending notification: ' + e.getMessage());
                }
            }
        }
    }
}