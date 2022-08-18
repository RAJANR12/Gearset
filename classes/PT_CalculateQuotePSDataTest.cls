/**
* @File Name          : PT_CalculateQuotePSDataTest.cls
* @Description        : Test Class for PT_CalculateQuotePSData
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@isTest
public class PT_CalculateQuotePSDataTest {
    private static L2I_DataFactory factory;

    @isTest
    static void invokeCalculateQuotePSDataTest() {
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

        L2I_P_L_Approval__c plApproval = factory.createPLApproval(dealOpp.Id, 'Approved');
        insert plApproval;

        L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOpp.Id);
        insert plSalesOpp;

        L2I_Aircraft_Type__c att = factory.createAircraftType(acc.Id, 123456);
        insert att;

        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule(acc.Id, att.Id);
        insert dsHeaderlList;

        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine(dsHeaderlList.Id);
        insert dsLineList;

        Boolean isPrimaryQuote = true;
        SBQQ__Quote__c quote = factory.createQuote('Draft', acc.Id, salesOpp.Id, isPrimaryQuote);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__BillingFrequency__c = 'Monthly';
        quote.SBQQ__StartDate__c = Date.today();
        quote.ApprovalStatus__c = 'Approved';
        quote.L2I_System_Type1__c = 'All';
        quote.SBQQ__OrderByQuoteLineGroup__c = true;
        quote.SBQQ__LineItemsGrouped__c = true;
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

        List<SBQQ__SolutionGroup__c> slGrpsList = new List<SBQQ__SolutionGroup__c>();
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
                Name = 'ALT',
                Type__c = 'CPL'
        );
        //slGrpsList.add(sg);
        SBQQ__SolutionGroup__c sg1 = new SBQQ__SolutionGroup__c(
                Name = 'FIT',
                Type__c = 'FC'
        );
        //slGrpsList.add(sg1);
        SBQQ__SolutionGroup__c sg2 = new SBQQ__SolutionGroup__c(
                Name = 'RACK',
                Type__c = 'EQ'
        );
        slGrpsList.add(sg2);
        insert slGrpsList;

        List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
        for(SBQQ__SolutionGroup__c slg : slGrpsList) {
            SBQQ__QuoteLineGroup__c qlg1 = new SBQQ__QuoteLineGroup__c(
                Name = slg.Name,
                SBQQ__SolutionGroup__c = slg.Id,
                SBQQ__Quote__c = quote.Id
            );
            qlgList.add(qlg1);
        }

        insert qlgList;

        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLineGroup__c qlg : qlgList) {
            SBQQ__QuoteLine__c ql1 = factory.createQuoteLine(quote.Id, products[0].Id, null);
            ql1.SBQQ__Group__c = qlg.Id;
            ql1.SBQQ__NetPrice__c = 10.0;
            qlList.add(ql1);
        }
        insert qlList;

        List<PT_CalculateQuotePSData.Requests> requests = new List<PT_CalculateQuotePSData.Requests>();
        PT_CalculateQuotePSData.Requests req = new PT_CalculateQuotePSData.Requests();
        req.quoteId = quote.Id;
        requests.add(req);

        PT_CalculateQuotePSData.invokeCalculateQuotePSData(requests);
    }
}