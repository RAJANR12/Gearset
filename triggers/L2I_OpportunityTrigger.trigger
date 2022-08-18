/**
 *      @author       Raj Rajen
 *      @date         07/12/2019
 *      @description  Trigger on the Opportunity object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/12/2019         Initial scaffold
 *                                    07/15/2019         added after delete
 *      Sarah Kennedy                 12/12/2019         added before update
 *      Sarah Kennedy                 01/28/2020         added before insert
 */
trigger L2I_OpportunityTrigger on Opportunity (before insert, before update, after insert, after update, after delete, after undelete) {

    // Check if the trigger has to be run by checking if the User(Profile) has the Disable_Opportunity__c
    // flag turned on in the L2I_Trigger_Settings__c custom setting.

    if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_Opportunity__c) {
        System.debug('***** Bypassed execution of Opportunity trigger functions for user ' + UserInfo.getUserName());
        return;
    }

    // now handle it
    
    //if (!PT_ValidateUserPMOUser.validatePMOUser()[0]) {
        new L2I_Opportunity_TriggerHandler().run();
    //} else {
        new PT_Opportunity_TriggerHandler().run();
   // }
}