/**
 *      @author       Raj Rajen
 *      @date         07/29/2019
 *      @description  Test class for L2I Create Order Quick Action.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/29/2019         Initial setup of tests
 *      Sarah Kennedy                 03/05/2020         Modified call to factory.createDeliverySchedule to remove dealOppty.Id parameter (US1520)
 *      MS Simplus Khrisna            12/03/2021         W-004060 - Test Class fix
 *      MS Simplus Khrisna            03/31/2022         W-001727 Primary System Type Validation Rule
 */
@isTest(SeeAllData=false)
public class L2I_CreateOrderController_Test {

    private static L2I_DataFactory factory;
    private static Account namedCustomer;
    private static Opportunity dealOppty;
    private static List<SObject> products;
    private static List<PricebookEntry> pbEntries;


    // It would have been nice to have annotated this method as a @testSetup method so that what it sets up
    // can be leveraged in all of the test methods. However, it turns out that static variables
    // are cleared out by Salesforce before the execution of test methods in order to not have any data depencies
    // in the test methods.
    //
    // Josh Kaplan: "We intentionally clear out static variables between each test method.  If we did not, each
    // test would cease to be an independent trial. You could modify the static in one test method, which would
    // make the order in which tests operate relevant to the results.
    // This is precisely what you don't want - data dependent tests.
    // Source: https://success.salesforce.com/ideaView?id=08730000000Dj51AAC
    // Also see https://developer.salesforce.com/forums/?id=906F00000008yb1IAA for a need for this scenario
    //
    static void setupTestContext() {
        factory = new L2I_DataFactory();

        namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

        dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');

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


        //List<SObject> blng_financePeriods = Test.loadData(blng__FinancePeriod__c.sObjectType,
        //                                                  L2I_StaticConstants.unitTestStaticResource.get('FinancePeriod_file'));


        List<SObject> blng_billingTreatments = Test.loadData(blng__BillingTreatment__c.sObjectType,
                                                             L2I_StaticConstants.unitTestStaticResource.get('BillingTreatment_file'));


        products = Test.loadData(Product2.sObjectType,
                                 L2I_StaticConstants.unitTestStaticResource.get('Product2_file'));


        pbEntries = new List<PricebookEntry>();
        for (SObject prod : products) {
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                                    Product2Id = prod.Id,
                                                    UnitPrice = 1000,
                                                    IsActive = true);
            pbEntries.add(pbe);
        }
        insert pbEntries;
    }

    @isTest
    static void test_quote_order_creation_with_valid_product() {
        setupTestContext();
        
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;

        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
                                                                          dealOppty.Id, 200000, 'DSS');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        System.assert(salesOppty.Id != null, 'Sales Opportunity must have an Id');


        Account competitor = factory.createCompetitorAccount('Competitor X', '123 Main St', 'San Diego', 'CA', '92123');
        insert competitor;

        L2I_Competitors__c opptyCompetitor = new L2I_Competitors__c();
        opptyCompetitor.CompetitorAccount__c = competitor.Id;
        opptyCompetitor.Opportunity__c = salesOppty.Id;
        opptyCompetitor.Type__c = 'IFEC';
        opptyCompetitor.Primary__c = true;
        insert opptyCompetitor;

        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);
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

        System.assert(quote.Id != null, 'Inserted quote cannot have a null Id');

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
        System.assert(gamesProduct.Id != null, 'Games product must exist');

        PricebookEntry pbe = [select Id,
                                     Product2Id,
                                     Pricebook2Id,
                                     UnitPrice,
                                     IsActive
                                from PricebookEntry
                               where Product2Id =: gamesProduct.Id
                               limit 1];
        System.assert(pbe.Id != null, 'Pricebook entry for Games product must exist');

        salesOppty = [select Id, StageName, L2I_Win_Loss_Date__c from Opportunity where Id =: salesOppty.Id];
        salesOppty.L2I_Win_Loss_Date__c = Date.today();
        salesOppty.StageName = 'Closed Won';
        System.debug('*** salesOppty ' + salesOppty);
        update salesOppty;

        List<Product2> selectedProducts = new List<Product2>{gamesProduct};
        System.debug('====== Selected Products :' + selectedProducts);

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        for (Product2 prod : selectedProducts) {
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = prod.Id);
            ql.SBQQ__BillingFrequency__c = 'Monthly';
            ql.SBQQ__BillingType__c = 'Arrears';
            ql.SBQQ__StartDate__c = currDate;
            lines.add(ql);
        }
        if (!lines.isEmpty()) {
            insert lines;
        }

        try {
            Boolean result = L2I_CreateOrderController.createOrder(quote.Id);
            System.debug('====== Results of Create L2I Order QuickAction :' + result);
        } catch (AuraHandledException ahe) {
            System.debug('Controller threw an AuraHandledException');
            System.debug('====== ' + ahe.getMessage());
        } catch (DmlException dmle) {
            // TODO:
            // first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Enter the Billing Day of Month to continue.: []
            // TBD where does the order get its Billing Day of Month value from?
            System.debug('Controller threw a DmlException');
            System.debug('====== ' + dmle.getMessage());
        }

    }

    /**
    @isTest
    static void test_quote_order_creation_with_invalid_product() {
        setupTestContext();

        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
                                                                          dealOppty.Id, 200000, 'IFEC');
        insert salesOppty;
        System.assert(salesOppty.Id != null, 'Sales Opportunity must have an Id');

        Datetime current = System.now(); // returns date time value in GMT time zone.
        Date currDate = current.date();
        //Time currTime = current.time();

        Boolean isPrimaryQuote = true;
        SBQQ__Quote__c quote = factory.createQuote('Draft', namedCustomer.Id, salesOppty.Id, isPrimaryQuote);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__BillingFrequency__c = 'Monthly';
        quote.SBQQ__StartDate__c =  currDate;
        insert quote;

        System.assert(quote.Id != null, 'Inserted quote cannot have a null Id');

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
        System.assert(gamesProduct.Id != null, 'Games product must exist');

        PricebookEntry pbe = [select Id,
                                     Product2Id,
                                     Pricebook2Id,
                                     UnitPrice,
                                     IsActive
                                from PricebookEntry
                               where Product2Id =: gamesProduct.Id
                               limit 1];
        System.assert(pbe.Id != null, 'Pricebook entry for Games product must exist');

        List<Product2> selectedProducts = new List<Product2>{gamesProduct};
        System.debug('====== Selected Products :' + selectedProducts);

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        for (Product2 prod : selectedProducts) {
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = prod.Id);
            ql.SBQQ__BillingFrequency__c = 'Monthly';
            ql.SBQQ__BillingType__c = 'Arrears';
            ql.SBQQ__StartDate__c = currDate;
            lines.add(ql);
        }
        if (!lines.isEmpty()) {
            insert lines;
        }

        try {
            Boolean result = L2I_CreateOrderController.createOrder(quote.Id);
            System.debug('====== Results of Create L2I Order QuickAction :' + result);
            // first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Enter the Billing Day of Month to continue.: []
            // TBD where does the order get its Billing Day of Month value from?
        } catch (AuraHandledException ahe) {
            System.debug('Controlled threw an exception');
            System.debug('====== ' + ahe.getMessage());
        }


    }
    **/

    @isTest
    static void testOrderCreation() {
        setupTestContext();

        List<Id> accRecTypes = new List<Id>();

        for(String recType: L2I_JSON_Settings.getSpecificSettingCollection('Order_Creation_Settings','Excluded_Account_RecTypes')) {
            accRecTypes.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(recType).getRecordTypeId());
        }
        System.debug(L2I_JSON_Settings.getSpecificSettingCollection('Order_Creation_Settings','Excluded_Account_RecTypes')+' '+accRecTypes);

        namedCustomer.RecordTypeId = accRecTypes[0];
        update namedCustomer;
        
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;

        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
                                                                          dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;

        SBQQ__Quote__c quote = factory.createQuote('Draft', namedCustomer.Id, salesOppty.Id, true);
        quote.L2I_Forecasting_Quote__c = true;
        insert quote;

        Set<String> placeholderProds = L2I_JSON_Settings.getSpecificSettingCollection('Order_Creation_Settings','Place_Holder_Parts');

        List<Product2> placeholder = [select Id,
                                             Name,
                                 		     ProductCode
                                        from Product2
                                       where L2I_Migrate__c = true and ProductCode in :placeholderProds];
        System.assert(placeholder != null, 'Placeholder Products must exist');

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = placeholder[0].Id);
        lines.add(ql);
        insert lines;

        Test.startTest();
        try {
            Boolean result = L2I_CreateOrderController.createOrder(quote.Id);
        } catch(AuraHandledException ahe) {
            System.debug('Controller threw an AuraHandledException');
            System.debug('====== ' + ahe.getMessage());
        } catch (DmlException dmle) {
            System.debug('Controller threw a DmlException');
            System.debug('====== ' + dmle.getMessage());
        }
        Test.stopTest();
    }
}