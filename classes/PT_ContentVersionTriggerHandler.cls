/**
 *      @author       Sarah Kennedy
 *      @date         09/27/2020
 *      @description  Trigger Handler for PT_ContentVersionTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy               09/27/2020          Initial scaffold
 */


public with sharing class PT_ContentVersionTriggerHandler extends L2I_TriggerHandler {
    
    private Map<Id, ContentVersion> newContentVersionMap;
    private List<ContentVersion> newContentVersionList;
    
    private Map<Id, ContentVersion> oldContentVersionMap;
    private List<ContentVersion> oldContentVersionList;
    
    public PT_ContentVersionTriggerHandler() {
        this.newContentVersionMap = (Map<Id, ContentVersion>) Trigger.newMap;
        this.newContentVersionList = (List<ContentVersion>) Trigger.new;
        
        this.oldContentVersionMap = (Map<Id, ContentVersion>) Trigger.oldMap;
        this.oldContentVersionList = (List<ContentVersion>) Trigger.old;
    }
    
//    public override void afterInsert() {
// valid trigger context vars:
//     newContentVersionList  (not modifiable)
//     newContentVersionMap
//        System.debug('======= executing ContentVersion_TriggerHander::afterInsert()');
//    }

//public override void beforeInsert() {
// valid trigger context vars:
//     newContentVersionList  (modifiable)
//}

//public override void beforeUpdate() {
// valid trigger context vars:
//     newContentVersionList  (modifiable)
//     newContentVersionMap
//     oldContentVersionList
//     oldContentVersionMap
//}
    
    public override void afterUpdate() {
// valid trigger context vars:
//     newContentVersionList  (not modifiable)
//     newContentVersionMap
//     oldContentVersionList
//     oldContentVersionMap
        System.debug('======= executing ContentVersion_TriggerHander::afterUpdate()');
        PT_ContentVersionTriggerFunctions.contentVersionToQuote(newContentVersionList,
              oldContentVersionMap);
    }

// public override void beforeDelete() {
// valid trigger context vars:
//     oldContentVersionList
//     oldContentVersionMap
//System.debug('======= executing ContentVersion_TriggerHander::beforeDelete()');
//}


//public override void afterDelete() {
// valid trigger context vars:
//     oldContentVersionList
//     oldContentVersionMap
//System.debug('======= executing ContentVersion_TriggerHander::afterDelete()');
//}

//public override void afterUndelete() {
// valid trigger context vars:
//     newContentVersionList  (not modifiable)
//     newContentVersionMap
//System.debug('====== executing L2I_ContentVersion_TriggerHander::afterUndelete()');
//}

}