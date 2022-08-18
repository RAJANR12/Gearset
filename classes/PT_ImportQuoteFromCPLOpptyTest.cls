/**
* @File Name          : PT_ImportQuoteFromCPLOpptyTest.cls
* @Description        : Test Class for PT_ImportQuoteFromCPLOppty
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@isTest
public class PT_ImportQuoteFromCPLOpptyTest {
    private static L2I_DataFactory factory;

    @isTest
    static void processCPLImportTest() {
        factory = new L2I_DataFactory();
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        
        // Added for W-001727
        List<Product2> prodSysTypes = new List<Product2>();
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        //insert prodSysType;
        prodSysTypes.add(prodSysType);
        
        Product2 prodSysType2 = factory.createProduct('1236541','EXW','IFEC','IFE HW', 'X-Series','C');
        prodSysTypes.add(prodSysType2);
        insert prodSysTypes;

        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.L2I_Primary_System_Type__c = prodSysTypes[0].Id;
        insert salesOpp;

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
        insert quote;

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

        Product2 product = factory.createProduct('99999802', 'MediaServices', null, null, null);
        product.productCode = 'MCS BUNDLE';
        insert product;

        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];

        SBQQ__QuoteLine__c ql1 = factory.createQuoteLine(quote.Id, prod.Id, null);
        ql1.SBQQ__Group__c = qlg1.Id;
        insert ql1;

        Opportunity salesOppNew = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOppNew.L2I_Product_Category__c = 'IFEC';
        salesOppNew.L2I_Primary_System_Type__c = prodSysTypes[1].Id;
        insert salesOppNew;

        Boolean isPrimaryQuoteNew = true;
        SBQQ__Quote__c quoteNew = factory.createQuote('Draft', acc.Id, salesOppNew.Id, isPrimaryQuoteNew);
        quoteNew.L2I_Reviewed_PO_Required__c = true;
        quoteNew.SBQQ__BillingFrequency__c = 'Monthly';
        quoteNew.SBQQ__StartDate__c = Date.today();
        quoteNew.ApprovalStatus__c = '';
        insert quoteNew;

        List<PT_ImportQuoteFromCPLOppty.Requests> requests = new List<PT_ImportQuoteFromCPLOppty.Requests>();
        PT_ImportQuoteFromCPLOppty.Requests req = new PT_ImportQuoteFromCPLOppty.Requests();
        req.quoteId = quoteNew.Id;
        req.opptyId = salesOpp.Id;
        requests.add(req);

        PT_ImportQuoteFromCPLOppty.processCPLImport(requests);
    }
}