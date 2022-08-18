@IsTest
private class L2I_OppAircraftLWCController_Test {
    @IsTest
    static void testAircraft() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
    
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        Opportunity salesOpp = [SELECT Id, L2I_AircraftQuantity__c FROM Opportunity WHERE Name = 'Sales Oppty' LIMIT 1];
        L2I_OppAircraftLWCController.oppAircraft oppAir = L2I_OppAircraftLWCController.getAircraft(salesOpp.Id);
    
        Test.startTest();
        L2I_OppAircraftLWCController.updateAircraft(salesOpp.Id, null, 5);
        Test.stopTest();
        salesOpp = [SELECT Id, L2I_AircraftQuantity__c FROM Opportunity WHERE Name = 'Sales Oppty' LIMIT 1];
        System.assertEquals(5, salesOpp.L2I_AircraftQuantity__c);
    }
}