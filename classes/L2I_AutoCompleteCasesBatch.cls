/**
 *      @author       Sarah Kennedy
 *      @date         06/25/2020
 *      @description  L2I_AutoCompleteCasesBatch - AutoComplete Cases
 *      This class can be run as a Batch or a Schedulable that calls the Batch.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/25/2020         Initial scaffold
 *
 */
global class L2I_AutoCompleteCasesBatch implements Database.Batchable<sObject>, Database.Stateful {
    private L2I_LoggingStringBuffer logBuffer;
    private L2I_Order_Activation_Execution_Log__c oaeLog;
    private String logGuid = '';
    private Set<Id> orderErrorIds = new Set<Id>();
    private String orderErrorMsg = '';
    private String logStatus = 'Completed';
    
    public L2I_AutoCompleteCasesBatch() {
// for independent batch run
    }
    
    public L2I_AutoCompleteCasesBatch(String guid) {
        logGuid = guid;
        logBuffer = new L2I_LoggingStringBuffer();
        logBuffer.append('Executing AutoExtend Step 8 ');
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('*** Starting L2I_AutoCompleteCasesBatch');
        Set<String> skipFulfillmentCategories = new Set<String>();
        skipFulfillmentCategories = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
              'Skip Fulfillment');
        
        String query =
              'SELECT Id, Name, OrderNumber, Type ' +
                    ' FROM Order ' +
                    ' WHERE Status = \'Activated\' ' +
                    ' AND Type = \'Renewal\' ' +
                    ' AND (L2I_Order_Process__c = \'Contract Management\' ' +
                    ' OR L2I_Order_Process__c = \'Advertising Brand\' ) ' +
                    ' AND L2I_Product_Category_2__c IN :skipFulfillmentCategories ' +
                    ' AND L2I_Revise_Modified__c = true ' +
                    ' AND L2I_OrderActivationAlert__c = NULL';
        System.debug('*** query ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('*** Executing L2I_AutoCompleteCasesBatch');
        
        
        List<Order> orders = (List<Order>) scope;
        Set <Id> orderIds = new Set<Id>();
        Set <String> ordersIdNumber = new Set<String>();
        Set <String> casesIdNumber = new Set<String>();
        
        for (Order ord : orders) {
            orderIds.add(ord.Id);
            ordersIdNumber.add(ord.OrderNumber + ' (' + ord.Id + ') ');
        }
        
        String idStr = '';
        for (String s : ordersIdNumber) {
            idStr += (idStr == '' ? '' : ',') + s;
        }
        if (logGuid != '') {
            logBuffer.append('Orders identified: ' + idStr);
        }
        
        List<Case> caseList = new List<Case>();
        caseList = [
              SELECT Id,
                    CaseNumber,
                    L2I_Activate_ASA_Record_Count__c,
                    L2I_Activation_Date__c,
                    L2I_Deactivate_ASA_Record_Count__c,
                    L2I_Deactivation_Date__c,
                    L2I_Cancel_ASA_Record_Count__c,
                    L2I_Order__c,
                    L2I_Order__r.EffectiveDate,
                    L2I_Case_Process__c
              FROM Case
              WHERE L2I_Order__c IN :orderIds
              AND L2I_Case_Process__c = 'Revise'
              AND L2I_Cancel_ASA_Record_Count__c = 0
              AND ((L2I_Activate_ASA_Record_Count__c > 0 AND L2I_Activation_Date__c = NULL)
              OR (L2I_Deactivate_ASA_Record_Count__c > 0 AND L2I_Deactivation_Date__c = NULL))
        ];
        
        if (caseList.size() > 0) {
            for (Case c : caseList) {
                casesIdNumber.add(c.caseNumber + ' (' + c.Id + ') ');
                if (c.L2I_Activate_ASA_Record_Count__c > 0) {
                    c.L2I_Activation_Date__c = c.L2I_Order__r.EffectiveDate;
                }
                if (c.L2I_Deactivate_ASA_Record_Count__c > 0) {
                    c.L2I_Deactivation_Date__c = c.L2I_Order__r.EffectiveDate.addDays(-1);
                    // setting the deactivation datetime to the end of the day; converting date effectivedate to datetime deactivation
                    //   sets the time to 00:00:00
                    c.L2I_Deactivation_Date__c = c.L2I_Deactivation_Date__c.addHours(23);
                }
            }
        }
        if (!casesIdNumber.isEmpty()) {
            idStr = '';
            for (String s : casesIdNumber) {
                idStr += (idStr == '' ? '' : ',') + s;
            }
            if (logGuid != '') {
                logBuffer.append('Cases identified: ' + idStr);
            }
        } else {
            if (logGuid != '') {
                logBuffer.append('No Cases were identified');
            }
        }
        
        
        Savepoint sp = Database.setSavepoint();
        try {
            if (caseList != NULL && caseList.size() > 0) {
                update caseList;
            }
        } catch (Exception e) {
            Database.rollback(sp);
            orderErrorIds.addAll(orderIds);
            orderErrorMsg = e.getMessage() + ' ' + e.getStackTraceString();
            if (!orderErrorIds.isEmpty()) {
                setException(orderErrorMsg, orderErrorIds);
            }
            orderErrorIds.clear();
            orderErrorMsg = '';
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('*** Finishing L2I_AutoCompleteCasesBatch');
        
        if (logGuid != '') {
            String logTrace = logBuffer.toStr();
            if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
                logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
            }
            oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(logGuid);
            oaeLog.Step8_Status__c = logStatus;
            oaeLog.Step8_Log_Message__c = logTrace;
            L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
            // cleanup the jobs
            System.debug('*** L2I_OA_ActivateContractSched calling Platform Event to clear jobs ' + logGuid);
            L2I_UtilityHelper.publishOrderActivationCompletedEvent(String.valueOf(logGuid));
        }
    }
    
    @TestVisible
    private void setException(String msgs, Set<Id> orderErrorIds) {
        
        Id systemAlertId = L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
              'Exception occurred while AutoCompleting Cases:' + msgs,
              'Order', 'see Order Contract Management Log', UserInfo.getUserId(), false);
        
        if (!orderErrorIds.isEmpty()) {
            List<Order> oList = [SELECT Id, L2I_OrderActivationAlert__c FROM Order WHERE Id IN :orderErrorIds];
            for (Order o : oList) {
                o.L2I_OrderActivationAlert__c = systemAlertId;
            }
            if (oList != null && oList.size() > 0) {
                update oList;
            }
        }
        if (logGuid != '') {
            logStatus = 'Encountered Exception';
            logBuffer.append('Exception occurred while AutoCompleting Cases :' + msgs + ' for Orders ' + orderErrorIds);
        }
    }
}