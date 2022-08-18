/**
 *      @author       Sarah Kennedy
 *      @date         06/25/2020
 *      @description  L2I_AE_AutoExtendSched - Starting Schedule for the AutoExtend automated process
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/25/2020         Initial scaffold
 *
 */
global class L2I_AE_AutoExtendSched implements Schedulable {
    private L2I_LoggingStringBuffer logBuffer = new L2I_LoggingStringBuffer();
    private L2I_Order_Activation_Execution_Log__c oaeLog;
    
    public void execute(SchedulableContext sc) {
        System.debug('*** Starting L2I_AE_AutoExtendSched');
        try {
// create the log
            oaeLog = L2I_OAExecutionLog_Helper.createLogEntry('AutoExtend');
            oaeLog.Step1_Name__c = 'AutoExtend Create Opportunity and Quote';
            oaeLog.Step2_Name__c = 'AutoExtend Prepare Quote';
            oaeLog.Step3_Name__c = 'AutoExtend Create Order';
            oaeLog.Step4_Name__c = 'AutoExtend Activate Order';
            oaeLog.Step5_Name__c = 'AutoExtend Create Contract';
            oaeLog.Step6_Name__c = 'AutoExtend Activate Contract';
            oaeLog.Step7_Name__c = 'Terminate Prior Contract';
            oaeLog.Step8_Name__c = 'AutoComplete Cases';
            oaeLog.Step1_Status__c = 'Started';
            oaeLog.Step1_Entry_Time__c = Datetime.now();
            oaeLog.Batch_Date__c = Date.today();
            oaeLog.Execution_Date__c = Date.today();
            L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
            
            Integer batchSize = Integer.valueOf([SELECT Order_Activation_Batch_Size__c FROM L2I_General_Settings__mdt LIMIT 1].Order_Activation_Batch_Size__c);
            logBuffer.append('AutoExtend Batch Size: ' + batchSize);
            Database.executeBatch(new L2I_AE_CreateOppQuoteBatch(oaeLog.GUID__c), batchSize);
        } catch (Exception e) {
            oaeLog.Step1_Status__c = 'Encountered Exception';
            logBuffer.append('Exception Error Message :\n' + e.getMessage());
        }
        
        oaeLog.Step1_Exit_Time__c = Datetime.now();
        
        String logTrace = oaeLog.Step1_Log_Message__c + '\n' + logBuffer.toStr();
        if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
            logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
        }
        oaeLog.Step1_Log_Message__c = logTrace;
        L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
        //
        // call the next step
        //
//        Datetime now = System.now();
//        Integer minsOffset = 1; // Schedule it a minute after the final batch has been completed.
//        String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
//
//        if (!Test.isRunningTest()) {
//            L2I_AE_PrepareQuoteSched step2 = new L2I_AE_PrepareQuoteSched(oaeLog.GUID__c);
//            String jobId = System.schedule('AutoExtend Step2 ' + oaeLog.GUID__c, cronTab, step2);
//            System.debug('AutoExtend Step 2 ' + oaeLog.GUID__c + ' has been scheduled as :' + jobId);
//        }
    }
}