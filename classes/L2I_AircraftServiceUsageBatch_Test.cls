@isTest(SeeAllData=false)
public class L2I_AircraftServiceUsageBatch_Test {
    
    private static L2I_DataFactory factory;
    private static List<SObject> products;
    private static List<PricebookEntry> pbEntries;
    
    static void setupTestContext() {
        
        factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
    
        L2I_Usage_Batch_Setting__c batchSetting = new L2I_Usage_Batch_Setting__c(
              Name='Default',
              Batch_Run_Date__c = Date.today()-1
        );
        insert batchSetting;
    
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
    
        SBQQ__Quote__c quote = factory.createQuote('draft', namedCustomer.Id, salesOppty.Id, true);
        insert quote;
    
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
    
        Set<Id> productIdSet = new Set<Id>();
        Map<Id, String> prodCategoryMap = new Map<Id, String>();
    
        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c from Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();
        List<Product2> updateProdList = new List<Product2>();
    
        for (Product2 p : prodList) {
            p.L2I_Migrate__c = true;
            p.SBQQ__ChargeType__c = 'Usage';
            p.SBQQ__BillingType__c = '';
            p.L2I_Service_Activation_Type__c = 'Monthly';
            updateProdList.add(p);
            prodIdMap.put( p.Name, p.Id );
            prodCategoryMap.put( p.Id, p.L2I_Sub_Category_2__c );
        }
    
        update updateProdList;
    
        Set<String> ProductNameList = new Set<String>();
    
        ProductNameList.add('Toca Boca - Toca Cars');
        Set<Id> prodIdList = New Set<Id>();
    
        for (String s : ProductNameList) {
            Id pid = prodIdMap.get( s );
            prodIdList.add( pid );
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine( quote.Id, pid, null );
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.SBQQ__SpecialPrice__c = 5;
            qlList.add(quoteLine);
        }
        insert qlList;
    
        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);
    
        insert att;
    
        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule( namedCustomer.Id, att.Id );
    
        insert dsHeaderlList;
    
        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine( dsHeaderlList.Id );
    
        insert dsLineList;
    
        //updateDSHToSalesOppo(salesOppty, dsHeaderlList.Id);
    
        List<PricebookEntry> pbeList = [SELECT Id,
              Product2Id,
              Pricebook2Id,
              UnitPrice,
              IsActive
        FROM PricebookEntry
        WHERE Product2Id in: prodIdList];
    
        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : pbeList ){
            pricebookMap.put( pbe.Product2Id, pbe );
        }
    
        Order theTestOrder = new Order(AccountId = namedCustomer.Id,
              PoNumber= 'Test',
              EffectiveDate = Date.today()-2,
              Status='Draft',
              Pricebook2Id=Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOppty.Id,
              SBQQ__Quote__c = quote.Id,
              L2I_Delivery_Schedule__c = dsHeaderlList.Id);
        insert theTestOrder;
    
        List<OrderItem> OrderItemList = new List<OrderItem>();
        blng__BillingRule__c billingrule = [SELECT Id FROM blng__BillingRule__c WHERE name = 'Non-Billable Product Rule' limit 1];
        for (Id pid : prodIdList) {
            OrderItem theTestOrderItem = new OrderItem(OrderId = theTestOrder.id,
                  Quantity = 1,
                  Product2Id = pid,
                  PricebookEntryId = pricebookMap.get(pid).Id,
                  UnitPrice = pricebookMap.get(pid).UnitPrice,
                  L2I_Sub_Category_2__c = prodCategoryMap.get( pid ),
                  SBQQ__ChargeType__c = 'Usage',
                  SBQQ__BillingFrequency__c = 'Monthly',
//                  SBQQ__BillingType__c = 'Advance',
                  blng__BillingRule__c = billingrule.Id,
                  SBQQ__Status__c = 'Draft',
                  ServiceDate = Date.today()-2,
                  EndDate = Date.today()+363,
                  SBQQ__DefaultSubscriptionTerm__c = 24,
                  L2I_blng_MatchingId__c = '1234567891011');
            OrderItemList.add(theTestOrderItem);
        }
    
        insert OrderItemList;
        
        //
        // Note that Usage_Summary records should have been created with OrderItem creation
    
        theTestOrder.Status = 'Activated';
        update theTestOrder;
    
        L2I_Aircraft__c ac = factory.createAircraft(att.Id, 'Name', '2333-11131133114499999988888805', namedCustomer.Id);
        ac.L2I_Suspended_Products__c = NULL;
        insert ac;
    
//        L2I_Aircraft_Order__c aircraftOrder = new L2I_Aircraft_Order__c(
//              Activation_Date__c = Date.today()-2,
//              Aircraft__c = ac.Id,
//              Order__c = theTestOrder.Id
//        );
//        insert aircraftOrder;
    }
    
    static testMethod void testAircraftServiceUsageBatch() {
        
        setupTestContext();
        
        String pid = [SELECT Id, Name FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars' LIMIT 1].Id;
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;
        List<L2I_Aircraft_Service__c> lAircraftServiceUpd = new List<L2I_Aircraft_Service__c>();
        
        L2I_Aircraft_Service__c aircraftService = new L2I_Aircraft_Service__c(
            //Order_Product__c = OrderItemList[0].Id,
              Status__c = 'Activated',
              L2I_Activation_Date__c = Date.today()-3,
            //Aircraft_Order__c = aircraftOrder.Id,
              Aircraft__c = acId,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService;
        
        L2I_Aircraft_Service__c aircraftService2 = new L2I_Aircraft_Service__c(
            //Order_Product__c = OrderItemList[0].Id,
            Status__c = 'Activated',
            L2I_Activation_Date__c = Date.today()-3,
            //Aircraft_Order__c = aircraftOrder.Id,
            Aircraft__c = acId,
            L2I_Activation_Adjustment_Needed__c = true,
            Product2__c = pid,
            Matching_Id__c = '1234567891011'
        );
        insert aircraftService2;

        for(L2I_Aircraft_Service__c test: [SELECT Id,L2I_Activation_Date__c FROM L2I_Aircraft_Service__c]){
            test.L2I_Activation_Date__c = Date.today()-3;
            lAircraftServiceUpd.add(test);
        }
        update lAircraftServiceUpd;

        Test.startTest();
        
        L2I_AircraftServiceUsageBatch batch = new L2I_AircraftServiceUsageBatch();
        DataBase.executeBatch(batch);
        
        Test.stopTest();
        System.assertEquals(1, [SELECT count() from blng__Usage__c]);
    
    }
    
    static testMethod void testAircraftServiceAdjUsageBatch() {
        
        setupTestContext();
        
        String pid = [SELECT Id, Name FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars' AND L2I_Service_Activation_Type__c = 'Monthly' AND SBQQ__ChargeType__c = 'Usage' LIMIT 1].Id;
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;
        List<L2I_Aircraft_Service__c> lAircraftServiceUpd = new List<L2I_Aircraft_Service__c>();
        
        L2I_Aircraft_Service__c aircraftService = new L2I_Aircraft_Service__c(
            Status__c = 'Activated',
            L2I_Activation_Date__c = Date.today()-3,
            Aircraft__c = acId,
            Product2__c = pid,
            Matching_Id__c = '1234567891011'
        );
        insert aircraftService;
        
        L2I_Aircraft_Service__c aircraftService2 = new L2I_Aircraft_Service__c(
              Status__c = 'Activated',
              L2I_Activation_Date__c = Date.today()-2,
              Aircraft__c = acId,
              L2I_Activation_Adjustment_Needed__c = true,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService2;
        
        for(L2I_Aircraft_Service__c test: [SELECT Id,L2I_Activation_Date__c FROM L2I_Aircraft_Service__c]){
            test.L2I_Activation_Date__c = test.Id == aircraftService2.Id ? Date.today()-2 : Date.today()-3;
            lAircraftServiceUpd.add(test);
        }
        update lAircraftServiceUpd;
        
        Test.startTest();

        L2I_AircraftServiceAdjUsageBatch adjBatch = new L2I_AircraftServiceAdjUsageBatch();
        DataBase.executeBatch(adjBatch);
        
        Test.stopTest();
    
        //System.assertEquals(1, [SELECT count() from blng__Usage__c]);
    
    }
    
    static testMethod void testAircraftServiceAdjUsageBatchDeactivation() {
        
        setupTestContext();
        
        String pid = [SELECT Id, Name FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars' LIMIT 1].Id;
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;
        
        L2I_Aircraft_Service__c aircraftService2 = new L2I_Aircraft_Service__c(
              Status__c = 'Activated',
              L2I_Deactivation_Date__c = Date.today()-2,
              Aircraft__c = acId,
              L2I_Deactivation_Adjustment_Needed__c = true,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService2;
        
        aircraftService2.L2I_Deactivation_Date__c = Date.today()-2;
        update aircraftService2;
            
        Test.startTest();
        
        L2I_AircraftServiceAdjUsageBatch adjBatch = new L2I_AircraftServiceAdjUsageBatch();
        DataBase.executeBatch(adjBatch);
        
        Test.stopTest();
        
        //System.assertEquals(0, [SELECT count() from blng__Usage__c]);
    
    }
    
    static testMethod void testAircraftServiceUsageSched() {
        
        setupTestContext();
        
        String pid = [SELECT Id, Name FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars' LIMIT 1].Id;
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;
        
        
        L2I_Aircraft_Service__c aircraftService = new L2I_Aircraft_Service__c(
              Status__c = 'Activated',
              L2I_Activation_Date__c = Date.today()-3,
              Aircraft__c = acId,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService;
        
        L2I_Aircraft_Service__c aircraftService2 = new L2I_Aircraft_Service__c(
              Status__c = 'Activated',
              L2I_Activation_Date__c = Date.today()-3,
              Aircraft__c = acId,
              L2I_Activation_Adjustment_Needed__c = true,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService2;
        
        Test.startTest();

//        L2I_AircraftServiceUsageSched usageSched = new L2I_AircraftServiceUsageSched();
//        String chron = '0 0 5 * * ?';
//        system.schedule('Test Usage Sched', chron, usageSched);
    
        L2I_Usage_Batch_Setting__c usageBatchSetting = [SELECT Batch_Run_Date__c FROM L2I_Usage_Batch_Setting__c];
        usageBatchSetting.Batch_Run_Date__c = Date.today() - 2;
        update usageBatchSetting;
        
        L2I_AircraftServiceUsageSchedulable usageSchedul = new L2I_AircraftServiceUsageSchedulable();
        String chron1 = '0 0 5 * * ?';
        system.schedule('Test Usage Schedulable', chron1, usageSchedul);
    
        L2I_AircraftServiceAdjUsageSched adjUsageSched = new L2I_AircraftServiceAdjUsageSched();
        String chron2 = '0 0 10 * * ?';
        system.schedule('Test Adj Usage Sched', chron2, adjUsageSched);
        
        Test.stopTest();
    }
    
    static testMethod void testAircraftServiceUsageBatchMultipleUS() {
        
        setupTestContext();
        
        String pid = [SELECT Id, Name FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars' LIMIT 1].Id;
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;
        
        L2I_Aircraft_Service__c aircraftService = new L2I_Aircraft_Service__c(
              Status__c = 'Activated',
              L2I_Activation_Date__c = Date.today()-3,
              Aircraft__c = acId,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService;
        
        L2I_Aircraft_Service__c aircraftService2 = new L2I_Aircraft_Service__c(
              Status__c = 'Activated',
              L2I_Activation_Date__c = Date.today()-3,
              Aircraft__c = acId,
              L2I_Activation_Adjustment_Needed__c = true,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService2;
        
        List<L2I_Aircraft_Service__c> lAircraftServiceUpd = new List<L2I_Aircraft_Service__c>();
        for(L2I_Aircraft_Service__c test: [SELECT Id,L2I_Activation_Date__c FROM L2I_Aircraft_Service__c]){
            test.L2I_Activation_Date__c = Date.today()-3;
            lAircraftServiceUpd.add(test);
        }
        update lAircraftServiceUpd;        
        
        String ordId = [SELECT Id FROM Order LIMIT 1].Id;
        String oiId = [SELECT Id FROM OrderItem WHERE Product2Id = :pid LIMIT 1].Id;
        String acctId = [SELECT Id FROM Account LIMIT 1].Id;
    
        blng__UsageSummary__c usageSummary = new blng__UsageSummary__c(
              blng__Account__c = acctId,
              blng__Order__c = ordId,
              blng__OrderProduct__c = oiId,
              blng__SummaryStartDate__c = Date.today()-5,
              blng__SummaryEndDate__c = Date.today()+26,
              blng__MatchingId__c = '1234567891011',
              blng__InvoiceRunProcessingStatus__c = '',
              L2I_Actual_Quantity__c = 0,
              blng__PreratedAmount__c = 0,
              L2I_True_Up_Created__c = false
        );
        insert usageSummary;

        Test.startTest();
        
        L2I_AircraftServiceUsageBatch batch = new L2I_AircraftServiceUsageBatch();
        DataBase.executeBatch(batch);
        
        Test.stopTest();
    
        System.debug('*** ubel ' + [SELECT Id, Status__c, Number_of_Records__c, Batch_Run_Date__c, Exception__c FROM L2I_Usage_Batch_Execution_Log__c]);
        System.assertEquals(1, [SELECT COUNT() FROM L2I_Usage_Batch_Execution_Log__c WHERE Status__c = 'Failure']);
    }
    
    static testMethod void testAircraftAdjEarlyActivation() {
        
        setupTestContext();
        
        String pid = [SELECT Id, Name FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars' LIMIT 1].Id;
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;
        
        L2I_Aircraft_Service__c aircraftService2 = new L2I_Aircraft_Service__c(
              Status__c = 'Activated',
              L2I_Activation_Date__c = Date.today()-5,
              Aircraft__c = acId,
              L2I_Activation_Adjustment_Needed__c = true,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService2;
        
        aircraftService2.L2I_Activation_Date__c = Date.today()-5;
        update aircraftService2;
        
        Test.startTest();
        L2I_AircraftServiceAdjUsageBatch batch = new L2I_AircraftServiceAdjUsageBatch();
        DataBase.executeBatch(batch);
        Test.stopTest();
    
        System.assertEquals(2, [SELECT COUNT() FROM L2I_Usage_Batch_Execution_Log__c WHERE Status__c = 'Success']);
        System.assertEquals(1, [SELECT COUNT() FROM L2I_Aircraft_Service__c WHERE Manual_Adjustment_Notes__c LIKE '%manual activation adjustment is needed%']);
        System.debug('*** manual aserv ' + [SELECT Id, Manual_Adjustment_Notes__c, L2I_Activation_Adjustment_Needed__c FROM L2I_Aircraft_Service__c]);
    }
    
    static testMethod void testAircraftAdjLateActivation() {
        
        setupTestContext();
        
        String pid = [SELECT Id, Name FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars' LIMIT 1].Id;
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;
        
        L2I_Aircraft_Service__c aircraftService2 = new L2I_Aircraft_Service__c(
              Status__c = 'Activated',
              L2I_Activation_Date__c = Date.today()+5,
              Aircraft__c = acId,
              L2I_Activation_Adjustment_Needed__c = true,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService2;
        
        Test.startTest();
        L2I_AircraftServiceAdjUsageBatch batch = new L2I_AircraftServiceAdjUsageBatch();
        DataBase.executeBatch(batch);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM L2I_Usage_Batch_Execution_Log__c WHERE Status__c = 'Success']);
        System.assertEquals(1, [SELECT COUNT() FROM L2I_Aircraft_Service__c WHERE L2I_Activation_Adjustment_Needed__c = false]);
        System.debug('*** manual aserv ' + [SELECT Id, Manual_Adjustment_Notes__c, L2I_Activation_Adjustment_Needed__c FROM L2I_Aircraft_Service__c]);
    }
    
    static testMethod void testASUsageBatchOverrideNone() {
        
        setupTestContext();
        
        String pid = [SELECT Id, Name FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars' LIMIT 1].Id;
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;
        
        L2I_Aircraft_Service__c aircraftService = new L2I_Aircraft_Service__c(
//              Order_Product__c = OrderItemList[0].Id,
              Status__c = 'Activated',
              L2I_Activation_Date__c = Date.today()-3,
//            Aircraft_Order__c = aircraftOrder.Id,
              Aircraft__c = acId,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService;
        
        L2I_Aircraft_Service__c aircraftService2 = new L2I_Aircraft_Service__c(
//              Order_Product__c = OrderItemList[0].Id,
              Status__c = 'Activated',
              L2I_Activation_Date__c = Date.today()-3,
//              Aircraft_Order__c = aircraftOrder.Id,
              Aircraft__c = acId,
              L2I_Activation_Adjustment_Needed__c = true,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService2;
    
        List<blng__UsageSummary__c> usList = [SELECT Id, Name,
              blng__SummaryStartDate__c,
              blng__SummaryEndDate__c,
              blng__OverrideSummaryStartDate__c,
              blng__OverrideSummaryEndDate__c,
              blng__MatchingId__c,
              blng__InvoiceRunProcessingStatus__c FROM blng__UsageSummary__c];
        for(blng__UsageSummary__c us : usList){
            us.blng__OverrideSummaryStartDate__c =  us.blng__SummaryStartDate__c;
            us.blng__OverrideSummaryEndDate__c =  us.blng__SummaryStartDate__c;
            System.debug('*** usagesummary ' + us);
        }
        update usList;
        
        Test.startTest();
        
        L2I_AircraftServiceUsageBatch batch = new L2I_AircraftServiceUsageBatch();
        DataBase.executeBatch(batch);
        
        Test.stopTest();
        System.assertEquals(0, [SELECT count() from blng__Usage__c]);
    
    }
    
    static testMethod void testASUsageBatchOverrideGood() {
        
        setupTestContext();
        
        String pid = [SELECT Id, Name FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars' LIMIT 1].Id;
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;
        
        L2I_Aircraft_Service__c aircraftService = new L2I_Aircraft_Service__c(
//              Order_Product__c = OrderItemList[0].Id,
              Status__c = 'Activated',
              L2I_Activation_Date__c = Date.today()-3,
//            Aircraft_Order__c = aircraftOrder.Id,
              Aircraft__c = acId,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService;
        
        L2I_Aircraft_Service__c aircraftService2 = new L2I_Aircraft_Service__c(
//              Order_Product__c = OrderItemList[0].Id,
              Status__c = 'Activated',
              L2I_Activation_Date__c = Date.today()-3,
//              Aircraft_Order__c = aircraftOrder.Id,
              Aircraft__c = acId,
              L2I_Activation_Adjustment_Needed__c = true,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService2;
        
        List<L2I_Aircraft_Service__c> lAircraftServiceUpd = new List<L2I_Aircraft_Service__c>();
        for(L2I_Aircraft_Service__c test: [SELECT Id,L2I_Activation_Date__c FROM L2I_Aircraft_Service__c]){
            test.L2I_Activation_Date__c = Date.today()-3;
            lAircraftServiceUpd.add(test);
        }
        update lAircraftServiceUpd;   
        
        List<blng__UsageSummary__c> usList = [SELECT Id, Name,
              blng__SummaryStartDate__c,
              blng__SummaryEndDate__c,
              blng__OverrideSummaryStartDate__c,
              blng__OverrideSummaryEndDate__c,
              blng__MatchingId__c,
              blng__InvoiceRunProcessingStatus__c FROM blng__UsageSummary__c];
        for(blng__UsageSummary__c us : usList){
            us.blng__OverrideSummaryStartDate__c =  us.blng__SummaryStartDate__c;
            us.blng__OverrideSummaryEndDate__c =  us.blng__SummaryEndDate__c;
            System.debug('*** usagesummary ' + us);
        }
        update usList;
        
        Test.startTest();
        
        L2I_AircraftServiceUsageBatch batch = new L2I_AircraftServiceUsageBatch();
        DataBase.executeBatch(batch);
        
        Test.stopTest();
        System.assertEquals(1, [SELECT count() from blng__Usage__c]);
    
    }
    
    static testMethod void testAircraftAdjLateDeactivation() {
        
        setupTestContext();
        
        String pid = [SELECT Id, Name FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars' LIMIT 1].Id;
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;
        
        L2I_Aircraft_Service__c aircraftService2 = new L2I_Aircraft_Service__c(
              Status__c = 'Deactivated',
              L2I_Deactivation_Date__c = Date.today()+5,
              Aircraft__c = acId,
              L2I_Deactivation_Adjustment_Needed__c = true,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService2;
        
        Test.startTest();
        L2I_AircraftServiceAdjUsageBatch batch = new L2I_AircraftServiceAdjUsageBatch();
        DataBase.executeBatch(batch);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM L2I_Usage_Batch_Execution_Log__c WHERE Status__c = 'Success']);
        System.assertEquals(1, [SELECT COUNT() FROM L2I_Aircraft_Service__c WHERE L2I_Deactivation_Adjustment_Needed__c = false]);
        System.debug('*** manual aserv ' + [SELECT Id, Manual_Adjustment_Notes__c, L2I_Deactivation_Date__c FROM L2I_Aircraft_Service__c]);
    }
    
    static testMethod void testAircraftOneTime() {
        
        setupTestContext();
        
        Product2 p = [SELECT Id, L2I_Service_Activation_Type__c, Name FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars' LIMIT 1];
        p.L2I_Service_Activation_Type__c = 'OneTime';
        update p;
        String pid = p.Id;
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;
        
        L2I_Aircraft_Service__c aircraftService2 = new L2I_Aircraft_Service__c(
              Status__c = 'Activated',
              L2I_Activation_Date__c = Date.today()-5,
              Aircraft__c = acId,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService2;
        
        Test.startTest();
        L2I_AircraftServiceAdjUsageBatch batch = new L2I_AircraftServiceAdjUsageBatch();
        DataBase.executeBatch(batch);
        Test.stopTest();
        System.debug('*** OneTime usage ' +  [SELECT L2I_Actual_Quantity__c FROM blng__Usage__c]);
        System.assertEquals(1, [SELECT L2I_Actual_Quantity__c FROM blng__Usage__c LIMIT 1].L2I_Actual_Quantity__c);
    }
    
    static testMethod void testAircraftYearly() {
        
        setupTestContext();
        
        Product2 p = [SELECT Id, L2I_Service_Activation_Type__c, Name FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars' LIMIT 1];
        p.L2I_Service_Activation_Type__c = 'Yearly';
        update p;
        String pid = p.Id;
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;
        
        L2I_Aircraft_Service__c aircraftService2 = new L2I_Aircraft_Service__c(
              Status__c = 'Activated',
              L2I_Activation_Date__c = Date.today()-5,
              Aircraft__c = acId,
              Product2__c = pid,
              Matching_Id__c = '1234567891011',
              Yearly_Bill_Date__c = Date.Today() - 10
        );
        insert aircraftService2;
        System.debug('*** yearly as ' + aircraftService2);
        System.debug('*** Serv ' + [SELECT Id, Service_Activation_Type__c FROM L2I_Aircraft_Service__c]);
        
        Test.startTest();
        L2I_AircraftServiceAdjUsageBatch batch = new L2I_AircraftServiceAdjUsageBatch();
        DataBase.executeBatch(batch);
        Test.stopTest();
        System.debug('*** Yearly usage ' +  [SELECT L2I_Actual_Quantity__c FROM blng__Usage__c]);
        System.assertEquals(1, [SELECT L2I_Actual_Quantity__c FROM blng__Usage__c LIMIT 1].L2I_Actual_Quantity__c);
    }
}