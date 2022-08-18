/**
 *      @author       Sarah Kennedy
 *      @date         06/25/2020
 *      @description  L2I_OA_CreateContractBatch - Create Contracts
 *      This class can be run as a Batch or a Schedulable that calls the Batch.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/25/2020         Initial scaffold
 *
 */
global class L2I_OA_CreateContractBatch implements Database.Batchable<sObject>, Database.Stateful {
    private L2I_LoggingStringBuffer logBuffer;
    private L2I_Order_Activation_Execution_Log__c oaeLog;
    private String logGuid = '';
    private Set<Id> orderErrorIds = new Set<Id>();
    private String orderErrorMsg = '';
    private String logStatus = 'Completed';
    
    public L2I_OA_CreateContractBatch() {
        // for independent batch run
    }
    
    public L2I_OA_CreateContractBatch(String guid) {
        logGuid = guid;
        logBuffer = new L2I_LoggingStringBuffer();
        logBuffer.append('Executing AutoExtend Step 5');
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('*** Starting L2I_OA_CreateContractBatch');
        
        String query = ' SELECT Id, Name, OrderNumber ' +
              ' FROM Order ' +
              ' WHERE SBQQ__Contracted__c = false ' +
              ' AND Status = \'Activated\' ' +
              ' AND (L2I_Order_Process__c = \'Contract Management\' ' +
              ' OR L2I_Order_Process__c = \'Advertising Brand\' ) ' +
              ' AND L2I_OrderActivationAlert__c = NULL';
        System.debug('*** query ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        System.debug('*** Executing L2I_OA_CreateContractBatch');
        List<Order> orders = (List<Order>) scope;
        Set <Id> orderIds = new Set<Id>();
        Set <String> ordersIdNumber = new Set<String>();
        
        for (Order ord : orders) {
            ord.SBQQ__Contracted__c = true;
            orderIds.add(ord.Id);
            ordersIdNumber.add(ord.orderNumber + ' (' + ord.Id + ') ');
        }
        
        String idStr = '';
        for (String s : ordersIdNumber) {
            idStr += (idStr == '' ? '' : ',') + s;
        }
        if (logGuid != '') {
            logBuffer.append('Orders identified: ' + idStr);
        }
        Savepoint sp = Database.setSavepoint();
        try {
            if (orders != NULL && orders.size() > 0) {
                update orders;
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
        System.debug('*** Finishing L2I_OA_CreateContractBatch');
      
        if (logGuid != '') {
            String logTrace = logBuffer.toStr();
            if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
                logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
            }
            oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(logGuid);
            oaeLog.Step5_Status__c = logStatus;
            oaeLog.Step5_Log_Message__c = logTrace;
            L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
            //
            // call the next step
            //
            Datetime now = System.now();
            Integer minsOffset = 1; // Schedule it a minute after the final batch has been completed.
            String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
    
            L2I_OA_ActivateContractSched step6 = new L2I_OA_ActivateContractSched(logGuid);
            if (!Test.isRunningTest()) {
                String jobId = System.schedule('AutoExtend Step6 ' + logGuid, cronTab, step6);
                System.debug('AutoExtend Step 6 ' + logGuid + ' has been scheduled as :' + jobId);
            }
        }
    }
    
    @TestVisible
    private void setException(String msgs, Set<Id> orderIds) {
        
        Id systemAlertId = L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
              'Exception occurred while Activating orders:' + msgs,
              'Order', 'see Order Contract Management Log', UserInfo.getUserId(), false);
        
        if (!orderIds.isEmpty()) {
            List<Order> oList = [SELECT Id, L2I_OrderActivationAlert__c FROM Order WHERE Id IN :orderIds];
            for (Order o : oList) {
                o.L2I_OrderActivationAlert__c = systemAlertId;
            }
            if (oList != NULL && oList.size() > 0) {
                update oList;
            }
        }
        if (logGuid != '') {
            logStatus = 'Encountered Exception';
            logBuffer.append('Exception occurred while setting creating AutoExtend Create Contract :' + msgs + ' for Orders ' + orderIds);
        }
    }
}