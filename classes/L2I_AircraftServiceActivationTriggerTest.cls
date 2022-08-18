@IsTest
private class L2I_AircraftServiceActivationTriggerTest {
    @IsTest
    static void testBehavior() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Order ord = [SELECT Id  FROM Order LIMIT 1];
        Map<Id, Date> orderMap = new Map<Id, Date>();
        Date actDate = Date.today();
        orderMap.put(ord.Id, actDate);
        String jsonString = JSON.serialize(orderMap);
        L2I_Aircraft_Service_Activated__e asa = new L2I_Aircraft_Service_Activated__e();
        asa.orderMap__c = jsonString;
        
        Test.startTest();
    
        // Publish test event
        Database.SaveResult sr = EventBus.publish(asa);
    
        Test.stopTest();

        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
    }
}