@IsTest
private class L2I_TerminatePriorContractSched_Test {
    @IsTest
    static void testBatch() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
              Name = 'TestSalesOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Product_Category__c = 'DSS',
              L2I_Fit_Type__c = 'Initial Sale',
              RecordTypeId = salesId);
        insert salesOppty;
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
//        ord.EffectiveDate = Date.today().addDays(-3);
        ord.OpportunityId = salesOppty.Id;
        update ord;
        SBQQ__Quote__c q1 = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
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
              SBQQ__Opportunity__c = salesOppty.Id,
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
        
        List<OrderItem> oiList = new List<OrderItem>();
        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate, Product2.SBQQ__PricingGuidance__c FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
            oi.ServiceDate = Date.Today();
            oiList.add(oi);
        }
        update oiList;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        List<OrderItem> ordItemList = new List<OrderItem>();
        ordItemList = [SELECT Id, Product2Id, L2I_blng_MatchingId__c, SBQQ__Subscription__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c];
        for (OrderItem oi : ordItemList) {
            SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
            obj.SBQQ__Account__c = acct.Id;
            obj.SBQQ__Product__c = oi.Product2Id;
            obj.SBQQ__Contract__c = ctr.Id;
            obj.SBQQ__Quantity__c = 10.00;
            obj.SBQQ__ProductSubscriptionType__c = 'Renewable';
            obj.SBQQ__SubscriptionType__c = 'Renewable';
            obj.SBQQ__OrderProduct__c = oi.Id;
            obj.L2I_ToBeTerminatedDate__c = Date.Today();
            obj.L2I_blng_MatchingId__c = oi.L2I_blng_MatchingId__c;
            subList.add(obj);
        }
        insert subList;
    
        ordItemList[0].SBQQ__Subscription__c = subList[0].Id;
        update ordItemList;
        
        L2I_Order_Activation_Execution_Log__c oaeLog = L2I_OAExecutionLog_Helper.createLogEntry('AutoExtend');
        Database.executeBatch(new L2I_TerminatePriorContractBatch(oaeLog.GUID__c), 1);
        Test.stopTest();
        
        System.assertEquals(true, [SELECT Id, L2I_Terminated__c FROM Order WHERE Id = :ord.Id].L2I_Terminated__c);
    }
    
    @IsTest
    static void testAlert() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
              Name = 'TestSalesOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Product_Category__c = 'DSS',
              L2I_Fit_Type__c = 'Initial Sale',
              RecordTypeId = salesId);
        insert salesOppty;
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
//        ord.EffectiveDate = Date.today().addDays(-3);
        ord.OpportunityId = salesOppty.Id;
        update ord;
        SBQQ__Quote__c q1 = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
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
              SBQQ__Opportunity__c = salesOppty.Id,
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
        
        List<OrderItem> oiList = new List<OrderItem>();
        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate, Product2.SBQQ__PricingGuidance__c FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
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
        
        Set<Id> contractIds = new Set<Id>();
        contractIds.add(ctr.Id);
        L2I_TerminatePriorContractBatch ab = new L2I_TerminatePriorContractBatch();
        ab.setException('Testing', contractIds);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM L2I_System_Alert__c]);
    }
    
    @IsTest
    static void testSched() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
              Name = 'TestSalesOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Product_Category__c = 'DSS',
              L2I_Fit_Type__c = 'Initial Sale',
              RecordTypeId = salesId);
        insert salesOppty;
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
//        ord.EffectiveDate = Date.today().addDays(-3);
        ord.OpportunityId = salesOppty.Id;
        update ord;
        SBQQ__Quote__c q1 = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
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
              SBQQ__Opportunity__c = salesOppty.Id,
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
        
        List<OrderItem> oiList = new List<OrderItem>();
        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate, Product2.SBQQ__PricingGuidance__c FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
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
        
        L2I_Order_Activation_Execution_Log__c oaeLog = L2I_OAExecutionLog_Helper.createLogEntry('AutoExtend');
        
        Datetime now = Datetime.now();
        L2I_TerminatePriorContractSched ae = new L2I_TerminatePriorContractSched(oaeLog.GUID__c);
        // It does not matter what CRON expression we use here as this is a Test method and
        // therefore the job will execute immediately after Test.stopTest().
        String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, 1, 0);
        String jobId = System.schedule('Test OA Terminate Prior Contract', cronTab, ae);
        
        Test.stopTest();
    }
}