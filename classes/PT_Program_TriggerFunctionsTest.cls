/**
* @File Name          : PT_Program_TriggerFunctionsTest.cls
* @Description        : Test Class for PT_Program_TriggerFunctions
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@isTest
private class PT_Program_TriggerFunctionsTest {
    @isTest
    private static void addUpdateProgramNameTest() {
        PT_Program__c prog = new PT_Program__c();
        prog.Name = 'Test1234';
        prog.Program_Number__c = 'Test1234';
        insert prog;

        prog.Program_Number__c = 'Test7890';
        prog.Name = 'Test7890';
        update prog;
    }

    @isTest
    private static void addMemberToQueueTest() {

        setupForQueues();

        User u1 = [SELECT Id FROM User WHERE FirstName = 'User1' LIMIT 1];
        Group grpObj = [SELECT Id FROM Group WHERE Name = 'Program PM Group' LIMIT 1];
        System.runAs(u1) {
            PT_Program__c prog = new PT_Program__c();
            prog.Name = 'Test1234';
            prog.Program_Number__c = 'Test1234';
            prog.Program_Manager__c = u1.Id;
            Test.startTest();
            insert prog;
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :u1.Id]);
    }

    @isTest
    private static void deleteMemberToQueueTest() {

        setupForQueues();

        User u1 = [SELECT Id FROM User WHERE FirstName = 'User1' LIMIT 1];
        Group grpObj = [SELECT Id FROM Group WHERE Name = 'Program PM Group' LIMIT 1];
        System.runAs(u1) {
            PT_Program__c prog = new PT_Program__c();
            prog.Name = 'Test1234';
            prog.Program_Number__c = 'Test1234';
            prog.Program_Manager__c = u1.Id;
            insert prog;
            Test.startTest();
            delete prog;
            Test.stopTest();
        }
        System.assertEquals(0, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :u1.Id]);
    }

    @isTest
    private static void deleteMemberMultipleToQueueTest() {

        setupForQueues();

        User u1 = [SELECT Id FROM User WHERE FirstName = 'User1' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE FirstName = 'User2' LIMIT 1];
        User u3 = [SELECT Id FROM User WHERE FirstName = 'User3' LIMIT 1];
        Group grpObj = [SELECT Id FROM Group WHERE Name = 'Program PM Group' LIMIT 1];
        System.runAs(u1) {
            PT_Program__c prog1 = new PT_Program__c();
            prog1.Name = 'Test12345';
            prog1.Program_Number__c = 'Test12345';
            prog1.Program_Manager__c = u1.Id;
            insert prog1;
            PT_Program__c prog2 = new PT_Program__c();
            prog2.Name = 'Test1234';
            prog2.Program_Number__c = 'Test1234';
            prog2.Program_Manager__c = u1.Id;
            insert prog2;
            PT_Program__c prog3 = new PT_Program__c();
            prog3.Name = 'Test12346';
            prog3.Program_Number__c = 'Test12346';
            prog3.Program_Manager__c = u2.Id;
            insert prog3;
            Test.startTest();
            delete prog2;
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :u1.Id]);
    }

    @isTest
    private static void changeMemberToQueueTest() {

        setupForQueues();

        User u1 = [SELECT Id FROM User WHERE FirstName = 'User1' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE FirstName = 'User2' LIMIT 1];
        Group grpObj = [SELECT Id FROM Group WHERE Name = 'Program PM Group' LIMIT 1];
        System.runAs(u1) {
            PT_Program__c prog = new PT_Program__c();
            prog.Program_Manager__c = u1.Id;
            prog.Name = 'Test1234';
            prog.Program_Number__c = 'Test1234';
            insert prog;
            System.debug('*** ' + [SELECT Name, Program_Number__c FROM PT_Program__c]);
            Test.startTest();
            prog.Program_Manager__c = u2.Id;
            update prog;
            Test.stopTest();
        }
        System.assertEquals(0, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :u1.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :u2.Id]);
    }

    @isTest
    private static void addnewPMOGroup() {
        setupForQueues();

        User u1 = [SELECT Id, Name FROM User WHERE FirstName = 'User1' LIMIT 1];
        User u2 = [SELECT Id, Name FROM User WHERE FirstName = 'User2' LIMIT 1];

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
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;

        Opportunity salesOppty = new Opportunity(
              Name = 'Sales Opp',
              AccountId = acctCustomer.Id,
              RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
              L2I_Product_Category__c = 'IFEC',
              CloseDate = Date.today(),
              StageName = 'Quotation',
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Fit_Type__c = '',
              L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;

        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;

        PT_PMO_Groups__c pg = new PT_PMO_Groups__c(
              Name = 'pgName',
              Group_Type__c = 'Group'
        );
        insert pg;
        pg.OwnerId = u1.Id;
        update pg;

        PT_PMO_Groups__c pg2 = new PT_PMO_Groups__c(
              Name = 'pgName2',
              Group_Type__c = 'Sub Group'
        );
        insert pg2;
        pg2.OwnerId = u2.Id;
        update pg2;

        PT_Program__c pgm = new PT_Program__c(
              Name = 'Test1234',
              Program_Number__c = 'Test1234',
              PT_PMO_Group__c = pg.Id,
              PT_PMO_SubGroup__c = pg2.Id
        );
        Test.startTest();
        insert pgm;
        Test.stopTest();
        System.assertEquals(u1.Id, [SELECT PMO_Regional_Director__c FROM PT_Program__c].PMO_Regional_Director__c, 'Regional Directory is PMO Group Owner');
        System.assertEquals(u2.Id, [SELECT Principal_Program_Manager__c FROM PT_Program__c].Principal_Program_Manager__c, 'PPM is PMO Sub Group Owner');

    }

    @isTest
    private static void changePMOGroup() {
        setupForQueues();

        User u1 = [SELECT Id, Name FROM User WHERE FirstName = 'User1' LIMIT 1];
        User u2 = [SELECT Id, Name FROM User WHERE FirstName = 'User2' LIMIT 1];

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
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
		
        Opportunity salesOppty = new Opportunity(
              Name = 'Sales Opp',
              AccountId = acctCustomer.Id,
              RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
              L2I_Product_Category__c = 'IFEC',
              CloseDate = Date.today(),
              StageName = 'Quotation',
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;

        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;

        PT_PMO_Groups__c pg = new PT_PMO_Groups__c(
              Name = 'pgName',
              Group_Type__c = 'Group'
        );
        insert pg;
        pg.OwnerId = u1.Id;
        update pg;

        PT_PMO_Groups__c pg2 = new PT_PMO_Groups__c(
              Name = 'pgName2',
              Group_Type__c = 'Sub Group'
        );
        insert pg2;
        pg2.OwnerId = u2.Id;
        update pg2;

        PT_PMO_Groups__c pg3 = new PT_PMO_Groups__c(
              Name = 'pgName3',
              Group_Type__c = 'Group'
        );
        insert pg3;
        pg3.OwnerId = u2.Id;
        update pg3;

        PT_PMO_Groups__c pg4 = new PT_PMO_Groups__c(
              Name = 'pgName4',
              Group_Type__c = 'Sub Group'
        );
        insert pg4;
        pg4.OwnerId = u1.Id;
        update pg4;

        PT_Program__c pgm = new PT_Program__c(
              Name = 'Test1234',
              Program_Number__c = 'Test1234',
              PT_PMO_Group__c = pg.Id,
              PT_PMO_SubGroup__c = pg2.Id
        );
        insert pgm;
        pgm.PT_PMO_Group__c = pg3.Id;
        pgm.PT_PMO_SubGroup__c = pg4.Id;
        Test.startTest();
        update pgm;
        Test.stopTest();
        System.assertEquals(u2.Id, [SELECT PMO_Regional_Director__c FROM PT_Program__c].PMO_Regional_Director__c, 'Regional Directory is PMO Group Owner');
        System.assertEquals(u1.Id, [SELECT Principal_Program_Manager__c FROM PT_Program__c].Principal_Program_Manager__c, 'PPM is PMO Sub Group Owner');

    }


    @isTest
    private static void approveMROD() {
        L2I_DataFactory factory = new L2I_DataFactory();
//        factory.setupTestContext(null, null, false);
        
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
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;

        Opportunity salesOppty = new Opportunity(
              Name = 'Sales Opp',
              AccountId = acctCustomer.Id,
              RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
              L2I_Product_Category__c = 'IFEC',
              CloseDate = Date.today(),
              StageName = 'Quotation',
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;

        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.today()
        );
        insert dsl;

        PT_Program__c pgm = new PT_Program__c(
              Name = 'Test1234',
              Program_Number__c = 'Test1234'
        );
        insert pgm;
        System.debug('*** insert pgm');

        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active'
        );
        insert instLoc;

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
              PT_Install_Location__c = instLoc.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = acctCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;
        System.debug('*** inserted ast ' + ast);
        pgm.MROD_Approval_Status__c = 'Approved';
        Test.startTest();
        
        dsl.PT_Program__c = pgm.Id;
        update dsl;                
        
        System.debug('*** pgm ' + pgm);
        update pgm;
        Test.stopTest();

        System.assertEquals(Date.today(), [SELECT PT_MROD__c FROM Asset LIMIT 1].PT_MROD__c, 'Asset MROD Date set from Pending MROD');
    }

@isTest
    private static void updateFirstDeliveryDate() {
        L2I_DataFactory factory = new L2I_DataFactory();
//        factory.setupTestContext(null, null, false);
        
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
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
		
        Opportunity salesOppty = new Opportunity(
              Name = 'Sales Opp',
              AccountId = acctCustomer.Id,
              RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
              L2I_Product_Category__c = 'IFEC',
              CloseDate = Date.today(),
              StageName = 'Quotation',
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;
		
        List<L2I_DSL__c> dslList = new List<L2I_DSL__c>();
        
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.today()
        );
        dslList.add(dsl);
        
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.today().addDays(-30)
        );
        dslList.add(dsl2);
        
        L2I_DSL__c dsl3 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.today().addDays(30)
        );
        dslList.add(dsl3);
        
        insert dslList;

        PT_Program__c pgm = new PT_Program__c(
              Name = 'Test1234',
              Program_Number__c = 'Test1234',
              PT_First_Aircraft_Delivery__c = Date.today().addDays(100),
              Airbus_MROD_Approval_Status__c = 'Approved'
        );
        insert pgm;
        System.debug('*** insert pgm');

        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active'
        );
        insert instLoc;

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
              PT_Install_Location__c = instLoc.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = acctCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;
        System.debug('*** inserted ast ' + ast);
        pgm.MROD_Approval_Status__c = 'Approved';
        pgm.Airbus_MROD_Approval_Status__c = 'Approved';
        Test.startTest();
        
        dslList[0].PT_Program__c = pgm.Id;
        dslList[1].PT_Program__c = pgm.Id;
        update dsl;                
        
        System.debug('*** pgm ' + pgm);
        update pgm;
        Test.stopTest();

        System.assertEquals(Date.today(), [SELECT PT_MROD__c FROM Asset LIMIT 1].PT_MROD__c, 'Asset MROD Date set from Pending MROD');
    }
    private static void setupForQueues() {
        L2I_DataFactory df = new L2I_DataFactory();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'PAC Sales'].Id;
        User u1 = df.createTestUser(null, profileId, 'User1', 'Test');
        insert u1;
        User u2 = df.createTestUser(null, profileId, 'User2', 'Test');
        insert u2;
        User u3 = df.createTestUser(null, profileId, 'User3', 'Test');
        insert u3;
    }
}