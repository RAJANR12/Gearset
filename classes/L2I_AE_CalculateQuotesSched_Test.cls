@IsTest
private class L2I_AE_CalculateQuotesSched_Test {
    @IsTest
    static void testBatch() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        ord.EffectiveDate = Date.today().addDays(-3);
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :ord.OpportunityId];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal'];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
    
        SBQQ__Quote__c q1 = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
              WHERE SBQQ__Opportunity2__c = :oppty.Id
              LIMIT 1
        ];
        q1.SBQQ__StartDate__c = Date.today().addDays(-3);
        q1.SBQQ__SubscriptionTerm__c = 12;
        q1.SBQQ__EndDate__c = q1.SBQQ__StartDate__c.addMonths(12);
        update q1;
    
        // create Contract
        Contract ctr = new Contract(
              AccountId = acct.Id,
              SBQQ__Order__c = ord.Id,
              SBQQ__Opportunity__c = oppty.Id,
              SBQQ__Quote__c = q1.Id,
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
        
        Id renewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Opportunity renewOpp = new Opportunity(
              Name = 'ReviseOpp',
              L2I_AutoExtend__c = true,
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Product_Category__c = 'DSS',
              SBQQ__RenewedContract__c = ctr.Id,
              RecordTypeId = renewId,
              L2I_Delivery_Schedule__c = dsh.Id);
        insert renewOpp;
        
        SBQQ__Quote__c q = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
              LIMIT 1
        ];
        q.SBQQ__Opportunity2__c = renewOpp.Id;
        q.SBQQ__StartDate__c = Date.today().addDays(-3);
        q.SBQQ__SubscriptionTerm__c = 12;
        q.SBQQ__EndDate__c = q.SBQQ__StartDate__c.addMonths(12);
        q.SBQQ__Ordered__c = false;
        q.ApprovalStatus__c = 'Approved';
        update q;
        
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
        Database.executeBatch(new L2I_AE_CalculateQuoteBatch(oaeLog.GUID__c), 100);
        Test.stopTest();
        
        System.assertNotEquals(0, [SELECT Id, Amount FROM Opportunity WHERE Id = :renewOpp.Id].Amount);
    }
    
    @IsTest
    static void testAlert() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        ord.EffectiveDate = Date.today().addDays(-3);
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :ord.OpportunityId];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal'];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        SBQQ__Quote__c q1 = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
              WHERE SBQQ__Opportunity2__c = :oppty.Id
              LIMIT 1
        ];
        q1.SBQQ__StartDate__c = Date.today().addDays(-3);
        q1.SBQQ__SubscriptionTerm__c = 12;
        q1.SBQQ__EndDate__c = q1.SBQQ__StartDate__c.addMonths(12);
        update q1;
        // create Contract
        Contract ctr = new Contract(
              AccountId = acct.Id,
              SBQQ__Order__c = ord.Id,
              SBQQ__Opportunity__c = oppty.Id,
              SBQQ__Quote__c = q1.Id,
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
        
        Id renewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Opportunity renewOpp = new Opportunity(
              Name = 'ReviseOpp',
              L2I_AutoExtend__c = true,
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Product_Category__c = 'DSS',
              SBQQ__RenewedContract__c = ctr.Id,
              RecordTypeId = renewId,
              L2I_Delivery_Schedule__c = dsh.Id);
        insert renewOpp;
        System.debug('*** 1 renewOpp.L2I_Fit_Type__c ' + renewOpp.L2I_Fit_Type__c );
        
        SBQQ__Quote__c q = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
              LIMIT 1
        ];
        q.SBQQ__Opportunity2__c = renewOpp.Id;
        q.SBQQ__StartDate__c = Date.today().addDays(-3);
        q.SBQQ__SubscriptionTerm__c = 12;
        q.SBQQ__EndDate__c = q.SBQQ__StartDate__c.addMonths(12);
        q.SBQQ__Ordered__c = false;
        q.ApprovalStatus__c = 'Approved';
        update q;
        
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
    
        Set<Id> quoteIds = new Set<Id>();
        quoteIds.add(q.Id);
        L2I_AE_CalculateQuoteBatch ab = new L2I_AE_CalculateQuoteBatch();
        ab.setException('Testing', quoteIds);
        Test.stopTest();
    
        System.assertEquals(1, [SELECT COUNT() FROM L2I_System_Alert__c]);
    }
    
    @IsTest
    static void testSched() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        ord.EffectiveDate = Date.today().addDays(-3);
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :ord.OpportunityId];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal'];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        SBQQ__Quote__c q1 = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
              WHERE SBQQ__Opportunity2__c = :oppty.Id
              LIMIT 1
        ];
        q1.SBQQ__StartDate__c = Date.today().addDays(-3);
        q1.SBQQ__SubscriptionTerm__c = 12;
        q1.SBQQ__EndDate__c = q1.SBQQ__StartDate__c.addMonths(12);
        update q1;
    
        // create Contract
        Contract ctr = new Contract(
              AccountId = acct.Id,
              SBQQ__Order__c = ord.Id,
              SBQQ__Opportunity__c = oppty.Id,
              SBQQ__Quote__c = q1.Id,
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
        
        Id renewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Opportunity renewOpp = new Opportunity(
              Name = 'ReviseOpp',
              L2I_AutoExtend__c = true,
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Product_Category__c = 'DSS',
              SBQQ__RenewedContract__c = ctr.Id,
              RecordTypeId = renewId,
              L2I_Delivery_Schedule__c = dsh.Id);
        insert renewOpp;
        
        SBQQ__Quote__c q = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
              LIMIT 1
        ];
        q.SBQQ__Opportunity2__c = renewOpp.Id;
        q.SBQQ__StartDate__c = Date.today().addDays(-3);
        q.SBQQ__SubscriptionTerm__c = 12;
        q.SBQQ__EndDate__c = q.SBQQ__StartDate__c.addMonths(12);
        q.SBQQ__Ordered__c = false;
        q.ApprovalStatus__c = 'Approved';
        update q;

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
        L2I_AE_CalculateQuoteSched ae = new L2I_AE_CalculateQuoteSched(oaeLog.GUID__c);
        // It does not matter what CRON expression we use here as this is a Test method and
        // therefore the job will execute immediately after Test.stopTest().
        String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, 1, 0);
        String jobId = System.schedule('Test AE PrepareQuote', cronTab, ae);
    
        Test.stopTest();
    }
}