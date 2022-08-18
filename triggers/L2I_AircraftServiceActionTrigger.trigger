/**
 *      @author       Andy Fang
 *      @date         08/14/2019
 *      @description  Trigger on the Aircraft Service Action object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                     08/14/2019         Initial scaffold
 *
 */
trigger L2I_AircraftServiceActionTrigger on L2I_ASA__c (after insert, after update) {

    // Check if the trigger has to be run by checking if the User(Profile) has the Disable_AircraftServiceAction__c
    // flag turned on in the L2I_Trigger_Settings__c custom setting.

    if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_AircraftServiceAction__c) {
        System.debug('***** Bypassed execution of AircraftServiceAction trigger functions for user ' + UserInfo.getUserName());
        return;
    }

    // now handle it
    new L2I_AircraftServiceAction_TriggerHandler().run();
}