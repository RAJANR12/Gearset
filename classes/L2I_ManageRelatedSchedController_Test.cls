/**
* @File Name          : L2I_ManageRelatedSchedController_Test.cls
* @Description        : Test Class for L2I_ManageRelatedSchedController
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class L2I_ManageRelatedSchedController_Test {
    private static L2I_DataFactory factory;
    @IsTest
    static void testGetIFEC() {
        factory = new L2I_DataFactory();
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

        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity testOpp = new Opportunity(Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              L2I_Product_Category__c = 'IFEC',
              RecordTypeId = RecordTypeIdOpportunitySales,
              L2I_Primary_System_Type__c = prodSysType.Id);
        insert testOpp;

        L2I_DSH__c delSched = new L2I_DSH__c(
              Account__c = testAccount.Id
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
        
        Test.startTest();
        List<L2I_ManageRelatedSchedController.IFECWrap> wrapList = L2I_ManageRelatedSchedController.getIFECSchedules(testOpp.Id, 'All', 'oppName', 'asc');
        Test.stopTest();
    
        System.assertEquals(1, wrapList.size());
    }
    
    @IsTest
    static void testAddLines() {
        factory = new L2I_DataFactory();
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
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;

        Opportunity testOpp = new Opportunity(Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              L2I_Product_Category__c = 'IFEC',
              L2I_Primary_System_Type__c = prodSysType.Id,
              RecordTypeId = RecordTypeIdOpportunitySales);
        insert testOpp;
        
        L2I_DSH__c delSched = new L2I_DSH__c(
              Account__c = testAccount.Id,
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
    
        Opportunity testOppDSS = new Opportunity(Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = RecordTypeIdOpportunitySales);
        insert testOppDSS;
    
        L2I_DSH__c delSchedDSS = new L2I_DSH__c(
              Account__c = testAccount.Id,
              Product_Category__c = 'DSS'
        );
        insert delSchedDSS;
    
        testOppDSS.L2I_Delivery_Schedule__c = delSchedDSS.Id;
        update testOppDSS;
        
        Test.startTest();
        Integer addCount= L2I_ManageRelatedSchedController.addScheduleLines(testOppDSS.Id, delSched.Id);
        Test.stopTest();
        
        System.assertEquals(2, addCount);
    }
    
    @IsTest
    static void testAddLinesRepeat() {
        factory = new L2I_DataFactory();
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
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity testOpp = new Opportunity(Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              L2I_Product_Category__c = 'IFEC',
              L2I_Primary_System_Type__c = prodSysType.Id,
              RecordTypeId = RecordTypeIdOpportunitySales);
        insert testOpp;
        
        L2I_DSH__c delSched = new L2I_DSH__c(
              Account__c = testAccount.Id,
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
        
        Opportunity testOppDSS = new Opportunity(Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = RecordTypeIdOpportunitySales);
        insert testOppDSS;
        
        L2I_DSH__c delSchedDSS = new L2I_DSH__c(
              Account__c = testAccount.Id,
              Product_Category__c = 'DSS'
        );
        insert delSchedDSS;
        
        testOppDSS.L2I_Delivery_Schedule__c = delSchedDSS.Id;
        update testOppDSS;
        
        Test.startTest();
        Integer addCount= L2I_ManageRelatedSchedController.addScheduleLines(testOppDSS.Id, delSched.Id);
        addCount= L2I_ManageRelatedSchedController.addScheduleLines(testOppDSS.Id, delSched.Id);
        Test.stopTest();
        
        System.assertEquals(2, addCount);
    }
}