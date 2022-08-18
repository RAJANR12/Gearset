/**
 *  @author       Ryan Lobitana (Simplus)
 *  @date         JUL/20/2021
 *  @description  L2I_SendEmailNotifications class
 *
 *  Modification Log:
 *  ------------------------------------------------------------------------------------
 *  Developer                       Date                Description
 *  ------------------------------------------------------------------------------------
 *  Ryan Lobitana                  7/20/2020         Initial scaffold
 *  MS Simplus Khrisna             03/31/2022        W-001727 Primary System Type Validation Rule
 */
@isTest(SeeAllData=false)
public class L2I_SendEmailNotificationsTest {
    
    private static L2I_DataFactory factory;
    
    @testSetup static void testSetup() {
        factory = new L2I_DataFactory();

        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        acc.L2I_Region__c = 'Europe';
        insert acc;
        System.assert(acc.Id != null, 'Named Customer Account must have an Id');

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
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
        Product2 testProd = factory.createProduct('905647-TEST10', 'Test product', 'IFEC','IFE HW', 'X-Series');
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
    static void closedWonOppty() {
        
        Send_Email_Notification_Setting__c settings = new Send_Email_Notification_Setting__c();
        settings.Is_Active__c = TRUE;
        settings.Additional_Emails__c = 'test@email.com';
        settings.Exception_Emails__c = 'test1@email.com';
        settings.Public_Group__c = 'Program Approval DL';
        
        insert settings;
        
        Opportunity oppty = [SELECT Id, StageName, L2I_Product_Category__c, L2I_Oppt_Region__c FROM Opportunity LIMIT 1];
        oppty.StageName = 'Closed Won';
        oppty.L2I_Product_Category__c = 'IFEC';
        
        User userRec = [SELECT Id, Email FROM User WHERE Profile.Name = 'System Administrator' ORDER BY Name LIMIT 1];
        oppty.PT_Program_Mgr__c = userRec.Id;
        oppty.PT_PL_Approval_Approver__c = userRec.Id;
        
        test.startTest();
        
        update oppty;
        
        oppty.StageName = 'Handoff';        
        update oppty;
        
        oppty.StageName = 'Delivery';
        update oppty;
        
        test.stopTest();
    }
	
}