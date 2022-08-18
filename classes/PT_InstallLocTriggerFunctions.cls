/**
 *      @author       Sarah Kennedy
 *      @date         09/27/2020
 *      @description  Trigger Functions for PT_InstallLocationTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy               09/27/2020          Initial scaffold
 */
public without sharing class PT_InstallLocTriggerFunctions {
    
    public static void setInstallLocsName(List<PT_Install_Location__c> newInstallLocList) {
        for (PT_Install_Location__c newInstLoc : newInstallLocList) {
            newInstLoc.PT_Install_Location__c = newInstLoc.Name;
        }
    }

//    public static void setInstallLocs(List<PT_Install_Location__c> newInstallLocList) {
//        // populate the install_locations picklist for the Grid Buddy droprown
//        for (PT_Install_Location__c newInstLoc : newInstallLocList) {
//            newInstLoc.Install_Locations__c = newInstLoc.Name;
//        }
//    }
    
    public static void updateInstallLocsName(List<PT_Install_Location__c> newInstallLocList, Map<Id, PT_Install_Location__c> oldInstallLocMap) {
        for (PT_Install_Location__c newInstallLoc : newInstallLocList) {
            PT_Install_Location__c oldInstallLoc = oldInstallLocMap.get(newInstallLoc.Id);
            if (newInstallLoc.Name != oldInstallLoc.Name) {
                newInstallLoc.Name = oldInstallLoc.Name;
                newInstallLoc.PT_Install_Location__c = oldInstallLoc.Name;
            }
        }
    }
    
    public static void updatePendingMRODs(Map<Id, PT_Install_Location__c> newInstallLocMap) {
        Set<Id> ilIds = newInstallLocMap.keySet();
        List<Asset> updateAssets = [
              SELECT Id, PT_Install_Location__c, PT_Pending__c, PT_Airbus_D1_Date__c
              FROM Asset
              WHERE PT_Install_Location__c IN :ilIds
              AND isDeleted = false
              AND canBulkChangePendingMROD__c = true
        ];
        for (Asset a : updateAssets) {
            a.PT_Pending__c = newInstallLocMap.get(a.PT_Install_Location__c).Pending_MROD__c;
            a.PT_Airbus_D1_Date__c = newInstallLocMap.get(a.PT_Install_Location__c).Pending_D1_Date__c;
        }
        update updateAssets;
        System.debug('======= PT_InstallLocTriggerFunctions::updatePendingMRODs() updated ' + updateAssets.size() + ' records');
    }

    /*
    * @author           Lipton Abillar
    * @date             09/21/2021
    * @workitem         W-003567
    * @description      If Seat Count, Model, or Vendor is changed, set approval status to pending
    * @trigger          PT_InstallLocationTriggerHandler.beforeUpdate()
    * Developer:        Lipton Abillar      09/21/2021      Create
    */
    public static void setPendingStatus(List<PT_Install_Location__c> newInstallLocList, Map<Id, PT_Install_Location__c> oldInstallLocMap) {
        for (PT_Install_Location__c il : newInstallLocList) {
            if (
                il.PT_Seat_Count__c != oldInstallLocMap.get(il.Id).PT_Seat_Count__c ||
                il.PT_Seat_Model__c != oldInstallLocMap.get(il.Id).PT_Seat_Model__c ||
                il.PT_Seat_Vendor__c != oldInstallLocMap.get(il.Id).PT_Seat_Vendor__c
            ) {
                il.PT_Approval_Status__c = 'Pending';
            }
        }
    }
}