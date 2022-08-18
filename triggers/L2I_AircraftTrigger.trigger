/**
 *      @author       Raj Rajen
 *      @date         08/02/2019
 *      @description  Trigger on L2I Aircraft Object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/02/2019            Initial Setup
 *
 */
trigger L2I_AircraftTrigger on L2I_Aircraft__c (before delete) {

    // Check if the trigger has to be run by checking if the User(Profile) has the Disable_Opportunity__c
    // flag turned on in the L2I_Trigger_Settings__c custom setting.
    if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_Aircraft__c) {
        System.debug('***** Bypassed execution of Quote trigger functions for user ' + UserInfo.getUserName());
        return;
    }

    // now handle it
    new L2I_Aircraft_TriggerHandler().run();
}