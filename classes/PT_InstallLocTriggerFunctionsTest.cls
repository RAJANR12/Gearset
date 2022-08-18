@IsTest
private class PT_InstallLocTriggerFunctionsTest {
    
    @IsTest
    static void testMRODUpdate() {
        L2I_DataFactory dt = new L2I_DataFactory();
        Account namedCustomer = dt.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Product2 p = new Product2(Name = 'TestProd', ProductCode = 'ProdCode', L2I_Inventory_Item_Id__c = '99999803');
        
        PT_Program__c prog1 = new PT_Program__c();
        prog1.MROD_Approval_Status__c = 'Approved';
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;
        
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;
        
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc;
        
        Asset ast = new Asset(
              Name = 'AssetName',
              AccountId = namedCustomer.Id,
              Product2Id = p.Id,
              PT_Program__c = prog1.Id,
              PT_Install_Location__c = instLoc.Id,
              PT_MROD__c = Date.Today(),
              Quantity = 5,
              PT_Status__c = 'Active'
        );
        insert ast;
        
        instLoc.Pending_MROD__c = Date.today()+3;
        instLoc.Pending_D1_Date__C = Date.today()+2;
        instLoc.MROD__c = Date.Today();
        
        Test.startTest();
            update instLoc;
        Test.stopTest();
        System.assertEquals([SELECT Id, Pending_MROD__c FROM PT_Install_Location__c LIMIT 1].Pending_MROD__c,
              [SELECT Id, PT_Pending__c FROM Asset LIMIT 1].PT_Pending__c);
    }
}