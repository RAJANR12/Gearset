/**
 *      @author       Sarah Kennedy
 *      @date         09/27/2020
 *      @description  Trigger Handler for PT_InstallLocationTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy               09/27/2020          Initial scaffold
 */


public with sharing class PT_InstallLocationTriggerHandler extends L2I_TriggerHandler {

    private Map<Id, PT_Install_Location__c> newInstallLocMap;
    private List<PT_Install_Location__c> newInstallLocList;

    private Map<Id, PT_Install_Location__c> oldInstallLocMap;
    private List<PT_Install_Location__c> oldInstallLocList;

    public PT_InstallLocationTriggerHandler() {
        this.newInstallLocMap = (Map<Id, PT_Install_Location__c>) Trigger.newMap;
        this.newInstallLocList = (List<PT_Install_Location__c>) Trigger.new;

        this.oldInstallLocMap = (Map<Id, PT_Install_Location__c>) Trigger.oldMap;
        this.oldInstallLocList = (List<PT_Install_Location__c>) Trigger.old;
    }

public override void afterInsert() {
// valid trigger context vars:
//     newInstallLocList  (not modifiable)
//     newInstallLocMap
    System.debug('======= executing InstallLoc_TriggerHander::afterInsert()');
    PT_InstallLocTriggerFunctions.updatePendingMRODs(newInstallLocMap);
}

public override void beforeInsert() {
//valid trigger context vars:
//     newInstallLocList  (modifiable)
    System.debug('======= executing InstallLoc_TriggerHander::beforeInsert()');
    PT_InstallLocTriggerFunctions.setInstallLocsName(newInstallLocList);
}

public override void beforeUpdate() {
// valid trigger context vars:
//     newInstallLocList  (modifiable)
//     newInstallLocMap
//     oldInstallLocList
//     oldInstallLocMap
    System.debug('======= executing InstallLoc_TriggerHander::beforeUpdate()');
    PT_InstallLocTriggerFunctions.updateInstallLocsName(newInstallLocList, oldInstallLocMap);
    PT_InstallLocTriggerFunctions.setPendingStatus(newInstallLocList, oldInstallLocMap); // Added by Lipton for W-003567
}

public override void afterUpdate() {
// valid trigger context vars:
//     newInstallLocList  (not modifiable)
//     newInstallLocMap
//     oldInstallLocList
//     oldInstallLocMap
    System.debug('======= executing InstallLoc_TriggerHander::afterUpdate()');
    PT_InstallLocTriggerFunctions.updatePendingMRODs(newInstallLocMap);
}


//public override void beforeDelete() {
// valid trigger context vars:
//     oldInstallLocList
//     oldInstallLocMap
//System.debug('======= executing InstallLoc_TriggerHander::beforeDelete()');
//}

//    public override void afterDelete() {
// valid trigger context vars:
//     oldInstallLocList
//     oldInstallLocMap
//        System.debug('======= executing InstallLoc_TriggerHander::afterDelete()');
//    }

//public override void afterUndelete() {
// valid trigger context vars:
//     newInstallLocList  (not modifiable)
//     newInstallLocMap
//System.debug('====== executing L2I_InstallLoc_TriggerHander::afterUndelete()');
//}

}