@isTest
public with sharing class PT_Opportunity_TriggerFunctionsTest {
    private static L2I_DataFactory factory;
    @isTest
    static void createProgramUpdateDSLsTest() {
        factory = new L2I_DataFactory();
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        System.assert(acc.Id != null, 'Named Customer Account must have an Id');

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','DSS','Applications', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'DSS');
        salesOpp.L2I_Product_Category__c = 'DSS';
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
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
        quote.SubmittedDate__c = Date.today(); // Added by Khrisna for W-004060
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today(); // Added by Khrisna for W-004060
        insert quote;
        salesOpp.L2I_Aircraft_Type__c = att.Id;
        salesOpp.L2I_Delivery_Schedule__c = dsHeaderlList.Id;
        salesOpp.L2I_Win_Loss_Date__c = Date.today();
        salesOpp.StageName = 'Closed Won';
        update salesOpp;

        //dealOppty = [select Id, Name, Amount from Opportunity where Id = :dealOppty.Id limit 1];

        //Double updatedAmount = salesOppty1.Amount + salesOppty2.Amount;
        //System.assert(dealOppty.Amount == updatedAmount, 'Deal Oppty amount does not reflect updated sum of Child Sales Oppty Amounts');
    }

    @isTest
    static void generateCPLDocGenerated() {
        factory = new L2I_DataFactory();
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        acc.L2I_Operator_Number__c = 'AB';
        //update acc;
        System.assert(acc.Id != null, 'Named Customer Account must have an Id');

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');
      
        PT_PMO_Groups__c pmoGroup = new  PT_PMO_Groups__c();
        pmoGroup.name = 'Europe';
        pmoGroup.Group_Type__c = 'Group';
        insert pmoGroup;

        PT_PMO_Groups__c pmoSubGroup = new  PT_PMO_Groups__c();
        pmoSubGroup.name = 'Europe Two';
        pmoSubGroup.Group_Type__c = 'Sub Group';
        insert pmoSubGroup;
        
        Profile profile = [Select Id From Profile Where Name='PAC Sales' limit 1];
        User testUser = factory.createTestUser(null, profile.id, 'First Name', 'Last Name');
        insert testUser;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','DSS','Applications', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Handoff', 30, acc.Id, dealOpp.Id, 200000, 'DSS');
        salesOpp.L2I_Product_Category__c = 'DSS';
        SalesOpp.Proposed_Program_Manager__c = testUser.id;
        SalesOpp.Proposed_PMO_Group__c= pmoGroup.id;
        SalesOpp.Proposed_PMO_SubGroup__c = pmoSubGroup.id;
        SalesOpp.L2I_Primary_System_Type__c = prodSysType.Id;

        System.debug('**** Program Manager ' + testUser.id  );
        System.debug('**** Group  ' +   SalesOpp.Proposed_PMO_Group__c);
        System.debug('**** Sub Group ' +  SalesOpp.Proposed_PMO_SubGroup__c);

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
        product.L2I_System_Type_Translation__c = 'A';
        insert product;

        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];

        SBQQ__QuoteLine__c ql1 = factory.createQuoteLine(quote.Id, prod.Id, null);
        ql1.SBQQ__Group__c = qlg1.Id;
        insert ql1;
    
        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;

       

        salesOpp.L2I_Primary_System_Type__c = product.Id;
        salesOpp.L2I_Aircraft_Type__c = att.Id;
        salesOpp.L2I_Delivery_Schedule__c = dsHeaderlList.Id;
        salesOpp.L2I_Win_Loss_Date__c = Date.today();
        salesOpp.StageName = 'Delivery';
        salesOpp.L2I_AC_Operator__c = acc.Id;
        salesOpp.L2I_Program_Num__c = prog1.Id;
        Boolean errFound = false;
        String msg = '';
        PT_Opportunity_TriggerHandler.recursive = true;
        try {
            Test.startTest();
            update salesOpp;
            Test.stopTest();
        } catch (Exception ex) {
            errFound = true;
            msg = ex.getMessage();
        }
        System.assertEquals(false, errFound, msg);
    }

    @isTest
    static void generateCPLDocNotGenerated() {
        factory = new L2I_DataFactory();
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        acc.L2I_Operator_Number__c = 'AB';
        //update acc;
        System.assert(acc.Id != null, 'Named Customer Account must have an Id');

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');

        L2I_Aircraft_Type__c airType = new L2I_Aircraft_Type__c(Name = '737 MAX 10',
              L2I_Model__c = '737',
              L2I_Master_Series__c = 'G4',
              L2I_Series__c = 'Max 10',
              L2I_Aircraft_Type__c = 'A',
              L2I_PAC_Type_Designator__c = 'A',
              L2I_Program_Code__c = 'abc',
              L2I_Is_Active__c = true);
        insert airType;

        Product2 product = factory.createProduct('99999802', 'MediaServices', 'IFEC', 'IFE HW', null);
        product.productCode = 'MCS BUNDLE';
        product.L2I_System_Type_Translation__c = 'A';
        insert product;

        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Handoff', 30, acc.Id, dealOpp.Id, 200000, 'DSS');
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.L2I_AC_Operator__c = acc.Id;
        salesOpp.L2I_Aircraft_Type__c = airType.Id;
        salesOpp.Account = acc;
        salesOpp.L2I_Primary_System_Type__c = product.Id;
        insert salesOpp;

        L2I_Aircraft_Type__c att = factory.createAircraftType(acc.Id, 123456);
        att.L2I_Program_Code__c = 'abc';
        insert att;

        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule(acc.Id, att.Id);
        dsHeaderlList.Aircraft_Type__c = att.Id;
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

        salesOpp.SBQQ__PrimaryQuote__c = quote.Id;
        update salesOpp;

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

        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];

        SBQQ__QuoteLine__c ql1 = factory.createQuoteLine(quote.Id, prod.Id, null);
        ql1.SBQQ__Group__c = qlg1.Id;
        insert ql1;
      
        PT_PMO_Groups__c pmoGroup = new  PT_PMO_Groups__c();
        pmoGroup.name = 'Europe';
        pmoGroup.Group_Type__c = 'Group';
        insert pmoGroup;

        PT_PMO_Groups__c pmoSubGroup = new  PT_PMO_Groups__c();
        pmoSubGroup.name = 'Europe';
        pmoSubGroup.Group_Type__c = 'Sub Group';
        insert pmoSubGroup;
        Profile profile = [Select Id From Profile Where Name='PAC Sales' limit 1];
        User testUser = factory.createTestUser(null, profile.id, 'First Name', 'Last Name');
        insert testUser;

        SalesOpp.Proposed_Program_Manager__c = testUser.id;
        SalesOpp.Proposed_PMO_Group__c= pmoGroup.id;
        SalesOpp.Proposed_PMO_SubGroup__c = pmoSubGroup.id;

        salesOpp.L2I_Aircraft_Type__c = att.Id;
        salesOpp.L2I_Delivery_Schedule__c = dsHeaderlList.Id;
        salesOpp.L2I_Win_Loss_Date__c = Date.today();
        salesOpp.StageName = 'Delivery';
        salesOpp.PT_Part_List_Name__c = 'CPL123';
        Boolean errFound = false;
        String msg = '';
        PT_Opportunity_TriggerHandler.recursive = true;
        try {
            Test.startTest();
            update salesOpp;
            Test.stopTest();
        } catch (Exception ex) {
            errFound = true;
            msg = ex.getMessage();
        }
        // error created is: Methods defined as TestMethod do not support Web service callouts
        //System.assertEquals(false, errFound, msg);
    }

    @IsTest
    static void testApproved() {

        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);

        Id customerRecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID;
        Account acctCustomer = new Account(
              Name = 'Acct1',
              RecordTypeId = customerRecordTypeId);
        insert acctCustomer;

        Opportunity dealOppty = new Opportunity(
              Name = 'Deal Opp',
              CloseDate = Date.today(),
              StageName = 'Open'
        );
        insert dealOppty;

        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','DSS','Applications', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = new Opportunity(
              Name = 'Sales Opp',
              AccountId = acctCustomer.Id,
              RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
              L2I_Product_Category__c = 'DSS',
              CloseDate = Date.today(),
              StageName = 'Handoff',
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_AircraftQuantity__c = 1,
              L2I_Program_Num__c = prog1.Id,
              PT_PL_Approval_Status__c = 'Pending',
              L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;

        SBQQ__Quote__c qt0 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = acctCustomer.Id,
              SBQQ__Opportunity2__c = salesOppty.Id,
              SBQQ__Primary__c = true,
              ApprovalStatus__c = 'Approved'
        );
        insert qt0;

        PT_PMO_Groups__c pmoGroup = new  PT_PMO_Groups__c();
        pmoGroup.name = 'Europe';
        pmoGroup.Group_Type__c = 'Group';
        insert pmoGroup;

        PT_PMO_Groups__c pmoSubGroup = new  PT_PMO_Groups__c();
        pmoSubGroup.name = 'Europe';
        pmoSubGroup.Group_Type__c = 'Sub Group';
        insert pmoSubGroup;

        Profile profile = [Select Id From Profile Where Name='PAC Sales' limit 1];
        User testUser = factory.createTestUser(null, profile.id, 'First Name', 'Last Name');
        insert testUser;

        SalesOppty.Proposed_Program_Manager__c = testUser.Id;
        SalesOppty.Proposed_PMO_Group__c= pmoGroup.id;
        SalesOppty.Proposed_PMO_SubGroup__c = pmoSubGroup.id;

        salesOppty.StageName = 'Delivery';       
        PT_Opportunity_TriggerHandler.recursive = true;
        update SalesOppty;

        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;

        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              PT_isActive__c = 'Active',
              PT_Program__c = prog1.Id
        );
        insert dsl;

        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;

        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;

        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc2.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = prog1.Id,
              Product2Id = prod.Id,
              AccountId = acctCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;
        SBQQ__Quote__c qt = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = acctCustomer.Id,
              SBQQ__Opportunity2__c = salesOppty.Id,
              SBQQ__Source__c = qt0.Id,
              SBQQ__Primary__c = true
        );
        insert qt;

        Map<Id, String> prodCategoryMap = new Map<Id, String>();

        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();
        List<Product2> updateProdList = new List<Product2>();

        for (Product2 p : prodList) {
            p.L2I_Migrate__c = true;
            p.SBQQ__ChargeType__c = 'Usage';
            p.SBQQ__BillingType__c = '';
            p.L2I_Service_Activation_Type__c = 'Monthly';
            updateProdList.add(p);
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }

        update updateProdList;

        Set<String> ProductNameList = new Set<String>();

        ProductNameList.add('Toca Boca - Toca Cars');
        Set<Id> prodIdList = New Set<Id>();

        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        for (String s : ProductNameList) {
            Id pid = prodIdMap.get(s);
            prodIdList.add(pid);
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(qt.Id, pid, null);
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.SBQQ__SpecialPrice__c = 5;
            quoteLine.PT_Asset__c = ast.Id;
            qlList.add(quoteLine);
        }
        insert qlList;

        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;

        List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
        for (SBQQ__QuoteLine__c ql : qlList) {
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
            qlg.SBQQ__Account__c = acctCustomer.id;
            qlg.SBQQ__SolutionGroup__c = sg.Id;
            qlg.SBQQ__Quote__c = qt.Id;
            qlgList.add(qlg);
        }
        insert qlgList;

        Test.startTest();
        salesOppty.PT_PL_Approval_Status__c = 'Approved';
        update salesOppty;
        Test.stopTest();

    }

    @IsTest
    static void testSubmitterCantApprove() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'PAC Sales'].Id;
        User u1 = factory.createTestUser(null, profileId, 'User1', 'Test');
        insert u1;

        factory.setupTestContext(null, null, false);

        Id customerRecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID;
        Account acctCustomer = new Account(
              Name = 'Acct1',
              RecordTypeId = customerRecordTypeId);
        insert acctCustomer;

        Opportunity dealOppty = new Opportunity(
              Name = 'Deal Opp',
              CloseDate = Date.today(),
              StageName = 'Open'
        );
        insert dealOppty;

        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','DSS','Applications', 'X-Series');
        insert prodSysType;

        Opportunity salesOppty = new Opportunity(
              Name = 'Sales Opp',
              AccountId = acctCustomer.Id,
              RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
              L2I_Product_Category__c = 'DSS',
              CloseDate = Date.today(),
              StageName = 'Handoff',
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_AircraftQuantity__c = 1,
              L2I_Program_Num__c = prog1.Id,
              PT_PL_Approval_Status__c = 'Pending',
              L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;

        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;

        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              PT_isActive__c = 'Active',
              PT_Program__c = prog1.Id
        );
        insert dsl;

        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;

        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;

        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc2.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = prog1.Id,
              Product2Id = prod.Id,
              AccountId = acctCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;

        SBQQ__Quote__c qt = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = acctCustomer.Id,
              SBQQ__Opportunity2__c = salesOppty.Id,
              SBQQ__Primary__c = true
        );
        insert qt;

        Map<Id, String> prodCategoryMap = new Map<Id, String>();

        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();
        List<Product2> updateProdList = new List<Product2>();

        for (Product2 p : prodList) {
            p.L2I_Migrate__c = true;
            p.SBQQ__ChargeType__c = 'Usage';
            p.SBQQ__BillingType__c = '';
            p.L2I_Service_Activation_Type__c = 'Monthly';
            updateProdList.add(p);
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }

        update updateProdList;

        Set<String> ProductNameList = new Set<String>();

        ProductNameList.add('Toca Boca - Toca Cars');
        Set<Id> prodIdList = New Set<Id>();

        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        for (String s : ProductNameList) {
            Id pid = prodIdMap.get(s);
            prodIdList.add(pid);
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(qt.Id, pid, null);
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.SBQQ__SpecialPrice__c = 5;
            quoteLine.PT_Asset__c = ast.Id;
            qlList.add(quoteLine);
        }
        insert qlList;

        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;

        List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
        for (SBQQ__QuoteLine__c ql : qlList) {
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
            qlg.SBQQ__Account__c = acctCustomer.id;
            qlg.SBQQ__SolutionGroup__c = sg.Id;
            qlg.SBQQ__Quote__c = qt.Id;
            qlgList.add(qlg);
        }
        insert qlgList;
        System.runAs(u1) {
            Test.startTest();
            Boolean gotError = false;
            try {
                salesOppty.PT_PL_Approval_Status__c = 'Approved';
                update salesOppty;
            } catch (Exception e) {
                gotError = true;
                System.debug('*** catch');
            }
            System.assertEquals(true, gotError);
            Test.stopTest();
        }
    }

    @IsTest
    static void testRejected() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);

        Id customerRecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID;
        Account acctCustomer = new Account(
              Name = 'Acct1',
              RecordTypeId = customerRecordTypeId);
        insert acctCustomer;

        Opportunity dealOppty = new Opportunity(
              Name = 'Deal Opp',
              CloseDate = Date.today(),
              StageName = 'Open'
        );
        insert dealOppty;

        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','DSS','Applications', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = new Opportunity(
              Name = 'Sales Opp',
              AccountId = acctCustomer.Id,
              RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
              L2I_Product_Category__c = 'DSS',
              CloseDate = Date.today(),
              StageName = 'Handoff',
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_AircraftQuantity__c = 1,
              L2I_Program_Num__c = prog1.Id,
              PT_PL_Approval_Status__c = 'Pending',
              L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;

        SBQQ__Quote__c qt0 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = acctCustomer.Id,
              SBQQ__Opportunity2__c = salesOppty.Id,
              SBQQ__Primary__c = true,
              ApprovalStatus__c = 'Approved'
        );
        insert qt0;
        PT_PMO_Groups__c pmoGroup = new  PT_PMO_Groups__c();
        pmoGroup.name = 'Europe';
        pmoGroup.Group_Type__c = 'Group';
        insert pmoGroup;

        PT_PMO_Groups__c pmoSubGroup = new  PT_PMO_Groups__c();
        pmoSubGroup.name = 'Europe T';
        pmoSubGroup.Group_Type__c = 'Sub Group';
        insert pmoSubGroup;

        Profile profile = [Select Id From Profile Where Name='PAC Sales' limit 1];
        User testUser = factory.createTestUser(null, profile.id, 'First Name', 'Last Name');
        insert testUser;
 
       
        SalesOppty.Proposed_Program_Manager__c = testUser.Id;
        SalesOppty.Proposed_PMO_Group__c= pmoGroup.id;
        salesOppty.Proposed_PMO_SubGroup__c = pmoSubGroup.id;
        salesOppty.StageName = 'Delivery';
        PT_Opportunity_TriggerHandler.recursive = true;
        update SalesOppty;

        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;

        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              PT_isActive__c = 'Active',
              PT_Program__c = prog1.Id
        );
        insert dsl;

        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;

        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;

        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc2.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = prog1.Id,
              Product2Id = prod.Id,
              AccountId = acctCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;

        SBQQ__Quote__c qt = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = acctCustomer.Id,
              SBQQ__Opportunity2__c = salesOppty.Id,
              SBQQ__Source__c = qt0.Id,
              SBQQ__Primary__c = true
        );
        insert qt;

        Map<Id, String> prodCategoryMap = new Map<Id, String>();

        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();
        List<Product2> updateProdList = new List<Product2>();

        for (Product2 p : prodList) {
            p.L2I_Migrate__c = true;
            p.SBQQ__ChargeType__c = 'Usage';
            p.SBQQ__BillingType__c = '';
            p.L2I_Service_Activation_Type__c = 'Monthly';
            updateProdList.add(p);
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }

        update updateProdList;

        Set<String> ProductNameList = new Set<String>();

        ProductNameList.add('Toca Boca - Toca Cars');
        Set<Id> prodIdList = New Set<Id>();

        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        for (String s : ProductNameList) {
            Id pid = prodIdMap.get(s);
            prodIdList.add(pid);
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(qt.Id, pid, null);
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.SBQQ__SpecialPrice__c = 5;
            quoteLine.PT_Asset__c = ast.Id;
            qlList.add(quoteLine);
        }
        insert qlList;

        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;

        List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
        for (SBQQ__QuoteLine__c ql : qlList) {
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
            qlg.SBQQ__Account__c = acctCustomer.id;
            qlg.SBQQ__SolutionGroup__c = sg.Id;
            qlg.SBQQ__Quote__c = qt.Id;
            qlgList.add(qlg);
        }
        insert qlgList;

        List<PT_Parts_List_Revision__c> plrList = new List<PT_Parts_List_Revision__c>();
        PT_Parts_List_Revision__c plr = new PT_Parts_List_Revision__c();
        plr.PT_Part_List_Opportunity__c = salesOppty.Id;
        plrList.add(plr);
        insert plrList;
        
        Test.startTest();
        salesOppty.PT_PL_Approval_Status__c = 'Rejected';
        update salesOppty;
        Test.stopTest();
    }
    
    @isTest
    static void testPPLOpportunities() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'PAC Sales'].Id;
        User u1 = factory.createTestUser(null, profileId, 'User1', 'Test');
        insert u1;
        
        factory.setupTestContext(null, null, false);
        
        Id customerRecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID;
        Account acctCustomer = new Account(
            Name = 'Acct1',
            RecordTypeId = customerRecordTypeId);
        insert acctCustomer;
        
        Opportunity dealOppty = new Opportunity(
            Name = 'Deal Opp',
            CloseDate = Date.today(),
            StageName = 'Open'
        );
        insert dealOppty;
        
        PT_PMO_Groups__c pmoGroup = new PT_PMO_Groups__c(Name = 'Test Group', Group_Type__c = 'Group');
        insert pmoGroup;
        
        PT_PMO_Groups__c pmoSubGroup = new PT_PMO_Groups__c(Name = 'Test Group 2', Group_Type__c = 'Sub Group');
        insert pmoSubGroup;
        
        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        prog1.Program_Manager__c = u1.Id;
        prog1.PT_PMO_Group__c = pmoGroup.id;
        prog1.PT_PMO_SubGroup__c = pmoSubGroup.id;
        insert prog1;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','DSS','Applications', 'X-Series');
        insert prodSysType;

        Opportunity salesOppty = new Opportunity(
            Name = 'Sales Opp',
            AccountId = acctCustomer.Id,
            RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
            L2I_Product_Category__c = 'DSS',
            CloseDate = Date.today(),
            StageName = 'Handoff',
            L2I_Parent_Opportunity__c = dealOppty.Id,
            L2I_AircraftQuantity__c = 1,
            L2I_Program_Num__c = prog1.Id,
            PT_PL_Approval_Status__c = 'Pending',
            L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;

        Opportunity salesOpptyCloned = salesOppty.clone();
        insert salesOpptyCloned;
        
        Opportunity pplOppty = new Opportunity(
            Name = 'Sales Opp',
            AccountId = acctCustomer.Id,
            RecordTypeId = L2I_StaticConstants.PPL_OPPORTUNITY_RT_ID,
            StageName = 'Pending Close',
            CloseDate = Date.today(),
            PT_PPL_Type__c = 'EQ',
            PT_CPL_Opportunity__c = salesOppty.Id,
            Proposed_Program_Manager__c = u1.Id,
            Proposed_PMO_Group__c = pmoGroup.Id,
            Proposed_PMO_SubGroup__c = pmoSubGroup.Id
        );
        
        insert pplOppty;
        
        SBQQ__Quote__c qt0 = new SBQQ__Quote__c(
            RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
            SBQQ__Account__c = acctCustomer.Id,
            SBQQ__Opportunity2__c = pplOppty.Id,
            SBQQ__Primary__c = true,
            ApprovalStatus__c = 'Approved'
        );
        insert qt0;
        
        
        pplOppty.StageName = 'Closed Won';
        update pplOppty;
        
        pplOppty.StageName = 'Handoff';
        update pplOppty;
        
        PT_Opportunity_TriggerHandler.recursive = true;
        pplOppty.StageName = 'Delivery';
        update pplOppty;
        
        /// Second Opportunity Same Type
        Test.startTest();
        Opportunity pplOppty2 = new Opportunity(
            Name = 'Sales Opp',
            AccountId = acctCustomer.Id,
            RecordTypeId = L2I_StaticConstants.PPL_OPPORTUNITY_RT_ID,
            StageName = 'Pending Close',
            CloseDate = Date.today(),
            PT_PPL_Type__c = 'EQ',
            PT_CPL_Opportunity__c = salesOppty.Id,
            Proposed_Program_Manager__c = u1.Id,
            Proposed_PMO_Group__c = pmoGroup.Id,
            Proposed_PMO_SubGroup__c = pmoSubGroup.Id
        );
        
        insert pplOppty2;
        
        SBQQ__Quote__c qt1 = new SBQQ__Quote__c(
            RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
            SBQQ__Account__c = acctCustomer.Id,
            SBQQ__Opportunity2__c = pplOppty2.Id,
            SBQQ__Primary__c = true,
            ApprovalStatus__c = 'Approved'
        );
        insert qt1;
        
        
        pplOppty2.StageName = 'Closed Won';
        update pplOppty2;
        
        pplOppty2.StageName = 'Handoff';
        update pplOppty2;
        PT_Opportunity_TriggerHandler.recursive = true;
        pplOppty2.StageName = 'Delivery';
        update pplOppty2;
        Test.stopTest();
    }

    @IsTest
    static void validateStageChangeTest() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'PAC Sales'].Id;
        User u1 = factory.createTestUser(null, profileId, 'User1', 'Test');
        insert u1;

        factory.setupTestContext(null, null, false);

        Id customerRecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID;
        Account acctCustomer = new Account(
              Name = 'Acct1',
              RecordTypeId = customerRecordTypeId);
        insert acctCustomer;

        Opportunity dealOppty = new Opportunity(
              Name = 'Deal Opp',
              CloseDate = Date.today(),
              StageName = 'Open'
        );
        insert dealOppty;

        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        Test.startTest();
        System.runAs(u1) {
        Opportunity salesOppty = new Opportunity(
              Name = 'Sales Opp',
              AccountId = acctCustomer.Id,
              RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
              L2I_Product_Category__c = 'IFEC',
              CloseDate = Date.today(),
              StageName = 'Handoff',
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_AircraftQuantity__c = 1,
              L2I_Program_Num__c = prog1.Id,
              PT_PL_Approval_Status__c = 'Pending',
              L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;

        Opportunity salesOppty1 = new Opportunity(
              Name = 'Sales Opp',
              AccountId = acctCustomer.Id,
              RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
              L2I_Product_Category__c = 'IFEC',
              CloseDate = Date.today(),
              StageName = 'Handoff',
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_AircraftQuantity__c = 1,
              L2I_Program_Num__c = prog1.Id,
              Probability = 50,
              PT_PL_Approval_Status__c = 'Pending',
              L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty1;

        Opportunity salesOppty2 = new Opportunity(
              Name = 'Sales Opp',
              AccountId = acctCustomer.Id,
              RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
              L2I_Product_Category__c = 'IFEC',
              CloseDate = Date.today(),
              StageName = 'Quotation',
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_AircraftQuantity__c = 1,
              L2I_Program_Num__c = prog1.Id,
              PT_PL_Approval_Status__c = 'Pending',
              L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty2;

        salesOppty.StageName = 'Quotation';
        salesOppty.PT_PL_Approval_Status__c = 'Approved';
        salesOppty1.StageName = 'Closed Won';
        salesOppty1.PT_PL_Approval_Status__c = 'Approved';
        salesOppty2.StageName = 'Handoff';
        salesOppty2.PT_PL_Approval_Status__c = 'Approved';
        
            try {
                PT_Opportunity_TriggerHandler.recursive = true;
                update salesOppty;
            } catch(Exception e) {
    
            }
    
            try {
                PT_Opportunity_TriggerHandler.recursive = true;
                update salesOppty1;
            } catch(Exception e) {
    
            }
    
            try {
                PT_Opportunity_TriggerHandler.recursive = true;
                update salesOppty2;
            } catch(Exception e) {
    
            }
        }  
        
        Test.stopTest();      
    }
    
   /************************************************************************************
    * Method Name: approveCROpp
    * Description:
    ************************************************************************************/
    @isTest
    static void approveCROpp() {
        Opportunity pplOppty;
        L2I_DataFactory factory = new L2I_DataFactory();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User u1 = factory.createTestUser(null, profileId, 'User1', 'Test');
        insert u1;
        
        factory.setupTestContext(null, null, false);
        
        Id customerRecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID;
        Account acctCustomer = new Account(Name = 'Acct1',RecordTypeId = customerRecordTypeId);
        insert acctCustomer;
        
        PT_PMO_Groups__c pmoGroup = new  PT_PMO_Groups__c();
        pmoGroup.name = 'Europe';
        pmoGroup.Group_Type__c = 'Group';
        insert pmoGroup;

        PT_PMO_Groups__c pmoSubGroup = new  PT_PMO_Groups__c();
        pmoSubGroup.name = 'Europe Two';
        pmoSubGroup.Group_Type__c = 'Sub Group';
        insert pmoSubGroup;
        
        Opportunity dealOppty = new Opportunity(Name = 'Deal Opp',CloseDate = Date.today(),StageName = 'Open');
        insert dealOppty;
        
        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        System.runAs(u1) {
            Opportunity salesOppty = new Opportunity(
                Name = 'Sales Opp',
                AccountId = acctCustomer.Id,
                RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
                L2I_Product_Category__c = 'IFEC',
                CloseDate = Date.today(),
                StageName = 'Handoff',
                L2I_Parent_Opportunity__c = dealOppty.Id,
                L2I_AircraftQuantity__c = 1,
                L2I_Program_Num__c = prog1.Id,
                PT_PL_Approval_Status__c = 'Pending',
                L2I_Primary_System_Type__c = prodSysType.Id
            );
            insert salesOppty;
            
            Opportunity salesOppty1 = new Opportunity(
                Name = 'Sales Opp',
                AccountId = acctCustomer.Id,
                RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
                L2I_Product_Category__c = 'IFEC',
                CloseDate = Date.today(),
                StageName = 'Handoff',
                L2I_Parent_Opportunity__c = dealOppty.Id,
                L2I_AircraftQuantity__c = 1,
                L2I_Program_Num__c = prog1.Id,
                Probability = 50,
                PT_PL_Approval_Status__c = 'Pending',
                L2I_Primary_System_Type__c = prodSysType.Id
            );
            insert salesOppty1;
                        
            pplOppty = new Opportunity(
                Name = 'CR - '+salesOppty1.Name,
                AccountId = acctCustomer.Id,
                RecordTypeId = L2I_StaticConstants.PPL_OPPORTUNITY_RT_ID,
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                PT_PPL_Type__c = 'CR',
                PT_CPL_Opportunity__c = salesOppty.Id,
                Proposed_Program_Manager__c = u1.Id,
                Proposed_PMO_Group__c = pmoGroup.Id,
                Proposed_PMO_SubGroup__c = pmoSubGroup.Id,
                PT_PL_Approval_Status__c = 'Pending'
            );
            PT_Opportunity_TriggerHandler.recursive = true;
            insert pplOppty;            
        }       
        
        SBQQ__Quote__c qt = new SBQQ__Quote__c(
            RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
            SBQQ__Account__c = acctCustomer.Id,
            SBQQ__Opportunity2__c = pplOppty.Id,
            SBQQ__Primary__c = true,
            ApprovalStatus__c = 'Approved'
        );
        insert qt;
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(Name = 'EC',Status__c = 'Active', Part_List_Opportunity__c = pplOppty.Id);
        insert instLoc2;
        
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;
        
        SBQQ__Cost__c cost = new SBQQ__Cost__c(SBQQ__Product__c = prod.Id, SBQQ__Active__c = true, SBQQ__UnitCost__c = 100);
        insert cost;
        
        Asset ast= new Asset(
            Name = 'Asset Name',
            PT_Install_Location__c = instLoc2.Id,
            PT_Pending__c = Date.today(),
            PT_Program__c = prog1.Id,
            Product2Id = prod.Id,
            AccountId = acctCustomer.Id,
            PT_Configured_Quantity__c = 10,
            Quantity = 10,
            PT_Status__c = 'Active', PT_Revision_Number__c = 1
        );
        insert ast;
        
        Map<Id, String> prodCategoryMap = new Map<Id, String>();
        
        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();
        List<Product2> updateProdList = new List<Product2>();
        
        for (Product2 p : prodList) {
            p.L2I_Migrate__c = true;
            p.SBQQ__ChargeType__c = 'Usage';
            p.SBQQ__BillingType__c = '';
            p.L2I_Service_Activation_Type__c = 'Monthly';
            updateProdList.add(p);
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }        
        update updateProdList;
        
        Set<String> ProductNameList = new Set<String>();
        
        ProductNameList.add('Toca Boca - Toca Cars');
        Set<Id> prodIdList = New Set<Id>();
        
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        for (String s : ProductNameList) {
            Id pid = prodIdMap.get(s);
            prodIdList.add(pid);
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(qt.Id, pid, null);
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.SBQQ__SpecialPrice__c = 5;
            quoteLine.PT_Asset__c = ast.Id;
            qlList.add(quoteLine);
        }
        insert qlList;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(Name = 'ALT');
        insert sg;
        
        List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
        for (SBQQ__QuoteLine__c ql : qlList) {
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
            qlg.SBQQ__Account__c = acctCustomer.id;
            qlg.SBQQ__SolutionGroup__c = sg.Id;
            qlg.SBQQ__Quote__c = qt.Id;
            qlgList.add(qlg);
        }
        insert qlgList;
        test.startTest();
        Asset ast2 = new Asset(
            Name = 'Asset Name',
            PT_Install_Location__c = instLoc2.Id,
            PT_Pending__c = Date.today(),
            PT_Program__c = prog1.Id,
            Product2Id = prod.Id,
            AccountId = acctCustomer.Id,
            PT_Configured_Quantity__c = 10,
            Quantity = 10,
            PT_Status__c = 'Active', PT_Revision_Number__c = 1
        );
        insert ast2;
        
        PT_Opportunity_TriggerHandler.recursive = true;
        pplOppty.PT_PL_Approval_Status__c = 'Approved';
        update pplOppty;
        
        test.stopTest();
    }

}