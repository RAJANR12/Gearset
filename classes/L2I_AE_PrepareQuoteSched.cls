/**
 *      @author       Sarah Kennedy
 *      @date         06/25/2020
 *      @description  L2I_AE_PrepareQuoteSched - AutoExtend Scheduled calls batch to perform TASM calcs and Activate the Quote
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/25/2020         Initial scaffold
 *
 */
global class L2I_AE_PrepareQuoteSched implements Schedulable {
    private L2I_LoggingStringBuffer logBuffer;
    private String logGuid;
    private L2I_Order_Activation_Execution_Log__c oaeLog;
    
    public L2I_AE_PrepareQuoteSched(String guid) {
        logBuffer = new L2I_LoggingStringBuffer();
        oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(guid);
        logGuid = guid;
    }
    
    public void execute(SchedulableContext sc) {
        System.debug('*** Starting L2I_AE_PrepareQuoteSched');
        try {
// create the log
            oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(logGuid);
            oaeLog.Step2_Status__c = 'Started';
            oaeLog.Step2_Entry_Time__c = Datetime.now();
            L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
            
            Integer batchSize = Integer.valueOf([SELECT Order_Activation_Batch_Size__c FROM L2I_General_Settings__mdt LIMIT 1].Order_Activation_Batch_Size__c);
            logBuffer.append('AutoExtend Batch Size: ' + batchSize);
            Database.executeBatch(new L2I_AE_PrepareQuoteBatch(logGuid), batchSize);
        } catch (Exception e) {
            oaeLog.Step2_Status__c = 'Encountered Exception';
            logBuffer.append('Exception Error Message :\n' + e.getMessage());
        }
        
        oaeLog.Step2_Exit_Time__c = Datetime.now();
    
        String logTrace = oaeLog.Step2_Log_Message__c + '\n' + logBuffer.toStr();
        if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
            logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
        }
        oaeLog.Step2_Log_Message__c = logTrace;
        L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
//        //
//        // call the next step
//        //
//        Datetime now = System.now();
//        Integer minsOffset = 1; // Schedule it a minute after the final batch has been completed.
//        String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
//        L2I_AE_CalculateQuoteSched step25 = new L2I_AE_CalculateQuoteSched(logGuid);
//        if (!Test.isRunningTest()) {
//            String jobId = System.schedule('AutoExtend Step2.5 ' + logGuid, cronTab, step25);
//            System.debug('AutoExtend Step 2.5 ' + logGuid + ' has been scheduled as :' + jobId);
//        }
    }
}