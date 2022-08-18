@isTest
public with sharing class PT_Quote_TriggerFunctionsTest {
    private static L2I_DataFactory factory;

    @IsTest
    static void createUpdateDSLsTest() {

        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);

        Id customerRecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID;
        Account acctCustomer = new Account(
              Name = 'Acct1',
              L2I_Operator_Number__c = 'AB',
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
              L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;

        Boolean isPrimaryQuote = true;
        SBQQ__Quote__c quote = factory.createQuote('Draft', acctCustomer.Id, salesOppty.Id, isPrimaryQuote);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__BillingFrequency__c = 'Monthly';
        quote.SBQQ__StartDate__c = Date.today();
        quote.ApprovalStatus__c = 'Approved';
        insert quote;
    
        L2I_Aircraft_Type__c att = factory.createAircraftType(acctCustomer.Id, 123456);
        insert att;
    
        Product2 prod = factory.createProduct('99999802', 'MediaServices', 'DSS', '', null);
        prod.productCode = 'MCS BUNDLE';
        prod.L2I_System_Type_Translation__c = 'A';
        insert prod;
    
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;
        
        //Added by Jan Geronga for W-004060: Start
        Profile profile = [Select Id From Profile Where Name='PAC Sales' limit 1];
        User testUser = factory.createTestUser(null, profile.id, 'First Name', 'Last Name');
        insert testUser;
        
        PT_PMO_Groups__c pmoGroup = new  PT_PMO_Groups__c();
        pmoGroup.name = 'Europe';
        pmoGroup.Group_Type__c = 'Group';
        insert pmoGroup;

        PT_PMO_Groups__c pmoSubGroup = new  PT_PMO_Groups__c();
        pmoSubGroup.name = 'Europe Two';
        pmoSubGroup.Group_Type__c = 'Sub Group';
        insert pmoSubGroup;
        //Added by Jan Geronga for W-004060: End
    
        salesOppty.L2I_Primary_System_Type__c = prod.Id;
        salesOppty.L2I_Aircraft_Type__c = att.Id;
        salesOppty.L2I_AC_Operator__c = acctCustomer.Id;
        salesOppty.L2I_Program_Num__c = prog1.Id;
        salesOppty.SBQQ__PrimaryQuote__c = quote.Id;
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        salesOppty.StageName = 'Delivery';
        salesOppty.Proposed_Program_Manager__c = testUser.id;//Added by Jan Geronga for W-004060
        salesOppty.Proposed_PMO_Group__c = pmoGroup.id;//Added by Jan Geronga for W-004060
        salesOppty.Proposed_PMO_SubGroup__c = pmoSubGroup.id;//Added by Jan Geronga for W-004060
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
              SBQQ__Source__c = quote.Id,
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
        qt.ApprovalStatus__c = 'Approved';
        update qt;
    }
    
    /*
    * @Method Name        : updatePTSStation_Test
    * @Description        : Test class for PTS Station auto populate
    * @Author             : Jan Denrick Geronga / Managed Services Simplus
    * @Modification Log   :
    * Ver         Date           Author              Modification
    * W-003016     Jul-12-2021   MS Simplus Jan      Initial Version
    **/
    @IsTest
    static void updatePTSStation_Test() {
        L2I_DataFactory df = new L2I_DataFactory();
        Account namedCustomer = df.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = df.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        Opportunity salesOppty = df.createSalesOpportunity('SalesOpp', 'Quotation', 5, namedCustomer.Id, dealOppty.Id);
        salesOppty.L2I_Product_Category__c = 'PTS';
        insert salesOppty;
        
        SBQQ__Quote__c quote = df.createQuote('draft', namedCustomer.Id, salesOppty.Id, false);
        quote.SBQQ__Primary__c = true;
        quote.ApprovalStatus__c = 'Pending';
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today();
        quote.L2I_Station__c = 'AKL';
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

        L2I_P_L_Approval__c pla = df.createPLApproval(dealOppty.Id, 'Pending');
        pla.L2I_Revision_Status__c = 'Initial';
        insert pla;
        
        L2I_P_L_Sales_Opportunity__c plso = df.createPLSalesOpp(pla.Id, salesOppty.Id);
        insert plso;
        
        Test.startTest();
        quote.L2I_Station__c = 'AKL;AMS';
        quote.ApprovalStatus__c = 'Approved';
        L2I_Quote_TriggerHandler.recursive = true;
        update quote;
        Test.stopTest();
    }
}