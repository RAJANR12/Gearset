@IsTest
private class L2I_DSLService_Test {
    @IsTest
    static void testCreateDSL() {
        Test.startTest();
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
    
        Opportunity testOpp = new Opportunity(Name = 'TestParentOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = testParentOpp.Id,
              RecordTypeId = RecordTypeIdOpportunitySales);
        insert testOpp;

        L2I_DSH__c delSched = new L2I_DSH__c(
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
              List<L2I_DSL__c> dslList = [SELECT Id FROM L2I_DSL__c];
        
        List<L2I_DSL__c> dslList2 = L2I_DSLService.pruneDSLList(dslList, testOpp.Id);
    Test.stopTest();
        System.assertEquals(dslList.size(), [SELECT COUNT() FROM L2I_DSL__c]);
    }
    
    @TestSetup
    static void testCases() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    }
    
    @IsTest
    static void testBehavior() {
        Test.startTest();
        Id aircraftOrder = L2I_UtilityHelper.getRecordTypeId('L2I_Aircraft_Order', 'Case');
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account Name' LIMIT 1];
        Opportunity salesOppty = [SELECT Id FROM Opportunity WHERE Name = 'Sales Oppty' LIMIT 1];
        SBQQ__Quote__c qt = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :salesOppty.Id LIMIT 1];
        L2I_DSH__c dsHeader = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        L2I_Aircraft__c ac = [SELECT Id FROM L2I_Aircraft__c LIMIT 1];
        L2I_DSL__c dsl = [SELECT Id FROM L2I_DSL__c LIMIT 1];
        
        Order theTestOrder = new Order(AccountId = acct.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOppty.Id,
              SBQQ__Quote__c = qt.Id,
              L2I_Product_Category_2__c = 'games',
              L2I_Delivery_Schedule__c = dsHeader.Id);
        insert theTestOrder;
        
        Case cse = new Case(
              L2I_Aircraft__c = ac.Id,
              L2I_Delivery_Schedule_Line__c = dsl.Id,
              L2I_Order__c = theTestOrder.Id,
              RecordTypeId = aircraftOrder
        );
        insert cse;
    
        Map<Id, Id> dslAircraftMap = new Map<Id, Id>();
        dslAircraftMap.put(dsl.Id, ac.Id);
        Set<Id> dslIds = L2I_DSLService.countCases4DSLAircraft(dslAircraftMap);
        Test.stopTest();
        
        System.assertEquals(1,dslIds.size() );
    }
}