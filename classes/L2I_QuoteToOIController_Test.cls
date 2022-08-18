/**
 *
 *      @author       Andy Fang
 *      @date         09/25/2019
 *      @description  L2I Quote to Order Product Controller
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                     09/25/2019         Initial scaffold
 *      Sarah Kennedy                 03/05/2020         Modified call to factory.createDeliverySchedule to remove dealOppty.Id parameter (US1520)
 *      Andy Fang                     04/09/2020         Commeting out
 */

@IsTest
private class L2I_QuoteToOIController_Test {

    /*
    private static L2I_DataFactory factory;
    private static List<SObject> products;
    private static List<PricebookEntry> pbEntries;

    static void setupTestContext() {
        factory = new L2I_DataFactory();

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

    @IsTest
    static void testUsageSummaryMatchingID() {
        setupTestContext();

        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

        //Create Opportunity
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');

        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
                dealOppty.Id, 200000, 'IFEC');
        insert salesOppty;

        SBQQ__Quote__c quote = factory.createQuote('draft', namedCustomer.Id, salesOppty.Id, true);
        insert quote;

        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();

        Set<Id> productIdSet = new Set<Id>();
        Map<Id, String> prodCategoryMap = new Map<Id, String>();

        List<Product2> prodList = [ select Id, Name, L2I_Sub_Category_2__c from Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();

        for (Product2 p : prodList) {
            prodIdMap.put( p.Name, p.Id );
            prodCategoryMap.put( p.Id, p.L2I_Sub_Category_2__c );
        }

        Set<String> ProductNameList = new Set<String>();

        //ProductNameList.add('Advertising Services');
        //[RR]ProductNameList.add('Connectivity Services - WiFi'); // this product will not work as L2I_Service_Activation_Type__c is null for it
        ProductNameList.add('Live Television - Monthly Additional Satellite Capacity - per aircraft');

        //ProductNameList.add('Games');
        //ProductNameList.add('Live Television');
        //ProductNameList.add('Media Services');
        //ProductNameList.add('OneMedia Overhead Initial License Fee - per airline');
        //ProductNameList.add('OneMedia Premium Service Monthly Recurring License Fee - per aircraft');
        //ProductNameList.add('OneMedia Optional Monthly Ad Operations Fee');
        //ProductNameList.add('OneMedia Content Management Tool Access');
        //ProductNameList.add('Boingo Usage');
        //ProductNameList.add('iPass Usage');
        //ProductNameList.add('Live Television - Monthly Additional Satellite Capacity - per aircraft');
        Set<Id> prodIdList = New Set<Id>();

        for (String s : ProductNameList) {
            Id pid = prodIdMap.get( s );
            prodIdList.add( pid );
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine( quote.Id, pid, null );
            qlList.add(quoteLine);
        }
        insert qlList;

        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);

        insert att;

        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule( namedCustomer.Id, att.Id );

        insert dsHeaderlList;

        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine( dsHeaderlList.Id );

        insert dsLineList;

        updateDSHToSalesOppo( salesOppty, dsHeaderlList.Id );

        List<PricebookEntry> pbeList = [select Id,
                Product2Id,
                Pricebook2Id,
                UnitPrice,
                IsActive
        from PricebookEntry
        where Product2Id in: prodIdList];

        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : pbeList ){
            pricebookMap.put( pbe.Product2Id, pbe );
        }
        Order theTestOrder = new Order(AccountId = namedCustomer.Id,
                PoNumber= 'Test',
                EffectiveDate = Date.today(),
                Status='Draft',
                Pricebook2Id=Test.getStandardPricebookId(),
                blng__BillingDayOfMonth__c = '30',
                OpportunityId = salesOppty.Id,
                SBQQ__Quote__c = quote.Id,
                L2I_Delivery_Schedule__c = dsHeaderlList.Id);
        insert theTestOrder;

        List<OrderItem> OrderItemList = new List<OrderItem>();
        blng__BillingRule__c billingrule = [ select Id from blng__BillingRule__c where name = 'Non-Billable Product Rule' limit 1];
        for ( Id pid : prodIdList ) {
            OrderItem theTestOrderItem = new OrderItem(OrderId = theTestOrder.id,
                    Quantity = 1,
                    Product2Id = pid,
                    PricebookEntryId = pricebookMap.get(pid).Id,
                    UnitPrice = pricebookMap.get(pid).UnitPrice,
                    L2I_Sub_Category_2__c = prodCategoryMap.get( pid ),
                    SBQQ__ChargeType__c = 'Recurring',
                    SBQQ__BillingFrequency__c = 'Monthly',
                    SBQQ__BillingType__c = 'Advance',
                    blng__BillingRule__c = billingrule.Id,
                    SBQQ__DefaultSubscriptionTerm__c = 24,
                    L2I_blng_MatchingId__c = '00N18000001Vkc2',
                    SBQQ__Activated__c = false);
            OrderItemList.add( theTestOrderItem );
        }

        insert OrderItemList;

        L2I_Aircraft__c ac = factory.createAircraft( att.Id, 'Test User Name', '2333-11131133114499999988888805', namedCustomer.Id);

        insert ac;
        System.assert( ac.Id != null , 'No aircraft record has been created.');

        Test.startTest();

        List<object> result = L2I_QuoteToOIController.autoCreateAircraftServicesFromQuote( new List<Id>{ quote.Id } );



        Test.stopTest();
    }


    @IsTest
    static void testUsageSummaryMatchingIDError() {
        setupTestContext();

        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

        //Create Opportunity
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');

        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
                dealOppty.Id, 200000, 'IFEC');
        insert salesOppty;

        SBQQ__Quote__c quote = factory.createQuote('draft', namedCustomer.Id, salesOppty.Id, true);
        insert quote;

        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();

        Set<Id> productIdSet = new Set<Id>();
        Map<Id, String> prodCategoryMap = new Map<Id, String>();

        List<Product2> prodList = [ select Id, Name, L2I_Sub_Category_2__c from Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();

        for (Product2 p : prodList) {
            prodIdMap.put( p.Name, p.Id );
            prodCategoryMap.put( p.Id, p.L2I_Sub_Category_2__c );
        }

        Set<String> ProductNameList = new Set<String>();

        //ProductNameList.add('Advertising Services');
        //[RR]ProductNameList.add('Connectivity Services - WiFi'); // this product will not work as L2I_Service_Activation_Type__c is null for it
        ProductNameList.add('Games');

        //ProductNameList.add('Games');
        //ProductNameList.add('Live Television');
        //ProductNameList.add('Media Services');
        //ProductNameList.add('OneMedia Overhead Initial License Fee - per airline');
        //ProductNameList.add('OneMedia Premium Service Monthly Recurring License Fee - per aircraft');
        //ProductNameList.add('OneMedia Optional Monthly Ad Operations Fee');
        //ProductNameList.add('OneMedia Content Management Tool Access');
        //ProductNameList.add('Boingo Usage');
        //ProductNameList.add('iPass Usage');
        //ProductNameList.add('Live Television - Monthly Additional Satellite Capacity - per aircraft');
        Set<Id> prodIdList = New Set<Id>();

        for (String s : ProductNameList) {
            Id pid = prodIdMap.get( s );
            prodIdList.add( pid );
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine( quote.Id, pid, null );
            qlList.add(quoteLine);
        }
        insert qlList;

        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);

        insert att;

        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule( namedCustomer.Id, att.Id);

        insert dsHeaderlList;

        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine( dsHeaderlList.Id );

        insert dsLineList;

        updateDSHToSalesOppo( salesOppty, dsHeaderlList.Id );

        List<PricebookEntry> pbeList = [select Id,
                Product2Id,
                Pricebook2Id,
                UnitPrice,
                IsActive
        from PricebookEntry
        where Product2Id in: prodIdList];

        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : pbeList ){
            pricebookMap.put( pbe.Product2Id, pbe );
        }
        Order theTestOrder = new Order(AccountId = namedCustomer.Id,
                PoNumber= 'Test',
                EffectiveDate = Date.today(),
                Status='Draft',
                Pricebook2Id=Test.getStandardPricebookId(),
                blng__BillingDayOfMonth__c = '30',
                OpportunityId = salesOppty.Id,
                SBQQ__Quote__c = quote.Id,
                L2I_Delivery_Schedule__c = dsHeaderlList.Id);
        insert theTestOrder;

        List<OrderItem> OrderItemList = new List<OrderItem>();
        blng__BillingRule__c billingrule = [ select Id from blng__BillingRule__c where name = 'Non-Billable Product Rule' limit 1];
        for ( Id pid : prodIdList ) {
            OrderItem theTestOrderItem = new OrderItem(OrderId = theTestOrder.id,
                    Quantity = 1,
                    Product2Id = pid,
                    PricebookEntryId = pricebookMap.get(pid).Id,
                    UnitPrice = pricebookMap.get(pid).UnitPrice,
                    L2I_Sub_Category_2__c = prodCategoryMap.get( pid ),
                    SBQQ__ChargeType__c = 'Recurring',
                    SBQQ__BillingFrequency__c = 'Monthly',
                    SBQQ__BillingType__c = 'Advance',
                    blng__BillingRule__c = billingrule.Id,
                    SBQQ__DefaultSubscriptionTerm__c = 24,
                    SBQQ__Activated__c = false);
            OrderItemList.add( theTestOrderItem );
        }

        insert OrderItemList;

        L2I_Aircraft__c ac = factory.createAircraft( att.Id, 'Test User Name', '2333-11131133114499999988888805', namedCustomer.Id);

        insert ac;
        System.assert( ac.Id != null , 'No aircraft record has been created.');

        Test.startTest();

        List<object> result = L2I_QuoteToOIController.autoCreateAircraftServicesFromQuote( new List<Id>{ quote.Id } );

        Test.stopTest();
    }

    static void updateDSHToSalesOppo( Opportunity oppo, Id DSHheaderID ){

        oppo.L2I_Delivery_Schedule__c = DSHheaderID;
        update oppo;

    }
    */
}