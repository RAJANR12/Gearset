/**
 * @Class Name         : PT_AddEffectivityController_Test
 * @Description        : Test Class for PT_AddEffectivityController
 * @Author             : Jan Denrick Geronga / Managed Services Simplus
 * @Modification Log   :
 * Ver       	Date       	  Author              Modification
 * W-001972    	Sep-10-2021   MS Simplus Jan      Initial Version
 * W-001727     Mar 31 2022   MS Simplus Khrisna  Primary System Type Validation Rule
**/

@isTest
public class PT_AddEffectivityController_Test {
    private static L2I_DataFactory factory;
    
    @isTest
    static void effectivity_Test() {
        factory = new L2I_DataFactory();
        List<L2I_Aircraft__c> acList = new List<L2I_Aircraft__c>();
        String searchEntry = 'TEST';
        String pending = 'Pending';
        String approved = 'Approved';
        String tailNumber = 'TEST1';
        List<String> listTailNumber = new List<String>{'TEST123', 'TEST1234'};
            
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        System.assert(acc.Id != null, 'Named Customer Account must have an Id');

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');
    
        L2I_Aircraft_Type__c att = factory.createAircraftType(acc.Id, 123456);
        insert att;
    
        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule(acc.Id, att.Id);
        insert dsHeaderlList;
        
        L2I_Aircraft__c ac1 = new L2I_Aircraft__c(Name = 'Test AC', Aircraft_Type__c = att.Id, L2I_Aircraft_Status__c = 'On Order',
                                                L2I_Serial_Number__c = '10017', L2I_Registration_Number__c = 'TEST1', L2I_Aircraft_Delivery_Date__c = system.today(),
                                                L2I_GPIN__c = 'A21N-12314', L2I_Operator__c = acc.Id);
        acList.add(ac1);
        
        L2I_Aircraft__c ac2 = new L2I_Aircraft__c(Name = 'Test AC1', Aircraft_Type__c = att.Id, L2I_Aircraft_Status__c = 'On Order',
                                                L2I_Serial_Number__c = '10017', L2I_Registration_Number__c = 'TEST12', L2I_Aircraft_Delivery_Date__c = system.today(),
                                                L2I_GPIN__c = 'A21N-12315', L2I_Operator__c = acc.Id);
        acList.add(ac2);
        
        L2I_Aircraft__c ac3 = new L2I_Aircraft__c(Name = 'Test AC2', Aircraft_Type__c = att.Id, L2I_Aircraft_Status__c = 'On Order',
                                                L2I_Serial_Number__c = '10017', L2I_Registration_Number__c = 'TEST123', L2I_Aircraft_Delivery_Date__c = system.today(),
                                                L2I_GPIN__c = 'A21N-12315', L2I_Operator__c = acc.Id);
        acList.add(ac3);
        
        L2I_Aircraft__c ac4 = new L2I_Aircraft__c(Name = 'Test AC3', Aircraft_Type__c = att.Id, L2I_Aircraft_Status__c = 'On Order',
                                                L2I_Serial_Number__c = '10017', L2I_Registration_Number__c = 'TEST1234', L2I_Aircraft_Delivery_Date__c = system.today(),
                                                L2I_GPIN__c = 'A21N-12315', L2I_Operator__c = acc.Id);
        acList.add(ac4);
        
        L2I_Aircraft__c ac5 = new L2I_Aircraft__c(Name = 'Test AC4', Aircraft_Type__c = att.Id, L2I_Aircraft_Status__c = 'On Order',
                                                L2I_Serial_Number__c = '10017', L2I_Registration_Number__c = 'TEST12345', L2I_Aircraft_Delivery_Date__c = system.today(),
                                                L2I_GPIN__c = 'A21N-12315', L2I_Operator__c = acc.Id);
        
        insert acList;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;

        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.Effectivity__c = 'TEST1;TEST12';
        salesOpp.Pending_Delete_Effectivity__c = 'TEST12';
        salesOpp.Pending_Effectivity__c = 'TEST123';
        salesOpp.L2I_Aircraft_Type__c = att.Id;
        salesOpp.L2I_Delivery_Schedule__c = dsHeaderlList.Id;
        salesOpp.L2I_Win_Loss_Date__c = Date.today();
        salesOpp.StageName = 'Handoff';
        salesOpp.PT_Parts_List_Revision_Number__c = 0;
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOpp;
        
        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine(dsHeaderlList.Id);
        dsLineList.Aircraft__c = ac1.Id;
        dsLineList.Original_Opportunity__c = salesOpp.Id;
        insert dsLineList;
        
        Test.startTest();
        PT_AddEffectivityController.findEffectivity(salesOpp.Id);
        PT_AddEffectivityController.findPendingEffectivity(salesOpp.Id);
        PT_AddEffectivityController.searchAircraft(searchEntry);
        PT_AddEffectivityController.saveEffectivity(salesOpp.Id, listTailNumber);   
        PT_AddEffectivityController.createAircraft(ac5, salesOpp.Id);
        PT_AddEffectivityController.deleteEffectivity(salesOpp.Id, tailNumber, pending);
        PT_AddEffectivityController.deleteEffectivity(salesOpp.Id, tailNumber, approved);
        Test.stopTest();
    }
}