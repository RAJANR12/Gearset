/**
 *
 *      @author       Raj Rajen
 *      @date         09/13/2019
 *      @description  Batch class used by L2I_OrderActivation_Orchestrator
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     09/13/2019         Initial creation of batch class
 *      Sarah Kennedy                 03/26/2020         Added log GUID to batch names
 *      Sarah Kennedy                 06/28/2020         US2070 - only step run for Case activation; other steps now run by AutoExtend Process US2046
 *
 */
global class L2I_OA_SetEffectiveDateBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global final Set<Id> affectedOrderIds;
    global final Map<Id, Date> effectiveDateLookup;
    global final String logEntryGUID;
    global String ordId = '';
    
    global L2I_OA_SetEffectiveDateBatch(Set<Id> orderIds, Map<Id, Date>effectiveDatesByIds, String logEntryId) {
        affectedOrderIds = orderIds;
        effectiveDateLookup = effectiveDatesByIds;
        logEntryGUID = logEntryId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('select Id, EffectiveDate, blng__BillingDayOfMonth__c, L2I_Product_Category_2__c, L2I_AutoActivate__c ' +
              ' from Order ' +
              ' where Id in :affectedOrderIds' +
              ' and L2I_OrderActivationAlert__c = NULL');
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        
        List<Order> orders = (List<Order>) scope;
        System.debug('Executing L2I_OA_EffectiveDateBatch for ' + orders.size() + ' orders');
        System.debug('Current set of values in effectiveDateLookup :');
        for (Id key : effectiveDateLookup.keySet()) {
            Date eDate = effectiveDateLookup.get(key);
            System.debug('  Key : ' + key + ' Value : ' + eDate);
        }
        System.debug('----------------------------------------------');
        for (Order ord : orders) {
            Date effDate = effectiveDateLookup.get(ord.Id);
            System.debug('Effective date for Order Id: ' + ord.Id + ' is : ' + effDate);
            if (effDate != null) {
                Integer billingDayOfMonth = effDate.day();
                ord.EffectiveDate = effDate;
                String orderProductCategory = ord.L2I_Product_Category_2__c;
                if ('wifi'.equalsIgnoreCase(orderProductCategory)) {
                    ord.blng__BillingDayOfMonth__c = '1'; // US-966
                } else {
                    ord.blng__BillingDayOfMonth__c = String.valueOf(billingDayOfMonth);
                }
                ord.L2I_AutoActivate__c = true;
            }
            ordId = ord.Id;
        }
        
        try {
            update orders;
            System.debug('Orders update of Effective Date and Billing Day of Month was successful');
        } catch (DmlException dmle) {
            // send an alert and add the alert to the affected order(s)
            setException( dmle.getMessage() + ' ' + dmle.getStackTraceString(), ordId);
            
            // Publish the Order Activation Completed Platform Event as we have hit an exception scenario
            // There is no point in Scheduling the next step. We just want to clean up the Completed jobs
            L2I_UtilityHelper.publishOrderActivationCompletedEvent(logEntryGUID);
        }
    }
    
    @TestVisible
    private void setException (String msgs, String ordId){
        Id systemAlertId = L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
              'DML Exception occurred while setting setting Activation date and Billing Day of Month in Order Activation :' + msgs,
              'Order', ordId, UserInfo.getUserId(), true);
        if (!String.isBlank(ordId)) {
            List<Order> ordList = [SELECT Id, L2I_OrderActivationAlert__c FROM Order WHERE Id = :ordId];
            ordList[0].L2I_OrderActivationAlert__c = systemAlertId;
            update ordList;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // end of the process
        
        // Schedule the next step of Order Activation
//        Datetime now = System.now();
        
//        Integer minsOffset = 1; // Schedule it a minute after the final batch has been completed.
//        String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
        
//        if (!Test.isRunningTest()) {
//            L2I_OrderActivation_SchedulableStep2 step2 = new L2I_OrderActivation_SchedulableStep2(affectedOrderIds, logEntryGUID);
//            String jobId = System.schedule('Order Activation Step 2 ' + logEntryGUID, cronTab, step2);
//            System.debug('Order Activation Step 2 ' + logEntryGUID + ' has been scheduled as :' + jobId);
//        }
    }

}