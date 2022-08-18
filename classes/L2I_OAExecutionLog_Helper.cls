/**
 *      @author       Raj Rajen
 *      @date         08/17/2019
 *      @description  Helper Class L2I Order Activation Execution Log
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/17/2019            Initial Setup
 *      Sarah Kennedy                 06/26/2020            US2046 expand to allow other types of logginf
 *
 */
public without sharing class L2I_OAExecutionLog_Helper {
    public static String logName = 'Order Activation';
    
    public L2I_OAExecutionLog_Helper() {
        this(logName);
    }
    
    public L2I_OAExecutionLog_Helper(String logName) {
        logName = logName;
    }
    
    public static L2I_Order_Activation_Execution_Log__c createLogEntry() {
        L2I_Order_Activation_Execution_Log__c oaeLog = createLogEntry(logName);
        return oaeLog;
    }
    
    public static L2I_Order_Activation_Execution_Log__c createLogEntry(String logName) {
        L2I_Order_Activation_Execution_Log__c log = new L2I_Order_Activation_Execution_Log__c();
        log.Step1_Log_Message__c = '';
        log.Step2_Log_Message__c = '';
        log.Step3_Log_Message__c = '';
        log.Step4_Log_Message__c = '';
        log.Step5_Log_Message__c = '';
        log.Step6_Log_Message__c = '';
        log.Step7_Log_Message__c = '';
        log.Step8_Log_Message__c = '';
        log.Log_Name__c = logName;
        insert log;
        
        L2I_Order_Activation_Execution_Log__c logEntry = [
              SELECT Id,
                    GUID__c,
                    Batch_Date__c,
                    Execution_Date__c,
                    Step1_Name__c,
                    Step2_Name__c,
                    Step3_Name__c,
                    Step4_Name__c,
                    Step5_Name__c,
                    Step6_Name__c,
                    Step7_Name__c,
                    Step8_Name__c,
                    Step1_Entry_Time__c,
                    Step1_Exit_Time__c,
                    Step1_Status__c,
                    Step1_Log_Message__c,
                    Step2_Entry_Time__c,
                    Step2_Exit_Time__c,
                    Step2_Status__c,
                    Step2_Log_Message__c,
                    Step3_Entry_Time__c,
                    Step3_Exit_Time__c,
                    Step3_Status__c,
                    Step3_Log_Message__c,
                    Step4_Entry_Time__c,
                    Step4_Exit_Time__c,
                    Step4_Status__c,
                    Step4_Log_Message__c,
                    Step5_Entry_Time__c,
                    Step5_Exit_Time__c,
                    Step5_Status__c,
                    Step5_Log_Message__c,
                    Step6_Entry_Time__c,
                    Step6_Exit_Time__c,
                    Step6_Status__c,
                    Step6_Log_Message__c,
                    Step7_Entry_Time__c,
                    Step7_Exit_Time__c,
                    Step7_Status__c,
                    Step7_Log_Message__c,
                    Step8_Entry_Time__c,
                    Step8_Exit_Time__c,
                    Step8_Status__c,
                    Step8_Log_Message__c,
                    Log_Name__c
              FROM L2I_Order_Activation_Execution_Log__c
              WHERE Id = :log.Id
              LIMIT 1
        ];
        return logEntry;
    }
    
    public static String getGUID(L2I_Order_Activation_Execution_Log__c logEntry) {
        return logEntry.GUID__c;
    }
    
    public static L2I_Order_Activation_Execution_Log__c getLogEntry(String guid) {
        
        L2I_Order_Activation_Execution_Log__c logEntry = [
              SELECT Id,
                    GUID__c,
                    Batch_Date__c,
                    Execution_Date__c,
                    Step1_Name__c,
                    Step2_Name__c,
                    Step3_Name__c,
                    Step4_Name__c,
                    Step5_Name__c,
                    Step6_Name__c,
                    Step7_Name__c,
                    Step8_Name__c,
                    Step1_Entry_Time__c,
                    Step1_Exit_Time__c,
                    Step1_Status__c,
                    Step1_Log_Message__c,
                    Step2_Entry_Time__c,
                    Step2_Exit_Time__c,
                    Step2_Status__c,
                    Step2_Log_Message__c,
                    Step3_Entry_Time__c,
                    Step3_Exit_Time__c,
                    Step3_Status__c,
                    Step3_Log_Message__c,
                    Step4_Entry_Time__c,
                    Step4_Exit_Time__c,
                    Step4_Status__c,
                    Step4_Log_Message__c,
                    Step5_Entry_Time__c,
                    Step5_Exit_Time__c,
                    Step5_Status__c,
                    Step5_Log_Message__c,
                    Step6_Entry_Time__c,
                    Step6_Exit_Time__c,
                    Step6_Status__c,
                    Step6_Log_Message__c,
                    Step7_Entry_Time__c,
                    Step7_Exit_Time__c,
                    Step7_Status__c,
                    Step7_Log_Message__c,
                    Step8_Entry_Time__c,
                    Step8_Exit_Time__c,
                    Step8_Status__c,
                    Step8_Log_Message__c,
                    Log_Name__c
              FROM L2I_Order_Activation_Execution_Log__c
              WHERE GUID__c = :guid
              ORDER BY CreatedDate DESC
              LIMIT 1
        ];
        return logEntry;
    }
    
    public static void updateLogEntry(L2I_Order_Activation_Execution_Log__c logEntry) {
        update logEntry;
    }

}