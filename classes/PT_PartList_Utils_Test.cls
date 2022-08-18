/**
* @File Name          : PT_PartList_Utils_Test.cls
* @Description        : Test Class for PT_PartList_Utils
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class PT_PartList_Utils_Test {
    @IsTest
    static void testUpdateAssets() {
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
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
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
              PT_Pending_Configured_Quantity__c = 15,
              Quantity = 10,
              PT_Pending_Quantity__c = 11,
              PT_Status__c = 'New'
        );
        insert ast;
        
        Test.startTest();
        Boolean foundErr = false;
        String msg = '';
        try {
            PT_PartList_Utils.updateAssetsOnPartListApproval(salesOppty.Id);
        } catch (Exception e) {
            foundErr = true;
            msg = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(false, foundErr, msg);
        System.assertEquals(11, [SELECT Id, Quantity FROM Asset LIMIT 1 ].Quantity);
        System.assertEquals(15, [SELECT Id, PT_Configured_Quantity__c FROM Asset LIMIT 1 ].PT_Configured_Quantity__c);
        System.assertEquals('Active', [SELECT Id, PT_Status__c FROM Asset LIMIT 1 ].PT_Status__c);
    }
    
    @IsTest
    static void testUpdateAssetsPendingReplaced() {
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
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
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
              PT_Pending_Configured_Quantity__c = 15,
              Quantity = 10,
              PT_Status__c = 'Pending Replaced'
        );
        insert ast;
        
        Test.startTest();
        Boolean foundErr = false;
        String msg = '';
        try {
            PT_PartList_Utils.updateAssetsOnPartListApproval(salesOppty.Id);
        } catch (Exception e) {
            foundErr = true;
            msg = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(false, foundErr, msg);
        System.assertEquals(15, [SELECT Id, PT_Configured_Quantity__c FROM Asset LIMIT 1 ].PT_Configured_Quantity__c);
        System.assertEquals('Active', [SELECT Id, PT_Status__c FROM Asset LIMIT 1 ].PT_Status__c);
    }
    @IsTest
    static void testUpdateAssetsPendingRemoved() {
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
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
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
              PT_Status__c = 'Pending Removed'
        );
        insert ast;
        
        Test.startTest();
        Boolean foundErr = false;
        String msg = '';
        try {
            PT_PartList_Utils.updateAssetsOnPartListApproval(salesOppty.Id);
        } catch (Exception e) {
            foundErr = true;
            msg = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(false, foundErr, msg);
        System.assertEquals('Removed', [SELECT Id, PT_Status__c FROM Asset LIMIT 1 ].PT_Status__c);
    }
    
    @IsTest
    static void testCreatePLRNew() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
		
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Program_Num__c = pgm.Id;
        update salesOppty;
        
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Id
        };
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl2;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'BC',
              ShipSet__c = dsl2.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc2;
        
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Original_Install_Location__c = instLoc2.Name,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'New',
              PT_Pending_Quantity__c = 15
        );
        insert ast;
        
        List<Id> oppIdList = new List<Id>();
        oppIdList.add(salesOppty.Id);
        PT_PartList_Utils.createPendingPartListRecords(oppIdList);
        System.assertEquals(1, [SELECT COUNT() FROM PT_Parts_List_Revision__c]);
    }
    
    @IsTest
    static void testCreatePLRChangeQty() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Program_Num__c = pgm.Id;
        update salesOppty;
        
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Id
        };
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl2;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'BC',
              ShipSet__c = dsl2.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc2;
        
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Original_Install_Location__c = instLoc2.Name,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active',
              PT_Pending_Quantity__c = 15
        );
        insert ast;
        
        List<Id> oppIdList = new List<Id>();
        oppIdList.add(salesOppty.Id);
        PT_PartList_Utils.createPendingPartListRecords(oppIdList);
        System.assertEquals(1, [SELECT COUNT() FROM PT_Parts_List_Revision__c]);
    }
    
    @IsTest
    static void testCreatePLRNotes() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Program_Num__c = pgm.Id;
        update salesOppty;
        
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Id
        };
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl2;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'BC',
              ShipSet__c = dsl2.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc2;
        
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Original_Install_Location__c = instLoc2.Name,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active',
              PT_Pending_Notes__c = 'A,C',
              PT_Notes__c = 'A,D',
              PT_Notes_Status__c = '[{"noteStatus":"Delete","noteName":"D"},{"noteStatus":"Add","noteName":"C"}]'
        );
        insert ast;
        
        List<Id> oppIdList = new List<Id>();
        oppIdList.add(salesOppty.Id);
        PT_PartList_Utils.createPendingPartListRecords(oppIdList);
        System.assertEquals(1, [SELECT COUNT() FROM PT_Parts_List_Revision__c]);
    }
    
    @IsTest
    static void testCreatePLRRemoveNotes() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Program_Num__c = pgm.Id;
        update salesOppty;
        
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Id
        };
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl2;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'BC',
              ShipSet__c = dsl2.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc2;
        
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Original_Install_Location__c = instLoc2.Name,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active',
              PT_Pending_Notes__c = 'Remove Notes',
              PT_Notes__c = 'A,D',
              PT_Notes_Status__c = '[{"noteStatus":"Delete","noteName":"D"},{"noteStatus":"Delete","noteName":"C"}]'
        );
        insert ast;
        
        List<Id> oppIdList = new List<Id>();
        oppIdList.add(salesOppty.Id);
        PT_PartList_Utils.createPendingPartListRecords(oppIdList);
        System.assertEquals(1, [SELECT COUNT() FROM PT_Parts_List_Revision__c]);
    }
    
    @IsTest
    static void testCreatePLRPendingRemoved() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;

        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Program_Num__c = pgm.Id;
        update salesOppty;
        
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Id
        };
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl2;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'BC',
              ShipSet__c = dsl2.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc2;
        
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Original_Install_Location__c = instLoc2.Name,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Pending Removed',
              PT_Pending_Quantity__c = 15
        );
        insert ast;

        Asset ast2 = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Original_Install_Location__c = instLoc2.Name,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Pending Replaced',
              PT_Pending_Quantity__c = 15,
              ParentId = ast.Id
        );
        insert ast2;
        
        List<Id> oppIdList = new List<Id>();
        oppIdList.add(salesOppty.Id);
        PT_PartList_Utils.createPendingPartListRecords(oppIdList);
        System.assertEquals(2, [SELECT COUNT() FROM PT_Parts_List_Revision__c]);
    }
    
    @IsTest
    static void testCreatePLRPendingRemoved2() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;

        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Program_Num__c = pgm.Id;
        update salesOppty;
        
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Id
        };
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl2;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'BC',
              ShipSet__c = dsl2.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc2;
        
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Original_Install_Location__c = instLoc2.Name,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Pending Removed',
              PT_Pending_Quantity__c = 15
        );
        insert ast;

        
        List<Id> oppIdList = new List<Id>();
        oppIdList.add(salesOppty.Id);
        PT_PartList_Utils.createPendingPartListRecords(oppIdList);
        System.assertEquals(1, [SELECT COUNT() FROM PT_Parts_List_Revision__c]);
    }
}