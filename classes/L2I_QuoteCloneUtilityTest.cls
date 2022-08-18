@isTest
private class L2I_QuoteCloneUtilityTest {
    
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
        Product2 testProd = factory.createProduct('905647-TEST10', 'Test product', 'DSS', 'Advertising', 'Advertising');
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

        PT_PriceList__c priceList = new PT_PriceList__c(PT_Program__c = null, PT_Description__c = 'TBD', PT_IsActive__c = TRUE, PT_Price_List_Sequence__c = '01', PT_Price_List_Name__c = 'TestPL', PT_Opportunity__c = salesOpp.Id);
        insert priceList;

        PT_PriceList_Entry__c plEntry = new PT_PriceList_Entry__c(PT_Program_Price_List__c = priceList.Id, PT_CanEscalate__c = TRUE, PT_isActive__c = TRUE, PT_StartDate__c = Date.today(), PT_Status__c = 'Approved', PT_Product__c = products[0].Id, PT_UnitPrice__c = 30.0, Name = 'Test1234');
        insert plEntry;

        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
    
        SBQQ__QuoteLineGroup__c qlg1 = new SBQQ__QuoteLineGroup__c(
              Name = sg.Name,
              SBQQ__SolutionGroup__c = sg.Id,
              SBQQ__Quote__c = quote.Id
        );
        insert qlg1;
        
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();

        for (Product2 prod : products) {
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine( quote.Id, prod.Id, null );
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.PT_Price_List_Entry__c = plEntry.Id;
            quoteLine.SBQQ__Group__c = qlg1.Id;
            qlList.add(quoteLine);
        }
        insert qlList;
    }
    
    @isTest
    static void testQuoteClone() {
        SBQQ__Quote__c quote = [Select Id, L2I_Version__c From SBQQ__Quote__c LIMIT 1];
        PT_PLG_Invoke_Revise.Requests req = new PT_PLG_Invoke_Revise.Requests();
        req.quoteobj = quote.Id;
        
        Test.startTest();
        List<PT_PLG_Invoke_Revise.Results> resp = PT_PLG_Invoke_Revise.ProcessPartsList(new List<PT_PLG_Invoke_Revise.Requests>{req});
        Test.stopTest();
        
        System.assert(resp != null && resp[0].quotes != null && !resp[0].quotes.isEmpty(), 'Failed to clone the quote');
        System.assert(resp != null && resp[0].quotes != null && !resp[0].quotes.isEmpty() && resp[0].quotes[0].L2I_Version__c == quote.L2I_Version__c+1, 'Failed to update Version # on the cloned quote');
    }

    @isTest
    static void testCloneQuoteAndLines() {
        SBQQ__Quote__c quote = [Select Id, L2I_Version__c From SBQQ__Quote__c LIMIT 1];
        
        Test.startTest();
        L2I_QuoteCloneUtility.CloneQuoteDetails cloneQuote = L2I_QuoteCloneUtility.cloneQuoteAndLines(quote.Id, 20);
        L2I_QuoteCloneUtility.getBatchJobStatus(cloneQuote.jobId);
        Test.stopTest();
        
        System.assert(cloneQuote != null && cloneQuote.clonedQuote != null, 'Failed to clone the quote');
    }

    @isTest
    static void testLWCHelperMethods() {
        SBQQ__Quote__c quote = [Select Id, L2I_Version__c From SBQQ__Quote__c LIMIT 1];
        
        Test.startTest();
        L2I_QuoteCloneUtility.getSystemTime();
        SBQQ__Quote__c quote2 = L2I_QuoteCloneUtility.getQuoteDetails(quote.Id);
        Test.stopTest();
        
        System.assert(quote2 != null, 'Failed to query the quote');
    }
}