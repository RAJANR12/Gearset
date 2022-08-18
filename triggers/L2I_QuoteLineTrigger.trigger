/**
 *  @author       Raj Rajen
 *  @date         03/02/2020
 *  @description  Trigger on CPQ QuoteLine Object
 *
 *  Modification Log:
 *  ------------------------------------------------------------------------------------
 *  Developer                       Date                Description
 *  ------------------------------------------------------------------------------------
 *  Raj Rajen                     03/02/2020            Initial setup
 *
 */
trigger L2I_QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, before update, after insert, after update, before delete, after delete) {

    // Check if the trigger has to be run by checking if the User(Profile) has the Disable_Opportunity__c
    // flag turned on in the L2I_Trigger_Settings__c custom setting.
    if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_QuoteLine__c) {
        System.debug('***** Bypassed execution of QuoteLine trigger functions for user ' + UserInfo.getUserName());
        return;
    }

    // now handle it.
    new L2I_QuoteLine_TriggerHandler().run();
}