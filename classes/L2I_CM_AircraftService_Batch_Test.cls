@IsTest
private class L2I_CM_AircraftService_Batch_Test {
    
    private static L2I_DataFactory factory;
    private static List<SObject> products;
    private static List<PricebookEntry> pbEntries;
    private static List<Product2> prodList;
    private static Set<Id> prodIdList;
    private static Map<Id, PricebookEntry> peIdMap;
    private static Map<Id, String> prodCategoryMap;
//
//    @testSetup
//    static void testBehavior() {
    static void setupTestContext() {
        
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_Case_Mgmt_Order');
        
        factory = new L2I_DataFactory();
        
        List<SObject> blng_GLRules = Test.loadData(blng__GLRule__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('GLRule_file'));
        
        
        List<SObject> blng_LegalEntities = Test.loadData(blng__LegalEntity__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('LegalEntity_file'));
        
        
        List<SObject> blng_financeBooks = Test.loadData(blng__FinanceBook__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('FinanceBook_file'));
        
        
        List<SObject> blng_billingRules = Test.loadData(blng__BillingRule__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('BillingRule_file'));
        
        
        List<SObject> blng_taxRules = Test.loadData(blng__TaxRule__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('TaxRule_file'));
        
        
        List<SObject> blng_revrecRules = Test.loadData(blng__RevenueRecognitionRule__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('RevenueRecognitionRule_file'));
        
        
        List<SObject> blng_GLAccounts = Test.loadData(blng__GLAccount__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('GLAccount_file'));
        
        
        List<SObject> blng_GLTreatments = Test.loadData(blng__GLTreatment__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('GLTreatment_file'));
        
        List<SObject> blng_BillingConfig = Test.loadData(blng__BillingConfig__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('BillingConfig_file'));
        
        products = Test.loadData(Product2.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('Product2_file'));
        
        
        pbEntries = new List<PricebookEntry>();
        for (SObject prod : products) {
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                  Product2Id = prod.Id,
                  UnitPrice = 1000,
                  IsActive = true);
            
            pbEntries.add(pbe);
        }
        insert pbEntries;
        
        List<PricebookEntry> peList = [select Id, Product2Id, Pricebook2Id, UnitPrice from PricebookEntry];
        peIdMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry p : peList) {
            peIdMap.put(p.Product2Id, p);
        }
        
        prodCategoryMap = new Map<Id, String>();
        prodList = [select Id, Name, L2I_Sub_Category_2__c from Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();
        
        for (Product2 p : prodList) {
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }
        
        
        List<SBQQ__Quote__c> quote = [select Id, ApprovalStatus__c, SBQQ__PricebookId__c from SBQQ__Quote__c limit 1];
        quote[0].SBQQ__PricebookId__c = Test.getStandardPricebookId();
        update quote;
        
        Set<String> ProductNameSet1 = new Set<String>();
        ProductNameSet1.add('Toca Boca - Toca Cars');
        ProductNameSet1.add('Nitro Street Run 2');
        ProductNameSet1.add('Live Television - Monthly Additional Satellite Capacity - per aircraft');
        ProductNameSet1.add('Connectivity Services - WiFi');
        
        List<SBQQ__Cost__c> ctList = new List<SBQQ__Cost__c>();
        prodIdList = New Set<Id>();
        for (String s : ProductNameSet1) {
            Id pid = prodIdMap.get(s);
            prodIdList.add(pid);
            SBQQ__Cost__c ct = new SBQQ__Cost__c();
            ct.SBQQ__Product__c = prodIdMap.get(s);
            ct.SBQQ__UnitCost__c = 0;
            ct.SBQQ__Active__c = true;
            
            ctList.add(ct);
        }
        insert ctList;
        
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        
        for (String s : ProductNameSet1) {
            Id pid = prodIdMap.get(s);
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(quote[0].Id, pid, null);
            quoteLine.SBQQ__UnitCost__c = 0;
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.SBQQ__RegularPrice__c = 0;
            quoteLine.SBQQ__CustomerPrice__c = 0;
            quoteLine.L2I_On_Doc_Delivery_Day__c = '1';
            quoteLine.SBQQ__BillingFrequency__c = 'Monthly';
            quoteLine.SBQQ__StartDate__c = Date.today();
            quoteLine.SBQQ__EndDate__c = Date.today().addYears(3);
            quoteLine.SBQQ__PricebookEntryId__c = peIdMap.get(pid).Id;
            quoteLine.L2I_Sub_Category_2__c = 'Games';
            quoteLine.L2I_Category__c = 'DSS';
            
            qlList.add(quoteLine);
        }
        insert qlList;
        
        quote[0].ApprovalStatus__c = 'Approved';
        quote[0].SBQQ__Primary__c = true;
        quote[0].SBQQ__PriceBook__c = Test.getStandardPricebookId();
        update quote;
    
    }
    
    @IsTest
    static void test_validate_Create_Order() {
        setupTestContext();
        Opportunity salesOpp = [SELECT Id, L2I_Delivery_Schedule__c FROM Opportunity WHERE RecordType.DeveloperName = 'Sales' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        salesOpp.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOpp;
        List<SBQQ__QuoteLine__c> qlist = [select id from SBQQ__QuoteLine__c];
        system.assertEquals(qlist.size(), 4);
        Test.startTest();
        List<SBQQ__Quote__c> olist = [select id, SBQQ__Ordered__c from SBQQ__Quote__c];
        List<Id> newIds = new List<Id>();
        for (SBQQ__Quote__c q : olist) {
            newIds.add (q.Id);
        }
        
        L2I_CM_OrderActivation_Batch.executeBatchMethod(newIds);
        Test.stopTest();
        
        List<Order> o = [select Id, OpportunityId, Type, L2I_Original_Sales_Opportunity__c, L2I_Product_Category_2__c, Opportunity.L2I_Delivery_Schedule__c from Order];
        system.debug (o);
        system.assertEquals(o.size(), 1);
    }
    
    @IsTest
    static void test_CreateCase() {
        setupTestContext();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity salesOppty = [SELECT Id, L2I_Delivery_Schedule__c FROM Opportunity WHERE RecordType.DeveloperName = 'Sales' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        List<SBQQ__QuoteLine__c> qlist = [select id from SBQQ__QuoteLine__c];
        system.assertEquals(qlist.size(), 4);
        Test.startTest();
        List<SBQQ__Quote__c> qtlist = [select id, SBQQ__Ordered__c from SBQQ__Quote__c];
        qtList[0].SBQQ__Ordered__c = true;
        update qtList;
        List<Id> newIds = new List<Id>();
        for (SBQQ__Quote__c q : qtlist) {
            newIds.add (q.Id);
        }
        
        Order theTestOrder = new Order(AccountId = acct.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOppty.Id,
              SBQQ__Quote__c = qtList[0].Id,
              L2I_Product_Category_2__c = 'games',
              L2I_Order_Process__c = 'Contract Management',
              L2I_Delivery_Schedule__c = dsh.Id);
        insert theTestOrder;
        theTestOrder.Type = 'Renewal';
        update theTestOrder;
        
        List<OrderItem> OrderItemList = new List<OrderItem>();
        blng__BillingRule__c billingrule = [select Id from blng__BillingRule__c where name = 'Non-Billable Product Rule' limit 1];
        for (Id pid : prodIdList) {
            OrderItem theTestOrderItem = new OrderItem(OrderId = theTestOrder.id,
                  Quantity = 1,
                  Product2Id = pid,
                  PricebookEntryId = peIdMap.get(pid).Id,
                  UnitPrice = peIdMap.get(pid).UnitPrice,
                  L2I_Sub_Category_2__c = prodCategoryMap.get(pid),
                  SBQQ__ChargeType__c = 'Recurring',
                  SBQQ__BillingFrequency__c = 'Monthly',
                  SBQQ__BillingType__c = 'Advance',
                  blng__BillingRule__c = billingrule.Id,
                  SBQQ__DefaultSubscriptionTerm__c = 24,
                  L2I_blng_MatchingId__c = '00N18000001Vkc2',
                  SBQQ__Activated__c = true);
            OrderItemList.add(theTestOrderItem);
        }
        insert OrderItemList;
        
        Database.executeBatch(new L2I_CaseMgmtFromCROrderBatch(newIds), 10);
        Test.stopTest();
        
        List<Order> o = [
              select Id, OpportunityId, Type, L2I_Original_Sales_Opportunity__c,
                    L2I_Product_Category_2__c, Opportunity.L2I_Delivery_Schedule__c
              from Order
              WHERE Id = :theTestOrder.Id
        ];
        system.debug (o);
        system.assertEquals(o.size(), 1);
        o[0].Type = 'Renewal';
        update o;
        
        System.debug('*** case ' + [select id, l2i_case_process__c from case]);
        List<Case> c = [select Id from case];
        system.assertEquals(2, c.size());
    
        System.debug('*** asa ' + [select Id from L2I_ASA__c]);
        List<L2I_ASA__c> asa = [select Id from L2I_ASA__c];
        system.assertEquals(1, asa.size());

        System.debug('*** as ' + [select Id from L2I_Aircraft_Service__c]);
        List<L2I_Aircraft_Service__c> asRecord = [select Id from L2I_Aircraft_Service__c];
        system.assertEquals(3, asRecord.size());
    }
}