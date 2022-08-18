/**
 *      @author       Sarah Kennedy
 *      @date         02/27/2020
 *      @description  Trigger on the L2I_DSL__c (Delivery Schedule Lines) object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 02/27/2020        Initial scaffold
 *      Sarah Kennedy                 04/15/2020        Added disable check
 *
 */
trigger L2I_DSLTrigger on L2I_DSL__c (before insert, before delete, before update, after update) {

// Check if the trigger has to be run by checking if the User(Profile) has the Disable_DSL__c
// flag turned on in the L2I_Trigger_Settings__c custom setting.

if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_DSL__c) {
    System.debug('***** Bypassed execution of DSL trigger functions for user ' + UserInfo.getUserName());
    return;
}

//now handle it
new L2I_DSLTriggerHandler().run();
}