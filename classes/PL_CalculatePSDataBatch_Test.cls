/**
 *      @author       Sarah Kennedy
 *      @date         03/16/2020
 *      @description  Batch processing for PL_CalculatePSDataBatch
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 03/18/2021         Initial creation
 *      MS Simplus Khrisna            03/31/2022         W-001727 Primary System Type Validation Rule
 */
@isTest
public with sharing class PL_CalculatePSDataBatch_Test {
    private static L2I_DataFactory factory;
    @isTest
    static void testBehavior() {
        factory = new L2I_DataFactory();
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        System.assert(acc.Id != null, 'Named Customer Account must have an Id');
        
        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');
        
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOpp;
        
        L2I_Aircraft_Type__c att = factory.createAircraftType( acc.Id, 123456);
        insert att;
        
        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule( acc.Id, att.Id);
        insert dsHeaderlList;
        
        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine( dsHeaderlList.Id );
        dsLineList.Original_Opportunity__c = salesOpp.Id;
        insert dsLineList;
        
        Boolean isPrimaryQuote = true;
        SBQQ__Quote__c quote = factory.createQuote('Draft', acc.Id, salesOpp.Id, isPrimaryQuote);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__BillingFrequency__c = 'Monthly';
        quote.SBQQ__StartDate__c =  Date.today();
        quote.ApprovalStatus__c = 'Approved';
        quote.SubmittedDate__c = Date.today(); // Added by Khrisna for W-004060
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today(); // Added by Khrisna for W-004060
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
        
        salesOpp.L2I_Aircraft_Type__c = att.Id;
        salesOpp.L2I_Delivery_Schedule__c = dsHeaderlList.Id;
        salesOpp.L2I_Win_Loss_Date__c = Date.today();
        salesOpp.StageName = 'Closed Won';
        update salesOpp;
        
        PT_AssignPTCPLController.FlowInput input = new PT_AssignPTCPLController.FlowInput();
        input.primaryQuoteId = quote.Id;
        PT_AssignPTCPLController.processDSLQuoteLinesFlow(new List<PT_AssignPTCPLController.FlowInput>{input});
    
        Test.startTest();
        PL_CalculatePSDataBatch batch = new PL_CalculatePSDataBatch(quote.Id);
        DataBase.executeBatch(batch);
        Test.stopTest();
    }
}