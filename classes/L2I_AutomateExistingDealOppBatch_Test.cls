@isTest
public with sharing class L2I_AutomateExistingDealOppBatch_Test {
    private static L2I_DataFactory factory;
    
    @isTest
    static void dealOpptyWithSalesOppty_Test() {
        factory = new L2I_DataFactory();
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        acc.L2I_Operator_Number__c = 'AC';
        insert acc;
        
        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.L2I_AC_Operator__c = acc.Id;
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
        quote.SubmittedDate__c = Date.today();
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today();
        insert quote;
        
        quote.PL_Business_Pillars__c = 'PTS';
        update quote;
    
        Test.startTest();
        L2I_AutomateExistingDealOppBatch batch = new L2I_AutomateExistingDealOppBatch();
        DataBase.executeBatch(batch);
        Test.stopTest();
        
        Opportunity opptyDealConfirm = [SELECT Id, L2I_Deal_Opportunity_Description__c FROM Opportunity WHERE Id =: dealOpp.Id];        
       	System.assertEquals(opptyDealConfirm.L2I_Deal_Opportunity_Description__c, 'AC / PTS');
        
        Opportunity opptySalesConfirm = [SELECT Id, L2I_Deal_Opportunity_Description__c FROM Opportunity WHERE Id =: dealOpp.Id];        
       	System.assertEquals(opptySalesConfirm.L2I_Deal_Opportunity_Description__c, 'AC / PTS');
    }
    
        
    @isTest
    static void dealOpptyWithSalesOpptys_Test() {
        factory = new L2I_DataFactory();
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        acc.L2I_Operator_Number__c = 'AC';
        insert acc;
        
        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOpp1 = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp1.L2I_Product_Category__c = 'IFEC';
        salesOpp1.L2I_Primary_System_Type__c = prodSysType.Id;
        salesOpp1.L2I_AC_Operator__c = acc.Id;
        insert salesOpp1;
        
        Opportunity salesOpp2 = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp2.L2I_Product_Category__c = 'IFEC';
        salesOpp2.L2I_Primary_System_Type__c = prodSysType.Id;
        salesOpp2.L2I_AC_Operator__c = acc.Id;
        insert salesOpp2;
        
        L2I_Aircraft_Type__c att = factory.createAircraftType( acc.Id, 123456);
        insert att;
        
        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule( acc.Id, att.Id);
        insert dsHeaderlList;
        
        L2I_DSL__c dsLineList1 = factory.createDeliveryScheduleLine( dsHeaderlList.Id );
        dsLineList1.Original_Opportunity__c = salesOpp1.Id;
        insert dsLineList1;
        
        L2I_DSL__c dsLineList2 = factory.createDeliveryScheduleLine( dsHeaderlList.Id );
        dsLineList2.Original_Opportunity__c = salesOpp2.Id;
        insert dsLineList2;
        
        Boolean isPrimaryQuote = true;
        SBQQ__Quote__c quote1 = factory.createQuote('Draft', acc.Id, salesOpp1.Id, isPrimaryQuote);
        quote1.L2I_Reviewed_PO_Required__c = true;
        quote1.SBQQ__BillingFrequency__c = 'Monthly';
        quote1.SBQQ__StartDate__c =  Date.today();
        quote1.ApprovalStatus__c = 'Approved';
        quote1.SubmittedDate__c = Date.today();
        quote1.L2I_Final_Proposal_Submission_Date__c = Date.today();
        insert quote1;
        
        quote1.PL_Business_Pillars__c = 'PTS';
        update quote1;
        
        SBQQ__Quote__c quote2 = factory.createQuote('Draft', acc.Id, salesOpp2.Id, isPrimaryQuote);
        quote2.L2I_Reviewed_PO_Required__c = true;
        quote2.SBQQ__BillingFrequency__c = 'Monthly';
        quote2.SBQQ__StartDate__c =  Date.today();
        quote2.ApprovalStatus__c = 'Approved';
        quote2.SubmittedDate__c = Date.today();
        quote2.L2I_Final_Proposal_Submission_Date__c = Date.today();
        quote2.PL_Business_Pillars__c = 'IFE';
        insert quote2;
    
        Test.startTest();
        L2I_AutomateExistingDealOppBatch batch = new L2I_AutomateExistingDealOppBatch();
        DataBase.executeBatch(batch);
        Test.stopTest();
        
        Opportunity opptyDealConfirm = [SELECT Id, L2I_Deal_Opportunity_Description__c FROM Opportunity WHERE Id =: dealOpp.Id];        
       	System.assertEquals(opptyDealConfirm.L2I_Deal_Opportunity_Description__c, 'AC / PTS-IFE');
        
        Opportunity opptySalesConfirm = [SELECT Id, L2I_Deal_Opportunity_Description__c FROM Opportunity WHERE Id =: dealOpp.Id LIMIT 1];        
       	System.assertEquals(opptySalesConfirm.L2I_Deal_Opportunity_Description__c, 'AC / PTS-IFE');
    }
    
    @isTest
    static void dealOpptyNoACWithSalesOppty_Test() {
        factory = new L2I_DataFactory();
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        
        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        
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
        quote.SubmittedDate__c = Date.today();
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today();
        insert quote;
        
        quote.PL_Business_Pillars__c = 'PTS';
        update quote;
    
        Test.startTest();
        L2I_AutomateExistingDealOppBatch batch = new L2I_AutomateExistingDealOppBatch();
        DataBase.executeBatch(batch);
        Test.stopTest();
        
        Opportunity opptyDealConfirm = [SELECT Id, L2I_Deal_Opportunity_Description__c FROM Opportunity WHERE Id =: dealOpp.Id];        
       	System.assertEquals(opptyDealConfirm.L2I_Deal_Opportunity_Description__c, 'Unavailable / PTS');
        
        Opportunity opptySalesConfirm = [SELECT Id, L2I_Deal_Opportunity_Description__c FROM Opportunity WHERE Id =: dealOpp.Id];        
       	System.assertEquals(opptySalesConfirm.L2I_Deal_Opportunity_Description__c, 'Unavailable / PTS');
    }
    
    @isTest
    static void dealOpptyNoACWithSalesOpptys_Test() {
        factory = new L2I_DataFactory();
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        
        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOpp1 = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp1.L2I_Product_Category__c = 'IFEC';
        salesOpp1.L2I_Primary_System_Type__c = prodSysType.Id;
        salesOpp1.L2I_AC_Operator__c = acc.Id;
        insert salesOpp1;
        
        Opportunity salesOpp2 = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp2.L2I_Product_Category__c = 'IFEC';
        salesOpp2.L2I_Primary_System_Type__c = prodSysType.Id;
        salesOpp2.L2I_AC_Operator__c = acc.Id;
        insert salesOpp2;
        
        L2I_Aircraft_Type__c att = factory.createAircraftType( acc.Id, 123456);
        insert att;
        
        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule( acc.Id, att.Id);
        insert dsHeaderlList;
        
        L2I_DSL__c dsLineList1 = factory.createDeliveryScheduleLine( dsHeaderlList.Id );
        dsLineList1.Original_Opportunity__c = salesOpp1.Id;
        insert dsLineList1;
        
        L2I_DSL__c dsLineList2 = factory.createDeliveryScheduleLine( dsHeaderlList.Id );
        dsLineList2.Original_Opportunity__c = salesOpp2.Id;
        insert dsLineList2;
        
        Boolean isPrimaryQuote = true;
        SBQQ__Quote__c quote1 = factory.createQuote('Draft', acc.Id, salesOpp1.Id, isPrimaryQuote);
        quote1.L2I_Reviewed_PO_Required__c = true;
        quote1.SBQQ__BillingFrequency__c = 'Monthly';
        quote1.SBQQ__StartDate__c =  Date.today();
        quote1.ApprovalStatus__c = 'Approved';
        quote1.SubmittedDate__c = Date.today();
        quote1.L2I_Final_Proposal_Submission_Date__c = Date.today();
        insert quote1;
        
        quote1.PL_Business_Pillars__c = 'PTS';
        update quote1;
        
        SBQQ__Quote__c quote2 = factory.createQuote('Draft', acc.Id, salesOpp2.Id, isPrimaryQuote);
        quote2.L2I_Reviewed_PO_Required__c = true;
        quote2.SBQQ__BillingFrequency__c = 'Monthly';
        quote2.SBQQ__StartDate__c =  Date.today();
        quote2.ApprovalStatus__c = 'Approved';
        quote2.SubmittedDate__c = Date.today();
        quote2.L2I_Final_Proposal_Submission_Date__c = Date.today();
        quote2.PL_Business_Pillars__c = 'IFE';
        insert quote2;
    
        Test.startTest();
        L2I_AutomateExistingDealOppBatch batch = new L2I_AutomateExistingDealOppBatch();
        DataBase.executeBatch(batch);
        Test.stopTest();
        
        Opportunity opptyDealConfirm = [SELECT Id, L2I_Deal_Opportunity_Description__c FROM Opportunity WHERE Id =: dealOpp.Id];        
       	System.assertEquals(opptyDealConfirm.L2I_Deal_Opportunity_Description__c, 'Unavailable / PTS-IFE');
        
        Opportunity opptySalesConfirm = [SELECT Id, L2I_Deal_Opportunity_Description__c FROM Opportunity WHERE Id =: dealOpp.Id LIMIT 1];        
       	System.assertEquals(opptySalesConfirm.L2I_Deal_Opportunity_Description__c, 'Unavailable / PTS-IFE');
    }
}