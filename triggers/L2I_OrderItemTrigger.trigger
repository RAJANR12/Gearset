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
 *      Blake Poutra                  08/18/2019         Added After Update
 *      Andy Fang                     04/22/2020         Added After Update
 */
trigger L2I_OrderItemTrigger on OrderItem (before insert, after insert, after update) {

    // Check if the trigger has to be run by checking if the User(Profile) has the Disable_Order__c
    // flag turned on in the L2I_Trigger_Settings__c custom setting.

    if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_OrderItem__c) {
        System.debug('***** Bypassed execution of OrderItem trigger functions for user ' + UserInfo.getUserName());
        return;
    }

    // now handle it
    new L2I_OrderItem_TriggerHandler().run();
}