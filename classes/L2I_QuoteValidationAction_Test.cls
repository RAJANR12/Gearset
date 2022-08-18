/**
 *      @author       Raj Rajen
 *      @date         09/18/2019
 *      @description  Test class for L2I Quote Validation Action (Invocable Apex class).
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     09/18/2019         Initial setup of tests
 *      Arun V                        11/08/2019         Added testExcludeFromOrderProduct
 *      Sarah Kennedy                 03/05/2020         Modified call to factory.createDeliverySchedule to remove dealOppty.Id parameter (US1520)
 *      MS Simplus Khrisna            01/13/2022         W-004060 Fix test classes
 *      MS Simplus Khrisna            03/31/2022         W-001727 Primary System Type Validation Rule
 * 
 */
@isTest(SeeAllData=false)
public class L2I_QuoteValidationAction_Test {

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
        namedCustomer.L2I_Operator_Number__c = 'AB';
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
    static void test_validation_of_valid_quote() {
        setupTestContext();
        
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','DSS','Applications', 'X-Series');
        insert prodSysType;

        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Handoff', 30, namedCustomer.Id,
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
    
        Product2 product = factory.createProduct('99999802', 'MediaServices', null, null, null);
        product.productCode = 'MCS BUNDLE';
        product.L2I_System_Type_Translation__c = 'A';
        insert product;

        // START Added by KElumba for W-004060
        PT_PMO_Groups__c pmoGroup = new  PT_PMO_Groups__c();
        pmoGroup.Name = 'Test12345';
        pmoGroup.Group_Type__c = 'Group';
        insert pmoGroup;

        PT_PMO_Groups__c pmoSubGroup = new  PT_PMO_Groups__c();
        pmoSubGroup.Name = 'Test456';
        pmoSubGroup.Group_Type__c = 'Sub Group';
        insert pmoSubGroup;

        User testUser;
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (currentUser) {
            Profile profile = [SELECT Id FROM Profile WHERE Name='PAC Sales' LIMIT 1];
            testUser = factory.createTestUser(null, profile.Id, 'First Name', 'Last Name');
            insert testUser;
        }
        // END W-004060

        salesOppty.L2I_Primary_System_Type__c = product.Id;
        salesOppty.L2I_Aircraft_Type__c = att.Id;
        salesOppty.L2I_Delivery_Schedule__c = dsHeaderlList.Id;
        salesOppty.L2I_AC_Operator__c = namedCustomer.Id;
        salesOppty.Proposed_Program_Manager__c = testUser.Id;
        salesOppty.Proposed_PMO_Group__c = pmoGroup.Id;
        salesOppty.Proposed_PMO_SubGroup__c = pmoSubGroup.Id;
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

        PT_Program__c prog1 = new PT_Program__c();
        prog1.MROD_Approval_Status__c = 'Pending';
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        prog1.Program_Manager__c = testUser.Id;
        prog1.PT_PMO_Group__c = pmoGroup.Id;
        prog1.PT_PMO_SubGroup__c = pmoSubGroup.Id;
        insert prog1;

        salesOppty = [select Id, StageName, L2I_Win_Loss_Date__c from Opportunity where Id =: salesOppty.Id];
        salesOppty.L2I_Win_Loss_Date__c = Date.today();
        salesOppty.StageName = 'Delivery';
        salesOppty.SBQQ__PrimaryQuote__c = quote.Id;
        salesOppty.L2I_Program_Num__c = prog1.Id;
        update salesOppty;

        List<Product2> selectedProducts = new List<Product2>{gamesProduct};
        System.debug('====== Selected Products :' + selectedProducts);
    
        Asset ast = new Asset(
              Name = 'AssetName',
              AccountId = namedCustomer.Id,
              Product2Id = selectedProducts[0].Id,
              PT_Program__c = prog1.Id
        );
        insert ast;

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        for (Product2 prod : selectedProducts) {
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = prod.Id);
            ql.SBQQ__BillingFrequency__c = 'Monthly';
            ql.SBQQ__BillingType__c = 'Arrears';
            ql.SBQQ__StartDate__c = currDate;
            ql.PT_Asset__c = ast.Id;
            lines.add(ql);
        }
        if (!lines.isEmpty()) {
            insert lines;
        }
        
        List<L2I_QuoteValidationAction.L2I_QuoteValidationResult> results = null;
        L2I_QuoteValidationAction.L2I_QuoteValidationRequest request = new L2I_QuoteValidationAction.L2I_QuoteValidationRequest();
        request.quoteId = quote.Id;

        List<L2I_QuoteValidationAction.L2I_QuoteValidationRequest> requests = new List<L2I_QuoteValidationAction.L2I_QuoteValidationRequest>();
        requests.add(request);
        results = L2I_QuoteValidationAction.validateQuote(requests);
        
        System.debug('====== Quote Validation Status :' + results[0].isValid);
        System.debug('====== Quote Validation Message :' + results[0].message);
        System.assert(results[0].isValid, 'Expected the Quote validation to pass');
    }


    @isTest
    static void test_validation_of_invalid_quote() {
        setupTestContext();

        List<Id> accRecTypes = new List<Id>();

        for(String recType: L2I_JSON_Settings.getSpecificSettingCollection('Order_Creation_Settings','Excluded_Account_RecTypes')) {
            accRecTypes.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(recType).getRecordTypeId());
        }
        System.debug(L2I_JSON_Settings.getSpecificSettingCollection('Order_Creation_Settings','Excluded_Account_RecTypes')+' '+accRecTypes);

        namedCustomer.RecordTypeId = accRecTypes[0];
        update namedCustomer;
        
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','DSS','Applications', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
                                                                           dealOppty.Id, 200000, 'DSS');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;

        SBQQ__Quote__c quote = factory.createQuote('Draft', namedCustomer.Id, salesOppty.Id, true);
        quote.L2I_Forecasting_Quote__c = true;
        quote.SBQQ__Primary__c = false;
        quote.SBQQ__Ordered__c = true;
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

        List<L2I_QuoteValidationAction.L2I_QuoteValidationResult> results = null;
        L2I_QuoteValidationAction.L2I_QuoteValidationRequest request = new L2I_QuoteValidationAction.L2I_QuoteValidationRequest();
        request.quoteId = quote.Id;

        List<L2I_QuoteValidationAction.L2I_QuoteValidationRequest> requests = new List<L2I_QuoteValidationAction.L2I_QuoteValidationRequest>();
        requests.add(request);
        results = L2I_QuoteValidationAction.validateQuote(requests);

        System.debug('====== Quote Validation Status :' + results[0].isValid);
        System.debug('====== Quote Validation Message :' + results[0].message);
        System.assert(!results[0].isValid, 'Expected the Quote validation to fail');
    }

    @isTest
    static void testExcludeFromOrderProduct() {
        setupTestContext();

        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','DSS','Applications', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
                                                                           dealOppty.Id, 200000, 'DSS');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;

        SBQQ__Quote__c quote = factory.createQuote('Draft', namedCustomer.Id, salesOppty.Id, true);
        quote.L2I_Forecasting_Quote__c = true;
        quote.SBQQ__Primary__c = true;
        insert quote;

        Product2 product = [select Id,Name,ProductCode,L2I_Exclude_From_Orders__c from Product2 LIMIT 1];
        product.L2I_Exclude_From_Orders__c = true;
        update product;

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = product.Id);
        lines.add(ql);
        insert lines;

        List<L2I_QuoteValidationAction.L2I_QuoteValidationResult> results = null;
        L2I_QuoteValidationAction.L2I_QuoteValidationRequest request = new L2I_QuoteValidationAction.L2I_QuoteValidationRequest();
        request.quoteId = quote.Id;

        List<L2I_QuoteValidationAction.L2I_QuoteValidationRequest> requests = new List<L2I_QuoteValidationAction.L2I_QuoteValidationRequest>();
        requests.add(request);
        results = L2I_QuoteValidationAction.validateQuote(requests);

        System.debug('====== Quote Validation Status :' + results[0].isValid);
        System.debug('====== Quote Validation Message :' + results[0].message);
        System.assert(!results[0].isValid, 'Expected the Quote validation to fail');
    }
    
    @isTest
    static void testAmendmentQuote() {
        setupTestContext();
        
        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);
        insert att;
        
        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule( namedCustomer.Id, att.Id);
        insert dsHeaderlList;
        blng__BillingRule__c billingRule = [Select Id From blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c revRec = [Select Id From blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c taxRule = [Select Id From blng__TaxRule__c LIMIT 1];
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','DSS','Applications', 'X-Series');
        insert prodSysType;

        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
                                                                           dealOppty.Id, 200000, 'DSS');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;

        SBQQ__Quote__c quote = factory.createQuote('Draft', namedCustomer.Id, salesOppty.Id, true);
        quote.SBQQ__Type__c = 'Amendment';
        quote.L2I_Obsolete__c = True;
        insert quote;

        Product2 product = [select Id,Name,ProductCode,L2I_Exclude_From_Orders__c from Product2 LIMIT 1];

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = product.Id);
        lines.add(ql);
        insert lines;
        
        Order testOrder = new Order(AccountId = namedCustomer.Id, PoNumber= 'Test', EffectiveDate = Date.today(), Status='Draft', 
                                       Pricebook2Id=Test.getStandardPricebookId(), blng__BillingDayOfMonth__c = '30', OpportunityId = salesOppty.Id, 
                                       SBQQ__Quote__c = quote.Id, L2I_Delivery_Schedule__c = dsHeaderlList.Id);
        insert testOrder;
        
        
        List<OrderItem> OrderItemList = new List<OrderItem>();
        OrderItem item = new OrderItem(OrderId = testOrder.id, Quantity = 1, Product2Id = product.Id,  
                                           UnitPrice = 123, blng__BillingRule__c = billingRule.Id, 
                                           blng__RevenueRecognitionRule__c = revRec.Id, blng__TaxRule__c = taxRule.Id, SBQQ__ChargeType__c = 'One-Time', 
                                           SBQQ__DefaultSubscriptionTerm__c = 24, SBQQ__Activated__c = false);
        insert OrderItemList;

        List<L2I_QuoteValidationAction.L2I_QuoteValidationResult> results = null;
        L2I_QuoteValidationAction.L2I_QuoteValidationRequest request = new L2I_QuoteValidationAction.L2I_QuoteValidationRequest();
        request.quoteId = quote.Id;

        List<L2I_QuoteValidationAction.L2I_QuoteValidationRequest> requests = new List<L2I_QuoteValidationAction.L2I_QuoteValidationRequest>();
        requests.add(request);
        results = L2I_QuoteValidationAction.validateQuote(requests);

        System.debug('====== Quote Validation Status :' + results[0].isValid);
        System.debug('====== Quote Validation Message :' + results[0].message);
        System.assert(!results[0].isValid, 'Expected the Quote validation to fail');
    }
    
    @isTest
    static void testRenewalQuote() {
        setupTestContext();
        
        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);
        insert att;
        
        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule( namedCustomer.Id, att.Id);
        insert dsHeaderlList;
        blng__BillingRule__c billingRule = [Select Id From blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c revRec = [Select Id From blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c taxRule = [Select Id From blng__TaxRule__c LIMIT 1];

        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','DSS','Applications', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
                                                                           dealOppty.Id, 200000, 'DSS');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;

        SBQQ__Quote__c quote = factory.createQuote('Draft', namedCustomer.Id, salesOppty.Id, true);
        quote.SBQQ__Type__c = 'Renewal';
        quote.L2I_Obsolete__c = True;
        insert quote;

        Product2 product = [select Id,Name,ProductCode,L2I_Exclude_From_Orders__c from Product2 LIMIT 1];

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = product.Id);
        lines.add(ql);
        insert lines;
        
        Order testOrder = new Order(AccountId = namedCustomer.Id, PoNumber= 'Test', EffectiveDate = Date.today(), Status='Draft', 
                                       Pricebook2Id=Test.getStandardPricebookId(), blng__BillingDayOfMonth__c = '30', OpportunityId = salesOppty.Id, 
                                       SBQQ__Quote__c = quote.Id, L2I_Delivery_Schedule__c = dsHeaderlList.Id);
        insert testOrder;
        
        
        List<OrderItem> OrderItemList = new List<OrderItem>();
        OrderItem item = new OrderItem(OrderId = testOrder.id, Quantity = 1, Product2Id = product.Id,  
                                           UnitPrice = 123, blng__BillingRule__c = billingRule.Id, 
                                           blng__RevenueRecognitionRule__c = revRec.Id, blng__TaxRule__c = taxRule.Id, SBQQ__ChargeType__c = 'One-Time', 
                                           SBQQ__DefaultSubscriptionTerm__c = 24, SBQQ__Activated__c = false);
        insert OrderItemList;

        List<L2I_QuoteValidationAction.L2I_QuoteValidationResult> results = null;
        L2I_QuoteValidationAction.L2I_QuoteValidationRequest request = new L2I_QuoteValidationAction.L2I_QuoteValidationRequest();
        request.quoteId = quote.Id;

        List<L2I_QuoteValidationAction.L2I_QuoteValidationRequest> requests = new List<L2I_QuoteValidationAction.L2I_QuoteValidationRequest>();
        requests.add(request);
        results = L2I_QuoteValidationAction.validateQuote(requests);

        System.debug('====== Quote Validation Status :' + results[0].isValid);
        System.debug('====== Quote Validation Message :' + results[0].message);
        System.assert(!results[0].isValid, 'Expected the Quote validation to fail');
    }
}