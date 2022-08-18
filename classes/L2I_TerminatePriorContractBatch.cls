/**
 *      @author       Sarah Kennedy
 *      @date         06/25/2020
 *      @description  L2I_TerminatePriorContractBatch - Terminate prior contracts
 *      This class can be run as a Batch or a Schedulable that calls the Batch.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/25/2020         Initial scaffold
 *
 */
global class L2I_TerminatePriorContractBatch implements Database.Batchable<sObject>, Database.Stateful {
    private L2I_LoggingStringBuffer logBuffer;
    private L2I_Order_Activation_Execution_Log__c oaeLog;
    private String logGuid = '';
    private Set<Id> contractErrorIds = new Set<Id>();
    private String contractErrorMsg = '';
    private String logStatus = 'Completed';
    
    public L2I_TerminatePriorContractBatch() {
// for independent batch run
    }
    
    public L2I_TerminatePriorContractBatch(String guid) {
        logGuid = guid;
        logBuffer = new L2I_LoggingStringBuffer();
        logBuffer.append('Executing AutoExtend Step 7 ');
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('*** Starting L2I_TerminatePriorContractBatch');
        
        String query = 'SELECT Id, Name, L2I_ToBeTerminatedDate__c, SBQQ__Contract__c, SBQQ__EndDate__c, SBQQ__Contract__r.ContractNumber, SBQQ__TerminatedDate__c' +
              ' FROM SBQQ__Subscription__c' +
              ' WHERE L2I_ToBeTerminatedDate__c != NULL ' +
              ' AND SBQQ__TerminatedDate__c = NULL' +
              ' AND SBQQ__SubscriptionType__c = \'Renewable\' ' +
              ' AND SBQQ__Contract__r.L2I_OrderActivationAlert__c = NULL';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('*** Executing L2I_TerminatePriorContractBatch');
        List<SBQQ__Subscription__c> subList = (List<SBQQ__Subscription__c>) scope;
        List<SBQQ__Subscription__c> finalSubList = new List<SBQQ__Subscription__c>();
        List<OrderItem> finalOiList = new List<OrderItem>();
        List<Order> finalOrderList = new List<Order>();
        Set <Id> contractIds = new Set<Id>();
        Set <Id> orderIds = new Set<Id>();
        Map<Id, Date> subTermDateMap = new Map<Id, Date>();
        Set <String> contractsIdNbr = new Set<String>();
        Savepoint sp = Database.setSavepoint();
        try {
            for (SBQQ__Subscription__c sub : subList) {
                if (sub.SBQQ__EndDate__c >= sub.L2I_ToBeTerminatedDate__c) {
                    sub.SBQQ__TerminatedDate__c = sub.L2I_ToBeTerminatedDate__c;
                    finalSubList.add(sub);
                    subTermDateMap.put(sub.Id, sub.L2I_ToBeTerminatedDate__c);
                    contractIds.add(sub.SBQQ__Contract__c);
                    contractsIdNbr.add(sub.SBQQ__Contract__r.ContractNumber + ' (' + sub.SBQQ__Contract__c + ') ' + sub.Name);
                }
            }
            String idStr = '';
            for (String s : contractsIdNbr) {
                idStr += (idStr == '' ? '' : ',') + s;
            }
            if (logGuid != '') {
                logBuffer.append('Contracts identified for Subscriptions: ' + idStr);
            }
            if (finalSubList.size() > 0) {
                finalOiList = [
                      SELECT
                            Id,
                            SBQQ__TerminatedDate__c,
                            SBQQ__Subscription__c,
                            OrderId
                      FROM OrderItem
                      WHERE SBQQ__Subscription__c IN :subTermDateMap.keySet()
                ];
                for (OrderItem oi : finalOiList) {
                    oi.SBQQ__TerminatedDate__c = subTermDateMap.get(oi.SBQQ__Subscription__c);
                    orderIds.add(oi.OrderId);
                }
                if (!orderIds.isEmpty()) {
                    finalOrderList = [
                          SELECT
                                Id, L2I_Terminated__c
                          FROM Order
                          WHERE Id IN :orderIds
                    ];
                    for (Order ord : finalOrderList) {
                        ord.L2I_Terminated__c = true;
                    }
                }
            }
            if (finalSubList.size() > 0) {
                update finalSubList;
            }
            if (finalOiList.size() > 0) {
                update finalOiList;
            }
            if (finalOrderList.size() > 0) {
                update finalOrderList;
            }
        } catch (Exception e) {
            Database.rollback(sp);
            contractErrorIds.addAll(contractIds);
            contractErrorMsg = e.getMessage() + ' ' + e.getStackTraceString();
            if (!contractErrorIds.isEmpty()) {
                setException(contractErrorMsg, contractErrorIds);
            }
            contractErrorIds.clear();
            contractErrorMsg = '';
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('*** Finishing L2I_TerminatePriorContractBatch');
        
        if (logGuid != '') {
            String logTrace = logBuffer.toStr();
            if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
                logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
            }
            oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(logGuid);
            oaeLog.Step7_Status__c = logStatus;
            oaeLog.Step7_Log_Message__c = logTrace;
            L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
    
            //
            // call the next steps
            //
            Datetime now = System.now();
            Integer minsOffset = 1; // Schedule it a minute after the final batch has been completed.
            String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
            String jobId;
    
            // AutoComplete Cases
            L2I_AutoCompleteCasesSched step8 = new L2I_AutoCompleteCasesSched(logGuid);
            if (!Test.isRunningTest()) {
                jobId = System.schedule('AutoExtend Step8 ' + logGuid, cronTab, step8);
                System.debug('AutoExtend Step 8 ' + logGuid + ' has been scheduled as :' + jobId);
            }
        }
    }
    
    @TestVisible
    private void setException(String msgs, Set<Id> contractErrorIds) {
        
        Id systemAlertId = L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
              'Exception occurred while Terminating Prior Contracts:' + msgs,
              'Contract', 'see Order Contract Management Log', UserInfo.getUserId(), false);
        
        if (!contractErrorIds.isEmpty()) {
            List<Contract> oList = [SELECT Id, L2I_OrderActivationAlert__c FROM Contract WHERE Id IN :contractErrorIds];
            for (Contract o : oList) {
                o.L2I_OrderActivationAlert__c = systemAlertId;
            }
            if (oList != NULL && oList.size() > 0) {
                update oList;
            }
        }
        if (logGuid != '') {
            logStatus = 'Encountered Exception';
            logBuffer.append('Exception occurred while setting creating Terminate Prior Contracts :' + msgs + ' for Contracts ' + contractErrorIds);
        }
    }
}