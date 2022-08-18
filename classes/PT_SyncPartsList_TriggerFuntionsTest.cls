/**
* @File Name          : PT_SyncPartsList_TriggerFuntionsTest.cls
* @Description        : Test Class for PT_SyncPartsListEvent_TriggerFuntions
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@isTest
public with sharing class PT_SyncPartsList_TriggerFuntionsTest {
    private static L2I_DataFactory factory;
    @isTest
    static void syncPartsListToQuoteTest() {
        factory = new L2I_DataFactory();
        List<L2I_Aircraft__c> acList = new List<L2I_Aircraft__c>(); //Added by Jan Geronga for W-001972
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        acc.L2I_Operator_Number__c = 'AB';
        update acc;
        System.assert(acc.Id != null, 'Named Customer Account must have an Id');

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');
    
        L2I_Aircraft_Type__c att = factory.createAircraftType(acc.Id, 123456);
        insert att;
    
        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule(acc.Id, att.Id);
        insert dsHeaderlList;
        
        //Added by Jan Geronga for W-001972: Start
        L2I_Aircraft__c ac1 = new L2I_Aircraft__c(Name = 'Test AC', Aircraft_Type__c = att.Id, L2I_Aircraft_Status__c = 'On Order',
                                                L2I_Serial_Number__c = '10017', L2I_Registration_Number__c = 'TEST123', L2I_Aircraft_Delivery_Date__c = system.today(),
                                                L2I_GPIN__c = 'A21N-12314', L2I_Operator__c = acc.Id);
        acList.add(ac1);
        
        L2I_Aircraft__c ac2 = new L2I_Aircraft__c(Name = 'Test AC1', Aircraft_Type__c = att.Id, L2I_Aircraft_Status__c = 'On Order',
                                                L2I_Serial_Number__c = '10017', L2I_Registration_Number__c = 'TEST1234', L2I_Aircraft_Delivery_Date__c = system.today(),
                                                L2I_GPIN__c = 'A21N-12315', L2I_Operator__c = acc.Id);
        acList.add(ac2);
        insert acList;
        //Added by Jan Geronga for W-001972: End
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
		
        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.Effectivity__c = 'TEST123'; //Added by Jan Geronga for W-001972
        salesOpp.Pending_Delete_Effectivity__c = 'TEST123'; //Added by Jan Geronga for W-001972
        salesOpp.Pending_Effectivity__c = 'TEST1234'; //Added by Jan Geronga for W-001972
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOpp;
        
        //Added by Jan Geronga for W-003548: Start
        PT_Program__c prog = new PT_Program__c();
        prog.Name = 'Test1234';
        prog.Program_Number__c = 'Test1234';
        insert prog;
        //Added by Jan Geronga for W-003548: End
        
        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine(dsHeaderlList.Id);
        dsLineList.Aircraft__c = ac1.Id; //Added by Jan Geronga for W-001972
        dsLineList.Original_Opportunity__c = salesOpp.Id;
        insert dsLineList;

        Boolean isPrimaryQuote = true;
        SBQQ__Quote__c quote = factory.createQuote('Draft', acc.Id, salesOpp.Id, isPrimaryQuote);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__BillingFrequency__c = 'Monthly';
        quote.SBQQ__StartDate__c = Date.today();
        quote.SubmittedDate__c = Date.today();//Added by Jan Geronga for W-003548
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today();//Added by Jan Geronga for W-003548
        quote.ApprovalStatus__c = 'Approved';
        insert quote;

        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;

        SBQQ__SolutionGroup__c sg1 = new SBQQ__SolutionGroup__c(
              Name = 'BC'
        );
        insert sg1;

        SBQQ__QuoteLineGroup__c qlg1 = new SBQQ__QuoteLineGroup__c(
              Name = sg.Name,
              SBQQ__SolutionGroup__c = sg.Id,
              SBQQ__Quote__c = quote.Id
        );
        insert qlg1;

        Product2 product = factory.createProduct('99999802', 'MediaServices', null, null, null);
        product.productCode = 'MCS BUNDLE';
        product.L2I_System_Type_Translation__c = 'A';
        insert product;

        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];

        SBQQ__QuoteLine__c ql1 = factory.createQuoteLine(quote.Id, prod.Id, null);
        ql1.SBQQ__Group__c = qlg1.Id;
        insert ql1;

        salesOpp.L2I_Delivery_Schedule__c = dsHeaderlList.Id;
        salesOpp.StageName = 'Closed Won';
        salesOpp.SBQQ__PrimaryQuote__c = quote.Id;
        salesOpp.L2I_Primary_System_Type__c = prod.Id; // Added by Khrisna for W-003434
        salesOpp.L2I_Program_Num__c = prog.Id;//Added by Jan Geronga for W-003548
        update salesOpp;

        salesOpp.L2I_Aircraft_Type__c = att.Id;
        salesOpp.L2I_Delivery_Schedule__c = dsHeaderlList.Id;
        salesOpp.L2I_Win_Loss_Date__c = Date.today();
        salesOpp.StageName = 'Handoff';
        salesOpp.PT_Parts_List_Revision_Number__c = 0;
        update salesOpp;

        PT_Install_Location__c inst = new PT_Install_Location__c(
                                                        Status__c = 'Active',
                                                        Solution_Group__c = sg.Id,
                                                        Quote_Line_Group__c = qlg1.id,
                                                        Part_List_Opportunity__c = salesOpp.Id,
                                                        Name = qlg1.Name,
                                                        PT_Install_Location__c = qlg1.Name
                                                    );
        insert inst;

        PT_Install_Location__c inst1 = new PT_Install_Location__c(
                                                        Status__c = 'Active',
                                                        Solution_Group__c = sg1.Id,
                                                        Part_List_Opportunity__c = salesOpp.Id,
                                                        Name = sg1.Name,
                                                        PT_Install_Location__c = sg1.Name
                                                    );
        insert inst1;

        Asset ast = new Asset(
                                    Status = 'Active',
                                    SBQQ__QuoteLine__c = ql1.id,
                                    SBQQ__LatestQuoteLine__c = ql1.id,
                                    PT_Install_Location__c = inst.id,
                                    Product2Id = ql1.SBQQ__Product__c,
                                    Quantity = ql1.SBQQ__Quantity__c,
                                    SBQQ__BundledQuantity__c = ql1.SBQQ__Quantity__c,
                                    Name = 'Test',
                                    PT_Configured_Quantity__c = 5,
                                    AccountId = acc.Id,
                                    PT_Status__c = 'Active',
                                    PT_isApproved__c = true,
                                    PT_Revision_Number__c = 0
                                    );
        insert ast;
        Test.startTest();
            PT_SyncPartsListEvent_TriggerFuntions.syncPartsListToQuote(salesOpp.Id);
        Test.stopTest();
    }
    
    @isTest
    static void syncPartsListToQuoteAddAssetTest() {
        factory = new L2I_DataFactory();
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        acc.L2I_Operator_Number__c = 'AB';
        update acc;
        System.assert(acc.Id != null, 'Named Customer Account must have an Id');

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');
    
        L2I_Aircraft_Type__c att = factory.createAircraftType(acc.Id, 123456);
        insert att;
    
        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule(acc.Id, att.Id);
        insert dsHeaderlList;
    
        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine(dsHeaderlList.Id);
        insert dsLineList;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;

        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOpp;

        Boolean isPrimaryQuote = true;
        SBQQ__Quote__c quote = factory.createQuote('Draft', acc.Id, salesOpp.Id, isPrimaryQuote);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__BillingFrequency__c = 'Monthly';
        quote.SBQQ__StartDate__c = Date.today();
        quote.SubmittedDate__c = Date.today();
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today();
        quote.ApprovalStatus__c = 'Approved';
        insert quote;

        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;

        SBQQ__SolutionGroup__c sg1 = new SBQQ__SolutionGroup__c(
              Name = 'BC'
        );
        insert sg1;

        SBQQ__QuoteLineGroup__c qlg1 = new SBQQ__QuoteLineGroup__c(
              Name = sg.Name,
              SBQQ__SolutionGroup__c = sg.Id,
              SBQQ__Quote__c = quote.Id
        );
        insert qlg1;

        Product2 product = factory.createProduct('99999802', 'MediaServices', null, null, null);
        product.productCode = 'MCS BUNDLE';
        product.L2I_System_Type_Translation__c = 'A';
        insert product;

        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];

        SBQQ__QuoteLine__c ql1 = factory.createQuoteLine(quote.Id, prod.Id, null);
        ql1.SBQQ__Group__c = qlg1.Id;
        insert ql1;
    
        salesOpp.L2I_Delivery_Schedule__c = dsHeaderlList.Id;
        salesOpp.StageName = 'Closed Won';
        salesOpp.SBQQ__PrimaryQuote__c = quote.Id;
        salesOpp.L2I_Primary_System_Type__c = prod.Id; // Added by Khrisna for W-003434
        update salesOpp;

        salesOpp.L2I_Aircraft_Type__c = att.Id;
        salesOpp.L2I_Delivery_Schedule__c = dsHeaderlList.Id;
        salesOpp.L2I_Win_Loss_Date__c = Date.today();
        salesOpp.StageName = 'Handoff';
        salesOpp.PT_Parts_List_Revision_Number__c = 0;
        update salesOpp;

        PT_Install_Location__c inst1 = new PT_Install_Location__c(
                                                        Status__c = 'Active',
                                                        Solution_Group__c = sg1.Id,
                                                        Part_List_Opportunity__c = salesOpp.Id,
                                                        Name = sg1.Name,
                                                        PT_Install_Location__c = sg1.Name
                                                    );
        insert inst1;
        
        SBQQ__Cost__c cost = new SBQQ__Cost__c(SBQQ__Product__c	= prod.Id, SBQQ__Active__c = true, SBQQ__UnitCost__c = 100);
        insert cost;

        Asset ast = new Asset(
                                    Status = 'Active',
                                    PT_Install_Location__c = inst1.id,
                                    Product2Id = ql1.SBQQ__Product__c,
                                    Name = 'Test',
                                    PT_Configured_Quantity__c = 5,
                                    AccountId = acc.Id,
                                    PT_Status__c = 'Active',
                                    PT_isApproved__c = true,
                                    PT_Revision_Number__c = 0
                                    );
        insert ast;
        Test.startTest();
            PT_SyncPartsListEvent_TriggerFuntions.syncPartsListToQuote(salesOpp.Id);
        Test.stopTest();
    }
}