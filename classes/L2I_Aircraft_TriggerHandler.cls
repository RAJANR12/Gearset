/**
 *      @author       Raj Rajen
 *      @date         07/12/2019
 *      @description  L2I Aircraft Trigger Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/01/2019         Initial scaffold
 *
 */
public without sharing class L2I_Aircraft_TriggerHandler extends L2I_TriggerHandler {

    private Map<Id, L2I_Aircraft__c> newAircraftMap;
    private List<L2I_Aircraft__c> newAircraftList;

    private Map<Id, L2I_Aircraft__c> oldAircraftMap;
    private List<L2I_Aircraft__c> oldAircraftList;

    public L2I_Aircraft_TriggerHandler() {
        this.newAircraftMap = (Map<Id, L2I_Aircraft__c>) Trigger.newMap;
        this.newAircraftList = (List<L2I_Aircraft__c>) Trigger.new;

        this.oldAircraftMap = (Map<Id, L2I_Aircraft__c>) Trigger.oldMap;
        this.oldAircraftList = (List<L2I_Aircraft__c>) Trigger.old;
    }


    public override void beforeDelete() {
        // valid trigger context vars:
        //     oldAircraftList
        //     oldAircraftMap
        System.debug('======= executing Aircraft_TriggerHander::beforeDelete()');
        L2I_Aircraft_TriggerFunctions.checkBeforeDelete(oldAircraftList, oldAircraftMap);
    }

}