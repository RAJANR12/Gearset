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
public with sharing class PT_QuoteLine_TriggerFunctionsTest {
    private static L2I_DataFactory factory;
    @IsTest
    static void validationDeliveryStageOpptyTest() {

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

        // START Added by Khrisna for W-004060
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
            testUser = factory.createTestUser(null, profile.Id, 'First Name', 'Last Name');
            insert testUser;
        }
        // END W-004060

        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;
    
        L2I_Aircraft_Type__c att = factory.createAircraftType(acctCustomer.Id, 123456);
        insert att;
    
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        prod.L2I_System_Type_Translation__c = 'A';
        insert prod;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
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
              Proposed_Program_Manager__c = testUser.Id,
              Proposed_PMO_Group__c = pmoGroup.Id,
              Proposed_PMO_SubGroup__c = pmoSubGroup.Id,
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


        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;
    
        salesOppty.L2I_Primary_System_Type__c = prod.Id;
        salesOppty.L2I_Aircraft_Type__c = att.Id;
        salesOppty.L2I_AC_Operator__c = acctCustomer.Id;
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        salesOppty.StageName = 'Delivery';
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
            qlList.add(quoteLine);
        }
        try {
            insert qlList;
        } catch(Exception e){
                System.Assert(e.getMessage().contains('Quote lines without Asset cannot be added when Oppotunity is in Delivery stage'));
        }
    }

    @IsTest
    static void validationAssetStatusNotDeletedTest() {

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

        // START Added by Khrisna for W-004060
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
            testUser = factory.createTestUser(null, profile.Id, 'First Name', 'Last Name');
            insert testUser;
        }
        // END W-004060

        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
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
              Proposed_Program_Manager__c = testUser.Id,
              Proposed_PMO_Group__c = pmoGroup.Id,
              Proposed_PMO_SubGroup__c = pmoSubGroup.Id,
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

        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;
    
        L2I_Aircraft_Type__c att = factory.createAircraftType(acctCustomer.Id, 123456);
        insert att;
    
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        prod.L2I_System_Type_Translation__c = 'A';
        insert prod;
    
        salesOppty.L2I_Primary_System_Type__c = prod.Id;
        salesOppty.L2I_Aircraft_Type__c = att.Id;
        salesOppty.L2I_AC_Operator__c = acctCustomer.Id;
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        salesOppty.StageName = 'Delivery';
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
        try {
            delete qlList;
        } catch(Exception e){
                System.Assert(e.getMessage().contains('Cannot Delete the QuoteLine with asset status not equal to Deleted.'));
        }
    }
}