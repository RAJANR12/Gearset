/**
 *      @author       Raj Rajen
 *      @date         08/03/2019
 *      @description  Test class for L2I Aircraft Trigger Functions.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/03/2019         Initial setup of tests
 *
 */
@isTest(SeeAllData=false)
public class L2I_Aircraft_TriggerFunctions_Test {

    @isTest
    static void test_unused_aircraft_deletion_as_non_system_administrator() {
        //Id salesProfileId = [SELECT Id, Name from Profile Where Name =: 'PAC Sales'].Id;

        L2I_DataFactory factory = new L2I_DataFactory();

        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC Sales');
        User salesUser = factory.createTestUser(null, salesProfile.Id, 'Sales', 'User');
        insert salesUser;

        System.assert(salesUser.Id != null, 'User Id cannot be null');

        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);
        insert att;
        System.assert(att.Id != null, 'Aircraft Type cannot be null');

        System.runAs(salesUser) {
            // Create the Aircraft as this user
            L2I_Aircraft__c ac = factory.createAircraft(att.Id, 'Name', '2333-11131133114499999988888805', namedCustomer.Id);
            insert ac;

            // Try to delete the aircraft, the system should *NOT* allow you to delete the aircraft
            try {
                delete ac;
            } catch (DmlException dmle) {
                System.assert(dmle.getMessage().containsIgnoreCase('Unauthorized Attempt to delete. Aircraft records can only be deleted by Administrators'));
            }
        }
    }

    @isTest
    static void test_unused_aircraft_deletion_as_system_administrator() {
        L2I_DataFactory factory = new L2I_DataFactory();

        Profile adminProfile = L2I_StaticConstants.getProfileByName('System Administrator');
        User adminUser = factory.createTestUser(null, adminProfile.Id, 'Super', 'User');
        insert adminUser;

        System.assert(adminUser.Id != null, 'User Id cannot be null');

        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);
        insert att;
        System.assert(att.Id != null, 'Aircraft Type cannot be null');

        System.runAs(adminUser) {
            // Create the Aircraft as this user
            L2I_Aircraft__c ac = factory.createAircraft(att.Id, 'Name', '2333-11131133114499999988888805', namedCustomer.Id);
            insert ac;

            // Try to delete the aircraft, the system should allow you to delete the aircraft
            delete ac;
        }
    }

    @isTest
    static void test_in_use_aircraft_deletion_as_system_administrator() {
        L2I_DataFactory factory = new L2I_DataFactory();

        Profile adminProfile = L2I_StaticConstants.getProfileByName('System Administrator');
        User adminUser = factory.createTestUser(null, adminProfile.Id, 'Super', 'User');
        insert adminUser;

        System.assert(adminUser.Id != null, 'User Id cannot be null');

        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

        L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);
        insert att;
        System.assert(att.Id != null, 'Aircraft Type cannot be null');

        System.runAs(adminUser) {
            // Create the Aircraft as this user
            L2I_Aircraft__c ac = factory.createAircraft(att.Id, 'Name', '2333-11131133114499999988888805', namedCustomer.Id);
            insert ac;

            L2I_Aircraft_Order__c ao = new L2I_Aircraft_Order__c(Aircraft__c = ac.id);
            insert ao;

            L2I_Aircraft_Service__c asvc = new L2I_Aircraft_Service__c(Aircraft__c = ac.Id,
                                                                       Aircraft_Order__c = ao.Id,
                                                                       Status__c = 'Pending Activation');
            insert asvc;
            System.assert(asvc.Id != null, 'Aircraft Service cannot be null');

            //ac = [select Id, Name, Total_Number_of_Services__c from L2I_Aircraft__c where Id =: ac.Id limit 1];
            //System.assert(ac.Total_Number_of_Services__c == 1, 'Number of Services on the Aircraft does not match expected value');

            // Try to delete the aircraft, the system should *NOT* allow you to delete the aircraft
            try {
                delete ac;
            } catch (DmlException dmle) {
                System.debug('====== EXCEPTION Message :' + dmle.getMessage());
                System.assert(dmle.getMessage().containsIgnoreCase('In-use Aircraft records cannot be deleted'));
            }
        }
    }


    @isTest
    static void test_in_use_aircraft_deletion_as_aircraft_data_steward() {
        L2I_DataFactory factory = new L2I_DataFactory();

        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC Sales');
        User stewardUser = factory.createTestUser(null, salesProfile.Id, 'Aircraft', 'Steward');
        insert stewardUser;

        System.assert(stewardUser.Id != null, 'User Id cannot be null');

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Aircraft_Data_Steward'];
        insert new PermissionSetAssignment(AssigneeId = stewardUser.Id, PermissionSetId = ps.Id);

        System.runAs(stewardUser) {
            Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

            L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);
            insert att;
            System.assert(att.Id != null, 'Aircraft Type cannot be null');

            // Create the Aircraft as this user
            L2I_Aircraft__c ac = factory.createAircraft(att.Id, 'Name', '2333-11131133114499999988888805', namedCustomer.Id);
            insert ac;

            L2I_Aircraft_Order__c ao = new L2I_Aircraft_Order__c(Aircraft__c = ac.id);
            insert ao;

            L2I_Aircraft_Service__c asvc = new L2I_Aircraft_Service__c(Aircraft__c = ac.Id,
                                                                       Aircraft_Order__c = ao.Id,
                                                                       Status__c = 'Pending Activation');
            insert asvc;
            System.assert(asvc.Id != null, 'Aircraft Service cannot be null');

            //ac = [select Id, Name, Total_Number_of_Services__c from L2I_Aircraft__c where Id =: ac.Id limit 1];
            //System.assert(ac.Total_Number_of_Services__c == 1, 'Number of Services on the Aircraft does not match expected value');

            // Try to delete the aircraft, the system should *NOT* allow you to delete the aircraft
            try {
                delete ac;
            } catch (DmlException dmle) {
                System.debug('====== EXCEPTION Message :' + dmle.getMessage());
                System.assert(dmle.getMessage().containsIgnoreCase('In-use Aircraft records cannot be deleted'));
            }
        }
    }

    @isTest
    static void test_unused_aircraft_deletion_as_aircraft_data_steward() {
        L2I_DataFactory factory = new L2I_DataFactory();

        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC Sales');
        User stewardUser = factory.createTestUser(null, salesProfile.Id, 'Aircraft', 'Steward');
        insert stewardUser;
        System.assert(stewardUser.Id != null, 'User Id cannot be null');

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Aircraft_Data_Steward'];
        insert new PermissionSetAssignment(AssigneeId = stewardUser.Id, PermissionSetId = ps.Id);

        System.runAs(stewardUser) {
            Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

            L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);
            insert att;
            System.assert(att.Id != null, 'Aircraft Type cannot be null');

            // Create the Aircraft as this user
            L2I_Aircraft__c ac = factory.createAircraft(att.Id, 'Name', '2333-11131133114499999988888805', namedCustomer.Id);
            insert ac;

            delete ac;
        }
    }

}