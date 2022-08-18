/**
 * @Description        : Test class for Account_TriggerFunctions
 * @Author             : Jan Denrick Geronga / Managed Services Simplus
 * @Modification Log   :
 * Ver          Date          Author              Modification
 * W-003956     Oct-18-2021   MS Simplus Jan      Initial Version
 **/

@isTest(SeeAllData=false)
public class Account_TriggerFunctions_Test {
    /*
    * @Method Name        : updateQuoteShipToBillTo_Test
    * @Description        : Test class for updateQuoteShipToBillTo
    * @Author             : Jan Denrick Geronga / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-003956      Oct-18-2021   MS Simplus Jan      Initial Version
    **/
    @IsTest
    static void updateQuoteShipToBillTo_Test() {
        L2I_DataFactory df = new L2I_DataFactory();
        Account namedCustomer = df.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = df.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        Opportunity salesOppty = df.createSalesOpportunity('SalesOpp', 'Quotation', 5, namedCustomer.Id, dealOppty.Id);
        salesOppty.L2I_Product_Category__c = 'PTS';
        //salesOppty.L2I_AC_Operator__c = namedCustomer.Id;
        insert salesOppty;
        
        SBQQ__Quote__c quote = df.createQuote('draft', namedCustomer.Id, salesOppty.Id, false);
        quote.SBQQ__Primary__c = true;
        quote.ApprovalStatus__c = 'Pending';
        insert quote;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'BC'
        );
        insert sg;

        SBQQ__QuoteLineGroup__c qlg1 = new SBQQ__QuoteLineGroup__c(
              Name = sg.Name,
              SBQQ__SolutionGroup__c = sg.Id,
              SBQQ__Quote__c = quote.Id
        );
        insert qlg1;
        
        Product2 product = df.createProduct('99999802', 'MediaServices', null, null, null);
        product.productCode = 'MCS BUNDLE';
        insert product;

        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];

        SBQQ__QuoteLine__c ql1 = df.createQuoteLine(quote.Id, prod.Id, null);
        ql1.SBQQ__Group__c = qlg1.Id;
        ql1.isNew__c = true;
        insert ql1; 
        
        Test.startTest();
        namedCustomer.BillingStreet = '400 N.Beck Avenue';
        namedCustomer.BillingCity = 'Chandler';
        namedCustomer.BillingState = 'AZ';
        namedCustomer.BillingPostalCode = '85226';
        update namedCustomer;
        Test.stopTest();
    }
}