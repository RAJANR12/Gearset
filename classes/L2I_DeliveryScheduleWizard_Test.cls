@isTest
public class L2I_DeliveryScheduleWizard_Test {

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
            RecordTypeId = RecordTypeIdOpportunitySales
        );
        insert testOpp;

        L2I_Aircraft_Type__c airType = new L2I_Aircraft_Type__c(
            Name = '737 MAX 10',
            L2I_Model__c = '737',
            L2I_Master_Series__c = 'G4',
            L2I_Series__c = 'Max 10',
            L2I_Is_Active__c = true
        );
        insert airType;

        L2I_DSH__c delSched = new L2I_DSH__c(
            deal_Opportunity__c = testParentOpp.Id,
            Aircraft_Type__c = airType.Id
        );
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

        L2I_DeliveryScheduleWizard.getDeliverySchedules(testOpp.Id, null);
        L2I_DeliveryScheduleWizard.getDeliverySchedules(testParentOpp.Id, null);
        L2I_DeliveryScheduleWizard.getDeliverySchedules(null, delSched.Id);
        L2I_DeliveryScheduleWizard.getDeliverySchedules(delSched.Id, null);
        L2I_DeliveryScheduleWizard.getAvailableDeliverySchedules(testOpp.Id);

        // Test the method executions
        // System.assertEquals(value, field);
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
            RecordTypeId = RecordTypeIdOpportunitySales
        );
        insert testOpp;

        L2I_Aircraft_Type__c airType = new L2I_Aircraft_Type__c(
            Name = '737 MAX 10',
            L2I_Model__c = '737',
            L2I_Master_Series__c = 'G4',
            L2I_Series__c = 'Max 10',
            L2I_Is_Active__c = true
        );
        insert airType;

        String deliveryScheduleInformation = '{"data":{"aircraftQuantity":"2","businessClass":"2","deliveryScheduleLines":[],"dsId":"","economyClass":"4","firstClass":"1","objectName":"Opportunity","premiumEconomyClass":"3","recordId":"' + testOpp.Id + '","subscriptionTerm":"1","aircraftType":"' + airType.Id + '"}}';
        L2I_DeliveryScheduleWizard.createDeliveryScheduleHeader(deliveryScheduleInformation);

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
            RecordTypeId = RecordTypeIdOpportunitySales
        );
        insert testOpp;

        L2I_Aircraft_Type__c airType = new L2I_Aircraft_Type__c(
            Name = '737 MAX 10',
            L2I_Model__c = '737',
            L2I_Master_Series__c = 'G4',
            L2I_Series__c = 'Max 10',
            L2I_Is_Active__c = true
        );
        insert airType;

        L2I_DSH__c delSched = new L2I_DSH__c(
            deal_Opportunity__c = testParentOpp.Id,
            Aircraft_Type__c = airType.Id,
            Aircraft_Quantity__c = 2
        );
        insert delSched;

        testOpp.L2I_Delivery_Schedule__c = delSched.Id;
        update testOpp;

        String deliveryScheduleInformation = '{"data":{"accountName":"' + testAccount.Id + '","aircraftName":"B737-BBJ1","aircraftQuantity":2,"businessClass":2,"createdBy":"Blake Poutra","createdDate":"2019-08-22","deliveryScheduleLines":[],"dsId":"' + delSched.Id + '","dsName":"DSH-00115","economyClass":4,"firstClass":1}}';
        L2I_DeliveryScheduleWizard.createDeliveryScheduleLines(deliveryScheduleInformation, Date.today(), 1, 'Same Date');
        L2I_DeliveryScheduleWizard.createDeliveryScheduleLines(deliveryScheduleInformation, Date.today(), 1, 'Every Month');
        L2I_DeliveryScheduleWizard.createDeliveryScheduleLines(deliveryScheduleInformation, Date.today(), 1, 'Every Other Month');
        L2I_DeliveryScheduleWizard.createDeliveryScheduleLines(deliveryScheduleInformation, Date.today(), 1, 'Quarterly');
        L2I_DeliveryScheduleWizard.createDeliveryScheduleLines(deliveryScheduleInformation, Date.today(), 1, 'Yearly');

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
            RecordTypeId = RecordTypeIdOpportunitySales
        );
        insert testOpp;

        L2I_Aircraft_Type__c airType = new L2I_Aircraft_Type__c(
            Name = '737 MAX 10',
            L2I_Model__c = '737',
            L2I_Master_Series__c = 'G4',
            L2I_Series__c = 'Max 10',
            L2I_Is_Active__c = true
        );
        insert airType;

        L2I_DSH__c delSched = new L2I_DSH__c(
            deal_Opportunity__c = testParentOpp.Id,
            Aircraft_Type__c = airType.Id
        );
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

        String deliveryScheduleLinesToDelete = '{"data":[{"createdBy":"Blake Poutra","createdDate":"2019-08-22","deliveryDate":"2019-08-08","dslId":"' + delSchedLine.Id + '","dslName":"DSL-01552","lineNumber":"01","linkName":"/a2t18000000ccO0AAI"}]}';

        //L2I_DeliveryScheduleWizard.deleteDeliveryScheduleLines(deliveryScheduleLinesToDelete);
        List<Id> delIds = new List<Id>();
        delIds.add(delSchedLine.Id);
        L2I_DeliveryScheduleWizard.deleteDeliveryScheduleLines(delIds);

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
            RecordTypeId = RecordTypeIdOpportunitySales
        );
        insert testOpp;

        L2I_Aircraft_Type__c airType = new L2I_Aircraft_Type__c(
            Name = '737 MAX 10',
            L2I_Model__c = '737',
            L2I_Master_Series__c = 'G4',
            L2I_Series__c = 'Max 10',
            L2I_Is_Active__c = true
        );
        insert airType;

        L2I_DSH__c delSched = new L2I_DSH__c(
            deal_Opportunity__c = testParentOpp.Id,
            Aircraft_Type__c = airType.Id
        );
        insert delSched;

        L2I_DeliveryScheduleWizard.saveDeliveryScheduleToOpportunity(testOpp.Id , delSched.Id);

    }

}