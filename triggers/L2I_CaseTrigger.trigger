/**
*      @author       Andy Fang
*      @date         03/17/2020
*      @description  Trigger on the Case object
*
*      Modification Log:
*      ------------------------------------------------------------------------------------
*      Developer                       Date                Description
*      ------------------------------------------------------------------------------------
*      Andy Fang                     07/12/2019         Initial scaffold
*/

trigger L2I_CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete) {
    // Check if the trigger has to be run by checking if the User(Profile) has the Disable_Case__c
    // flag turned on in the L2I_Trigger_Settings__c custom setting.

    if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_Case__c) {
        System.debug('***** Bypassed execution of Case trigger functions for user ' + UserInfo.getUserName());
        return;
    }

    // now handle it
    new L2I_Case_TriggerHandler().run();

}