@isTest
private class PT_PLG_CallOutTest {

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

        SBQQ__Quote__c quote = factory.createQuote('draft', acc.Id, salesOpp.Id, false);
        insert quote;

        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test Billable Rule', blng__InitialBillingTrigger__c = 'Order Product Activation Date', blng__PartialPeriodTreatment__c = 'Separate', blng__AmendmentBillCycleDateAlignment__c = 'Align to original Order Product', blng__GenerateInvoices__c = 'No', blng__Active__c = True);
        insert billingRule;

        blng__RevenueRecognitionRule__c revRec = new blng__RevenueRecognitionRule__c(name = 'Test Revenue Recognition Rule', blng__Active__c = true, blng__CreateRevenueSchedule__c = 'No');
        insert revRec;

        blng__TaxRule__c taxRule = new blng__TaxRule__c(Name = 'Test tax Rule', blng__Active__c = true, blng__TaxableYesNo__c = 'No');
        insert taxRule;

        List<Product2> products = new List<Product2>();
        Product2 testProd = factory.createProduct('905647-TEST10', 'Test product', null, null, null);
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

        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();

        for (Product2 prod : products) {
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine( quote.Id, prod.Id, null );
            quoteLine.SBQQ__Quantity__c = 1;
            qlList.add(quoteLine);
        }
        insert qlList;
    }

    @isTest
    static void getAirCraftConfigTest() {
        SBQQ__Quote__c quote = [Select Id, L2I_Version__c From SBQQ__Quote__c LIMIT 1];
        String url = PT_PLG_CallOut.getAirCraftConfig(quote.Id);
        System.assertNotEquals(null, url);
    }
}