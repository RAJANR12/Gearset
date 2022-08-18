/**
 *      @author       Raj Rajen
 *      @date         08/26/2019
 *      @description  Trigger on the L2I_DSH__c (Delivery Schedule Header) object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/26/2019         Initial scaffold
 *      Sarah Kennedy                 03/02/2020         Added before delete
 *      Sarah Kennedy                 04/15/2020         Added disable check
 */
trigger L2I_DSHTrigger on L2I_DSH__c (after update, before delete, before update) {

    // Check if the trigger has to be run by checking if the User(Profile) has the Disable_DSH__c
    // flag turned on in the L2I_Trigger_Settings__c custom setting.

    if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_DSH__c) {
        System.debug('***** Bypassed execution of DSH trigger functions for user ' + UserInfo.getUserName());
        return;
    }

    //now handle it
    new L2I_DSH_TriggerHandler().run();
}