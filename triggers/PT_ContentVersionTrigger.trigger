/**
 *      @author       Sarah Kennedy
 *      @date         09/27/2020
 *      @description  Trigger on the ContentVersion object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                    09/27/2020          Initial scaffold
 */


trigger PT_ContentVersionTrigger on ContentVersion (after update) {
// Check if the trigger has to be run by checking if the User(Profile) has the Disable_ContentVersion__c
// flag turned on in the L2I_Trigger_Settings__c custom setting.

if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_ContentVersion__c) {
System.debug('***** Bypassed execution of ContentVersion trigger functions for user ' + UserInfo.getUserName());
return;
}

// now handle it
new PT_ContentVersionTriggerHandler().run();
}