/**
* @File Name          : PT_ProgCPLSplitConfigTest.cls
* @Description        : Test Class for PT_ProgCPLSplitConfig
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class PT_ProgCPLSplitConfigTest {

    @testSetup static void setup() {
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
        pmoSubGroup.name = 'Europe Two';
        pmoSubGroup.Group_Type__c = 'Sub Group';
        insert pmoSubGroup;

        Profile profile = [Select Id From Profile Where Name='System Administrator' limit 1];
        User testUser = factory.createTestUser(null, profile.id, 'First Name', 'Last Name');
        insert testUser;

        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        prod.L2I_System_Type_Translation__c = 'A';
        insert prod;

        L2I_Aircraft_Type__c att = factory.createAircraftType(acctCustomer.Id, 123456);
        insert att;

        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        
        PT_Opportunity_TriggerHandler.recursive = true;
        salesOppty.L2I_Primary_System_Type__c = prod.Id;
        salesOppty.L2I_Aircraft_Type__c = att.Id;
        salesOppty.L2I_AC_Operator__c = acctCustomer.Id;
        salesOppty.L2I_Program_Num__c = prog1.Id;
        salesOppty.StageName = 'Delivery';
        salesOppty.Proposed_Program_Manager__c = testUser.id;
        salesOppty.Proposed_PMO_Group__c= pmoGroup.id;
        salesOppty.Proposed_PMO_SubGroup__c = pmoSubGroup.id;
        // update SalesOppty;
        
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        // update salesOppty;

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
        
        ProductNameList.add('Panasonic WIFI');
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
        for (SBQQ__QuoteLine__c ql : qlList){
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
            qlg.SBQQ__Account__c = acctCustomer.id;
            qlg.SBQQ__SolutionGroup__c = sg.Id;
            qlg.SBQQ__Quote__c = qt.Id;
            qlgList.add(qlg);
        }
        insert qlgList;
    }

    @IsTest
    static void testNewConfiguration() {
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        L2I_DSL__c dsl = [SELECT Id FROM L2I_DSL__c WHERE PT_isActive__c = 'Active' LIMIT 1];

        System.runAs(testUser) {
            Boolean foundErr = false;
            String msg = '';
            try {
                PT_ProgCPLSplitConfig.SplitWrapper sw = PT_ProgCPLSplitConfig.programSplitConfig(dsl.Id, 'No');
            } catch (Exception e){
                foundErr = true;
                msg = e.getMessage();
                System.debug('*** msg ' + msg);
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testSplit() {
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        L2I_DSL__c dsl = [SELECT Id FROM L2I_DSL__c WHERE PT_isActive__c = 'Active' LIMIT 1];

        System.runAs(testUser) {
            Boolean foundErr = false;
            String msg = '';
            try {
                PT_ProgCPLSplitConfig.SplitWrapper sw = PT_ProgCPLSplitConfig.programSplitConfig(dsl.Id, 'Yes');
            } catch (Exception e){
                foundErr = true;
                msg = e.getMessage();
                System.debug('*** msg ' + msg);
            }
        }
        Test.stopTest();


        // L2I_DataFactory factory = new L2I_DataFactory();
        // factory.setupTestContext(null, null, false);
    
        // Id customerRecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID;
        // Account acctCustomer = new Account(
        //       Name = 'Acct1',
        //       RecordTypeId = customerRecordTypeId);
        // insert acctCustomer;
    
        // Opportunity dealOppty = new Opportunity(
        //       Name = 'Deal Opp',
        //       CloseDate = Date.today(),
        //       StageName = 'Open'
        // );
        // insert dealOppty;
    
        // PT_Program__c prog1 = new PT_Program__c();
        // prog1.Name = 'Prog1';
        // prog1.Program_Number__c = 'Prog1';
        // insert prog1;
    
        // PT_PMO_Groups__c pmoGroup = new  PT_PMO_Groups__c();
        // pmoGroup.name = 'Europe';
        // pmoGroup.Group_Type__c = 'Group';
        // insert pmoGroup;

        // PT_PMO_Groups__c pmoSubGroup = new  PT_PMO_Groups__c();
        // pmoSubGroup.name = 'Europe Two';
        // pmoSubGroup.Group_Type__c = 'Sub Group';
        // insert pmoSubGroup;
        
        
        // Profile profile = [Select Id From Profile Where Name='System Administrator' limit 1];
        // User testUser = factory.createTestUser(null, profile.id, 'First Name', 'Last Name');
        // insert testUser;
        // Added for W-001727
        
        
            
            // Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
            // insert prodSysType;
            
            // Opportunity salesOppty = new Opportunity(
            //       Name = 'Sales Opp',
            //       AccountId = acctCustomer.Id,
            //       RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
            //       L2I_Product_Category__c = 'IFEC',
            //       CloseDate = Date.today(),
            //       StageName = 'Handoff',
            //       L2I_Parent_Opportunity__c = dealOppty.Id,
            //       L2I_AircraftQuantity__c = 1,
            //       L2I_Program_Num__c = prog1.Id,
            //       L2I_Primary_System_Type__c = prodSysType.Id
            // );
            // insert salesOppty;
        
            // SBQQ__Quote__c qt0 = new SBQQ__Quote__c(
            //       RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
            //       SBQQ__Account__c = acctCustomer.Id,
            //       SBQQ__Opportunity2__c = salesOppty.Id,
            //       SBQQ__Primary__c = true,
            //       ApprovalStatus__c = 'Approved'
            // );
            // insert qt0;
        
            // Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
            // prod.productCode = 'MCS BUNDLE';
            // prod.L2I_System_Type_Translation__c = 'A';
            // insert prod;
        
            // L2I_Aircraft_Type__c att = factory.createAircraftType(acctCustomer.Id, 123456);
            // insert att;
        
            // salesOppty.L2I_Primary_System_Type__c = prod.Id;
            // salesOppty.L2I_Aircraft_Type__c = att.Id;
            // salesOppty.L2I_AC_Operator__c = acctCustomer.Id;
            // salesOppty.L2I_Program_Num__c = prog1.Id;
            // salesOppty.SBQQ__PrimaryQuote__c = qt0.Id;
            // salesOppty.StageName = 'Delivery';
            // salesOppty.Proposed_Program_Manager__c = testUser.id;
            // salesOppty.Proposed_PMO_Group__c= pmoGroup.id;
            // salesOppty.Proposed_PMO_SubGroup__c = pmoSubGroup.id;
            // PT_Opportunity_TriggerHandler.recursive = true;
            // update SalesOppty;
        
            // L2I_DSH__c dsh = new L2I_DSH__c();
            // insert dsh;
            // update dsh;
            // salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
            // update salesOppty;
        
            // L2I_DSL__c dsl = new L2I_DSL__c(
            //       Delivery_Schedule_Header__c = dsh.Id,
            //       PT_isActive__c = 'Active',
            //       PT_Program__c = prog1.Id
            // );
            // insert dsl;
    
            // PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
            //         Name = 'EC',
            //         ShipSet__c = dsl.Id,
            //         Status__c = 'Active'
            // );
            // insert instLoc2;
            
            // Asset ast = new Asset(
            //         Name = 'Asset Name',
            //         PT_Install_Location__c = instLoc2.Id,
            //         PT_Pending__c = Date.today(),
            //         PT_Program__c = prog1.Id,
            //         Product2Id = prod.Id,
            //         AccountId = acctCustomer.Id,
            //         PT_Configured_Quantity__c = 10,
            //         Quantity = 10,
            //         PT_Status__c = 'Active'
            // );
            // insert ast;
        
            // SBQQ__Quote__c qt = new SBQQ__Quote__c(
            //       RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
            //       SBQQ__Account__c = acctCustomer.Id,
            //       SBQQ__Opportunity2__c = salesOppty.Id,
            //       SBQQ__Source__c = qt0.Id,
            //       SBQQ__Primary__c = true
            // );
            // insert qt;
        
            
            // Map<Id, String> prodCategoryMap = new Map<Id, String>();
        	// Test.startTest();
            // List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
            // Map<String, Id> prodIdMap = new Map<String, Id>();
            // List<Product2> updateProdList = new List<Product2>();
        
            // for (Product2 p : prodList) {
            //     p.L2I_Migrate__c = true;
            //     p.SBQQ__ChargeType__c = 'Usage';
            //     p.SBQQ__BillingType__c = '';
            //     p.L2I_Service_Activation_Type__c = 'Monthly';
            //     updateProdList.add(p);
            //     prodIdMap.put(p.Name, p.Id);
            //     prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
            // }
        
            // update updateProdList;
        
            // Set<String> ProductNameList = new Set<String>();
        
            // ProductNameList.add('Panasonic WIFI');
            // Set<Id> prodIdList = New Set<Id>();
        	// Test.stopTest();
            // List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
            // for (String s : ProductNameList) {
            //     Id pid = prodIdMap.get(s);
            //     prodIdList.add(pid);
            //     SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(qt.Id, pid, null);
            //     quoteLine.SBQQ__Quantity__c = 1;
            //     quoteLine.SBQQ__SpecialPrice__c = 5;
            //     quoteLine.PT_Asset__c = ast.Id;
            //     qlList.add(quoteLine);
            // }
            // insert qlList;
    
            // SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
            //         Name = 'ALT'
            // );
            // insert sg;
    
            // List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
            // for (SBQQ__QuoteLine__c ql : qlList){
            //     SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
            //     qlg.SBQQ__Account__c = acctCustomer.id;
            //     qlg.SBQQ__SolutionGroup__c = sg.Id;
            //     qlg.SBQQ__Quote__c = qt.Id;
            //     qlgList.add(qlg);
            // }
            // insert qlgList;
        	
            // System.runAs(testUser){
            // Boolean foundErr = false;
            // String msg = '';
            // try {
            //     PT_ProgCPLSplitConfig.SplitWrapper sw = PT_ProgCPLSplitConfig.programSplitConfig(dsl.Id, 'Yes');
            // } catch (Exception e){
            //     foundErr = true;
            //     msg = e.getMessage();
            // }
            
            // System.assertEquals(false, foundErr, msg);
    		/*
            Opportunity newOpp = [
                  SELECT Id, Name, AccountId, L2I_Product_Category__c, CloseDate, StageName, L2I_Delivery_Schedule__c,
                        L2I_Program_Num__c
                  FROM Opportunity
                  WHERE Id <> :salesOppty.Id
                  AND RecordType.DeveloperName = 'Sales'
                  LIMIT 1
            ];
            L2I_DSH__c newDSH = [SELECT Id FROM L2I_DSH__c WHERE Id <> :dsh.Id LIMIT 1];*/
        
            // System.assertEquals(newDSH.Id, [SELECT Id, L2I_Delivery_Schedule__c FROM Opportunity WHERE Id = :newOpp.Id].L2I_Delivery_Schedule__c);
            // System.assertEquals(null, [SELECT Id, L2I_Program_Num__c FROM Opportunity WHERE Id = :newOpp.Id].L2I_Program_Num__c);
            // System.assertEquals(newDSH.Id, [SELECT Id, Delivery_Schedule_Header__c FROM L2I_DSL__c WHERE Id = :dsl.Id].Delivery_Schedule_Header__c);
            //System.assertEquals(null, [SELECT Id, PT_Program__c FROM L2I_DSL__c WHERE Id = :dsl.Id].PT_Program__c);
            
        // }
        
    }
    
    @IsTest
    static void testActiveDSLs() {
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        L2I_DSL__c dsl = [SELECT Id FROM L2I_DSL__c WHERE PT_isActive__c = 'Active' LIMIT 1];

        System.runAs(testUser) {
            PT_ProgCPLSplitConfig.DSLWrapper dw = PT_ProgCPLSplitConfig.checkActiveShipsets(dsl.Id);
            System.assertEquals(1, dw.dslActiveCount);
        }
        Test.stopTest();

        // L2I_DataFactory factory = new L2I_DataFactory();
        // factory.setupTestContext(null, null, false);
        
        // PT_PMO_Groups__c pmoGroup = new  PT_PMO_Groups__c();
        // pmoGroup.name = 'Europe';
        // pmoGroup.Group_Type__c = 'Group';
        // insert pmoGroup;
        
        // PT_PMO_Groups__c pmoSubGroup = new  PT_PMO_Groups__c();
        // pmoSubGroup.name = 'Europe Two';
        // pmoSubGroup.Group_Type__c = 'Sub Group';
        // insert pmoSubGroup;
        
        // Profile profile = [Select Id From Profile Where Name='PAC Sales' limit 1];
        // User testUser = factory.createTestUser(null, profile.id, 'First Name', 'Last Name');
        // insert testUser;
        
        // Id customerRecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID;
        // Account acctCustomer = new Account(
        //       Name = 'Acct1',
        //       L2I_Operator_Number__c = 'AB',
        //       RecordTypeId = customerRecordTypeId);
        // insert acctCustomer;
        
        // Opportunity dealOppty = new Opportunity(
        //       Name = 'Deal Opp',
        //       CloseDate = Date.today(),
        //       StageName = 'Open'
        // );
        // insert dealOppty;
        
        // PT_Program__c prog1 = new PT_Program__c();
        // prog1.Name = 'Prog1';
        // prog1.Program_Number__c = 'Prog1';
        // insert prog1;
        // // Added for W-001727
        // Product2 prodSysType = factory.createProduct('9876543','EX3','DSS','Applications', 'X-Series');
        // insert prodSysType;
		
        // Opportunity salesOppty = new Opportunity(
        //       Name = 'Sales Opp',
        //       AccountId = acctCustomer.Id,
        //       RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
        //       L2I_Product_Category__c = 'DSS',
        //       CloseDate = Date.today(),
        //       StageName = 'Handoff',
        //       L2I_Parent_Opportunity__c = dealOppty.Id,
        //       L2I_AircraftQuantity__c = 1,
        //       L2I_Program_Num__c = prog1.Id,
        //       L2I_Primary_System_Type__c = prodSysType.Id
        // );
        // insert salesOppty;
    
        // SBQQ__Quote__c qt0 = new SBQQ__Quote__c(
        //       RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
        //       SBQQ__Account__c = acctCustomer.Id,
        //       SBQQ__Opportunity2__c = salesOppty.Id,
        //       SBQQ__Primary__c = true,
        //       ApprovalStatus__c = 'Approved'
        // );
        // insert qt0;
    
        // Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        // prod.productCode = 'MCS BUNDLE';
        // prod.L2I_System_Type_Translation__c = 'A';
        // insert prod;
    
        // L2I_Aircraft_Type__c att = factory.createAircraftType(acctCustomer.Id, 123456);
        // insert att;
    
        // PT_Opportunity_TriggerHandler.recursive = true;
        // salesOppty.L2I_Primary_System_Type__c = prod.Id;
        // salesOppty.L2I_Aircraft_Type__c = att.Id;
        // salesOppty.L2I_AC_Operator__c = acctCustomer.Id;
        // salesOppty.L2I_Program_Num__c = prog1.Id;
        // salesOppty.SBQQ__PrimaryQuote__c = qt0.Id;
        // salesOppty.StageName = 'Delivery';
        // salesOppty.Proposed_Program_Manager__c = testUser.id;
        // salesOppty.Proposed_PMO_Group__c= pmoGroup.id;
        // salesOppty.Proposed_PMO_SubGroup__c = pmoSubGroup.id;
        // update SalesOppty;
        
        // L2I_DSH__c dsh = new L2I_DSH__c();
        // insert dsh;
        // update dsh;
        // salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        // update salesOppty;
        
        // L2I_DSL__c dsl = new L2I_DSL__c(
        //       Delivery_Schedule_Header__c = dsh.Id,
        //       PT_isActive__c = 'Active',
        //       PT_Program__c = prog1.Id
        // );
        // insert dsl;

        // PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
        //         Name = 'EC',
        //         ShipSet__c = dsl.Id,
        //         Status__c = 'Active'
        // );
        // insert instLoc2;
        
        // Asset ast = new Asset(
        //         Name = 'Asset Name',
        //         PT_Install_Location__c = instLoc2.Id,
        //         PT_Pending__c = Date.today(),
        //         PT_Program__c = prog1.Id,
        //         Product2Id = prod.Id,
        //         AccountId = acctCustomer.Id,
        //         PT_Configured_Quantity__c = 10,
        //         Quantity = 10,
        //         PT_Status__c = 'Active'
        // );
        // insert ast;
        
        // SBQQ__Quote__c qt = new SBQQ__Quote__c(
        //       RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
        //       SBQQ__Account__c = acctCustomer.Id,
        //       SBQQ__Opportunity2__c = salesOppty.Id,
        //       SBQQ__Source__c = qt0.Id,
        //       SBQQ__Primary__c = true
        // );
        // insert qt;
        // Test.startTest();
        // Map<Id, String> prodCategoryMap = new Map<Id, String>();
        
        // List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
        // Map<String, Id> prodIdMap = new Map<String, Id>();
        // List<Product2> updateProdList = new List<Product2>();
        
        // for (Product2 p : prodList) {
        //     p.L2I_Migrate__c = true;
        //     p.SBQQ__ChargeType__c = 'Usage';
        //     p.SBQQ__BillingType__c = '';
        //     p.L2I_Service_Activation_Type__c = 'Monthly';
        //     updateProdList.add(p);
        //     prodIdMap.put(p.Name, p.Id);
        //     prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        // }
        
        // update updateProdList;
        
        // Set<String> ProductNameList = new Set<String>();
        
        // ProductNameList.add('Toca Boca - Toca Cars');
        // Set<Id> prodIdList = New Set<Id>();
        
        // List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        // for (String s : ProductNameList) {
        //     Id pid = prodIdMap.get(s);
        //     prodIdList.add(pid);
        //     SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(qt.Id, pid, null);
        //     quoteLine.SBQQ__Quantity__c = 1;
        //     quoteLine.SBQQ__SpecialPrice__c = 5;
        //     quoteLine.PT_Asset__c = ast.Id;
        //     qlList.add(quoteLine);
        // }
        // insert qlList;

        // SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
        //         Name = 'ALT'
        // );
        // insert sg;

        // List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
        // for (SBQQ__QuoteLine__c ql : qlList){
        //     SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
        //     qlg.SBQQ__Account__c = acctCustomer.id;
        //     qlg.SBQQ__SolutionGroup__c = sg.Id;
        //     qlg.SBQQ__Quote__c = qt.Id;
        //     qlgList.add(qlg);
        // }
        // insert qlgList;
        
        
        // PT_ProgCPLSplitConfig.DSLWrapper dw = PT_ProgCPLSplitConfig.checkActiveShipsets(dsl.Id);
        // Test.stopTest();
    
        // System.assertEquals(1, dw.dslActiveCount);
    }
}