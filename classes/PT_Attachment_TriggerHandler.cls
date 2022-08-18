/**
 *      @author       Sarah Kennedy
 *      @date         09/10/2020
 *      @description  Trigger Handler for PT_AttachmentTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy               09/10/2020          Initial scaffold
 */


public with sharing class PT_Attachment_TriggerHandler extends L2I_TriggerHandler {
    
    private Map<Id, Attachment> newAttachmentMap;
    private List<Attachment> newAttachmentList;
    
    private Map<Id, Attachment> oldAttachmentMap;
    private List<Attachment> oldAttachmentList;
    
    public PT_Attachment_TriggerHandler() {
        this.newAttachmentMap = (Map<Id, Attachment>) Trigger.newMap;
        this.newAttachmentList = (List<Attachment>) Trigger.new;
        
        this.oldAttachmentMap = (Map<Id, Attachment>) Trigger.oldMap;
        this.oldAttachmentList = (List<Attachment>) Trigger.old;
    }
    
    public override void afterInsert() {
// valid trigger context vars:
//     newAttachmentList  (not modifiable)
//     newAttachmentMap
        System.debug('======= executing PT_Attachment_TriggerHander::afterInsert()');
        PT_Attachment_TriggerFunctions.createFileFromAttachment(newAttachmentList);
    }
    
//    public override void beforeInsert() {
// valid trigger context vars:
//     newAttachmentList  (modifiable)
//    }

//    public override void beforeUpdate() {
// valid trigger context vars:
//     newAttachmentList  (modifiable)
//     newAttachmentMap
//     oldAttachmentList
//     oldAttachmentMap
//    }

//public override void afterUpdate() {
// valid trigger context vars:
//     newAttachmentList  (not modifiable)
//     newAttachmentMap
//     oldAttachmentList
//     oldAttachmentMap
//System.debug('======= executing PT_Attachment_TriggerHander::afterUpdate()');
//}


// public override void beforeDelete() {
// valid trigger context vars:
//     oldAttachmentList
//     oldAttachmentMap
//System.debug('======= executing PT_Attachment_TriggerHander::beforeDelete()');
//}


//public override void afterDelete() {
// valid trigger context vars:
//     oldAttachmentList
//     oldAttachmentMap
//System.debug('======= executing PT_Attachment_TriggerHander::afterDelete()');
//}

//public override void afterUndelete() {
// valid trigger context vars:
//     newAttachmentList  (not modifiable)
//     newAttachmentMap
//System.debug('====== executing PT_Attachment_TriggerHander::afterUndelete()');
//}

}