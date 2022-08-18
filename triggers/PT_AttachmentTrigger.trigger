/**
 *  @author       Sarah Kennedy
 *  @date         09/10/2020
 *  @description  Trigger on Attachment Object
 *
 *  Modification Log:
 *  ------------------------------------------------------------------------------------
 *  Developer                       Date                Description
 *  ------------------------------------------------------------------------------------
 *  Sarah Kennedy                     09/10/2020            Initial setup
 *
 */
trigger PT_AttachmentTrigger on Attachment (after insert) {

// Check if the trigger has to be run by checking if the User(Profile) has the Disable_Attachment__c
// flag turned on in the L2I_Trigger_Settings__c custom setting.
    if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_Attachment__c) {
        System.debug('***** Bypassed execution of Attachment trigger functions for user ' + UserInfo.getUserName());
        return;
    }

// now handle it.
    new PT_Attachment_TriggerHandler().run();
}