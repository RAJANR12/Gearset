/**
 *      @author       Sarah Kennedy
 *      @date         09/27/2020
 *      @description  Trigger Handler for PT_PMO_GroupsTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy               09/27/2020          Initial scaffold
 */


public with sharing class PT_PMO_GroupsTriggerHandler extends L2I_TriggerHandler {
    
    private Map<Id, PT_PMO_Groups__c> newPMO_GroupsMap;
    private List<PT_PMO_Groups__c> newPMO_GroupsList;
    
    private Map<Id, PT_PMO_Groups__c> oldPMO_GroupsMap;
    private List<PT_PMO_Groups__c> oldPMO_GroupsList;
    
    public PT_PMO_GroupsTriggerHandler() {
        this.newPMO_GroupsMap = (Map<Id, PT_PMO_Groups__c>) Trigger.newMap;
        this.newPMO_GroupsList = (List<PT_PMO_Groups__c>) Trigger.new;
        
        this.oldPMO_GroupsMap = (Map<Id, PT_PMO_Groups__c>) Trigger.oldMap;
        this.oldPMO_GroupsList = (List<PT_PMO_Groups__c>) Trigger.old;
    }
    
    public override void afterInsert() {
// valid trigger context vars:
//     newPMO_GroupsList  (not modifiable)
//     newPMO_GroupsMap
        System.debug('======= executing PMO_Groups_TriggerHander::afterInsert()');
        PT_PMO_GroupsTriggerFunctions.addPPMRDToPPMRDQueues(newPMO_GroupsList);
    }

//public override void beforeInsert() {
// valid trigger context vars:
//     newPMO_GroupsList  (modifiable)
//}

//public override void beforeUpdate() {
// valid trigger context vars:
//     newPMO_GroupsList  (modifiable)
//     newPMO_GroupsMap
//     oldPMO_GroupsList
//     oldPMO_GroupsMap
//}
    
    public override void afterUpdate() {
// valid trigger context vars:
//     newPMO_GroupsList  (not modifiable)
//     newPMO_GroupsMap
//     oldPMO_GroupsList
//     oldPMO_GroupsMap
        System.debug('======= executing PMO_Groups_TriggerHander::afterUpdate()');
        PT_PMO_GroupsTriggerFunctions.changePPMRDFromPPMRDQueue(newPMO_GroupsList, oldPMO_GroupsMap);
        PT_PMO_GroupsTriggerFunctions.changePMOOwnerChanged(newPMO_GroupsList, oldPMO_GroupsMap);
    }


// public override void beforeDelete() {
// valid trigger context vars:
//     oldPMO_GroupsList
//     oldPMO_GroupsMap
//System.debug('======= executing PMO_Groups_TriggerHander::beforeDelete()');
//}
    
    
    public override void afterDelete() {
// valid trigger context vars:
//     oldPMO_GroupsList
//     oldPMO_GroupsMap
        System.debug('======= executing PMO_Groups_TriggerHander::afterDelete()');
        PT_PMO_GroupsTriggerFunctions.deletePPMRDFromPPMRDQueue(oldPMO_GroupsList);
    }

//public override void afterUndelete() {
// valid trigger context vars:
//     newPMO_GroupsList  (not modifiable)
//     newPMO_GroupsMap
//System.debug('====== executing L2I_PMO_Groups_TriggerHander::afterUndelete()');
//}

}