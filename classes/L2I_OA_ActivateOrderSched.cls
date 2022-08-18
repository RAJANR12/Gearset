/**
 *      @author       Sarah Kennedy
 *      @date         06/25/2020
 *      @description  L2I_OA_ActivateOrderSched - Activate Orders
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/25/2020         Initial scaffold
 *
 */
global class L2I_OA_ActivateOrderSched implements Schedulable {
    private L2I_LoggingStringBuffer logBuffer;
    private String logGuid;
    private L2I_Order_Activation_Execution_Log__c oaeLog;
    
    public L2I_OA_ActivateOrderSched(String guid) {
        logBuffer = new L2I_LoggingStringBuffer();
        oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(guid);
        logGuid = guid;
    }
    
    public void execute(SchedulableContext sc) {
        System.debug('*** Starting L2I_OA_ActivateOrderSched');
        oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(logGuid);
        oaeLog.Step4_Status__c = 'Started';
        oaeLog.Step4_Entry_Time__c = Datetime.now();
        L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
        
        try {
            Integer batchSize = Integer.valueOf([select Order_Activation_Batch_Size__c from L2I_General_Settings__mdt limit 1].Order_Activation_Batch_Size__c);
            Database.executeBatch(new L2I_OA_ActivateOrderBatch(logGuid), batchSize);
        } catch (Exception e) {
            oaeLog.Step4_Status__c = 'Encountered Exception';
            logBuffer.append('Exception Error Message :\n' + e.getMessage());
        }
    
        oaeLog.Step4_Exit_Time__c = Datetime.now();
    
        String logTrace = oaeLog.Step4_Log_Message__c + '\n' + logBuffer.toStr();
        if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
            logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
        }
        oaeLog.Step4_Log_Message__c = logTrace;
        L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
        
//        //
//        // call the next steps
//        //
//        Datetime now = System.now();
//        Integer minsOffset = 1; // Schedule it a minute after the final batch has been completed.
//        String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
//        String jobId;
//
//        // Create Contracts
//
//        L2I_OA_CreateContractSched step5 = new L2I_OA_CreateContractSched(logGuid);
//        if (!Test.isRunningTest()) {
//            jobId = System.schedule('AutoExtend Step5 ' + logGuid, cronTab, step5);
//        }
//        System.debug('AutoExtend Step 5 ' + logGuid + ' has been scheduled as :' + jobId);
    }
}