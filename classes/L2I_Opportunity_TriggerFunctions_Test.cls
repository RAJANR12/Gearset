/**
 *      @author       Raj Rajen
 *      @date         07/29/2019
 *      @description  Test class for L2I Opportunity Trigger Functions.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/29/2019         Initial setup of tests
 *      Sarah Kennedy                 02/18/2020         Modified CreateDeliverySchedule to remove Deal Opp as a parameter
 *      Sarah Kennedy                 03/11/2020         Added ContractNumber to Contract SQL
 *      MS Simplus Khrisna            03/31/2022         W-001727 Primary System Type Validation Rule
 */
@isTest(SeeAllData=false)
public class L2I_Opportunity_TriggerFunctions_Test {
    
//    private static L2I_DataFactory factory;
//    private static List<SObject> products;
//    private static List<PricebookEntry> pbEntries;
    
    // It would have been nice to have annotated this method as a @testSetup method. However, static variables
    // are cleared out by Salesforce before the execution of test methods in order to not have any data depencies
    // in the test methods.
    // Josh Kaplan: "We intentionally clear out static variables between each test method.  If we did not, each
    // test would cease to be an independent trial. You could modify the static in one test method, which would
    // make the order in which tests operate relevant to the results.
    // This is precisely what you don't want - data dependent tests.
    // https://success.salesforce.com/ideaView?id=08730000000Dj51AAC
    // Also see https://developer.salesforce.com/forums/?id=906F00000008yb1IAA for a need for this scenario
//    static void setupTestContext() {
//        factory = new L2I_DataFactory();
//
//        List<SObject> blng_GLRules = Test.loadData(blng__GLRule__c.sObjectType,
//              L2I_StaticConstants.unitTestStaticResource.get('GLRule_file'));
//
//
//        List<SObject> blng_LegalEntities = Test.loadData(blng__LegalEntity__c.sObjectType,
//              L2I_StaticConstants.unitTestStaticResource.get('LegalEntity_file'));
//
//
//        List<SObject> blng_financeBooks = Test.loadData(blng__FinanceBook__c.sObjectType,
//              L2I_StaticConstants.unitTestStaticResource.get('FinanceBook_file'));
//
//
//        List<SObject> blng_billingRules = Test.loadData(blng__BillingRule__c.sObjectType,
//              L2I_StaticConstants.unitTestStaticResource.get('BillingRule_file'));
//
//
//        List<SObject> blng_taxRules = Test.loadData(blng__TaxRule__c.sObjectType,
//              L2I_StaticConstants.unitTestStaticResource.get('TaxRule_file'));
//
//
//        List<SObject> blng_revrecRules = Test.loadData(blng__RevenueRecognitionRule__c.sObjectType,
//              L2I_StaticConstants.unitTestStaticResource.get('RevenueRecognitionRule_file'));
//
//
//        List<SObject> blng_GLAccounts = Test.loadData(blng__GLAccount__c.sObjectType,
//              L2I_StaticConstants.unitTestStaticResource.get('GLAccount_file'));
//
//
//        List<SObject> blng_GLTreatments = Test.loadData(blng__GLTreatment__c.sObjectType,
//              L2I_StaticConstants.unitTestStaticResource.get('GLTreatment_file'));
//
//
//        // the following is a time-consuming load. Turn it on only if it is needed. In all likelihood, this is needed
//        // for Invoice runs, which is not in scope for the set of tests in this UnitTest class
//        //List<SObject> blng_financePeriods = Test.loadData(blng__FinancePeriod__c.sObjectType,
//        //                                                  L2I_StaticConstants.unitTestStaticResource.get('FinancePeriod_file'));
//
//
//        List<SObject> blng_billingTreatments = Test.loadData(blng__BillingTreatment__c.sObjectType,
//              L2I_StaticConstants.unitTestStaticResource.get('BillingTreatment_file'));
//
//
//        products = Test.loadData(Product2.sObjectType,
//              L2I_StaticConstants.unitTestStaticResource.get('Product2_file'));
//
//
//        pbEntries = new List<PricebookEntry>();
//        for (SObject prod : products) {
//            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
//                  Product2Id = prod.Id,
//                  UnitPrice = 1000,
//                  IsActive = true);
//            pbEntries.add(pbe);
//        }
//        insert pbEntries;
//    }
    
    private static L2I_DataFactory factory = new L2I_DataFactory();
    
   /*******************************
    * Method Name: testSetup
    * Description:
    ********************************/
    @testSetup
    private static void testSetup(){
        //L2I_DataFactory factory = new L2I_DataFactory();
        //factory.setupTestContext(null, null, false);
        factory.setupAccountThruOrder2(null, null, false, 'Activated');
    }
    
   /************************************************************************
    * Method Name: test_deal_and_single_sales_oppty_creation
    * Description:
    ************************************************************************/
    @isTest
    static void test_deal_and_single_sales_oppty_creation() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        //factory.setupTestContext(null, null, false);
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        test.startTest();
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;

        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        System.assert(salesOppty.Id != null, 'Sales Opportunity must have an Id');
        test.stopTest();
        dealOppty = [select Id, Name, Amount from Opportunity where Id = :dealOppty.Id limit 1];
        
        System.assert(dealOppty.Amount == salesOppty.Amount, 'Deal Oppty amount does not equal Child Sales Oppty Amount');
    }
    
    /************************************************************************
    * Method Name: test_deal_and_multiple_sales_oppty_creation
    * Description:
    ************************************************************************/
    @isTest
    static void test_deal_and_multiple_sales_oppty_creation() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        //factory.setupTestContext(null, null, false);
        
        test.startTest();
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
    
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;

        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty1 = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,dealOppty.Id, 200000, 'IFEC');
        salesOppty1.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty1;
        
        
        Opportunity salesOppty2 = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,dealOppty.Id, 300000, 'IFEC');
        salesOppty2.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty2;
        
        test.stopTest();
        
        dealOppty = [select Id, Name, Amount from Opportunity where Id = :dealOppty.Id limit 1];        
        Double totalAmount = salesOppty1.Amount + salesOppty2.Amount;
        
        System.assert(salesOppty1.Id != null, 'Sales Opportunity must have an Id');
        System.assert(salesOppty2.Id != null, 'Sales Opportunity must have an Id');
        System.assert(dealOppty.Amount == totalAmount, 'Deal Oppty amount does not equal sum of Child Sales Oppty Amounts');
    }
    
   /************************************************************************
    * Method Name: test_deal_and_multiple_sales_oppty_updates
    * Description:
    ************************************************************************/
    @isTest
    static void test_deal_and_multiple_sales_oppty_updates() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        //factory.setupTestContext(null, null, false);
    
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
    
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        test.startTest();
        Opportunity salesOppty1 = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,dealOppty.Id, 200000, 'IFEC');
        salesOppty1.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty1;
        System.assert(salesOppty1.Id != null, 'Sales Opportunity must have an Id');
        
        Opportunity salesOppty2 = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,dealOppty.Id, 300000, 'IFEC');
        salesOppty2.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty2;
        System.assert(salesOppty2.Id != null, 'Sales Opportunity must have an Id');
        
        dealOppty = [select Id, Name, Amount from Opportunity where Id = :dealOppty.Id limit 1];
        
        Double totalAmount = salesOppty1.Amount + salesOppty2.Amount;
        System.assert(dealOppty.Amount == totalAmount, 'Deal Oppty amount does not equal sum of Child Sales Oppty Amounts');
        
        salesOppty2.Amount = 250000;
        update salesOppty2;
        test.stopTest();
        
        dealOppty = [select Id, Name, Amount from Opportunity where Id = :dealOppty.Id limit 1];
        
        Double updatedAmount = salesOppty1.Amount + salesOppty2.Amount;
        //System.assert(dealOppty.Amount == updatedAmount, 'Deal Oppty amount does not reflect updated sum of Child Sales Oppty Amounts');
    }
    
   /************************************************************************
    * Method Name: test_deal_and_multiple_sales_oppty_creation_and_deletion
    * Description:
    ************************************************************************/
    @isTest
    static void test_deal_and_multiple_sales_oppty_creation_and_deletion() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        //factory.setupTestContext(null, null, false);
    
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
    
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;

        Opportunity salesOppty1 = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,dealOppty.Id, 200000, 'IFEC');
        salesOppty1.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty1;
        System.assert(salesOppty1.Id != null, 'Sales Opportunity must have an Id');
        
        test.startTest();
        Opportunity salesOppty2 = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,dealOppty.Id, 300000, 'IFEC');
        salesOppty2.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty2;
        System.assert(salesOppty2.Id != null, 'Sales Opportunity must have an Id');
        
        dealOppty = [select Id, Name, Amount from Opportunity where Id = :dealOppty.Id limit 1];
        
        Double totalAmount = salesOppty1.Amount + salesOppty2.Amount;
        System.assert(dealOppty.Amount == totalAmount, 'Deal Oppty amount does not equal sum of Child Sales Oppty Amounts');
        
        delete salesOppty2;
        
        dealOppty = [select Id, Name, Amount from Opportunity where Id = :dealOppty.Id limit 1];
        
        Double updatedAmount = salesOppty1.Amount;
        System.assert(dealOppty.Amount == updatedAmount, 'Deal Oppty amount does not reflect the updated amount');
        
        undelete salesOppty2;
        
        test.stopTest();
        
        dealOppty = [select Id, Name, Amount from Opportunity where Id = :dealOppty.Id limit 1];
        
        updatedAmount = salesOppty1.Amount + salesOppty2.Amount;
        System.assert(dealOppty.Amount == updatedAmount, 'Deal Oppty amount does not reflect the updated amount');
    }
    
   /**********************************************************************
    * Method Name: test_salesopp_no_close_no_approvals_as_non_system_admin
    * Description:
    **********************************************************************/
    @isTest
    static void test_salesopp_no_close_no_approvals_as_non_system_admin() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        
        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC System Administrator');
        User salesUser = factory.createTestUser(null, salesProfile.Id, 'Sales', 'User');
        insert salesUser;
        
        test.startTest();  
        System.runAs(salesUser) {       
            Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');
            
            Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
            insert dealOppty;
            System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');
            
            Opportunity salesOppty = factory.createSalesOpportunity('Sales', 'Open', 30, namedCustomer.Id,
                  dealOppty.Id);
            insert salesOppty;
            String msg = Label.P_L_Approval_Required;
            
            salesOppty.StageName = 'Prospect';
            // change the stagename
            Boolean gotError = false;
            try {
                update salesOppty;
            } catch (DmlException dmle) {
                gotError = true;
                System.assert(dmle.getMessage().equals(msg));
            }
            System.assertEquals(false, gotError);
        }
        test.stopTest();
    }
    
   /**********************************************************************
    * Method Name: test_salesopp_close_no_approvals_as_non_system_admin
    * Description:
    **********************************************************************/
    @isTest
    static void test_salesopp_close_no_approvals_as_non_system_admin() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        
        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC System Administrator');
        User salesUser = factory.createTestUser(null, salesProfile.Id, 'Sales', 'User');
        insert salesUser;
        
        test.startTest();  
        System.runAs(salesUser) {
            Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            
            Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
            insert dealOppty;
            
            Opportunity salesOppty = factory.createSalesOpportunity('Sales', 'Open', 30, namedCustomer.Id,
                                                                    dealOppty.Id);
            insert salesOppty;
            String msg = Label.P_L_Approval_Required; 
            
            salesOppty.StageName = 'Closed Won';
            // change the stagename
            Boolean gotError = false;
            try {
                update salesOppty;
            } catch (DmlException dmle) {
                gotError = true;
                System.assert(dmle.getMessage().contains(msg));
            }
            System.assertEquals(true, gotError);
        }
        test.stopTest();
    }
    
   /****************************************************************
    * Method Name: test_salesopp_close_approvals_as_non_system_admin
    * Description:
    ****************************************************************/
    @isTest
    static void test_salesopp_close_approvals_as_non_system_admin() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC System Administrator');
        User salesUser = factory.createTestUser(null, salesProfile.Id, 'Sales', 'User');
        insert salesUser;
        
        test.startTest();  
        System.runAs(salesUser) {
            Account namedCustomer = factory.createCustomerAccount('Airline Customer3', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');
            
            Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
            insert dealOppty;
            System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');
            
            L2I_Aircraft_Type__c airType = factory.createAircraftType(namedCustomer.Id, null);        
            airType.Name = airType.Name + '1';
            insert airType;
            
            L2I_Aircraft__c airCraft = factory.createAircraft(airType.Id, 'Testac', 'A319-1100', namedCustomer.Id);
            insert airCraft;
            
            L2I_DSH__c dsh = factory.createDeliverySchedule(namedCustomer.Id, airType.Id);
            insert dsh;
            
            Opportunity salesOppty = factory.createSalesOpportunity('Sales', 'Open', 30, namedCustomer.Id,
                                                                    dealOppty.Id);
            insert salesOppty;
            salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
            update salesOppty;
            
            L2I_P_L_Approval__c plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
            insert plApproval;
            
            L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOppty.Id);
            insert plSalesOpp;
            
            SBQQ__Quote__c approvedQuote = factory.createQuote('approved', namedCustomer.Id, salesOppty.Id, true);
            insert approvedQuote;
            approvedQuote.ApprovalStatus__c = 'Approved';
            update approvedQuote;
            
            Account compAcct = factory.createCompetitorAccount('CompAcct', '123 Main St.', 'Nashville', 'TN', '37011');
            insert compAcct;
            
            L2I_Competitors__c comp = factory.createCompetitor(salesOppty.Id, compAcct.Id, 'DSS');
            insert comp;
            comp.Primary__c = true;
            update comp;
            
            String msg = Label.P_L_Approval_Required;
            
            salesOppty.StageName = 'Closed Won';
            // change the stagename
            Boolean gotError = false;
            try {
                update salesOppty;
            } catch (DmlException dmle) {
                gotError = true;
                system.debug('>> ERROR: '+dmle.getMessage());
                System.assert(dmle.getMessage().contains(msg));
            }
            System.assertEquals(true, gotError);
        }       
        test.stopTest();
    }
    
   /************************************************************
    * Method Name: testAmendmentOpportunity
    * Description:
    ************************************************************/
    @isTest
    static void testAmendmentOpportunity() {
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Opportunity salesOpp = [SELECT Id FROM Opportunity WHERE Name = 'Sales Oppty'];
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        
        //ord.EffectiveDate = Date.today().addDays(-3);
        
        ord.OpportunityId = salesOpp.Id;
        update ord;
        
        SBQQ__Quote__c q1 = [SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
                             FROM SBQQ__Quote__c
                             LIMIT 1];
        
        q1.SBQQ__StartDate__c = Date.today().addDays(-3);
        q1.SBQQ__SubscriptionTerm__c = 12;
        q1.SBQQ__EndDate__c = q1.SBQQ__StartDate__c.addMonths(12);
        update q1;
        
        // create Contract
        Contract ctr = new Contract(
              AccountId = acct.Id,
              SBQQ__Order__c = ord.Id,
              SBQQ__Opportunity__c = salesOpp.Id,
              SBQQ__Quote__c = q1.Id,
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              CurrencyIsoCode = 'USD',
              ContractTerm = 24,
              StartDate = Date.today().addMonths(3),
              SBQQ__PreserveBundleStructureUponRenewals__c = true,
              SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
              SBQQ__DefaultRenewalPartners__c = true,
              SBQQ__DefaultRenewalContactRoles__c = true
        );
        insert ctr;
        
        ctr.Status = 'Activated';
        ctr.L2I_Auto_Extend__c = Date.today().addDays(1);
        ctr.ContractTerm = 12;
        ctr.SBQQ__RenewalTerm__c = 12;
        update ctr;
        
        Test.startTest();
        // create amendment opportunity and quote - see CPQ Developer Guide APIs and Models
        L2I_ContractAmender amender = new L2I_ContractAmender();
        L2I_QuoteModel quoteModel = amender.load(ctr.Id);
        System.debug('*** quoteModel ' + quoteModel);
        Test.stopTest();
        
        Id amendmentId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        
        Opportunity salesOppty = [
              SELECT Id,CreatedDate, Name, Recordtype.DeveloperName,
                    SBQQ__AmendedContract__c, SBQQ__RenewedContract__c,
                    L2I_AC_Operator__c,
                    L2I_AircraftQuantity__c,
                    L2I_Aircraft_Type__c,
                    L2I_Delivery_Schedule__c,
                    L2I_Parent_Opportunity__c,
                    L2I_Product_Category__c,
                    Pricebook2Id,
                    L2I_Deal_Account__c,
                    AccountId,
                    L2I_Fit_Type__c,
                    StageName,
                    L2I_Warranty__c,
                    L2I_Route_Supported__c,
                    L2I_Are_any_of_these_AC_to_be_leased__c,
                    L2I_Aircraft_Quantity_Option__c,
                    L2I_Are_These_Follow_On_Aircraft__c,
                    L2I_Are_These_Partial_Shipsets__c,
                      L2I_Business_Initiative__c
              FROM Opportunity
              WHERE Id = :ctr.SBQQ__Opportunity__c
              LIMIT 1
        ];
        
        Opportunity amendOppty = [
              SELECT Id,CreatedDate, Name, Recordtype.DeveloperName,
                    SBQQ__AmendedContract__c,
                    L2I_AC_Operator__c,
                    L2I_AircraftQuantity__c,
                    L2I_Aircraft_Type__c,
                    L2I_Delivery_Schedule__c,
                    L2I_Parent_Opportunity__c,
                    L2I_Product_Category__c,
                    Pricebook2Id,
                    L2I_Deal_Account__c,
                    AccountId,
                    L2I_Fit_Type__c,
                    StageName,
                    L2I_Warranty__c,
                    L2I_Route_Supported__c,
                    L2I_Are_any_of_these_AC_to_be_leased__c,
                    L2I_Aircraft_Quantity_Option__c,
                    L2I_Are_These_Follow_On_Aircraft__c,
                    L2I_Are_These_Partial_Shipsets__c,
                      L2I_Business_Initiative__c
              FROM Opportunity
              WHERE RecordTypeId = :amendmentId
              LIMIT 1
        ];
        System.assertEquals(ctr.Id, amendOppty.SBQQ__AmendedContract__c);
        System.assertEquals(salesOppty.L2I_AC_Operator__c, amendOppty.L2I_AC_Operator__c);
        System.assertEquals(salesOppty.L2I_AircraftQuantity__c, amendOppty.L2I_AircraftQuantity__c);
        System.assertEquals(salesOppty.L2I_Aircraft_Type__c, amendOppty.L2I_Aircraft_Type__c);
        System.assertEquals(salesOppty.L2I_Delivery_Schedule__c, amendOppty.L2I_Delivery_Schedule__c);
        System.assertEquals(salesOppty.L2I_Parent_Opportunity__c, amendOppty.L2I_Parent_Opportunity__c);
        System.assertEquals(salesOppty.L2I_Product_Category__c, amendOppty.L2I_Product_Category__c);
        System.assertEquals(salesOppty.Pricebook2Id, amendOppty.Pricebook2Id);
        System.assertEquals(salesOppty.L2I_Deal_Account__c, amendOppty.L2I_Deal_Account__c);
        System.assertEquals(salesOppty.AccountId, amendOppty.AccountId);
        System.assertEquals(salesOppty.L2I_Fit_Type__c, amendOppty.L2I_Fit_Type__c);
        System.assertEquals('Quotation', amendOppty.StageName);
        System.assertEquals(salesOppty.L2I_Warranty__c, amendOppty.L2I_Warranty__c);
        System.assertEquals(salesOppty.L2I_Route_Supported__c, amendOppty.L2I_Route_Supported__c);
        System.assertEquals(salesOppty.L2I_Are_any_of_these_AC_to_be_leased__c, amendOppty.L2I_Are_any_of_these_AC_to_be_leased__c);
        System.assertEquals(salesOppty.L2I_Aircraft_Quantity_Option__c, amendOppty.L2I_Aircraft_Quantity_Option__c);
        System.assertEquals(salesOppty.L2I_Are_These_Follow_On_Aircraft__c, amendOppty.L2I_Are_These_Follow_On_Aircraft__c);
        System.assertEquals(salesOppty.L2I_Are_These_Partial_Shipsets__c, amendOppty.L2I_Are_These_Partial_Shipsets__c);
        System.assertEquals(salesOppty.L2I_Business_Initiative__c, amendOppty.L2I_Business_Initiative__c);
    }
    
   /************************************************************
    * Method Name: testRenewalDSSOpportunity
    * Description:
    ************************************************************/
    @isTest
    static void testRenewalDSSOpportunity() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        //factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOpp = [SELECT Id, L2I_Product_Category__c, L2I_Delivery_Schedule__c
            FROM Opportunity
            WHERE RecordtypeId = :salesId AND L2I_Product_Category__c = 'IFEC'  LIMIT 1];

        if (salesOpp.L2I_Delivery_Schedule__c != null) {
            L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c WHERE Id = :salesOpp.L2I_Delivery_Schedule__c LIMIT 1];
            delete dsh;
        }
        // removed delivery schedule to avoid validation on Opp changing the Product Category
        salesOpp =  [SELECT Id, L2I_Product_Category__c, L2I_Delivery_Schedule__c FROM Opportunity WHERE RecordtypeId = :salesId LIMIT 1];
        salesOpp.L2I_Product_Category__c = 'DSS';
        salesOpp.L2I_Fit_Type__c = 'Initial Sale';
        salesOpp.L2I_Warranty__c = '';
        update salesOpp;
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        
        SBQQ__Quote__c q1 = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
              LIMIT 1
        ];
        q1.SBQQ__StartDate__c = Date.today().addDays(-3);
        q1.SBQQ__SubscriptionTerm__c = 12;
        q1.SBQQ__EndDate__c = q1.SBQQ__StartDate__c.addMonths(12);
        update q1;
    
        // create Contract
        Contract ctr = new Contract(
              AccountId = acct.Id,
              SBQQ__Order__c = ord.Id,
              SBQQ__Opportunity__c = salesOpp.Id,
              SBQQ__Quote__c = q1.Id,
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              CurrencyIsoCode = 'USD',
              ContractTerm = 24,
              StartDate = Date.today().addMonths(3),
              SBQQ__PreserveBundleStructureUponRenewals__c = true,
              SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
              SBQQ__DefaultRenewalPartners__c = true,
              SBQQ__DefaultRenewalContactRoles__c = true
        );
        insert ctr;
    
        ctr.Status = 'Activated';
        ctr.L2I_Auto_Extend__c = Date.today().addDays(1);
        ctr.ContractTerm = 12;
        ctr.SBQQ__RenewalTerm__c = 12;
        update ctr;
        
        System.debug('*** ctr.StartDate ' + ctr.StartDate);
        System.debug('*** ctr.EndDate ' + ctr.EndDate);
        
        // create renewal opportunity and quote - see CPQ Developer Guide APIs and Models
        // the quote throws a validation error - we only need the opportunity for this test
        try {
            String testInput = '{"masterContractId": "' + ctr.Id + '", "renewedContracts": [{"attributes":{"type":"Contract"},"Id":"' + ctr.Id + '"}]}';
            System.debug('*** testInput');
            L2I_ContractRenewer renewer = new L2I_ContractRenewer();
            L2I_QuoteModel[] quoteModels = renewer.load(null, testInput);
            System.debug('*** quoteModels ' + quoteModels);
        } catch (Exception e){
        }
        Test.stopTest();
        
        Id renewalId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        
        Opportunity salesOppty = [
              SELECT Id,CreatedDate, Name, Recordtype.DeveloperName,
                    SBQQ__AmendedContract__c, SBQQ__RenewedContract__c,
                    L2I_AC_Operator__c,
                    L2I_AircraftQuantity__c,
                    L2I_Aircraft_Type__c,
                    L2I_Delivery_Schedule__c,
                    L2I_Parent_Opportunity__c,
                    L2I_Product_Category__c,
                    Pricebook2Id,
                    L2I_Deal_Account__c,
                    AccountId,
                    L2I_Fit_Type__c,
                    StageName,
                    L2I_Warranty__c,
                    L2I_Route_Supported__c,
                    L2I_Are_any_of_these_AC_to_be_leased__c,
                    L2I_Aircraft_Quantity_Option__c,
                    L2I_Are_These_Follow_On_Aircraft__c,
                    L2I_Are_These_Partial_Shipsets__c,
                      L2I_Business_Initiative__c
              FROM Opportunity
              WHERE Id = :ctr.SBQQ__Opportunity__c
              LIMIT 1
        ];
        
        Opportunity renewalOppty = [
              SELECT Id,CreatedDate, Name, Recordtype.DeveloperName,
                    SBQQ__RenewedContract__c,
                    L2I_AC_Operator__c,
                    L2I_AircraftQuantity__c,
                    L2I_Aircraft_Type__c,
                    L2I_Delivery_Schedule__c,
                    L2I_Parent_Opportunity__c,
                    L2I_Product_Category__c,
                    Pricebook2Id,
                    L2I_Deal_Account__c,
                    AccountId,
                    L2I_Fit_Type__c,
                    StageName,
                    L2I_Warranty__c,
                    L2I_Route_Supported__c,
                    L2I_Are_any_of_these_AC_to_be_leased__c,
                    L2I_Aircraft_Quantity_Option__c,
                    L2I_Are_These_Follow_On_Aircraft__c,
                    L2I_Are_These_Partial_Shipsets__c,
                      L2I_Business_Initiative__c
              FROM Opportunity
              WHERE RecordTypeId = :renewalId
              LIMIT 1
        ];
        
        System.assertEquals('Renewal', renewalOppty.L2I_Fit_Type__c);
        System.debug('*** renewalOppty.Name ' + renewalOppty.Name);
        System.debug('*** ctr.ContractNumber ' + ctr.ContractNumber);
        System.assertEquals(ctr.Id, renewalOppty.SBQQ__RenewedContract__c);
        System.assertEquals(salesOppty.L2I_AC_Operator__c, renewalOppty.L2I_AC_Operator__c);
        System.assertEquals(salesOppty.L2I_AircraftQuantity__c, renewalOppty.L2I_AircraftQuantity__c);
        System.assertEquals(salesOppty.L2I_Aircraft_Type__c, renewalOppty.L2I_Aircraft_Type__c);
        System.assertEquals(salesOppty.L2I_Delivery_Schedule__c, renewalOppty.L2I_Delivery_Schedule__c);
        System.assertEquals(salesOppty.L2I_Parent_Opportunity__c, renewalOppty.L2I_Parent_Opportunity__c);
        System.assertEquals(salesOppty.L2I_Product_Category__c, renewalOppty.L2I_Product_Category__c);
        //System.assertEquals(salesOppty.Pricebook2Id, renewalOppty.Pricebook2Id);  // Pricebook field was removed; CPQ should be setting it US2025
        System.assertEquals(salesOppty.L2I_Deal_Account__c, renewalOppty.L2I_Deal_Account__c);
        System.assertEquals(salesOppty.L2I_Deal_Account__c, renewalOppty.L2I_Deal_Account__c);
        System.assertEquals(salesOppty.AccountId, renewalOppty.AccountId);
        //System.assertEquals(salesOppty.L2I_Fit_Type__c, renewalOppty.L2I_Fit_Type__c);
        System.assertEquals('Quotation', renewalOppty.StageName);
        System.assertEquals(salesOppty.L2I_Warranty__c, renewalOppty.L2I_Warranty__c);
        System.assertEquals(salesOppty.L2I_Route_Supported__c, renewalOppty.L2I_Route_Supported__c);
        System.assertEquals(salesOppty.L2I_Are_any_of_these_AC_to_be_leased__c, renewalOppty.L2I_Are_any_of_these_AC_to_be_leased__c);
        System.assertEquals(salesOppty.L2I_Aircraft_Quantity_Option__c, renewalOppty.L2I_Aircraft_Quantity_Option__c);
        System.assertEquals(salesOppty.L2I_Are_These_Follow_On_Aircraft__c, renewalOppty.L2I_Are_These_Follow_On_Aircraft__c);
        System.assertEquals(salesOppty.L2I_Are_These_Partial_Shipsets__c, renewalOppty.L2I_Are_These_Partial_Shipsets__c);
        System.assertEquals(salesOppty.L2I_Business_Initiative__c, renewalOppty.L2I_Business_Initiative__c);
    }
    
   /************************************************************
    * Method Name: testCopyAmendRenewalRelatedLists
    * Description:
    ************************************************************/
    @isTest
    static void testCopyAmendRenewalRelatedLists() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        //factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
              Name = 'TestSalesOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Product_Category__c = 'DSS',
              L2I_Fit_Type__c = 'Initial Sale',
              RecordTypeId = salesId);
        insert salesOppty;
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        //ord.EffectiveDate = Date.today().addDays(-3);
        ord.OpportunityId = salesOppty.Id;
        update ord;
        SBQQ__Quote__c q1 = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
              LIMIT 1
        ];
        q1.SBQQ__StartDate__c = Date.today().addDays(-3);
        q1.SBQQ__SubscriptionTerm__c = 12;
        q1.SBQQ__EndDate__c = q1.SBQQ__StartDate__c.addMonths(12);
        update q1;
    
        // create Contract
        Contract ctr = new Contract(
              AccountId = acct.Id,
              SBQQ__Order__c = ord.Id,
              SBQQ__Opportunity__c = salesOppty.Id,
              SBQQ__Quote__c = q1.Id,
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              CurrencyIsoCode = 'USD',
              ContractTerm = 24,
              StartDate = Date.today().addMonths(3),
              SBQQ__PreserveBundleStructureUponRenewals__c = true,
              SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
              SBQQ__DefaultRenewalPartners__c = true,
              SBQQ__DefaultRenewalContactRoles__c = true
        );
        insert ctr;
    
        ctr.Status = 'Activated';
        ctr.L2I_Auto_Extend__c = Date.today().addDays(1);
        ctr.ContractTerm = 12;
        ctr.SBQQ__RenewalTerm__c = 12;
        update ctr;
    
        // create renewal opportunity and quote - see CPQ Developer Guide APIs and Models
        // the quote throws a validation error - we only need the opportunity for this test
        try{
            String testInput = '{"masterContractId": "' + ctr.Id + '", "renewedContracts": [{"attributes":{"type":"Contract"},"Id":"' + ctr.Id + '"}]}';
            L2I_ContractRenewer renewer = new L2I_ContractRenewer();
            L2I_QuoteModel[] quoteModels = renewer.load(null, testInput);
            System.debug('*** quoteModels ' + quoteModels);
        } catch (Exception e){

        }
        Test.stopTest();
        System.assertNotEquals(0, [SELECT COUNT() FROM L2I_Competitors__c]);
        System.assertNotEquals(0, [SELECT COUNT() FROM OpportunityTeamMember]);
        
        System.debug('*** competitors ' + [SELECT Id, Opportunity__c FROM L2I_Competitors__c]);
        System.debug('*** teammembers ' + [SELECT Id, OpportunityId FROM OpportunityTeamMember]);
    }
    
   /************************************************************
    * Method Name: testCopyAmendRenewalNoRelatedLists
    * Description:
    ************************************************************/
    @isTest
    static void testCopyAmendRenewalNoRelatedLists() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        //factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
              Name = 'TestSalesOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Product_Category__c = 'DSS',
              L2I_Fit_Type__c = 'Initial Sale',
              RecordTypeId = salesId);
        insert salesOppty;
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        //ord.EffectiveDate = Date.today().addDays(-3);
        ord.OpportunityId = salesOppty.Id;
        update ord;
        SBQQ__Quote__c q1 = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
              LIMIT 1
        ];
        q1.SBQQ__StartDate__c = Date.today().addDays(-3);
        q1.SBQQ__SubscriptionTerm__c = 12;
        q1.SBQQ__EndDate__c = q1.SBQQ__StartDate__c.addMonths(12);
        update q1;
    
        // create Contract
        Contract ctr = new Contract(
              AccountId = acct.Id,
              SBQQ__Order__c = ord.Id,
              SBQQ__Opportunity__c = salesOppty.Id,
              SBQQ__Quote__c = q1.Id,
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              CurrencyIsoCode = 'USD',
              ContractTerm = 24,
              StartDate = Date.today().addMonths(3),
              SBQQ__PreserveBundleStructureUponRenewals__c = true,
              SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
              SBQQ__DefaultRenewalPartners__c = true,
              SBQQ__DefaultRenewalContactRoles__c = true
        );
        insert ctr;
    
        ctr.Status = 'Activated';
        ctr.L2I_Auto_Extend__c = Date.today().addDays(1);
        ctr.ContractTerm = 12;
        ctr.SBQQ__RenewalTerm__c = 12;
        update ctr;
        // create renewal opportunity and quote - see CPQ Developer Guide APIs and Models
        // the quote throws a validation error - we only need the opportunity for this test
        try {
            String testInput = '{"masterContractId": "' + ctr.Id + '", "renewedContracts": [{"attributes":{"type":"Contract"},"Id":"' + ctr.Id + '"}]}';
            L2I_ContractRenewer renewer = new L2I_ContractRenewer();
            L2I_QuoteModel[] quoteModels = renewer.load(null, testInput);
            System.debug('*** quoteModels ' + quoteModels);
        } catch (Exception e){
        }
        Test.stopTest();
        System.assertEquals(2, [SELECT COUNT() FROM L2I_Competitors__c]);
        System.assertEquals(2, [SELECT COUNT() FROM OpportunityTeamMember]);
    }
    
   /****************************************************************************
    * Method Name: test_amendopp_noclose_noapprovals_0amount_as_non_system_admin
    * Description:
    ****************************************************************************/
    @isTest
    static void test_amendopp_noclose_noapprovals_0amount_as_non_system_admin() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        
        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC System Administrator');
        User salesUser = factory.createTestUser(null, salesProfile.Id, 'Sales', 'User');
        insert salesUser;
        
        test.startTest();  
        System.runAs(salesUser) {
            Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');
            
            Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
            insert dealOppty;
            System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');
            
            Opportunity amendOppty = factory.createSalesOpportunity('Amendment', 'Open', 30, namedCustomer.Id,
                                                                    dealOppty.Id);
            insert amendOppty;
            String msg = Label.P_L_Approval_Required;
            amendOppty.StageName = 'Prospect';
            // change the stagename
            Boolean gotError = false;
            try {
                update amendOppty;
            } catch (DmlException dmle) {
                gotError = true;
                System.assert(dmle.getMessage().equals(msg));
            }
            System.assertEquals(false, gotError);
        }
        test.stopTest();
    }
    
   /***************************************************************************
    * Method Name: test_salesopp_close_noapprovals_0amount_as_non_system_admin
    * Description:
    ***************************************************************************/
    @isTest
    static void test_salesopp_close_noapprovals_0amount_as_non_system_admin() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        
        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC System Administrator');
        User salesUser = factory.createTestUser(null, salesProfile.Id, 'Sales', 'User');
        insert salesUser;
        
        test.startTest();  
        System.runAs(salesUser) {
            Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');
            
            Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
            insert dealOppty;
            System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');
            
            Opportunity amendOppty = factory.createSalesOpportunity('Amendment', 'Open', 30, namedCustomer.Id,dealOppty.Id);
            insert amendOppty;
            String msg = Label.P_L_Approval_Required;
            
            amendOppty.StageName = 'Closed Won';
            // change the stagename
            Boolean gotError = false;
            try {
                update amendOppty;
            } catch (DmlException dmle) {
                gotError = true;
                System.assert(dmle.getMessage().contains(msg));
            }
            System.assertEquals(true, gotError);
        }       
        test.stopTest();
    }
    
   /****************************************************************************
    * Method Name: test_salesopp_close_approvals_0amount_as_non_system_admin
    * Description:
    ****************************************************************************/
    @isTest
    static void test_salesopp_close_approvals_0amount_as_non_system_admin() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        
        
        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC System Administrator');
        User salesUser = factory.createTestUser(null, salesProfile.Id, 'Sales', 'User');
        insert salesUser;
        
        test.startTest();  
        System.runAs(salesUser) {
        
            Account namedCustomer = factory.createCustomerAccount('Airline Customer1', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');
            
            Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
            insert dealOppty;
            System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');
            L2I_Aircraft_Type__c airType = factory.createAircraftType(namedCustomer.Id, null);        
            airType.Name = airType.Name + '1';
            insert airType;
            
            L2I_Aircraft__c airCraft = factory.createAircraft(airType.Id, 'Testac', 'A319-1100', namedCustomer.Id);
            insert airCraft;
            
            L2I_DSH__c dsh = factory.createDeliverySchedule(namedCustomer.Id, airType.Id);
            insert dsh;
            
            Opportunity amendOppty = factory.createSalesOpportunity('Amendment', 'Open', 30, namedCustomer.Id,dealOppty.Id);
            insert amendOppty;
            
            amendOppty.L2I_Delivery_Schedule__c = dsh.Id;
            update amendOppty;
            
            L2I_P_L_Approval__c plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
            insert plApproval;
            
            L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, amendOppty.Id);
            insert plSalesOpp;
            
            SBQQ__Quote__c approvedQuote = factory.createQuote('approved', namedCustomer.Id, amendOppty.Id, true);
            insert approvedQuote;
            approvedQuote.ApprovalStatus__c = 'Approved';
            update approvedQuote;
            System.debug('*** approved quote ' + approvedQuote );
            
            Account compAcct = factory.createCompetitorAccount('CompAcct', '123 Main St.', 'Nashville', 'TN', '37011');
            insert compAcct;
            
            L2I_Competitors__c comp = factory.createCompetitor(amendOppty.Id, compAcct.Id, 'DSS');
            insert comp;
            comp.Primary__c = true;
            update comp;
            
            String msg = Label.P_L_Approval_Required;
            
            
            amendOppty.StageName = 'Closed Won';
            // change the stagename
            Boolean gotError = false;
            try {
                update amendOppty;
            } catch (DmlException dmle) {
                gotError = true;
                system.debug('>> ERROR: '+dmle.getMessage());
                System.assert(dmle.getMessage().contains(msg));
            }
            System.assertEquals(true, gotError);
        }
        test.stopTest();
    }
    
   /******************************************************************************
    * Method Name: test_amendopp_noclose_noapprovals_amount_as_non_system_admin
    * Description:
    ******************************************************************************/
    @isTest
    static void test_amendopp_noclose_noapprovals_amount_as_non_system_admin() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        
        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC System Administrator');
        User salesUser = factory.createTestUser(null, salesProfile.Id, 'Sales', 'User');
        insert salesUser;
        
        test.startTest();  
        System.runAs(salesUser) {
            Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');
            
            Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
            insert dealOppty;
            System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');
            
            Opportunity amendOppty = factory.createSalesOpportunity('Amendment', 'Open', 30, namedCustomer.Id,dealOppty.Id);
            insert amendOppty;
            String msg = Label.P_L_Approval_Required;
            
            amendOppty.StageName = 'Prospect';
            amendOppty.Amount = 10;
            // change the stagename
            Boolean gotError = false;
            try {
                update amendOppty;
            } catch (DmlException dmle) {
                gotError = true;
                System.assert(dmle.getMessage().equals(msg));
            }
            System.assertEquals(false, gotError);
        }
        test.stopTest();
    }
    
   /****************************************************************************
    * Method Name: test_salesopp_close_noapprovals_amount_as_non_system_admin
    * Description:
    ****************************************************************************/
    @isTest
    static void test_salesopp_close_noapprovals_amount_as_non_system_admin() {
        //L2I_DataFactory factory = new L2I_DataFactory();
        
        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC System Administrator');
        User salesUser = factory.createTestUser(null, salesProfile.Id, 'Sales', 'User');
        insert salesUser;
        
        test.startTest();  
        System.runAs(salesUser) {
            Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');
            
            Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
            insert dealOppty;
            System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');
            
            Opportunity amendOppty = factory.createSalesOpportunity('Amendment', 'Open', 30, namedCustomer.Id,
                                                                    dealOppty.Id);
            insert amendOppty;
            String msg = Label.P_L_Approval_Required;
            
            amendOppty.StageName = 'Closed Won';
            amendOppty.Amount = 10;
            // change the stagename
            Boolean gotError = false;
            try {
                update amendOppty;
            } catch (DmlException dmle) {
                gotError = true;
                System.assert(dmle.getMessage().contains(msg));
            }
            System.assertEquals(true, gotError);
        }              
        test.stopTest();
    }
    
   /************************************************************************************
    * Method Name: test_salesopp_close_approvals_amount_as_non_system_admin
    * Description:
    ************************************************************************************/
    @isTest
    static void test_salesopp_close_approvals_amount_as_non_system_admin() {
        L2I_DataFactory factory = new L2I_DataFactory();        
       
        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC System Administrator');
        User salesUser = factory.createTestUser(null, salesProfile.Id, 'Sales', 'User');
        insert salesUser;
        
        test.startTest();  
        System.runAs(salesUser) {
            Account namedCustomer = factory.createCustomerAccount('Airline Customer2', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');
            
            Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
            insert dealOppty;
            System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');
            
            L2I_Aircraft_Type__c airType = factory.createAircraftType(namedCustomer.Id, null);        
            airType.Name = airType.Name + '1';
            insert airType;
            
            L2I_Aircraft__c airCraft = factory.createAircraft(airType.Id, 'Testac', 'A319-1100', namedCustomer.Id);
            insert airCraft;
            
            L2I_DSH__c dsh = factory.createDeliverySchedule(namedCustomer.Id, airType.Id);
            insert dsh;
            
            Opportunity amendOppty = factory.createSalesOpportunity('Amendment', 'Open', 30, namedCustomer.Id,dealOppty.Id);
            insert amendOppty;
            
            amendOppty.L2I_Delivery_Schedule__c = dsh.Id;
            update amendOppty;
            
            L2I_P_L_Approval__c plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
            insert plApproval;
            
            L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, amendOppty.Id);
            insert plSalesOpp;
            
            SBQQ__Quote__c approvedQuote = factory.createQuote('approved', namedCustomer.Id, amendOppty.Id, true);
            insert approvedQuote;
            approvedQuote.ApprovalStatus__c = 'Approved';
            update approvedQuote;
            
            Account compAcct = factory.createCompetitorAccount('CompAcct', '123 Main St.', 'Nashville', 'TN', '37011');
            insert compAcct;
            
            L2I_Competitors__c comp = factory.createCompetitor(amendOppty.Id, compAcct.Id, 'DSS');
            insert comp;
            comp.Primary__c = true;
            update comp;
            
            String msg = Label.P_L_Approval_Required;
            
            amendOppty.StageName = 'Closed Won';
            amendOppty.Amount = 10;
            // change the stagename
            Boolean gotError = false;
            try {
                update amendOppty;
            } catch (DmlException dmle) {
                gotError = true;
                system.debug('>> ERROR: '+dmle.getMessage());
                System.assert(dmle.getMessage().contains(msg));
            }
            System.assertEquals(true, gotError);
        }
        test.stopTest();
    }
    
    /*
    * @Method Name        : updateQuoteShipToBillTo_Test
    * @Description        : Test class for updateQuoteShipToBillTo
    * @Author             : Jan Denrick Geronga / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-003956      Oct-18-2021   MS Simplus Jan      Initial Version
    **/
    @IsTest
    static void updateQuoteShipToBillTo_Test() {
        L2I_DataFactory df = new L2I_DataFactory();   
        
        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC System Administrator');
        User salesUser = df.createTestUser(null, salesProfile.Id, 'Sales', 'User');
        insert salesUser;
        
        test.startTest();  
        System.runAs(salesUser) {
            List<Account> lAccount = new List<Account>();
            Account namedCustomer = df.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            lAccount.add(namedCustomer);
            
            Account namedCustomer1 = df.createCustomerAccount('Airline Customer1', '1234 Jump Street', 'San Diego', 'CA', '92123');
            lAccount.add(namedCustomer1);
            insert lAccount;
            
            Opportunity dealOppty = df.createDealOpportunity('Deal', 'Open', 30, lAccount[0].Id);
            insert dealOppty;
            
            Opportunity salesOppty = df.createSalesOpportunity('SalesOpp', 'Quotation', 5, lAccount[0].Id, dealOppty.Id);
            salesOppty.L2I_Product_Category__c = 'PTS';
            insert salesOppty;
            
            SBQQ__Quote__c quote = df.createQuote('draft', lAccount[0].Id, salesOppty.Id, false);
            quote.SBQQ__Primary__c = true;
            quote.ApprovalStatus__c = 'Pending';
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
            
            
            salesOppty.AccountId = lAccount[1].Id;
            update salesOppty;
        }
        
        Test.stopTest();
    }

    /*
    * @Method Name        : bypassPLApprovalForCROppClosedWon_Test
    * @Description        : Test class for validatePLApproval for CR Opportunities on ClosedWon
    * @Author             : Leah Racquel Ajo / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-004410      Apr-27-2022   MS Simplus Leah      Initial Version
    **/
    @isTest
    static void bypassPLApprovalForCROppClosedWon_Test() {                  
        Account namedCustomer = [SELECT Id FROM Account LIMIT 1];
        
        Product2 gamesProduct = [select Id,
                                        Name,
                                        Family,
                                        SBQQ__ChargeType__c,
                                        SBQQ__BillingFrequency__c,
                                        SBQQ__BillingType__c,
                                        blng__BillingRule__c,
                                        blng__TaxRule__c,
                                        blng__RevenueRecognitionRule__c
                                   from Product2
                                  where L2I_Migrate__c = true and Name = 'Games'
                                  limit 1];

        PricebookEntry pbe = [select Id,
                                     Product2Id,
                                     Pricebook2Id,
                                     UnitPrice,
                                     IsActive
                                from PricebookEntry
                               where Product2Id =: gamesProduct.Id
                               limit 1];
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        test.startTest();      
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunity('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id);
        salesOppty.Change_Request__c = true;
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        String msg = Label.P_L_Approval_Required;
        
        Account compAcct = factory.createCompetitorAccount('CompAcct', '123 Main St.', 'Nashville', 'TN', '37011');
        insert compAcct;
        
        L2I_Competitors__c comp = factory.createCompetitor(salesOppty.Id, compAcct.Id, 'IFEC');
        insert comp;
        comp.Primary__c = true;
        update comp;
        
        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, Integer.valueof((Math.random() * 1000)));
        att.Name = 'F-18'+ Integer.valueof((Math.random() * 1000));
        insert att;

        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule( namedCustomer.Id, att.Id);
        insert dsHeaderlList;

        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine( dsHeaderlList.Id );
        insert dsLineList;

        salesOppty.L2I_Delivery_Schedule__c = dsHeaderlList.Id;
        salesOppty.L2I_Aircraft_Type__c = att.Id;
        update salesOppty;

        Datetime current = System.now(); // returns date time value in GMT time zone.
        Date currDate = current.date();
        //Time currTime = current.time();

        Boolean isPrimaryQuote = true;
        SBQQ__Quote__c quote = factory.createQuote('Draft', namedCustomer.Id, salesOppty.Id, isPrimaryQuote);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__BillingFrequency__c = 'Monthly';
        quote.SBQQ__StartDate__c =  currDate;
        quote.ApprovalStatus__c = 'Approved';
        quote.SubmittedDate__c = Date.today(); // Added by Khrisna for W-004060
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today(); // Added by Khrisna for W-004060
        insert quote;
        
        salesOppty = [select Id, StageName, L2I_Win_Loss_Date__c from Opportunity where Id =: salesOppty.Id];
        salesOppty.L2I_Win_Loss_Date__c = Date.today();
        salesOppty.StageName = 'Closed Won';
        System.debug('*** salesOppty ' + salesOppty);
        update salesOppty;
        // change the stagename
        Boolean gotError = false;
        try {
            update salesOppty;
        } catch (DmlException dmle) {
            gotError = true;
            //System.assert(dmle.getMessage().equals(msg));
        }
        System.assertEquals(false, gotError);
        test.stopTest();
    }

    /*
    * @Method Name        : bypassPLApprovalForCROppPendingClose_Test
    * @Description        : Test class for validatePLApproval for CR Opportunities on Pending Close
    * @Author             : Leah Racquel Ajo / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-004410      Apr-27-2022   MS Simplus Leah      Initial Version
    **/
    @isTest
    static void bypassPLApprovalForCROppPendingClose_Test() {        
        test.startTest();        
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        //System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        //System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');

        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunity('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id);
        salesOppty.Change_Request__c = true;
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        
        Account compAcct = factory.createCompetitorAccount('CompAcct', '123 Main St.', 'Nashville', 'TN', '37011');
        insert compAcct;
        
        L2I_Competitors__c comp = factory.createCompetitor(salesOppty.Id, compAcct.Id, 'IFEC');
        insert comp;
        comp.Primary__c = true;
        update comp;
        
        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, Integer.valueof((Math.random() * 1000)));
        att.Name = 'F-18'+ Integer.valueof((Math.random() * 1000));
        insert att;

        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule( namedCustomer.Id, att.Id);
        insert dsHeaderlList;

        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine( dsHeaderlList.Id );
        insert dsLineList;

        salesOppty.L2I_Delivery_Schedule__c = dsHeaderlList.Id;
        salesOppty.L2I_Aircraft_Type__c = att.Id;
        update salesOppty;

        Datetime current = System.now(); // returns date time value in GMT time zone.
        Date currDate = current.date();
        //Time currTime = current.time();

        Boolean isPrimaryQuote = true;
        SBQQ__Quote__c quote = factory.createQuote('Draft', namedCustomer.Id, salesOppty.Id, isPrimaryQuote);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__BillingFrequency__c = 'Monthly';
        quote.SBQQ__StartDate__c =  currDate;
        quote.ApprovalStatus__c = 'Approved';
        quote.SubmittedDate__c = Date.today(); // Added by Khrisna for W-004060
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today(); // Added by Khrisna for W-004060
        insert quote;

        Product2 gamesProduct = [select Id,
                                        Name,
                                        Family,
                                        SBQQ__ChargeType__c,
                                        SBQQ__BillingFrequency__c,
                                        SBQQ__BillingType__c,
                                        blng__BillingRule__c,
                                        blng__TaxRule__c,
                                        blng__RevenueRecognitionRule__c
                                   from Product2
                                  where L2I_Migrate__c = true and Name = 'Games'
                                  limit 1];

        PricebookEntry pbe = [select Id,
                                     Product2Id,
                                     Pricebook2Id,
                                     UnitPrice,
                                     IsActive
                                from PricebookEntry
                               where Product2Id =: gamesProduct.Id
                               limit 1];


        
        
        salesOppty = [select Id, StageName, L2I_Win_Loss_Date__c from Opportunity where Id =: salesOppty.Id];
        salesOppty.L2I_Win_Loss_Date__c = Date.today();
        salesOppty.StageName = 'Pending Close';
        // change the stagename
        Boolean gotError = false;
        try {
            update salesOppty;
        } catch (DmlException dmle) {
            gotError = true;
            //System.assert(dmle.getMessage().equals(msg));
        }
        System.assertEquals(false, gotError);
        test.stopTest();
    }
    
    /*
    * @Method Name        : populateOperatorAirlineCode
    * @Description        : Test class for updating airline code on Automated Deal Oppty Desc
    * @Author             : Leah Racquel Ajo / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-004410      Apr-27-2022   MS Simplus Leah      Initial Version
    **/
    @isTest
    static void populateOperatorAirlineCodewithSalesOppNoBPillar_Test() {   
        List<Account> accountList = [SELECT Id FROM Account LIMIT 2];
        Account namedCustomer = accountList[0];
        namedCustomer.L2I_Operator_Number__c = 'AC';
        update namedCustomer;
        
        test.startTest();               
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunity('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id);
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        salesOppty.L2I_AC_Operator__c = namedCustomer.Id;
        insert salesOppty;        
        
        test.stopTest();
        
        Opportunity dealOpptyRef = [select Id, L2I_Deal_Opportunity_Description__c from Opportunity where Id =: dealOppty.Id];
        System.assertEquals(dealOpptyRef.L2I_Deal_Opportunity_Description__c, 'AC');
        
        Opportunity salesOpptyRef = [select Id, L2I_Deal_Opportunity_Description__c from Opportunity where Id =: dealOppty.Id];
        System.assertEquals(salesOpptyRef.L2I_Deal_Opportunity_Description__c, 'AC');
    }
    
    /*
    * @Method Name        : populateOperatorAirlineCode
    * @Description        : Test class for updating airline code on Automated Deal Oppty Desc
    * @Author             : Leah Racquel Ajo / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-004410      Apr-27-2022   MS Simplus Leah      Initial Version
    **/
    @isTest
    static void populateOperatorAirlineCodewithSalesOppNoAC_Test() {   
        List<Account> accountList = [SELECT Id FROM Account LIMIT 2];
        Account namedCustomer = accountList[0];
        update namedCustomer;
        
        test.startTest();               
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunity('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id);
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        salesOppty.L2I_AC_Operator__c = namedCustomer.Id;
        insert salesOppty;        
        
        test.stopTest();
        
        Opportunity dealOpptyRef = [select Id, L2I_Deal_Opportunity_Description__c from Opportunity where Id =: dealOppty.Id];
        System.assertEquals(dealOpptyRef.L2I_Deal_Opportunity_Description__c, 'Unavailable');
        
        Opportunity salesOpptyRef = [select Id, L2I_Deal_Opportunity_Description__c from Opportunity where Id =: dealOppty.Id];
        System.assertEquals(salesOpptyRef.L2I_Deal_Opportunity_Description__c, 'Unavailable');
    }
    
    /*
    * @Method Name        : populateOperatorAirline
    * @Description        : Test class for updating airline code on Automated Deal Oppty Desc
    * @Author             : Leah Racquel Ajo / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-004410      Apr-27-2022   MS Simplus Leah      Initial Version
    **/
    @isTest
    static void populateOperatorAirlineCodewithSalesOppWithBPillar_Test() {   
        List<Account> accountList = [SELECT Id FROM Account LIMIT 2];
        Account namedCustomer = accountList[0];
        namedCustomer.L2I_Operator_Number__c = 'AC';
        update namedCustomer;
        
        test.startTest();               
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunity('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id);
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        salesOppty.L2I_AC_Operator__c = namedCustomer.Id;
        insert salesOppty;        
        
        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, Integer.valueof((Math.random() * 1000)));
        att.Name = 'F-18'+ Integer.valueof((Math.random() * 1000));
        insert att;
        
        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule( namedCustomer.Id, att.Id);
        insert dsHeaderlList;
        
        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine( dsHeaderlList.Id );
        dsLineList.Original_Opportunity__c = salesOppty.Id;
        insert dsLineList;
        
        Boolean isPrimaryQuote = true;
        SBQQ__Quote__c quote = factory.createQuote('Draft', namedCustomer.Id, salesOppty.Id, isPrimaryQuote);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__BillingFrequency__c = 'Monthly';
        quote.SBQQ__StartDate__c =  Date.today();
        quote.ApprovalStatus__c = 'Approved';
        quote.SubmittedDate__c = Date.today();
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today();
        insert quote;
        
        quote.PL_Business_Pillars__c = 'PTS';
        update quote;
        
        test.stopTest();
        
        Opportunity dealOpptyRef = [select Id, L2I_Deal_Opportunity_Description__c from Opportunity where Id =: dealOppty.Id];
        System.assertEquals(dealOpptyRef.L2I_Deal_Opportunity_Description__c, 'AC / PTS');
        
        Opportunity salesOpptyRef = [select Id, L2I_Deal_Opportunity_Description__c from Opportunity where Id =: dealOppty.Id];
        System.assertEquals(salesOpptyRef.L2I_Deal_Opportunity_Description__c, 'AC / PTS');
    }
    
    /*
    * @Method Name        : populateOperatorAirline
    * @Description        : Test class for updating airline code on Automated Deal Oppty Desc
    * @Author             : Leah Racquel Ajo / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-004410      Apr-27-2022   MS Simplus Leah      Initial Version
    **/
    @isTest
    static void populateOperatorAirlineCodewithSalesOppNoACWithBPillar_Test() {   
        List<Account> accountList = [SELECT Id FROM Account LIMIT 2];
        Account namedCustomer = accountList[0];
        
        test.startTest();               
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunity('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id);
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        salesOppty.L2I_AC_Operator__c = namedCustomer.Id;
        insert salesOppty;        
        
        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, Integer.valueof((Math.random() * 1000)));
        att.Name = 'F-18'+ Integer.valueof((Math.random() * 1000));
        insert att;
        
        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule( namedCustomer.Id, att.Id);
        insert dsHeaderlList;
        
        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine( dsHeaderlList.Id );
        dsLineList.Original_Opportunity__c = salesOppty.Id;
        insert dsLineList;
        
        Boolean isPrimaryQuote = true;
        SBQQ__Quote__c quote = factory.createQuote('Draft', namedCustomer.Id, salesOppty.Id, isPrimaryQuote);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__BillingFrequency__c = 'Monthly';
        quote.SBQQ__StartDate__c =  Date.today();
        quote.ApprovalStatus__c = 'Approved';
        quote.SubmittedDate__c = Date.today();
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today();
        insert quote;
        
        quote.PL_Business_Pillars__c = 'PTS';
        update quote;
        
        test.stopTest();
        
        Opportunity dealOpptyRef = [select Id, L2I_Deal_Opportunity_Description__c from Opportunity where Id =: dealOppty.Id];
        System.assertEquals(dealOpptyRef.L2I_Deal_Opportunity_Description__c, 'Unavailable / PTS');
        
        Opportunity salesOpptyRef = [select Id, L2I_Deal_Opportunity_Description__c from Opportunity where Id =: dealOppty.Id];
        System.assertEquals(salesOpptyRef.L2I_Deal_Opportunity_Description__c, 'Unavailable / PTS');
    }
    
    /*
    * @Method Name        : populateOperatorAirline
    * @Description        : Test class for updating airline code on Automated Deal Oppty Desc
    * @Author             : Leah Racquel Ajo / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-004410      Apr-27-2022   MS Simplus Leah      Initial Version
    **/
    @isTest
    static void populateOperatorAirlineCodewithSalesOppUpdateOperator_Test() {   
        List<Account> accountList = [SELECT Id FROM Account LIMIT 2];
        Account namedCustomer = accountList[0];
        namedCustomer.L2I_Operator_Number__c = 'AC';
        update namedCustomer;
        
        Account namedCustomer2 = accountList[1];
        namedCustomer2.L2I_Operator_Number__c = 'AD';
        update namedCustomer2;
        
        test.startTest();               
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunity('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id);
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        salesOppty.L2I_AC_Operator__c = namedCustomer.Id;
        insert salesOppty;       
        
        salesOppty.L2I_AC_Operator__c = namedCustomer2.Id;
        update salesOppty;
        
        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, Integer.valueof((Math.random() * 1000)));
        att.Name = 'F-18'+ Integer.valueof((Math.random() * 1000));
        insert att;
        
        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule( namedCustomer.Id, att.Id);
        insert dsHeaderlList;
        
        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine( dsHeaderlList.Id );
        dsLineList.Original_Opportunity__c = salesOppty.Id;
        insert dsLineList;
        
        Boolean isPrimaryQuote = true;
        SBQQ__Quote__c quote = factory.createQuote('Draft', namedCustomer2.Id, salesOppty.Id, isPrimaryQuote);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__BillingFrequency__c = 'Monthly';
        quote.SBQQ__StartDate__c =  Date.today();
        quote.ApprovalStatus__c = 'Approved';
        quote.SubmittedDate__c = Date.today();
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today();
        insert quote;
        
        quote.PL_Business_Pillars__c = 'PTS';
        update quote;
        
        test.stopTest();
        
        Opportunity dealOpptyRef = [select Id, L2I_Deal_Opportunity_Description__c from Opportunity where Id =: dealOppty.Id];
        System.assertEquals(dealOpptyRef.L2I_Deal_Opportunity_Description__c, 'AD / PTS');
        
        Opportunity salesOpptyRef = [select Id, L2I_Deal_Opportunity_Description__c from Opportunity where Id =: dealOppty.Id];
        System.assertEquals(salesOpptyRef.L2I_Deal_Opportunity_Description__c, 'AD / PTS');
    }
}