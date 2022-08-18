/**
 *      @author       Dan Morris
 *      @date         05/29/2020
 *      @description  Test class for Custom Billing Models
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Dan Morris                    05/29/2020         Initial setup of tests - shamelessly stolen
 *
 */

@isTest(SeeAllData=false)
public with sharing class L2I_OrderData_Testv2 {


    private static L2I_DataFactory factory;
    private static List<SObject> products;
    private static Map<Id,Product2> ProductMap;
    private static Map<String, Id> ProductCodeMap;
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

        // the following is a time-consuming load. Turn it on only if it is needed. In all likelihood, this is needed
        // for Invoice runs, which is not in scope for the set of tests in this UnitTest class
        //List<SObject> blng_financePeriods = Test.loadData(blng__FinancePeriod__c.sObjectType,
        //       L2I_StaticConstants.unitTestStaticResource.get('FinancePeriod_file'));

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
    }

    static SBQQ__QuoteLine__c createQuoteLine(Id quoteId, Id productId) {
        Product2 p = ProductMap.get(productId);
        return new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quoteId
            ,SBQQ__Product__c = productId
            ,SBQQ__ChargeType__c = p.SBQQ__ChargeType__c
            ,L2I_Sub_Category_1__c = p.L2I_Sub_Category_1__c
            ,L2I_Sub_Category_2__c = p.L2I_Sub_Category_2__c
            ,L2I_Sub_Category3__c = p.L2I_Sub_Category3__c
            ,SBQQ__Quantity__c = 1
            ,L2I_Megabyte_Definition__c = '1000'
        );
    }

    static List<SObject> getAllFields(SObject sobj) {
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
    static void test_tail_count_usage() {
        setupTestContext();

        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

        //Create Opportunity
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');
        dumpObj(dealOppty,'====== Deal Opportunity');

        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
                dealOppty.Id, 200000, 'DSS');
        insert salesOppty;
        dumpObj(salesOppty,'====== Sales Opportunity');


//        SBQQ__Quote__c quote = factory.createQuote('draft', namedCustomer.Id, salesOppty.Id, true);
        SBQQ__Quote__c quote = factory.createQuote('draft', namedCustomer.Id, salesOppty.Id, false);
        insert quote;

        //Got package errors on inserting quotelines as primary, trying to make primary ex post facto
        update (new SBQQ__Quote__c(Id = quote.Id, SBQQ__Primary__c = true));

        dumpObj(quote,'====== Quote');


        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();


        Set<String> ProductCodeList = new Set<String>();
        ProductCodeList.add('PA-CPSTPAC-YYYY'); // Tiered GB
        // ProductCodeList.add('PA-WIFIUSG-YYYY'); // WiFi
//        ProductCodeList.add('PA-COPSPHASE1'); //Ops Data 

        Set<Id> prodIdList = New Set<Id>();

        for (String s : ProductCodeList) {
            Id pid = ProductCodeMap.get( s );
            prodIdList.add(pid);
            SBQQ__QuoteLine__c quoteLine = createQuoteLine(quote.Id, pid);
            System.debug('===>>> quoteLine: '+quoteLine);
            qlList.add(quoteLine);
            insert quoteLine;
        }
        // insert qlList;

        dumpObj(dealOppty,'====== Deal Opportunity');
        dumpObj(salesOppty,'====== Sales Opportunity');
        dumpObj(quote,'====== Quote');
        dumpObj(qlList,'====== QuoteLines');




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

        Order theTestOrder = new Order(
            AccountId = namedCustomer.Id
            ,PoNumber= 'Test'
            ,EffectiveDate = Date.today()-60
            ,Status='Draft'
            ,Pricebook2Id=Test.getStandardPricebookId()
            ,blng__BillingDayOfMonth__c = '1'
            ,OpportunityId = salesOppty.Id
            ,SBQQ__PriceCalcStatus__c = 'Completed'
            ,SBQQ__Quote__c = quote.Id
        );
        insert theTestOrder;

        List<OrderItem> OrderItemList = new List<OrderItem>();
        List<SBQQ__PriceTier__c> PriceTierList = new List<SBQQ__PriceTier__c>();
        List<SBQQ__PriceSchedule__c> PriceScheduleList = new List<SBQQ__PriceSchedule__c>();
        for ( SBQQ__QuoteLine__c ql : qlList ) {
            String tierName = ql.Id;
            Id pid = ql.SBQQ__Product__c;
            SBQQ__PriceTier__c pt = new SBQQ__PriceTier__c(
                Name = tierName
                ,SBQQ__Number__c = 0
                ,SBQQ__PriceModel__c = 'Per Unit'
                ,SBQQ__LowerBound__c = 1
                ,SBQQ__Price__c = pricebookMap.get(pid).UnitPrice
            );
            OrderItem oi = new OrderItem(
                OrderId = theTestOrder.id
                ,Quantity = ql.SBQQ__Quantity__c
                ,Product2Id = pid
                ,PricebookEntryId = pricebookMap.get(pid).Id
                ,UnitPrice = pricebookMap.get(pid).UnitPrice
                ,L2I_blng_MatchingId__c = ql.Id
                ,L2I_IncludedUsage__c = ql.L2I_IncludedUsage__c
                ,L2I_Megabyte_Definition__c = ql.L2I_Megabyte_Definition__c
                ,L2I_Sub_Category_1__c = ql.L2I_Sub_Category_1__c
                ,L2I_Sub_Category_2__c = ql.L2I_Sub_Category_2__c
                ,L2I_Sub_Category3__c = ql.L2I_Sub_Category3__c
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
            if (ql.SBQQ__ChargeType__c != 'One-Time' && ql.SBQQ__ChargeType__c != 'Usage') { oi.SBQQ__BillingType__c = ql.SBQQ__BillingType__c; }
            // Price Schedule reference object for OrderItem and Price Tier
            //oi.SBQQ__PriceSchedule__r =  pt.SBQQ__PriceSchedule__r = new SBQQ__PriceSchedule__c(L2I_External_Id__c = oi.L2I_blng_MatchingId__c);
            SBQQ__PriceSchedule__c ps = new SBQQ__PriceSchedule__c(
                Name = tierName
                ,SBQQ__PriceType__c = 'Volume'
                ,SBQQ__DiscountUnit__c = 'Percent'
                ,SBQQ__Order__c = oi.OrderId
                ,L2I_External_Id__c = oi.L2I_blng_MatchingId__c 
            );
            insert ps;
            oi.SBQQ__PriceSchedule__c =  pt.SBQQ__PriceSchedule__c = ps.Id;
            insert oi;
            insert pt;

            PriceScheduleList.add(ps);
            OrderItemList.add(oi);
            PriceTierList.add(pt);
        }
        // insert PriceScheduleList;
        dumpObj(PriceScheduleList,'====== Price Schedules');
        // insert OrderItemList;
        dumpObj(OrderItemList,'====== Order Items');
        // insert PriceTierList;
        dumpObj(PriceTierList,'====== PriceTiers');

        Order activatedOrder = new Order(Id = theTestOrder.Id, Status = 'Activated');
        update activatedOrder;
        dumpObj(activatedOrder,'====== Activated Order');

        Date startDate = Date.today().toStartOfMonth();
        Date endDate = startDate.addMonths(1) - 1;
        List<blng__UsageSummary__c> UsageSummaryList = new List<blng__UsageSummary__c>();
        for (OrderItem oi : OrderItemList) {
            System.debug('==>>>> Order Item :' + oi);
            System.assert(oi.Id != null, 'OrderItem must have an Id');
            blng__UsageSummary__c us = new blng__UsageSummary__c(
                blng__MatchingId__c = oi.L2I_blng_MatchingId__c
                ,blng__Order__c = oi.OrderId
                ,blng__OrderProduct__c = oi.Id
                ,blng__SummaryStartDate__c = startDate
                ,blng__SummaryEndDate__c = endDate
                ,blng__UnitPrice__c = oi.UnitPrice
                ,blng__Status__c = 'New'
                ,blng__Source__c = 'External'
                ,blng__InvoiceRunProcessingStatus__c = 'Pending Billing');
            System.debug('==>>>> Usage Summary: ' + us);
            UsageSummaryList.add(us);
        }
        insert UsageSummaryList;
        dumpObj(UsageSummaryList,'====== Usage Summaries');

        List<blng__Usage__c> usages = new List<blng__Usage__c>();
        List<blng__UsageSummary__c> usList = [SELECT Id, blng__MatchingId__c,blng__Order__c,blng__SummaryStartDate__c,blng__SummaryEndDate__c FROM blng__UsageSummary__c];
        for (blng__UsageSummary__c myUs: usList){
            Datetime endDateTime = DateTime.newInstance(myUs.blng__SummaryEndDate__c.year(), myUs.blng__SummaryEndDate__c.month(), myUs.blng__SummaryEndDate__c.day());
            blng__Usage__c thisUsage = new blng__Usage__c(
                blng__MatchingId__c = myUs.blng__MatchingId__c
                ,blng__Quantity__c = 12456 - (12456*.17)
                ,L2I_Actual_Quantity__c = 12456
                ,blng__StartDateTime__c = endDateTime
                ,blng__EndDateTime__c = endDateTime
                ,blng__UsageSummary__c = myUs.Id
                ,blng__Status__c = 'Processed'
            );
            System.debug('==>>>> Usage: ' + thisUsage);
            usages.add(thisUsage);
        }
        insert usages;
        dumpObj(usages,'====== Usages');

        // We start the test to get a new set of Governor limits as upto this point in the
        // test method is all about setting up the data.
        Test.startTest();

        System.debug('Executing Test');
        Date targetDate = endDate.addDays(15);
        L2I_PrecisionTailCountUtils myObj = new L2I_PrecisionTailCountUtils(targetDate,true);
        List<AggregateResult> ars = myObj.productUsageList();
        System.assert(ars.size() > 0);
        System.debug('Query size: '+ars.size());
        for (AggregateResult usageSummary : ars) {
            System.debug('Aggregate result: '+JSON.serialize(usageSummary, true));
            L2I_OrderUsageData us = L2I_OrderUsageData.parse(usageSummary);
            System.assert(String.isNotBlank(us.mapKey));
            System.debug('Good mapkey: '+us.mapKey);
            myObj.processUsage(us);
            System.assert(L2I_OrderData.orderMap.size() > 0);
            L2I_OrderData.findOrderData(us);
                    L2I_OrderData o = new L2I_OrderData(theTestOrder.id, system.today(), system.today());
			o.setWiFi(us,true);
        }

        // Stopping the test will run the job synchronously
        Test.stopTest();
    }

/**
 * 
 
     private L2I_OrderUsageData(AggregateResult ar) {
        orderId		        	= (Id) ar.get('blng__Order__c');
        orderItemId	        	= (Id) ar.get('blng__OrderProduct__c');
        usageSummaryId      	= (Id) ar.get('blng__UsageSummary__c');
        holdBilling           	= (String) ar.get('blng__HoldBilling__c');
        summaryStartDate    	= (Date) ar.get('blng__SummaryStartDate__c');
        summaryEndDate      	= (Date) ar.get('blng__SummaryEndDate__c');
        matchingId	        	= (String) ar.get('blng__MatchingId__c');
        hasRateSchedule     	= (Boolean) ar.get('L2I_Has_Rate_Schedule__c');
        productCode	    	    = (String) ar.get('productCode');
        includedUsagePerTail	= (Double) (ar.get('includedUsage'));
        unitPrice		    	= (Double) ar.get('unitPrice');
        subTotal		    	= (Double) ar.get('subTotal');
        quantity			    = (Double) ar.get('totalQuantity');
        actualQuantity       	= (Double) ar.get('totalActualQuantity');
        bandwidthMultiplier 	= Double.valueOf(ar.get('L2I_Megabyte_Definition__c'));
        mapKey                  = mapKey();
    }



 */

}