@IsTest
private class L2I_OrderService_Test {
    @IsTest
    static void testActivatedOrderCheck() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
        
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        Opportunity salesOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Sales' LIMIT 1];
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        ord.L2I_Order_Process__c = 'Contract Management';
        ord.Type = 'Renewal';
        ord.Status = 'Activated';
        update ord;
        Date termDate = ord.EffectiveDate.addDays(-1);
    
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
        
        Opportunity oppty = [SELECT Id, SBQQ__RenewedContract__c FROM Opportunity WHERE Id = :ord.OpportunityId];
        oppty.SBQQ__RenewedContract__c = ctr.Id;
        update oppty;
        
        OrderItem oItem = [
              SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate, Order.Type, Order.Status, Order.OpportunityId, Order.Opportunity.SBQQ__RenewedContract__c, Order.L2I_Order_Process__c
              FROM OrderItem
              WHERE OrderId = :ctr.SBQQ__Order__c
              LIMIT 1
        ];
        oItem.ServiceDate = Date.Today();
        update oItem;
        System.debug('*** oItem.Order.Type ' + oItem.Order.Type);
        System.debug('*** oItem.Order.Status ' + oItem.Order.Status);
        System.debug('*** oItem.Order.OpportunityId ' + oItem.Order.OpportunityId);
        System.debug('*** oItem.Order.Opportunity.SBQQ__RenewedContract__c ' + oItem.Order.Opportunity.SBQQ__RenewedContract__c);
        System.debug('*** oItem.Order.L2I_Order_Process__c ' + oItem.Order.L2I_Order_Process__c);
        System.debug('*** oItem.L2I_blng_MatchingId__c ' + oItem.L2I_blng_MatchingId__c);
        
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
        
        oppty.SBQQ__RenewedContract__c = ctr.Id;
        update oppty;
        ord.Status = 'Activated';
        ord.Type = 'Renewal';
        ord.OpportunityId = oppty.Id;
        ord.EffectiveDate = Date.Today();
        update ord;
        
        L2I_OrderService.determineReviseModified(new Set<Id>{
              ord.Id
        });
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Order WHERE L2I_Revise_Modified__c = false]);
    }
    
    @IsTest
    static void testActivatedOrderNoCheck() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :ord.OpportunityId];

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
    
        Map<Id, String> prodCategoryMap = new Map<Id, String>();
        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();
        for (Product2 p : prodList) {
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }

        System.debug('*** orderitem ' + [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]);
        List<OrderItem> oiList = new List<OrderItem>();
        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
            oi.ServiceDate = Date.today().addDays(16);
            oi.L2I_blng_MatchingId__c = '1234567890';
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
        System.debug('*** sub enddate ' + [select SBQQ__EndDate__c from SBQQ__Subscription__c]);
        System.debug('*** oi startdate ' + [select servicedate from orderitem]);
        insert subList;
        System.debug('*** subList ' + subList);
        
        oppty.SBQQ__RenewedContract__c = ctr.Id;
        update oppty;
        ord.L2I_Order_Process__c = 'Contract Management';
        ord.Status = 'Activated';
        ord.Type = 'Renewal';
        ord.OpportunityId = oppty.Id;
        ord.EffectiveDate = Date.Today();
        update ord;
        L2I_OrderService.determineReviseModified(new Set<Id>{
              ord.Id
        });
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Order WHERE L2I_Revise_Modified__c = false]);
    }
    
    @IsTest
    static void testActivatedOrderNoMatch() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :ord.OpportunityId];
    
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
    
        Map<Id, String> prodCategoryMap = new Map<Id, String>();
        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();
        for (Product2 p : prodList) {
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }
    
        System.debug('*** orderitem ' + [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]);
        List<OrderItem> oiList = new List<OrderItem>();
        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
            oi.ServiceDate = Date.today().addDays(16);              
            oi.L2I_blng_MatchingId__c = '1234567890';
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
            obj.L2I_blng_MatchingId__c = '123456789';
            subList.add(obj);
        }
        System.debug('*** sub enddate ' + [select SBQQ__EndDate__c from SBQQ__Subscription__c]);
        System.debug('*** oi startdate ' + [select servicedate from orderitem]);
        insert subList;
        System.debug('*** subList ' + subList);
        
        oppty.SBQQ__RenewedContract__c = ctr.Id;
        update oppty;
        ord.L2I_Order_Process__c = 'Contract Management';
        ord.Status = 'Activated';
        ord.Type = 'Renewal';
        ord.OpportunityId = oppty.Id;
        ord.EffectiveDate = Date.Today();
        update ord;
        L2I_OrderService.determineReviseModified(new Set<Id>{
              ord.Id
        });
        Test.stopTest();
        
        System.assertEquals(0, [SELECT COUNT() FROM Order WHERE L2I_Revise_Modified__c = false]);
    }
    
    @IsTest
    static void testNoValidOrders() {
        L2I_OrderService.determineReviseModified(new Set<Id>());
    }
}