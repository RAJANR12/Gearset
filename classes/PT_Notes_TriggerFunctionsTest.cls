/**
* @File Name          : PT_Notes_TriggerFunctionsTest.cls
* @Description        : Test Class for PT_Notes_TriggerFunctions
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class PT_Notes_TriggerFunctionsTest {
    @IsTest
    static void testInsertNote() {
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
        salesOppty.PT_Revised_Parts_List_Version_Trans__c = 'B';
        update salesOppty;
        
        PT_Note__c note = new PT_Note__c(
              PT_Notes__c = 'Testing 1 2 3',
              PT_Opportunity__c = salesOppty.Id
        );
        insert note;
        System.assertEquals(1, [SELECT Id, PT_Sequence__c FROM PT_Note__c].PT_Sequence__c);
        System.assertEquals('A', [SELECT Id, PT_Note_Name__c FROM PT_Note__c].PT_Note_Name__c);
        System.assertEquals('B', [SELECT Id, PT_Rev_Note_Added__c FROM PT_Note__c].PT_Rev_Note_Added__c);
    }
    
    @IsTest
    static void testDeleteNote() {
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
        salesOppty.PT_Revised_Parts_List_Version_Trans__c = 'B';
        update salesOppty;
        
        PT_Note__c note = new PT_Note__c(
              PT_Notes__c = 'Testing 1 2 3',
              PT_Opportunity__c = salesOppty.Id
        );
        insert note;
    
        System.assertEquals('B', [SELECT Id, PT_Rev_Note_Added__c FROM PT_Note__c].PT_Rev_Note_Added__c);
    
        salesOppty.PT_Revised_Parts_List_Version_Trans__c = 'C';
        update salesOppty;
        
        note.PT_Delete_Note__c = true;
        update note;
        
        System.assertEquals('C', [SELECT Id, PT_Rev_Note_Deleted__c FROM PT_Note__c].PT_Rev_Note_Deleted__c);
    }
    
    @IsTest
    static void testDeleteNoteOnAssets() {
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
        salesOppty.PT_Revised_Parts_List_Version_Trans__c = 'B';
        update salesOppty;
    
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
    
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
    
        salesOppty.Pricebook2Id = Test.getStandardPricebookId();
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        salesOppty.L2I_Program_Num__c = pgm.Id;
        update salesOppty;
        
        PT_Note__c note = new PT_Note__c(
              PT_Notes__c = 'Testing 1 2 3',
              PT_Opportunity__c = salesOppty.Id,
              PT_Approval_Status__c = 'Approved'
        );
        insert note;
    
        PT_Note__c note2 = new PT_Note__c(
              PT_Notes__c = 'Testing 4 5 6',
              PT_Opportunity__c = salesOppty.Id,
              PT_Approval_Status__c = 'Approved'
        );
        insert note2;
    
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
    
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc;
    
        String partFilter = '';
    
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.ProductCode = 'MCS BUNDLE';
        insert prod;
    
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = namedCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10,
              PT_Status__c = 'Active',
              PT_Notes__c = 'A,C',
              PT_Pending_Notes__c = 'C',
              PT_Notes_Status__c = '[{"noteStatus":"Add","noteName":"C"}]'
        );
        insert ast;
        
        note.PT_Delete_Note__c = true;
        update note;
        note.PT_Approval_Status__c = 'Approved';
        update note;
        
        System.assertEquals('C', [SELECT Id, PT_Notes__c FROM Asset].PT_Notes__c);

        User admin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true Limit 1];

        System.runAs(admin) {
              delete note;
        }
    }
}