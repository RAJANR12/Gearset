/**
* @File Name          : L2I_CPQUtils_Test.cls
* @Description        : Test Class for CPQ
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@isTest
private class L2I_CPQUtils_Test {
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

    @isTest static void myTest() {
        setupTestContext();
        
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');
        
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;

        //Create Opportunity
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');
        dumpObj(dealOppty,'====== Deal Opportunity');
        
        SBQQ__Quote__c qt=new SBQQ__Quote__c();
        qt.recordtypeId=L2I_StaticConstants.DRAFT_QUOTE_RT_ID;
        qt.SBQQ__Account__c = namedCustomer.id;
        qt.SBQQ__Primary__c = true;
        Insert qt;
        System.debug('*** b4 ' + qt.SBQQ__OrderBy__c);
        qt = [SELECT SBQQ__Account__c, SBQQ__Primary__c, SBQQ__OrderBy__c FROM SBQQ__Quote__c WHERE Id = :qt.Id];
        System.debug('*** after ' + qt.SBQQ__OrderBy__c);
        

        /*Opportunity salesOppty2 = factory.createSalesOpportunityWithAmount('Sales2', 'Open', 30, namedCustomer.Id,
                dealOppty.Id, 200000, 'IFEC');
        salesOppty2.SBQQ__PrimaryQuote__c = qt.id;
        //insert salesOppty2;
        dumpObj(salesOppty2,'====== Sales Opportunity');
        */
        
        
        Opportunity salesOppty=new Opportunity();
        salesOppty.Name='Sales2';
        salesOppty.StageName = 'Open';
        salesOppty.SBQQ__PrimaryQuote__c = qt.id;
        salesOppty.CloseDate = Date.today();
        salesOppty.accountId = namedCustomer.id;
        salesOppty.L2I_Parent_Opportunity__c = dealOppty.id;
        salesOppty.recordtypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID;
        salesOppty.Amount = 200000;
        salesOppty.L2I_Product_Category__c = 'IFEC';
        salesOppty.L2I_Business_Class_Cabin_Configuration__c = 'None; N/A';
        salesOppty.L2I_First_Class_Cabin_Configuration__c = 'None; N/A';
        salesOppty.L2I_Economy_Cabin_Configuration__c = 'None; N/A';
        salesOppty.L2I_Premium_Economy_Cabin_Configuration__c = 'None; N/A';
        salesOppty.L2I_Are_These_Follow_On_Aircraft__c = 'No';
        salesOppty.L2I_Are_These_Partial_Shipsets__c = 'No';
        
        salesOppty.L2I_Cabin_Configuration__c = '1-Class';
        salesOppty.L2I_First_Class_Cabin_Configuration__c = 'In-Seat Audio Only';
        salesOppty.L2I_Business_Class_Cabin_Configuration__c = 'In-Seat Audio Only';
        salesOppty.L2I_Premium_Economy_Cabin_Configuration__c = 'In-Seat Audio Only';
        salesOppty.L2I_Economy_Cabin_Configuration__c = 'In-Seat Audio Only';
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        Insert salesOppty;
       

        List<SBQQ__Quote__c> quotelist2 = [SELECT ID,SBQQ__Opportunity2__c,SBQQ__Account__c FROM  SBQQ__Quote__c WHERE SBQQ__Account__c = :namedCustomer.id ];
        quotelist2[0].SBQQ__Opportunity2__c = salesOppty.id;
        update quotelist2;
        // SBQQ__Quote__c quote = factory.createQuote('draft', namedCustomer.Id, salesOppty.Id, true);
        SBQQ__Quote__c quote = factory.createQuote('draft', namedCustomer.Id, salesOppty.Id, false);
        insert quote;
        dumpObj(quote,'====== Quote');
        System.debug('*** b4 ' + quote.SBQQ__OrderBy__c);
        quote = [SELECT SBQQ__Account__c, SBQQ__Opportunity2__c, L2I_System_Type1__c, L2I_Connectivity_System_Type1__c, SBQQ__Primary__c, SBQQ__OrderBy__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        System.debug('*** after ' + quote.SBQQ__OrderBy__c);


        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();

        Set<Id> productIdSet = new Set<Id>();
        Map<Id, String> prodCategoryMap = new Map<Id, String>();

        List<Product2> prodList = [ select Id, Name, L2I_Sub_Category_2__c, L2I_Service_Activation_Type__c from Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();

        for (Product2 p : prodList) {
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
            //System.debug('====== Product Id :' + p.Id + ' [Name] :' + p.Name + ' [Category] :' + p.L2I_Sub_Category_2__c + ' [SAT] :' + p.L2I_Service_Activation_Type__c);
        }

        Set<String> ProductNameList = new Set<String>();
        //[RR]ProductNameList.add('Connectivity Services - WiFi'); // this product will not work as L2I_Service_Activation_Type__c is null for it
        //ProductNameList.add('Panasonic Wi-Fi - Monthly Data Connection to the Aircraft, Tiered Plan per Aircraft');
        //ProductNameList.add('Whitelist');
        //ProductNameList.add('Operational Data');
        //ProductNameList.add('WiFi Usage');
        //ProductNameList.add('Live Television');
        ProductNameList.add('Panasonic WIFI');
        ProductNameList.add('Panasonic Mobile');
        Set<Id> prodIdList = New Set<Id>();

        for (String s : ProductNameList) {
            Id pid = prodIdMap.get( s );
            prodIdList.add(pid);
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(quote.Id, pid, null);
            quoteLine.SBQQ__Quantity__c = 1;
            System.debug('===>>> quoteLine: '+quoteLine);
            qlList.add(quoteLine);
        }
        insert qlList;

        dumpObj(dealOppty,'====== Deal Opportunity');
        dumpObj(salesOppty,'====== Sales Opportunity');
        dumpObj(quote,'====== Quote');
        dumpObj(qlList,'====== QuoteLines');

        //Got package errors on inserting quotelines as primary, trying to make primary ex post facto
        //update (new SBQQ__Quote__c(Id = quote.Id, SBQQ__Primary__c = true));

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
                                       SBQQ__Quote__c = qt.Id);
        insert theTestOrder;

        List<OrderItem> OrderItemList = new List<OrderItem>();
        blng__BillingRule__c billingrule = [ select Id from blng__BillingRule__c where name = 'Non-Billable Product Rule' limit 1];
        for ( Id pid : prodIdList ) {
            OrderItem theTestOrderItem = new OrderItem(OrderId = theTestOrder.id,
                                                       Quantity = 1,
                                                       Product2Id = pid,
                                                       PricebookEntryId = pricebookMap.get(pid).Id,
                                                       UnitPrice = pricebookMap.get(pid).UnitPrice,
                                                       L2I_Sub_Category_2__c = prodCategoryMap.get(pid),
                                                       L2I_PO_Required__c = true,
                                                       L2I_Frequency__c = 'Monthly (12)',
                                                       SBQQ__ChargeType__c = 'Recurring',
                                                       SBQQ__BillingFrequency__c = 'Monthly',
                                                       SBQQ__BillingType__c = 'Advance',
                                                       blng__BillingRule__c = billingrule.Id,
                                                       SBQQ__DefaultSubscriptionTerm__c = 24,
                                                       EndDate = Date.today().addMonths(24),
                                                       SBQQ__Activated__c = false);
            OrderItemList.add(theTestOrderItem);
        }
        insert OrderItemList;

        Date startDate = Date.today().toStartOfMonth();
        Date endDate = startDate.addMonths(1) - 1;
        List<blng__UsageSummary__c> UsageSummaryList = new List<blng__UsageSummary__c>();
        for (OrderItem oi : OrderItemList) {
            System.debug('==>>>> Order Item :' + oi);
            System.assert(oi.Id != null, 'OrderItem must have an Id');
            blng__UsageSummary__c us = new blng__UsageSummary__c(
                blng__MatchingId__c = oi.Id
                ,blng__Order__c = oi.OrderId
                ,blng__SummaryStartDate__c = startDate
                ,blng__SummaryEndDate__c = endDate
                ,blng__UnitPrice__c = oi.UnitPrice
                ,blng__Status__c = 'New'
                ,blng__Source__c = 'External'
                ,blng__InvoiceRunProcessingStatus__c = 'Pending Billing');
            UsageSummaryList.add(us);
        }
        insert UsageSummaryList;

        List<blng__UsageSummary__c> usList = [SELECT Id, blng__MatchingId__c,blng__Order__c,blng__SummaryStartDate__c,blng__SummaryEndDate__c FROM blng__UsageSummary__c];
        for (blng__UsageSummary__c myUs: usList){
            System.debug('==>>>> Usage Summary: ' + myUs);
        }
        
        
        L2I_CustomModelUtils c = new L2I_CustomModelUtils();
        //set<account> myset = new set<account>([select id from account limit 100]);
        //List<String> lStrings = new List<String>{'a','b','c','d','e'};
        //Set<String> sStrings = new Set<String>(OrderItemList);
        //List<OrderItem> lStrings = new List<OrderItem>{'a','b','c','d','e'};
        //Set<OrderItem> sStrings = new Set<OrderItem>(OrderItemList);
        List<Id> lStrings = new List<Id>{qt.Id};
        Set<Id> sStrings = new Set<Id>(lStrings);
            L2I_CustomModelUtils.getSourceOrderItems(lStrings);
            L2I_CustomModelUtils.usageRecord(qt.Id, System.now(), System.now(), 123, 123, 'String notes');
        L2I_CustomModelUtils.parseRateScheduleJson(OrderItemList[0]);
        L2I_CustomModelUtils.buildUsageSummary(OrderItemList[0], system.today(), system.today(), 123);
        //L2I_OrderData od = new L2I_OrderData();
        //L2I_OrderData.L2I_OrderData(qt.Id, system.today(), system.today());
        L2I_OrderData.getAllOrders();
        //L2I_OrderData.getAffectedOrders();
        L2I_OrderData.getAffectedOrderIds();
        //wasjustL2I_OrderData.parseJSONmodels(OrderItemList); 
        //L2I_OrderData.L2I_OrderData s = new L2I_OrderData.L2I_OrderData(qt.Id, system.today(), system.today());
        //L2I_OrderData.getMapKey();
        //L2I_OrderData.processWiFiUsage(qt.Id, qt.Id);
        //wasjustL2I_OrderData.insertNewRecords();
        //wasjustL2I_OrderData.updateSObjects();
            L2I_OrderData.executeUpdates();
        //wasjustL2I_OrderData.sourceOrderItemIds=sStrings;
        List<blng__UsageSummary__c> l2Strings = new List<blng__UsageSummary__c>{};
            List<blng__Usage__c> l22Strings = new List<blng__Usage__c>{};
        L2I_OrderData.usageSummaries=l2Strings;
            L2I_OrderData.trueUpUsages=l22Strings;
        
        L2I_OrderData o = new L2I_OrderData(theTestOrder.id, system.today(), system.today());
        
        
        L2I_OrderData.processJSONmodels();
        o.getMapKey();
        o.getEndDatetime();
        o.isLegacyGB();
        o.isCustomModel();
        o.includedUsageQuantity();
        o.includedUsageAmount();
        //o.createLegacyGBcredit();
        
        //L2I_PrecisionTailCountUsage.affectedOrder(theTestOrder.id,'asdf');
        //L2I_OrderData.shadowOrderItems();
        //L2I_OrderUsageData planeCountUsage;
        //L2I_OrderData.findOrderData(L2I_OrderUsageData);
        //o.createLegacyGBcredit();
        //o.totalBandwithInMB();
        //o.totalBandwithInGB();
        //o.averageGBperTail();
        //L2I_OrderData.L2I_OrderData fieldSetMemberWrapper = new L2I_OrderData.L2I_OrderData(theTestOrder.id, system.today(), system.today());

        //L2I_OrderData(theTestOrder.id, system.today(), system.today());
        //
        //
        
        ///factory.setupAccountThruContract(products,pbeList,false);
        //setupTestContext

        SBQQ__QuoteLine__c quoteLine2 = [
            SELECT SBQQ__Product__c, SBQQ__Quote__c,SBQQ__PricebookEntryId__c,SBQQ__PricingMethod__c,SBQQ__StartDate__c,SBQQ__ListPrice__c,
            SBQQ__Quantity__c,SBQQ__PriorQuantity__c,SBQQ__RegularPrice__c,SBQQ__NetPrice__c,SBQQ__Number__c,SBQQ__ProrateMultiplier__c,SBQQ__SubscriptionPricing__c,
            SBQQ__SubscriptionScope__c,SBQQ__DefaultSubscriptionTerm__c,SBQQ__ChargeType__c,SBQQ__BillingType__c,SBQQ__BillingFrequency__c
            FROM SBQQ__QuoteLine__c LIMIT 1
        ];
        quoteLine2.Id = null;
        system.debug('nick quoteLine.Id'+quoteLine2.Id);
        system.debug('nick2 quoteLine '+quoteLine2);
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>{quoteLine2};
        String jsonString = JSON.serialize(quoteLines);        
    
        // As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/QuoteLine/'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
    
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
            List<SBQQ__QuoteLine__c> newQuoteLines = L2I_QcpPluginExtendor.updateQuoteLines();//HttpClass.updateCustomObject();
        Test.stopTest();
    }
}