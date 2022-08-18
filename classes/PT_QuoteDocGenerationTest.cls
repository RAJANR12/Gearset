/**
* @File Name          : PT_QuoteDocGenerationTest.cls
* @Description        : Test Class for PT_QuoteDocGeneration
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class PT_QuoteDocGenerationTest {
    @isTest
    static void testDocGen() {
        L2I_DataFactory factory = new L2I_DataFactory();
        
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        System.assert(acc.Id != null, 'Named Customer Account must have an Id');
        
        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');
    
        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Test1234';
        prog1.Program_Number__c = 'Test1234';
        insert prog1;
        
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
            
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = acc.Id,
              Product_Category__c = 'IFEC'
        );
        insert dsh;
        
        L2I_Aircraft_Type__c atype = new L2I_Aircraft_Type__c(
              Name = 'F-18TestThis',
              L2I_PAC_Type_Designator__c = 'ABCD',
              L2I_Model__c = 'GT',
              Manufacturer__c = acc.Id,
              L2I_Aircraft_Type__c = 'MyTest',
              L2I_Is_Active__c = true,
              L2I_Manufacturer_Party_ID__c = 123456,
              L2I_Make__c = 'ABC',
              L2I_Series__c = 'DEF'
        );
        insert atype;
        
        L2I_Aircraft__c ac = new L2I_Aircraft__c(
              L2I_Aircraft_Status__c = 'In Service',
              Name = 'Test A/C 1',
              L2I_GPIN__c = 'A319-1100',
              L2I_Operator__c = acc.Id,
              L2I_Serial_Number__c = 'abc12289',
              L2I_Aircraft_Delivery_Date__c = DATE.today().addDays(30),
              Aircraft_Type__c = atype.Id,
              L2I_Approved__c = true
        );
        insert ac;
        
        L2I_Aircraft__c ac2 = new L2I_Aircraft__c(
              L2I_Aircraft_Status__c = 'In Service',
              Name = 'Test A/C 2',
              L2I_GPIN__c = 'A319-1100',
              L2I_Operator__c = acc.Id,
              L2I_Serial_Number__c = 'abc12289',
              L2I_Aircraft_Delivery_Date__c = DATE.today().addDays(30),
              Aircraft_Type__c = atype.Id,
              L2I_Approved__c = true
        );
        insert ac2;
        
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(100),
              Aircraft__c = ac2.Id,
              PT_Program__c = prog1.Id
        );
        insert dsl;
    
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Handoff', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.PT_Part_List_Name__c = 'PL Name';
        salesOpp.L2I_Program_Num__c = prog1.Id;
        salesOpp.Proposed_Program_Manager__c = testUser.id;
        salesOpp.Proposed_PMO_Group__c= pmoGroup.id;
        salesOpp.Proposed_PMO_SubGroup__c = pmoSubGroup.id;
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOpp;
    
        SBQQ__Quote__c quote0 = factory.createQuote('draft', acc.Id, salesOpp.Id, false);
        quote0.ApprovalStatus__c = 'Approved';
        insert quote0;
        
        PT_Opportunity_TriggerHandler.recursive = true;
        salesOpp.StageName = 'Delivery';
        salesOpp.SBQQ__PrimaryQuote__c = quote0.id;
        update salesOpp;
        
        salesOpp.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOpp;
        
        SBQQ__Quote__c quote = factory.createQuote('draft', acc.Id, salesOpp.Id, false);
        quote.SBQQ__Source__c = quote0.Id;
        insert quote;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c(
              SBQQ__SolutionGroup__c = sg.Id,
              SBQQ__Quote__c = quote.Id
        );
        insert qlg;
        
        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test Billable Rule', blng__InitialBillingTrigger__c = 'Order Product Activation Date', blng__PartialPeriodTreatment__c = 'Separate', blng__AmendmentBillCycleDateAlignment__c = 'Align to original Order Product', blng__GenerateInvoices__c = 'No', blng__Active__c = True);
        insert billingRule;
        
        blng__RevenueRecognitionRule__c revRec = new blng__RevenueRecognitionRule__c(name = 'Test Revenue Recognition Rule', blng__Active__c = true, blng__CreateRevenueSchedule__c = 'No');
        insert revRec;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(Name = 'Test tax Rule', blng__Active__c = true, blng__TaxableYesNo__c = 'No');
        insert taxRule;
        
        List<Product2> products = new List<Product2>();
        Product2 testProd = factory.createProduct('905647-TEST10', 'Test product', 'IFEC', 'IFE HW', '');
        testProd.blng__BillingRule__c = billingRule.Id;
        testProd.blng__RevenueRecognitionRule__c = revRec.Id;
        testProd.blng__TaxRule__c = taxRule.Id;
        products.add(testProd);
        insert products;
    
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc2.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = prog1.Id,
              Product2Id = testProd.Id,
              AccountId = acc.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;
        
        List<PricebookEntry> entries = new List<PricebookEntry>();
        for (SObject prod : products) {
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
            entries.add(pbe);
        }
        insert entries;
        
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        
        for (Product2 prod : products) {
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(quote.Id, prod.Id, null);
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.SBQQ__Group__c = qlg.Id;
            quoteLine.PT_Asset__c = ast.Id;
            qlList.add(quoteLine);
        }
        insert qlList;

        Test.startTest();
        PT_QuoteDocGeneration.FlowInput fi = new  PT_QuoteDocGeneration.FlowInput();
        List<PT_QuoteDocGeneration.FlowInput> fiList = new  List<PT_QuoteDocGeneration.FlowInput>();
        fi.oppIdToProcess = salesOpp.Id;
        fiList.add(fi);
        System.debug('*** fi ' + fi);
        Boolean gotError = false;
        try {
            // PT_QuoteDocGeneration.genQuoteDoc(fiList); Updated for test code coverage
            PT_QuoteDocGeneration.genDoc(salesOpp.Id);
        } catch (Exception e) {
            System.debug('*** e ' + e.getMessage());
            gotError = true;
        }
        Test.stopTest();
        System.assertEquals(false, gotError);
    }
    
    @isTest
    static void testDocGenPrimary() {
        L2I_DataFactory factory = new L2I_DataFactory();
        
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        System.assert(acc.Id != null, 'Named Customer Account must have an Id');
        
        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');
        
        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Test1234';
        prog1.Program_Number__c = 'Test1234';
        insert prog1;
        
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
        
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = acc.Id,
              Product_Category__c = 'IFEC'
        );
        insert dsh;
        
        L2I_Aircraft_Type__c atype = new L2I_Aircraft_Type__c(
              Name = 'F-18TestThis',
              L2I_PAC_Type_Designator__c = 'ABCD',
              L2I_Model__c = 'GT',
              Manufacturer__c = acc.Id,
              L2I_Aircraft_Type__c = 'MyTest',
              L2I_Is_Active__c = true,
              L2I_Manufacturer_Party_ID__c = 123456,
              L2I_Make__c = 'ABC',
              L2I_Series__c = 'DEF'
        );
        insert atype;

		List<L2I_Aircraft__c> lAircraftToInsert = new List<L2I_Aircraft__c>();        
        L2I_Aircraft__c ac = new L2I_Aircraft__c(
              L2I_Aircraft_Status__c = 'In Service',
              Name = 'Test A/C 1',
              L2I_GPIN__c = 'A319-1100',
              L2I_Operator__c = acc.Id,
              L2I_Serial_Number__c = 'abc12289',
              L2I_Aircraft_Delivery_Date__c = DATE.today().addDays(30),
              Aircraft_Type__c = atype.Id,
              L2I_Approved__c = true
        );
        lAircraftToInsert.add(ac);
        
        L2I_Aircraft__c ac2 = new L2I_Aircraft__c(
              L2I_Aircraft_Status__c = 'In Service',
              Name = 'Test A/C 2',
              L2I_GPIN__c = 'A319-1100',
              L2I_Operator__c = acc.Id,
              L2I_Serial_Number__c = 'abc12289',
              L2I_Aircraft_Delivery_Date__c = DATE.today().addDays(30),
              Aircraft_Type__c = atype.Id,
              L2I_Approved__c = true
        );
        lAircraftToInsert.add(ac2);
        insert lAircraftToInsert;
        
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(100),
              Aircraft__c = ac2.Id,
              PT_Program__c = prog1.Id
        );
        insert dsl;
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
                
        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Handoff', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.PT_Part_List_Name__c = 'PL Name';
        salesOpp.L2I_Program_Num__c = prog1.Id;
        salesOpp.Proposed_Program_Manager__c = testUser.id;
        salesOpp.Proposed_PMO_Group__c= pmoGroup.id;
        salesOpp.Proposed_PMO_SubGroup__c = pmoSubGroup.id;
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOpp;
        salesOpp.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOpp;
    
        SBQQ__Quote__c quote0 = factory.createQuote('approved', acc.Id, salesOpp.Id, true);
        quote0.ApprovalStatus__c = 'Approved';
        insert quote0;
    
        PT_Opportunity_TriggerHandler.recursive = true;
        salesOpp.StageName = 'Delivery';
        salesOpp.SBQQ__PrimaryQuote__c = quote0.Id;
        update salesOpp;
        
        SBQQ__Quote__c quote = factory.createQuote('draft', acc.Id, salesOpp.Id, true);
        quote.SBQQ__Source__c = quote0.Id;
        insert quote;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c(
              SBQQ__SolutionGroup__c = sg.Id,
              SBQQ__Quote__c = quote.Id
        );
        insert qlg;
        
        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test Billable Rule', blng__InitialBillingTrigger__c = 'Order Product Activation Date', blng__PartialPeriodTreatment__c = 'Separate', blng__AmendmentBillCycleDateAlignment__c = 'Align to original Order Product', blng__GenerateInvoices__c = 'No', blng__Active__c = True);
        insert billingRule;
        
        blng__RevenueRecognitionRule__c revRec = new blng__RevenueRecognitionRule__c(name = 'Test Revenue Recognition Rule', blng__Active__c = true, blng__CreateRevenueSchedule__c = 'No');
        insert revRec;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(Name = 'Test tax Rule', blng__Active__c = true, blng__TaxableYesNo__c = 'No');
        insert taxRule;
        
        List<Product2> products = new List<Product2>();
        Product2 testProd = factory.createProduct('905647-TEST10', 'Test product', 'IFEC', 'IFE HW', '');
        testProd.blng__BillingRule__c = billingRule.Id;
        testProd.blng__RevenueRecognitionRule__c = revRec.Id;
        testProd.blng__TaxRule__c = taxRule.Id;
        products.add(testProd);
        insert products;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc2.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = prog1.Id,
              Product2Id = testProd.Id,
              AccountId = acc.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;
        
        Test.startTest();
        
        List<PricebookEntry> entries = new List<PricebookEntry>();
        for (SObject prod : products) {
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
            entries.add(pbe);
        }
        insert entries;
        
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        
        for (Product2 prod : products) {
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(quote.Id, prod.Id, null);
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.SBQQ__Group__c = qlg.Id;
            quoteLine.PT_Asset__c = ast.Id;
            qlList.add(quoteLine);
        }
        insert qlList;
        
        PT_QuoteDocGeneration.FlowInput fi = new  PT_QuoteDocGeneration.FlowInput();
        List<PT_QuoteDocGeneration.FlowInput> fiList = new  List<PT_QuoteDocGeneration.FlowInput>();
        fi.oppIdToProcess = salesOpp.Id;
        fiList.add(fi);
        System.debug('*** fi ' + fi);
        Boolean gotError = false;
        try {
            // PT_QuoteDocGeneration.genQuoteDoc(fiList); Updated for test code coverage
            PT_QuoteDocGeneration.genDoc(salesOpp.Id);
        } catch (Exception e) {
            System.debug('*** e ' + e.getMessage());
            gotError = true;
        }
        Test.stopTest();
        System.assertEquals(false, gotError);
    }
}