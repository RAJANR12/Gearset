/**
 *      @author       Raj Rajen
 *      @date         12/12/2019
 *      @description  Test class for L2I_DeliverySchedController_Test
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     12/12/2019         Initial setup of tests
 *      Sarah Kennedy                 01/04/2020         Initialized from L2I_DeliveryScheduleWizard
 *
 */
@isTest
public class L2I_DeliverySchedLWCController_Test {

    static testMethod void validateGetDeliverySchedules() {

        Account testAccount = new Account(
              Name = 'BRITISH AIRWAYS CORP',
              L2I_Payment_Term__c = '30 NET -a',
              L2I_Customer_Group__c = 'External',
              L2I_Customer_ID__c = '1083',
              L2I_Party_Id__c = '1083',
              L2I_Region__c = 'Europe',
              L2I_Operator_Number__c = 'BA',
              L2I_Airline_Code__c = 'BAW',
              AccountNumber = '1058',
              L2I_Account_Status__c = 'Active'
        );
        insert testAccount;

        Id RecordTypeIdOpportunityDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        System.debug('RecordTypeIdOpportunityDeal: ' + RecordTypeIdOpportunityDeal);

        Opportunity testParentOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = testAccount.Id,
              RecordTypeId = RecordTypeIdOpportunityDeal
        );
        insert testParentOpp;

        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        System.debug('RecordTypeIdOpportunitySales: ' + RecordTypeIdOpportunitySales);

        Opportunity testOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              AccountId = testAccount.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = RecordTypeIdOpportunitySales
        );
        insert testOpp;

        L2I_DSH__c delSched = new L2I_DSH__c();
        insert delSched;

        testOpp.L2I_Delivery_Schedule__c = delSched.Id;
        update testOpp;

        Id RecordTypeIdDeliverySchedLine = Schema.SObjectType.L2I_DSL__c.getRecordTypeInfosByName().get('Hardware').getRecordTypeId();

        L2I_DSL__c delSchedLine = new L2I_DSL__c(
              Delivery_Schedule_Header__c = delSched.Id,
              Line_Number__c = '01',
              Delivery_Date__c = Date.today(),
              RecordTypeId = RecordTypeIdDeliverySchedLine
        );
        insert delSchedLine;

        L2I_DSL__c delSchedLine2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = delSched.Id,
              Line_Number__c = '02',
              Delivery_Date__c = Date.today(),
              RecordTypeId = RecordTypeIdDeliverySchedLine
        );
        insert delSchedLine2;

        L2I_DeliverySchedLWCController.getDeliverySchedules(testOpp.Id, null);
        L2I_DeliverySchedLWCController.getDeliverySchedules(testParentOpp.Id, null);
        L2I_DeliverySchedLWCController.getDeliverySchedules(null, delSched.Id);
        L2I_DeliverySchedLWCController.getDeliverySchedules(delSched.Id, null);
    }

    static testMethod void validateCreateDeliverySchedules() {

        Account testAccount = new Account(
              Name = 'BRITISH AIRWAYS CORP',
              L2I_Payment_Term__c = '30 NET -a',
              L2I_Customer_Group__c = 'External',
              L2I_Customer_ID__c = '1083',
              L2I_Party_Id__c = '1083',
              L2I_Region__c = 'Europe',
              L2I_Operator_Number__c = 'BA',
              L2I_Airline_Code__c = 'BAW',
              AccountNumber = '1058',
              L2I_Account_Status__c = 'Active'
        );
        insert testAccount;

        Id RecordTypeIdOpportunityDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        System.debug('RecordTypeIdOpportunityDeal: ' + RecordTypeIdOpportunityDeal);

        Opportunity testParentOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = testAccount.Id,
              RecordTypeId = RecordTypeIdOpportunityDeal
        );
        insert testParentOpp;

        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        System.debug('RecordTypeIdOpportunitySales: ' + RecordTypeIdOpportunitySales);

        Opportunity testOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              AccountId = testAccount.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = RecordTypeIdOpportunitySales
        );
        insert testOpp;

        String deliveryScheduleInformation = '{"data":{"deliveryScheduleLines":[],"dsId":"","objectName":"Opportunity","recordId":"' + testOpp.Id + '"}}';
        L2I_DeliverySchedLWCController.createDeliveryScheduleHeader(deliveryScheduleInformation);

    }

    static testMethod void validateCreateDeliveryScheduleLines() {

        Account testAccount = new Account(
              Name = 'BRITISH AIRWAYS CORP',
              L2I_Payment_Term__c = '30 NET -a',
              L2I_Customer_Group__c = 'External',
              L2I_Customer_ID__c = '1083',
              L2I_Party_Id__c = '1083',
              L2I_Region__c = 'Europe',
              L2I_Operator_Number__c = 'BA',
              L2I_Airline_Code__c = 'BAW',
              AccountNumber = '1058',
              L2I_Account_Status__c = 'Active'
        );
        insert testAccount;

        Id RecordTypeIdOpportunityDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        System.debug('RecordTypeIdOpportunityDeal: ' + RecordTypeIdOpportunityDeal);

        Opportunity testParentOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = testAccount.Id,
              RecordTypeId = RecordTypeIdOpportunityDeal
        );
        insert testParentOpp;

        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        System.debug('RecordTypeIdOpportunitySales: ' + RecordTypeIdOpportunitySales);

        Opportunity testOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              AccountId = testAccount.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = RecordTypeIdOpportunitySales
        );
        insert testOpp;

        // need to change once the aircraft qty gets moved to the opportunity
        L2I_DSH__c delSched = new L2I_DSH__c();
        insert delSched;

        testOpp.L2I_Delivery_Schedule__c = delSched.Id;
        update testOpp;

        String deliveryScheduleInformation = '{"data":{"accountName":"' + testAccount.Id + '","createdBy":"Blake Poutra","aircraftQuantity":"2","interval":"1","deliveryInterval":"Same Date","createdDate":"2019-08-22","deliveryScheduleLines":[],"dsId":"' + delSched.Id + '","dsName":"DSH-00115"}}';
        L2I_DeliverySchedLWCController.createDeliveryScheduleLines(deliveryScheduleInformation, Date.today(), testOpp.Id);
        L2I_DeliverySchedLWCController.createDeliveryScheduleLines(deliveryScheduleInformation, Date.today(), testOpp.Id);
        L2I_DeliverySchedLWCController.createDeliveryScheduleLines(deliveryScheduleInformation, Date.today(), testOpp.Id);
        L2I_DeliverySchedLWCController.createDeliveryScheduleLines(deliveryScheduleInformation, Date.today(), testOpp.Id);
        L2I_DeliverySchedLWCController.createDeliveryScheduleLines(deliveryScheduleInformation, Date.today(), testOpp.Id);

    }

    static testMethod void validateDeleteDeliveryScheduleLines() {

        Account testAccount = new Account(
              Name = 'BRITISH AIRWAYS CORP',
              L2I_Payment_Term__c = '30 NET -a',
              L2I_Customer_Group__c = 'External',
              L2I_Customer_ID__c = '1083',
              L2I_Party_Id__c = '1083',
              L2I_Region__c = 'Europe',
              L2I_Operator_Number__c = 'BA',
              L2I_Airline_Code__c = 'BAW',
              AccountNumber = '1058',
              L2I_Account_Status__c = 'Active'
        );
        insert testAccount;

        Id RecordTypeIdOpportunityDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        System.debug('RecordTypeIdOpportunityDeal: ' + RecordTypeIdOpportunityDeal);

        Opportunity testParentOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = testAccount.Id,
              RecordTypeId = RecordTypeIdOpportunityDeal
        );
        insert testParentOpp;

        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        System.debug('RecordTypeIdOpportunitySales: ' + RecordTypeIdOpportunitySales);

        Opportunity testOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              AccountId = testAccount.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = RecordTypeIdOpportunitySales
        );
        insert testOpp;

        L2I_DSH__c delSched = new L2I_DSH__c();
        insert delSched;

        testOpp.L2I_Delivery_Schedule__c = delSched.Id;
        update testOpp;

        Id RecordTypeIdDeliverySchedLine = Schema.SObjectType.L2I_DSL__c.getRecordTypeInfosByName().get('Hardware').getRecordTypeId();

        L2I_DSL__c delSchedLine = new L2I_DSL__c(
              Delivery_Schedule_Header__c = delSched.Id,
              Line_Number__c = '01',
              Delivery_Date__c = Date.today(),
              RecordTypeId = RecordTypeIdDeliverySchedLine
        );
        insert delSchedLine;

        List<String> dslIdsList = new List<String>{
              delSchedLine.Id
        };
        L2I_DeliverySchedLWCController.deleteDeliveryScheduleLines(dslIdsList, testOpp.Id);

    }
    
    static testMethod void validateResetDeliveryScheduleLinesSalesOpp() {
        
        Account testAccount = new Account(
              Name = 'BRITISH AIRWAYS CORP',
              L2I_Payment_Term__c = '30 NET -a',
              L2I_Customer_Group__c = 'External',
              L2I_Customer_ID__c = '1083',
              L2I_Party_Id__c = '1083',
              L2I_Region__c = 'Europe',
              L2I_Operator_Number__c = 'BA',
              L2I_Airline_Code__c = 'BAW',
              AccountNumber = '1058',
              L2I_Account_Status__c = 'Active'
        );
        insert testAccount;
        
        Id RecordTypeIdOpportunityDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        System.debug('RecordTypeIdOpportunityDeal: ' + RecordTypeIdOpportunityDeal);
        
        Opportunity testParentOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = testAccount.Id,
              RecordTypeId = RecordTypeIdOpportunityDeal
        );
        insert testParentOpp;
        
        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        System.debug('RecordTypeIdOpportunitySales: ' + RecordTypeIdOpportunitySales);
        
        Opportunity testOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              AccountId = testAccount.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = RecordTypeIdOpportunitySales
        );
        insert testOpp;
        
        L2I_DSH__c delSched = new L2I_DSH__c();
        insert delSched;
        
        testOpp.L2I_Delivery_Schedule__c = delSched.Id;
        update testOpp;
        
        Id RecordTypeIdDeliverySchedLine = Schema.SObjectType.L2I_DSL__c.getRecordTypeInfosByName().get('Hardware').getRecordTypeId();
        
        L2I_DSL__c delSchedLine = new L2I_DSL__c(
              Delivery_Schedule_Header__c = delSched.Id,
              Line_Number__c = '01',
              Delivery_Date__c = Date.today(),
              Original_Opportunity__c = testOpp.Id,
              RecordTypeId = RecordTypeIdDeliverySchedLine
        );
        insert delSchedLine;
        
        List<String> dslIdsList = new List<String>{
              delSchedLine.Id
        };
        L2I_DeliverySchedLWCController.resetDeliveryScheduleLines(testOpp.Id);
    
        System.assertEquals(1, [SELECT COUNT() FROM L2I_DSL__c]);
    }
    
    static testMethod void validateResetDeliveryScheduleLinesRenewal() {
        
        Account testAccount = new Account(
              Name = 'BRITISH AIRWAYS CORP',
              L2I_Payment_Term__c = '30 NET -a',
              L2I_Customer_Group__c = 'External',
              L2I_Customer_ID__c = '1083',
              L2I_Party_Id__c = '1083',
              L2I_Region__c = 'Europe',
              L2I_Operator_Number__c = 'BA',
              L2I_Airline_Code__c = 'BAW',
              AccountNumber = '1058',
              L2I_Account_Status__c = 'Active'
        );
        insert testAccount;
        
        Id RecordTypeIdOpportunityDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        System.debug('RecordTypeIdOpportunityDeal: ' + RecordTypeIdOpportunityDeal);
        
        Opportunity testParentOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = testAccount.Id,
              RecordTypeId = RecordTypeIdOpportunityDeal
        );
        insert testParentOpp;
        
        Id RecordTypeIdOpportunityRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        System.debug('RecordTypeIdOpportunityRenewal: ' + RecordTypeIdOpportunityRenewal);
        
        Opportunity testOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              AccountId = testAccount.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = RecordTypeIdOpportunityRenewal
        );
        insert testOpp;
        
        L2I_DSH__c delSched = new L2I_DSH__c();
        insert delSched;
        
        testOpp.L2I_Delivery_Schedule__c = delSched.Id;
        update testOpp;
        
        Id RecordTypeIdDeliverySchedLine = Schema.SObjectType.L2I_DSL__c.getRecordTypeInfosByName().get('Hardware').getRecordTypeId();
        
        L2I_DSL__c delSchedLine = new L2I_DSL__c(
              Delivery_Schedule_Header__c = delSched.Id,
              Line_Number__c = '01',
              Delivery_Date__c = Date.today(),
              Original_Opportunity__c = testOpp.Id,
              RecordTypeId = RecordTypeIdDeliverySchedLine
        );
        insert delSchedLine;
        
        List<String> dslIdsList = new List<String>{
              delSchedLine.Id
        };
        L2I_DeliverySchedLWCController.resetDeliveryScheduleLines(testOpp.Id);
        
        System.assertEquals(0, [SELECT COUNT() FROM L2I_DSL__c]);
    }

    static testMethod void validateSaveDeliveryScheduleToOpportunity() {

        Account testAccount = new Account(
              Name = 'BRITISH AIRWAYS CORP',
              L2I_Payment_Term__c = '30 NET -a',
              L2I_Customer_Group__c = 'External',
              L2I_Customer_ID__c = '1083',
              L2I_Party_Id__c = '1083',
              L2I_Region__c = 'Europe',
              L2I_Operator_Number__c = 'BA',
              L2I_Airline_Code__c = 'BAW',
              AccountNumber = '1058',
              L2I_Account_Status__c = 'Active'
        );
        insert testAccount;

        Id RecordTypeIdOpportunityDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        System.debug('RecordTypeIdOpportunityDeal: ' + RecordTypeIdOpportunityDeal);

        Opportunity testParentOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = testAccount.Id,
              RecordTypeId = RecordTypeIdOpportunityDeal
        );
        insert testParentOpp;

        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        System.debug('RecordTypeIdOpportunitySales: ' + RecordTypeIdOpportunitySales);

        Opportunity testOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              AccountId = testAccount.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = RecordTypeIdOpportunitySales
        );
        insert testOpp;

        L2I_DSH__c delSched;
        try {
            delSched = new L2I_DSH__c();
            insert delSched;
        } catch (Exception e) {
            System.debug('error: ' + e);
        }

        System.debug('*** testOpp.Id ' + testOpp.Id);
        System.debug('*** delSched.Id ' + delSched.Id);

        L2I_DeliverySchedLWCController.saveDeliveryScheduleToOpportunity(testOpp.Id, delSched.Id);

    }

    static testMethod void validatePushPull() {

        Account testAccount = new Account(
              Name = 'BRITISH AIRWAYS CORP',
              L2I_Payment_Term__c = '30 NET -a',
              L2I_Customer_Group__c = 'External',
              L2I_Customer_ID__c = '1083',
              L2I_Party_Id__c = '1083',
              L2I_Region__c = 'Europe',
              L2I_Operator_Number__c = 'BA',
              L2I_Airline_Code__c = 'BAW',
              AccountNumber = '1058',
              L2I_Account_Status__c = 'Active'
        );
        insert testAccount;

        Id RecordTypeIdOpportunityDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        System.debug('RecordTypeIdOpportunityDeal: ' + RecordTypeIdOpportunityDeal);

        Opportunity testParentOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = testAccount.Id,
              RecordTypeId = RecordTypeIdOpportunityDeal
        );
        insert testParentOpp;

        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        System.debug('RecordTypeIdOpportunitySales: ' + RecordTypeIdOpportunitySales);

        Opportunity testOpp = new Opportunity(
              Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              AccountId = testAccount.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = RecordTypeIdOpportunitySales
        );
        insert testOpp;

        L2I_DSH__c sched = new L2I_DSH__c();
        insert sched;

        testOpp.L2I_Delivery_Schedule__c = sched.Id;
        update testOpp;

        Id RecordTypeIdDeliverySchedLine = Schema.SObjectType.L2I_DSL__c.getRecordTypeInfosByName().get('Hardware').getRecordTypeId();

        L2I_DSL__c schedLine = new L2I_DSL__c(
              Delivery_Schedule_Header__c = sched.Id,
              Line_Number__c = '01',
              Delivery_Date__c = Date.today(),
              RecordTypeId = RecordTypeIdDeliverySchedLine
        );
        insert schedLine;

        List<String> dslIdsList = new List<String>{
              schedLine.Id
        };
        L2I_DeliverySchedLWCController.pushPullDeliveryDates('+1', '1', dslIdsList, sched.Id);
        schedLine = [SELECT Id, Delivery_Date__c FROM L2I_DSL__c WHERE Id = :schedLine.Id];

        System.assertEquals(Date.today().addMonths(1), schedLine.Delivery_Date__c, 'Delivery Date is one month later');
    }

    @isTest
    static void testDeleteDeliverySchedule() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity opp = [SELECT Id, L2I_Delivery_Schedule__c FROM Opportunity WHERE RecordTypeId = :RecordTypeIdOpportunitySales LIMIT 1];
        
        L2I_DeliverySchedLWCController.deleteDeliverySchedule(opp.L2I_Delivery_Schedule__c);
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM L2I_DSH__c]);
    }
    
    @IsTest
    static void testDSHUpdate(){
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        Test.startTest();
        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity opp = [SELECT Id, L2I_Delivery_Schedule__c FROM Opportunity WHERE RecordTypeId = :RecordTypeIdOpportunitySales LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        L2I_DeliverySchedLWCController.updateDeliverySchedule('{"data":[{"deliveryDateOffset":"5","dsId":"' + dsh.Id + '"}]}');
        Test.stopTest();
    }
}