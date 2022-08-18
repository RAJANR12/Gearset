@IsTest
private class L2I_Case_TriggerFunctions_Test {
    @TestSetup
    static void testSetup() {
    
        System.debug('*** Start Order Trigger Functions Setup');
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    }
    
    @IsTest
    static void testCase() {
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
              L2I_Service_Activation_Types__c = 'abc',
              L2I_DSS_PO_Case_Closed__c = true);
        insert theTestOrder;
        
        Case cse = new Case(
              L2I_Order__c = theTestOrder.Id,
              RecordTypeId = aircraftOrder,
              L2I_Case_Process__c = 'Revise'
        );
        insert cse;
    
        L2I_Aircraft_Order__c airOrder = new L2I_Aircraft_Order__c(Aircraft__c = ac.Id, Order__c = null);
        insert airOrder;
    
        L2I_Aircraft_Service__c airService = new L2I_Aircraft_Service__c(
              Aircraft_Order__c = airOrder.Id,
              Status__c = 'Deactivated',
              L2I_Deactivation_Date__c = Date.today(),
              Aircraft__c = ac.Id
        );
        insert airService;
    
        OrderItem oi = [SELECT Id FROM OrderItem LIMIT 1];
    
        L2I_ASA__c newASA = new L2I_ASA__c(
              Order_Product__c = oi.Id,
              Aircraft_Order__c = cse.Id,
              Aircraft_Service__c = airService.Id,
              Action__c = 'Activate'
        );
        insert newASA;
        
        cse.L2I_Activation_Date__c = Date.today();
        cse.L2I_Deactivation_Date__c = Date.today();
        cse.L2I_Cancel_Date__c = Date.today();
        update cse;
        
        System.assertEquals(1,L2I_Case_TriggerFunctions.affectedOrderIds.size() );
        System.assert(L2I_Case_TriggerFunctions.affectedOrderIds.contains(theTestOrder.Id));
        
        Test.stopTest();       
        
    }
    
}