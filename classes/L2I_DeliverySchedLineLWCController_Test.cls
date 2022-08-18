/**
 *      @author       Raj Rajen
 *      @date         12/12/2019
 *      @description  Test class for L2I_DeliverySchedLineLWCController
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     12/12/2019         Initial setup of tests
 *      Sarah Kennedy                 01/04/2020         Initialized from L2I_DeliveryScheduleLineController
 *
 */
@IsTest(SeeAllData=false)
public class L2I_DeliverySchedLineLWCController_Test {
    
    @TestSetup
    static void setup() {
        
        Account testAccount = new Account(Name = 'BRITISH AIRWAYS CORP',
              L2I_Payment_Term__c = '30 NET -a',
              L2I_Customer_Group__c = 'External',
              L2I_Customer_ID__c = '1083',
              L2I_Party_Id__c = '1083',
              L2I_Region__c = 'Europe',
              L2I_Operator_Number__c = 'BA',
              L2I_Airline_Code__c = 'BAW',
              AccountNumber = '1058',
              L2I_Account_Status__c = 'Active');
        insert testAccount;
        
        Id RecordTypeIdOpportunityDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        System.debug('RecordTypeIdOpportunityDeal: ' + RecordTypeIdOpportunityDeal);
        
        Opportunity testParentOpp = new Opportunity(Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = testAccount.Id,
              RecordTypeId = RecordTypeIdOpportunityDeal);
        insert testParentOpp;
        
        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        System.debug('RecordTypeIdOpportunitySales: ' + RecordTypeIdOpportunitySales);
        
        Opportunity testOpp = new Opportunity(Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              RecordTypeId = RecordTypeIdOpportunitySales);
        insert testOpp;
        
        L2I_Aircraft_Type__c airType = new L2I_Aircraft_Type__c(Name = '737 MAX 10',
              L2I_Model__c = '737',
              L2I_Master_Series__c = 'G4',
              L2I_Series__c = 'Max 10',
              L2I_Is_Active__c = true);
        insert airType;
    
        L2I_DSH__c delSched = new L2I_DSH__c(
              Product_Category__c = 'IFEC'
        );
        insert delSched;
        
        testOpp.L2I_Delivery_Schedule__c = delSched.Id;
        update testOpp;
        
        Id RecordTypeIdDeliverySchedLine = Schema.SObjectType.L2I_DSL__c.getRecordTypeInfosByName().get('Hardware').getRecordTypeId();
        
        L2I_DSL__c delSchedLine1 = new L2I_DSL__c(Delivery_Schedule_Header__c = delSched.Id,
              Line_Number__c = '01',
              Delivery_Date__c = Date.today(),
              Head_End_Date__c = Date.today().addMonths(-3),
              Seat_End_Date__c = Date.today().addMonths(-6),
              RecordTypeId = RecordTypeIdDeliverySchedLine);
        insert delSchedLine1;
        
        L2I_DSL__c delSchedLine2 = new L2I_DSL__c(Delivery_Schedule_Header__c = delSched.Id,
              Line_Number__c = '02',
              Delivery_Date__c = Date.today(),
              Head_End_Date__c = Date.today().addMonths(-3),
              Seat_End_Date__c = Date.today().addMonths(-6),
              RecordTypeId = RecordTypeIdDeliverySchedLine);
        insert delSchedLine2;
    }
    
    @IsTest
    static void update_delivery_schedule_lines_error() {
        L2I_DSL__c delSchedLine1 = [SELECT Id FROM L2I_DSL__c WHERE Line_Number__c = '01' LIMIT 1];
        L2I_DSL__c delSchedLine2 = [SELECT Id FROM L2I_DSL__c WHERE Line_Number__c = '02' LIMIT 1];
        String dslsJSON = '{"data":[{"aircraftConfirmation":true,"deliveryDate":"2099-01-01","dslId":"' + delSchedLine1.Id + '"},{"deliveryDate":"2099-02-01","dslId":"' + delSchedLine2.Id + '"}]}';
        String dslsOrigJSON = '{"data":[{"aircraftConfirmation":false,"deliveryDate":"2098-01-01","dslId":"' + delSchedLine1.Id + '"},{"aircraftConfirmation":false,"deliveryDate":"2099-02-01","dslId":"' + delSchedLine2.Id + '"}]}';
    
        L2I_DeliverySchedLineLWCController.ErrorWrapper ew = L2I_DeliverySchedLineLWCController.updateDSLs(dslsJSON, dslsOrigJSON, 'PTS');
        System.assertEquals(1, ew.errorRowWrapperList.size(), 'There should be 1 error for aircraftConfirmation without an aircraft');
    }
    
    @IsTest
    static void update_delivery_schedule_lines_no_error() {
        L2I_DSL__c delSchedLine1 = [SELECT Id FROM L2I_DSL__c WHERE Line_Number__c = '01' LIMIT 1];
        L2I_DSL__c delSchedLine2 = [SELECT Id FROM L2I_DSL__c WHERE Line_Number__c = '02' LIMIT 1];
        String dslsJSON = '{"data":[{"deliveryDate":"2099-01-01","dslId":"' + delSchedLine1.Id + '"},{"deliveryDate":"2099-02-01","dslId":"' + delSchedLine2.Id + '"}]}';
        String dslsOrigJSON = '{"data":[{"aircraftConfirmation":false,"deliveryDate":"2098-01-01","dslId":"' + delSchedLine1.Id + '"},{"aircraftConfirmation":false,"deliveryDate":"2099-02-01","dslId":"' + delSchedLine2.Id + '"}]}';
    
        L2I_DeliverySchedLineLWCController.ErrorWrapper ew = L2I_DeliverySchedLineLWCController.updateDSLs(dslsJSON, dslsOrigJSON,'PTS');
        System.assertEquals(0, ew.errorRowWrapperList.size(), 'There should be no error');
    }
}