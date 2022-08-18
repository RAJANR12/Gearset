/**
 *      @author       Arun vadduri
 *      @date         07/09/2019
 *      @description  Trigger on CPQ Quote Object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Arun Vadduri                  07/09/2019            Updates the source field with cloned record Id
 *      Raj Rajen                     08/01/2019            Refactored to use the Trigger Framework
 *      Sarah Kennedy                 03/31/2020            US1618 added after insert
 *
 */
 trigger L2I_QuoteTrigger on SBQQ__Quote__c (before insert, after insert, before update, after update) {

     /*
    for (SBQQ__Quote__c quote: Trigger.new) {
        if(quote.isClone() && quote.getCloneSourceId() != null) {
            quote.SBQQ__Source__c = quote.getCloneSourceId();
        }
    }
    */

     // Check if the trigger has to be run by checking if the User(Profile) has the Disable_Opportunity__c
     // flag turned on in the L2I_Trigger_Settings__c custom setting.
     if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_Quote__c) {
         System.debug('***** Bypassed execution of Quote trigger functions for user ' + UserInfo.getUserName());
         return;
     }

     // now handle it
     new L2I_Quote_TriggerHandler().run();
}