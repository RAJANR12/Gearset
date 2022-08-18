/**
 *      @author       Sarah Kennedy
 *      @date         09/27/2020
 *      @description  Trigger Functions for PT_AssetTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy               09/27/2020          Initial scaffold
 */
public class PT_AssetTriggerFunctions {

    public static void validateAssetLockedOnUpdate(Map<Id, Asset> newAssetMap) {
        // do not throw lock error if Sys Admin (causes issues with CPQ jobs otherwise)
        Id userProfileId = UserInfo.getProfileId();
        String userType = UserInfo.getUserType();
        Id profileId = [SELECT Id FROM Profile where name = 'System Administrator' Limit 1].Id;
        if (userProfileId == profileId ||
              userType == 'AutomatedProcess') {
            return;
        }

        Map<Id, Asset> assetMap = new Map<Id, Asset>();

        try {
            for (Asset ast : newAssetMap.values()) {
                if (ast.PT_Program__c != null) {
                    System.debug('*** ast ' + ast);
                    assetMap.put(ast.Id, ast);
                }
            }
            for (Asset astProg : [
                  SELECT Id, PT_Program__r.MROD_Approval_Status__c,
                        PT_Install_Location__c, PT_Program__c,
                        PT_Install_Location__r.Part_List_Opportunity__c,
                        PT_Install_Location__r.Part_List_Opportunity__r.PT_PL_Approval_Status__c
                  FROM Asset
                  WHERE Id IN :assetMap.keySet()
            ]) {
                // check MROD Approval Status
                if (astProg.PT_Program__c != null &&
                      astProg.PT_Program__r.MROD_Approval_Status__c == 'Pending') {
                    newAssetMap.get(astProg.Id).addError('Asset may not be modified while the Program is in an Approval process.');
                } else {
                    // check Part List Approval Status
                    if (astProg.PT_Install_Location__c != null &&
                          astProg.PT_Install_Location__r.Part_List_Opportunity__c != null &&
                          astProg.PT_Install_Location__r.Part_List_Opportunity__r.PT_PL_Approval_Status__c == 'Pending') {
                        newAssetMap.get(astProg.Id).addError('Asset may not be modified while the Part List is in an Approval process.');

                    }
                }
            }
        } catch (Exception e){
            // CPQ Post Install error avoidance:
//           CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY: PT_AssetTrigger: execution of BeforeUpdate caused by: System.SObjectException: Invalid field Id Class.PT_AssetTriggerFunctions.validateAssetLockedOnUpdate: line 27, column 1 Class.PT_AssetTriggerHandler.beforeUpdate: line 59, column 1 Class.L2I_TriggerHandler.run: line 53, column 1 Trigger.PT_AssetTrigger: line 24, column 1
            System.debug('*** Error Asset TriggerFunctions validateAssetLockedOnUpdate ' + e.getMessage());
            System.debug('*** User ' + UserInfo.getProfileId() + ' ' + UserInfo.getUserName() + ' ' + UserInfo.getUserId());
        }
    }

    public static void validateAssetLockedOnDelete(Map<Id, Asset> oldAssetMap) {
        // do not throw lock error if Sys Admin (causes issues with CPQ jobs otherwise)
        Id userProfileId = UserInfo.getProfileId();
        String userType = UserInfo.getUserType();
        Id profileId = [SELECT Id FROM Profile where name = 'System Administrator' Limit 1].Id;
        if (userProfileId == profileId ||
              userType == 'AutomatedProcess') {
            return;
        }

        // using trigger instead of validation rule as you cannot prevent a deletion via a validation rule
        Map<Id, Asset> assetMap = new Map<Id, Asset>();

        for (Asset ast : oldAssetMap.values()) {
            if (ast.PT_Program__c != null) {
                assetMap.put(ast.Id, ast);
            }
        }

        for (Asset astProg : [
              SELECT Id, PT_Program__r.MROD_Approval_Status__c,
                    PT_Install_Location__c, PT_Program__c,
                    PT_Install_Location__r.Part_List_Opportunity__c,
                    PT_Install_Location__r.Part_List_Opportunity__r.PT_PL_Approval_Status__c
              FROM Asset
              WHERE Id IN :assetMap.keySet()
        ]) {
            if (astProg.PT_Program__c != null &&
                  astProg.PT_Program__r.MROD_Approval_Status__c == 'Pending') {
                oldAssetMap.get(astProg.Id).addError('Asset may not be deleted while the Program is in an Approval process.');
            } else {
                // check Part List Approval Status
                if (astProg.PT_Install_Location__c != null &&
                      astProg.PT_Install_Location__r.Part_List_Opportunity__c != null &&
                      astProg.PT_Install_Location__r.Part_List_Opportunity__r.PT_PL_Approval_Status__c == 'Pending') {
                    oldAssetMap.get(astProg.Id).addError('Asset may not be deleted while the Part List is in an Approval process.');

                }
            }
        }
    }

    public static void validateAssetLockedAfterInsert(Map<Id, Asset> newAssetMap) {
        // do not throw lock error if Sys Admin (causes issues with CPQ jobs otherwise)
        Id userProfileId = UserInfo.getProfileId();
        String userType = UserInfo.getUserType();
        Id profileId = [SELECT Id FROM Profile where name = 'System Administrator' Limit 1].Id;
        if (userProfileId == profileId ||
              userType == 'AutomatedProcess') {
            return;
        }

        Map<Id, Asset> assetMap = new Map<Id, Asset>();

        for (Asset ast : newAssetMap.values()) {
            if (ast.PT_Program__c != null) {
                assetMap.put(ast.Id, ast);
            }
        }
        for (Asset astProg : [
              SELECT Id, PT_Program__r.MROD_Approval_Status__c,
                    PT_Install_Location__c, PT_Program__c,
                    PT_Install_Location__r.Part_List_Opportunity__c,
                    PT_Install_Location__r.Part_List_Opportunity__r.PT_PL_Approval_Status__c
              FROM Asset
              WHERE Id IN :assetMap.keySet()
        ]) {
            if (astProg.PT_Program__c != null &&
                  astProg.PT_Program__r.MROD_Approval_Status__c == 'Pending') {
                newAssetMap.get(astProg.Id).addError('Asset may not be inserted while the Program is in an Approval process.');
            } else {
                // check Part List Approval Status
                if (astProg.PT_Install_Location__c != null &&
                      astProg.PT_Install_Location__r.Part_List_Opportunity__c != null &&
                      astProg.PT_Install_Location__r.Part_List_Opportunity__r.PT_PL_Approval_Status__c == 'Pending') {
                    newAssetMap.get(astProg.Id).addError('Asset may not be inserted while the Part List is in an Approval process.');

                }
            }
        }
    }

    public static void processMissingQuantity(List<Asset> newAssetList) {
        for (Asset ast : newAssetList) {
            if (ast.PT_Program__c != null) {
                if (ast.Quantity == null ||
                      ast.Quantity == 0) {
                    ast.PT_Pending__c = null;
                    ast.PT_MROD__c = null;
                }
            }
        }
    }

    public static void validateConfigQty(List<Asset> newAssetList) {
        // do not throw lock error if Sys Admin (causes issues with CPQ jobs otherwise)
        Id userProfileId = UserInfo.getProfileId();
        String userType = UserInfo.getUserType();
        Id profileId = [SELECT Id FROM Profile where name = 'System Administrator' Limit 1].Id;
        if (userProfileId == profileId ||
              userType == 'AutomatedProcess') {
            return;
        }
        for (Asset ast : newAssetList) {
            if (ast.PT_Program__c != null) {
                Decimal qty = ast.PT_Pending_Quantity__c == null ? ast.Quantity : ast.PT_Pending_Quantity__c;
                Decimal configQty = ast.PT_Pending_Configured_Quantity__c == null ? ast.PT_Configured_Quantity__c : ast.PT_Pending_Configured_Quantity__c;
                if (configQty < qty){
                    ast.addError('Quantity cannot be greater than Configured Quantity.');
                }
            }
        }
    }
    // 3.4.2021 Sarah K W-003189
    public static void validateConformityDefaultWarehouse(List<Asset> newAssetList) {
        // do not throw lock error if Sys Admin (causes issues with CPQ jobs otherwise)
        Id userProfileId = UserInfo.getProfileId();
        String userType = UserInfo.getUserType();
        Id profileId = [SELECT Id FROM Profile where name = 'System Administrator' Limit 1].Id;
        if (userProfileId == profileId ||
              userType == 'AutomatedProcess') {
            return;
        }
        Set<Id> programIds = new Set<Id>();
        for (Asset ast : newAssetList) {
            if (ast.PT_Program__c != null && !String.isBlank(ast.PT_Warehouse__c)) {
                programIds.add(ast.PT_Program__c);
            }
        }
        if(programIds.size() > 0) {
            Map<Id, PT_Program__c> programRecordsMap = new Map<Id, PT_Program__c>([SELECT Id, PT_Program_Type__c FROM PT_Program__c WHERE Id IN :programIds]);
            for (Asset ast : newAssetList) {
                if (!String.isBlank(ast.PT_Warehouse__c) && ast.PT_Program__c != null && programRecordsMap.containsKey(ast.PT_Program__c)) {
                    if (programRecordsMap.get(ast.PT_Program__c).PT_Program_Type__c == 'Retrofit' && !ast.PT_Conformity_Required__c && ast.PT_Conformity_Overwritten__c != 'Yes') {
                        ast.addError('Conformity required for NonDefault Conforming Org.');
                    }
                }
            }
        }
    }
    
    //6.30.2021  Alvin C W-003746   
    public static void populateUsageEndDate(List<Asset> newAssetList){
        for (Asset ast : newAssetList) {
            if (ast.UsageEndDate != null) {
                ast.UsageEndDate =  Date.Today();
            }
        }
        
    }

    public static void updateWarehouseAltField(List<Asset> newAssetList, Map<Id, Asset> oldAssetMap) {
        for (Asset ast : newAssetList) {
            // Updated by Lipton for W-003995
            // Added more filter to prevent recursion
            if (ast.PT_Warehouse__c != null
                && ast.PT_Warehouse__c != ast.PT_xx_Warehouse_Text__c) {
                ast.PT_xx_Warehouse_Text__c = ast.PT_Warehouse__c;
            }
        }
    }

    public static void disallowQtyUpdateForKits(List<Asset> newAssetList, Map<Id, Asset> oldAssetMap) {
        for (Asset ast : newAssetList) {
            if (ast.PT_Is_Kit__c) {
                if (ast.PT_Status__c != oldAssetMap.get(ast.Id).PT_Status__c){
                    System.debug('*** in approval');
                    // in the PL Approval process, allow setting of qtys
                } else {
                    System.debug('*** ast.PT_Status__c ' + ast.PT_Status__c);
                    System.debug('*** oldAssetMap.get(ast.Id).PT_Status__c ' + oldAssetMap.get(ast.Id).PT_Status__c);
                    if (ast.PT_Pending_Quantity__c != oldAssetMap.get(ast.Id).PT_Pending_Quantity__c ||
                          ast.PT_Pending_Configured_Quantity__c != oldAssetMap.get(ast.Id).PT_Pending_Configured_Quantity__c) {
                        ast.addError('Kit Part quantities may not be changed.');
                    }
                }
            }
        }
    }


    /**
    * @description
    * helper method to update the total order quantity for all child assets on parent asset
    * @author Arun | 01-17-2021
    * @param List<Asset> newAssetList
    * @param Map<Id Asset> oldAssetMap
    * @param Boolean isInsert
    * @param Boolean isUpdate
    * @param Boolean isDelete
    **/
    public static void updateParentTotalOrderQty(List<Asset> newAssetList, List<Asset> oldAssetList, Map<Id, Asset> oldAssetMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
        System.debug('*** in PT_AssetTriggerFunctions.updateParentTotalOrderQty :: Start');
        Set<Id> parentIds = new Set<Id>();
        //List<Asset> assetList = isDelete ? oldAssetList: newAssetList;
        
        List<Asset> assetList =  new List<Asset>();
        
        if( isDelete){
            assetList = oldAssetList;
        }else {
            assetList =  newAssetList; 
        }
        //System.debug('***PT_AssetTriggerFunctions.updateParentTotalOrderQty :: assetList.size :: ' + assetList.size());
        
        for(Asset asset: assetList) {
             //System.debug('***PT_AssetTriggerFunctions.updateParentTotalOrderQty :: asset.Id :: ' + asset.Id);
            if((isDelete || isInsert || (isUpdate && asset.PT_Order_Quantity__c != oldAssetMap.get(asset.Id).PT_Order_Quantity__c) ) && asset.ParentId != null && asset.PT_Case__c != null) {
                parentIds.add(asset.ParentId);
                System.debug('*** asset.ParentId ' + asset.ParentId);
               
            }
        }
        

        if(parentIds.isEmpty()) {
            return;}

        System.debug('*** parentIds ' + parentIds);
        Map<Id, Decimal> assetToQtyMap = new Map<Id, Decimal>();
        for(AggregateResult result: [Select SUM(PT_Order_Quantity__c ), ParentId From Asset Where ParentId IN :parentIds and PT_Case__c != null Group By ParentId]) {
            assetToQtyMap.put((Id)result.get('ParentId'), (Decimal)result.get('expr0'));
        }

        List<Asset> parentAssets = new List<Asset>();
        for(Id parentId: assetToQtyMap.keySet()) {
            parentAssets.add(new Asset(Id = parentId, PT_Total_Order_Quantity__c = assetToQtyMap.get(parentId)));
        }
        System.debug('*** parentAssets.size() ' + parentAssets.size());
        Database.SaveResult[] asaList = Database.update(parentAssets, false);
        for (Database.SaveResult sr : asaList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated the Asset. Asset ID: ' + sr.getId());
            } else {
                // Operation failed, so get all errors
                for (Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }

    /**
    * @description
    * Helper method to update the total number of assets on the case
    * @author Arun | 01-20-2021
    * @param List<Asset> newAssetList
    * @param List<Asset> oldAssetList
    * @param Map<Id Asset> oldAssetMap
    * @param Boolean isInsert
    * @param Boolean isUpdate
    * @param Boolean isDelete
    **/
    public static void updateTotalAssetsOnCase(List<Asset> newAssetList, List<Asset> oldAssetList, Map<Id, Asset> oldAssetMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
        Set<Id> caseIds = new Set<Id>();
        System.debug('***PT_AssetTriggerFunctions.updateTotalAssetsOnCase :: Start');
        List<Asset> assetList = isDelete ? oldAssetList: newAssetList;
        for(Asset asset: assetList) {
            //System.debug('***PT_AssetTriggerFunctions.updateTotalAssetsOnCase ::  asset.Id :: ' + asset.Id);
            if((isInsert && asset.PT_Case__c != null) || (isUpdate && asset.PT_Case__c != oldAssetMap.get(asset.Id).PT_Case__c) ) {
                caseIds.add(asset.PT_Case__c);
            } else if(isDelete && asset.PT_Case__c != null) {
                caseIds.add(asset.PT_Case__c);
            }
        }

        if(caseIds.isEmpty()) {
            return;}

        Map<Id, Decimal> caseToAssetCountMap = new Map<Id, Decimal>();
        for(AggregateResult result: [Select count(Id), PT_Case__c From Asset Where PT_Case__c IN :caseIds Group By PT_Case__c]) {
            caseToAssetCountMap.put((Id)result.get('PT_Case__c'), (Decimal)result.get('expr0'));
        }

        List<Case> cases = new List<Case>();
        for(Id caseId: caseToAssetCountMap.keySet()) {
            cases.add(new Case(Id = caseId, PT_Total_Assets__c = caseToAssetCountMap.get(caseId)));
        }
        Database.update(cases, false);
    }

    /**
    * @description
    * Validation to prevent deleting the Asset once the Case is in Ordered Status
    * @author Arun | 01-26-2021
    * @param List<Asset> oldAssetList
    **/
    public static void validateAssetDeletion(List<Asset> oldAssetList) {
        Map<Id, List<Asset>> caseToAssetMap = new Map<Id, List<Asset>>();
        for(Asset asset: oldAssetList) {
            if(asset.PT_Case__c != null && asset.ParentId != null && asset.SBQQ__OrderProduct__c != null) {
                if(caseToAssetMap.containsKey(asset.PT_Case__c)) {
                    caseToAssetMap.get(asset.PT_Case__c).add(asset);
                } else {
                    caseToAssetMap.put(asset.PT_Case__c, new List<Asset>{asset});
                }
            }
        }

        if(caseToAssetMap.isEmpty()) { return; }

        Map<Id, Case> cases = new Map<Id, Case>([Select Id, Status From Case Where Id IN :caseToAssetMap.keySet() And Status = 'Ordered']);
        for(Id caseId: caseToAssetMap.keySet()) {
            if(!cases.containsKey(caseId)) { continue; }
            for(Asset asset: caseToAssetMap.get(caseId)) {
                asset.addError('You cannot remove this Asset from the Case as it has been Ordered');
            }
        }
    }

    /*
    * @author           Lipton Abillar
    * @date             09/23/2021
    * @workitem         W-003567
    * @description      If the PT_Status__c is changed to Pending, roll up to Install Location
    *                   Updates in Future method to avoid recurssion error
    * @trigger          PT_AssetTriggerHandler.afterUpdate()
    * Developer:        Lipton Abillar      09/21/2021      Create
    */
    public static void rollupPendingStatus(List<Asset> newAssetList, Map<Id, Asset> oldAssetMap) {
        Set<Id> installLocIdSet = new Set<Id>();

        for (Asset a : newAssetList) {
            if (a.PT_Is_Pending__c && a.PT_Is_Pending__c != oldAssetMap.get(a.Id).PT_Is_Pending__c) {
                installLocIdSet.add(a.PT_Install_Location__c);
            }
        }

        if (!installLocIdSet.isEmpty()) {
            rollupPendingStatusUpdate(installLocIdSet);
        }
    }

    @future
    public static void rollupPendingStatusUpdate(Set<Id> installlocIdSet) {
        List<PT_Install_Location__c> installLocList = [SELECT Id, PT_Approval_Status__c FROM PT_Install_Location__c
                                                        WHERE Id IN :installLocIdSet AND PT_Approval_Status__c != 'Pending'];
        for (PT_Install_Location__c il : installLocList) {
            il.PT_Approval_Status__c = 'Pending';
        }
        update installLocList;
    }


//    public static void validateOppAsset(List<Asset> newAssetList) {
//        Set<Id> iLocIds = new Set<Id>();
//        Set<Id> iLocIdsToProcess = new Set<Id>();
//        Map<String, Integer> iLocPart = new Map<String, Integer>();
//
//        for (Asset ast : newAssetList) {
//            if (ast.PT_Install_Location__c != NULL) {
//                iLocIds.add(ast.PT_Install_Location__c);
//            }
//        }
//        for (Asset astOpp : [
//              SELECT
//                    Id, PT_Install_Location__c, PT_Install_Location__r.Part_List_Opportunity__c, PT_Configured_Quantity__c,
//                    Quantity, PT_Install_Location__r.Part_List_Opportunity__r.PT_Is_CPL__c,
//                    PT_Install_Location__r.Part_List_Opportunity__r.PT_Is_PPL__c,
//                    PT_Install_Location__r.Part_List_Opportunity__r.StageName,
//                    Product2Id, Product2.Name, ProductCode
//              FROM Asset
//              WHERE PT_Install_Location__c IN :iLocIds
//              AND PT_Install_Location__r.Part_List_Opportunity__c <> NULL
//              AND (PT_Install_Location__r.Part_List_Opportunity__r.PT_Is_CPL__c = true
//              OR PT_Install_Location__r.Part_List_Opportunity__r.PT_Is_PPL__c = true)
//              AND PT_Install_Location__r.Part_List_Opportunity__r.StageName = 'Delivery'
//              AND Product2Id <> NULL
//              AND ProductCode <> NULL
//        ]) {
//            iLocIdsToProcess.add(astOpp.PT_Install_Location__c);
//            if (!iLocPart.containsKey(astOpp.PT_Install_Location__c + ':' + astOpp.ProductCode)){
//                iLocPart.put(astOpp.PT_Install_Location__c + ':' + astOpp.ProductCode, 0);
//            }
//            Integer pCount = iLocPart.get(astOpp.PT_Install_Location__c + ':' + astOpp.ProductCode);
//            pCount++;
//            iLocPart.put(astOpp.PT_Install_Location__c + ':' + astOpp.ProductCode, pCount);
//        }
//
//        for (Asset ast : newAssetList) {
//            if (iLocIdsToProcess.contains(ast.PT_Install_Location__c)) {
//                if (ast.PT_Configured_Quantity__c == NULL ||
//                      ast.PT_Configured_Quantity__c <= 0) {
//                    ast.addError('Config Qty is missing, 0 or negative');
//                } else {
//                    if (ast.Quantity == NULL ||
//                          ast.Quantity <= 0) {
//                        ast.Quantity = ast.PT_Configured_Quantity__c;
//                    }
//                }
//                if (iLocPart.containsKey(ast.PT_Install_Location__c + ':' + ast.ProductCode)) {
//                    if (iLocPart.get(ast.PT_Install_Location__c + ':' + ast.ProductCode) > 1) {
//                        ast.addError('Product ' + ast.ProductCode + ' already exists ');
//                    }
//                }
//            }
//        }
//    }
}