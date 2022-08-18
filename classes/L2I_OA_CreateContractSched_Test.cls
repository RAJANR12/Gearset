@IsTest
private class L2I_OA_CreateContractSched_Test {
    @IsTest
    static void testAlert2() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
        
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Order ord = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        Set<Id> orderIds = new Set<Id>();
        orderIds.add(ord.Id);
        L2I_OA_CreateContractBatch ab = new L2I_OA_CreateContractBatch();
        ab.setException('Testing', orderIds);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM L2I_System_Alert__c]);
    }
    
    @IsTest
    static void testBatch2() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
        
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Order ord = [SELECT Id FROM Order LIMIT 1];
    
        Test.startTest();
        L2I_Order_Activation_Execution_Log__c oaeLog = L2I_OAExecutionLog_Helper.createLogEntry('AutoExtend Part 1 of 2');
        Database.executeBatch(new L2I_OA_CreateContractBatch(oaeLog.GUID__c), 1);
        Test.stopTest();
    
        System.assertEquals(true, [SELECT Id, SBQQ__Contracted__c FROM Order WHERE Id = :ord.Id].SBQQ__Contracted__c);
    }
    
    @IsTest
    static void testSched2() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Order ord = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        L2I_Order_Activation_Execution_Log__c oaeLog = L2I_OAExecutionLog_Helper.createLogEntry('AutoExtend Part 1 of 2');
        
        Datetime now = Datetime.now();
        L2I_OA_CreateContractSched ae = new L2I_OA_CreateContractSched(oaeLog.GUID__c);
        // It does not matter what CRON expression we use here as this is a Test method and
        // therefore the job will execute immediately after Test.stopTest().
        String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, 1, 0);
        String jobId = System.schedule('Test AE Create Contract', cronTab, ae);
        
        Test.stopTest();
    }
}