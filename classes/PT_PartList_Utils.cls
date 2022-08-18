/**
 *      @author       
 *      @date         
 *      @description  PT_PartList_Utils 
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *                                                          Initial
 *      QOng                            Sept-1-2021	        W-003749 - Updated to include the Changes for CR PPL Type
 *      Khrisna                         Sept-17-2021        W-003269 - Updated to populate Submitter Comments on Parts List Revision
 */
public class PT_PartList_Utils {

    private static String IFE_MISC = 'IFE MISCELLANEOUS'; // Added by Lipton for W-003649

   /**
    * @Method Name        : createPendingPartListRecords
    * @Description        : This method is used to create the Part List Revision which are pending.
    * @Author             : 
    * @Modification Log   : 
    * Ver           Date          Author                Modification
    *                                                   Initial Version
    **/
    @InvocableMethod(Label = 'Create Pending Part List Revision')
    public static List<Boolean> createPendingPartListRecords(List<Id> OpptyId) {
        Map<Id, Asset> partsList_toBeInsertedForDelete = new Map<Id, Asset>();
        List<Asset> partsList_toBeInsertedForReplace = new List<Asset>();
        // Get Opportunity Details for the first oportunity
        Opportunity oppty = [
              SELECT Id, PT_PL_Approval_Submitter__c, PT_PL_Approval_Approver__c, PT_PL_Approval_Approver_Comments__c,
                (SELECT Id, PT_Approval_Status__c, PT_Revision_Notes__c FROM Notes__r WHERE PT_Approval_Status__c = 'Pending' ORDER BY PT_Note_Name__c ASC), // Added by Lipton for W-003567
                (SELECT Id, PT_Approval_Status__c FROM Install_Locations__r WHERE PT_Approval_Status__c = 'Pending') // Added by Lipton for W-003567
              FROM Opportunity
              WHERE Id = :OpptyId[0]
        ];

        // Get all Assets related to the Opportunity Id
        List<Asset> partsList_toBeInserted = [
              SELECT Id, ParentId, Parent.PT_Status__c, Parent.Quantity, Parent.Product2.ProductCode, Product2.ProductCode, Parent.PT_Configured_Quantity__c,
                    PT_Status__c, PT_Install_Location__r.Name, PT_Notes__c, PT_Pending_Notes__c, PT_Notes_Status__c,
                    PT_Pending_Quantity__c, PT_Pending_Configured_Quantity__c, PT_Configured_Quantity__c, Quantity,
                    PT_Original_Install_Location__c, PT_Pending_Kit_Revision_Code__c, PT_Kit_Revision_Code__c,
                    PT_Proposed_Part_Code__c, Parent.PT_Proposed_Part_Code__c // Added by Lipton for W-003649
              FROM Asset
              WHERE PT_Install_Location__r.Part_List_Opportunity__c = :oppty.Id AND
              (PT_Status__c = 'New' OR PT_Status__c = 'Pending Removed' OR PT_Status__c = 'Pending Move' OR
              PT_Status__c = 'Pending Replaced' OR PT_Pending_Quantity__c != null OR
              PT_Pending_Configured_Quantity__c != null OR PT_Pending_Notes__c != null OR PT_Pending_Kit_Revision_Code__c != null
              OR PT_Install_Location__r.Part_List_Opportunity__r.Pending_Effectivity__c != null //Added by Jan Geronga for W-001972
              OR PT_Install_Location__r.Part_List_Opportunity__r.Pending_Delete_Effectivity__c != null ) //Added by Jan Geronga for W-001972
              ORDER BY Product2.ProductCode ASC
        ];
        // Added oppty.Notes__r and oppty.Install_Locations__r by Lipton for W-003567
        if (partsList_toBeInserted.isEmpty() && oppty.Notes__r.isEmpty() && oppty.Install_Locations__r.isEmpty()){
            return new List<Boolean>{false};   // no changes are pending
        }
        // Loop thru all the assets and create the Part List Revision records with status pending
        List<PT_Parts_List_Revision__c> plrList = new List<PT_Parts_List_Revision__c>();
        for (Asset ast : partsList_toBeInserted) {
            // Added by Lipton for W-003649
            // Description: Use PT_Proposed_Part_Code__c field as the product code if the asset is IFE MISCELLANEOUS
            String productCode = (ast.Product2.ProductCode == IFE_MISC && !string.isBlank(ast.PT_Proposed_Part_Code__c)) ? ast.PT_Proposed_Part_Code__c : ast.Product2.ProductCode;
            if (ast.PT_Status__c != 'Reinitialized') {
                String plrRevisedAction = '';
                String plrRevisedDescription = '';
                if (ast.PT_Status__c == 'New') {
                    plrRevisedAction = 'Part Added' + getNoteStatus(ast);
                    if (ast.PT_Pending_Configured_Quantity__c == null){     // first time approved it will come in with the config qty, not pending config
                        plrRevisedDescription = ast.PT_Install_Location__r.Name + ' - Added. (' + productCode + ' : A/C Qty ' + ast.PT_Configured_Quantity__c + ')' + getNoteDescription(ast);
                    } else {
                        plrRevisedDescription = ast.PT_Install_Location__r.Name + ' - Added. (' + productCode + ' : A/C Qty ' + ast.PT_Pending_Configured_Quantity__c + ')' + getNoteDescription(ast);
                    }
                    
//            } else if (ast.PT_Status__c == 'Reinitialized') {
//                plrRevisedAction = 'Part Reinitialized' + getNoteStatus(ast);
//                plrRevisedDescription = ast.PT_Install_Location__r.Name + ' - Reinitialized. (' + productCode + ' : A/C Qty ' + ast.Quantity + ')' + getNoteDescription(ast);
                } else if (ast.PT_Status__c == 'Pending Move') {
                    plrRevisedAction = 'Part Moved' + getNoteStatus(ast);
                    plrRevisedDescription = 'Moved P/N. (' + productCode + ' from ' + ast.PT_Original_Install_Location__c + ' to ' + ast.PT_Install_Location__r.Name + ')' + getNoteDescription(ast);
                } else if (ast.PT_Status__c == 'Pending Removed') {
                    partsList_toBeInsertedForDelete.put(ast.Id, ast);
                    continue;
                } else if (ast.PT_Status__c == 'Pending Replaced') {
                    partsList_toBeInsertedForReplace.add(ast);
                    continue;
                } else if (ast.PT_Pending_Quantity__c != null || ast.PT_Pending_Configured_Quantity__c != null) {
                    plrRevisedAction = 'Quantity changed' + getNoteStatus(ast);
                    plrRevisedDescription = ast.PT_Install_Location__r.Name + ' - Change Quantity. (' + productCode + ' : A/C Qty ' + ast.PT_Configured_Quantity__c +
                          ' to A/C Qty ' + ast.PT_Pending_Configured_Quantity__c +
                          ', Purchase Qty ' + ast.Quantity + ' to Purchase Qty ' + ast.PT_Pending_Quantity__c + ')' + getNoteDescription(ast);
                } else if (ast.PT_Pending_Kit_Revision_Code__c!= null) {
                    plrRevisedAction = 'Kit Rev changed' + getNoteStatus(ast);
                    plrRevisedDescription = ast.PT_Install_Location__r.Name + ' - Change Kit Rev. (' + productCode + ' : ' + ast.PT_Kit_Revision_Code__c +
                          ' to ' + ast.PT_Pending_Kit_Revision_Code__c + ')' + getNoteDescription(ast);
                } else if (!String.isBlank(ast.PT_Pending_Notes__c)) {
                    plrRevisedAction = 'Notes changed' + getNoteStatus(ast);
                    plrRevisedDescription = plrRevisedDescription = getNoteDescription(ast);
                } else if (ast.PT_Status__c == 'Active' || ast.PT_Status__c == 'Reinitialized') {
                    plrRevisedAction = getNoteStatus(ast);
                    plrRevisedDescription = getNoteDescription(ast);
                } else {
                    plrRevisedAction = ast.PT_Status__c + getNoteStatus(ast);
                    plrRevisedDescription = ast.PT_Status__c + getNoteDescription(ast);
                }
                plrList.add(new PT_Parts_List_Revision__c(
                      PT_Part_List_Opportunity__c = oppty.Id,
                      Revised_Action__c = plrRevisedAction,
                      Revised_Description__c = plrRevisedDescription,
                      Asset__c = ast.Id
                ));
            }
        }

        for (Asset ast : partsList_toBeInsertedForReplace) {
            // Added by Lipton for W-003649
            // Description: Use PT_Proposed_Part_Code__c field as the product code if the asset is IFE MISCELLANEOUS
            String productCode = (ast.Product2.ProductCode == IFE_MISC && !string.isBlank(ast.PT_Proposed_Part_Code__c)) ? ast.PT_Proposed_Part_Code__c : ast.Product2.ProductCode;
            String productCodeParent = (ast.Parent.Product2.ProductCode == IFE_MISC && !string.isBlank(ast.Parent.PT_Proposed_Part_Code__c)) ? ast.Parent.PT_Proposed_Part_Code__c : ast.Parent.Product2.ProductCode;
            
            String plrRevisedAction = '';
            String plrRevisedDescription = '';
            if (ast.ParentId != null && ast.PT_Pending_Quantity__c == ast.Parent.Quantity && (ast.Parent.PT_Status__c == 'Pending Removed' || ast.Parent.PT_Status__c == 'Pending Removed/Replaced')) {
                plrRevisedAction = 'Part Replaced' + getNoteStatus(ast);
                plrRevisedDescription = ast.PT_Install_Location__r.Name + ' - Replaced. (' + productCodeParent + ' : A/C Qty ' + ast.Parent.PT_Configured_Quantity__c +
                      ' to ' + productCode + ' : A/C Qty ' + ast.PT_Pending_Configured_Quantity__c + ')' + getNoteDescription(ast);
                partsList_toBeInsertedForDelete.get(ast.ParentId).PT_Status__c = 'Pending Removed/Replaced';
                if (partsList_toBeInsertedForDelete.containsKey(ast.ParentId)) {
                    partsList_toBeInsertedForDelete.get(ast.ParentId).PT_Status__c = 'Pending Removed/Replaced';
                }
            } else if (ast.Parent != null && ast.PT_Pending_Quantity__c != ast.Parent.Quantity && (ast.Parent.PT_Status__c == 'Pending Removed' || ast.Parent.PT_Status__c == 'Pending Removed/Replaced')) {
                plrRevisedAction = 'Part Replaced (with multiple parts)' + getNoteStatus(ast);
                plrRevisedDescription = ast.PT_Install_Location__r.Name + ' - Replaced. (' + productCodeParent + ' : A/C Qty ' + ast.Parent.PT_Configured_Quantity__c +
                      ' to ' + productCode + ' : A/C Qty ' + ast.PT_Pending_Configured_Quantity__c + ')' + getNoteDescription(ast);
                if (partsList_toBeInsertedForDelete.containsKey(ast.ParentId)) {
                    partsList_toBeInsertedForDelete.get(ast.ParentId).PT_Status__c = 'Pending Removed/Replaced';
                }
            } else {
                plrRevisedAction = ast.PT_Status__c + getNoteStatus(ast);
                plrRevisedDescription = ast.PT_Status__c + getNoteDescription(ast);
            }
            plrList.add(new PT_Parts_List_Revision__c(
                  PT_Part_List_Opportunity__c = oppty.Id,
                  Revised_Action__c = plrRevisedAction,
                  Revised_Description__c = plrRevisedDescription,
                  Asset__c = ast.Id
            ));
        }

        for (Asset ast : partsList_toBeInsertedForDelete.values()) {
            // Added by Lipton for W-003649
            // Description: Use PT_Proposed_Part_Code__c field as the product code if the asset is IFE MISCELLANEOUS
            String productCode = (ast.Product2.ProductCode == IFE_MISC && !string.isBlank(ast.PT_Proposed_Part_Code__c)) ? ast.PT_Proposed_Part_Code__c : ast.Product2.ProductCode;

            String plrRevisedAction = '';
            String plrRevisedDescription = '';
            if (ast.PT_Status__c == 'Pending Removed' ||
                  ast.PT_Status__c == 'Pending Removed/Replaced'  ) {
                plrRevisedAction = 'Part Deleted' + getNoteStatus(ast);
                plrRevisedDescription = ast.PT_Install_Location__r.Name + ' - Deleted. (' + productCode + ' : A/C Qty ' + ast.PT_Configured_Quantity__c + ')' + getNoteDescription(ast);

                plrList.add(new PT_Parts_List_Revision__c(
                      PT_Part_List_Opportunity__c = oppty.Id,
                      Revised_Action__c = plrRevisedAction,
                      Revised_Description__c = plrRevisedDescription,
                      Asset__c = ast.Id
                ));
            }
        }
        
        // Added by Lipton for W-004070
        for (PT_Note__c notes : oppty.Notes__r) {
            plrList.add(new PT_Parts_List_Revision__c(
                PT_Part_List_Opportunity__c = oppty.Id,
                Revised_Action__c = notes.PT_Revision_Notes__c,
                Revised_Description__c = notes.PT_Revision_Notes__c
          ));
        }

        // If Part List Size is greater than zero then insert records.
        if (plrList.size() > 0) {
            insert plrList;
        }
        return new List<Boolean>{true};
    }

   /**
    * @Method Name        : updateOpportunityPostApproval
    * @Description        : This method is used to update the Opportunity record post approval.
    * @Author             : 
    * @Modification Log   : 
    * Ver           Date		Author					Modification
    *                                                   Initial Version
    * 				Oct-21		QOng					W-003749 - CR Changes
    **/
    public static void updateOpportunityPostApproval(Id OpptyId) {
        // Get Opportunity Details for the this oportunity
        Opportunity oppty = [
              SELECT Id, LastModifiedById, OwnerId, PT_Parts_List_Revision_Number__c, PT_Revised_Parts_List_Version_Trans__c,
            		 L2I_Program_Num__c, L2I_Program_Num__r.Name, PT_Part_List_Name__c, PT_PPL_Type__c
                     , PT_PL_Approval_Submitter_Comments__c // Khrisna W-003269
              FROM Opportunity
              WHERE Id = :OpptyId
        ];

        // if PT_Parts_List_Revision_Number__c = 0, set fields for auto approved
        if (oppty.PT_Parts_List_Revision_Number__c == 0) {
            oppty.PT_PL_Approval_Submitter__c = oppty.OwnerId;
            oppty.PT_PL_Approval_Approver__c = oppty.LastModifiedById;
            oppty.PT_PL_Approval_Date__c = System.now();
            oppty.PT_PL_Approval_Approver_Comments__c = 'Created by P&L Upload Program';
            // oppty.PT_PL_Approval_Submitter_Comments__c = 'Created by P&L Upload Program'; // Khrisna W-003269
        }
        // Update opportunity record with next revision code
        oppty.PT_Parts_List_Revision_Number__c = (oppty.PT_Parts_List_Revision_Number__c + 1);
        oppty.PT_Revised_Parts_List_Version_Trans__c = PT_Program_Utils.revisionCharacter(Integer.valueOf(oppty.PT_Parts_List_Revision_Number__c));
        
        //W-003749 Populate PT_Part_List_Name__c based on the PT_Part_List Rev name that will be generated for 
        if('CR'== oppty.PT_PPL_Type__c && String.isBlank(oppty.PT_Part_List_Name__c) && oppty.L2I_Program_Num__c != NULL ){            
        	oppty.PT_Part_List_Name__c = 'CR-' + oppty.L2I_Program_Num__r.Name + '-' + oppty.PT_Parts_List_Revision_Number__c; 
        } 
        update oppty;
    }

   /**
    * @Method Name        : updatePartListPostApproval
    * @Description        : This method is used to update Part List Revision Records post approval.
    * @Author             : 
    * @Modification Log   : 
    * Ver           Date			Author			Modification
    *                                               Initial Version
    *            	Sept-17-2021    Khrisna         W-003269 Updated to populate Submitter Comments on Parts List Revision
    *     			Oct-21			QOng			W-003749 - CR Changes
    **/
    public static void updatePartListPostApproval(Id OpptyId) {
        // Get Opportunity Details for the this oportunity
        Opportunity oppty = [
              SELECT Id, PT_PL_Approval_Submitter__c, PT_PL_Approval_Approver__c, PT_PL_Approval_Date__c,
                    PT_Parts_List_Revision_Number__c, PT_PL_Approval_Approver_Comments__c,
                    PT_Part_List_Name__c, PT_Revised_Parts_List_Version_Trans__c
            		, PT_CR_Parts_List_Revision_Number__c, PT_CR_Parts_List_Revision_Trans__c //W-003749
                    , PT_PL_Approval_Submitter_Comments__c //Khrisna W-003269
              FROM Opportunity
              WHERE Id = :OpptyId
        ];
        // Update Part List Revision Records which belongs to this Oppty and PT_Parts_List_Revision_Number__c = null
        List<PT_Parts_List_Revision__c> partsList_toBeUpdated = [
              SELECT Id, PT_Submitter__c, PT_Approver__c, PT_Date_approved__c, PT_Approver_Comments__c, PT_Parts_List_Revision_Number__c, PT_Part_List_Opportunity__r.PT_PPL_Type__c
              FROM PT_Parts_List_Revision__c
              WHERE PT_Part_List_Opportunity__c = :oppty.Id AND PT_Parts_List_Revision_Number__c = null
        ];

        for (PT_Parts_List_Revision__c plr : partsList_toBeUpdated) {
            plr.PT_Submitter__c = oppty.PT_PL_Approval_Submitter__c;
            plr.PT_Approver__c = oppty.PT_PL_Approval_Approver__c;
            plr.PT_Date_approved__c = oppty.PT_PL_Approval_Date__c ;
            plr.PT_Approver_Comments__c = oppty.PT_PL_Approval_Approver_Comments__c;
          	plr.PT_Parts_List_Revision_Number__c = ( plr.PT_Part_List_Opportunity__r.PT_PPL_Type__c == 'CR') ?  oppty.PT_CR_Parts_List_Revision_Number__c : oppty.PT_Parts_List_Revision_Number__c; 			//W-003749
           	plr.PT_Revised_Parts_List_Version_Trans__c = ( plr.PT_Part_List_Opportunity__r.PT_PPL_Type__c == 'CR') ? oppty.PT_CR_Parts_List_Revision_Trans__c : oppty.PT_Revised_Parts_List_Version_Trans__c;	//W-003749
            plr.PT_Part_List_Name__c = oppty.PT_Part_List_Name__c;
            // plr.PT_Submitter_Comments__c = oppty.PT_PL_Approval_Submitter_Comments__c; 
            plr.PT_Submitter_Comments__c = oppty.PT_Parts_List_Revision_Number__c == 1 ? 'Created by P&L Upload Program' : oppty.PT_PL_Approval_Submitter_Comments__c; // Added by Khrisna W-003269
        }

        // If Part List Size is greater than zero then update records.
        if (partsList_toBeUpdated.size() > 0) {
            update partsList_toBeUpdated;
        }
    }

   /**
    * @Method Name        : updateAssetsOnPartListApproval
    * @Description        : Update Assets on Part List Approval
    * @Author             : 
    * @Modification Log   : 
    * Ver           Date		Author                	Modification
    *                                                   Initial Version    
    *     			Oct-21		QOng					W-003749 - CR Changes
    **/
    public static void updateAssetsOnPartListApproval(Id oppId) {
        List<Asset> assetList = new List<Asset>();
        for (Asset ast : [
              SELECT Id, Quantity, PT_Pending_Quantity__c, PT_Configured_Quantity__c,
                    PT_Pending_Configured_Quantity__c, PT_Status__c, PT_Install_Location__r.Status__c,
                    PT_Install_Location__c, PT_Can_Be_Processed__c, PT_Reason__c, PT_Pending_Reason__c,
                    PT_Install_Location__r.Part_List_Opportunity__c, PT_Revision_Number__c, PT_Pending_Kit_Revision_Code__c,
                    PT_Install_Location__r.Part_List_Opportunity__r.PT_Parts_List_Revision_Number__c, PT_Kit_Revision_Code__c,
                  	PT_Install_Location__r.Part_List_Opportunity__r.PT_CR_Parts_List_Revision_Number__c, PT_Install_Location__r.Part_List_Opportunity__r.PT_PPL_Type__c, //W-003749
                    PT_Notes__c, PT_Pending_Notes__c, PT_Notes_Status__c
              FROM Asset
              WHERE PT_Install_Location__r.Part_List_Opportunity__c = :oppId
              AND PT_Install_Location__r.Status__c = 'Active'
//                      AND PT_Can_Be_Processed__c = true
        ]) {
            //System.debug('*** ast ' + ast);
            Boolean setRevNbr = false;
            if (ast.PT_Status__c == 'New' ||
                  ast.PT_Status__c == 'Reinitialized' ||
                  ast.PT_Status__c == 'Pending Move' ||
                  ast.PT_Status__c == 'Pending Replaced') {
                ast.PT_Status__c = 'Active';
                ast.PT_Original_Install_Location__c = '';
                setRevNbr = true;
            }
            if (ast.PT_Status__c == 'Pending Removed') {
                ast.PT_Status__c = 'Removed';
                setRevNbr = true;
            }

            if (ast.PT_Pending_Notes__c == 'Remove Notes'){
                // clear the notes
                ast.PT_Notes__c = '';
                ast.PT_Pending_Notes__c = '';
                ast.PT_Notes_Status__c = '';
                setRevNbr = true;
            } else if (!String.isBlank(ast.PT_Pending_Notes__c)) {
                ast.PT_Notes__c = ast.PT_Pending_Notes__c;
                ast.PT_Pending_Notes__c = '';
                ast.PT_Notes_Status__c = '';
                setRevNbr = true;
            } else {
                // no change
            }
            
            if (ast.PT_Pending_Quantity__c != null ||
                ast.PT_Pending_Configured_Quantity__c != null) {
                    if (ast.PT_Pending_Quantity__c != null) {
                        ast.Quantity = ast.PT_Pending_Quantity__c;
                        ast.PT_Pending_Quantity__c = null;
                        setRevNbr = true;
                    }
                    if (ast.PT_Pending_Configured_Quantity__c != null) {
                        ast.PT_Configured_Quantity__c = ast.PT_Pending_Configured_Quantity__c;
                        ast.PT_Pending_Configured_Quantity__c = null;
                        setRevNbr = true;
                    }
                  }
            
            if (!String.isBlank(ast.PT_Pending_Kit_Revision_Code__c)){
                ast.PT_Kit_Revision_Code__c = ast.PT_Pending_Kit_Revision_Code__c;
                ast.PT_Pending_Kit_Revision_Code__c = '';
                setRevNbr = true;
            }
            
            ast.PT_Reason__c = '';
            
            if (setRevNbr) {
                ast.PT_Revision_Number__c = ast.PT_Install_Location__r.Part_List_Opportunity__r.PT_Parts_List_Revision_Number__c;  
                //W-003749 START
                if( ast.PT_Install_Location__c != NULL &&  ast.PT_Install_Location__r.Part_List_Opportunity__c != NULL &&  'CR' == ast.PT_Install_Location__r.Part_List_Opportunity__r.PT_PPL_Type__c ){
                    ast.PT_Revision_Number__c = ast.PT_Install_Location__r.Part_List_Opportunity__r.PT_CR_Parts_List_Revision_Number__c;   
                }
                //W-003749 END
            }
            assetList.add(ast);
        }
        if (assetList.size() > 0) {
            update assetList;
        }
    }

   /**
    * @Method Name        : createSyncPartsListToQuoteEvent
    * @Description        : Publish an event to Trigger Synchronize_Parts_List__e
    * @Author             : 
    * @Modification Log   : 
    * Ver           Date          Author                Modification
    *                                                   Initial Version
    **/
    public static void createSyncPartsListToQuoteEvent(Id opptyId) {
        List<Synchronize_Parts_List__e> addEvents = new List<Synchronize_Parts_List__e>();
        Synchronize_Parts_List__e event = new Synchronize_Parts_List__e();
        System.debug('===PT_PartList_Utils.createSyncPartsListToQuoteEvent');
        event.OpportunityId__c = opptyId;
        event.Synchronize_To__c = 'Quote';
        addEvents.add(event);
        if (addEvents.size() > 0) {
            List<Database.SaveResult> results = EventBus.publish(addEvents);
            System.debug('===PT_PartList_Utils.createSyncPartsListToQuoteEvent :: results :: ' +  results.get(0));
        }
    }
/*
    public static void createSyncPartsListToDSLEvent(Id opptyId) {
        List<Synchronize_Parts_List__e> addEvents = new List<Synchronize_Parts_List__e>();
        Synchronize_Parts_List__e event = new Synchronize_Parts_List__e();
        event.OpportunityId__c = opptyId;
        event.Synchronize_To__c = 'DSL';
        addEvents.add(event);
        if (addEvents.size() > 0) {
            List<Database.SaveResult> results = EventBus.publish(addEvents);
        }
    }
*/
//    public static void generateDocSerialzePartList(Id quoteId) {
//        // generate the Quote Proposal document and serialize related SOQL data
//        System.debug('*** generateDocSerialzePartList ' + quoteId);
//        PT_QuoteService.genQuoteDoc(quoteId);
//    }
    //
    
   /**
    * @Method Name        : syncPriceFromQuoteLinesToAssets
    * @Description        : Method to sync the price from quote lines to its associated opportunity assets
    * @Author             : 
    * @Modification Log   : 
    * Ver           Date          Author                Modification
    *                                                   Initial Version
    **/
    public static void syncPriceFromQuoteLinesToAssets(Id quoteId) {
        List<Asset> assetsToBeUpdatedForPrice = new List<Asset>();
        for (SBQQ__QuoteLine__c ql : [
            SELECT Id, PT_Asset__c, PT_Asset__r.SBQQ__ListPrice__c, PT_Asset__r.Price, SBQQ__ListPrice__c, SBQQ__Netprice__c, SBQQ__Quantity__c, PT_Configured_Quantity__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c = :quoteId AND PT_Asset__c != null
        ]) {
            
            //System.debug('======= PT_PartList_Utils.syncPriceFromQuoteLinesToAssets:: ql.PT_Asset__c :: ' + ql.PT_Asset__c );
            
            if (ql.SBQQ__ListPrice__c != ql.PT_Asset__r.SBQQ__ListPrice__c || ql.SBQQ__Netprice__c != ql.PT_Asset__r.Price) {
                assetsToBeUpdatedForPrice.add(new Asset (Id = ql.PT_Asset__c, SBQQ__ListPrice__c = ql.SBQQ__ListPrice__c, Price = ql.SBQQ__Netprice__c,
                                                         Quantity = ql.SBQQ__Quantity__c, PT_Configured_Quantity__c = ql.PT_Configured_Quantity__c));
            }
            
        }
        // Ashish Moved the below code out of FOR Loop
        System.debug('======= PT_PartList_Utils.syncPriceFromQuoteLinesToAssets:: assetsToBeUpdatedForPrice.size() :: ' + assetsToBeUpdatedForPrice.size() );
        if (assetsToBeUpdatedForPrice.size() > 0) {
            update assetsToBeUpdatedForPrice;
        }
    }

   /**
    * @Method Name        : syncPriceFromQuoteLinesToDSLAssets
    * @Description        : Method to sync the price from quote lines to its associated DSL assets
    * @Author             : 
    * @Modification Log   : 
    * Ver           Date          Author                Modification
    *                                                   Initial Version
    **/
    public static void syncPriceFromQuoteLinesToDSLAssets(Id quoteId) {
        List<Asset> dslAssetsToBeUpdatedForPrice = new List<Asset>();
        
        System.debug('======= PT_PartList_Utils.syncPriceFromQuoteLinesToDSLAssets ');
        
        List<Asset> astQry = [
              SELECT Id, PT_Install_Location__r.ShipSet__c, SBQQ__ListPrice__c, Price, SBQQ__QuoteLine__r.SBQQ__ListPrice__c, SBQQ__QuoteLine__r.SBQQ__Netprice__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c, SBQQ__QuoteLine__r.PT_Configured_Quantity__c
              FROM Asset
              WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c = :quoteId AND PT_Install_Location__r.ShipSet__c != null ];
        
        System.debug('======= PT_PartList_Utils.syncPriceFromQuoteLinesToDSLAssets:: Suresh :: Current Quote ID :: ' + quoteId );
        
        
        
        for (Asset ast : astQry) {
                  
            if (ast.SBQQ__ListPrice__c != ast.SBQQ__QuoteLine__r.SBQQ__ListPrice__c || ast.Price != ast.SBQQ__QuoteLine__r.SBQQ__Netprice__c) {
                dslAssetsToBeUpdatedForPrice.add(new Asset (Id = ast.Id, SBQQ__ListPrice__c = ast.SBQQ__QuoteLine__r.SBQQ__ListPrice__c,
                      Price = ast.SBQQ__QuoteLine__r.SBQQ__Netprice__c, Quantity = ast.SBQQ__QuoteLine__r.SBQQ__Quantity__c,
                      PT_Configured_Quantity__c = ast.SBQQ__QuoteLine__r.PT_Configured_Quantity__c));
            }

            /*if (dslAssetsToBeUpdatedForPrice.size() > 0) {
                update dslAssetsToBeUpdatedForPrice;
            }*/// Ashish Moving it down
        }
        
        // Ashish moved the above code out of the for loop 
         if (dslAssetsToBeUpdatedForPrice.size() > 0) {
                update dslAssetsToBeUpdatedForPrice;
            }
    
    }

   /**
    * @Method Name        : getNoteStatus
    * @Description        : 
    * @Author             : 
    * @Modification Log   : 
    * Ver           Date          Author                Modification
    *                                                   Initial Version
    **/
    public static String getNoteStatus(Asset ast) {
        List<PT_OpportunityService.NoteStatusWrapper> nswList = new List<PT_OpportunityService.NoteStatusWrapper>();
        String status = '';
        Integer addCount = 0;
        Integer deleteCount = 0;
        if (!String.isBlank(ast.PT_Notes_Status__c)) {
            nswList = (List<PT_OpportunityService.NoteStatusWrapper>) JSON.deserialize(ast.PT_Notes_Status__c, List<PT_OpportunityService.NoteStatusWrapper>.class);
            for (PT_OpportunityService.NoteStatusWrapper nsw : nswList) {
                if (nsw.noteStatus == 'Add') {
                   addCount++;
                }
                if (nsw.noteStatus == 'Delete') {
                    deleteCount++;
                }
            }
        }
        if (addCount > 0 && deleteCount > 0){
            status = ' with Notes added and deleted';
        }
        if (addCount > 0 && deleteCount == 0){
            status = ' with Notes added';
        }
        if (addCount == 0 && deleteCount > 0){
            status = ' with Notes deleted';
        }
//        if (ast.PT_Note_Status__c == 'Add') {
//            status = ' with Note added';
//        } else if (ast.PT_Note_Status__c == 'Replace') {
//            status = ' with Note added and deleted';
//        } else if (ast.PT_Note_Status__c == 'Delete') {
//            status = ' with Note deleted';
//        } else {
//            status = '';
//        }
        return status;
    }

   /**
    * @Method Name        : getNoteDescription
    * @Description        : 
    * @Author             : 
    * @Modification Log   : 
    * Ver           Date          Author                Modification
    *                                                   Initial Version
    **/
    public static String getNoteDescription(Asset ast) {
        List<PT_OpportunityService.NoteStatusWrapper> nswList = new List<PT_OpportunityService.NoteStatusWrapper>();
        String addNotes = '';
        String deleteNotes = '';

        // Added by Lipton for W-003649
        // Description: Use PT_Proposed_Part_Code__c field as the product code if the asset is IFE MISCELLANEOUS
        String productCode = (ast.Product2.ProductCode == IFE_MISC && !string.isBlank(ast.PT_Proposed_Part_Code__c)) ? ast.PT_Proposed_Part_Code__c : ast.Product2.ProductCode;

        if (!String.isBlank(ast.PT_Notes_Status__c)) {
            nswList = (List<PT_OpportunityService.NoteStatusWrapper>) JSON.deserialize(ast.PT_Notes_Status__c, List<PT_OpportunityService.NoteStatusWrapper>.class);
            for (PT_OpportunityService.NoteStatusWrapper nsw : nswList) {
                if (nsw.noteStatus == 'Add') {
                    addNotes = String.isBlank(addNotes) ? nsw.noteName : addNotes + ',' + nsw.noteName;
                }
                if (nsw.noteStatus == 'Delete') {
                    deleteNotes = String.isBlank(deleteNotes) ? nsw.noteName : deleteNotes + ',' + nsw.noteName;
                }
            }
        }
        String description = '';
        if (!String.isBlank(addNotes) && !String.isBlank(deleteNotes)){
            description = ' ' + ast.PT_Install_Location__r.Name + ' - Add Notes (' + productCode + ' : ' + addNotes + ')' +
                  ' - Delete Notes (' + productCode + ' : ' + deleteNotes + ')';
        }
        if (String.isBlank(addNotes) && !String.isBlank(deleteNotes)){
            description = ' ' + ast.PT_Install_Location__r.Name + ' - Delete Notes (' + productCode + ' : ' + deleteNotes + ')';
        }
        if (!String.isBlank(addNotes) && String.isBlank(deleteNotes)){
            description = ' ' + ast.PT_Install_Location__r.Name + ' - Add Notes (' + productCode + ' : ' + addNotes + ')';
        }
//        if (ast.PT_Note_Status__c == 'Add') {
//            description = ' ' + ast.PT_Install_Location__r.Name + ' - Add Note (' + ast.Product2.ProductCode + ' : ' + ast.PT_Pending_Note__r.Name + ')';
//        } else if (ast.PT_Note_Status__c == 'Replace') {
//            description = ' ' + ast.PT_Install_Location__r.Name + ' - Add Note (' + ast.Product2.ProductCode + ' : ' + ast.PT_Pending_Note__r.Name + ')' +
//                  ' - Delete Note (' + ast.Product2.ProductCode + ' : ' + ast.PT_Note__r.Name + ')';
//        } else if (ast.PT_Note_Status__c == 'Delete') {
//            description = ' ' + ast.PT_Install_Location__r.Name + ' - Delete Note (' + ast.Product2.ProductCode + ' : ' + ast.PT_Note__r.Name + ')';
//        } else {
//            description = '';
//        }
        return description;
    }

}