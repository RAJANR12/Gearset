/**
 *      @author       Nitin Gupta
 *      @date         01/12/2021
 *      @description  Trigger Handler for PT_NotesTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Nitin Gupta                   01/12/2021          Initial scaffold
 */


public class PT_NotesTriggerHandler extends L2I_TriggerHandler {

    private Map<Id, PT_Note__c> newNoteMap;
    private List<PT_Note__c> newNoteList;

    private Map<Id, PT_Note__c> oldNoteMap;
    private List<PT_Note__c> oldNoteList;

    public PT_NotesTriggerHandler() {
        this.newNoteMap = (Map<Id, PT_Note__c>) Trigger.newMap;
        this.newNoteList = (List<PT_Note__c>) Trigger.new;

        this.oldNoteMap = (Map<Id, PT_Note__c>) Trigger.oldMap;
        this.oldNoteList = (List<PT_Note__c>) Trigger.old;
    }

    public override void afterInsert() {

    }

    public override void beforeInsert() {
        System.debug('====== executing PT_NotesTriggerHandler::beforeInsert()');
        PT_Notes_TriggerFunctions.updateName(newNoteList);
        System.debug('====== exiting PT_NotesTriggerHandler::beforeInsert()');
        PT_Notes_TriggerFunctions.setStatusPending(newNoteList, null, true); // Added by Lipton for W-003567
    }

    public override void beforeUpdate() {
        System.debug('====== executing PT_NotesTriggerHandler::beforeUpdate()');
        PT_Notes_TriggerFunctions.retainName(newNoteList);
        System.debug('====== exiting PT_NotesTriggerHandler::beforeUpdate()');
        PT_Notes_TriggerFunctions.setStatusPending(newNoteList, oldNoteMap, false);  // Added by Lipton for W-003567
        PT_Notes_TriggerFunctions.setStatusApproved(newNoteList, oldNoteMap);  // Added by Lipton for W-003567
    }
    
    public override void beforeDelete() {
        System.debug('====== executing PT_NotesTriggerHandler::beforeDelete()');
        PT_Notes_TriggerFunctions.preventDelete(oldNoteList);
        System.debug('====== exiting PT_NotesTriggerHandler::beforeDelete()');
    }

    public override void afterUpdate() {
        System.debug('====== executing PT_NotesTriggerHandler::afterUpdate()');
        PT_Notes_TriggerFunctions.deleteAssetNotes(newNoteList, oldNoteMap);
        System.debug('====== exiting PT_NotesTriggerHandler::afterUpdate()');
    }

//    public override void afterDelete() {
//
//    }
}