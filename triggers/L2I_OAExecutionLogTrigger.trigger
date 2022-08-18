/**
 *      @author       Raj Rajen
 *      @date         08/17/2019
 *      @description  Trigger on L2I Order Activation Execution Log
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/17/2019            Initial Setup
 *      Sarah Kennedy                 06/25/2020            US2046 - allow for varying steps of logging for other processes
 *
 */
trigger L2I_OAExecutionLogTrigger on L2I_Order_Activation_Execution_Log__c (before insert) {

    for (L2I_Order_Activation_Execution_Log__c log: Trigger.new) {
        if (trigger.isBefore && trigger.isInsert) {
            log.GUID__c = L2I_UtilityHelper.generateGuid();
//            log.Step1_Status__c = 'Awaiting Start';
//            log.Step2_Status__c = 'Awaiting Start';
//            log.Step3_Status__c = 'Awaiting Start';
//            log.Step4_Status__c = 'Awaiting Start';
        }
    }
}