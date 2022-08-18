/**
* @File Name          : PT_EditTailNumberTest.cls
* @Description        : Test Class for PT_EditTailNumber
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@isTest
public class PT_EditTailNumberTest {
    private static L2I_DataFactory factory;

    @isTest
    static void getAvailableAirCraftsTest() {
        factory = new L2I_DataFactory();
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;

        L2I_Aircraft_Type__c att = factory.createAircraftType(acc.Id, 123456);
        insert att;

        L2I_Aircraft__c ac = factory.createAircraft(att.Id, 'Name', '2333-1113113311449', acc.Id);
        ac.L2I_Registration_Number__c = 'TEST123';
        insert ac;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.Effectivity__c = 'TEST123'; //Added by Jan Geronga for W-001972
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOpp;

        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        prog1.PT_Program_Aircraft_IDs__c = ac.Id;
        insert prog1;

        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule(acc.Id, att.Id);
        insert dsHeaderlList;

        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine(dsHeaderlList.Id);
        dsLineList.PT_Program__c = prog1.Id;
        dsLineList.Original_Opportunity__c = salesOpp.Id; //Added by Jan Geronga for W-001972
        insert dsLineList;

        List<PT_EditTailNumber.Requests> requests = new List<PT_EditTailNumber.Requests>();
        PT_EditTailNumber.Requests req = new PT_EditTailNumber.Requests();
        req.dslId = dsLineList.Id;
        requests.add(req);

        System.assertEquals(PT_EditTailNumber.getAvailableAirCrafts(requests).size(), 1);
    }

    @isTest
    static void noAirCraftsAvailableTest() {
        factory = new L2I_DataFactory();
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOpp;

        L2I_Aircraft_Type__c att = factory.createAircraftType(acc.Id, 123456);
        insert att;

        L2I_Aircraft__c ac = factory.createAircraft(att.Id, 'Name', '2333-1113113311449', acc.Id);
        insert ac;

        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;

        L2I_DSH__c dsHeaderlList = factory.createDeliverySchedule(acc.Id, att.Id);
        insert dsHeaderlList;

        L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine(dsHeaderlList.Id);
        dsLineList.PT_Program__c = prog1.Id;
        insert dsLineList;

        List<PT_EditTailNumber.Requests> requests = new List<PT_EditTailNumber.Requests>();
        PT_EditTailNumber.Requests req = new PT_EditTailNumber.Requests();
        req.dslId = dsLineList.Id;
        requests.add(req);

        System.assertEquals(PT_EditTailNumber.getAvailableAirCrafts(requests)[0], 'No Aircraft Available');
    }
}