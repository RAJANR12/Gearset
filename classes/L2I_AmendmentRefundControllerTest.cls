/**
* @File Name          : L2I_AmendmentRefundControllerTest.cls
* @Description        : Test Class for L2I_AmendmentRefundController
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@isTest
public class L2I_AmendmentRefundControllerTest {
    
    private static L2I_DataFactory factory;
    
    @testSetup
    static void testSetup() {
        factory = new L2I_DataFactory();
        
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        System.assert(acc.Id != null, 'Named Customer Account must have an Id');
        
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');

        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOpp;

        SBQQ__Quote__c quote = factory.createQuote('draft', acc.Id, salesOpp.Id, true);
        quote.SBQQ__Type__c = 'Amendment';
        insert quote;
        
        List<Product2> products = new List<Product2>();
        products.add(factory.createProduct('340213', 'Advanced Master Control Unit', 'IFEC', 'IFE HW', null));
        //products.add(factory.createProduct('905647-TEST10', 'Test product', 'DSS', 'Media Creative Services', 'MCS'));
        insert products;
        
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        
        for (Product2 prod : products) {
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine( quote.Id, prod.Id, null );
            quoteLine.SBQQ__Quantity__c = 1;
            qlList.add(quoteLine);
        }
        insert qlList;
    }
    
    @isTest
    static void testGetQuoteLines() {
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c LIMIT 1];
        
        Test.startTest();
        List<L2I_AmendmentRefundController.QuoteLineWrapper> qLines = L2I_AmendmentRefundController.getQuoteLines(quote.Id);
        Test.stopTest();
        
        System.assert(qLines != null, 'Method Did not return any Quote Lines');
    }
    
    @isTest
    static void testGetQuoteLinesNonAmendment() {
        SBQQ__Quote__c quote = [Select Id, SBQQ__Type__c From SBQQ__Quote__c LIMIT 1];
        quote.SBQQ__Type__c = '';
        update quote;
        
        Test.startTest();
        String excepMsg;
        try {
        	List<L2I_AmendmentRefundController.QuoteLineWrapper> qLines = L2I_AmendmentRefundController.getQuoteLines(quote.Id);
        } catch(Exception e) {
            excepMsg = e.getMessage();
            System.debug(excepMsg);
        }
        System.assert(excepMsg != null && excepMsg.contains('You can only cancel the lines for an Amendment quote'), 'Test failed for Non Amendment Quotes');
        Test.stopTest();
    }
    
    @isTest
    static void testSubmitForRefund() {
        List<SBQQ__QuoteLine__c> qLines = [Select Id From SBQQ__QuoteLine__c];
        
        Test.startTest();
        L2I_AmendmentRefundController.submitForRefund(qLines);
        Test.stopTest();
        
        for(SBQQ__QuoteLine__c ql: [Select Id, SBQQ__Quantity__c From SBQQ__QuoteLine__c Where Id in :qLines]) {
            System.assert(ql.SBQQ__Quantity__c == 0, 'Quote Line quantity is not 0');
        }
    }
}