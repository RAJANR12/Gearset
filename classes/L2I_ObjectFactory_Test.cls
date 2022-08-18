/**
 *      @author       Raj Rajen
 *      @date         02/03/2020
 *      @description  Test class for L2I Object Factory
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     02/03/2020         Initial setup of tests
 *
 */
@isTest(SeeAllData=false)
public class L2I_ObjectFactory_Test {

    @isTest
    static void test_load_static_resource() {
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('ddt_test_1');

        Map<String, SObject> registry = objFactory.getRegistry();
        for (String key : registry.keySet()) {
            SObject obj = objFactory.getRegistryItem(key);
            System.debug('******* identifier :' + key);
            System.debug('******* sobject :' + obj);
        }

        Account acct = (Account) registry.get('my_account_1');
        System.assert(acct.Name.equals('Test Account Name'), 'Account name must match with specified name in the data template');

    }

    @isTest
    static void test_load_string() {
        String jsonPayload = '{"records":[{"fields":{"RecordTypeId":"$recordType{Account.Customer}","Name":"Test Account Name","BillingPostalCode":"12345","BillingState":"UT","BillingStreet":"123 Main St","BillingCity":"Utopia"},"identifier":"my_account_1","sobject":"Account"},{"fields":{"RecordTypeId":"$recordType{Opportunity.Deal}","Name":"Deal Oppty","StageName":"Open","Amount":"1000000.00","CloseDate":"$eval{DATE(today,addDays,20)}","AccountId":"$resolve{my_account_1.Id}"},"identifier":"deal_oppty_1","sobject":"Opportunity"},{"fields":{"Name":"F-18","L2I_PAC_Type_Designator__c":"ABCD","L2I_Model__c":"GT","Manufacturer__c":"$resolve{my_account_1.Id}","L2I_Aircraft_Type__c":"Testing","L2I_Is_Active__c":"true","L2I_Manufacturer_Party_ID__c":"123456","L2I_Make__c":"Mustang","L2I_Series__c":"Racing"},"identifier":"my_aircraft_type","sobject":"L2I_Aircraft_Type__c"},{"fields":{"L2I_Aircraft_Status__c":"In Service","Name":"Test A/C","L2I_GPIN__c":"A319-1100","L2I_Operator__c":"$resolve{my_account_1.Id}","L2I_Serial_Number__c":"abc12289","L2I_Aircraft_Delivery_Date__c":"$eval{DATE(today,addDays,30)}","Aircraft_Type__c":"$resolve{my_aircraft_type.Id}","L2I_Approved__c":"true"},"identifier":"my_aircraft","sobject":"L2I_Aircraft__c"},{"fields":{"Account__c":"$resolve{my_account_1.Id}","Subscription_Term__c":"36","Term_Type__c":"Fixed","Economy_Class__c":"120","Aircraft_Quantity__c":"5","Deal_Opportunity__c":"$resolve{deal_oppty_1.Id}","Premium_Economy_Class__c":"40","Aircraft_Type__c":"$resolve{my_aircraft_type.Id}","Business_Class__c":"20","First_Class__c":"20"},"identifier":"my_dsh","sobject":"L2I_DSH__c"},{"fields":{"Seat_End_Date__c":"$eval{DATE(today,addMonths,7)}","Out_of_Warranty_Date_2__c":"$eval{DATE(today,addYears,3)}","Delivery_Date__c":"$eval{DATE(today,addMonths,1)}","Out_of_Warranty_Date_1__c":"$eval{DATE(today,addYears,2)}","Head_End_Date__c":"$eval{DATE(today,addMonths,4)}","Line_Number__c":"01","Delivery_Schedule_Header__c":"$resolve{my_dsh.Id}"},"identifier":"dsl_1","sobject":"L2I_DSL__c"},{"fields":{"Seat_End_Date__c":"$eval{DATE(today,addMonths,8)}","Out_of_Warranty_Date_2__c":"$eval{DATE(today,addYears,3)}","Delivery_Date__c":"$eval{DATE(today,addMonths,2)}","Out_of_Warranty_Date_1__c":"$eval{DATE(today,addYears,2)}","Head_End_Date__c":"$eval{DATE(today,addMonths,5)}","Line_Number__c":"02","Delivery_Schedule_Header__c":"$resolve{my_dsh.Id}"},"identifier":"dsl_2","sobject":"L2I_DSL__c"}],"testdataset":"Sample data template"}';

        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadString(jsonPayload);

        Map<String, SObject> registry = objFactory.getRegistry();
        for (String key : registry.keySet()) {
            SObject obj = objFactory.getRegistryItem(key);
            System.debug('******* identifier :' + key);
            System.debug('******* sobject :' + obj);
        }

        Account acct = (Account) registry.get('my_account_1');
        System.assert(acct.Name.equals('Test Account Name'), 'Account name must match with specified name in the data template');
    }

}