/**
 *      @author       Andy Fang
 *      @date         03/17/2020
 *      @description  L2I Case Trigger Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                     03/17/2020         Initial scaffold
 *      Sarah Kennedy                 04/10/2020         US1762 added checkService Action method
 *
 */
public without sharing class L2I_Case_TriggerHandler extends L2I_TriggerHandler {

    private Map<Id, Case> newCaseMap;
    private List<Case> newCaseList;

    private Map<Id, Case> oldCaseMap;
    private List<Case> oldCaseList;

    public L2I_Case_TriggerHandler() {
        this.newCaseMap = (Map<Id, Case>) Trigger.newMap;
        this.newCaseList = (List<Case>) Trigger.new;

        this.oldCaseMap = (Map<Id, Case>) Trigger.oldMap;
        this.oldCaseList = (List<Case>) Trigger.old;
    }

    public override void afterInsert() {
        // valid trigger context vars:
        //     newCaseList  (not modifiable)
        //     newCaseMap
        System.debug('====== executing L2I_Case_TriggerHander::afterInsert()');
        //L2I_Case_TriggerFunctions.sendCaseEvent(newCaseList);
        L2I_Case_TriggerFunctions.processCaseManagment(newCaseList);


    }


    public override void afterUpdate(){

        System.debug('====== executing L2I_Case_TriggerHander::afterUpdate()');
        L2I_Case_TriggerFunctions.processAircraftActions(newCaseList, oldCaseMap);
        L2I_Case_TriggerFunctions.allowToReprocess(newCaseList, oldCaseMap);
        L2I_Case_TriggerFunctions.checkServiceActivation(newCaseList, newCaseMap, oldCaseMap);
        
    }
}