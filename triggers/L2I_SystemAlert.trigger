/**
 *      @author       Raj Rajen
 *      @date         08/07/2019
 *      @description  Trigger on the System Alert object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/07/2019         Initial scaffold
 *
 */
trigger L2I_SystemAlert on L2I_System_Alert__c (before insert, before update,
                                                after insert,  after update) {

    // Check if the trigger has to be run by checking if the User(Profile) has the Disable_Account__c
    // flag turned on in the L2I_Trigger_Settings__c custom setting.

    //if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_Account__c) {
    //    System.debug('***** Bypassed execution of Account trigger functions for user ' + UserInfo.getUserName());
    //    return;
    //}

    new L2I_SystemAlert_TriggerHandler().run();
}