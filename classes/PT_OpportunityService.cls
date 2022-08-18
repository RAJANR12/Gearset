/**
 *      @author       Sarah Kennedy
 *      @date         10/18/2020
 *      @description  Service class for Opportunity object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 10/18/2020         Initial creation
 *      MS Simplus Jan                08/06/2021         Added method getSelectedParts
 *      MS Simplus Khrisna            09/01/2021         W-003786 Sync Proposed Part from placeholder to replacement
 */


public with sharing class PT_OpportunityService {
    @AuraEnabled
    public static OppWrapper getQuoteInitFields(String recordId) {
        OppWrapper opw = new OppWrapper();
        try {
            Opportunity opp = [
                  SELECT Id,
                        Name,
                        AccountId,
                        L2I_Delivery_Schedule__r.First_Delivery_Date__c
                  FROM Opportunity
                  WHERE Id = :recordId
            ];
            if (opp == null) {
                opw.Msg = 'Opportunity ' + recordId + ' was not found';
            } else {
                opw.AccountId = opp.AccountId;
                opw.OppName = opp.Name;
                opw.SalesRepId = UserInfo.getUserId();
                opw.StartDate = opp.L2I_Delivery_Schedule__r.First_Delivery_Date__c;
                opw.Msg = 'Success';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return opw;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SBQQ__SolutionGroup__c> getSolutionGroups() {
        return [SELECT Id, Name FROM SBQQ__SolutionGroup__c ORDER BY Name];
    }
    
    @AuraEnabled(cacheable=true)
    public static oppWrapper getOpportunity(String oppId) {
        String pbId;
        String programId;
        oppWrapper opw = new oppWrapper();
        String msg = '';
        
        Opportunity opp = [SELECT Id, Pricebook2Id, L2I_Program_Num__c FROM Opportunity WHERE Id = :oppId];
        pbId = opp.Pricebook2Id;
        programId = opp.L2I_Program_Num__c;
        if (pbId == NULL ||
              programId == NULL) {
            if (pbId == NULL &&
                  programId == NULL) {
                msg = 'Pricebook and related Program are required in order to Add Parts';
            } else if (pbId == NULL) {
                msg = 'Pricebook is required in order to Add Parts';
            } else {
                msg = 'Related Program is required in order to Add Parts';
            }
        }
        opw.Msg = msg;
        opw.OppId = opp.Id;
        opw.PriceBookId = opp.Pricebook2Id;
        opw.ProgramId = opp.L2I_Program_Num__c;
        
        return opw;
    }
    
    @AuraEnabled(cacheable=true)
    public static oppWrapper getOpportunityFromAsset(String assetId) {
        String pbId;
        String programId;
        oppWrapper opw = new oppWrapper();
        
        String msg = '';
        
        Asset ast = [SELECT Id, PT_Install_Location__r.Part_List_Opportunity__c FROM Asset WHERE Id = :assetId];
        if (ast == null ||
              ast.PT_Install_Location__c == null ||
              ast.PT_Install_Location__r.Part_List_Opportunity__c == null) {
            msg = 'No Part List Opportunity exists for this Part';
        } else {
            String oppId = ast.PT_Install_Location__r.Part_List_Opportunity__c;
            Opportunity opp = [SELECT Pricebook2Id, L2I_Program_Num__c FROM Opportunity WHERE Id = :oppId];
            pbId = opp.Pricebook2Id;
            programId = opp.L2I_Program_Num__c;
            if (pbId == NULL ||
                  programId == NULL) {
                
                if (pbId == NULL &&
                      programId == NULL) {
                    msg = 'Pricebook and related Program are required in order to Add Parts';
                } else if (pbId == NULL) {
                    msg = 'Pricebook is required in order to Add Parts';
                } else {
                    msg = 'Related Program is required in order to Add Parts';
                }
            }
            opw.Msg = msg;
            opw.OppId = opp.Id;
            opw.PriceBookId = opp.Pricebook2Id;
            opw.ProgramId = opp.L2I_Program_Num__c;
        }
        opw.Msg = msg;
        return opw;
    }
    
    @AuraEnabled(cacheable=true)
    public static partsReturnWrapper getAsset(String assetId, string actionType) {
        String pbId;
        String programId;
        List<partsReturnWrapper> pwReturnList = new List<partsReturnWrapper>();
        List<partsWrapper> pwList = new List<partsWrapper>();
        String msg = '';
        
        Asset ast = [
              SELECT Id, Name, ProductCode, PT_Configured_Quantity__c, Product2Id, PT_Status__c,
                    PT_Pending_Configured_Quantity__c, Quantity, PT_Install_Location__c,
                    PT_Is_Kit__c, PT_Kit_Revision_Code__c,
                    PT_Pending_Quantity__c, PT_Reason__c, PT_Pending_Reason__c, PT_Install_Location__r.Name,
                    PT_Notes__c, PT_Pending_Notes__c, PT_Notes_Status__c,
                    PT_Is_Placeholder_Part__c, PT_Proposed_Part_Code__c, PT_Proposed_Part_Nomenclature__c // Added by Khrisna for W-003786
              FROM Asset
              WHERE Id = :assetId
        ];
    
        Product2 prod;
        if (ast.PT_Is_Kit__c) {
            prod = [
                  SELECT Id, PT_Kit_Current_Revision__c
                  FROM Product2
                  WHERE Id = :ast.Product2Id
            ];
        }
        // find base part code
        Integer idx = ast.ProductCode.lastIndexOf('-');
        String basePartCode = '';
        if (idx != -1) {
            basePartCode = ast.ProductCode.substring(0, idx);
            system.debug('BasePartCode ='+ basePartCode);
        }
        partsWrapper pw = new partsWrapper();
        pw.Id = ast.Product2Id;
        pw.assetId = ast.Id;
        pw.partCode = ast.ProductCode;
        pw.partName = ast.Name;
        pw.isKit = ast.PT_Is_Kit__c;
        pw.latestKitRevCode = ast.PT_Kit_Revision_Code__c;
        if (ast.PT_Is_Kit__c && actionType == 'Refresh') {
            pw.prevKitRevCode = ast.PT_Kit_Revision_Code__c;
            pw.latestKitRevCode = prod.PT_Kit_Current_Revision__c;
        }
        pw.configQty = Integer.valueOf(ast.PT_Configured_Quantity__c);
        pw.qty = Integer.valueOf(ast.Quantity);
        pw.reason = ast.PT_Reason__c;
        pw.installLocName = ast.PT_Install_Location__r.Name;
        pw.installLocId = ast.PT_Install_Location__c;
        pw.basePartCode = basePartCode;
        pw.notes = ast.PT_Notes__c;
        pw.notesStatus = ast.PT_Notes_Status__c;
        // Added by Khrisna for W-003786
        pw.isPlaceholder = ast.PT_Is_Placeholder_Part__c;
        pw.proposedPartCode = ast.PT_Proposed_Part_Code__c;
        pw.proposedPartNomenclature = ast.PT_Proposed_Part_Nomenclature__c;
        // End W-003786
        pwList.add(pw);
        partsReturnWrapper returnpw = new partsReturnWrapper();
        returnpw.pwList = pwList;
        if (actionType == 'Replace') {
            if (basePartCode == '' && !ast.PT_Is_Placeholder_Part__c) {
                returnpw.msg = 'Error - There are no other versions of this Product Code.';
            } else if (ast.PT_Pending_Configured_Quantity__c != null ||
                  ast.PT_Pending_Quantity__c != null) {
                returnpw.msg = 'Error - A Part with pending Quantity changes may not be replaced.';
            } else if (ast.PT_Status__c == 'New') {
                returnpw.msg = 'Error - A Part with a New status may not be Replaced. Please approve the Part List before proceeding.';
            } else {
                if (ast.PT_Is_Kit__c && !ast.PT_Is_Placeholder_Part__c) {
                    returnpw.msg = 'Error - Selected Part may not be a Kit.';
                } else {
                    returnpw.msg = 'Part to Replace';
                }
            }
        } else if (actionType == 'Delete') {
            if (ast.PT_Status__c == 'Pending Replaced') {
                returnpw.msg = 'Error - A Replaced Part may not be Deleted.';
            } else {
                returnpw.msg = 'Part to Delete';
            }
        } else if (actionType == 'Refresh') {
            if (!ast.PT_Is_Kit__c) {
                returnpw.msg = 'Error - Selected Part is not a Kit.';
            } else if (ast.PT_Pending_Configured_Quantity__c != null ||
                  ast.PT_Pending_Quantity__c != null) {
                returnpw.msg = 'Error - A Kit Part with pending Quantity changes may not be refreshed.  Please delete or approve the Part List before proceeding.';
            } else if (ast.PT_Status__c == 'New') {
                returnpw.msg = 'Error - A Kit Part with a New status may not be Refreshed. Please delete or approve the Part List before proceeding.';
            } else {
                if (ast.PT_Kit_Revision_Code__c == prod.PT_Kit_Current_Revision__c) {
                    returnpw.msg = 'Error - Kit currently has the latest revision information: ' + prod.PT_Kit_Current_Revision__c + '.';
                } else {
                    returnpw.msg = 'Kit to Refresh';
                }
            }
        } else if (actionType == 'Note') {
            returnpw.msg = 'Notes';
        } else {
            if (ast.PT_Status__c == 'Pending Replaced') {
                returnpw.msg = 'Error - A Replaced Part may not be modified.';
            }
        }
        pwReturnList.add(returnpw);
        return returnpw;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<NoteWrapper> getNotes(oppWrapper oppData) {
        String msg = '';
        System.debug('*** oppData ' + oppData);
        String oppId = oppData.OppId;
        List<NoteWrapper> noteWrapperList = new List<NoteWrapper>();
        List<PT_Note__c> noteList = new List<PT_Note__c>();
        
        noteList = [
              SELECT Id, PT_Notes__c, PT_Opportunity__c, PT_Sequence__c, PT_Note_Name__c, PT_Delete_Note__c
              FROM PT_Note__c
              WHERE PT_Opportunity__c = :oppId
              AND PT_Delete_Note__c = FALSE
            //   AND (PT_Approval_Status__c = 'Approved' OR PT_Approval_Status__c = null) // Added by Lipton for W-003567
              ORDER BY PT_Sequence__c
        ];
        
        for (PT_Note__c note : noteList) {
            NoteWrapper nw = new NoteWrapper();
            nw.Id = note.Id;
            nw.noteName = note.PT_Note_Name__c;
            nw.notes = note.PT_Notes__c;
            nw.OppId = note.PT_Opportunity__c; // Added by Lipton for W-003567
            //nw.noteSeq = note.PT_Sequence__c;
            noteWrapperList.add(nw);
        }
        
        return noteWrapperList;
    }
    
    @AuraEnabled
    public static void saveNote(List<NoteWrapper> selectedNotes, partsWrapper assetToUpdate) {
        Id noteId;
        String noteStatus = '';
        List<String> assetNotes = new List<String>();
        List<String> pendingNotesList = new List<String>();
        List<NoteStatusWrapper> nswList = new List<NoteStatusWrapper>();
        String pendingNotes = '';
        
        // get the asset notes
        if (!String.isBlank(assetToUpdate.Notes) ){
            assetNotes = assetToUpdate.Notes.split(',');
        }
        
        //compare the asset notes to the selected notes
        
        System.debug('*** assetToUpdate ' + assetToUpdate);
        System.debug('*** selectedNote ' + selectedNotes);
        
        for (Integer i = 0; i < assetNotes.size(); i++){
            Boolean foundMatch = false;
            for (Integer k = 0; k < selectedNotes.size(); k++){
                if (assetNotes[i] == selectedNotes[k].noteName){
                    foundMatch = true;
                    system.debug('*** asset Note the same ' + assetNotes[i]);
                    pendingNotesList.add(assetNotes[i]);
                    break;
                }
            }
            if (!foundMatch){
                system.debug('*** asset Note deleted ' + assetNotes[i]);
                nswList.add(new NoteStatusWrapper(assetNotes[i], 'Delete'));
                
            }
        }
    
        for (Integer i = 0; i < selectedNotes.size(); i++){
            Boolean foundMatch = false;
            for (Integer k = 0; k < assetNotes.size(); k++){
                if (assetNotes[k] == selectedNotes[i].noteName){
                    foundMatch = true;
                    break;
                }
            }
            if (!foundMatch){
                pendingNotesList.add(selectedNotes[i].noteName);
                system.debug('*** Note added ' + selectedNotes[i].noteName);
                nswList.add(new NoteStatusWrapper(selectedNotes[i].noteName, 'Add'));
            }
        }
    
        System.debug('*** pendingNotesList ' + pendingNotesList);
        
        pendingNotesList.sort();
        for (String s : pendingNotesList){
            pendingNotes = String.isBlank(pendingNotes) ? s : pendingNotes + ',' + s;
        }
        System.debug('*** pendingNotes ' + pendingNotes);
        
        // serialize add/delete statuses
        if (nswList.size() > 0){
            noteStatus = JSON.serialize(nswList);
        }
        
        if (pendingNotes == assetToUpdate.Notes){
            // no change
            pendingNotes = '';
            noteStatus = '';
        }
    
        if (String.isBlank(pendingNotes) &&
              !String.isBlank(noteStatus)){
            pendingNotes = 'Remove Notes';
        }
        
//        if (selectedNote == null || selectedNote.size() == 0) {
//            if (assetToUpdate.note != null) {
//                noteId = null;
//                noteStatus = 'Delete';
//            } else {
//                noteId = null;
//                noteStatus = null;
//            }
//        } else {
//            if (assetToUpdate.note != null) {
//                if (selectedNote[0].Id != assetToUpdate.note) {
//                    noteId = selectedNote[0].Id;
//                    noteStatus = 'Replace';
//                } else {
//                    noteId = selectedNote[0].Id;
//                    noteStatus = null;
//                }
//            } else {
//                noteId = selectedNote[0].Id;
//                noteStatus = 'Add';
//            }
//        }
//        System.debug('*** noteId ' + noteId);
//        System.debug('*** noteStatus ' + noteStatus);
        Asset updateAsset = new Asset();
        updateAsset.Id = assetToUpdate.assetId;
        updateAsset.PT_Pending_Notes__c = pendingNotes;
        updateAsset.PT_Notes_Status__c = noteStatus;
        
        update updateAsset;
    }
    
    @AuraEnabled(cacheable=true)
    public static ShipSetWrapper getShipSet(Id ssId) {
        System.debug('*** ssId ' + ssId);
        
        // get the original dsl data
        L2I_DSL__c origDSL = [
              SELECT Id, Name, Delivery_Schedule_Header__c, PT_Program__c, PT_isActive__c, Aircraft__c, Original_Opportunity__c
              FROM L2I_DSL__c
              WHERE Id = :ssId
        ];
        
        ShipSetWrapper ssw = new ShipSetWrapper();
        ssw.dslId = origDSL.Id;
        ssw.dslName = origDSL.Name;
        ssw.programId = origDSL.PT_Program__c;
        ssw.cplId = origdsl.Original_Opportunity__c;
        ssw.Msg = '';
        if (origDSL.PT_isActive__c != 'Active'
              //|| origDSL.Aircraft__c != null // Removed by Jan Geronga for W-003798
           ) {
            ssw.Msg = 'Error - ShipSet ' + origDSL.Name + ' is not Active.';
        }
        return ssw;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CPLWrapper> getProgramCPLs(Id programId, Id origCPLId) {
        String msg = '';
        System.debug('*** programId ' + programId);
        System.debug('*** origCPLId ' + origCPLId);
        List<CPLWrapper> cplWrapperList = new List<CPLWrapper>();
        
        // find all CPLs for the same program
        for (Opportunity opp : [
              SELECT Id, Name, PT_Part_List_Name_Rev__c, L2I_Delivery_Schedule__c, L2I_Program_Num__c
              FROM Opportunity
              WHERE PT_Is_CPL__c = TRUE
              AND PT_PL_Approval_Status__c != 'Pending'
              AND L2I_Program_Num__c = :programId
              AND Id != :origCPLId
              AND StageName = 'Delivery'
        ]) {
            CPLWrapper cw = new CPLWrapper(
                  opp.Id,
                  opp.Name,
                  opp.PT_Part_List_Name_Rev__c
            );
            cplWrapperList.add(cw);
        }
        return cplWrapperList;
    }
    
    @AuraEnabled
    public static void moveShipSet(Id ssId, Id selectedOppId) {
        
        // get the original dsl data
        L2I_DSL__c origDSL = [
              SELECT Id, Name, Delivery_Schedule_Header__c, Original_Opportunity__c, Aircraft__c
              FROM L2I_DSL__c
              WHERE Id = :ssId
        ];
        System.debug('*** origDSL ' + origDSL);
        
        Opportunity oppOrig = [SELECT Id, L2I_AircraftQuantity__c, L2I_Delivery_Schedule__c FROM Opportunity WHERE L2I_Delivery_Schedule__c = :origDSL.Delivery_Schedule_Header__c];
        System.debug('*** oppOrig ' + oppOrig);
        
        Opportunity opp = [SELECT Id, L2I_AircraftQuantity__c, L2I_Delivery_Schedule__c, SBQQ__PrimaryQuote__c
        FROM Opportunity
        WHERE Id = :selectedOppId];
        System.debug('*** opp ' + opp);
    
        origDSL.Delivery_Schedule_Header__c = opp.L2I_Delivery_Schedule__c;
        origDSL.Original_Opportunity__c = opp.Id;
        System.debug('*** origDSL ' + origDSL);
        //Added by Jan Geronga for W-003798: Start
        if(origDSL.Aircraft__c != null){
            origDSL.Aircraft__c = null;
        }
        //Added by Jan Geronga for W-003798: End
        update origDSL;
    
        Decimal dslCount = [SELECT COUNT() FROM L2I_DSL__c WHERE Delivery_Schedule_Header__c = :opp.L2I_Delivery_Schedule__c];
        Decimal origDSLCount = [SELECT COUNT() FROM L2I_DSL__c WHERE Delivery_Schedule_Header__c = :oppOrig.L2I_Delivery_Schedule__c];
    
        oppOrig.L2I_AircraftQuantity__c = origDSLCount;
        System.debug('*** oppOrig ' + oppOrig);
        update oppOrig;
        
        opp.L2I_AircraftQuantity__c = dslCount;
        System.debug('*** opp ' + opp);
        update opp;
        
        // sync the DSLs for the new CPL
        PT_UpdateDSLWIthPartsListBatch batch = new PT_UpdateDSLWIthPartsListBatch(opp.SBQQ__PrimaryQuote__c);
        Id batchId = Database.executeBatch(batch, 1);
    }
    
    
    @AuraEnabled
    public static List<partsWrapper> findPartsForIL(oppWrapper oppData, List<String> sgIdList, String partFilter, String actionType, partsWrapper pw) {
        System.debug('*** pw ' + pw);
        System.debug('*** oppData ' + oppData);
        System.debug('*** sgIdList ' + sgIdList);
        List<partsWrapper> pwList = new List<partsWrapper>();
        Set<String> existingProductCodes = new Set<String>();
        // get pricebook from opp
        String oppId = oppData.OppId;
        String pbId = oppData.PriceBookId;
        
        String likeFilter = '%' + partFilter + '%';
        String likeFilter2;
        if (actionType == 'Replace') {
            likeFilter2 = '%' + pw.basePartCode + '%';
        } else {
            likeFilter2 = '%' + partFilter + '%';
        }
        System.debug('*** likeFilter ' + likeFilter);
        System.debug('*** likeFilter2 ' + likeFilter2);
        
        Map<String, PricebookEntry> prodListPriceMap = new Map<String, PricebookEntry>();
        if (actionType == 'Replace') {
            string assetInstallLocId;
            // find existing Products for the Install Loc
            for (Asset ast : [
                  SELECT Id, ProductCode, PT_Install_Location__c, PT_Install_Location__r.Part_List_Opportunity__c
                  FROM Asset
                  WHERE PT_Install_Location__r.Part_List_Opportunity__c = :oppId
                  AND PT_Install_Location__c = :pw.installLocId
                  AND PT_Can_Be_Processed__c = true
            ]) {
                if (ast.ProductCode != null) {
                    existingProductCodes.add(ast.ProductCode);
                    assetInstallLocId = ast.PT_Install_Location__c;
                }
            }
            System.debug('*** existingProductCodes ' + existingProductCodes);
            for (List<PricebookEntry> pbeList : [
                  SELECT Product2Id, UnitPrice, CurrencyIsoCode, ProductCode
                  FROM PricebookEntry
                  WHERE Pricebook2Id = :pbId
                  AND ProductCode NOT IN :existingProductCodes
                  AND Product2Id <> NULL
            ]) {
                for (PricebookEntry pbe : pbeList) {
                    prodListPriceMap.put(pbe.ProductCode, pbe);
                }
            }
            for (Product2 prod : [
                  SELECT Id, Name, Description, ProductCode, Family, L2I_Product_Family__c, L2I_Price_List_ID__c,
                        L2I_Is_Kit__c, PT_Kit_Current_Revision__c
                  FROM Product2
                  WHERE L2I_Category__c = 'IFEC'
                  AND L2I_Sub_Category_1__c = 'IFE HW'
                  AND ProductCode IN :prodListPriceMap.keySet()
                  AND ProductCode LIKE :likeFilter2
                  AND (Name LIKE :likeFilter OR ProductCode LIKE :likeFilter)
                  ORDER BY ProductCode
                  LIMIT 500
            ]) {
                if (prodListPriceMap.get(prod.ProductCode) != null) {
                    partsWrapper pwFound = new partsWrapper();
                    pwFound.Id = prod.Id;
                    pwFound.partCode = prod.ProductCode;
                    pwFound.partName = prod.Name;
                    pwFound.installLocId = assetInstallLocId;
                    // pwFound.sgIdList = sgIdList;
                    pwFound.oppId = oppId;
                    // Added by Khrisna for W-003786
                    if (pw.isPlaceholder) {
                        pwFound.isPlaceholder = pw.isPlaceholder;
                        pwFound.proposedPartCode = pw.proposedPartCode;
                        pwFound.proposedPartNomenclature = pw.proposedPartNomenclature;
                    } // End W-003786
                    pwList.add(pwFound);
                }
            }
        } else {
            // find existing Products for the Install Loc
            SBQQ__SolutionGroup__c sg = [
                  SELECT Id, Name
                  FROM SBQQ__SolutionGroup__c
                  WHERE Id = :sgIdList[0]
            ];
            if (sg != null) {
                String assetInstallLocId = '';
                List<PT_Install_Location__c> ilocList = new List<PT_Install_Location__c>();
                ilocList = [
                      SELECT Id, Part_List_Opportunity__c
                      FROM PT_Install_Location__c
                      WHERE Part_List_Opportunity__c = :oppId
                      AND Name = :sg.Name
                ];
                if (ilocList != null && ilocList.size() > 0) {
                    assetInstallLocId = ilocList[0].Id;
                }
                if (assetInstallLocId != '') {
                    for (Asset ast : [
                          SELECT Id, ProductCode, PT_Install_Location__c, PT_Install_Location__r.Part_List_Opportunity__c
                          FROM Asset
                          WHERE PT_Install_Location__r.Part_List_Opportunity__c = :oppId
                          AND PT_Install_Location__c = :assetInstallLocId
                          AND PT_Can_Be_Processed__c = true
                    ]) {
                        if (ast.ProductCode != null) {
                            existingProductCodes.add(ast.ProductCode);
                            assetInstallLocId = ast.PT_Install_Location__c;
                        }
                    }
                }
            }
            
            System.debug('*** existingProductCodes ' + existingProductCodes);
            for (List<PricebookEntry> pbeList : [
                  SELECT Product2Id, UnitPrice, CurrencyIsoCode, ProductCode
                  FROM PricebookEntry
                  WHERE Pricebook2Id = :pbId
                  AND ProductCode NOT IN :existingProductCodes
                  AND Product2Id <> NULL
                  AND (Name LIKE :likeFilter OR ProductCode LIKE :likeFilter2)
            ]) {
                for (PricebookEntry pbe : pbeList) {
                    prodListPriceMap.put(pbe.ProductCode, pbe);
                }
            }
            
            for (Product2 prod : [
                  SELECT Id, Name, Description, ProductCode, Family, L2I_Product_Family__c, L2I_Price_List_ID__c,
                        L2I_Is_Kit__c, PT_Kit_Current_Revision__c
                  FROM Product2
                  WHERE L2I_Category__c = 'IFEC'
                  AND L2I_Sub_Category_1__c = 'IFE HW'
                  AND ProductCode IN :prodListPriceMap.keySet()
                  AND (Name LIKE :likeFilter OR ProductCode LIKE :likeFilter2)
                  ORDER BY ProductCode
                  LIMIT 500
            ]) {
                if (prodListPriceMap.get(prod.ProductCode) != null) {
                    Integer pendConfigQty = prod.L2I_Is_Kit__c ? 1 : null;
                    Integer pendQty = prod.L2I_Is_Kit__c ? 1 : null;
                    
                    partsWrapper pwFound = new partsWrapper();
                    pwFound.Id = prod.Id;
                    pwFound.partCode = prod.ProductCode;
                    pwFound.partName = prod.Name;
                    pwFound.sgIdList = sgIdList;
                    pwFound.oppId = oppId;
                    pwFound.isKit = prod.L2I_Is_Kit__c;
                    pwFound.latestKitRevCode = prod.PT_Kit_Current_Revision__c;
                    pwFound.configQty = pendConfigQty;
                    pwFound.qty = pendQty;
                    pwList.add(pwFound);
                }
            }
        }
        return pwList;
    }
    /**
    * @Method Name        : getSelectedParts
    * @Description        : Gets selected parts from Program and compares Standard Cost vs  Standard Price
    * @Author             : Jan Denrick Geronga / Managed Services Simplus
    * @Modification Log   :
    * Ver       	Date       	  Author              Modification
    * W-003812    	Aug-06-2021   MS Simplus Jan      Initial Version
    * W-004065      Nov 17 2021   MS Simplus Khrisna  Added '=' in the standard price & standard cost validation
    **/
    @AuraEnabled
    public static partsReturnWrapper getSelectedParts(List<partsWrapper> selectedPartsList, String oppId, List<String> sgIdList, String actionType) {
        partsReturnWrapper prw = new partsReturnWrapper();
        String msg = '';
        List<partsWrapper> pwReturnList = new List<partsWrapper>();
        
        Map<Id, PricebookEntry> mapPBE = new Map<Id, PricebookEntry>();
        Map<Id, SBQQ__Cost__c> mapCost = new Map<Id, SBQQ__Cost__c>();
        List<partsWrapper> listPW = new List<partsWrapper>();
        Set<Id> sProdId = new Set<Id>();
        Map<String, String> errorMessage = new Map<String, String>();
        
        for (partsWrapper pw : selectedPartsList) {
            sProdId.add(pw.Id);
            listPW.add(pw);
        }
        
        try{
            Opportunity oppty = [SELECT Pricebook2Id FROM Opportunity WHERE ID =: oppId];
            
            for(SBQQ__Cost__c c : [SELECT SBQQ__Product__c, SBQQ__UnitCost__c FROM SBQQ__Cost__c WHERE SBQQ__Product__c IN: sProdId]){
                mapCost.put(c.SBQQ__Product__c, c);
            }

            for(PricebookEntry pBE : [SELECT Product2Id, UnitPrice, ProductCode FROM PricebookEntry WHERE Product2Id IN: sProdId AND Pricebook2Id =: oppty.Pricebook2Id]){
                if(mapCost.keySet().contains(pBE.Product2Id) && pBE.UnitPrice >= mapCost.get(pBE.Product2Id).SBQQ__UnitCost__c){
                    mapPBE.put(pBE.Product2Id, pBE);
                }
                else{
                    errorMessage.put(pBE.Product2Id, pBE.ProductCode);
                }
            }
            
            for(partsWrapper prodSG : listPW){
                if(mapPBE.containsKey(prodSG.Id)){
                    pwReturnList.add(prodSG);
                }
            }
            
            if(!errorMessage.isEmpty()){
                String errMsg = ': The standard price cannot be less than the standard cost.';
                msg = string.join(errorMessage.values(), '; ') + errMsg;
            }

        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        prw.msg = msg;
        prw.pwList = pwReturnList;
        return prw;
    }
    
    @AuraEnabled
    public static partsReturnWrapper savePartsForOpportunity(List<partsWrapper> selectedPartsList, String oppId, List<String> sgIdList, String actionType) {
        String msg = '';
        String acctId = '';
        Map<Id, String> sgMap = new Map<Id, String>();
        Set<String> selectedParts = new Set<String>();
        Map<Id, partsWrapper> prodPW = new Map<Id, partsWrapper>();
        Set<String> sgIds = new Set<String>();
        Map<String, Set<String>> iLocProdMap = new Map<String, Set<String>>();
        Map<String, List<Asset>> astProdMap = new Map<String, List<Asset>>();
        Set<String> newIlocIds = new Set<String>();
        Map<Id, PT_Install_Location__c> ilMap = new Map<Id, PT_Install_Location__c>();
        List<PT_Install_Location__c> newILocList = new List<PT_Install_Location__c>();
        List<Asset> newAstList = new List<Asset>();
        List<Asset> newAstChildList = new List<Asset>();
        List<partsWrapper> pwReturnList = new List<partsWrapper>();
        partsReturnWrapper prw = new partsReturnWrapper();
        Map<String, Asset> kitPartAssetMap = new Map<String, Asset>();
//        Map<String, Asset> kitAssetLocMap = new Map<String, Asset>();
        
        if (selectedPartsList == NULL ||
              selectedPartsList.size() == 0) {
            msg = 'Error - No Parts were selected.';
            prw.msg = msg;
            return prw;
        }
        if (sgIdList == NULL ||
              sgIdList.size() == 0) {
            msg = 'No Solution Groups were selected.';
            prw.msg = msg;
            return prw;
        }
        for (partsWrapper pw : selectedPartsList) {
            selectedParts.add(pw.Id);
            prodPW.put(pw.Id, pw);
        }
        for (String sgId : sgIdList) {
            sgIds.add(sgId);
        }
        try {
            for (SBQQ__SolutionGroup__c sg : [SELECT Id, Name FROM SBQQ__SolutionGroup__c WHERE Id IN:sgIds]) {
                sgMap.put(sg.Id, sg.Name);
            }
            acctId = [SELECT AccountId FROM Opportunity WHERE Id = :oppId].AccountId;
            // create new Install Locations if needed
            for (String sgId : sgIds) {
                // find existing install locs for opp and sol groups
                Boolean foundMatch = false;
                for (PT_Install_Location__c iLoc : [
                      SELECT Id, Name, Solution_Group__c,
                            Part_List_Opportunity__r.L2I_Program_Num__c
                      FROM PT_Install_Location__c
                      WHERE Part_List_Opportunity__c = :oppId
                      AND Status__c = 'Active'
                ]) {
                    if (iLoc.Solution_Group__c == sgId) {
                        ilMap.put(iLoc.Id, iLoc);
                        foundMatch = true;
                        break;
                    }
                }
                if (!foundMatch) {
                    PT_Install_Location__c newILoc = new PT_Install_Location__c(
                          Name = sgMap.get(sgId),
                          Solution_Group__c = sgId,
                          Part_List_Opportunity__c = oppId,
                          Status__c = 'Active'
                    );
                    newILocList.add(newILoc);
                }
            }
            System.debug('*** newILocList.size() ' + newILocList.size());
            if (newILocList != NULL &&
                  newILocList.size() > 0) {
                insert newILocList;
            }
            
            // save new install locs to map
            for (PT_Install_Location__c newILoc : newILocList) {
                newIlocIds.add(newILoc.Id);
            }
            
            for (PT_Install_Location__c iLoc : [
                  SELECT Id, Name, Solution_Group__c,
                        Part_List_Opportunity__r.L2I_Program_Num__c
                  FROM PT_Install_Location__c
                  WHERE Id IN :newIlocIds
                  AND Status__c = 'Active'
            ]) {
                ilMap.put(iLoc.Id, iLoc);
            }
            
            
            for (PT_Install_Location__c newILoc : ilMap.values()) {
                for (String prod : prodPW.keySet()) {
                    if (!iLocProdMap.containsKey(newILoc.Id)) {
                        iLocProdMap.put(newILoc.Id, new Set<String>());
                    }
                    Set<String> sList = iLocProdMap.get(newILoc.Id);
                    sList.add(prod);
                    iLocProdMap.put(newILoc.Id, sList);
                }
            }
            
            // find existing parts for Install loc
            for (Asset ast : [
                  SELECT Id, Name, Product2Id, PT_Install_Location__c, AccountID, PT_Can_Be_Processed__c
                  FROM Asset
                  WHERE PT_Install_Location__c IN :ilMap.keySet()
            ]) {
                System.debug('*** ast ' + ast);
                if (!astProdMap.containsKey(ast.PT_Install_Location__c)) {
                    astProdMap.put(ast.PT_Install_Location__c, new List<Asset>());
                }
                List<Asset> sList = astProdMap.get(ast.PT_Install_Location__c);
                sList.add(ast);
                astProdMap.put(ast.PT_Install_Location__c, sList);
            }
            
            // add only new parts
            for (String ilocId : iLocProdMap.keySet()) {
                Set<String> ilProds = iLocProdMap.get(ilocId);
                for (String ilProd : ilProds) {
                    List<Asset> astProds = astProdMap.get(ilocId);
                    Boolean foundProdMatch = false;
                    if (astProds != NULL) {
                        for (Asset astProd : astProds) {
                            System.debug('*** astProd ' + astProd);
                            if (astProd.Product2Id == ilProd) {
                                // is there already an viable Asset? if not, create it
                                if (astProd.PT_Can_Be_Processed__c) {
                                    foundProdMatch = true;
                                    break;
                                }
                            }
                        }
                    }
                    if (foundProdMatch) {
                        partsWrapper returnpw = new partsWrapper();
                        returnpw.partCode = prodPW.get(ilProd).partCode;
                        returnpw.partName = prodPW.get(ilProd).partName;
                        returnpw.configQty = prodPW.get(ilProd).configQty;
                        returnpw.qty = prodPW.get(ilProd).qty;
                        returnpw.reason = prodPW.get(ilProd).reason;
                        //returnpw.note = prodPW.get(ilProd).note;
                        returnpw.installLocName = ilMap.get(iLocId).Name;
                        returnpw.installLocId = iLocId;
                        returnpw.isDuplicate = true;
                        returnpw.latestKitRevCode = prodPW.get(ilProd).latestKitRevCode;
                        returnpw.isKit = prodPW.get(ilProd).isKit;
                        
                        pwReturnList.add(returnpw);
                    } else {
                        Integer pendConfigQty = prodPW.get(ilProd).isKit ? 1 : prodPW.get(ilProd).configQty;
                        Integer pendQty = prodPW.get(ilProd).isKit ? 1 : prodPW.get(ilProd).qty;
                        //String noteStatus = prodPW.get(ilProd).note != null ? 'Add' : '';
                        
                        Asset ast = new Asset(
                              Name = prodPW.get(ilProd).partName,
                              PT_Pending_Configured_Quantity__c = pendConfigQty,
                              PT_Pending_Quantity__c = pendQty,
                              PT_Reason__c = prodPW.get(ilProd).reason,
                              AccountId = acctid,
                              PT_Install_Location__c = ilocId,
                              PT_Program__c = ilMap.get(ilocId).Part_List_Opportunity__r.L2I_Program_Num__c,
                              Product2Id = ilProd,
                              PT_Kit_Revision_Code__c = prodPW.get(ilProd).latestKitRevCode,
                              PT_Status__c = 'New'
                        );
                        
                        newAstList.add(ast);
                        
                        partsWrapper returnpw = new partsWrapper();
                        returnpw.partCode = prodPW.get(ilProd).partCode;
                        returnpw.partName = prodPW.get(ilProd).partName;
                        returnpw.configQty = pendConfigQty;
                        returnpw.qty = pendQty;
                        returnpw.reason = prodPW.get(ilProd).reason;
                        //returnpw.note = prodPW.get(ilProd).note;
                        returnpw.installLocName = ilMap.get(iLocId).Name;
                        returnpw.installLocId = iLocId;
                        returnpw.isDuplicate = false;
                        returnpw.latestKitRevCode = prodPW.get(ilProd).latestKitRevCode;
                        returnpw.isKit = prodPW.get(ilProd).isKit;
                        
                        pwReturnList.add(returnpw);
                    }
                }
            }
            System.debug('*** newAstList.size() ' + newAstList.size());
            if (newAstList != NULL &&
                  newAstList.size() > 0) {
                upsert newAstList;
                
                // if any kit parts were added, now add all the child components
                // first query the new assets to get the formulas working
                Set<Id> astIds = new Set<Id>();
                for (Asset astAdd : newAstList) {
                    astIds.add(astAdd.Id);
                }
                
                // if any kit parts were added, now add all the child components
                for (Asset astQ : [
                      SELECT Id, PT_Is_Kit__c, Product2Id, PT_Install_Location__c, PT_Kit_Revision_Code__c, PT_Program__c
                      FROM Asset
                      WHERE Id IN :astIds
                      AND PT_Is_Kit__c = true
                ]) {
                    if (astQ.PT_Is_Kit__c) {
                        kitPartAssetMap.put(astQ.Product2Id, astQ);  // the Kit asset to use as the component kit parent
                    }
                }
                System.debug('*** kitPartAssetMap ' + kitPartAssetMap);
                if (!kitPartAssetMap.isEmpty()) {
                    for (Kit_Products__c kitChild : [
                          SELECT Id,
                                Kit_Product_Code__c,
                                PT_Component_Part__c,
                                PT_Component_Part__r.Name,
                                PT_Component_Part_Code__c,
                                PT_Component_Part_Quantity__c,
                                PT_Kit_Part__c,
                                PT_Kit_Part__r.Name,
                                PT_Kit_Revision_Code__c
                          FROM Kit_Products__c
                          WHERE PT_Kit_Part__c IN :kitPartAssetMap.keySet()
                    ]) {
                        if (kitChild.PT_Kit_Revision_Code__c == kitPartAssetMap.get(kitChild.PT_Kit_Part__c).PT_Kit_Revision_Code__c) {
                            Asset astChild = new Asset(
                                  Name = kitChild.PT_Component_Part__r.Name,
                                  PT_Pending_Configured_Quantity__c = kitChild.PT_Component_Part_Quantity__c,
                                  PT_Pending_Quantity__c = 0,
                                  PT_Kit_Parent__c = kitPartAssetMap.get(kitChild.PT_Kit_Part__c).Id,
                                  Product2Id = kitChild.PT_Component_Part__c,
                                  AccountId = acctId,
                                  PT_Install_Location__c = kitPartAssetMap.get(kitChild.PT_Kit_Part__c).PT_Install_Location__c,
                                  PT_Program__c = kitPartAssetMap.get(kitChild.PT_Kit_Part__c).PT_Program__c,
                                  PT_Status__c = 'New'
                            );
                            System.debug('*** astChild ' + astChild);
                            
                            newAstChildList.add(astChild);
                            
                            partsWrapper returnChildpw = new partsWrapper();
                            returnChildpw.partCode = kitChild.PT_Component_Part_Code__c;
                            returnChildpw.partName = kitChild.PT_Component_Part__r.Name;
                            returnChildpw.configQty = Integer.valueOf(kitChild.PT_Component_Part_Quantity__c);
                            returnChildpw.qty = 0;
                            returnChildpw.isDuplicate = false;
                        }
                    }
                }
                System.debug('*** newAstChildList.size() ' + newAstChildList.size());
                if (newAstChildList != NULL &&
                      newAstChildList.size() > 0) {
                    upsert newAstChildList;
                }
                Integer astCount = newAstList.size() + newAstChildList.size();
                msg = 'Successfully added ' + astCount + ' Parts';
            } else {
                msg = 'No Parts were added.';
            }
        
        } catch (Exception e) {
            String exMsg = e.getMessage();
            if (exMsg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') != -1) {
                exMsg = exMsg.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION');
            }
            msg = 'Error adding Parts: ' + exMsg;
        }
        prw.msg = msg;
        prw.pwList = pwReturnList;
        System.debug('*** msg ' + msg);
        return prw;
    }
    
    @AuraEnabled
    public static partsReturnWrapper saveReplacementParts(List<partsWrapper> selectedPartsList, oppWrapper oppData, partsWrapper assetToBeReplaced, String actionType) {
        String msg = '';
        String acctId = '';
        System.debug('*** oppData ' + oppData);
        String oppId = oppData.OppId;
        Asset assetReplaced = new Asset();
        List<Asset> newAstList = new List<Asset>();
        List<partsWrapper> pwReturnList = new List<partsWrapper>();
        partsReturnWrapper prw = new partsReturnWrapper();
        
        if (selectedPartsList == NULL ||
              selectedPartsList.size() == 0) {
            msg = 'Error - No Parts were selected.';
            prw.msg = msg;
            return prw;
        }
        
        assetReplaced.Id = assetToBeReplaced.assetId;
        assetReplaced.PT_Status__c = 'Pending Removed';
        update assetReplaced;
        
        try {
            
            acctId = [SELECT AccountId FROM Opportunity WHERE Id = :oppId].AccountId;
            for (partsWrapper pw : selectedPartsList) {
               // String noteStatus = pw.note != null ? 'Add' : '';
                Asset ast = new Asset(
                      Name = pw.partName,
                      ParentId = assetToBeReplaced.assetId,
                      PT_Pending_Configured_Quantity__c = pw.configQty,
                      PT_Pending_Quantity__c = pw.qty,
                      PT_Reason__c = pw.reason,
                      AccountId = acctid,
                      PT_Install_Location__c = pw.installLocId,
                      PT_Program__c = oppData.ProgramId,
                      Product2Id = pw.Id,
                      PT_Status__c = 'Pending Replaced',
                      PT_Proposed_Part_Code__c = pw.proposedPartCode,
                      PT_Proposed_Part_Nomenclature__c = pw.proposedPartNomenclature
                );
                newAstList.add(ast);
                
                partsWrapper returnpw = new partsWrapper();
                returnpw.partCode = pw.partCode;
                returnpw.partName = pw.partName;
                returnpw.configQty = pw.configQty;
                returnpw.qty = pw.qty;
                returnpw.reason = pw.reason;
                returnpw.installLocName = pw.installLocName;
                returnpw.installLocId = pw.installLocId;
                // Added by Khrisna for W-003786
                returnpw.proposedPartCode = pw.proposedPartCode;
                returnpw.proposedPartNomenclature = pw.proposedPartNomenclature;
                // End W-003786
                pwReturnList.add(returnpw);
            }
            System.debug('*** newAstList.size() ' + newAstList.size());
            if (newAstList != NULL &&
                  newAstList.size() > 0) {
                upsert newAstList;
                msg = 'Successfully added ' + newAstList.size() + ' Parts';
            } else {
                msg = 'No Parts were Added. Check for Existing Parts. Config Qty is required.';
            }
        
        } catch (Exception e) {
            String exMsg = e.getMessage();
            if (exMsg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') != -1) {
                exMsg = exMsg.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION');
            }
            msg = 'Error adding Parts: ' + exMsg;
        }
        prw.msg = msg;
        prw.pwList = pwReturnList;
        System.debug('*** msg ' + msg);
        return prw;
    }
    
    @AuraEnabled
    public static partsReturnWrapper deletePart(List<partsWrapper> deletedRow, oppWrapper oppData, partsWrapper assetToBeDeleted, String actionType) {
        String msg = '';
        String acctId = '';
        System.debug('*** oppData ' + oppData);
        String oppId = oppData.OppId;
        Asset assetDeleted = new Asset();
        List<Asset> deleteAstList = new List<Asset>();
        List<Asset> removeAstList = new List<Asset>();
        List<partsWrapper> pwReturnList = new List<partsWrapper>();
        partsReturnWrapper prw = new partsReturnWrapper();
        String deleteOrRemove = '';
        
        if (deletedRow == NULL ||
              deletedRow.size() == 0) {
            msg = 'Error - No Parts were selected.';
            prw.msg = msg;
            return prw;
        }
        try {
            System.debug('*** assetToBeDeleted ' + assetToBeDeleted);
            Asset assetStatus = [SELECT Id, PT_Status__c FROM Asset WHERE Id = :assetToBeDeleted.assetId];
            if (assetStatus.PT_Status__c == 'New') {
                deleteAstList.add(assetStatus);
                deleteOrRemove = 'delete';
            } else {
                deleteOrRemove = 'remove';
                assetDeleted.Id = assetToBeDeleted.assetId;
                assetDeleted.PT_Status__c = 'Pending Removed';
                assetDeleted.PT_Reason__c = deletedRow[0].reason;
                removeAstList.add(assetDeleted);
                
                partsWrapper returnpw = new partsWrapper();
                returnpw.partCode = assetToBeDeleted.partCode;
                returnpw.partName = assetToBeDeleted.partName;
                returnpw.configQty = assetToBeDeleted.configQty;
                returnpw.qty = assetToBeDeleted.qty;
                returnpw.reason = deletedRow[0].reason;
                returnpw.installLocName = assetToBeDeleted.installLocName;
                returnpw.installLocId = assetToBeDeleted.installLocId;
                
                pwReturnList.add(returnpw);
            }
            // delete/remove any kit component parts also
            for (Asset astChild : [
                  SELECT Id, PT_Status__c, PT_Pending_Reason__c, PT_Kit_Parent__r.Name
                  FROM Asset
                  WHERE PT_Kit_Parent__c <> NULL
                  AND PT_Kit_Parent__c = :assetToBeDeleted.assetId
            ]) {
                System.debug('*** astChild ' + astChild);
                if (deleteOrRemove == 'delete') {
                    deleteAstList.add(astChild);
                } else {
                    astChild.PT_Status__c = 'Pending Removed';
                    astChild.PT_Reason__c = 'Kit ' + astChild.PT_Kit_Parent__r.Name + ' Component Removed';
                    removeAstList.add(astChild);
                }
            }
            if (!removeAstList.isEmpty() &&
                  removeAstList.size() > 0) {
                update removeAstList;
            }
            
            if (!deleteAstList.isEmpty() &&
                  deleteAstList.size() > 0) {
                delete deleteAstList;
            }
            
            msg = 'Successfully deleted part';
        } catch (Exception e) {
            String exMsg = e.getMessage();
            if (exMsg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') != -1) {
                exMsg = exMsg.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION');
            }
            msg = 'Error deleting Part: ' + exMsg;
        }
        prw.msg = msg;
        prw.pwList = pwReturnList;
        System.debug('*** msg ' + msg);
        return prw;
    }
    
    @AuraEnabled
    public static partsReturnWrapper refreshKitPart(List<partsWrapper> refreshedRow, oppWrapper oppData, partsWrapper currentKitWrapper, String actionType) {
        System.debug('*** Starting PT_OpportunityService.refreshKitPart');
        String msg = '';
//        String acctId = oppData.AccountId;
        String programId = oppData.ProgramId;
       // Asset currentKitAst = new Asset();
        List<Asset> updateAstList = new List<Asset>();
        List<Asset> addAstList = new List<Asset>();
        List<partsWrapper> pwReturnList = new List<partsWrapper>();
        Map<String, Kit_Products__c> kitNewChildProdMap = new Map<String, Kit_Products__c>();
        Map<String, Asset> kitCurrentChildAssetMap = new Map<String, Asset>();
        partsReturnWrapper prw = new partsReturnWrapper();
        
        System.debug('*** currentKitWrapper ' + currentKitWrapper);
        try {
            // get the latest kit revision from Product2
            Product2 prod = [
                  SELECT Id, PT_Kit_Current_Revision__c
                  FROM Product2
                  WHERE Id = :currentKitWrapper.Id
            ];
            String latestRevCode = prod.PT_Kit_Current_Revision__c;
            System.debug('*** prod ' + prod);
            
            // get the current Asset data
            Asset currentAst = [
                  SELECT Id, Name, PT_Configured_Quantity__c,
                        Product2Id, Product2.Name,
                        PT_Status__c, AccountId, ProductCode,
                        PT_Pending_Configured_Quantity__c, Quantity, PT_Install_Location__c,
                        PT_Is_Kit__c, PT_Kit_Revision_Code__c, PT_Pending_Kit_Revision_Code__c,
                        PT_Pending_Notes__c, PT_Notes__c, PT_Notes_Status__c,
                        PT_Pending_Quantity__c, PT_Reason__c, PT_Pending_Reason__c, PT_Install_Location__r.Name
                  FROM Asset
                  WHERE Id = :currentKitWrapper.assetId
            ];
            
            // remove the current kit asset and add the new kit asset with the new rev code
            //String reason = (!refreshedRow.isEmpty() && refreshedRow.size() > 0) ? refreshedRow[0].reason : currentKitWrapper.reason;
            
            //System.debug('*** currentKit to be removed ' + currentKitWrapper);
            //currentKitAst.Id = currentKitWrapper.assetId;
            //currentKitAst.PT_Status__c = 'Pending Removed';
            //System.debug('*** currentKitAst ' + currentKitAst);
            currentAst.PT_Pending_Kit_Revision_Code__c = latestRevCode;
            update currentAst;
           //String noteStatus = currentAst.PT_Pending_Notes__c != null ? 'Add' : '';
            
//            Asset newKitAsset = new Asset(
//                  Name = currentAst.Product2.Name,
//                  PT_Pending_Configured_Quantity__c = 1,
//                  PT_Pending_Quantity__c = 1,
//                  Product2Id = currentAst.Product2Id,
//                  AccountId = currentAst.AccountId,
//                  PT_Install_Location__c = currentAst.PT_Install_Location__c,
//                  PT_Program__c = programId,
//                  PT_Kit_Revision_Code__c = latestRevCode,
//                  PT_Reason__c = reason,
//                  PT_Pending_Notes__c = currentAst.PT_Pending_Notes__c,
//                  PT_Notes_Status__c = noteStatus,
//                  PT_Status__c = 'New'
//            );
//            System.debug('*** newKitAsset ' + newKitAsset);
//            insert newKitAsset;
            
//            Asset queryAst = [
//                  SELECT Id,Product2Id, ProductCode, Product2.Name, PT_Configured_Quantity__c,
//                        PT_Pending_Configured_Quantity__c, PT_Pending_Quantity__c, PT_Pending_Reason__c, Quantity,
//                        PT_Install_Location__r.Name, PT_Install_Location__c, PT_Reason__c
//                  FROM Asset
//                  WHERE Id = :newKitAsset.Id
//            ];
            
            partsWrapper returnpw = new partsWrapper();
            returnpw.Id = currentAst.Product2Id;
            returnpw.partCode = currentAst.ProductCode;
            returnpw.partName = currentAst.Product2.Name;
            returnpw.configQty = Integer.valueOf(currentAst.PT_Pending_Configured_Quantity__c);
            returnpw.qty = Integer.valueOf(currentAst.PT_Pending_Quantity__c);
            returnpw.reason = currentAst.PT_Reason__c;
            returnpw.installLocName = currentAst.PT_Install_Location__r.Name;
            returnpw.installLocId = currentAst.PT_Install_Location__c;
            returnpw.latestKitRevCode = currentAst.PT_Pending_Kit_Revision_Code__c;
            returnpw.isKit = true;
            
            pwReturnList.add(returnpw);
            
            // get the new children for the Kit
            for (Kit_Products__c kitChild : [
                  SELECT Id,
                        Kit_Product_Code__c,
                        PT_Component_Part__c,
                        PT_Component_Part__r.Name,
                        PT_Component_Part_Code__c,
                        PT_Component_Part_Quantity__c,
                        PT_Kit_Part__c,
                        PT_Kit_Part__r.Name,
                        PT_Kit_Revision_Code__c
                  FROM Kit_Products__c
                  WHERE PT_Kit_Part__c = :currentKitWrapper.Id
                  AND PT_Kit_Revision_Code__c = :latestRevCode
            ]) {
                kitNewChildProdMap.put(kitChild.PT_Component_Part__c, kitChild);
                System.debug('*** kitChild ' + kitChild);
            }
            
            // match the current children components with the latest children components
            for (Asset currentChildAst : [
                  SELECT Id, Name, ProductCode, PT_Configured_Quantity__c, Product2Id, PT_Status__c,
                        PT_Pending_Configured_Quantity__c, Quantity, PT_Install_Location__c,
                        PT_Is_Kit__c, PT_Kit_Revision_Code__c,
                        PT_Pending_Quantity__c, PT_Reason__c, PT_Pending_Reason__c, PT_Install_Location__r.Name
                  FROM Asset
                  WHERE PT_Kit_Parent__c = :currentKitWrapper.assetId
            ]) {
                kitCurrentChildAssetMap.put(currentChildAst.Product2Id, currentChildAst);
                System.debug('*** getting current children ' + currentChildAst);
                if (kitNewChildProdMap.containsKey(currentChildAst.Product2Id)) {
                    Kit_Products__c kitProdChild = kitNewChildProdMap.get(currentChildAst.Product2Id);
                    System.debug('*** kitProdChild.PT_Component_Part_Quantity__c ' + kitProdChild.PT_Component_Part_Quantity__c);
                    System.debug('*** currentChildAst.PT_Configured_Quantity__c ' + currentChildAst.PT_Configured_Quantity__c);
                    System.debug('*** integer currentChildAst.PT_Configured_Quantity__c ' + Integer.valueOf(currentChildAst.PT_Configured_Quantity__c));
                    if (kitProdChild.PT_Component_Part_Quantity__c == Integer.valueOf(currentChildAst.PT_Configured_Quantity__c)) {
                        // same product, same qty - just reassign kit parent to the new kit - do nothing
//                        currentChildAst.PT_Kit_Parent__c = newKitAsset.Id;
//                        currentChildAst.PT_Status__c = 'New';
//                        updateAstList.add(currentChildAst);
                        System.debug('*** child qty match ' + currentChildAst);
                    } else {
                        currentChildAst.PT_Pending_Configured_Quantity__c = kitProdChild.PT_Component_Part_Quantity__c;
//                        currentChildAst.PT_Kit_Parent__c = newKitAsset.Id;
//                        currentChildAst.PT_Status__c = 'New';
                        updateAstList.add(currentChildAst);
                        System.debug('*** update child qty ' + currentChildAst);
                    }
                } else {
                    // remove current child as there was no match
                    currentChildAst.PT_Status__c = 'Pending Removed';
                    updateAstList.add(currentChildAst);
                    System.debug('*** remove child ' + currentChildAst);
                }
            }
            
            // find any new children to add
            for (Kit_Products__c kitNewChildProd : kitNewChildProdMap.values()) {
                if (!kitCurrentChildAssetMap.containsKey(kitNewChildProd.PT_Component_Part__c)) {
                    // add a new Asset
                    Asset astChild = new Asset(
                          Name = kitNewChildProd.PT_Component_Part__r.Name,
                          PT_Pending_Configured_Quantity__c = kitNewChildProd.PT_Component_Part_Quantity__c,
                          PT_Pending_Quantity__c = 0,
                          PT_Kit_Parent__c = currentAst.Id,
                          Product2Id = kitNewChildProd.PT_Component_Part__c,
                          AccountId = currentAst.AccountId,
                          PT_Install_Location__c = currentAst.PT_Install_Location__c,
                          PT_Program__c = programId,
                          PT_Status__c = 'New'
                    );
                    addAstList.add(astChild);
                    System.debug('*** new child ' + astChild);
                }
            }
            
            if (!updateAstList.isEmpty() &&
                  updateAstList.size() > 0) {
                update updateAstList;
            }
            
            if (!addAstList.isEmpty() &&
                  addAstList.size() > 0) {
                insert addAstList;
            }
            
            msg = 'Successfully Refreshed Kit Part';
        } catch (Exception e) {
            String exMsg = e.getMessage();
            if (exMsg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') != -1) {
                exMsg = exMsg.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION');
            }
            msg = 'Error Refreshing Kit Part: ' + exMsg;
        }
        
        prw.msg = msg;
        prw.pwList = pwReturnList;
        System.debug('*** msg ' + msg);
        System.debug('*** Exiting PT_OpportunityService.refreshKitPart');
        return prw;
    }
    
//    public static void serializeOppShipset(Opportunity opp, String quoteId) {
//        System.debug('*** serializeOppShipset ' + opp.Id + ' ' + opp.PT_Is_CPL__c + ' ' + quoteId);
//        System.debug('*** opp ' + opp);
//        List<QuoteShipset> quoteShipSetList = new List<QuoteShipset>();
//        List<L2I_DSH__c> dshList = new List<L2I_DSH__c>();
//        if (opp.PT_Is_CPL__c) {
//            dshList = [
//                  SELECT Id, Name, (
//                        SELECT Id, Name,
//                              Original_Opportunity__c,
//                              Original_Opportunity_Number__c,
//                              PT_Aircraft_Program_Identification_Field__c,
//                              PT_Program__r.Program_Number__c,
//                              PT_Program__r.PT_Program_Type__c,
//                              Original_Opportunity__r.AccountId,
//                              Original_Opportunity__r.Account.Name,
//                              Original_Opportunity__r.L2I_Opportunity_Number__c,
//                              Original_Opportunity__r.PT_Current_Parts_List__c,
//                              Original_Opportunity__r.PT_Current_Parts_List__r.SubmittedUser__r.Name,
//                              Original_Opportunity__r.L2I_Aircraft_Type__r.L2I_Make__c,
//                              Original_Opportunity__r.PT_Parts_List_Revision_Number__c,
//                              Original_Opportunity__r.PT_Revised_Parts_List_Version_Trans__c
//                        FROM Delivery_Schedules__r
//                        WHERE Aircraft__c <> NULL
//                        AND Original_Opportunity__r.PT_Current_Parts_List__c = :quoteId
//                  )
//                  FROM L2I_DSH__c
//                  WHERE Id = :opp.L2I_Delivery_Schedule__c
//            ];
//            System.debug('*** dshList ' + dshList);
//            if (!dshList.isEmpty() &&
//                  dshList.size() > 0) {
//                for (L2I_DSL__c dsl : dshList[0].Delivery_Schedules__r) {
//                    QuoteShipset oppSS = new QuoteShipset();
//                    oppSS.dslId = dsl.Id;
//                    oppSS.dslName = dsl.Name;
//                    oppSS.aircraftIdentification = dsl.PT_Aircraft_Program_Identification_Field__c;
//                    oppSS.programNumber = dsl.PT_Program__r.Program_Number__c;
//                    oppSS.programType = dsl.PT_Program__r.PT_Program_Type__c;
//                    oppSS.partListOppId = dsl.Original_Opportunity__c;
//                    oppSS.accountId = dsl.Original_Opportunity__r.AccountId;
//                    oppSS.accountName = dsl.Original_Opportunity__r.Account.Name;
//                    oppSS.partListOppNumber = dsl.Original_Opportunity__r.L2I_Opportunity_Number__c;
//                    oppSS.partListOppCurrentPartsListId = dsl.Original_Opportunity__r.PT_Current_Parts_List__c;
//                    oppSS.partListOppCurrentPartsListSubmitter = dsl.Original_Opportunity__r.PT_Current_Parts_List__r.SubmittedUser__r.Name;
//                    oppSS.aircraftMake = dsl.Original_Opportunity__r.L2I_Aircraft_Type__r.L2I_Make__c;
//                    oppSS.partListNameRevNumber = dsl.Original_Opportunity__r.PT_Parts_List_Revision_Number__c;
//                    oppSS.partListNameRevNumberTrans = dsl.Original_Opportunity__r.PT_Revised_Parts_List_Version_Trans__c;
//                    quoteShipSetList.add(oppSS);
//                }
//            }
//            System.debug('*** quoteShipSetList.size()  ' + quoteShipSetList.size());
//            if (!quoteShipSetList.isEmpty() &&
//                  quoteShipSetList.size() > 0) {
//                String serialJSON = JSON.serializePretty(quoteShipSetList, false);
//                String docTitle = opp.PT_Part_List_Name_Rev__c + ' Quote Shipsets';
//                String docPath = opp.PT_Part_List_Name_Rev__c + ' Quote Shipsets.txt';
//                Id docLink = opp.Id;
//                PT_ContentDocumentService.createFile(docTitle, docPath, docLink, serialJSON);
//            }
//        }
//    }
    
    @InvocableMethod(Label = 'Revert Pending Part List')
    public static void revertPartList(List<String> oppIds) {
        String oppId = oppIds[0];
        System.debug('*** Starting PT_OpportunityService.revertPartList ' + oppId);
        List<Asset> assetUpdateList = new List<Asset>();
        List<Asset> assetDeleteList = new List<Asset>();
        Map<String, Id> installLocMap = new Map<String, Id>();
        Opportunity pl = [
              SELECT Id, PT_PL_Reverted_Date__c, PT_PL_Reverted_By__c
              FROM Opportunity
              WHERE Id = :oppId
        ];
        pl.PT_PL_Reverted_Date__c = DateTime.now();
        pl.PT_PL_Reverted_By__c = UserInfo.getUserId();
        update pl;
        
        for (PT_Install_Location__c instLoc : [SELECT Id, Name
                                          FROM PT_Install_Location__c
                            WHERE Part_List_Opportunity__c = :oppId]){
            installLocMap.put(instLoc.Name, instLoc.Id);
        }
        
        for (Asset ast : [
              SELECT Id, Quantity, PT_Pending_Quantity__c, PT_Configured_Quantity__c,
                    PT_Pending_Configured_Quantity__c, PT_Status__c, PT_Install_Location__r.Status__c,
                    PT_Install_Location__c, PT_Can_Be_Processed__c, PT_Reason__c, PT_Pending_Reason__c,
                    PT_Notes__c, PT_Pending_Notes__c, PT_Notes_Status__c, PT_Is_Kit__c, PT_Kit_Parent__c, PT_Pending_Kit_Revision_Code__c,
                    PT_Install_Location__r.Part_List_Opportunity__c, PT_Revision_Number__c, PT_Original_Install_Location__c,
                    PT_Install_Location__r.Part_List_Opportunity__r.PT_Parts_List_Revision_Number__c
              FROM Asset
              WHERE PT_Install_Location__r.Part_List_Opportunity__c = :oppId
              AND PT_Install_Location__r.Status__c = 'Active'
//                      AND PT_Can_Be_Processed__c = true
        ]) {
            System.debug('*** ast ' + ast);
            if (ast.PT_Status__c == 'New' ||
                  ast.PT_Status__c == 'Pending Replaced') {
                // Pending Replaced are replacement parts for another part (which is set to Pending Removed)
                assetDeleteList.add(ast);
            } else {
                // clear pending values
                Boolean hasPendingChanges = false;
                if (!String.isBlank(ast.PT_Pending_Notes__c)||
                      !String.isBlank(ast.PT_Notes_Status__c)||
                      !String.isBlank(ast.PT_Pending_Kit_Revision_Code__c)||
                      ast.PT_Pending_Quantity__c != null||
                      ast.PT_Pending_Configured_Quantity__c != null ||
					  ast.PT_Reason__c != NULL){
                    hasPendingChanges = true;
                }
                ast.PT_Pending_Notes__c = null;
                ast.PT_Notes_Status__c = '';
                ast.PT_Pending_Kit_Revision_Code__c = '';
                ast.PT_Pending_Quantity__c = null;
                ast.PT_Pending_Configured_Quantity__c = null;
                ast.PT_Reason__c = '';
                
                if (ast.PT_Status__c == 'Active' &&
                      hasPendingChanges){
                    assetUpdateList.add(ast);
                }
                
                if (ast.PT_Status__c == 'Pending Move' ||
                      ast.PT_Status__c == 'Pending Removed') {
                    if (ast.PT_Status__c == 'Pending Move') {
                        // reset to the original install location
                        ast.PT_Install_Location__c = installLocMap.get(ast.PT_Original_Install_Location__c);
                        ast.PT_Original_Install_Location__c = '';
                    }
                    ast.PT_Status__c = 'Active';
                    assetUpdateList.add(ast);
                }
            }
        }
        System.debug('*** assetDeleteList.size() ' + assetDeleteList.size());
        if (!assetDeleteList.isEmpty() && assetDeleteList.size() > 0) {
            delete assetDeleteList;
        }
        System.debug('*** assetUpdateList.size() ' + assetUpdateList.size());
        if (!assetUpdateList.isEmpty() && assetUpdateList.size() > 0) {
            update assetUpdateList;
        }
        System.debug('*** Exiting PT_OpportunityService.revertPartList ');
    }
    
    @AuraEnabled(cacheable=true)
    public static List<KitComponentWrapper> getKitComponents(Id assetId) {
        System.debug('*** getKitComponents');
        String msg = '';
        List<KitComponentWrapper> kcList = new List<KitComponentWrapper>();
        for (Asset ast : [
              SELECT Id, Name, PT_Status__c, ProductCode, PT_Kit_Parent__c, PT_Kit_Parent__r.Name, PT_Kit_Parent__r.PT_Is_Kit__c,
                    PT_Configured_Quantity__c, PT_Pending_Configured_Quantity__c, Quantity, PT_Pending_Quantity__c
              FROM Asset
              WHERE PT_Kit_Parent__c = :assetId
              AND PT_Kit_Parent__r.PT_Is_Kit__c = true
              AND PT_Can_be_Processed__c = true
              ORDER BY productCode
        ]){
            System.debug('*** ast ' + ast);
            KitComponentWrapper kc = new KitComponentWrapper();
            kc.kcName = ast.Name;
            kc.kcStatus = ast.PT_Status__c;
            kc.kcProductCode = ast.ProductCode;
            kc.kcParentName = ast.PT_Kit_Parent__r.Name;
            kc.kcConfigQty = ast.PT_Configured_Quantity__c;
            kc.kcPendConfigQty = ast.PT_Pending_Configured_Quantity__c;
            kc.kcQty = ast.Quantity;
            kc.kcPendQty = ast.PT_Pending_Quantity__c;
            kc.kcIsKit = ast.PT_Kit_Parent__r.PT_Is_Kit__c;
            kcList.add(kc);
        }
        
        return kcList;
    }
    
    public class partsReturnWrapper {
        @AuraEnabled public String msg { get; set; }
        @AuraEnabled public List<partsWrapper> pwList { get; set; }
        @AuraEnabled public String oppId { get; set; }
        public partsReturnWrapper() {
        }
    }
    
    public class partsWrapper {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String assetId { get; set; }
        @AuraEnabled public String findMsg { get; set; }
        @AuraEnabled public String partCode { get; set; }
        @AuraEnabled public String basePartCode { get; set; }
        @AuraEnabled public String partName { get; set; }
        @AuraEnabled public Integer configQty { get; set; }
        @AuraEnabled public Integer qty { get; set; }
        @AuraEnabled public String reason { get; set; }
//        @AuraEnabled public String note { get; set; }
//        @AuraEnabled public String noteName { get; set; }
        @AuraEnabled public String installLocName { get; set; }
        @AuraEnabled public String installLocId { get; set; }
        @AuraEnabled public List<String> sgIdList { get; set; }
        @AuraEnabled public String oppId { get; set; }
        @AuraEnabled public Boolean isDuplicate { get; set; }
        @AuraEnabled public Boolean isKit { get; set; }
        @AuraEnabled public String prevKitRevCode { get; set; }
        @AuraEnabled public String latestKitRevCode { get; set; }
        @AuraEnabled public String notes { get; set; }
        @AuraEnabled public String notesStatus { get; set; }
        // Added by Khrisna for W-003786
        @AuraEnabled public Boolean isPlaceholder { get; set; }
        @AuraEnabled public String proposedPartCode { get; set; }
        @AuraEnabled public String proposedPartNomenclature { get; set; }
        // End W-003786

        public partsWrapper() {
        }
    }
    
    public class OppWrapper {
        @AuraEnabled public String AccountId { get; set; }
        @AuraEnabled public String OppName { get; set; }
        @AuraEnabled public String OppId { get; set; }
        @AuraEnabled public String SalesRepId { get; set; }
        @AuraEnabled public Date StartDate { get; set; }
        @AuraEnabled public String Msg { get; set; }
        @AuraEnabled public String PriceBookId { get; set; }
        @AuraEnabled public String ProgramId { get; set; }
        public OppWrapper() {
        }
    }
    
    public class NoteWrapper {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String OppId { get; set; }
        @AuraEnabled public String noteName { get; set; }
        @AuraEnabled public String notes { get; set; }
        @AuraEnabled public String Msg { get; set; }
        public NoteWrapper() {
        }
    }
    
    public class NoteStatusWrapper {
        @AuraEnabled public String noteName { get; set; }
        @AuraEnabled public String noteStatus { get; set; }
        public NoteStatusWrapper(String noteName, String noteStatus) {
            this.noteName = noteName;
            this.noteStatus = noteStatus;
        }
    }
    
    public class ShipSetWrapper {
        @AuraEnabled public String dslId { get; set; }
        @AuraEnabled public String dslName { get; set; }
        @AuraEnabled public String programId { get; set; }
        @AuraEnabled public String cplId { get; set; }
        @AuraEnabled public String Msg { get; set; }
        public ShipSetWrapper(String dslId, String programId, String cplId, String dslName, String msg) {
            this.dslId = dslId;
            this.dslName = dslName;
            this.programId = programId;
            this.cplId = cplId;
            this.Msg = msg;
        }
        public ShipSetWrapper(){
        
        }
    }
    
    public class CPLWrapper {
        @AuraEnabled public String oppId { get; set; }
        @AuraEnabled public String cplName { get; set; }
        @AuraEnabled public String cplPartListName { get; set; }
        @AuraEnabled public String Msg { get; set; }
        public CPLWrapper(String oppId, String cplName, String cplPartListName) {
            this.oppId = oppId;
            this.cplName = cplName;
            this.cplPartListName = cplPartListName;
        }
        public CPLWrapper(){
        
        }
    }
    
    public class KitComponentWrapper {
        @AuraEnabled public String kcName { get; set; }
        @AuraEnabled public String kcParentName { get; set; }
        @AuraEnabled public String kcProductCode { get; set; }
        @AuraEnabled public String kcStatus { get; set; }
        @AuraEnabled public Decimal kcConfigQty { get; set; }
        @AuraEnabled public Decimal kcPendConfigQty { get; set; }
        @AuraEnabled public Decimal kcQty { get; set; }
        @AuraEnabled public Decimal kcPendQty { get; set; }
        @AuraEnabled public Boolean kcIsKit { get; set; }
        @AuraEnabled public String Msg { get; set; }
        public KitComponentWrapper(){
        
        }
    }
    
//    public class quoteShipset {
//        public String dslId;
//        public String dslName;
//        public String aircraftIdentification;
//        public String programNumber;
//        public String programType;
//        public String partListOppId;
//        public String accountId;
//        public String accountName;
//        public String partListOppNumber;
//        public String partListOppCurrentPartsListId;
//        public String partListOppCurrentPartsListSubmitter;
//        public String aircraftMake;
//        public Decimal partListNameRevNumber;
//        public String partListNameRevNumberTrans;
//    }
}