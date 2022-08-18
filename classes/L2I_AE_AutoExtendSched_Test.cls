@IsTest
private class L2I_AE_AutoExtendSched_Test {
//    @IsTest
//    static void testBatchActiveContract() {
//        L2I_DataFactory factory = new L2I_DataFactory();
//        factory.setupAccountThruOrder(null, null, false, 'Activated');
//
//        Test.startTest();
//        Account acct = [SELECT Id FROM Account LIMIT 1];
//        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
//        ord.EffectiveDate = Date.today().addDays(-3);
//        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :ord.OpportunityId];
//        SBQQ__Quote__c q = [
//              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
//              FROM SBQQ__Quote__c
//              WHERE SBQQ__Opportunity2__c = :oppty.Id
//              LIMIT 1
//        ];
//        q.SBQQ__StartDate__c = Date.today().addDays(-3);
//        q.SBQQ__SubscriptionTerm__c = 12;
//        q.SBQQ__EndDate__c = q.SBQQ__StartDate__c.addMonths(12);
//        update q;
//
//        // create Contract
//        Contract ctr = new Contract(
//              AccountId = acct.Id,
//              SBQQ__Order__c = ord.Id,
//              SBQQ__Opportunity__c = oppty.Id,
//              SBQQ__Quote__c = q.Id,
//              Status = 'Draft',
//              Pricebook2Id = Test.getStandardPricebookId(),
//              CurrencyIsoCode = 'USD',
//              ContractTerm = 24,
//              StartDate = Date.today().addMonths(3),
//              SBQQ__PreserveBundleStructureUponRenewals__c = true,
//              SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
//              SBQQ__DefaultRenewalPartners__c = true,
//              SBQQ__DefaultRenewalContactRoles__c = true
//        );
//        insert ctr;
//
//        ctr.Status = 'Activated';
//        ctr.L2I_Auto_Extend__c = Date.today().addDays(1);
//        ctr.ContractTerm = 12;
//        ctr.SBQQ__RenewalTerm__c = 12;
//        update ctr;
//
//        List<OrderItem> oiList = new List<OrderItem>();
//        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
//            oi.ServiceDate = Date.Today();
//            oiList.add(oi);
//        }
//        update oiList;
//
//        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
//        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
//            SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
//            obj.SBQQ__Account__c = acct.Id;
//            obj.SBQQ__Product__c = oi.Product2Id;
//            obj.SBQQ__Contract__c = ctr.Id;
//            obj.SBQQ__Quantity__c = 10.00;
//            obj.SBQQ__ProductSubscriptionType__c = 'Renewable';
//            obj.SBQQ__SubscriptionType__c = 'Renewable';
//            obj.SBQQ__OrderProduct__c = oi.Id;
//            obj.L2I_blng_MatchingId__c = oi.L2I_blng_MatchingId__c;
//            subList.add(obj);
//        }
//        insert subList;
//
//        L2I_Order_Activation_Execution_Log__c oaeLog = L2I_OAExecutionLog_Helper.createLogEntry('AutoExtend Part 1 of 2');
//        Database.executeBatch(new L2I_AE_CreateOppQuoteBatch(oaeLog.GUID__c), 1);
//        Test.stopTest();
//
//        System.assertEquals(true, [SELECT Id, SBQQ__RenewalQuoted__c FROM Contract LIMIT 1].SBQQ__RenewalQuoted__c);
//        System.assertNotEquals(null, [SELECT Id, L2I_Last_Auto_Extend_Processed__c FROM Contract LIMIT 1].L2I_Last_Auto_Extend_Processed__c);
//        List<Opportunity> oppRenewedList = [
//              SELECT Id, SBQQ__RenewedContract__c, SBQQ__PrimaryQuote__c
//              FROM Opportunity
//              WHERE SBQQ__RenewedContract__c = :ctr.Id
//              AND SBQQ__PrimaryQuote__c != NULL
//        ];
//        System.assertEquals(1, oppRenewedList.size());
//        System.assertNotEquals(null, oppRenewedList[0].SBQQ__PrimaryQuote__c);
//    }
//
//    @IsTest
//    static void testBatchContractAlert() {
//        L2I_DataFactory factory = new L2I_DataFactory();
//        factory.setupAccountThruOrder(null, null, false, 'Activated');
//
//        Test.startTest();
//        Account acct = [SELECT Id FROM Account LIMIT 1];
//        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
//        ord.EffectiveDate = Date.today().addDays(-3);
//        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :ord.OpportunityId];
//        SBQQ__Quote__c q = [
//              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
//              FROM SBQQ__Quote__c
//              WHERE SBQQ__Opportunity2__c = :oppty.Id
//              LIMIT 1
//        ];
//        q.SBQQ__StartDate__c = Date.today().addDays(-3);
//        q.SBQQ__SubscriptionTerm__c = 12;
//        q.SBQQ__EndDate__c = q.SBQQ__StartDate__c.addMonths(12);
//        update q;
//
//        // create Contract
//        Contract ctr = new Contract(
//              AccountId = acct.Id,
//              SBQQ__Order__c = ord.Id,
//              SBQQ__Opportunity__c = oppty.Id,
//              SBQQ__Quote__c = q.Id,
//              Status = 'Draft',
//              Pricebook2Id = Test.getStandardPricebookId(),
//              CurrencyIsoCode = 'USD',
//              ContractTerm = 24,
//              StartDate = Date.today().addMonths(3),
//              SBQQ__PreserveBundleStructureUponRenewals__c = true,
//              SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
//              SBQQ__DefaultRenewalPartners__c = true,
//              SBQQ__DefaultRenewalContactRoles__c = true
//        );
//        insert ctr;
//        ctr.Status = 'Activated';
//        ctr.L2I_Auto_Extend__c = Date.today().addDays(1);
//        ctr.ContractTerm = 12;
//        ctr.SBQQ__RenewalTerm__c = 12;
//        update ctr;
//
//        List<OrderItem> oiList = new List<OrderItem>();
//        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
//            oi.ServiceDate = Date.Today();
//            oiList.add(oi);
//        }
//        update oiList;
//
//        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
//        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
//            SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
//            obj.SBQQ__Account__c = acct.Id;
//            obj.SBQQ__Product__c = oi.Product2Id;
//            obj.SBQQ__Contract__c = ctr.Id;
//            obj.SBQQ__Quantity__c = 10.00;
//            obj.SBQQ__ProductSubscriptionType__c = 'Renewable';
//            obj.SBQQ__SubscriptionType__c = 'Renewable';
//            obj.SBQQ__OrderProduct__c = oi.Id;
//            obj.L2I_blng_MatchingId__c = oi.L2I_blng_MatchingId__c;
//            subList.add(obj);
//        }
//        insert subList;
//
//        Set<Id> contractIds = new Set<Id>();
//        contractIds.add(ctr.Id);
//        L2I_AE_CreateOppQuoteBatch ab = new L2I_AE_CreateOppQuoteBatch();
//        ab.setException('Testing', contractIds);
//        Test.stopTest();
//
//        System.assertEquals(1, [SELECT COUNT() FROM L2I_System_Alert__c]);
//    }
//
    @IsTest
    static void testSched() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        ord.EffectiveDate = Date.today().addDays(-3);
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :ord.OpportunityId];
        SBQQ__Quote__c q = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
              WHERE SBQQ__Opportunity2__c = :oppty.Id
              LIMIT 1
        ];
        q.SBQQ__StartDate__c = Date.today().addDays(-3);
        q.SBQQ__SubscriptionTerm__c = 12;
        q.SBQQ__EndDate__c = q.SBQQ__StartDate__c.addMonths(12);
        update q;
    
        // create Contract
        Contract ctr = new Contract(
              AccountId = acct.Id,
              SBQQ__Order__c = ord.Id,
              SBQQ__Opportunity__c = oppty.Id,
              SBQQ__Quote__c = q.Id,
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              CurrencyIsoCode = 'USD',
              ContractTerm = 24,
              StartDate = Date.today().addMonths(3),
              SBQQ__PreserveBundleStructureUponRenewals__c = true,
              SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
              SBQQ__DefaultRenewalPartners__c = true,
              SBQQ__DefaultRenewalContactRoles__c = true
        );
        insert ctr;
        ctr.Status = 'Activated';
        ctr.L2I_Auto_Extend__c = Date.today().addDays(1);
        ctr.ContractTerm = 12;
        ctr.SBQQ__RenewalTerm__c = 12;
        update ctr;
    
        List<OrderItem> oiList = new List<OrderItem>();
        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
            oi.ServiceDate = Date.Today();
            oiList.add(oi);
        }
        update oiList;
    
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
            SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
            obj.SBQQ__Account__c = acct.Id;
            obj.SBQQ__Product__c = oi.Product2Id;
            obj.SBQQ__Contract__c = ctr.Id;
            obj.SBQQ__Quantity__c = 10.00;
            obj.SBQQ__ProductSubscriptionType__c = 'Renewable';
            obj.SBQQ__SubscriptionType__c = 'Renewable';
            obj.SBQQ__OrderProduct__c = oi.Id;
            obj.L2I_blng_MatchingId__c = oi.L2I_blng_MatchingId__c;
            subList.add(obj);
        }
        insert subList;
        
        L2I_Order_Activation_Execution_Log__c oaeLog = L2I_OAExecutionLog_Helper.createLogEntry('AutoExtend Part 1 of 2');

        Datetime now = Datetime.now();
        L2I_AE_AutoExtendSched ae = new L2I_AE_AutoExtendSched();
        // It does not matter what CRON expression we use here as this is a Test method and
        // therefore the job will execute immediately after Test.stopTest().
        String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, 1, 0);
        String jobId = System.schedule('Test AE Create Opportunity and Quote', cronTab, ae);

        Test.stopTest();
    }
    
    @IsTest
    static void testBatchPendingOpp() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOpp = [SELECT Id FROm Opportunity WHERE RecordType.DeveloperName = 'Deal'];
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        Date termDate = ord.EffectiveDate.addDays(-1);
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :ord.OpportunityId];
        SBQQ__Quote__c q = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
              WHERE SBQQ__Opportunity2__c = :oppty.Id
              LIMIT 1
        ];
        q.SBQQ__StartDate__c = Date.today().addDays(-3);
        q.SBQQ__SubscriptionTerm__c = 12;
        q.SBQQ__EndDate__c = q.SBQQ__StartDate__c.addMonths(12);
        update q;
        // create Contract
        Contract ctr = new Contract(
              AccountId = acct.Id,
              SBQQ__Order__c = ord.Id,
              SBQQ__Opportunity__c = oppty.Id,
              SBQQ__Quote__c = q.Id,
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              CurrencyIsoCode = 'USD',
              ContractTerm = 24,
              StartDate = Date.today().addMonths(3),
              SBQQ__PreserveBundleStructureUponRenewals__c = true,
              SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
              SBQQ__DefaultRenewalPartners__c = true,
              SBQQ__DefaultRenewalContactRoles__c = true
        );
        insert ctr;
        ctr.Status = 'Activated';
        ctr.L2I_Auto_Extend__c = Date.today().addDays(1);
        ctr.ContractTerm = 12;
        ctr.SBQQ__RenewalTerm__c = 12;
        update ctr;
        
        Opportunity oppPending = factory.createSalesOpportunity('PendOpp', 'Quotation', 5, acct.Id, dealOpp.Id);
        oppPending.SBQQ__AmendedContract__c = ctr.Id;
        insert oppPending;
        
        List<OrderItem> oiList = new List<OrderItem>();
        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
            oi.ServiceDate = Date.Today();
            oiList.add(oi);
        }
        update oiList;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
            SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
            obj.SBQQ__Account__c = acct.Id;
            obj.SBQQ__Product__c = oi.Product2Id;
            obj.SBQQ__Contract__c = ctr.Id;
            obj.SBQQ__Quantity__c = 10.00;
            obj.SBQQ__ProductSubscriptionType__c = 'Renewable';
            obj.SBQQ__SubscriptionType__c = 'Renewable';
            obj.SBQQ__OrderProduct__c = oi.Id;
            obj.L2I_blng_MatchingId__c = oi.L2I_blng_MatchingId__c;
            subList.add(obj);
        }
        insert subList;
        
        L2I_Order_Activation_Execution_Log__c oaeLog = L2I_OAExecutionLog_Helper.createLogEntry('AutoExtend Part 1 of 2');
        Database.executeBatch(new L2I_AE_CreateOppQuoteBatch(oaeLog.GUID__c), 100);
        
        
        List<Opportunity> oppRenewedList = [
              SELECT Id, SBQQ__RenewedContract__c, SBQQ__PrimaryQuote__c
              FROM Opportunity
              WHERE SBQQ__RenewedContract__c = :ctr.Id
              AND SBQQ__PrimaryQuote__c != NULL
        ];
        System.assertEquals(0, oppRenewedList.size());
        Test.stopTest();
    
    }
}