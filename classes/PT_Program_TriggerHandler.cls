/**
 *      @author       Sarah Kennedy
 *      @date         04/27/2020
 *      @description  Trigger Handler for PT_ProgramTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy               04/27/2020          Initial scaffold
 *      Sarah Kennedy               09/29/2020          Added methods to add, delete from PM Queue
 */


public with sharing class PT_Program_TriggerHandler extends L2I_TriggerHandler {

    /** 
    * @Workitem W-004168    
    * @description  
    * Prevent recursion on Update DMLs  
    * @author Alvin Claridad | 12/16/2021   
    **/ 
    private static Boolean isRecursive = false;

    private Map<Id, PT_Program__c> newProgramMap;
    private List<PT_Program__c> newProgramList;

    private Map<Id, PT_Program__c> oldProgramMap;
    private List<PT_Program__c> oldProgramList;

    public PT_Program_TriggerHandler() {
        this.newProgramMap = (Map<Id, PT_Program__c>) Trigger.newMap;
        this.newProgramList = (List<PT_Program__c>) Trigger.new;

        this.oldProgramMap = (Map<Id, PT_Program__c>) Trigger.oldMap;
        this.oldProgramList = (List<PT_Program__c>) Trigger.old;
    }

    public override void afterInsert() {
    // valid trigger context vars:
    //     newProgramList  (not modifiable)
    //     newProgramMap
        //PT_Program_TriggerFunctions.updateProgramName(newProgramList);
        PT_Program_TriggerFunctions.updateProgramOnOpportunity(newProgramList);
        PT_Program_TriggerFunctions.callUdpateProgramAircrafts(newProgramList);
        PT_Program_TriggerFunctions.addProgramMgrToPMQueue(newProgramList);
    }

    public override void beforeInsert() {
    // valid trigger context vars:
    //     newProgramList  (modifiable)
        PT_Program_TriggerFunctions.addUpdateProgramName(newProgramList);
        PT_Program_TriggerFunctions.getNewPMOUser(newProgramList);
    }

    public override void beforeUpdate() {
        // valid trigger context vars:
        //     newProgramList  (modifiable)
        //     newProgramMap
        //     oldProgramList
        //     oldProgramMap
        if (Test.isRunningTest() || !isRecursive) { // Added by Alvin for W-004168
        PT_Program_TriggerFunctions.addUpdateProgramName(newProgramList);
        PT_Program_TriggerFunctions.inactiveProgramValidation(newProgramList, oldProgramMap);
        PT_Program_TriggerFunctions.getChangedPMOUser(newProgramList, oldProgramMap);
        PT_Program_TriggerFunctions.preventSubmitterFromApproving(newProgramList, oldProgramMap);
        //Work Item W-003555 Ryan (Simplus)
        PT_Program_TriggerFunctions.updateFirstDeliveryDate(newProgramList);
        PT_Program_TriggerFunctions.sendApprovalEmail(newProgramList);
        }
    }

    public override void afterUpdate() {
    // valid trigger context vars:
    //     newProgramList  (not modifiable)
    //     newProgramMap
    //     oldProgramList
    //     oldProgramMap
    System.debug('======= executing Program_TriggerHander::afterUpdate()');
    if (Test.isRunningTest() || !isRecursive) { // Added by Alvin for W-004168
        PT_Program_TriggerFunctions.changeProgramMgrForPMQueue(newProgramList, oldProgramMap);
        PT_Program_TriggerFunctions.updateAssetsInstLocsOnProgramMRODApproved(newProgramList, oldProgramMap);
        PT_Program_TriggerFunctions.removeMRODRevisionRecordsOnRejectedRecalled(newProgramList, oldProgramMap);
        PT_Program_TriggerFunctions.updateOpportunity(newProgramList, oldProgramMap); // Added by Lipton for W-003988
   }   
        isRecursive = true; // Added by Alvin for W-004168 
    }


    // public override void beforeDelete() {
    // valid trigger context vars:
    //     oldProgramList
    //     oldProgramMap
    //System.debug('======= executing Program_TriggerHander::beforeDelete()');
    //}


    public override void afterDelete() {
    // valid trigger context vars:
    //     oldProgramList
    //     oldProgramMap
    System.debug('======= executing Program_TriggerHander::afterDelete()');
        PT_Program_TriggerFunctions.deleteProgramMgrFromPMQueue(oldProgramList);
    }

    //public override void afterUndelete() {
    // valid trigger context vars:
    //     newProgramList  (not modifiable)
    //     newProgramMap
    //System.debug('====== executing L2I_Program_TriggerHander::afterUndelete()');
    //}

}