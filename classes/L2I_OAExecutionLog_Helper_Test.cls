/**
 *      @author       Raj Rajen
 *      @date         08/17/2019
 *      @description  Test Class L2I Order Activation Execution Log Tester
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/17/2019            Initial Setup
 *
 */
@isTest(SeeAllData=false)
public class L2I_OAExecutionLog_Helper_Test {

    @isTest
    static void test_log_creation_and_update() {
        L2I_Order_Activation_Execution_Log__c logEntry = L2I_OAExecutionLog_Helper.createLogEntry();
        System.assert(logEntry.Id != null, 'Log Entry Id cannot be null');
        System.assert(logEntry.GUID__c != null, 'Log Entry GUID cannot be null');

        String guid = L2I_OAExecutionLog_Helper.getGUID(logEntry);
        System.assert(guid.equals(logEntry.GUID__c), 'GUIDs must match');

        L2I_Order_Activation_Execution_Log__c entry = L2I_OAExecutionLog_Helper.getLogEntry(guid);
        entry.Step1_Status__c = 'Started';
        entry.Step1_Entry_Time__c = Datetime.now();
        entry.Step1_Log_Message__c = 'Processing Aircraft Service Records';

        L2I_OAExecutionLog_Helper.updateLogEntry(entry);
    }

}