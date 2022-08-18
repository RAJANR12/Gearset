@IsTest
private class L2I_InvoiceLine_TriggerFunctionsTest {
    @TestSetup
    static void testSetup() {
        
        System.debug('*** Start Invoice Lines Trigger Functions Setup');
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    }
    
    @IsTest
    static void testCaseToInvoice() {
        Test.startTest();
        Id aircraftOrder = L2I_UtilityHelper.getRecordTypeId('L2I_Aircraft_Order', 'Case');
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];

        Contact c = new Contact(
              LastName = 'MyName'
        );
        insert c;
        
        Shipping_Method__c sm = new Shipping_Method__c(
        Name = 'SM1'
        );
        insert sm;
        
        Order ord = [SELECT Id, PT_Case__c FROM Order LIMIT 1];
        Id ordItemId = [SELECT Id FROM OrderItem LIMIT 1].Id;
        
        Id rtId = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'DSS_PO_Case_2_Closed'].Id;
        Case cse = new Case(
              RecordTypeId = rtId,
              PT_PO_Number__c = '123',
              PT_PO_Received_Date__c = Date.today(),
              PT_Freight_Terms__c = 'Prepaid',
              PT_Ship_to_Customer__c = acct.Id,
              PT_Ship_to_Location__c = null,
              PT_Shipping_Method__c = sm.Id,
              PT_Packing_Instructions__c = 'do this',
              PT_Ship_to_Contact__c = c.Id,
              PT_Shipping_Instructions__c = 'do that',
              PT_Purpose__c = 'Interactive',
              PT_CR_Number__c = 'cr123',
              PT_Comments__c = 'here are comments',
              L2I_End_User_Location__c = null,
              L2I_Product_Category_2__c = 'games'
        );
        insert cse;
        
        ord.PT_Case__c = cse.Id;
        update ord;
        
        blng__Invoice__c inv = new blng__Invoice__c();
        inv.blng__InvoiceStatus__c = 'Draft';
        inv.blng__Account__c = acct.Id;
        inv.blng__DueDate__c = Date.today();
        inv.blng__InvoiceDate__c = Date.today();
        inv.blng__TargetDate__c = Date.today();
        insert inv;
        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c();
        invLine.blng__Invoice__c = inv.Id;
        invLine.blng__OrderProduct__c = ordItemId;
        insert invLine;
        
        Test.stopTest();
    
        System.assertEquals('Interactive', [SELECT PT_Purpose__c FROM blng__Invoice__c LIMIT 1].PT_Purpose__c);
        System.assertEquals('Prepaid', [SELECT PT_Freight_Terms__c FROM blng__Invoice__c LIMIT 1].PT_Freight_Terms__c);
    }

}