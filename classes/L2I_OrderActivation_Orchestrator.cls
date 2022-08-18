/**
 *      @author       Raj Rajen
 *      @date         08/09/2019
 *      @description  L2I Order Activation Schedulable Job - Step 1
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/09/2019         Initial scaffold
 *      Sarah Kennedy                 03/19/2020         Modifications for Amendments/Renewals changes to objects and fields
 *      Sarah Kennedy                 03/26/2020         Added log GUID to batch name
 *      Sarah Kennedy                 04/10/2020         Removed unused Order_Product_Activation_Status__c  from the Aircraft Service Query as it is being removed as a field
 *      Sarah Kennedy                 04/10/2020         US1762 Order Activation by Case
 *      Sarah Kennedy                 06/28/2020         US2070 - Modify so this is the only step run
 *
 */
global class L2I_OrderActivation_Orchestrator implements Schedulable {
    
    // This Schedulable class implements Step 1 of the following four-step process.
    // =============================================================================
    
    // +----------------------------------------------------------------------------------------------------+
    // | Identify order to activate, query min activation Date from Aircraft Services.                      |
    // | Step 1                                                                                             |
    // | Update Order.EffectiveDate (Order Start Date)= Min Activation Date                                 |
    // | Update Order.blng__BillingDayOfMonth__c  (Billing Day of Month)= Day of month (Min Activation Date)|
    // | Commit, This will update Start/End Dates & Next Bill Date, on OrderItems                           |
    // +----------------------------------------------------------------------------------------------------+
    //
    // **** The following steps are now run as part of the AutoExtend Process - US2046 ****
    //
    // Step 2
    // Update Order.Status = "Activated"
    // Commit, This will Activate Order, OrderItems and Update Usage Summary Dates correctly.
    //
    // Step 3
    // Update Order.Contracted = True
    // Commit, This will create/Update Contract and create Subscription Records.
    //
    // Step 4
    // Query Contract where contract.SBQQ__Order__c (Order) = order.id
    // Update Contract.Status = Activated
    // Commit, This will activate the contract.
    
    global String logId;
    global Map<Id, Date> orderMinActivationDateMapIn = new Map<Id, Date>();
    public L2I_OrderActivation_Orchestrator(String logGuid, String jsonOrderMap) {
        System.debug('*** L2I_OrderActivation_Orchestrator logGuid ' + logGuid);
        System.debug('*** L2I_OrderActivation_Orchestrator jsonOrderMap ' + jsonOrderMap);
        logId = logGuid;
        orderMinActivationDateMapIn = (Map<Id, Date>) JSON.deserializeStrict(jsonOrderMap, Map<Id, Date> .class);
    }
    
    global void execute(SchedulableContext sc) {
        L2I_LoggingStringBuffer logBuffer = new L2I_LoggingStringBuffer();
        
        Datetime today = Datetime.now();
        String dayOfWeek = today.format('EEEE');
        
        Date batchRunDate = Date.today();
        System.debug('*** Accessing OA log');
//        L2I_Order_Activation_Execution_Log__c logEntry = L2I_OAExecutionLog_Helper.createLogEntry();
        L2I_Order_Activation_Execution_Log__c logEntry = [
              SELECT Id,
                    Step1_Status__c,
                    Step2_Status__c,
                    Step3_Status__c,
                    Step4_Status__c,
                    Step1_Entry_Time__c,
                    Batch_Date__c,
                    Execution_Date__c,
                    Step1_Exit_Time__c,
                    Step1_Log_Message__c,
                    Guid__c
              FROM L2I_Order_Activation_Execution_Log__c
              WHERE Guid__c = :logId
        ];
        logEntry.Step1_Status__c = 'Started';
        logEntry.Step2_Status__c = '';
        logEntry.Step3_Status__c = '';
        logEntry.Step4_Status__c = '';
        logEntry.Step1_Entry_Time__c = Datetime.now();
        logEntry.Batch_Date__c = batchRunDate;
        logEntry.Execution_Date__c = Date.today();
        
        System.debug('*** logEntry ' + logEntry);
        
        L2I_OAExecutionLog_Helper.updateLogEntry(logEntry);
        
        logBuffer.append('Executing Order Activation Step 1 Scheduled Job');
        
        Map<Id, Date> orderMinActivationDateMap = new Map<Id, Date>();
        Set<Id> affectedOrderIds = new Set<Id>();
        // make sure order status is still not activated
        // there is still a potential that an order that was draft comes through but gets activated in the minute it takes for the Order Orchestration to run
        for (Order ord : [
              SELECT Id,
                    Status
              FROM Order
              WHERE Id IN :orderMinActivationDateMapIn.keySet()
              AND Status != 'Activated'
        ]) {
            orderMinActivationDateMap.put(ord.Id, orderMinActivationDateMapIn.get(ord.Id));
            affectedOrderIds.add(ord.Id);
        }
        
        System.debug('*** affectedOrderIds ' + affectedOrderIds);
        if (!affectedOrderIds.isEmpty()) {
            System.debug('*** orderMinActivationDateMap ' + orderMinActivationDateMap);
            System.debug('*** orderMinActivationDateMapIn ' + orderMinActivationDateMapIn);
            logBuffer.append('Step 1 Number of Orders to Activate :' + affectedOrderIds.size());
            
            List<Order> affectedOrders = new List<Order>([
                  select Id,
                        Status,
                        ActivatedDate,
                        EffectiveDate,
                        EndDate
                  from Order
                  where Id in :affectedOrderIds
            ]);
//
//            logBuffer.append('Number of Affected Orders : ' + affectedOrders.size() + ' to Activate');
            
            // ==============================================================================
            // Step 1 - set Effective Date and Billing Day of Month on affected Orders
            // Expectation: This will update Start/End Dates & Next Bill Date, on OrderItems
            // ==============================================================================
            for (Order ord : affectedOrders) {
                logBuffer.append('Updating order ' + ord.Id + ' with EffectiveDate and BillingDayOfMonth ');
                Date minDate = orderMinActivationDateMap.get(ord.Id);
//                Integer billingDayOfMonth = minDate.day();
                logBuffer.append('Min Activation Date for Order ' + ord.Id + ' is :' + minDate);
//                logBuffer.append('Billing day of month : ' + billingDayOfMonth);
            }
            
            try {
                //update affectedOrders;
                System.debug('*** affectedOrderIds ' + affectedOrderIds);
                System.debug('*** orderMinActivationDateMap ' + orderMinActivationDateMap);
                Integer batchSize = Integer.valueOf([select Order_Activation_Batch_Size__c from L2I_General_Settings__mdt limit 1].Order_Activation_Batch_Size__c);
                logBuffer.append('Order Activation Batch Size: ' + batchSize);
                L2I_OA_SetEffectiveDateBatch effectiveDateBatch = new L2I_OA_SetEffectiveDateBatch(affectedOrderIds, orderMinActivationDateMap, logEntry.GUID__c);
                Database.executeBatch(effectiveDateBatch, batchSize);
                
                logEntry.Step1_Status__c = 'Completed';
               
                L2I_OAExecutionLog_Helper.updateLogEntry(logEntry); // Need to commit logEntry or the step1 status wont be picked up in step 2
    
                // Publish the Order Activation Completed Platform Event as we are all done
                L2I_UtilityHelper.publishOrderActivationCompletedEvent(logEntry.GUID__c);
            } catch (DmlException dmle) {
                logEntry.Step1_Status__c = 'Encountered DML Exception';
                logBuffer.append('DML Exception occurred while setting Effective Date and Billing Day of Month:');
                logBuffer.append('Exception Error Message :\n' + dmle.getMessage());
                
                L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
                      'DML Exception occurred while setting Activation date and Billing Day of Month :' + dmle.getMessage());
                
               
                // There is no point in Scheduling the next step. We just want to clean up the Completed jobs
                L2I_UtilityHelper.publishOrderActivationCompletedEvent(logEntry.GUID__c);
            }
        } else {
            logEntry.Step1_Status__c = 'Nothing to process';
//            logEntry.Step2_Status__c = 'Aborted';
//            logEntry.Step3_Status__c = 'Aborted';
//            logEntry.Step4_Status__c = 'Aborted';
            // Looks like we have nothing to act on
            logBuffer.append('There are *Zero* affected Aircraft Service Orders to process');
            logBuffer.append('Nothing to Process');
//            logBuffer.append('Aborting Step 2');
//            logBuffer.append('Aborting Step 3');
//            logBuffer.append('Aborting Step 4');
            
            // Clean up the Completed jobs (in this Case just the Step 1 Scheduled job)
            L2I_UtilityHelper.publishOrderActivationCompletedEvent(logEntry.GUID__c);
        }
        
        logEntry.Step1_Exit_Time__c = Datetime.now();
        String logTrace = logBuffer.toStr();
        if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
            logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
        }
        logEntry.Step1_Log_Message__c = logTrace;
        L2I_OAExecutionLog_Helper.updateLogEntry(logEntry);
    }

}