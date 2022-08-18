/**
* @File Name          : PT_ContentVersionTriggerFunctions_Test.cls
* @Description        : Test Class for PT_ContentVersionTriggerFunctions
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class PT_ContentVersionTriggerFunctions_Test {
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
    
    @IsTest
    static void testCVReady() {
        L2I_DataFactory factory = new L2I_DataFactory();
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
        pmoGroup.name = 'Europe';
        pmoGroup.Group_Type__c = 'Group';
        insert pmoGroup;

        PT_PMO_Groups__c pmoSubGroup = new  PT_PMO_Groups__c();
        pmoSubGroup.name = 'Europe Two';
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
            L2I_Product_Category__c = 'IFEC',
            CloseDate = Date.today(),
            StageName = 'Handoff',
            L2I_Parent_Opportunity__c = dealOppty.Id,
            L2I_AircraftQuantity__c = 1,
            L2I_Program_Num__c = prog1.Id,
            PT_PL_Approval_Status__c = 'Pending',
            Proposed_Program_Manager__c = testUser.id, 
            Proposed_PMO_Group__c = pmoGroup.id,
            Proposed_PMO_SubGroup__c = pmoSubGroup.id,
            PT_Parts_List_Revision_Number__c = 0,
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
        
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        SBQQ__Quote__c quote = dt.createQuote('draft', acctCustomer.Id, salesOppty.Id, true);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__Source__c = qt0.Id;
        insert quote;
    
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'MediaServices' LIMIT 1];
        prod.L2I_System_Type_Translation__c = 'A';
        update prod;
    
        L2I_Aircraft_Type__c att = dt.createAircraftType(acctCustomer.Id, 123456);
        insert att;
    
        salesOppty.L2I_Primary_System_Type__c = prod.Id;
        salesOppty.L2I_Aircraft_Type__c = att.Id;
        salesOppty.L2I_AC_Operator__c = acctCustomer.Id;
        salesOppty.L2I_Program_Num__c = prog1.Id;
        salesOppty.SBQQ__PrimaryQuote__c = qt0.Id;
        salesOppty.StageName = 'Delivery';
        salesOppty.PT_Current_Parts_List__c = quote.Id;
        update SalesOppty;
        
        Attachment attach = new Attachment();
        attach.Name = 'CPL Unit Test Attachment Anon';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = salesOppty.id;
        
        insert attach;
        
        ContentVersion cv =  [SELECT Id,
              Tagcsv,
              PT_CPL_External_ControlId__c,
              PT_IntegrationMessage__c,
              PT_IntegrationStatus__c,
              PT_IntegrationType__c
        FROM ContentVersion LIMIT 1];
        cv.PT_IntegrationStatus__c = 'Ready To Integrate';
        Test.startTest();
        update cv;
        Test.stopTest();
       
    }
}