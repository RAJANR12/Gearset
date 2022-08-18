/**
 *      @author       Sarah Kennedy
 *      @date         06/25/2020
 *      @description  L2I_OA_ActivateContractBatch - Activate Contracts
 *      This class can be run as a Batch or a Schedulable that calls the Batch.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/25/2020         Initial scaffold
 *
 */
global class L2I_OA_ActivateContractBatch implements Database.Batchable<sObject>, Database.Stateful {
    private L2I_LoggingStringBuffer logBuffer;
    private L2I_Order_Activation_Execution_Log__c oaeLog;
    private String logGuid = '';
    private Set<Id> contractErrorIds = new Set<Id>();
    private String contractErrorMsg = '';
    private String logStatus = 'Completed';
    
    public L2I_OA_ActivateContractBatch() {
        // for independent batch run
    }
    
    public L2I_OA_ActivateContractBatch(String guid) {
        logGuid = guid;
        logBuffer = new L2I_LoggingStringBuffer();
        logBuffer.append('Executing AutoExtend Step 6');
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('*** Starting L2I_OA_ActivateContractBatch');
        
        String query = 'SELECT Id, Name, ContractNumber ' +
              '  FROM Contract ' +
              '  WHERE Status != \'Activated\' ' +
              '  AND L2I_OrderActivationAlert__c = NULL';
        System.debug('*** query ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        System.debug('*** Executing L2I_OA_ActivateContractBatch');
        List<Contract> contracts = (List<Contract>) scope;
        Set <Id> contractIds = new Set<Id>();
        Set <String> contractsIdNumber = new Set<String>();
        
        for (Contract c : contracts) {
            c.Status = 'Activated';
            contractIds.add(c.Id);
            contractsIdNumber.add(c.ContractNumber + ' (' + c.Id + ') ');
        }
    
        String idStr = '';
        for (String s : contractsIdNumber) {
            idStr += (idStr == '' ? '' : ',') + s;
        }
        if (logGuid != '') {
            logBuffer.append('Contracts identified: ' + idStr);
        }
        Savepoint sp = Database.setSavepoint();
        try {
            if (contracts != NULL && contracts.size() > 0) {
                update contracts;
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
        System.debug('*** Finishing L2I_OA_ActivateContractBatch');
        
        if (logGuid != '') {
            String logTrace = logBuffer.toStr();
            if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
                logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
            }
            oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(logGuid);
            oaeLog.Step6_Status__c = logStatus;
            oaeLog.Step6_Log_Message__c = logTrace;
            L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
            //
            // call the next steps
            //
            Datetime now = System.now();
            Integer minsOffset = 1; // Schedule it a minute after the final batch has been completed.
            String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
            String jobId;
    
            // terminate prior contracts
            L2I_TerminatePriorContractSched step7 = new L2I_TerminatePriorContractSched(logGuid);
            if (!Test.isRunningTest()) {
                jobId = System.schedule('AutoExtend Step7 ' + logGuid, cronTab, step7);
                System.debug('AutoExtend Step 7 ' + logGuid + ' has been scheduled as :' + jobId);
            }
        }
    }
    
    @TestVisible
    private void setException(String msgs, Set<Id> contractErrorIds) {
        
        Id systemAlertId = L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
              'Exception occurred while Activating contracts:' + msgs,
              'Contract', 'see Order Contract Management Log', UserInfo.getUserId(), false);
        
        if (!contractErrorIds.isEmpty()) {
            List<Contract> cList = [SELECT Id, L2I_OrderActivationAlert__c FROM Contract WHERE Id IN :contractErrorIds];
            for (Contract c : cList) {
                c.L2I_OrderActivationAlert__c = systemAlertId;
            }
            if (cList != NULL && cList.size() > 0) {
                update cList;
            }
        }
        if (logGuid != '') {
            logStatus = 'Encountered Exception';
            logBuffer.append('Exception occurred while setting creating AutoExtend Activate Contracts:' + msgs + ' for Contracts ' + contractErrorIds);
        }
    }
}