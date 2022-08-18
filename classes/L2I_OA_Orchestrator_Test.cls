/**
 *      @author       Raj Rajen
 *      @date         08/18/2019
 *      @description  Test class for L2I Order Activation Orchestrator
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                     08/18/2019         Initial setup of tests
 *      Sarah Kennedy                 03/04/2020         Removed references to dsLineList.L2I_Games_Est_Start_Date__c (US1593)
 *      Sarah Kennedy                 03/05/2020         Modified call to factory.createDeliverySchedule to remove dealOppty.Id parameter (US1520)
 *      Sarah Kennedy                 03/19/2020         Modified for changed objects and fields
 */
@isTest(SeeAllData=false)
public class L2I_OA_Orchestrator_Test {

    private static L2I_DataFactory factory;
    private static List<SObject> products;
    private static List<PricebookEntry> pbEntries;

    static void setupTestContext() {
        factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);

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

        List<Product2> prodList = [ select Id, Name, L2I_Sub_Category_2__c from Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();

        for (Product2 p : prodList) {
            prodIdMap.put( p.Name, p.Id );
            prodCategoryMap.put( p.Id, p.L2I_Sub_Category_2__c );
        }

        Set<String> ProductNameList = new Set<String>();

        //ProductNameList.add('Advertising Services');
        //[RR]ProductNameList.add('Connectivity Services - WiFi'); // this product will not work as L2I_Service_Activation_Type__c is null for it
        ProductNameList.add('Toca Boca - Toca Cars');

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

        updateDSHToSalesOppo(salesOppty, dsHeaderlList.Id);

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
                  SBQQ__Activated__c = false,
                  L2I_blng_MatchingId__c = '1234567891011');
            OrderItemList.add(theTestOrderItem);
        }

        insert OrderItemList;

        //L2I_Aircraft__c ac = createAircraft( att.Id, 'Test User Name' );
        L2I_Aircraft__c ac = factory.createAircraft(att.Id, 'Name', '2333-11131133114499999988888805', namedCustomer.Id);
        insert ac;

        dsLineList.L2I_Aircraft_Confirmation__c = true;
        dsLineList.Aircraft__c = ac.Id;
        update dsLineList;
        System.debug('*** dsLineList ' + dsLineList);

    }

    static void updateDSHToSalesOppo( Opportunity oppo, Id DSHheaderID ){

        oppo.L2I_Delivery_Schedule__c = DSHheaderID;
        update oppo;

    }

    @IsTest
    static void test_activated_aircraft_services() {
        setupTestContext();
    
        Order ord = [SELECT Id  FROM Order LIMIT 1];
        Map<Id, Date> orderMap = new Map<Id, Date>();
        Date actDate = Date.today();
        orderMap.put(ord.Id, actDate);
        String jsonString = JSON.serialize(orderMap);
        
        Test.startTest();
            Datetime now = Datetime.now();
            L2I_Order_Activation_Execution_Log__c logEntry = L2I_OAExecutionLog_Helper.createLogEntry();
            L2I_OrderActivation_Orchestrator step1 = new L2I_OrderActivation_Orchestrator(logEntry.GUID__c, jsonString);

            // It does not matter what CRON expression we use here as this is a Test method and
            // therefore the job will execute immediately after Test.stopTest().
            String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, 1, 0);
            String jobId = System.schedule('Test Order Activation Step 1', cronTab, step1);

        // Stopping the test will run the job synchronously
        Test.stopTest();
    }
    
    @IsTest
    static void test_active_orders() {
        setupTestContext();
        
        Order ord = [SELECT Id  FROM Order LIMIT 1];
        ord.Status = 'Activated';
        update ord;
        Map<Id, Date> orderMap = new Map<Id, Date>();
        Date actDate = Date.today();
        orderMap.put(ord.Id, actDate);
        String jsonString = JSON.serialize(orderMap);
        
        Test.startTest();
        Datetime now = Datetime.now();
        L2I_Order_Activation_Execution_Log__c logEntry = L2I_OAExecutionLog_Helper.createLogEntry();
        L2I_OrderActivation_Orchestrator step1 = new L2I_OrderActivation_Orchestrator(logEntry.GUID__c, jsonString);
        
        // It does not matter what CRON expression we use here as this is a Test method and
        // therefore the job will execute immediately after Test.stopTest().
        String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, 1, 0);
        String jobId = System.schedule('Test Order Activation Step 1', cronTab, step1);
        
        // Stopping the test will run the job synchronously
        Test.stopTest();
    }
    
    @IsTest
    static void test_activated_aircraft_services_exception() {
        setupTestContext();
        
        Order ord = [SELECT Id  FROM Order LIMIT 1];
        Map<Id, Date> orderMap = new Map<Id, Date>();
        Date actDate = Date.today();
        orderMap.put(ord.Id, actDate);
        String jsonString = JSON.serialize(orderMap);
        Set<Id> ordIds = new Set<Id>();
        ordIds.add(ord.id);
        String ordId = ord.Id;
        Test.startTest();
        Datetime now = Datetime.now();
        L2I_Order_Activation_Execution_Log__c logEntry = L2I_OAExecutionLog_Helper.createLogEntry();
        L2I_OA_SetEffectiveDateBatch ab = new L2I_OA_SetEffectiveDateBatch(ordIds, orderMap, logEntry.GUID__c);
        ab.setException('Testing', ordId);

        // Stopping the test will run the job synchronously
        Test.stopTest();
    }
}