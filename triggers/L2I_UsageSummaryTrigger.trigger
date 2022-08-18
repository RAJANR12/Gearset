/**
 *      @author       Andy Fang
 *      @date         09/24/2019
 *      @description  Trigger on the Usage Summary object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                     09/24/2019         Initial scaffold
 */

trigger L2I_UsageSummaryTrigger on blng__UsageSummary__c (before insert) {


    // Check if the trigger has to be run by checking if the User(Profile) has the Disable_UsageSummary__c
    // flag turned on in the L2I_Trigger_Settings__c custom setting.

    /* Skipping the flag, since usage summary is a must have functionality
    if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_UsageSummary__c) {
        System.debug('***** Bypassed execution of Usage Summary trigger functions for user ' + UserInfo.getUserName());
        return;
    }
    */

    // now handle it
    new L2I_UsageSummary_TriggerHandler().run();

}