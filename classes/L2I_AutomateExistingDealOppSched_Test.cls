@isTest
public class L2I_AutomateExistingDealOppSched_Test {
    public static String CRON_EXP = '0 10 * * * ?';
    
    @isTest static void AutomateExistingDealOppSchedPositive() {
        
        Test.startTest();        
        String jobId = System.schedule('AutomateExistingDealOppSched',CRON_EXP, new L2I_AutomateExistingDealOppSched());
        Test.stopTest();
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
    }
}