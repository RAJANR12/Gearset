/**
 *      @author       Raj Rajen
 *      @date         08/26/2019
 *      @description  L2I DSH Trigger Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/26/2019         Initial scaffold
 *      Sarah Kennedy                 02/23/2020         US1376 - removing updateDSLserviceMonths method
 *      Sarah Kennedy                 03/02/2020         Added validateDelete method
 *
 */
public without sharing class L2I_DSH_TriggerHandler extends L2I_TriggerHandler {

    private Map<Id, L2I_DSH__c> newDSHMap;
    private List<L2I_DSH__c> newDSHList;

    private Map<Id, L2I_DSH__c> oldDSHMap;
    private List<L2I_DSH__c> oldDSHList;

    public L2I_DSH_TriggerHandler() {
        this.newDSHMap = (Map<Id, L2I_DSH__c>) Trigger.newMap;
        this.newDSHList = (List<L2I_DSH__c>) Trigger.new;

        this.oldDSHMap = (Map<Id, L2I_DSH__c>) Trigger.oldMap;
        this.oldDSHList = (List<L2I_DSH__c>) Trigger.old;
    }

//    public override void beforeUpdate() {
        // valid trigger context vars:
        //     newDSHList  (modifiable)
        //     newDSHMap
        //     oldDSHList
        //     oldDSHMap
//        System.debug('====== executing L2I_DSH_TriggerHander::beforeUpdate()');
//    }

//    public override void afterInsert() {
        // valid trigger context vars:
        //     newDSHList  (not modifiable)
        //     newDSHMap
//        System.debug('====== executing L2I_DSH_TriggerHander::afterInsert()');
//    }

//    public override void beforeInsert() {
        // valid trigger context vars:
        //     newDSHList  (modifiable)
//    }

//    public override void afterUpdate() {
        // valid trigger context vars:
        //     newDSHList  (not modifiable)
        //     newDSHMap
        //     oldDSHList
        //     oldDSHMap
//        System.debug('======= executing L2I_DSH_TriggerHander::afterUpdate()');
//        L2I_DSH_TriggerFunctions.updateDSLserviceMonths(newDSHList, newDSHMap, oldDSHMap);
//    }

    public override void beforeDelete() {
        // valid trigger context vars:
        //     oldDSHList
        //     oldDSHMap
        System.debug('======= executing L2I_DSH_TriggerHander::beforeDelete()');
        L2I_DSH_TriggerFunctions.validateDelete(oldDSHMap);
    }

//    public override void afterDelete() {
        // valid trigger context vars:
        //     oldDSHList
        //     oldDSHMap
//        System.debug('======= executing L2I_DSH_TriggerHander::afterDelete()');
//    }

//    public override void afterUndelete() {
        // valid trigger context vars:
        //     newDSHList  (not modifiable)
        //     newDSHMap
//        System.debug('====== executing L2I_DSH_TriggerHander::afterUndelete()');
//    }

}