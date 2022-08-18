/**
 *      @author       Raj Rajen
 *      @date         07/28/2019
 *      @description  Trigger on the Opportunity object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/28/2019         Initial scaffold
 *      Andy Fang                     08/12/2019         Add after update
 *      Andy Fang                     02/05/2019         Add before update
 */
trigger L2I_OrderTrigger on Order ( before update, before insert, after insert, after update) {

    // Check if the trigger has to be run by checking if the User(Profile) has the Disable_Order__c
    // flag turned on in the L2I_Trigger_Settings__c custom setting.

    if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_Order__c) {
        System.debug('***** Bypassed execution of Order trigger functions for user ' + UserInfo.getUserName());
        return;
    }

    // now handle it
    new L2I_Order_TriggerHandler().run();
}