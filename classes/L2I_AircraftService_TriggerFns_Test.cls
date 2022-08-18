/**
 *      @author       Raj Rajen
 *      @date         08/14/2019
 *      @description  Test class for L2I Aircraft Service Trigger Functions.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/14/2019         Initial setup of tests
 *      Sarah Kennedy                 03/24/2020         Changes for Amendment/Renewal object/field changes
 *
 */
@isTest(SeeAllData=false)
public class L2I_AircraftService_TriggerFns_Test {
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
        System.debug('*** prodCategoryMap ' + prodCategoryMap);
        
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
        System.debug('*** prodIdList ' + prodList);
        
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
        System.debug('*** theTestOrder.OpportunityId ' + theTestOrder.OpportunityId);
        System.debug('*** theTestOrder.L2I_Order_Process__c ' + theTestOrder.L2I_Order_Process__c);
        
        List<OrderItem> OrderItemList = new List<OrderItem>();
        blng__BillingRule__c billingrule = [SELECT Id FROM blng__BillingRule__c WHERE name = 'Non-Billable Product Rule' limit 1];
        for (Id pid : prodIdList) {
            System.debug('*** pid ' + pid);
            System.debug('*** prodCategoryMap.get( pid ) ' + prodCategoryMap.get( pid ));
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
        System.debug('*** orderItemList b4 ' + orderItemList);
        insert OrderItemList;
        System.debug('*** orderItemList ' + orderItemList);

        L2I_Aircraft__c ac = factory.createAircraft(att.Id, 'Name', '2333-11131133114499999988888805', namedCustomer.Id);
        insert ac;
    }
    
    static testMethod void testAircraftServiceUpdate() {
        
        setupTestContext();
        
        Product2 p = [SELECT Id, Name,L2I_Sub_Category_2__c FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars'  AND L2I_Service_Activation_Type__c = 'Monthly' LIMIT 1];
        p.L2I_Sub_Category_2__c = 'TV/Media';
        update p;
        
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;
        
        L2I_Aircraft_Service__c aircraftService = new L2I_Aircraft_Service__c(
            Aircraft__c = acId,
            Product2__c = p.Id,
            Matching_Id__c = '1234567891011'
        );
        insert aircraftService;
        aircraftService.L2I_Activation_Date__c = NULL;
        update aircraftService;
        
        test.startTest();
        aircraftService.L2I_Activation_Date__c = Date.today() - 2;
        system.debug('>> before update');
        update aircraftService;
        test.stopTest();
        System.assertEquals(true, [SELECT L2I_Activation_Adjustment_Needed__c FROM L2I_Aircraft_Service__c].L2I_Activation_Adjustment_Needed__c);
    }
    
    static testMethod void testAircraftServiceUpdateBillDate() {

        setupTestContext();

        Product2  p = [SELECT Id, L2I_Service_Activation_Type__c FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars' LIMIT 1];
        p.L2I_Service_Activation_Type__c = 'Yearly';
        update p;
        String pid = p.Id;
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;

        L2I_Aircraft_Service__c aircraftService = new L2I_Aircraft_Service__c(
              Aircraft__c = acId,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService;
        aircraftService.L2I_Activation_Date__c = Datetime.now();
        update aircraftService;
        System.debug('*** aircraftService ' + aircraftService);

        System.assertEquals(Date.today().addYears(1), [SELECT Yearly_Bill_Date__c FROM L2I_Aircraft_Service__c].Yearly_Bill_Date__c);
    }
    
    static testMethod void testAircraftServiceUpdateDeactivate() {
        
        setupTestContext();
        
        String pid = [SELECT Id, Name FROM Product2 WHERE Name =: 'Toca Boca - Toca Cars' LIMIT 1].Id;
        String acId = [SELECT Id FROM L2I_Aircraft__c LIMIT 1].Id;
        
        L2I_Aircraft_Service__c aircraftService = new L2I_Aircraft_Service__c(
              Aircraft__c = acId,
              Product2__c = pid,
              Matching_Id__c = '1234567891011'
        );
        insert aircraftService;
        aircraftService.L2I_Deactivation_Date__c = Date.today() - 2;
        update aircraftService;
    
        System.assertEquals(true, [SELECT L2I_Deactivation_Adjustment_Needed__c FROM L2I_Aircraft_Service__c].L2I_Deactivation_Adjustment_Needed__c);

    }
}