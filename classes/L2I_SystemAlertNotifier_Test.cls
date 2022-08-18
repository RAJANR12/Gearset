/**
 *      @author       Raj Rajen
 *      @date         08/18/2019
 *      @description  Test class for System Alert Notifier
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/18/2019         Initial setup of tests
 *
 */
@IsTest(SeeAllData=false)
public class L2I_SystemAlertNotifier_Test {

    @IsTest
    static void test_generate_system_alert() {
        L2I_SystemAlertNotifier.createSystemAlert('Other', 'Just Testing...');
        // Nothing really to assert here, as everything about System Alert Notifications is happening in the background
    }
    
    @IsTest
    static void test_generate_system_alert2() {
        Test.startTest();
        Id systemAlertId = L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
              'DML Exception occurred while setting setting Contracts as Activated:',
              'Contract', null, UserInfo.getUserId(), true);
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM L2I_System_Alert__c]);
    }
    
}