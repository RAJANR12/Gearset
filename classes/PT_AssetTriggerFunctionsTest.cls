/**
* @File Name          : PT_AssetTriggerFunctionsTest.cls
* @Description        : Test Class for PT_AssetTriggerFunctions
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class PT_AssetTriggerFunctionsTest {
    @IsTest
    static void testInsertAssetOnProgramPending() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'PAC System Administrator' LIMIT 1];
        User u = new User(
              LastName = 'SMITH',
              FirstName = 'JOHN',
              Alias = 'main',
              Email = 'testPACuser@testfactory.com',
              Phone = '1234567890',
              Username = 'testPACuser@testfactory.com.' + Math.random(),
              TimeZoneSidKey = 'Europe/Berlin',
              LanguageLocaleKey = 'en_US',
              EmailEncodingKey = 'UTF-8',
              LocaleSidKey = 'en_US',
              ProfileId = profile.Id);
        insert u;
//        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PAC_PMO_Admin'];
//        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

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

        PT_Program__c prog = new PT_Program__c();
        prog.Name = 'prog';
        prog.Program_Number__c = 'prog';
        insert prog;
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
            L2I_Program_Num__c = prog.Id,
            PT_PL_Approval_Status__c = 'Approved',
            L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;

        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
            //   ShipSet__c = dsl.Id,
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc2;
        
        Boolean gotError = false;
        System.runAs(u) {
            
            L2I_DataFactory dt = new L2I_DataFactory();
            Account namedCustomer = dt.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            
            Product2 p = new Product2(Name = 'TestProd', ProductCode = 'ProdCode', L2I_Inventory_Item_Id__c = '99999803');
            
            PT_Program__c prog1 = new PT_Program__c();
            prog1.MROD_Approval_Status__c = 'Pending';
            prog1.Name = 'Prog1';
            prog1.Program_Number__c = 'Prog1';
            insert prog1;
            
            Asset ast = new Asset(
                  Name = 'AssetName',
                  AccountId = namedCustomer.Id,
                  Product2Id = p.Id,
                  PT_Program__c = prog1.Id,
                  PT_Install_Location__c = instLoc2.Id
            );
            
            Test.startTest();
            
            try {
                insert ast;
            } catch (Exception e) {
                gotError = true;
                System.debug('*** e ' + e.getMessage());
            }
            Test.stopTest();
        }
        System.assertEquals(true, gotError);
    }
    
    @IsTest
    static void testChangeAssetOnProgramPending() {
        L2I_DataFactory dt = new L2I_DataFactory();
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'PAC System Administrator' LIMIT 1];
        User u = new User(
              LastName = 'SMITH',
              FirstName = 'JOHN',
              Alias = 'main',
              Email = 'testPACuser@testfactory.com',
              Phone = '1234567890',
              Username = 'testPACuser@testfactory.com.' + Math.random(),
              TimeZoneSidKey = 'Europe/Berlin',
              LanguageLocaleKey = 'en_US',
              EmailEncodingKey = 'UTF-8',
              LocaleSidKey = 'en_US',
              ProfileId = profile.Id);
        insert u;
//        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PAC_PMO_Admin'];
//        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
        Boolean gotError = false;

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
        
        List<PT_PMO_Groups__c> lGroups = new List<PT_PMO_Groups__c>();
        PT_PMO_Groups__c pmoG = new PT_PMO_Groups__c();
        pmoG.Name = 'TestG';
        pmoG.Group_Type__c = 'Group';
        lGroups.add(pmoG);
        
        PT_PMO_Groups__c pmoSG = new PT_PMO_Groups__c();
        pmoSG.Name = 'TestSG';
        pmoSG.Group_Type__c = 'Sub Group';
        lGroups.add(pmoSG);
        
        insert lGroups;

        PT_Program__c prog = new PT_Program__c();
        prog.Name = 'prog';
        prog.Program_Number__c = 'prog';
        insert prog;
        
        // Added for W-001727
        Product2 prodSysType = dt.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
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
            L2I_Program_Num__c = prog.Id,
            PT_PL_Approval_Status__c = 'Approved',
            L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;

        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
            //   ShipSet__c = dsl.Id,
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc2;
        
        System.runAs(u) {
            
            Account namedCustomer = dt.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            
            Product2 p = new Product2(Name = 'TestProd', ProductCode = 'ProdCode', L2I_Inventory_Item_Id__c = '99999803');
            
            PT_Program__c prog1 = new PT_Program__c();
            prog1.Name = 'Prog1';
            prog1.Program_Number__c = 'Prog1';
            insert prog1;
            
            Case cases = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', PT_Program__c = prog1.Id,AccountId =namedCustomer.id );
            insert cases;
            Asset ast = new Asset(
                  Name = 'AssetName',
                  AccountId = namedCustomer.Id,
                  Product2Id = p.Id,
                  PT_Program__c = prog1.Id,
                  PT_Install_Location__c = instLoc2.Id,
                  PT_Status__c = 'Active',
                  PT_Case__c = cases.Id
            );
            insert ast;

            Asset astCloned = ast.Clone();
            astCloned.ParentId = ast.Id;
            insert astCloned;

            salesOppty.PT_PL_Approval_Status__c = 'Pending';
            salesOppty.Proposed_Program_Manager__c = u.Id;
            salesOppty.Proposed_PMO_Group__c = lGroups[0].Id;
            salesOppty.Proposed_PMO_SubGroup__c = lGroups[1].Id;
            update salesOppty;

            prog1.MROD_Approval_Status__c = 'Pending';
            update prog1;
            ast.Quantity = 3;
            ast.PT_Status__c = 'Pending Move';
            ast.PT_Warehouse__c = 'BOT';
            
            Test.startTest();
            try {
                update ast;
            } catch (Exception e) {
                gotError = true;
                System.debug('*** e ' + e.getMessage());
            }
            Test.stopTest();
        }
        System.assertEquals(true, gotError);
    }
    
    @IsTest
    static void testDeleteAssetOnProgramPending() {
        L2I_DataFactory dt = new L2I_DataFactory();
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'PAC System Administrator' LIMIT 1];
        User u = new User(
              LastName = 'SMITH',
              FirstName = 'JOHN',
              Alias = 'main',
              Email = 'testPACuser@testfactory.com',
              Phone = '1234567890',
              Username = 'testPACuser@testfactory.com.' + Math.random(),
              TimeZoneSidKey = 'Europe/Berlin',
              LanguageLocaleKey = 'en_US',
              EmailEncodingKey = 'UTF-8',
              LocaleSidKey = 'en_US',
              ProfileId = profile.Id);
        insert u;
//        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PAC_PMO_Admin'];
//        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
        Boolean gotError = false;

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

        PT_Program__c prog = new PT_Program__c();
        prog.Name = 'prog';
        prog.Program_Number__c = 'prog';
        insert prog;

        // Added for W-001727
        Product2 prodSysType = dt.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
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
            L2I_Program_Num__c = prog.Id,
            PT_PL_Approval_Status__c = 'Approved',
            L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;

        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
            //   ShipSet__c = dsl.Id,
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc2;

        System.runAs(u) {
 
            Account namedCustomer = dt.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            
            Product2 p = new Product2(Name = 'TestProd', ProductCode = 'ProdCode', L2I_Inventory_Item_Id__c = '99999803');
            
            List<PT_PMO_Groups__c> lGroups = new List<PT_PMO_Groups__c>();
            PT_PMO_Groups__c pmoG = new PT_PMO_Groups__c();
            pmoG.Name = 'TestG';
            pmoG.Group_Type__c = 'Group';
            lGroups.add(pmoG);
            
            PT_PMO_Groups__c pmoSG = new PT_PMO_Groups__c();
            pmoSG.Name = 'TestSG';
            pmoSG.Group_Type__c = 'Sub Group';
            lGroups.add(pmoSG);
            
            insert lGroups;
            
            PT_Program__c prog1 = new PT_Program__c();
            prog1.Name = 'Prog1';
            prog1.Program_Number__c = 'Prog1';
            insert prog1;
            
            Asset ast = new Asset(
                  Name = 'AssetName',
                  AccountId = namedCustomer.Id,
                  Product2Id = p.Id,
                  PT_Program__c = prog1.Id,
                  PT_Install_Location__c = instLoc2.Id,
                  PT_Status__c = 'Active'
            );
            insert ast;

            salesOppty.PT_PL_Approval_Status__c = 'Pending';
            salesOppty.Proposed_Program_Manager__c = u.Id;
            salesOppty.Proposed_PMO_Group__c = lGroups[0].Id;
            salesOppty.Proposed_PMO_SubGroup__c = lGroups[1].Id;
            update salesOppty;

            prog1.MROD_Approval_Status__c = 'Pending';
            update prog1;
            
            Test.startTest();
            try {
                delete ast;
            } catch (Exception e) {
                gotError = true;
                System.debug('*** e ' + e.getMessage());
            }
            Test.stopTest();
        }
        System.assertEquals(true, gotError);
    }
    
    @IsTest
    static void testInsertAssetOnProgramNOTPending() {
        L2I_DataFactory dt = new L2I_DataFactory();
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'PAC System Administrator' LIMIT 1];
        User u = new User(
              LastName = 'SMITH',
              FirstName = 'JOHN',
              Alias = 'main',
              Email = 'testPACuser@testfactory.com',
              Phone = '1234567890',
              Username = 'testPACuser@testfactory.com.' + Math.random(),
              TimeZoneSidKey = 'Europe/Berlin',
              LanguageLocaleKey = 'en_US',
              EmailEncodingKey = 'UTF-8',
              LocaleSidKey = 'en_US',
              ProfileId = profile.Id);
        insert u;
//        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PAC_PMO_Admin'];
//        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
        Boolean gotError = false;

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

        PT_Program__c prog = new PT_Program__c();
        prog.Name = 'prog';
        prog.Program_Number__c = 'prog';
        insert prog;
        // Added for W-001727
        Product2 prodSysType = dt.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
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
            L2I_Program_Num__c = prog.Id,
            PT_PL_Approval_Status__c = 'Approved',
            L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;

        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
            //   ShipSet__c = dsl.Id,
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc2;

        System.runAs(u) {
            
            Account namedCustomer = dt.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            
            Product2 p = new Product2(Name = 'TestProd', ProductCode = 'ProdCode', L2I_Inventory_Item_Id__c = '99999803');
            
            PT_Program__c prog1 = new PT_Program__c();
            prog1.MROD_Approval_Status__c = 'Approved';
            prog1.Name = 'Prog1';
            prog1.Program_Number__c = 'Prog1';
            insert prog1;
            
            Asset ast = new Asset(
                  Name = 'AssetName',
                  AccountId = namedCustomer.Id,
                  Product2Id = p.Id,
                  PT_Program__c = prog1.Id,
                  PT_Install_Location__c = instLoc2.Id,
                  PT_Status__c = 'Active'
            );
            
            
            Test.startTest();
            try {
                insert ast;
            } catch (Exception e) {
                gotError = true;
                System.debug('*** e ' + e.getMessage());
            }
            Test.stopTest();
        }
        System.assertEquals(false, gotError);
    }
    
    @IsTest
    static void testChangeAssetOnProgramNOTPending() {
        L2I_DataFactory dt = new L2I_DataFactory();
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'PAC System Administrator' LIMIT 1];
        User u = new User(
              LastName = 'SMITH',
              FirstName = 'JOHN',
              Alias = 'main',
              Email = 'testPACuser@testfactory.com',
              Phone = '1234567890',
              Username = 'testPACuser@testfactory.com.' + Math.random(),
              TimeZoneSidKey = 'Europe/Berlin',
              LanguageLocaleKey = 'en_US',
              EmailEncodingKey = 'UTF-8',
              LocaleSidKey = 'en_US',
              ProfileId = profile.Id);
        insert u;
//        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PAC_PMO_Admin'];
//        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
        Boolean gotError = false;

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

        PT_Program__c prog = new PT_Program__c();
        prog.Name = 'prog';
        prog.Program_Number__c = 'prog';
        insert prog;
        // Added for W-001727
        Product2 prodSysType = dt.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
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
            L2I_Program_Num__c = prog.Id,
            PT_PL_Approval_Status__c = 'Approved',
            L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;

        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
            //   ShipSet__c = dsl.Id,
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc2;
        
        System.runAs(u) {
            Account namedCustomer = dt.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            
            Product2 p = new Product2(Name = 'TestProd', ProductCode = 'ProdCode', L2I_Inventory_Item_Id__c = '99999803');
            
            PT_Program__c prog1 = new PT_Program__c();
            prog1.Name = 'Prog1';
            prog1.Program_Number__c = 'Prog1';
            insert prog1;
            
            Asset ast = new Asset(
                  Name = 'AssetName',
                  AccountId = namedCustomer.Id,
                  Product2Id = p.Id,
                  PT_Program__c = prog1.Id,
                  PT_Install_Location__c = instLoc2.Id,
                  PT_Status__c = 'Active'
            );
            insert ast;

            prog1.MROD_Approval_Status__c = 'Approved';
            update prog1;
            ast.Quantity = 3;
            ast.PT_Status__c = 'Pending Move';
            ast.PT_Warehouse__c = 'BOT';
            
            Test.startTest();
            try {
                update ast;
            } catch (Exception e) {
                gotError = true;
                System.debug('*** e ' + e.getMessage());
            }
            Test.stopTest();
        }
        System.assertEquals(false, gotError);
    }
    
    @IsTest
    static void testDeleteAssetOnProgramNOTPending() {
        L2I_DataFactory dt = new L2I_DataFactory();
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'PAC System Administrator' LIMIT 1];
        User u = new User(
              LastName = 'SMITH',
              FirstName = 'JOHN',
              Alias = 'main',
              Email = 'testPACuser@testfactory.com',
              Phone = '1234567890',
              Username = 'testPACuser@testfactory.com.' + Math.random(),
              TimeZoneSidKey = 'Europe/Berlin',
              LanguageLocaleKey = 'en_US',
              EmailEncodingKey = 'UTF-8',
              LocaleSidKey = 'en_US',
              ProfileId = profile.Id);
        insert u;
//        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PAC_PMO_Admin'];
//        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
        Boolean gotError = false;

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

        PT_Program__c prog = new PT_Program__c();
        prog.Name = 'prog';
        prog.Program_Number__c = 'prog';
        insert prog;
        // Added for W-001727
        Product2 prodSysType = dt.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
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
            L2I_Program_Num__c = prog.Id,
            PT_PL_Approval_Status__c = 'Approved',
            L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;

        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
            //   ShipSet__c = dsl.Id,
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc2;
        
        System.runAs(u) {
            Account namedCustomer = dt.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            
            Product2 p = new Product2(Name = 'TestProd', ProductCode = 'ProdCode', L2I_Inventory_Item_Id__c = '99999803');
            
            PT_Program__c prog1 = new PT_Program__c();
            prog1.Name = 'Prog1';
            prog1.Program_Number__c = 'Prog1';
            insert prog1;
            
            
            Asset ast = new Asset(
                  Name = 'AssetName',
                  AccountId = namedCustomer.Id,
                  Product2Id = p.Id,
                  PT_Program__c = prog1.Id,
                  PT_Install_Location__c = instLoc2.Id
            );
            insert ast;

            prog1.MROD_Approval_Status__c = 'Approved';
            update prog1;
            
            Test.startTest();
            try {
                delete ast;
            } catch (Exception e) {
                gotError = true;
                System.debug('*** e ' + e.getMessage());
            }
            Test.stopTest();
        }
        System.assertEquals(false, gotError);
    }
}