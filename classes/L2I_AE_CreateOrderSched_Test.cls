@IsTest
private class L2I_AE_CreateOrderSched_Test {

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
        ord.OpportunityId = salesOppty.Id;
        update ord;
        System.debug('*** ord ' + ord);
        SBQQ__Quote__c q1 = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
              LIMIT 1
        ];
        q1.SBQQ__StartDate__c = Date.today().addDays(-3);
        q1.SBQQ__SubscriptionTerm__c = 12;
        q1.SBQQ__EndDate__c = q1.SBQQ__StartDate__c.addMonths(12);
        update q1;
        System.debug('*** q1 ' + q1);
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
        System.debug('*** ctr ' + ctr);
        ctr.Status = 'Activated';
        ctr.L2I_Auto_Extend__c = Date.today().addDays(1);
        ctr.ContractTerm = 12;
        ctr.SBQQ__RenewalTerm__c = 12;
        update ctr;
        SBQQ__Quote__c renewedQuote;
        try {
            String testInput = '{"masterContractId": "' + ctr.Id + '", "renewedContracts": [{"attributes":{"type":"Contract"},"Id":"' + ctr.Id + '"}]}';
            L2I_ContractRenewer renewer = new L2I_ContractRenewer();
            L2I_QuoteModel[] quoteModels = renewer.load(null, testInput);
            System.debug('*** quoteModels ' + quoteModels);
            for (L2I_QuoteModel model : quoteModels) {
                System.debug('*** model ' + model);
                renewedQuote = model.record;
            }
        } catch (Exception e) {
            System.debug('*** exception ' + e.getMessage());
        }
        if (renewedQuote != null) {
            renewedQuote.ApprovalStatus__c = 'Approved';
            update renewedQuote;
            Id renewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            Id renewOppId = renewedQuote.SBQQ__Opportunity2__c;
            Opportunity renewOpp = [
                  SELECT Id, L2I_AutoExtend__c, StageName, CloseDate, L2I_Parent_Opportunity__c,
                        L2I_Product_Category__c, L2I_Delivery_Schedule__c
                  FROM Opportunity
                  WHERE Id = :renewOppId
            ];
            renewOpp.L2I_AutoExtend__c = true;
            renewOpp.StageName = 'Closed Won';
            renewOpp.CloseDate = Date.today();
            renewOpp.L2I_Parent_Opportunity__c = dealOppty.Id;
            renewOpp.L2I_Product_Category__c = 'DSS';
            renewOpp.SBQQ__RenewedContract__c = ctr.Id;
            renewOpp.RecordTypeId = renewId;
            renewOpp.L2I_Delivery_Schedule__c = dsh.Id;
            update renewOpp;
            System.debug('*** renewOpp ' + renewOpp);
            // START W-004060
            List<SBQQ__QuoteLine__c> qlLIst = new List<SBQQ__QuoteLine__c>();
            for (SBQQ__QuoteLine__c ql : [SELECT Id, SBQQ__Quantity__c, SBQQ__SpecialPrice__c, SBQQ__Product__c 
                                            FROM SBQQ__QuoteLine__c 
                                           WHERE SBQQ__Quote__c =: q1.Id]) {
                SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(renewedQuote.Id, ql.SBQQ__Product__c, null);
                quoteLine.SBQQ__Quantity__c = ql.SBQQ__Quantity__c;
                quoteLine.SBQQ__SpecialPrice__c = ql.SBQQ__SpecialPrice__c;
                qlLIst.add(quoteLine);
            }
            System.debug('*** qlLIst ' + qlLIst);
            insert qlLIst;
            // END W-004060
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
            Database.executeBatch(new L2I_AE_CreateOrderBatch(oaeLog.GUID__c), 1);
        }
        Test.stopTest();
        
        System.assertEquals(1, [
              SELECT COUNT()
              FROM SBQQ__Quote__c
              WHERE SBQQ__Opportunity2__r.RecordType.DeveloperName = 'Renewal'
              AND SBQQ__Ordered__c = true
        ]);
    }
    
    @IsTest
    static void testSched() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        ord.EffectiveDate = Date.today().addDays(-3);
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :ord.OpportunityId];
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
        
        Id renewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Opportunity renewOpp = new Opportunity(
              Name = 'ReviseOpp',
              L2I_AutoExtend__c = true,
              StageName = 'Closed Won',
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
        L2I_AE_CreateOrderSched ae = new L2I_AE_CreateOrderSched(oaeLog.GUID__c);
        // It does not matter what CRON expression we use here as this is a Test method and
        // therefore the job will execute immediately after Test.stopTest().
        String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, 1, 0);
        String jobId = System.schedule('Test AE Create Order', cronTab, ae);
        Test.stopTest();
    }
    
    @IsTest
    static void testAlert() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        ord.EffectiveDate = Date.today().addDays(-3);
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :ord.OpportunityId];
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
        
        Id renewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Opportunity renewOpp = new Opportunity(
              Name = 'ReviseOpp',
              L2I_AutoExtend__c = true,
              StageName = 'Closed Won',
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
        
        Set<Id> quoteIds = new Set<Id>();
        quoteIds.add(q.Id);
        L2I_AE_CreateOrderBatch ab = new L2I_AE_CreateOrderBatch();
        ab.setException('Testing', quoteIds);
        Test.stopTest();
    
        System.assertEquals(1, [SELECT COUNT() FROM L2I_System_Alert__c]);
    }
}