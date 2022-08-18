/**
 *      @author       Raj Rajen
 *      @date         08/14/2019
 *      @description  Trigger on the AircraftService object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/14/2019         Initial scaffold
 *
 */
trigger L2I_AircraftServiceTrigger on L2I_Aircraft_Service__c (before update, before insert, after insert, after update) {

    // Check if the trigger has to be run by checking if the User(Profile) has the Disable_AircraftService__c
    // flag turned on in the L2I_Trigger_Settings__c custom setting.

    if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_AircraftService__c) {
        System.debug('***** Bypassed execution of AircraftService trigger functions for user ' + UserInfo.getUserName());
        return;
    }

    // now handle it
    new L2I_AircraftService_TriggerHandler().run();
}