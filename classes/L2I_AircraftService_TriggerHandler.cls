/**
 *      @author       Raj Rajen
 *      @date         08/14/2019
 *      @description  L2I AircraftService Trigger Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/14/2019         Initial scaffold
 *      Sarah Kennedy                 04/10/2020         US1762 removed checkService Action method call
 *
 */
public without sharing class L2I_AircraftService_TriggerHandler extends L2I_TriggerHandler {

    private Map<Id, L2I_Aircraft_Service__c> newAircraftServiceMap;
    private List<L2I_Aircraft_Service__c> newAircraftServiceList;

    private Map<Id, L2I_Aircraft_Service__c> oldAircraftServiceMap;
    private List<L2I_Aircraft_Service__c> oldAircraftServiceList;

    public L2I_AircraftService_TriggerHandler() {
        this.newAircraftServiceMap = (Map<Id, L2I_Aircraft_Service__c>) Trigger.newMap;
        this.newAircraftServiceList = (List<L2I_Aircraft_Service__c>) Trigger.new;

        this.oldAircraftServiceMap = (Map<Id, L2I_Aircraft_Service__c>) Trigger.oldMap;
        this.oldAircraftServiceList = (List<L2I_Aircraft_Service__c>) Trigger.old;
    }


    public override void beforeUpdate() {
        // valid trigger context vars:
        //     newAircraftServiceList  (modifiable)
        //     newAircraftServiceMap
        //     oldAircraftServiceList
        //     oldAircraftServiceMap
        System.debug('====== executing L2I_AircraftService_TriggerHander::beforeUpdate()');

        L2I_AircraftService_TriggerFunctions.InitializeFlags(newAircraftServiceList, newAircraftServiceMap, oldAircraftServiceMap);
    }

    /*public override void afterInsert() {
        // valid trigger context vars:
        //     newAircraftServiceList  (not modifiable)
        //     newAircraftServiceMap
        System.debug('====== executing L2I_AircraftService_TriggerHander::afterInsert()');


    } */

    /*public override void beforeInsert() {
        // valid trigger context vars:
        //     newAircraftServiceList  (modifiable)
        System.debug('====== executing L2I_AircraftService_TriggerHander::beforeInsert()');
        //L2I_AircraftService_TriggerFunctions.InitializeFlags(newAircraftServiceList, newAircraftServiceMap, oldAircraftServiceMap);
    }
    */

    /*public override void afterUpdate() {
        // valid trigger context vars:
        //     newAircraftServiceList  (not modifiable)
        //     newAircraftServiceMap
        //     oldAircraftServiceList
        //     oldAircraftServiceMap
        System.debug('======= executing L2I_AircraftService_TriggerHander::afterUpdate()');
//        L2I_AircraftService_TriggerFunctions.checkServiceActivation(newAircraftServiceList, newAircraftServiceMap, oldAircraftServiceMap);

        L2I_AircraftService_TriggerFunctions.adjustBillingUsage(newAircraftServiceList, newAircraftServiceMap, oldAircraftServiceMap);

    } */

    /**
    public override void beforeDelete() {
        // valid trigger context vars:
        //     oldAircraftServiceList
        //     oldAircraftServiceMap
        System.debug('======= executing L2I_AircraftService_TriggerHander::beforeDelete()');
    }

    public override void afterDelete() {
        // valid trigger context vars:
        //     oldAircraftServiceList
        //     oldAircraftServiceMap
        System.debug('======= executing L2I_AircraftService_TriggerHander::afterDelete()');
    }

    public override void afterUndelete() {
        // valid trigger context vars:
        //     newAircraftServiceList  (not modifiable)
        //     newAircraftServiceMap
        System.debug('====== executing L2I_AircraftService_TriggerHander::afterUndelete()');
    }
    **/

}