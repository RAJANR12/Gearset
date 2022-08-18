/**
 *      @author       Sarah Kennedy
 *      @date         02/09/2021
 *      @description  Trigger on the Invoice Line object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                  02/09/2021           Initial scaffold
 */
trigger L2I_InvoiceLineTrigger on blng__InvoiceLine__c (after insert) {

// Check if the trigger has to be run by checking if the User(Profile) has the Disable_Order__c
// flag turned on in the L2I_Trigger_Settings__c custom setting.

if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_InvoiceLine__c) {
System.debug('***** Bypassed execution of OrderItem trigger functions for user ' + UserInfo.getUserName());
return;
}

// now handle it
new L2I_InvoiceLine_TriggerHandler().run();
}