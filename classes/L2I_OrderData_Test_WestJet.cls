/**
 *      @author       Dan Morris
 *      @date         12/29/2020
 *      @description  Test class for Custom Billing Models
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Dan Morris                    12/29/2020         Initial setup of tests - shamelessly stolen
 *
 */

@isTest(SeeAllData=false)
public with sharing class L2I_OrderData_Test_WestJet {

    private static Boolean DEBUG = false;
    private static final String sampleTierConfig = '[{"attributes":{"type":"L2I_Custom_Model__mdt","url":"/services/data/v50.0/sobjects/L2I_Custom_Model__mdt/m05000000005108732"},"L2I_Per_Unit_Price__c":0.4300,"L2I_Product_Id__c":"01t21000003Nw8nAAC","L2I_Parent__c":"a0q21000004Mg86AAC","L2I_Upper_Bound__c":30000,"L2I_Lower_Bound__c":1,"Id":"m05000000005108732"},{"attributes":{"type":"L2I_Custom_Model__mdt","url":"/services/data/v50.0/sobjects/L2I_Custom_Model__mdt/m05000000009309483"},"L2I_Per_Unit_Price__c":0.4000,"L2I_Product_Id__c":"01t21000003Nw8nAAC","L2I_Parent__c":"a0q21000004Mg86AAC","L2I_Upper_Bound__c":50000,"L2I_Lower_Bound__c":30001,"Id":"m05000000009309483"},{"attributes":{"type":"L2I_Custom_Model__mdt","url":"/services/data/v50.0/sobjects/L2I_Custom_Model__mdt/m05000000002284317"},"L2I_Per_Unit_Price__c":0.3800,"L2I_Product_Id__c":"01t21000003Nw8nAAC","L2I_Parent__c":"a0q21000004Mg86AAC","L2I_Upper_Bound__c":75000,"L2I_Lower_Bound__c":50001,"Id":"m05000000002284317"},{"attributes":{"type":"L2I_Custom_Model__mdt","url":"/services/data/v50.0/sobjects/L2I_Custom_Model__mdt/m05000000008720114"},"L2I_Per_Unit_Price__c":0.3600,"L2I_Product_Id__c":"01t21000003Nw8nAAC","L2I_Parent__c":"a0q21000004Mg86AAC","L2I_Upper_Bound__c":100000,"L2I_Lower_Bound__c":75001,"Id":"m05000000008720114"},{"attributes":{"type":"L2I_Custom_Model__mdt","url":"/services/data/v50.0/sobjects/L2I_Custom_Model__mdt/m05000000003697725"},"L2I_Per_Unit_Price__c":0.3300,"L2I_Product_Id__c":"01t21000003Nw8nAAC","L2I_Parent__c":"a0q21000004Mg86AAC","L2I_Upper_Bound__c":null,"L2I_Lower_Bound__c":100001,"Id":"m05000000003697725"}]';
    private static final Decimal actualQuantity = 123456;

    private static L2I_DataFactory factory;
    private static List<SObject> products;
    private static Map<Id,Product2> ProductMap;
    private static Map<String, Id> ProductCodeMap;
    private static Map<Id, PricebookEntry> pricebookMap;
    private static Id BillingRuleId;
    private static Id BillingTreatmentId;
    private static Id BillingGLRuleId;
    private static Id BillingGLTreatmentId;

    private static List<PricebookEntry> pbEntries;

    static void setupTestContext() {
        factory = new L2I_DataFactory();

        List<SObject> blng_GLRules = Test.loadData(blng__GLRule__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('GLRule_file'));
        BillingGLRuleId = blng_GLRules[0].Id;

        List<SObject> blng_LegalEntities = Test.loadData(blng__LegalEntity__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('LegalEntity_file'));

        List<SObject> blng_financeBooks = Test.loadData(blng__FinanceBook__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('FinanceBook_file'));

        List<SObject> blng_billingRules = Test.loadData(blng__BillingRule__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('BillingRule_file'));
        BillingRuleId = [SELECT Id FROM blng__BillingRule__c WHERE name = 'Billable Product Rule' LIMIT 1].Id;

        List<SObject> blng_taxRules = Test.loadData(blng__TaxRule__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('TaxRule_file'));

        List<SObject> blng_revrecRules = Test.loadData(blng__RevenueRecognitionRule__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('RevenueRecognitionRule_file'));

        List<SObject> blng_GLAccounts = Test.loadData(blng__GLAccount__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('GLAccount_file'));

        List<SObject> blng_GLTreatments = Test.loadData(blng__GLTreatment__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('GLTreatment_file'));
        BillingGLTreatmentId = blng_GLTreatments[0].Id;

        List<SObject> blng_billingTreatments = Test.loadData(blng__BillingTreatment__c.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('BillingTreatment_file'));
        BillingTreatmentId = blng_billingTreatments[0].Id;

        products = Test.loadData(Product2.sObjectType,
                L2I_StaticConstants.unitTestStaticResource.get('Product2_file'));
        ProductMap = new Map<Id,Product2>((List<Product2>)products);
        ProductCodeMap = new Map<String, Id>();
        for (Product2 p : (List<Product2>)products) {
            ProductCodeMap.put(p.ProductCode, p.Id);
        }

        pbEntries = new List<PricebookEntry>();
        for (SObject prod : products) {
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                                    Product2Id = prod.Id,
                                                    UnitPrice = 1000,
                                                    IsActive = true);
            pbEntries.add(pbe);
        }
        insert pbEntries;
        pricebookMap = new Map<Id,PricebookEntry>();
        for (PricebookEntry pbe : pbEntries ){
            pricebookMap.put( pbe.Product2Id, pbe );
        }
    }

    static SBQQ__PriceSchedule__c createPriceSchedule(String name, Id orderId, String matchingId) {
        return new SBQQ__PriceSchedule__c(
            Name = name
            ,SBQQ__PriceType__c = 'Volume'
            ,SBQQ__DiscountUnit__c = 'Percent'
            ,SBQQ__Order__c = orderId
            ,L2I_External_Id__c = matchingId 
        );
    }

    static SBQQ__PriceTier__c createPriceTier(String name, Decimal price) {
        return new SBQQ__PriceTier__c(
            Name = name
            ,SBQQ__Number__c = 0
            ,SBQQ__PriceModel__c = 'Per Unit'
            ,SBQQ__LowerBound__c = 1
            ,SBQQ__Price__c = price        );
    }

    static Order createOrder(Id accountId, Id opportunityId, Id quoteId) {
        return new Order(
            AccountId = accountId
            ,PoNumber= 'Test'
            ,EffectiveDate = Date.today()-60
            ,Status='Draft'
            ,Pricebook2Id=Test.getStandardPricebookId()
            ,blng__BillingDayOfMonth__c = '1'
            ,OpportunityId = opportunityId
            ,SBQQ__PriceCalcStatus__c = 'Completed'
            ,SBQQ__Quote__c = quoteId
        );
    }

    static OrderItem createOrderItem(Id orderId, SBQQ__QuoteLine__c ql, Decimal unitPrice) {
        OrderItem oi = new OrderItem(
            OrderId = orderId
            ,Quantity = ql.SBQQ__Quantity__c
            ,Product2Id = ql.SBQQ__Product__c
            ,PricebookEntryId = (Id) ql.SBQQ__PricebookEntryId__c
            ,UnitPrice = unitPrice
            ,L2I_Model_Type__c = ''
            ,L2I_blng_MatchingId__c = ql.Id
            ,L2I_IncludedUsage__c = ql.L2I_IncludedUsage__c
            ,L2I_Megabyte_Definition__c = ql.L2I_Megabyte_Definition__c
            ,L2I_Sub_Category_1__c = ql.L2I_Sub_Category_1__c
            ,L2I_Sub_Category_2__c = ql.L2I_Sub_Category_2__c
            ,L2I_PO_Required__c = false
            ,L2I_Frequency__c = 'Monthly (12)'
            ,SBQQ__ChargeType__c = ql.SBQQ__ChargeType__c
            ,SBQQ__BillingFrequency__c = 'Monthly'
            ,SBQQ__DefaultSubscriptionTerm__c = 24
            ,SBQQ__QuoteLine__c = ql.Id
            ,EndDate = Date.today().addMonths(24)
            ,SBQQ__Activated__c = false
            ,blng__BillingRule__c = BillingRuleId
            ,blng__BillingTreatment__c = BillingTreatmentId
            ,blng__BillingGLRule__c = BillingGLRuleId
            ,blng__BillingGLTreatment__c = BillingGLTreatmentId
        );
        if (ql.SBQQ__ChargeType__c != 'One-Time' && ql.SBQQ__ChargeType__c != 'Usage')
            oi.SBQQ__BillingType__c = ql.SBQQ__BillingType__c;
        if (ql.L2I_Product_Code__c == 'PA-CPSTPAC-YYYY')
            oi.L2I_Model_Type__c = 'Average GB per Tail with Overage';
        if (ql.L2I_Product_Code__c == 'PA-CPSPERCAL-YYYY') {
            oi.L2I_Rate_Schedule_JSON__c = sampleTierConfig;
            oi.L2I_Has_Rate_Schedule__c = true;
        }
        return oi;
    }

    static SBQQ__QuoteLine__c createQuoteLine(Id quoteId, Id productId) {
        Product2 p = ProductMap.get(productId);
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quoteId
            ,SBQQ__Product__c = productId
            ,SBQQ__PricebookEntryId__c = (String)pricebookMap.get(productId).Id
            ,L2I_Product_Code__c = p.ProductCode
            ,SBQQ__ChargeType__c = p.SBQQ__ChargeType__c
            ,L2I_Sub_Category_1__c = p.L2I_Sub_Category_1__c
            ,L2I_Sub_Category_2__c = p.L2I_Sub_Category_2__c
            ,SBQQ__Quantity__c = 1
            ,L2I_Megabyte_Definition__c = '1000'
        );
        if (ql.L2I_Product_Code__c == 'PA-CPSPERCAL-YYYY') {
            ql.L2I_Rate_Schedule_JSON__c = sampleTierConfig;
            ql.L2I_Has_Rate_Schedule__c = true;
        }
        return ql;
    }

    static blng__UsageSummary__c createUsageSummary(OrderItem oi, Date startDate, Date endDate) {
        blng__UsageSummary__c us = new blng__UsageSummary__c(
            blng__MatchingId__c = oi.L2I_blng_MatchingId__c
            ,blng__Order__c = oi.OrderId
            ,blng__OrderProduct__c = oi.Id
            ,blng__SummaryStartDate__c = startDate
            ,blng__SummaryEndDate__c = endDate
            ,blng__UnitPrice__c = oi.UnitPrice
            ,blng__Status__c = 'New'
            ,blng__Source__c = 'External'
            ,blng__InvoiceRunProcessingStatus__c = 'Pending Billing'
        );
        return us;
    }

    static blng__Usage__c createUsage(blng__UsageSummary__c myUs, DateTime endDateTime, Boolean drift) {
        Decimal quantity = drift ? actualQuantity * .17 : actualQuantity;
        blng__Usage__c usage = new blng__Usage__c(
            blng__MatchingId__c = myUs.blng__MatchingId__c
            ,blng__Quantity__c = quantity
            ,L2I_Actual_Quantity__c = actualQuantity
            ,blng__StartDateTime__c = endDateTime
            ,blng__EndDateTime__c = endDateTime
            ,blng__UsageSummary__c = myUs.Id
            ,blng__Status__c = 'Processed'
        );
        return usage;
    }

    static List<SObject> getAllFields(SObject sobj) {
        if (!DEBUG){return new List<SObject>{sobj};}
        System.debug('getAllFields query object: '+sobj.Id);
        String apos = '\'';
        if (sobj == null || sobj.Id == null) return null;
        DescribeSObjectResult describeResult = sobj.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        String query = ' SELECT ' +String.join(fieldNames,',') 
        +' FROM ' +describeResult.getName() 
        +' WHERE id = '+apos+sobj.Id+apos+'  LIMIT 1 ';
        //System.debug(query);
        List<SObject> records = Database.query( query );
        return records;
    }

    static void dumpObj(SObject sobj, String msg) {
        for (SObject thisObj: getAllFields(sobj)) {
            System.debug('Dumping Object '+msg);
            System.debug(JSON.serialize(thisObj,true));
        }
    }
    static void dumpObj(List<SObject> sobj, String msg) {
        for (SObject thisObj: sobj) {
            dumpObj(thisObj,msg);
        }
    }

    @IsTest
    static void test_westjet_usage() {
        setupTestContext();

        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

        //Create Opportunity
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');

        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
                dealOppty.Id, 200000, 'DSS');
        insert salesOppty;

        SBQQ__Quote__c quote = factory.createQuote('draft', namedCustomer.Id, salesOppty.Id, false);
        quote.SBQQ__Pricebook__c = quote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
        insert quote;
        //Got package errors on inserting quotelines as primary, trying to make primary ex post facto
        update (new SBQQ__Quote__c(Id = quote.Id, SBQQ__Primary__c = true));

        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        Set<String> ProductCodeList = new Set<String>();
        ProductCodeList.add('PA-CPSPERCAL-YYYY');     // WestJet
        ProductCodeList.add('PA-WIFIUSG-YYYY');       // WiFi
        ProductCodeList.add('PA-COPSPHASE1');         // Ops Data - shadow Product
        ProductCodeList.add('PA-COPSPAXWHTLST-YYYY'); // WhiteList 

        Set<Id> prodIdList = New Set<Id>();

        for (String s : ProductCodeList) {
            Id pid = ProductCodeMap.get( s );
            prodIdList.add(pid);
            SBQQ__QuoteLine__c quoteLine = createQuoteLine(quote.Id, pid);
            System.debug('===>>> quoteLine: '+quoteLine);
            qlList.add(quoteLine);
        }
        insert qlList;

        //dumpObj(dealOppty,'====== Deal Opportunity');
        //dumpObj(salesOppty,'====== Sales Opportunity');
        //dumpObj(quote,'====== Quote');
        dumpObj(qlList,'====== QuoteLines');

        Order theTestOrder = createOrder(namedCustomer.Id, salesOppty.Id, quote.Id);
        insert theTestOrder;
        List<OrderItem> OrderItemList = new List<OrderItem>();
        List<SBQQ__PriceTier__c> PriceTierList = new List<SBQQ__PriceTier__c>();
        List<SBQQ__PriceSchedule__c> PriceScheduleList = new List<SBQQ__PriceSchedule__c>();
        for ( SBQQ__QuoteLine__c ql : qlList ) {
            Decimal unitPrice = pricebookMap.get(ql.SBQQ__Product__c).UnitPrice;
            SBQQ__PriceTier__c pt = createPriceTier(ql.Id, unitPrice);
            OrderItem oi = createOrderItem(theTestOrder.id, ql, unitPrice);

            // Price Schedule reference object for OrderItem and Price Tier
            oi.SBQQ__PriceSchedule__r =  pt.SBQQ__PriceSchedule__r = new SBQQ__PriceSchedule__c(L2I_External_Id__c = oi.L2I_blng_MatchingId__c);
            SBQQ__PriceSchedule__c ps = createPriceSchedule(ql.Id, oi.OrderId, oi.L2I_blng_MatchingId__c);
            PriceScheduleList.add(ps);
            OrderItemList.add(oi);
            PriceTierList.add(pt);
        }
        List<SObject> orderItemInsertList = new List<SObject>();
        orderItemInsertList.addAll(PriceScheduleList);
        orderItemInsertList.addAll(OrderItemList);
        orderItemInsertList.addAll(PriceTierList);
        insert orderItemInsertList;
        dumpObj(orderItemInsertList, '====== Order Items Objects');
        
        Order activatedOrder = new Order(Id = theTestOrder.Id, Status = 'Activated');
        update activatedOrder;
        dumpObj(activatedOrder,'====== Activated Order');

        Date startDate = Date.today().toStartOfMonth();
        Date endDate = startDate.addMonths(1) - 1;
        List<blng__UsageSummary__c> UsageSummaryList = new List<blng__UsageSummary__c>();
        Map<String,Boolean> orderItemDrift = new Map<String,Boolean>();
        for (OrderItem oi : OrderItemList) {
            if (oi.SBQQ__ChargeType__c != 'Usage') continue;
            System.assert(oi.Id != null, 'OrderItem must have an Id' + oi);
            orderItemDrift.put(oi.L2I_blng_MatchingId__c, oi.L2I_Service_Activation_Type__c == 'Monthly'|| oi.L2I_Service_Activation_Type__c == 'Yearly'|| oi.L2I_Service_Activation_Type__c == 'OneTime');
            UsageSummaryList.add(createUsageSummary(oi, startDate, endDate));
        }
        insert UsageSummaryList;
        dumpObj(UsageSummaryList,'====== Usage Summaries');

        List<blng__Usage__c> usages = new List<blng__Usage__c>();
        List<blng__UsageSummary__c> usList = [SELECT Id, blng__MatchingId__c,blng__Order__c,blng__SummaryStartDate__c,blng__SummaryEndDate__c FROM blng__UsageSummary__c];
        for (blng__UsageSummary__c myUs: usList){
            Datetime endDateTime = DateTime.newInstance(myUs.blng__SummaryEndDate__c.year(), myUs.blng__SummaryEndDate__c.month(), myUs.blng__SummaryEndDate__c.day());
            blng__Usage__c thisUsage = createUsage(myUs, endDateTime, orderItemDrift.get(myUs.blng__MatchingId__c));
            usages.add(thisUsage);
        }
        insert usages;
        dumpObj(usages,'====== Usages');

        // We start the test to get a new set of Governor limits as upto this point in the
        // test method is all about setting up the data.
        Test.startTest();

        System.debug('Executing Test');
        Date targetDate = endDate.addDays(15);
        L2I_PrecisionTailCountUtils.queueErrorMessage('No errors!');
        L2I_PrecisionTailCountUtils myObj = new L2I_PrecisionTailCountUtils();
        myObj = new L2I_PrecisionTailCountUtils(targetDate,'fred');
        myObj = new L2I_PrecisionTailCountUtils(targetDate);
        myObj = new L2I_PrecisionTailCountUtils(targetDate,true);
        myObj.execute();
        System.Debug('====== Order Usage Data:');
        System.Debug(myObj.getOrderDataAsJson());
        List<Id> affectedOrderIds = new List<Id>(L2I_OrderData.getAffectedOrderIds());
        Id firstOrderId = affectedOrderIds[0];
        Order firstOrder = L2I_OrderData.getSourceOrder(firstOrderId);
        Integer OrderMapSize = L2I_OrderData.getAffectedOrderIds().size();
        L2I_OrderData.deleteAffectedOrderId(firstOrderId);
        System.assert(L2I_OrderData.getAffectedOrderIds().size() < OrderMapSize);

        // Stopping the test will run the job synchronously
        Test.stopTest();
    }


}