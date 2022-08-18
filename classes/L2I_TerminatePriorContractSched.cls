/**
 *      @author       Sarah Kennedy
 *      @date         06/25/2020
 *      @description  L2I_TerminatePriorContractSched - Scheduled job calls batch to Terminate Prior Contracts
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/25/2020         Initial scaffold
 *
 */
global class L2I_TerminatePriorContractSched implements Schedulable {
    private L2I_LoggingStringBuffer logBuffer = new L2I_LoggingStringBuffer();
    private L2I_Order_Activation_Execution_Log__c oaeLog;
    private String logGuid;
    
    public L2I_TerminatePriorContractSched(String guid) {
        logBuffer = new L2I_LoggingStringBuffer();
        oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(guid);
        logGuid = guid;
    }
    
    public void execute(SchedulableContext sc) {
        System.debug('*** Starting L2I_TerminatePriorContractSched');
        try {
            oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(logGuid);
            oaeLog.Step7_Status__c = 'Started';
            oaeLog.Step7_Entry_Time__c = Datetime.now();
            L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
            
            Integer batchSize = Integer.valueOf([SELECT Order_Activation_Batch_Size__c FROM L2I_General_Settings__mdt LIMIT 1].Order_Activation_Batch_Size__c);
            Database.executeBatch(new L2I_TerminatePriorContractBatch(oaeLog.GUID__c), batchSize);
        } catch (Exception e) {
            oaeLog.Step7_Status__c = 'Encountered Exception';
            logBuffer.append('Exception Error Message :\n' + e.getMessage());
        }
        
        oaeLog.Step7_Exit_Time__c = Datetime.now();
        
        String logTrace = oaeLog.Step7_Log_Message__c + '\n' + logBuffer.toStr();
        if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
            logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
        }
        oaeLog.Step7_Log_Message__c = logTrace;
        L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
//
//        //
//        // call the next steps
//        //
//        Datetime now = System.now();
//        Integer minsOffset = 1; // Schedule it a minute after the final batch has been completed.
//        String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
//        String jobId;
//
//        // AutoComplete Cases
//        L2I_AutoCompleteCasesSched step8 = new L2I_AutoCompleteCasesSched(logGuid);
//        if (!Test.isRunningTest()) {
//            jobId = System.schedule('AutoExtend Step8 ' + logGuid, cronTab, step8);
//            System.debug('AutoExtend Step 8 ' + logGuid + ' has been scheduled as :' + jobId);
//        }
    }
}