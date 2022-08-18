/**
 *      @author       Sarah Kennedy
 *      @date         09/27/2020
 *      @description  Trigger on the PT_PMO_Groups__c object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                09/27/2020          Initial scaffold
 */


trigger PT_PMO_GroupsTrigger on PT_PMO_Groups__c (after insert, after update, after delete) {
// Check if the trigger has to be run by checking if the User(Profile) has the Disable_PMO_Groups__c
// flag turned on in the L2I_Trigger_Settings__c custom setting.
    
    if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_PMO_Groups__c) {
        System.debug('***** Bypassed execution of PT_PMO_Groups__c trigger functions for user ' + UserInfo.getUserName());
        return;
    }

// now handle it
    new PT_PMO_GroupsTriggerHandler().run();
}