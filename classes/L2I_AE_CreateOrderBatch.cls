/**
 *      @author       Sarah Kennedy
 *      @date         06/25/2020
 *      @description  L2I_AE_CreateOrderBatch - Creates Orders
 *      This class can be run as a Batch or a Schedulable that calls the Batch.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/25/2020         Initial scaffold
 *
 */
global class L2I_AE_CreateOrderBatch implements Database.Batchable<SObject>, Database.Stateful {
    private L2I_LoggingStringBuffer logBuffer;
    private L2I_Order_Activation_Execution_Log__c oaeLog;
    private String logGuid = '';
    private Set<Id> allQuoteIds = new Set<Id>();
    private Set<Id> quoteErrorIds = new Set<Id>();
    private String quoteErrorMsg = '';
    private String logStatus = 'Completed';
    
    public L2I_AE_CreateOrderBatch() {
        // for independent batch run
    }
    
    public L2I_AE_CreateOrderBatch(String guid) {
        logGuid = guid;
        logBuffer = new L2I_LoggingStringBuffer();
        logBuffer.append('Executing AutoExtend Step 3');
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('*** Starting L2I_AE_CreateOrderBatch');
        String query = 'SELECT Id, Name, ApprovalStatus__c, ' +
              ' SBQQ__Opportunity2__c, SBQQ__Ordered__c ' +
              ' FROM SBQQ__Quote__c ' +
              ' WHERE SBQQ__Primary__c = true ' +
              ' AND SBQQ__Opportunity2__r.L2I_AutoExtend__c  = true ' +
              ' AND SBQQ__Opportunity2__r.StageName = \'Closed Won\' ' +
              ' AND SBQQ__Ordered__c = false ' +
              ' AND ApprovalStatus__c = \'Approved\' ' +
              ' AND SBQQ__Opportunity2__r.RecordType.DeveloperName = \'Renewal\' ' +
              ' AND L2I_OrderActivationAlert__c = NULL '
        ;
        System.debug('*** query ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        System.debug('*** Executing L2I_AE_CreateOrderBatch');
        List<SBQQ__Quote__c> quotes = (List<SBQQ__Quote__c>) scope;
        Set <Id> quoteIds = new Set<Id>();
        Set <Id> opptyIds = new Set<Id>();
        Set<String> quotesIdNumber = new Set<String>();
    
        for (SBQQ__Quote__c q : quotes) {
            quoteIds.add(q.Id);
        }
        Savepoint sp = Database.setSavepoint();
        try {
            if (quotes.size() > 1) {
                if (logGuid != '') {
                    logBuffer.append('Skipping processing: Batch Size not = 1');
                    logStatus = 'Encountered Exception';
                }
            } else {
                for (SBQQ__Quote__c qt : quotes) {
                    qt.SBQQ__Ordered__c = true;
                    opptyIds.add(qt.SBQQ__Opportunity2__c);
                    allQuoteIds.add(qt.Id);
                    quotesIdNumber.add(qt.Name + ' (' + qt.Id + ') ');
                }
    
                String idStr = '';
                for (String s : quotesIdNumber) {
                    idStr += (idStr == '' ? '' : ',') + s;
                }
                if (logGuid != '') {
                    logBuffer.append('Quotes identified: ' + idStr);
                }
    
                System.debug('*** L2I_AE_CreateOrderBatch quotes to process: ' + quotes.size());
                System.debug('*** L2I_AE_CreateOrderBatch quotes: ' + quotes);
                
                if (quotes != NULL && quotes.size() > 0) {
                    update quotes;
                }

                System.debug('*** L2I_AE_CreateOrderBatch updated quotes and opportunities');
            }
        } catch (Exception e) {
            Database.rollback(sp);
            quoteErrorIds.addAll(quoteIds);
            quoteErrorMsg = e.getMessage() + ' ' + e.getStackTraceString();
            if (!quoteErrorIds.isEmpty()){
                setException(quoteErrorMsg, quoteErrorIds);
            }
            quoteErrorIds.clear();
            quoteErrorMsg = '';
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug('*** Finishing L2I_AE_CreateOrderBatch');
        
        if (logGuid != '') {
            String logTrace = logBuffer.toStr();
            if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
                logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
            }
            oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(logGuid);
            oaeLog.Step3_Status__c = logStatus;
            oaeLog.Step3_Log_Message__c = logTrace;
            L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
            //
            // call the next step
            //
            Datetime now = System.now();
            Integer minsOffset = 1; // Schedule it a minute after the final batch has been completed.
            String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
    
            L2I_OA_ActivateOrderSched step4 = new L2I_OA_ActivateOrderSched(logGuid);
            if (!Test.isRunningTest()) {
                String jobId = System.schedule('AutoExtend Step4 ' + logGuid, cronTab, step4);
                System.debug('AutoExtend Step 4 ' + logGuid + ' has been scheduled as :' + jobId);
            }
        }
    }
    
    @TestVisible
    private void setException(String msgs, Set<Id> quoteIds) {
        Id systemAlertId = L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
              'Exception occurred while setting creating AutoExtend Create Orders :' + msgs,
              'Quote', 'see Order Contract Management Log', UserInfo.getUserId(), false);
    
        if (!quoteIds.isEmpty()) {
            List<SBQQ__Quote__c> qList = [SELECT Id, L2I_OrderActivationAlert__c FROM SBQQ__Quote__c WHERE Id IN :quoteIds];
            for (SBQQ__Quote__c q : qList) {
                q.L2I_OrderActivationAlert__c = systemAlertId;
            }
            if (qList != NULL && qList.size() > 0) {
                update qList;
            }
        }
    
        if (logGuid != '') {
            logStatus = 'Encountered Exception';
            logBuffer.append('Exception occurred while setting creating AutoExtend Create Order :' + msgs + ' for Quotes ' + quoteIds);
        }
    }
}