/**
 *      @author       
 *      @date         
 *      @description  Test class for L2I_QuoteApprovalController
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *                                                      Initial
 *      MS Simplus Khrisna          01/13/2022          W-004060 Fix test classes
 *      MS Simplus Khrisna          03/31/2022          W-001727 Primary System Type Validation Rule
 */
@isTest
private class L2I_QuoteApprovalControllerTest {
    
    static L2I_DataFactory dt;
    
    static {
        dt = new L2I_DataFactory();
    }
    
    @testSetup
    private static void setupData() {
        List<Product2> prods = new List<Product2>();
        Product2 product = dt.createProduct('99999801', 'Connectivity', null, null, null);
        product.productCode = 'CONNECTIVITY BUNDLE';
        prods.add(product);
        
        product = dt.createProduct('99999802', 'MediaServices', null, null, null);
        product.productCode = 'MCS BUNDLE';
        prods.add(product);
        
        product = dt.createProduct('99999803', 'Live Television', null, null, null);
        product.productCode = 'TV/MEDIA BUNDLE';
        prods.add(product);
        
        product = dt.createProduct('99999804', 'Test YYY', null, null, null);
        product.productCode = 'TEST-Prod-YYYY';
        prods.add(product);
        
        product = dt.createProduct('99999805', 'Test Product Recuring', null, null, null);
        product.productCode = 'TBD-Recurring';
        prods.add(product);
        
        product = dt.createProduct('99999806', 'Test Product Tiered Pricing', null, null, null);
        product.productCode = 'PA-CPSTPAC-YYYY';
        prods.add(product);
        insert prods;
    }
    
    @isTest
    static void testSubmit() {
        SBQQ__Quote__c quote = dt.createQuote('draft', null, null, true);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.L2I_Proposal_Due_Date__c = System.today();
        quote.SubmittedDate__c = System.today();
        quote.L2I_Final_Proposal_Submission_Date__c = System.today();
        insert quote;
        
        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
        
        SBQQ__QuoteLine__c ql = dt.createQuoteLine(quote.Id, prod.Id, null);
        insert ql;
        
        Test.startTest();
        L2I_QuoteApprovalController.onSubmit(quote.Id);
        Test.stopTest();
        
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        System.assertEquals('Approved', quote.ApprovalStatus__c);
    }
    
    @isTest
    static void testRecall() {
        SBQQ__Quote__c quote = dt.createQuote('draft', null, null, true);
        quote.L2I_Proposal_Due_Date__c = System.today();
        quote.SubmittedDate__c = System.today();
        quote.L2I_Final_Proposal_Submission_Date__c = System.today();
        insert quote;
        
        Test.startTest();
        L2I_QuoteApprovalController.onRecall(quote.Id);
        Test.stopTest();
        
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        System.assertEquals('Recalled', quote.ApprovalStatus__c);
    }
    
    @isTest
    private static void testMediaServices() {
        SBQQ__Quote__c quote = dt.createQuote('draft', null, null, true);
        quote.L2I_Proposal_Due_Date__c = System.today();
        quote.SubmittedDate__c = System.today();
        quote.L2I_Final_Proposal_Submission_Date__c = System.today();
        insert quote;
        
        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
        
        SBQQ__QuoteLine__c ql = dt.createQuoteLine(quote.Id, prod.Id, null);
        insert ql;
        
        Product2 prodY = [Select Id From Product2 Where productCode = 'TEST-Prod-YYYY' LIMIT 1];
        
        insert dt.createQuoteLine(quote.Id, prodY.Id, ql.Id);
        
        Test.startTest();
        try {
            L2I_QuoteApprovalController.onSubmit(quote.Id);
        } catch (Exception e) {
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testConnectivity() {
        SBQQ__Quote__c quote = dt.createQuote('draft', null, null, true);
        quote.L2I_Proposal_Due_Date__c = System.today();
        quote.SubmittedDate__c = System.today();
        quote.L2I_Final_Proposal_Submission_Date__c = System.today();
        insert quote;
        
        Product2 prod = [Select Id From Product2 Where productCode = 'CONNECTIVITY BUNDLE' LIMIT 1];
        SBQQ__QuoteLine__c ql = dt.createQuoteLine(quote.Id, prod.Id, null);
        insert ql;
        
        Product2 prodY = [Select Id From Product2 Where productCode = 'TEST-Prod-YYYY' LIMIT 1];
        
        insert dt.createQuoteLine(quote.Id, prodY.Id, ql.Id);
        
        Test.startTest();
        try {
            L2I_QuoteApprovalController.onSubmit(quote.Id);
        } catch (Exception e) {
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testLiveTelevision() {
        SBQQ__Quote__c quote = dt.createQuote('draft', null, null, true);
        insert quote;
        
        Product2 prod = [Select Id From Product2 Where productCode = 'TV/MEDIA BUNDLE' LIMIT 1];
        SBQQ__QuoteLine__c ql = dt.createQuoteLine(quote.Id, prod.Id, null);
        insert ql;
        
        Product2 prodY = [Select Id From Product2 Where productCode = 'TEST-Prod-YYYY' LIMIT 1];
        
        insert dt.createQuoteLine(quote.Id, prodY.Id, ql.Id);
        
        Test.startTest();
        try {
            L2I_QuoteApprovalController.onSubmit(quote.Id);
        } catch (Exception e) {
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testPlaceholderPartValidation() {
        SBQQ__Quote__c quote = dt.createQuote('draft', null, null, true);
        quote.L2I_Proposal_Due_Date__c = System.today();
        quote.SubmittedDate__c = System.today();
        quote.L2I_Final_Proposal_Submission_Date__c = System.today();
        insert quote;
        
        Product2 prodY = [Select Id From Product2 Where productCode = 'TBD-Recurring' LIMIT 1];
        
        insert dt.createQuoteLine(quote.Id, prodY.Id, null);
        
        Test.startTest();
        try {
            L2I_QuoteApprovalController.onSubmit(quote.Id);
        } catch (Exception e) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSubmitWithoutLines() {
        SBQQ__Quote__c quote = dt.createQuote('draft', null, null, true);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.L2I_Proposal_Due_Date__c = System.today();
        quote.SubmittedDate__c = System.today();
        quote.L2I_Final_Proposal_Submission_Date__c = System.today();
        insert quote;
        
        Test.startTest();
        try {
            L2I_QuoteApprovalController.onSubmit(quote.Id);
        } catch (Exception e) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testTieredPricing() {
        SBQQ__Quote__c quote = dt.createQuote('draft', null, null, true);
        insert quote;
        
        Product2 prod = [Select Id From Product2 Where productCode = 'PA-CPSTPAC-YYYY' LIMIT 1];
        SBQQ__QuoteLine__c ql = dt.createQuoteLine(quote.Id, prod.Id, null);
        insert ql;
        
        Test.startTest();
        try {
            L2I_QuoteApprovalController.onSubmit(quote.Id);
        } catch (Exception e) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testRenewalQuoteTotals() {
        SBQQ__Quote__c quote = dt.createQuote('draft', null, null, true);
        quote.SBQQ__Status__c = 'Renewal';
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.L2I_Proposal_Due_Date__c = System.today();
        quote.SubmittedDate__c = System.today();
        quote.L2I_Final_Proposal_Submission_Date__c = System.today();
        insert quote;
        
        Test.startTest();
        try {
            L2I_QuoteApprovalController.onSubmit(quote.Id);
        } catch (Exception e) {
        }
        Test.stopTest();
    }

    @isTest
    static void testAirbusA350() {
        Account custAcct = dt.createCustomerAccount();
        insert custAcct;

        Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
        insert dealOpp;

        L2I_Aircraft_Type__c aircraftType =  dt.createAircraftType(custAcct.Id, 234567);
        aircraftType.Name = 'AIRBUS A350';
        insert aircraftType;

        // START Added by KElumba for W-004060
        PT_PMO_Groups__c pmoGroup = new  PT_PMO_Groups__c();
        pmoGroup.Name = 'Test12345';
        pmoGroup.Group_Type__c = 'Group';
        insert pmoGroup;

        PT_PMO_Groups__c pmoSubGroup = new  PT_PMO_Groups__c();
        pmoSubGroup.Name = 'Test456';
        pmoSubGroup.Group_Type__c = 'Sub Group';
        insert pmoSubGroup;

        User testUser;
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (currentUser) {
            Profile profile = [SELECT Id FROM Profile WHERE Name='PAC Sales' LIMIT 1];
            testUser = dt.createTestUser(null, profile.Id, 'First Name', 'Last Name');
            insert testUser;
        }
        // END W-004060
        
        Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Delivery', 15, custAcct.Id, dealOpp.Id);
        salesOpp.L2I_Aircraft_Type__c = aircraftType.Id;
        //salesOpp.PT_Part_List_Name__c = 'CPL123';
        //salesOpp.L2I_Product_Category__c = 'IFEC';
        // START Added by KElumba for W-004060
        salesOpp.Proposed_Program_Manager__c = testUser.Id;
        salesOpp.Proposed_PMO_Group__c = pmoGroup.Id;
        salesOpp.Proposed_PMO_SubGroup__c = pmoSubGroup.Id;
        // END W-004060
        insert salesOpp;
        
        SBQQ__Quote__c quote = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
        insert quote;

        Test.startTest();
        try {
            L2I_QuoteApprovalController.onSubmit(quote.Id);
        } catch (Exception e) {
        }
        Test.stopTest();
    }

    @isTest
    static void testBoeing787() {
        Account custAcct = dt.createCustomerAccount();
        insert custAcct;

        Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
        insert dealOpp;

        L2I_Aircraft_Type__c aircraftType =  dt.createAircraftType(custAcct.Id, 234567);
        aircraftType.Name = 'BOEING 787';
        insert aircraftType;

        // START Added by KElumba for W-004060
        PT_PMO_Groups__c pmoGroup = new  PT_PMO_Groups__c();
        pmoGroup.Name = 'Test12345';
        pmoGroup.Group_Type__c = 'Group';
        insert pmoGroup;

        PT_PMO_Groups__c pmoSubGroup = new  PT_PMO_Groups__c();
        pmoSubGroup.Name = 'Test456';
        pmoSubGroup.Group_Type__c = 'Sub Group';
        insert pmoSubGroup;

        User testUser;
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (currentUser) {
            Profile profile = [SELECT Id FROM Profile WHERE Name='PAC Sales' LIMIT 1];
            testUser = dt.createTestUser(null, profile.Id, 'First Name', 'Last Name');
            insert testUser;
        }
        // END W-004060

        Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Delivery', 15, custAcct.Id, dealOpp.Id);
        salesOpp.L2I_Aircraft_Type__c = aircraftType.Id;
        //salesOpp.PT_Part_List_Name__c = 'CPL123';
        //salesOpp.L2I_Product_Category__c = 'IFEC';
        // START Added by KElumba for W-004060
        salesOpp.Proposed_Program_Manager__c = testUser.Id;
        salesOpp.Proposed_PMO_Group__c = pmoGroup.Id;
        salesOpp.Proposed_PMO_SubGroup__c = pmoSubGroup.Id;
        // END W-004060
        insert salesOpp;
        
        SBQQ__Quote__c quote = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
        insert quote;

        Test.startTest();
        try {
            L2I_QuoteApprovalController.onSubmit(quote.Id);
        } catch (Exception e) {
        }
        Test.stopTest();
    }

    @isTest
    static void testIFECOpp() {
        L2I_Rule_Settings__c rule = new L2I_Rule_Settings__c(SetupOwnerId = UserInfo.getOrganizationId(), Enforce_Validation_Rule__c = true);
        insert rule;
        
        Account custAcct = dt.createCustomerAccount();
        insert custAcct;

        Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
        insert dealOpp;

        // Added for W-001727
        Product2 prodSysType = dt.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Handoff', 15, custAcct.Id, dealOpp.Id);
        //salesOpp.PT_Part_List_Name__c = 'CPL123';
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOpp;
        
        SBQQ__Quote__c quote = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
        insert quote;

        Test.startTest();
        try {
            L2I_QuoteApprovalController.onSubmit(quote.Id);
        } catch (Exception e) {
        }
        Test.stopTest();
    }
    
//    @isTest
//    static void testQuoteProposalNotGeneratedTest() {
//        Account custAcct = dt.createCustomerAccount();
//        insert custAcct;
//        Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
//        insert dealOpp;
//        Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Delivery', 15, custAcct.Id, dealOpp.Id);
//        salesOpp.PT_Part_List_Name__c = 'CPL123';
//        salesOpp.L2I_Product_Category__c = 'IFEC';
//        insert salesOpp;
//        System.debug('*** Sales Opp ' + salesOpp);
//        SBQQ__Quote__c quote = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
//        quote.L2I_Reviewed_PO_Required__c = true;
//        insert quote;
//        SBQQ__QuoteTemplate__c qtemplate = new SBQQ__QuoteTemplate__c(Name = 'Test Template');
//        insert qtemplate;
//
//        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
//
//        SBQQ__QuoteLine__c ql = dt.createQuoteLine(quote.Id, prod.Id, null);
//        insert ql;
//        Boolean errFound = false;
//        String msg = '';
//        try {
//            Test.startTest();
//            L2I_QuoteApprovalController.onSubmit(quote.Id);
//            Test.stopTest();
//        } catch (Exception ex) {
//            errFound = true;
//            msg = ex.getMessage();
//        }
//        // error created is: Methods defined as TestMethod do not support Web service callouts
//        System.assertEquals(true, errFound, msg);
//    }
    
//    @isTest
//    static void testQuoteProposalGeneratedTest() {
//        Account custAcct = dt.createCustomerAccount();
//        insert custAcct;
//        Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
//        insert dealOpp;
//        Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Handoff', 15, custAcct.Id, dealOpp.Id);
//        salesOpp.L2I_Product_Category__c = 'IFEC';
//        insert salesOpp;
//        salesOpp.StageName = 'Delivery';
//        update salesOpp;
//        System.debug('*** Sales Opp ' + salesOpp);
//        SBQQ__Quote__c quote = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
//        quote.L2I_Reviewed_PO_Required__c = true;
//        insert quote;
//        SBQQ__QuoteTemplate__c qtemplate = new SBQQ__QuoteTemplate__c(Name = 'Test Template');
//        insert qtemplate;
//        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
//              Name = 'ALT'
//        );
//        insert sg;
//        SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c(
//              SBQQ__SolutionGroup__c = sg.Id,
//              SBQQ__Quote__c = quote.Id
//        );
//        insert qlg;
//
//        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
//
//        SBQQ__QuoteLine__c ql = dt.createQuoteLine(quote.Id, prod.Id, null);
//        ql.SBQQ__Group__c = qlg.Id;
//        insert ql;
//        Boolean errFound = false;
//
//        try {
//            Test.startTest();
//            L2I_QuoteApprovalController.onSubmit(quote.Id);
//            Test.stopTest();
//        } catch (Exception ex) {
//            System.debug('*** ex ' + ex.getMessage() + ' ' + ex.getStackTraceString());
//            errFound = true;
//        }
//
//        // error created is: Methods defined as TestMethod do not support Web service callouts
//        System.assertEquals(true, errFound);
//    }
    
//    @isTest
//    static void testBuildChangeRcdsQtyChgTest() {
//        Account custAcct = dt.createCustomerAccount();
//        insert custAcct;
//        Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
//        insert dealOpp;
//        Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Handoff', 15, custAcct.Id, dealOpp.Id);
//        salesOpp.L2I_Product_Category__c = 'IFEC';
//        insert salesOpp;
//        salesOpp.StageName = 'Delivery';
//        update salesOpp;
//        System.debug('*** Sales Opp ' + salesOpp);
//        SBQQ__Quote__c quote1 = dt.createQuote('draft', custAcct.Id, salesOpp.Id, false);
//        quote1.L2I_Reviewed_PO_Required__c = true;
//        quote1.ApprovalStatus__c = 'Approved';
//        insert quote1;
//        SBQQ__Quote__c quote2 = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
//        quote2.L2I_Reviewed_PO_Required__c = true;
//        quote2.ApprovalStatus__c = 'Pending';
//        quote2.SBQQ__Source__c = quote1.Id;
//        insert quote2;
//        SBQQ__QuoteTemplate__c qtemplate = new SBQQ__QuoteTemplate__c(Name = 'Test Template');
//        insert qtemplate;
//        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
//              Name = 'ALT'
//        );
//        insert sg;
//        SBQQ__QuoteLineGroup__c qlg1 = new SBQQ__QuoteLineGroup__c(
//              Name = sg.Name,
//              SBQQ__SolutionGroup__c = sg.Id,
//              SBQQ__Quote__c = quote1.Id
//        );
//        insert qlg1;
//
//        SBQQ__QuoteLineGroup__c qlg2 = new SBQQ__QuoteLineGroup__c(
//              Name = sg.Name,
//              SBQQ__SolutionGroup__c = sg.Id,
//              SBQQ__Quote__c = quote2.Id
//        );
//        insert qlg2;
//
//        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
//
//        SBQQ__QuoteLine__c ql1 = dt.createQuoteLine(quote1.Id, prod.Id, null);
//        ql1.SBQQ__Group__c = qlg1.Id;
//        ql1.SBQQ__Quantity__c = 4;
//        insert ql1;
//        System.debug('*** ql1 ' + ql1);
//
//        SBQQ__QuoteLine__c ql2 = dt.createQuoteLine(quote2.Id, prod.Id, null);
//        ql2.SBQQ__Group__c = qlg2.Id;
//        ql2.SBQQ__Quantity__c = 3;
//        ql2.SBQQ__Source__c = ql1.Id;
//        insert ql2;
//        System.debug('*** ql2 ' + ql2);
//
//        Test.startTest();
//        L2I_QuoteService.buildPartsListRevisions(quote2.Id);
//        Test.stopTest();
//        PT_Parts_List_Revision__c plr = [
//              SELECT Id, Name, Parts_List__c,
//                    Revised_Action__c,
//                    Revised_Description__c,
//                    Revised_Details__c,
//                    Revised_Element__c
//              FROM PT_Parts_List_Revision__c
//        ];
//        System.assertEquals(1, [SELECT COUNT() FROM PT_Parts_List_Revision__c]);
//        System.debug('*** plr ' + plr);
//        System.assertEquals('Change Quantity', plr.Revised_Action__c);
//    }
    
//    @isTest
//    static void testBuildChangeRcdsChgPNTest() {
//        Account custAcct = dt.createCustomerAccount();
//        insert custAcct;
//        Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
//        insert dealOpp;
//        Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Handoff', 15, custAcct.Id, dealOpp.Id);
//        salesOpp.L2I_Product_Category__c = 'IFEC';
//        insert salesOpp;
//        salesOpp.StageName = 'Delivery';
//        update salesOpp;
//        System.debug('*** Sales Opp ' + salesOpp);
//        SBQQ__Quote__c quote1 = dt.createQuote('draft', custAcct.Id, salesOpp.Id, false);
//        quote1.L2I_Reviewed_PO_Required__c = true;
//        quote1.ApprovalStatus__c = 'Approved';
//        insert quote1;
//        SBQQ__Quote__c quote2 = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
//        quote2.L2I_Reviewed_PO_Required__c = true;
//        quote2.ApprovalStatus__c = 'Pending';
//        quote2.SBQQ__Source__c = quote1.Id;
//        insert quote2;
//        SBQQ__QuoteTemplate__c qtemplate = new SBQQ__QuoteTemplate__c(Name = 'Test Template');
//        insert qtemplate;
//        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
//              Name = 'ALT'
//        );
//        insert sg;
//        SBQQ__QuoteLineGroup__c qlg1 = new SBQQ__QuoteLineGroup__c(
//              Name = sg.Name,
//              SBQQ__SolutionGroup__c = sg.Id,
//              SBQQ__Quote__c = quote1.Id
//        );
//        insert qlg1;
//
//        SBQQ__QuoteLineGroup__c qlg2 = new SBQQ__QuoteLineGroup__c(
//              Name = sg.Name,
//              SBQQ__SolutionGroup__c = sg.Id,
//              SBQQ__Quote__c = quote2.Id
//        );
//        insert qlg2;
//
//        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
//        Product2 prod2 = [Select Id From Product2 Where productCode = 'CONNECTIVITY BUNDLE' LIMIT 1];
//
//        SBQQ__QuoteLine__c ql1 = dt.createQuoteLine(quote1.Id, prod.Id, null);
//        ql1.SBQQ__Group__c = qlg1.Id;
//        insert ql1;
//        System.debug('*** ql1 ' + ql1);
//
//        SBQQ__QuoteLine__c ql2 = dt.createQuoteLine(quote2.Id, prod2.Id, null);
//        ql2.SBQQ__Group__c = qlg2.Id;
//        ql2.SBQQ__Source__c = ql1.Id;
//        insert ql2;
//        System.debug('*** ql2 ' + ql2);
//
//        Test.startTest();
//        L2I_QuoteService.buildPartsListRevisions(quote2.Id);
//        Test.stopTest();
//        PT_Parts_List_Revision__c plr = [
//              SELECT Id, Name, Parts_List__c,
//                    Revised_Action__c,
//                    Revised_Description__c,
//                    Revised_Details__c,
//                    Revised_Element__c
//              FROM PT_Parts_List_Revision__c
//        ];
//        System.assertEquals(1, [SELECT COUNT() FROM PT_Parts_List_Revision__c]);
//        System.debug('*** plr ' + plr);
//        System.assertEquals('Replace P/N', plr.Revised_Action__c);
//    }
    
//    @isTest
//    static void testBuildChangeRcdsMovePNTest() {
//        Account custAcct = dt.createCustomerAccount();
//        insert custAcct;
//        Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
//        insert dealOpp;
//        Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Handoff', 15, custAcct.Id, dealOpp.Id);
//        salesOpp.L2I_Product_Category__c = 'IFEC';
//        insert salesOpp;
//        salesOpp.StageName = 'Delivery';
//        update salesOpp;
//        System.debug('*** Sales Opp ' + salesOpp);
//        SBQQ__Quote__c quote1 = dt.createQuote('draft', custAcct.Id, salesOpp.Id, false);
//        quote1.L2I_Reviewed_PO_Required__c = true;
//        quote1.ApprovalStatus__c = 'Approved';
//        insert quote1;
//        SBQQ__Quote__c quote2 = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
//        quote2.L2I_Reviewed_PO_Required__c = true;
//        quote2.ApprovalStatus__c = 'Pending';
//        quote2.SBQQ__Source__c = quote1.Id;
//        insert quote2;
//        SBQQ__QuoteTemplate__c qtemplate = new SBQQ__QuoteTemplate__c(Name = 'Test Template');
//        insert qtemplate;
//        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
//              Name = 'ALT'
//        );
//        insert sg;
//        SBQQ__SolutionGroup__c sg2 = new SBQQ__SolutionGroup__c(
//              Name = 'BCC'
//        );
//        insert sg2;
//        SBQQ__QuoteLineGroup__c qlg1 = new SBQQ__QuoteLineGroup__c(
//              Name = sg.Name,
//              SBQQ__SolutionGroup__c = sg.Id,
//              SBQQ__Quote__c = quote1.Id
//        );
//        insert qlg1;
//
//        SBQQ__QuoteLineGroup__c qlg2 = new SBQQ__QuoteLineGroup__c(
//              Name = sg2.Name,
//              SBQQ__SolutionGroup__c = sg2.Id,
//              SBQQ__Quote__c = quote2.Id
//        );
//        insert qlg2;
//
//        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
//        Product2 prod2 = [Select Id From Product2 Where productCode = 'CONNECTIVITY BUNDLE' LIMIT 1];
//
//        SBQQ__QuoteLine__c ql1 = dt.createQuoteLine(quote1.Id, prod.Id, null);
//        ql1.SBQQ__Group__c = qlg1.Id;
//        insert ql1;
//        System.debug('*** ql1 ' + ql1);
//
//        SBQQ__QuoteLine__c ql2 = dt.createQuoteLine(quote2.Id, prod.Id, null);
//        ql2.SBQQ__Group__c = qlg2.Id;
//        ql2.SBQQ__Source__c = ql1.Id;
//        insert ql2;
//        System.debug('*** ql2 ' + ql2);
//
//        Test.startTest();
//        L2I_QuoteService.buildPartsListRevisions(quote2.Id);
//        Test.stopTest();
//        PT_Parts_List_Revision__c plr = [
//              SELECT Id, Name, Parts_List__c,
//                    Revised_Action__c,
//                    Revised_Description__c,
//                    Revised_Details__c,
//                    Revised_Element__c
//              FROM PT_Parts_List_Revision__c
//        ];
//        System.assertEquals(1, [SELECT COUNT() FROM PT_Parts_List_Revision__c]);
//        System.debug('*** plr ' + plr);
//        System.assertEquals('Moved P/N', plr.Revised_Action__c);
//    }
    
//    @isTest
//    static void testBuildChangeRcdsAddDeleteTest() {
//        Account custAcct = dt.createCustomerAccount();
//        insert custAcct;
//        Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
//        insert dealOpp;
//        Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Handoff', 15, custAcct.Id, dealOpp.Id);
//        salesOpp.L2I_Product_Category__c = 'IFEC';
//        insert salesOpp;
//        salesOpp.StageName = 'Delivery';
//        update salesOpp;
//        System.debug('*** Sales Opp ' + salesOpp);
//        SBQQ__Quote__c quote1 = dt.createQuote('draft', custAcct.Id, salesOpp.Id, false);
//        quote1.L2I_Reviewed_PO_Required__c = true;
//        quote1.ApprovalStatus__c = 'Approved';
//        insert quote1;
//        SBQQ__Quote__c quote2 = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
//        quote2.L2I_Reviewed_PO_Required__c = true;
//        quote2.ApprovalStatus__c = 'Pending';
//        quote2.SBQQ__Source__c = quote1.Id;
//        insert quote2;
//        SBQQ__QuoteTemplate__c qtemplate = new SBQQ__QuoteTemplate__c(Name = 'Test Template');
//        insert qtemplate;
//        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
//              Name = 'ALT'
//        );
//        insert sg;
//        SBQQ__SolutionGroup__c sg2 = new SBQQ__SolutionGroup__c(
//              Name = 'BCC'
//        );
//        insert sg2;
//        SBQQ__QuoteLineGroup__c qlg1 = new SBQQ__QuoteLineGroup__c(
//              Name = sg.Name,
//              SBQQ__SolutionGroup__c = sg.Id,
//              SBQQ__Quote__c = quote1.Id
//        );
//        insert qlg1;
//
//        SBQQ__QuoteLineGroup__c qlg2 = new SBQQ__QuoteLineGroup__c(
//              Name = sg2.Name,
//              SBQQ__SolutionGroup__c = sg2.Id,
//              SBQQ__Quote__c = quote2.Id
//        );
//        insert qlg2;
//
//        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
//        Product2 prod2 = [Select Id From Product2 Where productCode = 'CONNECTIVITY BUNDLE' LIMIT 1];
//
//        SBQQ__QuoteLine__c ql1 = dt.createQuoteLine(quote1.Id, prod.Id, null);
//        ql1.SBQQ__Group__c = qlg1.Id;
//        insert ql1;
//        System.debug('*** ql1 ' + ql1);
//
//        SBQQ__QuoteLine__c ql3 = dt.createQuoteLine(quote2.Id, prod2.Id, null);
//        ql3.SBQQ__Group__c = qlg1.Id;
//        insert ql3;
//
//        Test.startTest();
//        L2I_QuoteService.buildPartsListRevisions(quote2.Id);
//        Test.stopTest();
//        List<PT_Parts_List_Revision__c> plrList = [
//              SELECT Id, Name, Parts_List__c,
//                    Revised_Action__c,
//                    Revised_Description__c,
//                    Revised_Details__c,
//                    Revised_Element__c
//              FROM PT_Parts_List_Revision__c
//        ];
//        System.assertEquals(2, [SELECT COUNT() FROM PT_Parts_List_Revision__c]);
//        System.assertEquals(1, [SELECT COUNT() FROM PT_Parts_List_Revision__c WHERE Revised_Action__c = 'Added']);
//        System.assertEquals(1, [SELECT COUNT() FROM PT_Parts_List_Revision__c WHERE Revised_Action__c = 'Deleted']);
//        System.debug('*** plrList ' + plrList);
//    }
}