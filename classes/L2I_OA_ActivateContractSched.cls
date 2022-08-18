/**
 *      @author       Sarah Kennedy
 *      @date         06/25/2020
 *      @description  L2I_OA_ActivateContractSched - Scheduled job calls batch to Activate Contracts
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/25/2020         Initial scaffold
 *
 */
global class L2I_OA_ActivateContractSched implements Schedulable {
    private L2I_LoggingStringBuffer logBuffer;
    private String logGuid;
    private L2I_Order_Activation_Execution_Log__c oaeLog;
    
    public L2I_OA_ActivateContractSched(String guid) {
        logBuffer = new L2I_LoggingStringBuffer();
        oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(guid);
        logGuid = guid;
    }
    
    public void execute(SchedulableContext sc) {
        System.debug('*** Starting L2I_OA_ActivateContractSched');
    
        oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(logGuid);
        oaeLog.Step6_Status__c = 'Started';
        oaeLog.Step6_Entry_Time__c = Datetime.now();
        L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
        
        try {
            Integer batchSize = Integer.valueOf([SELECT Order_Activation_Batch_Size__c FROM L2I_General_Settings__mdt LIMIT 1].Order_Activation_Batch_Size__c);
            Database.executeBatch(new L2I_OA_ActivateContractBatch(logGuid), batchSize);
        } catch (Exception e) {
            oaeLog.Step6_Status__c = 'Encountered Exception';
            logBuffer.append('Exception Error Message :\n' + e.getMessage());
        }
    
        oaeLog.Step6_Exit_Time__c = Datetime.now();
    
        String logTrace = oaeLog.Step6_Log_Message__c + '\n' + logBuffer.toStr();
        if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
            logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
        }
        oaeLog.Step6_Log_Message__c = logTrace;
        L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
        
        // remove all completed schedule jobs
//        L2I_UtilityHelper.publishOrderActivationCompletedEvent(String.valueOf(logGuid));
    
//        //
//        // call the next steps
//        //
//        Datetime now = System.now();
//        Integer minsOffset = 1; // Schedule it a minute after the final batch has been completed.
//        String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
//        String jobId;
//
//        // terminate prior contracts
//        L2I_TerminatePriorContractSched step7 = new L2I_TerminatePriorContractSched(logGuid);
//        if (!Test.isRunningTest()) {
//            jobId = System.schedule('AutoExtend Step7 ' + logGuid, cronTab, step7);
//            System.debug('AutoExtend Step 7 ' + logGuid + ' has been scheduled as :' + jobId);
//        }

    }
}