/**
 *      @author       Sarah Kennedy
 *      @date         06/25/2020
 *      @description  L2I_AE_CalculateQuoteBatch - Performs CPQ calcs
 *      This class can be run as a Batch or a Schedulable that calls the Batch.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/25/2020         Initial scaffold
 *
 */
global class L2I_AE_CalculateQuoteBatch implements Database.Batchable<SObject>, Database.Stateful {
    private L2I_LoggingStringBuffer logBuffer;
    private L2I_Order_Activation_Execution_Log__c oaeLog;
    private String logGuid = '';
    private Set<Id> allQuoteIds = new Set<Id>();
    private Set<Id> quoteErrorIds = new Set<Id>();
    private String quoteErrorMsg = '';
    private String logStatus = 'Completed';
    
    public L2I_AE_CalculateQuoteBatch() {
// for independent batch run
    }
    
    public L2I_AE_CalculateQuoteBatch(String guid) {
        logGuid = guid;
        logBuffer = new L2I_LoggingStringBuffer();
        logBuffer.append('Executing AutoExtend Step 2.5');
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('*** Starting L2I_AE_CalculateQuoteBatch');
        String query = 'SELECT Id, Name, SBQQ__Opportunity2__c ' +
              ' FROM SBQQ__Quote__c ' +
              ' WHERE SBQQ__Primary__c = true ' +
              ' AND SBQQ__Opportunity2__r.L2I_AutoExtend__c  = true ' +
              ' AND SBQQ__Ordered__c = false ' +
              ' AND ApprovalStatus__c = \'Approved\' ' +
              ' AND SBQQ__Opportunity2__r.RecordType.DeveloperName = \'Renewal\' ' +
              ' AND SBQQ__Opportunity2__r.StageName <> \'Closed Won\' ' +
              ' AND L2I_OrderActivationAlert__c = NULL ';
        System.debug('*** query ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        System.debug('*** Executing L2I_AE_CalculateQuoteBatch');
        List<SBQQ__Quote__c> quotes = (List<SBQQ__Quote__c>) scope;
        Set <Id> quoteIds = new Set<Id>();
        Set <Id> opptyIds = new Set<Id>();
        Set<String> quotesIdNumber = new Set<String>();
        for (SBQQ__Quote__c q : quotes) {
            quoteIds.add(q.Id);
            opptyIds.add(q.SBQQ__Opportunity2__c);
        }
        Savepoint sp = Database.setSavepoint();
        try {
// as this batch runs with a size of 1
            if (quotes.size() != 1) {
                if (logGuid != '') {
                    logBuffer.append('Skipping processing: Batch Size not = 1');
                    logStatus = 'Encountered Exception';
                }
            } else {
                allQuoteIds.add(quotes[0].Id);
                quotesIdNumber.add(quotes[0].Name + ' (' + quotes[0].Id + ') ');
                
                String idStr = '';
                for (String s : quotesIdNumber) {
                    idStr += (idStr == '' ? '' : ',') + s;
                }
                if (logGuid != '') {
                    logBuffer.append('Quotes identified: ' + idStr);
                }
    
                //  Update oppty stage to Closed Won
                System.debug('*** opptyIds ' + opptyIds);
                List<Opportunity> opptyList = new List<Opportunity>();
                opptyList = [SELECT Id, StageName, SBQQ__PrimaryQuote__r.ApprovalStatus__c, RecordType.DeveloperName
                    FROM Opportunity
                    WHERE Id IN :opptyIds];
                System.debug('*** opptyList ' + opptyList);
                for (Opportunity opp : opptyList) {
                    opp.StageName = 'Closed Won';
                }
                if (opptyList != NULL && opptyList.size() > 0) {
                    update opptyList;
                }
                
                System.debug('*** L2I_AE_CalculateQuoteBatch quotes to process: ' + quotes.size());
                System.debug('*** L2I_AE_CalculateQuoteBatch quotes: ' + quotes);

                // perform CPQ calculations and run Pricing Rules
                L2I_QuoteReader reader = new L2I_QuoteReader();
                L2I_QuoteModel quoteModel = reader.read(quotes[0].Id);
                L2I_QuoteCalculator quoteCalc = new L2I_QuoteCalculator();
                quoteCalc.calculate(quoteModel, 'L2I_CalculatorCallback');
            }
        } catch (Exception e) {
            Database.rollback(sp);
            quoteErrorIds.addAll(quoteIds);
            quoteErrorMsg = e.getMessage() + ' ' + e.getStackTraceString();
            if (!quoteErrorIds.isEmpty()) {
                setException(quoteErrorMsg, quoteErrorIds);
            }
            quoteErrorIds.clear();
            quoteErrorMsg = '';
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug('*** Finishing L2I_AE_CalculateQuoteBatch');
       
        if (logGuid != '') {
            oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(logGuid);
            String logTrace = oaeLog.Step2_Log_Message__c + '\n' + logBuffer.toStr();
            if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
                logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
            }
            oaeLog.Step2_Status__c = logStatus;
            oaeLog.Step2_Log_Message__c = logTrace;
            L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
            //
// call the next step
//
            Datetime now = System.now();
            Integer minsOffset = 1; // Schedule it a minute after the final batch has been completed.
            String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
    
            L2I_AE_CreateOrderSched step3 = new L2I_AE_CreateOrderSched(logGuid);
            if (!Test.isRunningTest()) {
                String jobId = System.schedule('AutoExtend Step3 ' + logGuid, cronTab, step3);
                System.debug('AutoExtend Step 3 ' + logGuid + ' has been scheduled as :' + jobId);
            }
        }
    
    }
    
    @TestVisible
    private void setException(String msgs, Set<Id> quoteIds) {
    
        Id systemAlertId = L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
              'Exception occurred while setting creating AutoExtend Calculate Quote :' + msgs,
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
            logBuffer.append('Exception occurred while setting creating AutoExtend Calculate Quote :' + msgs + ' for Quotes ' + quoteIds);
        }
    }
}