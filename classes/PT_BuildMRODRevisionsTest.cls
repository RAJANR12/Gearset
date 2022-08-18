/**
* @File Name          : PT_BuildMRODRevisionsTest.cls
* @Description        : Test Class for PT_BuildMRODRevisions
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class PT_BuildMRODRevisionsTest {
    @IsTest
    static void testBuild() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{sg.Name};
        
        L2I_DSL__c dsl = new L2I_DSL__c(
              Name = '01',
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1',
              Latest_Approval_Process_Type__c = 'MROD'
        );
        insert pgm;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        System.debug('*** ' + [select Part_List_Opportunity__c from PT_Install_Location__c]);
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;
        
        String partFilter = '';
        
        Product2 product = factory.createProduct('99999802', 'MediaServices', 'IFEC', 'IFE HW', null);
        product.productCode = 'MCS BUNDLE';
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
              Product2Id = product.Id,
              UnitPrice = 1000,
              IsActive = true);
        insert pbe;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = product.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active'
        );
        insert ast;
    
        PT_BuildMRODRevisions.buildPendingMRODRecords(new List<Id>{pgm.Id});
        System.assertEquals(1, [SELECT COUNT() FROM PT_MROD_Revision__c]);
    }
}