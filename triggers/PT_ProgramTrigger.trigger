/**
 *      @author       Sarah Kennedy
 *      @date         04/27/2020
 *      @description  Trigger on the PT_Program__c object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sreekanth Basireddy              04/27/2020          Initial scaffold
 *      Sarah Kennedy                    09/27/2020          added after update, after delete
 */


trigger PT_ProgramTrigger on PT_Program__c (before insert, before update, after insert, after update, after delete) {
// Check if the trigger has to be run by checking if the User(Profile) has the Disable_Program__c
// flag turned on in the L2I_Trigger_Settings__c custom setting.

    if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_Program__c) {
        System.debug('***** Bypassed execution of PT_Program__c trigger functions for user ' + UserInfo.getUserName());
        return;
    }

// now handle it
    new PT_Program_TriggerHandler().run();
}