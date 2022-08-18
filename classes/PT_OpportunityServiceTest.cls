/**
* @File Name          : PT_OpportunityServiceTest.cls
* @Description        : Test Class for PT_OpportunityService
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class PT_OpportunityServiceTest {
    @IsTest
    static void testBehavior() {
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
        
        L2I_DSH__c dsh = new L2I_DSH__c(
              Product_Category__c = 'IFEC'
        );
        insert dsh;
        
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.today()
        );
        insert dsl;
        
        PT_OpportunityService.OppWrapper ow = PT_OpportunityService.getQuoteInitFields(salesOppty.Id);
        System.debug('*** ow ' + ow);
    
    }
    
    @IsTest
    static void testSolGroups() {
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<SBQQ__SolutionGroup__c> sgList = PT_OpportunityService.getSolutionGroups();
        System.assertEquals(1, [SELECT COUNT() FROM SBQQ__SolutionGroup__c]);
    }
    
    @IsTest
    static void testGetOpp() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;

        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        
        PT_OpportunityService.oppWrapper pwList = PT_OpportunityService.getOpportunity(salesOppty.Id);
        System.assertEquals(1, [SELECT COUNT() FROM Opportunity WHERE RecordType.DeveloperName = 'Sales']);
    
    }
    
    @IsTest
    static void testFindParts() {
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
        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Program_Num__c = prog1.Id;
        update salesOppty;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Id
        };
        
        String partFilter = '';
        
        Product2 product = factory.createProduct('99999802', 'MediaServices', 'IFEC', 'IFE HW', null);
        product.productCode = 'MCS BUNDLE';
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe;
        
        PT_OpportunityService.oppWrapper oppData = PT_OpportunityService.getOpportunity(salesOppty.Id);
        List<PT_OpportunityService.partsWrapper> pwList = PT_OpportunityService.findPartsForIL(oppData, solGroupList, partFilter, 'Add', null);
        System.assertEquals(1, pwList.size());
    
    }
    
    @IsTest
    static void testSaveParts() {
        L2I_DataFactory factory = new L2I_DataFactory();
        //Added by Jan Geronga for W-003833: Start
		List<Product2> lProd = new List<Product2>();
        List<PricebookEntry> lPBE = new List<PricebookEntry>(); 
        List<SBQQ__Cost__c> lCost = new List<SBQQ__Cost__c>(); 
        //Added by Jan Geronga for W-003833: End
		
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
        
        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Program_Num__c = prog1.Id;
        update salesOppty;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Id
        };
        
        String partFilter = '';
        
        Product2 product = factory.createProduct('99999802', 'MediaServices', 'IFEC', 'IFE HW', null);
        product.productCode = 'MCS BUNDLE';
        lProd.add(product);
        
        //Added by Jan Geronga for W-003833
        Product2 product2 = factory.createProduct('99999803', 'MediaServices2', 'IFEC', 'IFE HW', null);
        product.productCode = 'MCS BUNDLE 2';
        lProd.add(product2);
        insert lProd;
        //Added by Jan Geronga for W-003833: End
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product.Id,
              UnitPrice = 1000,
              IsActive = true);
        lPBE.add(pbe);

        //Added by Jan Geronga for W-003833
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product2.Id,
              UnitPrice = 50,
              IsActive = true);
        lPBE.add(pbe2);
        insert lPBE;
        //Added by Jan Geronga for W-003833: End
        
        //Added by Jan Geronga for W-003833: Start
        SBQQ__Cost__c cost = new SBQQ__Cost__c(SBQQ__Product__c	= product.Id, SBQQ__Active__c = true, SBQQ__UnitCost__c = 100);
        lCost.add(cost);
        
        SBQQ__Cost__c cost2 = new SBQQ__Cost__c(SBQQ__Product__c = product2.Id, SBQQ__Active__c = true, SBQQ__UnitCost__c = 100);
        lCost.add(cost2);
        insert lCost;
        //Added by Jan Geronga for W-003833: End
        
        PT_OpportunityService.oppWrapper oppData = PT_OpportunityService.getOpportunity(salesOppty.Id);
        List<PT_OpportunityService.partsWrapper> pwList = PT_OpportunityService.findPartsForIL(oppData, solGroupList, partFilter, 'Add', null);
        
        System.debug('*** pwList ' + pwList);
        pwList[0].configQty = 10;
        PT_OpportunityService.partsReturnWrapper prw = PT_OpportunityService.savePartsForOpportunity(pwList, salesOppty.Id, solGroupList, 'Add');
        //Added by Jan Geronga for W-003833
        PT_OpportunityService.partsReturnWrapper prw2 = PT_OpportunityService.getSelectedParts(pwList, salesOppty.Id, solGroupList, 'Selected');
        System.assertEquals(3, prw.pwList.size());
    }
    
    @IsTest
    static void testNoProgram() {
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
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        update salesOppty;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Id
        };
        
        String partFilter = '';
        
        Product2 product = factory.createProduct('99999802', 'MediaServices', 'IFEC', 'IFE HW', null);
        product.productCode = 'MCS BUNDLE';
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe;
        
        PT_OpportunityService.oppWrapper oppData = PT_OpportunityService.getOpportunity(salesOppty.Id);
        List<PT_OpportunityService.partsWrapper> pwList = PT_OpportunityService.findPartsForIL(oppData, solGroupList, partFilter, 'Add', null);
        
        System.assertEquals(1, pwList.size());
        System.assertEquals('Related Program is required in order to Add Parts', oppData.Msg);
    
    }
    
    @IsTest
    static void testGetOppFromAsset() {
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
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Name
        };
        
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        System.debug('*** ' + [select Part_List_Opportunity__c from PT_Install_Location__c]);
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;
        
        String partFilter = '';
        
        Product2 product = factory.createProduct('99999802', 'MediaServices', 'IFEC', 'IFE HW', null);
        product.productCode = 'MCS BUNDLE';
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = product.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;
        
        PT_OpportunityService.oppWrapper oppData = PT_OpportunityService.getOpportunityFromAsset(ast.Id);
        System.assertEquals('Related Program is required in order to Add Parts', oppData.Msg);
    }
    
    @IsTest
    static void testGetAssetNoBasePart() {
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
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Name
        };
        
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        System.debug('*** ' + [select Part_List_Opportunity__c from PT_Install_Location__c]);
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;
        
        String partFilter = '';
        
        Product2 product = factory.createProduct('99999802', 'MediaServices', 'IFEC', 'IFE HW', null);
        product.productCode = 'MCS BUNDLE';
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = product.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;
        
        PT_OpportunityService.partsReturnWrapper prw = PT_OpportunityService.getAsset(ast.Id, 'Replace');
//        List<PT_OpportunityService.partsWrapper> pwList = PT_OpportunityService.findPartsForIL(oppData, solGroupList, partFilter, 'Add', null);

//        System.assertEquals(1, pwList.size());
        System.assertEquals('Error - There are no other versions of this Product Code.', prw.msg);
    
    }
    
    @IsTest
    static void testGetAssetBasePartOK() {
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
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Name
        };
        
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        System.debug('*** ' + [select Part_List_Opportunity__c from PT_Install_Location__c]);
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;
        
        String partFilter = '';
        
        Product2 product = factory.createProduct('99999802', 'MediaServices', 'IFEC', 'IFE HW', null);
        product.productCode = 'RD123-02';
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = product.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;
        
        PT_OpportunityService.partsReturnWrapper prw = PT_OpportunityService.getAsset(ast.Id, 'Replace');
        System.assertEquals('Part to Replace', prw.msg);
    }
    
    @IsTest
    static void testGetAssetBasePartPending() {
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
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Name
        };
        
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        System.debug('*** ' + [select Part_List_Opportunity__c from PT_Install_Location__c]);
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;
        
        String partFilter = '';
        
        Product2 product = factory.createProduct('99999802', 'MediaServices', 'IFEC', 'IFE HW', null);
        product.productCode = 'RD123-02';
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = product.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Pending_Quantity__c = 5,
              PT_Status__c = 'Active'
        );
        insert ast;
        
        PT_OpportunityService.partsReturnWrapper prw = PT_OpportunityService.getAsset(ast.Id, 'Replace');
//        List<PT_OpportunityService.partsWrapper> pwList = PT_OpportunityService.findPartsForIL(oppData, solGroupList, partFilter, 'Add', null);

//        System.assertEquals(1, pwList.size());
        System.assertEquals('Error - A Part with pending Quantity changes may not be replaced.', prw.msg);
    
    }
    
    @IsTest
    static void testFindReplace() {
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
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Name
        };
        
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        System.debug('*** ' + [select Part_List_Opportunity__c from PT_Install_Location__c]);
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;
        
        String partFilter = '';
        
        Product2 product = factory.createProduct('99999802', 'MediaServices', 'IFEC', 'IFE HW', null);
        product.productCode = 'RD123-02';
        product.Is_Placeholder_Part__c = true;
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe;
        
        Product2 product2 = factory.createProduct('99999803', 'MediaServices', 'IFEC', 'IFE HW', null);
        product2.productCode = 'RD123-03';
        insert product2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product2.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe2;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = product.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;
        
        Asset ast2 = new Asset(
              Name = 'Asset Name2',
              PT_Install_Location__c = instLoc2.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = product2.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 1,
              Quantity = 2,
              PT_Status__c = 'Active'
        );
        insert ast2;
        
        PT_OpportunityService.oppWrapper oppData = PT_OpportunityService.getOpportunityFromAsset(ast.Id);
        PT_OpportunityService.partsReturnWrapper prw = PT_OpportunityService.getAsset(ast.Id, 'Replace');
        List<PT_OpportunityService.partsWrapper> pwList = PT_OpportunityService.findPartsForIL(oppData, solGroupList, partFilter, 'Replace', prw.pwList[0]);
        for (PT_OpportunityService.partsWrapper pw : pwList) {
            System.debug('*** pw ' + pw);
        }
        System.assertEquals(1, pwList.size());
    
    }
    
    @IsTest
    static void testSaveReplaceParts() {
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
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
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
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        System.debug('*** ' + [select Part_List_Opportunity__c from PT_Install_Location__c]);
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;
        
        String partFilter = '';
        
        Product2 product = factory.createProduct('99999802', 'MediaServices', 'IFEC', 'IFE HW', null);
        product.productCode = 'RD123-02';
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe;
        
        Product2 product2 = factory.createProduct('99999803', 'MediaServices', 'IFEC', 'IFE HW', null);
        product2.productCode = 'RD123-03';
        insert product2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product2.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe2;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = product.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;
        
        Asset ast2 = new Asset(
              Name = 'Asset Name2',
              PT_Install_Location__c = instLoc2.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = product2.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 1,
              Quantity = 2,
              PT_Status__c = 'Active'
        );
        insert ast2;
        
        PT_OpportunityService.oppWrapper oppData = PT_OpportunityService.getOpportunityFromAsset(ast.Id);
        PT_OpportunityService.partsReturnWrapper prw = PT_OpportunityService.getAsset(ast.Id, 'Replace');
        List<PT_OpportunityService.partsWrapper> pwList = PT_OpportunityService.findPartsForIL(oppData, solGroupList, partFilter, 'Replace', prw.pwList[0]);
        
        System.assertEquals(1, pwList.size());
        
        pwList[0].configQty = 10;
        PT_OpportunityService.partsReturnWrapper prwSave = PT_OpportunityService.saveReplacementParts(pwList, oppData, prw.pwList[0], 'Replace');
        System.assertEquals(1, prwSave.pwList.size());
    }
    
    @IsTest
    static void testDeletePart() {
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
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Name
        };
        
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        System.debug('*** ' + [select Part_List_Opportunity__c from PT_Install_Location__c]);
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;
        
        String partFilter = '';
        
        Product2 product = factory.createProduct('99999802', 'MediaServices', 'IFEC', 'IFE HW', null);
        product.productCode = 'RD123-02';
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe;
        
        Product2 product2 = factory.createProduct('99999803', 'MediaServices', 'IFEC', 'IFE HW', null);
        product2.productCode = 'RD123-03';
        insert product2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product2.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe2;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = product.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;
        
        Asset ast2 = new Asset(
              Name = 'Asset Name2',
              PT_Install_Location__c = instLoc2.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = product2.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 1,
              Quantity = 2,
              PT_Status__c = 'Active'
        );
        insert ast2;
        
        PT_OpportunityService.oppWrapper oppData = PT_OpportunityService.getOpportunityFromAsset(ast.Id);
        PT_OpportunityService.partsReturnWrapper prw = PT_OpportunityService.getAsset(ast.Id, 'Delete');
        
        PT_OpportunityService.partsReturnWrapper prwSave = PT_OpportunityService.deletePart(prw.pwList, oppData, prw.pwList[0], 'Replace');
        System.assertEquals(1, prwSave.pwList.size());
    }
    
//    @IsTest
//    static void testSerialize() {
//        L2I_DataFactory factory = new L2I_DataFactory();
//        factory.setupTestContext(null, null, false);
//
//        Id customerRecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID;
//        Account acctCustomer = new Account(
//              Name = 'Acct1',
//              RecordTypeId = customerRecordTypeId);
//        insert acctCustomer;
//
//        Opportunity dealOppty = new Opportunity(
//              Name = 'Deal Opp',
//              CloseDate = Date.today(),
//              StageName = 'Open'
//        );
//        insert dealOppty;
//
//        PT_Program__c prog1 = new PT_Program__c();
//        prog1.Name = 'Prog1';
//        prog1.Program_Number__c = 'Prog1';
//        insert prog1;
//
//        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
//        Opportunity salesOppty = new Opportunity(
//              Name = 'Sales Opp',
//              AccountId = acctCustomer.Id,
//              RecordTypeId = RecordTypeIdOpportunitySales,
//              L2I_Product_Category__c = 'IFEC',
//              CloseDate = Date.today(),
//              StageName = 'Handoff',
//              L2I_Parent_Opportunity__c = dealOppty.Id,
//              L2I_AircraftQuantity__c = 1,
//              L2I_Program_Num__c = prog1.Id
//        );
//        insert salesOppty;
//
//        L2I_DSH__c dsh = new L2I_DSH__c();
//        insert dsh;
//        update dsh;
//        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
//        update salesOppty;
//
//        L2I_Aircraft_Type__c atype = new L2I_Aircraft_Type__c(
//              Name = 'F-18TestThis',
//              L2I_PAC_Type_Designator__c = 'ABCD',
//              L2I_Model__c = 'GT',
//              Manufacturer__c = acctCustomer.Id,
//              L2I_Aircraft_Type__c = 'MyTest',
//              L2I_Is_Active__c = true,
//              L2I_Manufacturer_Party_ID__c = 123456,
//              L2I_Make__c = 'ABC',
//              L2I_Series__c = 'DEF'
//        );
//        insert atype;
//
//        L2I_Aircraft__c ac = new L2I_Aircraft__c(
//              L2I_Aircraft_Status__c = 'In Service',
//              Name = 'Test A/C 1',
//              L2I_GPIN__c = 'A319-1100',
//              L2I_Operator__c = acctCustomer.Id,
//              L2I_Serial_Number__c = 'abc12289',
//              L2I_Aircraft_Delivery_Date__c = DATE.today().addDays(30),
//              Aircraft_Type__c = atype.Id,
//              L2I_Approved__c = true
//        );
//        insert ac;
//
//        L2I_DSL__c dsl = new L2I_DSL__c(
//              Delivery_Schedule_Header__c = dsh.Id,
//              PT_isActive__c = 'Active',
//              PT_Program__c = prog1.Id,
//              Name = '01',
//              Original_Opportunity__c = salesOppty.id,
//              Aircraft__c = ac.Id
//        );
//        insert dsl;
//
//        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
//              Name = 'EC',
//              ShipSet__c = dsl.Id,
//              PT_Program__c = prog1.Id,
//              Status__c = 'Active'
//        );
//        insert instLoc2;
//
//        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
//        prod.productCode = 'MCS BUNDLE';
//        insert prod;
//
//        Asset ast = new Asset(
//              Name = 'Asset Name',
//              PT_Install_Location__c = instLoc2.Id,
//              PT_Pending__c = Date.today(),
//              PT_Program__c = prog1.Id,
//              Product2Id = prod.Id,
//              AccountId = acctCustomer.Id,
//              PT_Configured_Quantity__c = 10,
//              Quantity = 10,
//              PT_Status__c = 'Active'
//        );
//        insert ast;
//
//        SBQQ__Quote__c qt = new SBQQ__Quote__c(
//              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
//              SBQQ__Account__c = acctCustomer.Id,
//              SBQQ__Opportunity2__c = salesOppty.Id,
//              SBQQ__OrderBy__c = 'L2I_Sub_Category_2__c',
//              SBQQ__Primary__c = true
//        );
//        insert qt;
//
//        Map<Id, String> prodCategoryMap = new Map<Id, String>();
//
//        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
//        Map<String, Id> prodIdMap = new Map<String, Id>();
//        List<Product2> updateProdList = new List<Product2>();
//
//        for (Product2 p : prodList) {
//            p.L2I_Migrate__c = true;
//            p.SBQQ__ChargeType__c = 'Usage';
//            p.SBQQ__BillingType__c = '';
//            p.L2I_Service_Activation_Type__c = 'Monthly';
//            updateProdList.add(p);
//            prodIdMap.put(p.Name, p.Id);
//            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
//        }
//
//        update updateProdList;
//
//        Set<String> ProductNameList = new Set<String>();
//
//        ProductNameList.add('Toca Boca - Toca Cars');
//        Set<Id> prodIdList = New Set<Id>();
//
//        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
//        for (String s : ProductNameList) {
//            Id pid = prodIdMap.get(s);
//            prodIdList.add(pid);
//            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(qt.Id, pid, null);
//            quoteLine.SBQQ__Quantity__c = 1;
//            quoteLine.SBQQ__SpecialPrice__c = 5;
//            quoteLine.PT_Asset__c = ast.Id;
//            qlList.add(quoteLine);
//        }
//        insert qlList;
//
//        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
//              Name = 'ALT'
//        );
//        insert sg;
//
//        List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
//        for (SBQQ__QuoteLine__c ql : qlList) {
//            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
//            qlg.SBQQ__Account__c = acctCustomer.id;
//            qlg.SBQQ__SolutionGroup__c = sg.Id;
//            qlg.SBQQ__Quote__c = qt.Id;
//            qlgList.add(qlg);
//        }
//        insert qlgList;
//
//        salesOppty.StageName = 'Delivery';
//        salesOppty.PT_Current_Parts_List__c = qt.Id;
//        update salesOppty;
//
//        Opportunity opp = [
//              SELECT Id, Name, PT_Is_CPL__c, L2I_Delivery_Schedule__c, PT_Part_List_Name_Rev__c, RecordTypeId,
//                    RecordType.DeveloperName, L2I_Product_Category__c
//              FROM Opportunity
//              WHERE Id = :salesOppty.Id
//        ];
//
//        Test.startTest();
//        Boolean foundErr = false;
//        String msg = '';
//        try {
//            PT_OpportunityService.serializeOppShipset(opp, qt.Id);
//        } catch (Exception e) {
//            foundErr = true;
//            msg = e.getMessage();
//        }
//        Test.stopTest();
//        System.assertEquals(false, foundErr, msg);
//        System.assertEquals(1, [select count() from contentversion]);
//    }
    
    @IsTest
    static void testRefreshParts() {
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
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
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
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        System.debug('*** ' + [select Part_List_Opportunity__c from PT_Install_Location__c]);
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;
        
        String partFilter = '';
    
        createKits(instLoc.Id, pgm.Id, namedCustomer.Id, true);
        
        Asset ast = [SELECT Id FROM Asset WHERE PT_Kit_Parent__c = null LIMIT 1];
    
        PT_OpportunityService.oppWrapper oppData = PT_OpportunityService.getOpportunityFromAsset(ast.Id);
        PT_OpportunityService.partsReturnWrapper prw = PT_OpportunityService.getAsset(ast.Id, 'Refresh');
        List<PT_OpportunityService.partsWrapper> pwList = new List<PT_OpportunityService.partsWrapper>();
        pwList.add(prw.pwList[0]);
        PT_OpportunityService.partsReturnWrapper pwReturnList = PT_OpportunityService.refreshKitPart(pwList, oppData, prw.pwList[0], 'Refresh');
        System.assertEquals(1, pwList.size());
        
        //added for W-003304
		List<PT_OpportunityService.KitComponentWrapper> kitWList = new List<PT_OpportunityService.KitComponentWrapper>();
		kitWList = PT_OpportunityService.getKitComponents(ast.Id);
        
        PT_OpportunityService.ShipSetWrapper ssWList = new PT_OpportunityService.ShipSetWrapper();
        ssWList = PT_OpportunityService.getShipSet(dsl.Id);                
    }
    
    @IsTest
    static void testSaveKitParts() {
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
        
        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Program_Num__c = prog1.Id;
        update salesOppty;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Id
        };
        
        String partFilter = '';

        createKits(null, null, null, false);
        
        PT_OpportunityService.oppWrapper oppData = PT_OpportunityService.getOpportunity(salesOppty.Id);
        List<PT_OpportunityService.partsWrapper> pwList = PT_OpportunityService.findPartsForIL(oppData, solGroupList, partFilter, 'Add', null);
        
        System.debug('*** pwList ' + pwList);
        pwList[0].configQty = 10;
        PT_OpportunityService.partsReturnWrapper prw = PT_OpportunityService.savePartsForOpportunity(pwList, salesOppty.Id, solGroupList, 'Add');
        System.assertEquals(5, prw.pwList.size());
        
        //W-003304              
        //update salesOppty;
    	List<PT_OpportunityService.CPLWrapper> pcplList = PT_OpportunityService.getProgramCPLs(prog1.Id, dealOppty.Id);
    }
    
    @IsTest
    static void testGetNotes() {
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
        
        
        SBQQ__Quote__c quote0 = factory.createQuote('draft', namedCustomer.Id, salesOppty.Id, false);
        quote0.ApprovalStatus__c = 'Approved';
        insert quote0;
        
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
    
       
    
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        
        String partFilter = '';
        
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;
    
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;
        
        PT_Note__c note = new PT_Note__c(
              PT_Note_Name__c = 'Note A',
              PT_Sequence__c = 1,
              PT_Opportunity__c = salesOppty.Id,
              PT_Notes__c = 'Note123'
        );
        insert note;
        
        PT_OpportunityService.oppWrapper oppData = PT_OpportunityService.getOpportunityFromAsset(ast.Id);
        PT_OpportunityService.partsReturnWrapper prw = PT_OpportunityService.getAsset(ast.Id, 'Refresh');

        List<PT_OpportunityService.noteWrapper> nw = PT_OpportunityService.getNotes(oppData);
        System.assertEquals(1, nw.size());
        
        //W-003304
        try{
        	//PT_OpportunityService.moveShipSet(dsl.id, salesOppty.id);
        }catch(Exception ex){
            
        }
    }
    
    @IsTest
    static void testSaveNotes() {
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
        
        
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        
        String partFilter = '';
        
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;
        
        PT_Note__c note = new PT_Note__c(
              PT_Sequence__c = 1,
              PT_Opportunity__c = salesOppty.Id,
              PT_Notes__c = 'Note123'
        );
        insert note;
        
        PT_OpportunityService.oppWrapper oppData = PT_OpportunityService.getOpportunityFromAsset(ast.Id);
        PT_OpportunityService.partsReturnWrapper prw = PT_OpportunityService.getAsset(ast.Id, 'Note');
        
        List<PT_OpportunityService.noteWrapper> nw = PT_OpportunityService.getNotes(oppData);
        System.assertEquals(1, nw.size());
        
    
        PT_OpportunityService.saveNote(nw, prw.pwList[0]);
        System.assertEquals(1, [SELECT COUNT() FROM Asset WHERE PT_Pending_Notes__c = :nw[0].noteName]);
        PT_OpportunityService.saveNote(nw, prw.pwList[0]);
        System.assertEquals(1, [SELECT COUNT() FROM Asset WHERE PT_Pending_Notes__c = :nw[0].noteName], 'Found match');
    
    }
    
    @IsTest
    static void testRevertPending() {
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
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        
        String partFilter = '';
        
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
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
        
        PT_OpportunityService.oppWrapper oppData = PT_OpportunityService.getOpportunityFromAsset(ast.Id);
        PT_OpportunityService.partsReturnWrapper prw = PT_OpportunityService.getAsset(ast.Id, 'Refresh');
        String oppId = oppData.OppId;
        List<String> oppIdList = new List<String>();
        oppIdList.add(oppId);
        PT_OpportunityService.revertPartList(oppIdList);
        System.assertEquals(null, [SELECT Id, PT_Pending_Quantity__c FROM Asset LIMIT 1].PT_Pending_Quantity__c);
    }
    
    @IsTest
    static void testRevertNew() {
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
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        
        String partFilter = '';
        
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'New'
        );
        insert ast;
        
        PT_OpportunityService.oppWrapper oppData = PT_OpportunityService.getOpportunityFromAsset(ast.Id);
        PT_OpportunityService.partsReturnWrapper prw = PT_OpportunityService.getAsset(ast.Id, 'Refresh');
        String oppId = oppData.OppId;
        List<String> oppIdList = new List<String>();
        oppIdList.add(oppId);
        PT_OpportunityService.revertPartList(oppIdList);
        System.assertEquals(0, [SELECT COUNT() FROM Asset]);
    }
    
    @IsTest
    static void testRevertMove() {
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
              PT_Status__c = 'Pending Move'
        );
        insert ast;
        
        PT_OpportunityService.oppWrapper oppData = PT_OpportunityService.getOpportunityFromAsset(ast.Id);
        PT_OpportunityService.partsReturnWrapper prw = PT_OpportunityService.getAsset(ast.Id, 'Refresh');
        String oppId = oppData.OppId;
        List<String> oppIdList = new List<String>();
        oppIdList.add(oppId);
        PT_OpportunityService.revertPartList(oppIdList);
        System.assertEquals('BC', [SELECT PT_Install_Location__r.Name FROM Asset LIMIT 1].PT_Install_Location__r.Name);
    }
    
    private static void createKits(Id instLocId, Id pgmId, Id namedCustomerId, Boolean createAssets) {
        L2I_DataFactory factory = new L2I_DataFactory();
        
        // create 2 Kit products with different rev codes
        Product2 product = factory.createProduct('99999802', 'MediaServices', 'IFEC', 'IFE HW', null);
        product.productCode = 'RD123-02';
        product.L2I_Is_Kit__c = true;
        product.PT_Kit_Current_Revision__c = 'BB';
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe;
        
        // create 4 kit child components
        Product2 product4 = factory.createProduct('99999804', 'MediaServices', 'IFEC', 'IFE HW', null);
        product4.productCode = 'RD123-04';
        insert product4;
        
        PricebookEntry pbe4 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product4.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe4;
        
        Product2 product5 = factory.createProduct('99999805', 'MediaServices', 'IFEC', 'IFE HW', null);
        product5.productCode = 'RD123-05';
        insert product5;
        
        PricebookEntry pbe5 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product5.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe5;
        
        Product2 product6 = factory.createProduct('99999806', 'MediaServices', 'IFEC', 'IFE HW', null);
        product6.productCode = 'RD123-06';
        insert product6;
        
        PricebookEntry pbe6 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product6.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe6;
        
        Product2 product7 = factory.createProduct('99999807', 'MediaServices', 'IFEC', 'IFE HW', null);
        product7.productCode = 'RD123-07';
        insert product7;
        
        PricebookEntry pbe7 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product7.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe7;
        
        // create the Kit Part junction records
        // same product as kit with 2 compoents rev AA and 2 components BB
        Kit_Products__c k0 = new Kit_Products__c(
              PT_Component_Part__c = product4.Id,
              PT_Component_Part_Quantity__c = 3,
              PT_Kit_Part__c = product.Id,
              PT_Kit_Revision_Code__c = 'AA'
        );
        insert k0;
        Kit_Products__c k1 = new Kit_Products__c(
              PT_Component_Part__c = product5.Id,
              PT_Component_Part_Quantity__c = 2,
              PT_Kit_Part__c = product.Id,
              PT_Kit_Revision_Code__c = 'AA'
        );
        insert k1;
        Kit_Products__c k2 = new Kit_Products__c(
              PT_Component_Part__c = product6.Id,
              PT_Component_Part_Quantity__c = 5,
              PT_Kit_Part__c = product.Id,
              PT_Kit_Revision_Code__c = 'BB'
        );
        insert k2;
        // same child product
        Kit_Products__c k3 = new Kit_Products__c(
              PT_Component_Part__c = product5.Id,
              PT_Component_Part_Quantity__c = 22,
              PT_Kit_Part__c = product.Id,
              PT_Kit_Revision_Code__c = 'BB'
        );
        insert k3;
        
        if (createAssets) {
            // kit part asset and component parts
            List<Asset> assetList = new List<Asset>();
            Asset ast1 = new Asset(
                  Name = 'Asset Name1',
                  PT_Install_Location__c = instLocId,
                  PT_Pending__c = Date.today(),
                  PT_Program__c = pgmId,
                  Product2Id = product.Id,
                  AccountId = namedCustomerId,
                  PT_Configured_Quantity__c = 1,
                  Quantity = 2,
                  PT_Status__c = 'Active',
                  PT_Kit_Revision_Code__c = 'AA'
            );
            assetList.add(ast1);
    
            Asset ast4 = new Asset(
                  Name = 'Asset Name1',
                  PT_Install_Location__c = instLocId,
                  PT_Pending__c = Date.today(),
                  PT_Program__c = pgmId,
                  Product2Id = product4.Id,
                  AccountId = namedCustomerId,
                  PT_Configured_Quantity__c = 1,
                  Quantity = 2,
                  PT_Status__c = 'Active',
                  PT_Kit_Parent__c = ast1.Id
            );
            assetList.add(ast4);
            Asset ast5 = new Asset(
                  Name = 'Asset Name1',
                  PT_Install_Location__c = instLocId,
                  PT_Pending__c = Date.today(),
                  PT_Program__c = pgmId,
                  Product2Id = product5.Id,
                  AccountId = namedCustomerId,
                  PT_Configured_Quantity__c = 1,
                  Quantity = 2,
                  PT_Status__c = 'Active',
                  PT_Kit_Parent__c = ast1.Id
            );
            assetList.add(ast5);
            Asset ast6 = new Asset(
                  Name = 'Asset Name1',
                  PT_Install_Location__c = instLocId,
                  PT_Pending__c = Date.today(),
                  PT_Program__c = pgmId,
                  Product2Id = product6.Id,
                  AccountId = namedCustomerId,
                  PT_Configured_Quantity__c = 1,
                  Quantity = 2,
                  PT_Status__c = 'Active',
                  PT_Kit_Parent__c = ast1.Id
            );
            assetList.add(ast6);
            Asset ast7 = new Asset(
                  Name = 'Asset Name1',
                  PT_Install_Location__c = instLocId,
                  PT_Pending__c = Date.today(),
                  PT_Program__c = pgmId,
                  Product2Id = product7.Id,
                  AccountId = namedCustomerId,
                  PT_Configured_Quantity__c = 1,
                  Quantity = 2,
                  PT_Status__c = 'Active',
                  PT_Kit_Parent__c = ast1.Id
            );
            assetList.add(ast7);
            insert assetList;
        }
    }
    
}