/**
 *      @author       Lipton Abillar
 *      @date         08/30/2021
 *      @description  RelatedOpportunitiesController
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Lipton Abillar                 08/30/2021         Initial
 *      MS Simplus Khrisna             03/31/2022         W-001727 Primary System Type Validation Rule
 */
@isTest
public without sharing class RelatedOpportunitiesControllerTest {

    @TestSetup
    static void makeData(){
        L2I_DataFactory factory = new L2I_DataFactory();

        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        System.assert(acc.Id != null, 'Named Customer Account must have an Id');

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');

        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;

        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOpp;
        
        Opportunity dssOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'DSS');
        dssOpp.L2I_Product_Category__c = 'DSS';
        insert dssOpp;
        
        L2I_Aircraft_Type__c att = factory.createAircraftType(acc.Id, 123456);
        insert att;
        
        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule(acc.Id, att.Id);
        dsHeaderlList.Product_Category__c = 'IFEC';
        insert dsHeaderlList;
        
        L2I_DSH__c dsHeaderlList2 = factory.createDeliverySchedule(acc.Id, att.Id);
        insert dsHeaderlList2;
        
        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine(dsHeaderlList.Id);
        dsLineList.Original_Opportunity__c = salesOpp.Id;
        insert dsLineList;
        
        Test.startTest();
        L2I_DSL__c dsLineList2 = factory.createDeliveryScheduleLine(dsHeaderlList2.Id);
        dsLineList2.IFEC_DSL__c = dsLineList.Id;
        insert dsLineList2;
        
        Boolean isPrimaryQuote = true;
        SBQQ__Quote__c quote = factory.createQuote('Draft', acc.Id, salesOpp.Id, isPrimaryQuote);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__BillingFrequency__c = 'Monthly';
        quote.SBQQ__StartDate__c = Date.today();
        quote.ApprovalStatus__c = 'Approved';
        quote.SubmittedDate__c = Date.today(); // Added by Khrisna for W-004060
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today(); // Added by Khrisna for W-004060
        insert quote;
        salesOpp.L2I_Aircraft_Type__c = att.Id;
        salesOpp.L2I_Delivery_Schedule__c = dsHeaderlList.Id;
        salesOpp.L2I_Win_Loss_Date__c = Date.today();
        salesOpp.L2I_Program_Num__c = prog1.Id;
        salesOpp.StageName = 'Closed Won';
        update salesOpp;

        dssOpp.L2I_Aircraft_Type__c = att.Id;
        dssOpp.L2I_Delivery_Schedule__c = dsHeaderlList2.Id;
        dssOpp.L2I_Win_Loss_Date__c = Date.today();
        update dssOpp;
        Test.stopTest();
    }

    @isTest
    static void fetchDataTest() {
        Opportunity dealOpp = [SELECT Id FROM Opportunity WHERE RecordType.Name = 'Deal' LIMIT 1];

        RelatedOpportunitiesController.InputWrapper input = new RelatedOpportunitiesController.InputWrapper();
        input.recordId = dealOpp.Id;
        input.sObjectName = 'Opportunity';
        input.lookupField = 'L2I_Parent_Opportunity__c';
        input.filter = 'L2I_Product_Category__c = \'IFEC\' OR L2I_Product_Category__c = \'DSS\'';
        input.rows = 10;
        input.offset = 0;
        input.sortBy = 'Name';
        input.sortDirection = 'ASC';

        RelatedOpportunitiesController.ResponseWrapper response = RelatedOpportunitiesController.fetchData(JSON.serialize(input));
    }

    @isTest
    static void fetchDataTest2() {
        PT_Program__c dealOpp = [SELECT Id FROM PT_Program__c LIMIT 1];

        RelatedOpportunitiesController.InputWrapper input = new RelatedOpportunitiesController.InputWrapper();
        input.recordId = dealOpp.Id;
        input.sObjectName = 'PT_Program__c';
        input.lookupField = 'L2I_Program_Num__c';
        input.rows = 10;
        input.offset = 0;
        input.sortBy = 'Name';
        input.sortDirection = 'ASC';

        RelatedOpportunitiesController.ResponseWrapper response = RelatedOpportunitiesController.fetchData(JSON.serialize(input));
    }
}