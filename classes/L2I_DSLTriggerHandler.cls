/**
 *      @author       Sarah Kennedy
 *      @date         02/27/2020
 *      @description  L2I DSL Trigger Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                  02/27/2020       Initial scaffold
 *      Sarah Kennedy                  US2010, US2002, US1977 - Add/delete processing moved into the LWC to be able to control by Opp Id
 *
 */
public without sharing class L2I_DSLTriggerHandler extends L2I_TriggerHandler {

    private Map<Id, L2I_DSL__c> newDSLMap;
    private List<L2I_DSL__c> newDSLList;

    private Map<Id, L2I_DSL__c> oldDSLMap;
    private List<L2I_DSL__c> oldDSLList;

    public L2I_DSLTriggerHandler() {
        this.newDSLMap = (Map<Id, L2I_DSL__c>) Trigger.newMap;
        this.newDSLList = (List<L2I_DSL__c>) Trigger.new;

        this.oldDSLMap = (Map<Id, L2I_DSL__c>) Trigger.oldMap;
        this.oldDSLList = (List<L2I_DSL__c>) Trigger.old;
    }

    public override void beforeUpdate() {
// valid trigger context vars:
//     newDSLList  (modifiable)
//     newDSLMap
//     oldDSLList
//     oldDSLMap
        System.debug('====== executing L2I_DSL_TriggerHander::beforeUpdate()');
        L2I_DSLTriggerFunctions.updateDSLName(newDSLList);
        L2I_DSLTriggerFunctions.disallowDSLConfirmationForAmendment(newDSLList, newDSLMap, oldDSLMap);
        //L2I_DSLTriggerFunctions.restrictAircraftRetrofitProgram(newDSLList, oldDSLMap);
        L2I_DSLTriggerFunctions.setTailUniquenessOnDSL(newDSLList, oldDSLMap);
        L2I_DSLTriggerFunctions.updateDeliveryDateforrollup(newDSLList, oldDSLMap, true);
    }

    public override void afterInsert() {
// valid trigger context vars:
//     newDSLList  (not modifiable)
//     newDSLMap
        /*
        System.debug('====== executing L2I_DSL_TriggerHander::afterInsert()');
        L2I_DSLTriggerFunctions.setTailUniquenessOnDSL(newDSLList, oldDSLMap);
        L2I_DSLTriggerFunctions.updateDeliveryDateforrollup(newDSLList, oldDSLMap, false);
        //
        L2I_DSLTriggerFunctions.checkProgramFirstDeliveryDate(newDSLList); //added by Ryan for W-003555
        L2I_DSLTriggerFunctions.rollupHardwareProgramNumbers(newDSLList, null);//added by Lipton for W-004055
		*/
    }

    public override void beforeInsert() {
// valid trigger context vars:
//     newDSLList  (modifiable)
        System.debug('====== executing L2I_DSL_TriggerHander::beforeInsert()');
        L2I_DSLTriggerFunctions.updateDSLName(newDSLList);
        L2I_DSLTriggerFunctions.ifecDSLsAdded(newDSLList);
        L2I_DSLTriggerFunctions.updateDeliveryDateforrollup(newDSLList, oldDSLMap, true);

    }

    public override void afterUpdate() {
// valid trigger context vars:
//     newDSLList  (not modifiable)
//     newDSLMap
//     oldDSLList
//     oldDSLMap
        System.debug('======= executing L2I_DSL_TriggerHander::afterUpdate()');
        L2I_DSLTriggerFunctions.createCasesFromDSLs(newDSLList, newDSLMap, oldDSLMap);
        L2I_DSLTriggerFunctions.updateDeliveryDateforrollup(newDSLList, oldDSLMap, false);
        L2I_DSLTriggerFunctions.recalculatePrimaryQuotes(newDSLList, oldDSLMap); // Added by Lipton for W-003512
        L2I_DSLTriggerFunctions.populateACService(newDSLList,oldDSLMap); // Added by Alvin for W-003950
        L2I_DSLTriggerFunctions.checkProgramFirstDeliveryDate(newDSLMap,oldDSLMap);//added by Ryan for W-003555
        L2I_DSLTriggerFunctions.rollupHardwareProgramNumbers(newDSLList, oldDSLMap);//added by Lipton for W-004055
       
    }

    public override void beforeDelete() {
// valid trigger context vars:
//     oldDSLList
//     oldDSLMap
        System.debug('======= executing L2I_DSL_TriggerHander::beforeDelete()');
        L2I_DSLTriggerFunctions.ifecDSLsDeleted(oldDSLList);
    }
    public override void afterDelete(){
        L2I_DSLTriggerFunctions.checkProgramFirstDeliveryDate(null,oldDSLMap);//added by Ryan for W-003555
    }

//    public override void afterDelete() {
// valid trigger context vars:
//     oldDSLList
//     oldDSLMap
//        System.debug('======= executing L2I_DSL_TriggerHander::afterDelete()');
//    }

//    public override void afterUndelete() {
// valid trigger context vars:
//     newDSLList  (not modifiable)
//     newDSLMap
//        System.debug('====== executing L2I_DSL_TriggerHander::afterUndelete()');
//    }

}