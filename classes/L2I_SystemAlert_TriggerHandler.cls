/**
 *      @author       Raj Rajen
 *      @date         08/07/2019
 *      @description  L2I Account Trigger Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/07/2019         Initial scaffold
 *
 */
public without sharing class L2I_SystemAlert_TriggerHandler extends L2I_TriggerHandler {

    private Map<Id, L2I_System_Alert__c> newAlertMap;
    private List<L2I_System_Alert__c> newAlertList;

    private Map<Id, L2I_System_Alert__c> oldAlertMap;
    private List<L2I_System_Alert__c> oldAlertList;

    public L2I_SystemAlert_TriggerHandler() {
        this.newAlertMap = (Map<Id, L2I_System_Alert__c>) Trigger.newMap;
        this.newAlertList = (List<L2I_System_Alert__c>) Trigger.new;

        this.oldAlertMap = (Map<Id, L2I_System_Alert__c>) Trigger.oldMap;
        this.oldAlertList = (List<L2I_System_Alert__c>) Trigger.old;
    }

//    public override void beforeInsert() {
//        // valid trigger context vars:
//        //     newAlertList  (modifiable)
//        System.debug('======= executing Alert_TriggerHander::beforeInsert()');
//    }

    public override void afterInsert() {
        // valid trigger context vars:
        //     newAlertList  (not modifiable)
        //     newAlertMap
        System.debug('======= executing Alert_TriggerHander::afterInsert()');
        Set<Id> alertIds = new Set<Id>();
        for (L2I_System_Alert__c alert : newAlertList) {
            alertIds.add(alert.Id);
        }
        System.debug('======= Number of alerts to handle :' + alertIds.size());
        L2I_SystemAlertNotifier.sendEmailNotifications(alertIds);
    }

//    public override void beforeUpdate() {
//        // valid trigger context vars:
//        //     newAlertList  (modifiable)
//        //     newAlertMap
//        //     oldAlertList
//        //     oldAlertMap
//        //System.debug('======= executing Alert_TriggerHander::beforeUpdate()');
//    }

//    public override void afterUpdate() {
//        // valid trigger context vars:
//        //     newAlertList  (not modifiable)
//        //     newAlertMap
//        //     oldAlertList
//        //     oldAlertMap
//        //System.debug('======= executing Alert_TriggerHander::afterUpdate()');
//    }

//    public override void beforeDelete() {
//        // valid trigger context vars:
//        //     oldAlertList
//        //     oldAlertMap
//        //System.debug('======= executing Alert_TriggerHander::beforeDelete()');
//    }

//    public override void afterDelete() {
//        // valid trigger context vars:
//        //     oldAlertList
//        //     oldAlertMap
//        //System.debug('======= executing Alert_TriggerHander::afterDelete()');
//    }

}