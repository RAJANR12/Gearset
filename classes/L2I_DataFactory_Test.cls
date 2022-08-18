/**
 *      @author       Raj Rajen
 *      @date         07/17/2019
 *      @description  Test class for global static constants
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/17/2019         Initial setup of tests
 *      Sarah Kennedy                 02/18/2020         Modified CreateDeliverySchedule to remove Deal Opp as a parameter
 *      MS Simplus Khrisna            03/31/2022         W-001727 Primary System Type Validation Rule
 */
@IsTest(SeeAllData=false)
public class L2I_DataFactory_Test {


    @isTest
    static void test_aircraft_insertion() {
        L2I_DataFactory factory = new L2I_DataFactory();

        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);
        insert att;

        L2I_Aircraft__c ac = factory.createAircraft(att.Id, 'Name', '2333-11131133114499999988888805', namedCustomer.Id);
        insert ac;

        System.assert(ac.Id != null, 'Aircraft Id cannot be null');
    }

    @isTest
    static void test_user_insertion() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Profile prof = L2I_StaticConstants.getProfileByName('PAC Sales');
        Id roleId = null;
        Id profileId = prof.Id;
        User u = factory.createTestUser(roleId, profileId, 'Joe', 'Jacoby');
        insert u;

        User usr = [select ProfileId from User where Id = :u.Id limit 1];

        System.assert(usr.ProfileId == prof.Id, 'User profile must be same as "PAC Sales" profile');
    }

    @isTest
    static void test_account_creation() {
        L2I_DataFactory factory = new L2I_DataFactory();

        Account customer = factory.createCustomerAccount();
        insert customer;
        System.assert(customer.Id != null, 'Customer Account must have an Id');

        Account competitor = factory.createCompetitorAccount();
        insert competitor;
        System.assert(competitor.Id != null, 'Competitor Account must have an Id');

        Account namedCustomer = factory.createCustomerAccount('Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

        Account namedCompetitor = factory.createCompetitorAccount('Competitor', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCompetitor;
        System.assert(namedCompetitor.Id != null, 'Named Competitor Account must have an Id');
    }

    @isTest
    static void test_account_opportunity_quotes() {
        L2I_DataFactory factory = new L2I_DataFactory();

        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');
        
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        prodSysType.L2I_System_Type_Translation__c = 'G';
        insert prodSysType;

        //Create Opportunity
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');

        Opportunity salesOppty1 = factory.createSalesOpportunity('Sales', 'Open', 30, namedCustomer.Id, dealOppty.Id);
        insert salesOppty1;

        Opportunity salesOppty2 = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
                dealOppty.Id, 200000, 'IFEC');
        // Added for W-001727
        salesOppty2.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty2;

        SBQQ__Quote__c draftQuote = factory.createQuote('draft', namedCustomer.Id, salesOppty2.Id, true);
        insert draftQuote;

        SBQQ__Quote__c approvedQuote = factory.createQuote('approved', namedCustomer.Id, salesOppty2.Id, true);
        insert approvedQuote;

        SBQQ__Quote__c pendingQuote = factory.createQuote('pending', namedCustomer.Id, salesOppty2.Id, true);
        insert pendingQuote;
    }

    /**
    @IsTest
    static void test_quote_line_creation() {
        L2I_DataFactory factory = new L2I_DataFactory();

        List<Product2> products = Test.loadData(Product2.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('Product2_file'));


        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        for (SObject prod : products) {
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                    Product2Id = prod.Id,
                    UnitPrice = 1000,
                    IsActive = true);
            pbEntries.add(pbe);
        }
        insert pbEntries;


        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

        //Create Opportunity
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');

        Opportunity salesOppty2 = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
                dealOppty.Id, 200000, 'IFEC');
        insert salesOppty2;

        SBQQ__Quote__c draftQuote = factory.createQuote('draft', namedCustomer.Id, salesOppty2.Id, true);
        insert draftQuote;

        SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine( draftQuote.Id, products[0].Id, null );
        insert quoteLine;
    }
    **/

    @isTest
    static void test_recordtypes() {
        L2I_DataFactory factory = new L2I_DataFactory();

        RecordType[] accountRecordTypes = L2I_StaticConstants.getRecordTypeIDsByObject('Account');
        System.assert(accountRecordTypes.size() == 3, 'Three Record Types are expected for Account Data Type');
    }

    @isTest
    static void test_product_insertion() {
        L2I_DataFactory factory = new L2I_DataFactory();

        //[RR]Product2 prod = factory.createProduct('1234','Training','PTS','PTS', 'PTS');
        Product2 prod = factory.createProduct('1234','WiFi Usage Test','DSS','Connectivity Services', 'WiFi');
        insert prod;

        System.assert(prod.Id != null, 'Inserted Product must have an Id');
    }

    @TestVisible
    static void test_load_products() {
        L2I_DataFactory factory = new L2I_DataFactory();


        List<SObject> blng_GLRules = Test.loadData(blng__GLRule__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('GLRule_file'));


        List<SObject> blng_LegalEntities = Test.loadData(blng__LegalEntity__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('LegalEntity_file'));


        List<SObject> blng_financeBooks = Test.loadData(blng__FinanceBook__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('FinanceBook_file'));


        List<SObject> blng_billingRules = Test.loadData(blng__BillingRule__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('BillingRule_file'));


        List<SObject> blng_taxRules = Test.loadData(blng__TaxRule__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('TaxRule_file'));


        List<SObject> blng_revrecRules = Test.loadData(blng__RevenueRecognitionRule__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('RevenueRecognitionRule_file'));


        List<SObject> blng_GLAccounts = Test.loadData(blng__GLAccount__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('GLAccount_file'));


        List<SObject> blng_GLTreatments = Test.loadData(blng__GLTreatment__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('GLTreatment_file'));


        // the following is a time-consuming load. Turn it on only if it is needed. In all likelihood, this is needed
        // for Invoice runs, which is not in scope for the set of tests in this UnitTest class
        //List<SObject> blng_financePeriods = Test.loadData(blng__FinancePeriod__c.sObjectType,
        //                                                  L2I_StaticConstants.unitTestStaticResource.get('FinancePeriod_file'));


        List<SObject> blng_billingTreatments = Test.loadData(blng__BillingTreatment__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('BillingTreatment_file'));


        List<Product2>products = Test.loadData(Product2.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('Product2_file'));


        List<Product2> ptsProducts = [select Id, Name from Product2 where L2I_Sub_Category_2__c = 'pts'];
        System.assert(ptsProducts.size() > 0, 'There must be PTS products loaded in the system');

        List<Product2> advProducts = [select Id, Name from Product2 where L2I_Sub_Category_2__c = 'advertising'];
        System.assert(advProducts.size() > 0, 'There must be Advertising products loaded in the system');

        List<Product2> brandsProducts = [select Id, Name from Product2 where L2I_Sub_Category_2__c = 'advertisers/brands'];
        System.assert(brandsProducts.size() > 0, 'There must be Advertisers/Brands products loaded in the system');

        List<Product2> gamesProducts = [select Id, Name from Product2 where L2I_Sub_Category_2__c = 'games'];
        System.assert(gamesProducts.size() > 0, 'There must be Games products loaded in the system');

        //Hardware products existed at one time in the system, but were removed in the August '19 timeframe.
        //List<Product2> hardwareProducts = [select Id, Name from Product2 where L2I_Sub_Category_2__c = 'hardware'];
        //System.assert(hardwareProducts.size() > 0, 'There must be Hardware products loaded in the system');

        List<Product2> mcsProducts = [select Id, Name from Product2 where L2I_Sub_Category_2__c = 'mcs'];
        System.assert(mcsProducts.size() > 0, 'There must be MCS products loaded in the system');

        List<Product2> tvMediaProducts = [select Id, Name from Product2 where L2I_Sub_Category_2__c = 'tv/media'];
        System.assert(tvMediaProducts.size() > 0, 'There must be TV/Media products loaded in the system');

        List<Product2> wifiProducts = [select Id, Name from Product2 where L2I_Sub_Category_2__c = 'wifi'];
        System.assert(wifiProducts.size() > 0, 'There must be WiFi products loaded in the system');
    }

    @isTest
    static void test_delivery_schedule_creation() {
        L2I_DataFactory factory = new L2I_DataFactory();

        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);
        insert att;

        L2I_Aircraft__c ac = factory.createAircraft(att.Id, 'Name', '2333-11131133114499999988888805', namedCustomer.Id);
        insert ac;

        System.assert(ac.Id != null, 'Aircraft Id cannot be null');

        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');

        L2I_DSH__c dsh = factory.createDeliverySchedule(namedCustomer.Id, att.Id);
        insert dsh;
        System.assert(dsh.Id != null, 'Delivery Schedule Header Id cannot be null');

        L2I_DSL__c dsl = factory.createDeliveryScheduleLine(dsh.Id);
        insert dsl;
        System.assert(dsl.Id != null, 'Delivery Schedule Line Id cannot be null');
    }
    
   /**
    * @Method Name		: testChat
    * @Description      : test method for 
    **/
    @isTest
    static void testChat() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder2(null, null, false, 'Activated');
    }

   /**
    * @Method Name		: testFactory
    * @Description      : test method for other Data Factory Method
    **/
    @isTest
    static void testFactory() {
        L2I_DataFactory factory = new L2I_DataFactory();      
        
        Profile prof = L2I_StaticConstants.getProfileByName('PAC Sales');
        User u = factory.createTestUser(null, prof.Id, 'Sales', 'User');
        insert u;        

        test.startTest();
        System.runAs(u) {  
            Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');
            
            L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);
            insert att;
            
            L2I_Aircraft__c ac = factory.createAircraft(att.Id, 'Name', '2333-11131133114499999988888805', namedCustomer.Id);
            insert ac;
            
            System.assert(ac.Id != null, 'Aircraft Id cannot be null');
            
            Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
            insert dealOppty;
            System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');
            
            L2I_Competitors__c comp = factory.createCompetitor(dealOppty.Id, namedCustomer.Id, 'DSS');
            L2I_P_L_Approval__c plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
            OpportunityTeamMember oppTeam = factory.createOpportunityTeamMember('','',dealOppty.Id, u.Id);
            insert plApproval;
            
            L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, dealOppty.Id);  
            
            system.assert(comp != NULL);
            system.assert(plApproval != NULL);
            system.assert(plSalesOpp != NULL);
            system.assert(plSalesOpp != NULL);
        }
        test.stopTest();
        
        
    }
}