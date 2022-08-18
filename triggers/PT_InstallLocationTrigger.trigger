/**
 *      @author       Sarah Kennedy
 *      @date         09/27/2020
 *      @description  Trigger on the PT_InstallLocation object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                09/27/2020          Initial scaffold
 */


trigger PT_InstallLocationTrigger on PT_Install_Location__c (before insert, before update, after insert, after update) {
// Check if the trigger has to be run by checking if the User(Profile) has the Disable_InstallLoc__c
// flag turned on in the L2I_Trigger_Settings__c custom setting.

if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_InstallLoc__c) {
System.debug('***** Bypassed execution of Asset trigger functions for user ' + UserInfo.getUserName());
return;
}

// now handle it
new PT_InstallLocationTriggerHandler().run();
}