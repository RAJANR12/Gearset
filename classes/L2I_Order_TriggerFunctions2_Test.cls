@IsTest
private class L2I_Order_TriggerFunctions2_Test {
    @TestSetup
    static void testSetup() {
        
        System.debug('*** Start Order Trigger Functions Setup');
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    }
    
    @IsTest
    static void testOrderNotClosed() {
        Test.startTest();
        Id aircraftOrder = L2I_UtilityHelper.getRecordTypeId('L2I_Aircraft_Order', 'Case');
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        SBQQ__Quote__c qt = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
              Name = 'TestSalesOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = salesId);
        insert salesOppty;
        qt.SBQQ__Opportunity2__c = salesOppty.Id;
        update qt;
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        salesOppty.SBQQ__PrimaryQuote__c = qt.Id;
        update salesOppty;
        
        L2I_Aircraft__c ac = [SELECT Id FROM L2I_Aircraft__c LIMIT 1];
        L2I_DSL__c dsl = [SELECT Id, Name, L2I_Aircraft_Confirmation__c, Aircraft__c,  Aircraft__r.Name FROM L2I_DSL__c LIMIT 1];
        dsl.Aircraft__c = ac.Id;
        dsl.L2I_Aircraft_Confirmation__c = true;
        update dsl;
    
        Case cse = new Case(
              Status = 'New'
        );
        insert cse;
        
        Order theTestOrder = new Order(AccountId = acct.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOppty.Id,
              SBQQ__Quote__c = qt.Id,
              L2I_Product_Category_2__c = 'games',
              L2I_Delivery_Schedule__c = dsh.Id,
              PT_Case__c = cse.Id);
        insert theTestOrder;
        
        theTestOrder.PT_Ext_Order_Header_Status__c = 'NOT CLOSED';
        update theTestOrder;
        
        Test.stopTest();
        
        System.assertEquals('New',[SELECT Status FROM CASE WHERE ID = : cse.Id].Status );
    }
    
    @IsTest
    static void testOrderClosed() {
        Test.startTest();
        Id aircraftOrder = L2I_UtilityHelper.getRecordTypeId('L2I_Aircraft_Order', 'Case');
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        SBQQ__Quote__c qt = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
              Name = 'TestSalesOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = salesId);
        insert salesOppty;
        qt.SBQQ__Opportunity2__c = salesOppty.Id;
        update qt;
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        salesOppty.SBQQ__PrimaryQuote__c = qt.Id;
        update salesOppty;
        
        L2I_Aircraft__c ac = [SELECT Id FROM L2I_Aircraft__c LIMIT 1];
        L2I_DSL__c dsl = [SELECT Id, Name, L2I_Aircraft_Confirmation__c, Aircraft__c,  Aircraft__r.Name FROM L2I_DSL__c LIMIT 1];
        dsl.Aircraft__c = ac.Id;
        dsl.L2I_Aircraft_Confirmation__c = true;
        update dsl;
        
        Case cse = new Case(
              Status = 'New'
        );
        insert cse;
        
        Order theTestOrder = new Order(AccountId = acct.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOppty.Id,
              SBQQ__Quote__c = qt.Id,
              L2I_Product_Category_2__c = 'games',
              L2I_Delivery_Schedule__c = dsh.Id,
              PT_Case__c = cse.Id);
        insert theTestOrder;
        
        theTestOrder.PT_Ext_Order_Header_Status__c = 'CLOSED';
        update theTestOrder;
        
        Test.stopTest();
        
        System.assertEquals('Order Closed',[SELECT Status FROM CASE WHERE ID = : cse.Id].Status );
    }
    
    @IsTest
    static void testOrderMixed() {
        Test.startTest();
        Id aircraftOrder = L2I_UtilityHelper.getRecordTypeId('L2I_Aircraft_Order', 'Case');
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        SBQQ__Quote__c qt = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
              Name = 'TestSalesOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = salesId);
        insert salesOppty;
        qt.SBQQ__Opportunity2__c = salesOppty.Id;
        update qt;
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        salesOppty.SBQQ__PrimaryQuote__c = qt.Id;
        update salesOppty;
        
        L2I_Aircraft__c ac = [SELECT Id FROM L2I_Aircraft__c LIMIT 1];
        L2I_DSL__c dsl = [SELECT Id, Name, L2I_Aircraft_Confirmation__c, Aircraft__c,  Aircraft__r.Name FROM L2I_DSL__c LIMIT 1];
        dsl.Aircraft__c = ac.Id;
        dsl.L2I_Aircraft_Confirmation__c = true;
        update dsl;
        
        Case cse = new Case(
              Status = 'New'
        );
        insert cse;
        
        Order theTestOrder0 = [SELECT Id, PT_Case__c, PT_Ext_Order_Header_Status__c FROM Order LIMIT 1];
        Order theTestOrder = new Order(AccountId = acct.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOppty.Id,
              SBQQ__Quote__c = qt.Id,
              L2I_Product_Category_2__c = 'games',
              L2I_Delivery_Schedule__c = dsh.Id,
              PT_Case__c = cse.Id);
        insert theTestOrder;
        
        theTestOrder0.PT_Ext_Order_Header_Status__c = 'NOT CLOSED';
        theTestOrder0.PT_Case__c = cse.Id;
        update theTestOrder0;
    
        theTestOrder.PT_Ext_Order_Header_Status__c = 'CLOSED';
        update theTestOrder;
        
        Test.stopTest();
        
        System.assertEquals('New',[SELECT Status FROM CASE WHERE ID = : cse.Id].Status );
    }
    
    @IsTest
    static void testOrderMixedClosed() {
        Test.startTest();
        Id aircraftOrder = L2I_UtilityHelper.getRecordTypeId('L2I_Aircraft_Order', 'Case');
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        SBQQ__Quote__c qt = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
              Name = 'TestSalesOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = salesId);
        insert salesOppty;
        qt.SBQQ__Opportunity2__c = salesOppty.Id;
        update qt;
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        salesOppty.SBQQ__PrimaryQuote__c = qt.Id;
        update salesOppty;
        
        L2I_Aircraft__c ac = [SELECT Id FROM L2I_Aircraft__c LIMIT 1];
        L2I_DSL__c dsl = [SELECT Id, Name, L2I_Aircraft_Confirmation__c, Aircraft__c,  Aircraft__r.Name FROM L2I_DSL__c LIMIT 1];
        dsl.Aircraft__c = ac.Id;
        dsl.L2I_Aircraft_Confirmation__c = true;
        update dsl;
        
        Case cse = new Case(
              Status = 'New'
        );
        insert cse;
        
        Order theTestOrder0 = [SELECT Id, PT_Case__c, PT_Ext_Order_Header_Status__c FROM Order LIMIT 1];
        Order theTestOrder = new Order(AccountId = acct.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOppty.Id,
              SBQQ__Quote__c = qt.Id,
              L2I_Product_Category_2__c = 'games',
              L2I_Delivery_Schedule__c = dsh.Id,
              PT_Case__c = cse.Id);
        insert theTestOrder;
        
        theTestOrder0.PT_Ext_Order_Header_Status__c = 'CANCELLED';
        theTestOrder0.PT_Case__c = cse.Id;
        update theTestOrder0;
        
        theTestOrder.PT_Ext_Order_Header_Status__c = 'CLOSED';
        update theTestOrder;
        
        Test.stopTest();
        
        System.assertEquals('Order Closed',[SELECT Status FROM CASE WHERE ID = : cse.Id].Status );
    }
}