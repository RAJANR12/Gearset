/**
 *      @author       Sarah Kennedy
 *      @date         09/27/2020
 *      @description  Trigger Handler for PT_AssetTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy               09/27/2020          Initial scaffold
 */


public class PT_AssetTriggerHandler extends L2I_TriggerHandler {

    private Map<Id, Asset> newAssetMap;
    private List<Asset> newAssetList;

    private Map<Id, Asset> oldAssetMap;
    private List<Asset> oldAssetList;

    /**
    * @Workitem W-003995 
    * @description
    * Prevent recursion on Update DMLs
    * @author Lipton Abillar | 10-11-2021
    **/
    private static Boolean isRecursive = false;

    public PT_AssetTriggerHandler() {
        this.newAssetMap = (Map<Id, Asset>) Trigger.newMap;
        this.newAssetList = (List<Asset>) Trigger.new;

        this.oldAssetMap = (Map<Id, Asset>) Trigger.oldMap;
        this.oldAssetList = (List<Asset>) Trigger.old;
    }

    public override void afterInsert() {
// valid trigger context vars:
//     newAssetList  (not modifiable)
//     newAssetMap
        System.debug('======= executing Asset_TriggerHander::afterInsert()');
        PT_AssetTriggerFunctions.validateAssetLockedAfterInsert(newAssetMap);
        PT_AssetTriggerFunctions.updateParentTotalOrderQty(newAssetList, oldAssetList, oldAssetMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete); // Added by Arun
        PT_AssetTriggerFunctions.updateTotalAssetsOnCase(newAssetList, oldAssetList, oldAssetMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete); // Added by Arun
    }

public override void beforeInsert() {
// valid trigger context vars:
//     newAssetList  (not modifiable)
//     newAssetMap
    System.debug('======= executing Asset_TriggerHander::beforeInsert()');
    PT_AssetTriggerFunctions.updateWarehouseAltField(newAssetList, oldAssetMap); // Updated by Lipton for W-003995
    PT_AssetTriggerFunctions.processMissingQuantity(newAssetList);
    PT_AssetTriggerFunctions.populateUsageEndDate(newAssetList);
//    PT_AssetTriggerFunctions.validateOppAsset(newAssetList);

}

    public override void beforeUpdate() {
// valid trigger context vars:
//     newAssetList  (modifiable)
//     newAssetMap
//     oldAssetList
//     oldAssetMap
        System.debug('======= executing Asset_TriggerHander::beforeUpdate()');
        if (Test.isRunningTest() || !isRecursive) { // Added by Lipton for W-003995
            PT_AssetTriggerFunctions.validateConformityDefaultWarehouse(newAssetList);
            PT_AssetTriggerFunctions.updateWarehouseAltField(newAssetList, oldAssetMap); // Updated by Lipton for W-003995
            PT_AssetTriggerFunctions.validateAssetLockedOnUpdate(newAssetMap);
            PT_AssetTriggerFunctions.processMissingQuantity(newAssetList);
            PT_AssetTriggerFunctions.validateConfigQty(newAssetList);
            PT_AssetTriggerFunctions.disallowQtyUpdateForKits(newAssetList,oldAssetMap);
        }
        //    PT_AssetTriggerFunctions.validateOppAsset(newAssetList);
        //PT_AssetTriggerFunctions.updateInstallLocPicklist(newAssetList, oldAssetMap); //Added by Jan Geronga for W-002662
    }
    
    public override void afterUpdate() {
        // valid trigger context vars:
        // newAssetList  (not modifiable)
        // newAssetMap
        // oldAssetList
        // oldAssetMap
        if (Test.isRunningTest() || !isRecursive) {// Added by Lipton for W-003995
            System.debug('======= executing Asset_TriggerHander::afterUpdate()');
            PT_AssetTriggerFunctions.updateParentTotalOrderQty(newAssetList, oldAssetList, oldAssetMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete); // Added by Arun
            System.debug('======= executing Asset_TriggerHander::after calling updateParentTotalOrderQty inside After Update');
            PT_AssetTriggerFunctions.updateTotalAssetsOnCase(newAssetList, oldAssetList, oldAssetMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete); // Added by Arun
            PT_AssetTriggerFunctions.rollupPendingStatus(newAssetList, oldAssetMap); // Added by Lipton for W-003567
        }
        isRecursive = true; // Added by Lipton for W-003995
   }


    public override void beforeDelete() {
// valid trigger context vars:
//     oldAssetList
//     oldAssetMap
        System.debug('======= executing Asset_TriggerHander::beforeDelete()');
        PT_AssetTriggerFunctions.validateAssetLockedOnDelete(oldAssetMap);
        PT_AssetTriggerFunctions.validateAssetDeletion(oldAssetList); // Added by Arun
    }

   public override void afterDelete() {
    // valid trigger context vars:
    // oldAssetList
    // oldAssetMap
       System.debug('======= executing Asset_TriggerHander::afterDelete()');
       PT_AssetTriggerFunctions.updateTotalAssetsOnCase(newAssetList, oldAssetList, oldAssetMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete); // Added by Arun
       PT_AssetTriggerFunctions.updateParentTotalOrderQty(newAssetList, oldAssetList, oldAssetMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete); // Added by Arun
   }

//public override void afterUndelete() {
// valid trigger context vars:
//     newAssetList  (not modifiable)
//     newAssetMap
//System.debug('====== executing L2I_Asset_TriggerHander::afterUndelete()');
//}

}