/**
 *      @author       Sarah Kennedy
 *      @date         06/25/2020
 *      @description  L2I_AutoCompleteCasesSched - AutoComplete Cases
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/25/2020         Initial scaffold
 *
 */
global class L2I_AutoCompleteCasesSched implements Schedulable {
    private L2I_LoggingStringBuffer logBuffer;
    private String logGuid;
    private L2I_Order_Activation_Execution_Log__c oaeLog;
    
    public L2I_AutoCompleteCasesSched(String guid) {
        logBuffer = new L2I_LoggingStringBuffer();
        oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(guid);
        logGuid = guid;
    }
    
    public void execute(SchedulableContext sc) {
        System.debug('*** Starting L2I_AutoCompleteCasesSched');
        oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(logGuid);
        oaeLog.Step8_Status__c = 'Started';
        oaeLog.Step8_Entry_Time__c = Datetime.now();
        L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
        
        try {
            Integer batchSize = Integer.valueOf([select Order_Activation_Batch_Size__c from L2I_General_Settings__mdt limit 1].Order_Activation_Batch_Size__c);
            Database.executeBatch(new L2I_AutoCompleteCasesBatch(logGuid), batchSize);
        } catch (Exception e) {
            oaeLog.Step8_Status__c = 'Encountered Exception';
            logBuffer.append('Exception Error Message :\n' + e.getMessage());
        }
        
        oaeLog.Step8_Exit_Time__c = Datetime.now();
        
        String logTrace = oaeLog.Step8_Log_Message__c + '\n' + logBuffer.toStr();
        if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
            logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
        }
        oaeLog.Step8_Log_Message__c = logTrace;
        L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
        
//        // cleanup the jobs
//        System.debug('*** L2I_OA_ActivateContractSched calling Platform Event to clear jobs ' + oaeLog.GUID__c);
//        L2I_UtilityHelper.publishOrderActivationCompletedEvent(String.valueOf(oaeLog.GUID__c));
    }
}