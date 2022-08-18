/**
 *      @author       Raj Rajen
 *      @date         03/24/2020
 *      @description  Trigger on the PLSalesOpportunity object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     03/24/2020         Initial scaffold
 *
 */
trigger L2I_PLSalesOpportunityTrigger on L2I_P_L_Sales_Opportunity__c (before insert, after insert, after update, after delete, after undelete) {

    // Check if the trigger has to be run by checking if the User(Profile) has the Disable_PLSalesOpportunity__c
    // flag turned on in the L2I_Trigger_Settings__c custom setting.

    if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_PLSalesOpportunity__c) {
        System.debug('***** Bypassed execution of PLSalesOpportunity trigger functions for user ' + UserInfo.getUserName());
        return;
    }

    // now handle it
    new L2I_PLSalesOpportunity_TriggerHandler().run();
}