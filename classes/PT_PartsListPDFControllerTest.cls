/**
* @File Name          : PT_PartsListPDFControllerTest.cls
* @Description        : Test Class for PT_PartsListPDFController
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class PT_PartsListPDFControllerTest {
    
    @IsTest
    static void testLoadData() {
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
        salesOppty.OwnerId = UserInfo.getUserId();
        salesOppty.PT_Parts_List_Revision_Number__c = 0; //Khrisna W-003269
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        System.debug('*** pgm ' + pgm);
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Program_Num__c = pgm.Id;
        update salesOppty;
        
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        List<String> solGroupList = new List<String>{
              sg.Id
        };
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Original_Opportunity__c = salesOppty.Id
        );
        insert dsl;
        
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Original_Opportunity__c = salesOppty.Id
        );
        insert dsl2;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'BC',
              ShipSet__c = dsl2.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc2;
        
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Original_Install_Location__c = instLoc2.Name,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active',
              PT_Pending_Notes__c = 'Remove Notes',
              PT_Notes__c = 'A,D',
              PT_Notes_Status__c = '[{"noteStatus":"Delete","noteName":"D"},{"noteStatus":"Delete","noteName":"C"}]'
        );
        insert ast;
    
        Asset ast2 = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc2.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active',
              PT_Notes__c = 'A,D'
        );
        insert ast2;
    
        Asset ast3 = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc2.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active',
              PT_Notes__c = 'A,D'
        );
        insert ast3;
        //Khrisna W-003269
        Product2 prod2 = factory.createProduct('90000000', 'IFE MISCELLANEOUS', '', '', null);
        prod2.productCode = 'IFE MISCELLANEOUS';
        insert prod2;

        Asset ast4 = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc2.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod2.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 1,
              Quantity = 1,
              PT_Status__c = 'Active',
              PT_Notes__c = 'A,D'
        );
        insert ast4;
        //Khrisna W-003269
        PT_Note__c note = new PT_Note__c(
              PT_Note_Name__c = 'Note A',
              PT_Sequence__c = 1,
              PT_Opportunity__c = salesOppty.Id,
              PT_Notes__c = 'Note123'
        );
        insert note;
        List<Id> oppIdList = new List<Id>();
        oppIdList.add(salesOppty.Id);
        PT_PartList_Utils.createPendingPartListRecords(oppIdList);

        ApexPages.StandardController standardController = new ApexPages.StandardController(salesOppty);
        PT_PartsListPDFController plc = new PT_PartsListPDFController(standardController);
        System.assertEquals(pgm.Name, plc.oppw.program);
        System.assertEquals(1, plc.noteWrapperList.size());
        // Khrisna W-003269
        ast4.PT_Status__c = 'Pending Removed';
        update ast4;

        List<Id> updateOppIdList = new List<Id>();
        updateOppIdList.add(salesOppty.Id);
        PT_PartList_Utils.createPendingPartListRecords(updateOppIdList);

        salesOppty.PT_PL_Approval_Status__c = 'Approved';
        salesOppty.PT_PL_Approval_Date__c = System.now();
        update salesOppty;

        PT_PartList_Utils.updateOpportunityPostApproval(salesOppty.Id);
        PT_PartList_Utils.updatePartListPostApproval(salesOppty.Id);

        Test.startTest();
        ApexPages.StandardController standardController2 = new ApexPages.StandardController(salesOppty);
        PT_PartsListPDFController plc2 = new PT_PartsListPDFController(standardController2);
        System.assertNotEquals(null, plc2.plrListWrapper);
        Test.stopTest();
    }
}