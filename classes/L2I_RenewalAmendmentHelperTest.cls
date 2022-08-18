@isTest
private class L2I_RenewalAmendmentHelperTest {
    
    private static L2I_DataFactory factory;
    
    @testSetup
    static void testSetup() {
        factory = new L2I_DataFactory();

        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        System.assert(acc.Id != null, 'Named Customer Account must have an Id');

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');

        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'DSS');
        // salesOpp.L2I_Product_Category__c = 'DSS'; // Updated by Khrisna for Test Class Fix W-004060
        insert salesOpp;

        SBQQ__Quote__c quote = factory.createQuote('draft', acc.Id, salesOpp.Id, true);
        insert quote;

        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();

        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test Billable Rule', blng__InitialBillingTrigger__c = 'Order Product Activation Date', blng__PartialPeriodTreatment__c = 'Separate', blng__AmendmentBillCycleDateAlignment__c = 'Align to original Order Product', blng__GenerateInvoices__c = 'No', blng__Active__c = True);
        insert billingRule;

        blng__RevenueRecognitionRule__c revRec = new blng__RevenueRecognitionRule__c(name = 'Test Revenue Recognition Rule', blng__Active__c = true, blng__CreateRevenueSchedule__c = 'No');
        insert revRec;

        blng__TaxRule__c taxRule = new blng__TaxRule__c(Name = 'Test tax Rule', blng__Active__c = true, blng__TaxableYesNo__c = 'No');
        insert taxRule;

        List<Product2> products = new List<Product2>();
        Product2 testProd = factory.createProduct('905647-TEST10', 'Test product', 'DSS', 'Media Creative Services', 'MCS');
        testProd.blng__BillingRule__c = billingRule.Id;
        testProd.blng__RevenueRecognitionRule__c = revRec.Id;
        testProd.blng__TaxRule__c = taxRule.Id;
        products.add(testProd);
        insert products;

        List<PricebookEntry> entries = new List<PricebookEntry>();
        for (SObject prod : products) {
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
            entries.add(pbe);
        }
        insert entries;

        for (Product2 prod : products) {
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine( quote.Id, prod.Id, null );
            quoteLine.SBQQ__Quantity__c = 1;
            qlList.add(quoteLine);
        }
        insert qlList;

        L2I_Aircraft_Type__c airType = factory.createAircraftType( acc.Id, 123456);
        insert airType;

        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule( acc.Id, airType.Id);
        insert dsHeaderlList;

        L2I_Aircraft__c ac = factory.createAircraft( airType.Id, 'Test User','2333-11131133114499999988888805', acc.Id);
        insert ac;

        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine( dsHeaderlList.Id );
        insert dsLineList;

        List<PricebookEntry> pbeList = [select Id, Product2Id, Pricebook2Id, UnitPrice, IsActive from PricebookEntry where Product2Id in: products and PriceBook2Id =: Test.getStandardPricebookId()];

        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : pbeList ){
            pricebookMap.put( pbe.Product2Id, pbe );
        }

        Order testOrder = new Order(AccountId = acc.Id, PoNumber= 'Test', EffectiveDate = Date.today(), Status='Draft',
                                       Pricebook2Id=Test.getStandardPricebookId(), blng__BillingDayOfMonth__c = '30', OpportunityId = salesOpp.Id,
                                       SBQQ__Quote__c = quote.Id, L2I_Delivery_Schedule__c = dsHeaderlList.Id);
        insert testOrder;


        List<OrderItem> OrderItemList = new List<OrderItem>();
        for(Product2 prod : products) {
            OrderItem item = new OrderItem(OrderId = testOrder.id, Quantity = 1, Product2Id = prod.Id, PricebookEntryId = pricebookMap.get(prod.Id).Id,
                                           UnitPrice = pricebookMap.get(prod.Id).UnitPrice, blng__BillingRule__c = billingRule.Id,
                                           blng__RevenueRecognitionRule__c = revRec.Id, blng__TaxRule__c = taxRule.Id, SBQQ__ChargeType__c = 'One-Time',
                                           SBQQ__DefaultSubscriptionTerm__c = 24, SBQQ__Activated__c = false);
            OrderItemList.add(item);
        }
        insert OrderItemList;

        testOrder.Status = 'Activated';
        testOrder.StatusCode = 'Activated';
        update testOrder;

        testOrder.SBQQ__Contracted__c = true;
        update testOrder;

        Contract ctr = new Contract(AccountId = acc.Id, SBQQ__Order__c = testOrder.Id, SBQQ__Opportunity__c = salesOpp.Id, SBQQ__RenewalOpportunity__c = salesOpp.Id, SBQQ__Quote__c = quote.Id,
                                    Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(), CurrencyIsoCode = 'USD', ContractTerm = 24,
                                    StartDate = Date.today().addMonths(3), SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
                                    SBQQ__DefaultRenewalPartners__c = true, SBQQ__DefaultRenewalContactRoles__c = true);
        insert ctr;
    }
    
    @isTest
    static void testReviseRenewal() {
        Contract contract = [Select Id From Contract LIMIT 1];
        Test.startTest();
        List<Id> result = L2I_ReviseRenewal_Helper.contractAmendment(new List<Id>{contract.Id});
        Test.stopTest();
        
        System.assert(result != null);
    }
	
    @isTest
    static void testAmendmentCancelation() { 
        Contract contract = [Select Id From Contract LIMIT 1];
        Test.startTest();
        List<SBQQ__Quote__c> result = L2I_Amendment_Cancelation_Helper.contractAmendment(new List<Id>{contract.Id});
        Test.stopTest();
        
        System.assert(result != null);
    }
    
    @isTest
    static void testCancelLines() {
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c LIMIT 1];
        Test.startTest();
        L2I_Amendment_Cancelation_Helper.cancelAllLines(quote.Id);
        Test.stopTest();
    }
}