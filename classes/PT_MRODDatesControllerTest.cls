@IsTest
private class PT_MRODDatesControllerTest {
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
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }
        
        update updateProdList;
        
        L2I_Aircraft_Type__c att = factory.createAircraftType(namedCustomer.Id, 123456);
        
        insert att;
        
        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule(namedCustomer.Id, att.Id);
        
        insert dsHeaderlList;
        
        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine(dsHeaderlList.Id);
        
        insert dsLineList;
        
        
    }
    @isTest
    private static void testBlankMRODDate() {
        
        setupTestContext();
        
        L2I_DSL__c dsLineList = [SELECT Id FROM L2I_DSL__c LIMIT 1];
        Account namedCustomer = [SELECT Id FROM Account LIMIT 1];
    
        PT_Install_Location__c instLoc = new PT_Install_Location__c (
              Name = 'CW',
              ShipSet__c = dsLineList.Id
        );
        insert instLoc;
    
        Product2 p2 = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2 LIMIT 1];
        Asset ast1 = new Asset(
              Name = 'Asset1',
              Product2 = p2,
              AccountId = namedCustomer.Id,
              PT_Install_Location__c = instLoc.Id
        );
        insert ast1;
        
        Date pendingMrod = Date.today().addDays(2);
        Test.startTest();
        PT_MRODDatesController.updateMRODDates(instLoc.Id, 'IL', pendingMrod);
        Test.stopTest();
        
        System.assertEquals(pendingMrod, [SELECT Pending_MROD__c FROM PT_Install_Location__c LIMIT 1].Pending_MROD__c, 'Install Location gets the passed Pending Date');
        System.assertEquals(pendingMrod, [SELECT PT_Pending__c FROM Asset LIMIT 1].PT_Pending__c, 'Null MROD Date on Asset gets the passed Pending Date');
    
    }
    
    @isTest
    private static void testMatchingMRODDate() {
        
        setupTestContext();
        
        L2I_DSL__c dsLineList = [SELECT Id FROM L2I_DSL__c LIMIT 1];
        Account namedCustomer = [SELECT Id FROM Account LIMIT 1];
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c (
              Name = 'CW',
              ShipSet__c = dsLineList.Id,
              MROD__c = Date.today().addDays(1)
              
        );
        insert instLoc;
        
        Product2 p2 = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2 LIMIT 1];
        Asset ast1 = new Asset(
              Name = 'Asset1',
              Product2 = p2,
              AccountId = namedCustomer.Id,
              PT_Install_Location__c = instLoc.Id,
              PT_MROD__c = Date.today().addDays(1)
        );
        insert ast1;
        
        Date pendingMrod = Date.today().addDays(2);
        Test.startTest();
        PT_MRODDatesController.updateMRODDates(instLoc.Id, 'IL', pendingMrod);
        Test.stopTest();
        
        System.assertEquals(pendingMrod, [SELECT Pending_MROD__c FROM PT_Install_Location__c LIMIT 1].Pending_MROD__c, 'Install Location gets the passed Pending Date');
        System.assertEquals(pendingMrod, [SELECT PT_Pending__c FROM Asset LIMIT 1].PT_Pending__c, 'Matching MROD Date on Asset gets the passed Pending Date');
    
    }
    
    @isTest
    private static void testNonMatchingMRODDate() {
        
        setupTestContext();
        
        L2I_DSL__c dsLineList = [SELECT Id FROM L2I_DSL__c LIMIT 1];
        Account namedCustomer = [SELECT Id FROM Account LIMIT 1];
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c (
              Name = 'CW',
              ShipSet__c = dsLineList.Id,
              MROD__c = Date.today().addDays(-2)
        
        );
        insert instLoc;
        
        Product2 p2 = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2 LIMIT 1];
        Asset ast1 = new Asset(
              Name = 'Asset1',
              Product2 = p2,
              AccountId = namedCustomer.Id,
              PT_Install_Location__c = instLoc.Id,
              PT_MROD__c = Date.today().addDays(1)
        );
        insert ast1;
        
        Date pendingMrod = Date.today().addDays(2);
        Test.startTest();
        PT_MRODDatesController.updateMRODDates(instLoc.Id, 'IL', pendingMrod);
        Test.stopTest();
        
        System.assertEquals(pendingMrod, [SELECT Pending_MROD__c FROM PT_Install_Location__c LIMIT 1].Pending_MROD__c, 'Install Location gets the passed Pending Date');
        System.assertNotEquals(pendingMrod, [SELECT PT_Pending__c FROM Asset LIMIT 1].PT_Pending__c, 'Non-Matching MROD Date on Asset does not get the passed Pending Date');
    
    }
}