@isTest
public class L2I_ReactivateAircraftService_Test {

    static testMethod void validateGetAircraftServiceRecords() {
        /**
        L2I_Aircraft__c aircraft = new L2I_Aircraft__c();
        insert aircraft;

        L2I_Aircraft_Type__c airType = new L2I_Aircraft_Type__c(
            Name = '737 MAX 10',
            L2I_Model__c = '737',
            L2I_Master_Series__c = 'G4',
            L2I_Series__c = 'Max 10',
            L2I_Is_Active__c = true
        );
        insert airType;
        **/
        L2I_DataFactory factory = new L2I_DataFactory();

        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);
        att.Name = '737 MAX 10';
        att.L2I_Model__c = '737';
        att.L2I_Master_Series__c = 'G4';
        att.L2I_Series__c = 'Max 10';
        att.L2I_Is_Active__c = true;
        insert att;
        System.assert(att.Id != null, 'Aircraft Type cannot be null');

        L2I_Aircraft__c aircraft = factory.createAircraft(att.Id, 'Name', '2333-11131133114499999988888805', namedCustomer.Id);
        insert aircraft;

        /**
        L2I_Aircraft_Order__c airOrder = new L2I_Aircraft_Order__c(
            Aircraft__c = '',
            Order__c = ''
        );
        insert airOrder;
        **/

        L2I_Aircraft_Order__c airOrder = new L2I_Aircraft_Order__c(Aircraft__c = aircraft.Id, Order__c = null);
        insert airOrder;

        L2I_Aircraft_Service__c airService = new L2I_Aircraft_Service__c(
            Aircraft_Order__c = airOrder.Id,
            Status__c = 'Deactivated',
            L2I_Deactivation_Date__c = Date.today(),
            Aircraft__c = aircraft.Id
        );
        insert airService;

        airService.Status__c = 'Deactivated';
        airService.L2I_Deactivation_Date__c = Date.today();
        update airService;
        
        String serviceRecordResult = L2I_ReactivateAircraftService.getAircraftServiceRecords(airService.Id);
        System.assertEquals(serviceRecordResult, 'Success');
        
        String activateRecordResult = L2I_ReactivateAircraftService.activateServiceRecord(airService.Id, Date.today());
        System.assertNotEquals(activateRecordResult, 'There is an existing record with the same Billing Matching Id with a Status of Pending Activation or Activated.');

    }

}