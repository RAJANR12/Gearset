/**
 *      @author       Nitin Gupta
 *      @date         01/12/2021
 *      @description  Trigger on the PT_Note__c object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Nitin Gupta                   01/12/2021          Initial scaffold
 */


trigger PT_NotesTrigger on PT_Note__c (before insert, before update, before delete, after insert, after update, after delete) {
        new PT_NotesTriggerHandler().run();
    }