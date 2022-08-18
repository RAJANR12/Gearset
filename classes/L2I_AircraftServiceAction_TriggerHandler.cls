/**
 *      @author       Andy Fang 
 *      @date         03/31/2020
 *      @description  L2I AircraftService Trigger Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                     03/31/2020         Initial scaffold
 *
 */
public without sharing class L2I_AircraftServiceAction_TriggerHandler extends L2I_TriggerHandler {

    private Map<Id, L2I_ASA__c> newAircraftServiceActionMap;
    private List<L2I_ASA__c> newAircraftServiceActionList;

    private Map<Id, L2I_ASA__c> oldAircraftServiceActionMap;
    private List<L2I_ASA__c> oldAircraftServiceActionList;

    public L2I_AircraftServiceAction_TriggerHandler() {
        this.newAircraftServiceActionMap = (Map<Id, L2I_ASA__c>) Trigger.newMap;
        this.newAircraftServiceActionList = (List<L2I_ASA__c>) Trigger.new;

        this.oldAircraftServiceActionMap = (Map<Id, L2I_ASA__c>) Trigger.oldMap;
        this.oldAircraftServiceActionList = (List<L2I_ASA__c>) Trigger.old;
    }
    
    public override void afterUpdate() {

        System.debug('======= executing L2I_AircraftServiceAction_TriggerHander::afterUpdate()');
        L2I_ASAction_TriggerFunctions.updateCaseCompletion(newAircraftServiceActionList );

    }
        
}