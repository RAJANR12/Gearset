/**
* @File Name          : L2I_DealSummaryFunctions_Test.cls
* @Description        : Test Class for L2I_DealSummaryFunctions
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@isTest
private class L2I_DealSummaryFunctions_Test {
    
    
    @isTest
    static void test_deal_and_single_sales_oppty_deal_summary_creation() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        System.assert(salesOppty.Id != null, 'Sales Opportunity must have an Id');
    
        SBQQ__Quote__c quote = factory.createQuote('draft', namedCustomer.Id, salesOppty.Id, true);
        quote.PL_Business_Pillars__c =  'IFE';
        insert quote;
    
        salesOppty.SBQQ__PrimaryQuote__c = quote.Id;
        
        dealOppty = [select Id, Name, Amount from Opportunity where Id = :dealOppty.Id limit 1];
        
        L2I_P_L_Approval__c plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
        insert plApproval;
        
        L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOppty.Id);
        insert plSalesOpp;
        
        L2I_Deal_Summary__c dealsum = new L2I_Deal_Summary__c();
        dealsum.L2I_Deal_Account__c = namedCustomer.id;
        dealsum.L2I_P_L_Approval__c = plApproval.id;
        insert dealsum;
//        L2I_DealSummaryFunctions.gettheDeal(dealsum.id);
//        L2I_DealSummaryFunctions.getDealsOpp(dealsum.id);
        System.assert(dealOppty.Amount == salesOppty.Amount, 'Deal Oppty amount does not equal Child Sales Oppty Amount');
        
        List<Id> dsIds = new List<Id>();
        dsIds.add(dealsum.Id);
        L2I_DealSummaryFunctions.PopulateDealSummary(dsIds);
    }
    
    @isTest
    static void test_ifc() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        System.assert(salesOppty.Id != null, 'Sales Opportunity must have an Id');
        
        SBQQ__Quote__c quote = factory.createQuote('draft', namedCustomer.Id, salesOppty.Id, true);
        quote.PL_Business_Pillars__c =  'IFC';
        insert quote;
        
        salesOppty.SBQQ__PrimaryQuote__c = quote.Id;
        
        dealOppty = [select Id, Name, Amount from Opportunity where Id = :dealOppty.Id limit 1];
        
        L2I_P_L_Approval__c plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
        insert plApproval;
        
        L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOppty.Id);
        insert plSalesOpp;
        
        L2I_Deal_Summary__c dealsum = new L2I_Deal_Summary__c();
        dealsum.L2I_Deal_Account__c = namedCustomer.id;
        dealsum.L2I_P_L_Approval__c = plApproval.id;
        insert dealsum;
//        L2I_DealSummaryFunctions.gettheDeal(dealsum.id);
//        L2I_DealSummaryFunctions.getDealsOpp(dealsum.id);
        System.assert(dealOppty.Amount == salesOppty.Amount, 'Deal Oppty amount does not equal Child Sales Oppty Amount');
        
        List<Id> dsIds = new List<Id>();
        dsIds.add(dealsum.Id);
        L2I_DealSummaryFunctions.PopulateDealSummary(dsIds);
    }
    
    @isTest
    static void test_dss() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        System.assert(salesOppty.Id != null, 'Sales Opportunity must have an Id');
        
        SBQQ__Quote__c quote = factory.createQuote('draft', namedCustomer.Id, salesOppty.Id, true);
        quote.PL_Business_Pillars__c =  'DSS';
        insert quote;
        
        salesOppty.SBQQ__PrimaryQuote__c = quote.Id;
        
        dealOppty = [select Id, Name, Amount from Opportunity where Id = :dealOppty.Id limit 1];
        
        L2I_P_L_Approval__c plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
        insert plApproval;
        
        L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOppty.Id);
        insert plSalesOpp;
        
        L2I_Deal_Summary__c dealsum = new L2I_Deal_Summary__c();
        dealsum.L2I_Deal_Account__c = namedCustomer.id;
        dealsum.L2I_P_L_Approval__c = plApproval.id;
        insert dealsum;
//        L2I_DealSummaryFunctions.gettheDeal(dealsum.id);
//        L2I_DealSummaryFunctions.getDealsOpp(dealsum.id);
        System.assert(dealOppty.Amount == salesOppty.Amount, 'Deal Oppty amount does not equal Child Sales Oppty Amount');
        
        List<Id> dsIds = new List<Id>();
        dsIds.add(dealsum.Id);
        L2I_DealSummaryFunctions.PopulateDealSummary(dsIds);
    }
    
    @isTest
    static void test_pts() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        System.assert(salesOppty.Id != null, 'Sales Opportunity must have an Id');
        
        SBQQ__Quote__c quote = factory.createQuote('draft', namedCustomer.Id, salesOppty.Id, true);
        quote.PL_Business_Pillars__c =  'PTS';
        insert quote;
        
        salesOppty.SBQQ__PrimaryQuote__c = quote.Id;
        
        dealOppty = [select Id, Name, Amount from Opportunity where Id = :dealOppty.Id limit 1];
        
        L2I_P_L_Approval__c plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
        insert plApproval;
        
        L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOppty.Id);
        insert plSalesOpp;
        
        L2I_Deal_Summary__c dealsum = new L2I_Deal_Summary__c();
        dealsum.L2I_Deal_Account__c = namedCustomer.id;
        dealsum.L2I_P_L_Approval__c = plApproval.id;
        insert dealsum;
//        L2I_DealSummaryFunctions.gettheDeal(dealsum.id);
//        L2I_DealSummaryFunctions.getDealsOpp(dealsum.id);
        System.assert(dealOppty.Amount == salesOppty.Amount, 'Deal Oppty amount does not equal Child Sales Oppty Amount');
        
        List<Id> dsIds = new List<Id>();
        dsIds.add(dealsum.Id);
        L2I_DealSummaryFunctions.PopulateDealSummary(dsIds);
    }
    
    @isTest
    static void test_quoteLines() {
        L2I_DataFactory factory = new L2I_DataFactory();
    
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
    
        Set<Id> ids = new Set<Id>();
        ids.add(quote.Id);
        L2I_DealSummaryFunctions.QuoteLineInfo qlInfo = new L2I_DealSummaryFunctions.QuoteLineInfo();
        Map <Id, L2I_DealSummaryFunctions.QuoteLineInfo> mds = L2I_DealSummaryFunctions.getQuoteLineInfo(ids);
        System.assertEquals(false, mds.isEmpty());
    }
}