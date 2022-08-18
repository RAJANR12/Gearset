/**
* @File Name          : L2I_DSLTriggerFunctions_Test.cls
* @Description        : Test Class for L2I_DSLTriggerFunctions
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   :
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class L2I_DSLTriggerFunctions_Test {
//    @IsTest
//    static void testAddDSLClosedOpp() {
//        L2I_DataFactory factory = new L2I_DataFactory();
//        factory.setupTestContext(null, null, false);
//
//        // create objects
//        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
//        objFactory.loadResource('Unit_Test_AccountThruQuote');
//
//        L2I_Competitors__c comp = [SELECT Id, Type__c, Primary__c FROM L2I_Competitors__c LIMIT 1];
//        comp.Type__c = 'IFEC';
//        comp.Primary__c = true;
//        update comp;
//
//        SBQQ__Quote__c quote1 = [SELECT Id, ApprovalStatus__c FROM SBQQ__Quote__c LIMIT 1];
//        quote1.ApprovalStatus__c = 'Approved';
//        update quote1;
//
//        L2I_DSH__c dsh = [SELECT Id, Name FROM L2I_DSH__c LIMIT 1];
//        Opportunity opp = [SELECT Id, Name, L2I_Delivery_Schedule__c, StageName, L2I_Win_Loss_Date__c
//                        FROM Opportunity WHERE Recordtype.DeveloperName = 'Sales' LIMIT 1];
//        opp.L2I_Delivery_Schedule__c = dsh.Id;
//        opp.StageName = 'Closed Won';
//        opp.L2I_Win_Loss_Date__c = Date.Today();
//        update opp;
//
//        L2I_DSL__c dsl = new L2I_DSL__c(
//              Delivery_Date__c = Date.Today(),
//              Seat_End_Date__c = Date.Today(),
//              Head_End_Date__c = Date.Today(),
//              Delivery_Schedule_Header__c = dsh.Id
//        );
//        Test.startTest();
//        String err = '';
//        try {
//            insert dsl;
//        } catch (Exception e){
//            err = e.getMessage();
//        }
//        Test.stopTest();
//        System.assertEquals(true, err.Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//    }
//
//    @IsTest
//    static void testDeleteDSLClosedOpp() {
//        L2I_DataFactory factory = new L2I_DataFactory();
//        factory.setupTestContext(null, null, false);
//
//        // create objects
//        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
//        objFactory.loadResource('Unit_Test_AccountThruQuote');
//
//        L2I_Competitors__c comp = [SELECT Id, Type__c, Primary__c FROM L2I_Competitors__c LIMIT 1];
//        comp.Type__c = 'IFEC';
//        comp.Primary__c = true;
//        update comp;
//
//        SBQQ__Quote__c quote1 = [SELECT Id, ApprovalStatus__c FROM SBQQ__Quote__c LIMIT 1];
//        quote1.ApprovalStatus__c = 'Approved';
//        update quote1;
//
//        L2I_DSH__c dsh = [SELECT Id, Name FROM L2I_DSH__c LIMIT 1];
//        Opportunity opp = [SELECT Id, Name, L2I_Delivery_Schedule__c, StageName, L2I_Win_Loss_Date__c
//        FROM Opportunity WHERE Recordtype.DeveloperName = 'Sales' LIMIT 1];
//        opp.L2I_Delivery_Schedule__c = dsh.Id;
//        opp.StageName = 'Closed Won';
//        opp.L2I_Win_Loss_Date__c = Date.Today();
//        update opp;
//
//
//        L2I_DSL__c dsl = [SELECT Id FROM L2I_DSL__c WHERE Delivery_Schedule_Header__c = :dsh.Id LIMIT 1];
//
//        Test.startTest();
//        String err = '';
//        try {
//            delete dsl;
//        } catch (Exception e){
//            err = e.getMessage();
//        }
//        Test.stopTest();
//        System.assertEquals(true, err.Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//    }
 
    @IsTest
    static void testChat() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');

        // create objects
//        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
//        objFactory.loadResource('Unit_Test_AccountThruQuote');
        Test.startTest();

        Account acct = [SELECT Id FROM Account LIMIT 1];

        Opportunity oppIFEC = [SELECT Id, Name, L2I_Delivery_Schedule__c, StageName, L2I_Win_Loss_Date__c
                FROM Opportunity WHERE Recordtype.DeveloperName = 'Sales' LIMIT 1];

        Opportunity oppDeal = [SELECT Id, Name, L2I_Delivery_Schedule__c, StageName, L2I_Win_Loss_Date__c
                FROM Opportunity WHERE Recordtype.DeveloperName = 'Deal' LIMIT 1];

        L2I_DSH__c dsh = [SELECT Id, Name FROM L2I_DSH__c LIMIT 1];
        dsh.Product_Category__c = 'IFEC';
        update dsh;

        L2I_DSH__c dsh2 = new L2I_DSH__c(
              Product_Category__c = 'DSS',
              Account__c = acct.Id
        );
        insert dsh2;

        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity oppDSS = new Opportunity(
              Name = 'OppDSS',
              StageName = 'Quotation',
              AccountId = acct.Id,
              L2I_Product_Category__c = 'DSS',
              CloseDate = Date.today(),
              RecordTypeId = RecordTypeIdOpportunitySales,
              L2I_Delivery_Schedule__c = dsh2.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppDSS;

        L2I_DSL__c dsl = [SELECT Id FROM L2I_DSL__c WHERE Delivery_Schedule_Header__c = :dsh.Id LIMIT 1];

        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh2.Id,
              Delivery_Date__c = Date.today(),
              IFEC_DSL__c = dsl.Id
        );
        insert dsl2;

        L2I_DSL__c dsl3 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh2.Id,
              Delivery_Date__c = Date.today(),
              IFEC_DSL__c = dsl.Id
        );
        insert dsl3;

        L2I_DSL__c dsl4 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh2.Id,
              Delivery_Date__c = Date.today().addDays(-20)
        );
        insert dsl4;

            delete dsl;
        Test.stopTest();
        System.assertEquals(3, [SELECT COUNT() FROM L2I_DSL__c WHERE Product_Category__c <> 'IFEC' and IFEC_DSL__c = null]);
    }

    @IsTest
    static void testChat2() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');


        // create objects
//        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
//        objFactory.loadResource('Unit_Test_AccountThruQuote');
        Test.startTest();

        Account acct = [SELECT Id FROM Account LIMIT 1];

        Opportunity oppIFEC = [SELECT Id, Name, L2I_Delivery_Schedule__c, StageName, L2I_Win_Loss_Date__c
        FROM Opportunity WHERE Recordtype.DeveloperName = 'Sales' LIMIT 1];

        Opportunity oppDeal = [SELECT Id, Name, L2I_Delivery_Schedule__c, StageName, L2I_Win_Loss_Date__c
        FROM Opportunity WHERE Recordtype.DeveloperName = 'Deal' LIMIT 1];

        L2I_DSH__c dsh = [SELECT Id, Name FROM L2I_DSH__c LIMIT 1];
        dsh.Product_Category__c = 'IFEC';
        update dsh;

        L2I_DSH__c dsh2 = new L2I_DSH__c(
              Product_Category__c = 'DSS',
              Account__c = acct.Id
        );
        insert dsh2;

        L2I_DSH__c dsh3 = new L2I_DSH__c(
              Product_Category__c = 'PTS',
              Account__c = acct.Id
        );
        insert dsh3;

        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity oppDSS = new Opportunity(
              Name = 'OppDSS',
              StageName = 'Quotation',
              AccountId = acct.Id,
              L2I_Product_Category__c = 'DSS',
              CloseDate = Date.today(),
              RecordTypeId = RecordTypeIdOpportunitySales,
              L2I_Delivery_Schedule__c = dsh2.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppDSS;

        Opportunity oppPTS = new Opportunity(
              Name = 'OppPTS',
              StageName = 'Quotation',
              AccountId = acct.Id,
              L2I_Product_Category__c = 'PTS',
              CloseDate = Date.today(),
              RecordTypeId = RecordTypeIdOpportunitySales,
              L2I_Delivery_Schedule__c = dsh3.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppPTS;

        L2I_DSL__c dsl = [SELECT Id FROM L2I_DSL__c WHERE Delivery_Schedule_Header__c = :dsh.Id LIMIT 1];

        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh2.Id,
              Delivery_Date__c = Date.today(),
              IFEC_DSL__c = dsl.Id
        );
        insert dsl2;

        L2I_DSL__c dsl3 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh3.Id,
              Delivery_Date__c = Date.today(),
              IFEC_DSL__c = dsl.Id
        );
        insert dsl3;

        L2I_DSL__c dsl4 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh2.Id,
              Delivery_Date__c = Date.today()
        );
        insert dsl4;
        
        delete dsl;
        Test.stopTest();
        System.assertEquals(3, [SELECT COUNT() FROM L2I_DSL__c WHERE Product_Category__c <> 'IFEC' and IFEC_DSL__c = null]);
    }

    @IsTest
    static void testNoChat() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');

        // create objects
//        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
//        objFactory.loadResource('Unit_Test_AccountThruQuote');
        Test.startTest();

        Account acct = [SELECT Id FROM Account LIMIT 1];

        Opportunity oppDeal = [SELECT Id, Name, L2I_Delivery_Schedule__c, StageName, L2I_Win_Loss_Date__c
                FROM Opportunity WHERE Recordtype.DeveloperName = 'Deal' LIMIT 1];

        Opportunity oppIFEC = [SELECT Id, Name, L2I_Delivery_Schedule__c, StageName, L2I_Win_Loss_Date__c
            FROM Opportunity WHERE Recordtype.DeveloperName = 'Sales' LIMIT 1];

        L2I_DSH__c dsh = [SELECT Id, Name FROM L2I_DSH__c LIMIT 1];
        dsh.Product_Category__c = 'IFEC';
        update dsh;

        L2I_DSH__c dsh2 = new L2I_DSH__c(
              Product_Category__c = 'DSS',
              Account__c = acct.Id
        );
        insert dsh2;

        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity oppDSS = new Opportunity(
              Name = 'OppDSS',
              StageName = 'Quotation',
              AccountId = acct.Id,
              L2I_Product_Category__c = 'DSS',
              CloseDate = Date.today(),
              RecordTypeId = RecordTypeIdOpportunitySales,
              L2I_Delivery_Schedule__c = dsh2.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppDSS;

        L2I_DSL__c dsl = [SELECT Id FROM L2I_DSL__c WHERE Delivery_Schedule_Header__c = :dsh.Id LIMIT 1];


        delete dsl;
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM L2I_DSL__c WHERE Product_Category__c <> 'IFEC' and IFEC_DSL__c = null]);

    }

    @IsTest
    static void testAddIFEC() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');

        // create objects
//        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
//        objFactory.loadResource('Unit_Test_AccountThruQuote');
        Test.startTest();

        Account acct = [SELECT Id FROM Account LIMIT 1];

        Opportunity oppDeal = [SELECT Id, Name, L2I_Delivery_Schedule__c, StageName, L2I_Win_Loss_Date__c
        FROM Opportunity WHERE Recordtype.DeveloperName = 'Deal' LIMIT 1];

        Opportunity oppIFEC = [SELECT Id, Name, L2I_Delivery_Schedule__c, StageName, L2I_Win_Loss_Date__c
        FROM Opportunity WHERE Recordtype.DeveloperName = 'Sales' LIMIT 1];

        L2I_DSH__c dsh = [SELECT Id, Name FROM L2I_DSH__c LIMIT 1];
        dsh.Product_Category__c = 'IFEC';
        update dsh;

        L2I_DSH__c dsh2 = new L2I_DSH__c(
              Product_Category__c = 'DSS',
              Account__c = acct.Id
        );
        insert dsh2;
        L2I_DSH__c dsh3 = new L2I_DSH__c(
              Product_Category__c = 'PTS',
              Account__c = acct.Id
        );
        insert dsh3;

        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity oppDSS = new Opportunity(
              Name = 'OppDSS',
              StageName = 'Quotation',
              AccountId = acct.Id,
              L2I_Product_Category__c = 'DSS',
              CloseDate = Date.today(),
              RecordTypeId = RecordTypeIdOpportunitySales,
              L2I_Delivery_Schedule__c = dsh2.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppDSS;

        Opportunity oppPTS = new Opportunity(
              Name = 'OppPTS',
              StageName = 'Quotation',
              AccountId = acct.Id,
              L2I_Product_Category__c = 'DSS',
              CloseDate = Date.today(),
              RecordTypeId = RecordTypeIdOpportunitySales,
              L2I_Delivery_Schedule__c = dsh3.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppPTS;

        L2I_DSL__c dsl = [SELECT Id FROM L2I_DSL__c WHERE Delivery_Schedule_Header__c = :dsh.Id LIMIT 1];
        L2I_DSL__c dslPTS = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh3.Id,
              Delivery_Date__c = Date.today(),
              IFEC_DSL__c = dsl.Id
        );
        insert dslPTS;

        L2I_DSL__c dslDSS = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh3.Id,
              Delivery_Date__c = Date.today()
        );
        insert dslDSS;

        L2I_DSL__c dslIFEC = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.today()
        );

        insert dslIFEC;
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM L2I_DSL__c WHERE Product_Category__c <> 'IFEC' and IFEC_DSL__c = null]);

    }

    @IsTest
    static void testNotClosed() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');

        // create objects
//        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
//        objFactory.loadResource('Unit_Test_AccountThruQuote');
        Test.startTest();

        L2I_Competitors__c comp = [SELECT Id, Type__c, Primary__c FROM L2I_Competitors__c LIMIT 1];
        comp.Type__c = 'IFEC';
        comp.Primary__c = true;
        update comp;

        L2I_DSH__c dsh = [SELECT Id, Name FROM L2I_DSH__c LIMIT 1];
        Opportunity opp = [SELECT Id, Name, L2I_Delivery_Schedule__c, StageName, L2I_Win_Loss_Date__c
        FROM Opportunity WHERE Recordtype.DeveloperName = 'Sales' LIMIT 1];

        L2I_DSL__c dsl = [SELECT Id FROM L2I_DSL__c WHERE Delivery_Schedule_Header__c = :dsh.Id LIMIT 1];
        
        String err = '';
        try {
            delete dsl;
        } catch (Exception e){
            err = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(false, err.Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    }
    
    @IsTest
    static void testDSLAmendmentOrder() {
    
        System.debug('*** Start Order Trigger Functions Setup');
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
    
        test.startTest();
    
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        Opportunity dealOpp = [SELECT Id FROM Opportunity WHERE RecordType.Developername = 'DEAL' LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
              Name = 'TestSalesOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOpp.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = salesId);
        insert salesOppty;
        Order ord1 = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
//        ord.EffectiveDate = Date.today().addDays(-3);
        ord1.OpportunityId = salesOppty.Id;
        update ord1;
        SBQQ__Quote__c q1 = [
              SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
              FROM SBQQ__Quote__c
              LIMIT 1
        ];
        q1.SBQQ__StartDate__c = Date.today().addDays(-3);
        q1.SBQQ__SubscriptionTerm__c = 12;
        q1.SBQQ__EndDate__c = q1.SBQQ__StartDate__c.addMonths(12);
        update q1;
    
        // create Contract
        Contract ctr = new Contract(
              AccountId = namedCustomer.Id,
              SBQQ__Order__c = ord1.Id,
              SBQQ__Opportunity__c = salesOppty.Id,
              SBQQ__Quote__c = q1.Id,
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              CurrencyIsoCode = 'USD',
              ContractTerm = 24,
              StartDate = Date.today().addMonths(3),
              SBQQ__PreserveBundleStructureUponRenewals__c = true,
              SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
              SBQQ__DefaultRenewalPartners__c = true,
              SBQQ__DefaultRenewalContactRoles__c = true
        );
        insert ctr;
    
        ctr.Status = 'Activated';
        ctr.L2I_Auto_Extend__c = Date.today().addDays(1);
        ctr.ContractTerm = 12;
        ctr.SBQQ__RenewalTerm__c = 12;
        update ctr;
        Id amendId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        Opportunity amend1Opp = new Opportunity(
              Name = 'TestAmend1Opp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = namedCustomer.Id,
              L2I_Parent_Opportunity__c = dealOpp.Id,
              L2I_Product_Category__c = 'DSS',
              SBQQ__AmendedContract__c = ctr.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              RecordTypeId = amendId);
        insert amend1Opp;
        amend1Opp.L2I_Delivery_Schedule__c = dsh.Id;
        update amend1Opp;
        System.debug('*** amendopp ' + [select id, L2I_Delivery_Schedule__c from opportunity where recordtype.developername = 'Amendment']);
    
        SBQQ__Quote__c amendQuote1 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = namedCustomer.Id,
              SBQQ__Opportunity2__c = amend1Opp.Id,
              SBQQ__Primary__c = true
        );
        insert amendQuote1;
    
        amend1Opp.SBQQ__PrimaryQuote__c = amendQuote1.Id;
        update amend1Opp;
        
        Order ord =  [select Id, L2I_Delivery_Schedule__c, Type, OpportunityId from order LIMIT 1];
        ord.Type = 'Amendment';
        ord.OpportunityId = amend1Opp.Id;
        update ord;
        
        L2I_Aircraft_Type__c atype = new L2I_Aircraft_Type__c(
              Name = 'F-18TestThis',
              L2I_PAC_Type_Designator__c = 'ABCD',
              L2I_Model__c = 'GT',
              Manufacturer__c = namedCustomer.Id,
              L2I_Aircraft_Type__c = 'MyTest',
              L2I_Is_Active__c = true,
              L2I_Manufacturer_Party_ID__c = 123456,
              L2I_Make__c = 'ABC',
              L2I_Series__c = 'DEF'
        );
        insert atype;
    
        L2I_Aircraft__c ac = new L2I_Aircraft__c(
              L2I_Aircraft_Status__c = 'In Service',
              Name = 'Test A/C 1',
              L2I_GPIN__c = 'A319-1100',
              L2I_Operator__c = namedCustomer.Id,
              L2I_Serial_Number__c = 'abc12289',
              L2I_Aircraft_Delivery_Date__c = DATE.today().addDays(30),
              Aircraft_Type__c = atype.Id,
              L2I_Approved__c = true
        );
        insert ac;
    
        L2I_DSL__c dsl = [SELECT Id, Aircraft__c, L2I_Aircraft_Confirmation__c, Original_Opportunity__c, Delivery_Schedule_Header__c
        FROM L2I_DSL__c
        LIMIT 1];
        System.debug('*** dsl ' + dsl);
        
        dsl.Aircraft__c = ac.Id;
        dsl.L2I_Aircraft_Confirmation__c = true;
        dsl.Original_Opportunity__c = salesOppty.Id;
        try {
            update dsl;
        } catch (Exception e){
            System.assertEquals(true, e.getMessage().contains('canceled'));
        }
        
        Test.stopTest();
    }
    
   @IsTest
    static void testRecalculatePrimaryQuotes() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
        
        test.startTest();
        
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        Opportunity dealOpp = [SELECT Id FROM Opportunity WHERE RecordType.Developername = 'DEAL' LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
            Name = 'TestSalesOpp',
            StageName = 'Quotation',
            CloseDate = Date.today(),
            L2I_Parent_Opportunity__c = dealOpp.Id,
            L2I_Product_Category__c = 'DSS',
            L2I_Delivery_Schedule__c = dsh.Id,
            RecordTypeId = salesId);
        insert salesOppty;
        
        SBQQ__Quote__c amendQuote1 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = namedCustomer.Id,
              SBQQ__Opportunity2__c = salesOppty.Id,
              SBQQ__Primary__c = true
        );
        insert amendQuote1;
        
        SBQQ__Quote__c amendQuote2 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = namedCustomer.Id,
              SBQQ__Opportunity2__c = salesOppty.Id,
              SBQQ__Primary__c = true
        );
        insert amendQuote2;
        
        amendQuote1.ApprovalStatus__c = 'Pending';
        update amendQuote1;
        
        SBQQ__Quote__c quoteRecord = [Select Id, SBQQ__Primary__c, ApprovalStatus__c, SBQQ__Opportunity2__c 
                                      From SBQQ__Quote__c Where Id = :amendQuote1.Id limit 1];
        
        System.debug(quoteRecord);
        System.assertEquals(true, quoteRecord.SBQQ__Primary__c);
        System.assertEquals('Pending', quoteRecord.ApprovalStatus__c);
        System.assertEquals(salesOppty.Id, quoteRecord.SBQQ__Opportunity2__c);
        
        L2I_DSL__c dsl = [SELECT Id, Aircraft__c, L2I_Aircraft_Confirmation__c, Original_Opportunity__c, 
                          Delivery_Schedule_Header__c, Delivery_Date__c FROM L2I_DSL__c LIMIT 1];
        
        dsl.Delivery_Date__c = Date.newInstance(2022, 10, 12);
        update dsl;
        test.stopTest();
    }
    
     @IsTest 
    static void testPopulateACService() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
        
        test.startTest();
        
        L2I_DSH__c dsh = [SELECT Id, Product_Category__c FROM L2I_DSH__c LIMIT 1];
        
        dsh.Product_Category__c = 'IFEC';
        update dsh;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('1236541','EXW','IFEC','IFE HW', 'X-Series','C');
        insert prodSysType;
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        Opportunity dealOpp = [SELECT Id FROM Opportunity WHERE RecordType.Developername = 'DEAL' LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
            Name = 'TestSalesOpp',
            StageName = 'Quotation',
            CloseDate = Date.today(),
            L2I_Parent_Opportunity__c = dealOpp.Id,
            L2I_Product_Category__c = 'IFEC',
            RecordTypeId = salesId,
            L2I_Primary_System_Type__c = prodSysType.Id);
        insert salesOppty;
        
        Order ord1 = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c, 
                      L2I_1st_Aircraft_Entered_In_Service__c, L2I_1st_AC_Entered_In_Service_Date__c
                      FROM Order LIMIT 1];
        ord1.OpportunityId = salesOppty.Id;
        ord1.L2I_1st_Aircraft_Entered_In_Service__c = false;
        ord1.L2I_1st_AC_Entered_In_Service_Date__c = null;
        update ord1;
        
        SBQQ__Quote__c amendQuote1 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = namedCustomer.Id,
              SBQQ__Opportunity2__c = salesOppty.Id,
              SBQQ__Primary__c = true
        );
        
        insert amendQuote1;
                
        L2I_DSL__c dsl = [SELECT Id, Aircraft__c, L2I_AC_Entered_Into_Service__c, Original_Opportunity__c, 
                          Delivery_Schedule_Header__c, Delivery_Date__c FROM L2I_DSL__c LIMIT 1];
        System.debug('------ dsl: ' + dsl);
        L2I_DSL__c dslchild = new L2I_DSL__c();
        dslchild.Delivery_Schedule_Header__c = dsh.Id;
        dslchild.Delivery_Date__c = Date.today();
        dslchild.Line_Number__c = '01';
        dslchild.IFEC_DSL__c = dsl.Id; 
        insert dslchild;
        System.debug('------ dslchild: ' + dslchild);
        dsl.Original_Opportunity__c = salesOppty.Id;
        dsl.L2I_AC_Entered_Into_Service__c = true;
        dsl.PT_InService_Date__c = Date.newInstance(2022, 01, 01);
        dsl.Hardware_Program_Number__c = '123321';
        update dsl;
        
        test.stopTest();
    }
    /*
	*W-003555
	*/
    @IsTest
    static void testDSLActiveUpdate() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
        
        test.startTest();
        
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        Opportunity dealOpp = [SELECT Id FROM Opportunity WHERE RecordType.Developername = 'DEAL' LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
            Name = 'TestSalesOpp',
            StageName = 'Quotation',
            CloseDate = Date.today(),
            L2I_Parent_Opportunity__c = dealOpp.Id,
            L2I_Product_Category__c = 'DSS',
            L2I_Delivery_Schedule__c = dsh.Id,
            RecordTypeId = salesId);
        insert salesOppty;
        
        SBQQ__Quote__c amendQuote1 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = namedCustomer.Id,
              SBQQ__Opportunity2__c = salesOppty.Id,
              SBQQ__Primary__c = true
        );
        insert amendQuote1;
        
        amendQuote1.ApprovalStatus__c = 'Pending';
        update amendQuote1;
        
        SBQQ__Quote__c quoteRecord = [Select Id, SBQQ__Primary__c, ApprovalStatus__c, SBQQ__Opportunity2__c 
                                      From SBQQ__Quote__c Where Id = :amendQuote1.Id limit 1];
               
        PT_Program__c probj = new PT_Program__c();
        probj.Name = '-AB220001';
        probj.Program_Number__c = '-AB220001';
        insert probj;
        
        L2I_DSL__c dsl = [SELECT Id, Aircraft__c, L2I_Aircraft_Confirmation__c, Original_Opportunity__c, 
                          Delivery_Schedule_Header__c, Delivery_Date__c, PT_isActive__c, PT_Program__c
                          FROM L2I_DSL__c LIMIT 1];
        System.debug('DSL is ' +dsl);
        dsl.PT_Program__c = probj.Id;
        dsl.PT_isActive__c = 'Inactive';
        update dsl;
        
        dsl.PT_isActive__c = 'Active';
        update dsl;
        test.stopTest();
    }
    
    @IsTest 
    static void testUpdateDeliveryDateforRollup() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
        
        test.startTest();
        L2I_DSH__c dsh = [SELECT Id, Product_Category__c FROM L2I_DSH__c LIMIT 1];
        
        dsh.Product_Category__c = 'IFEC';
        update dsh;
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        L2I_DSH__c dsh1 = new L2I_DSH__c(
              Product_Category__c = 'DSS',
              Account__c = namedCustomer.Id
        );
        insert dsh1;
        
        L2I_DSL__c dsl = [SELECT Id, Aircraft__c, L2I_Aircraft_Confirmation__c, Original_Opportunity__c, Product_Category__c, 
                          Delivery_Schedule_Header__c, Delivery_Date__c, PT_isActive__c, PT_Program__c, IFEC_Delivery_Date__c
                          FROM L2I_DSL__c LIMIT 1];
        
        L2I_DSL__c dsl1 = new L2I_DSL__c();
        dsl1.Delivery_Schedule_Header__c = dsh1.Id;
        dsl1.Delivery_Date__c = Date.newInstance(2022, 01, 01);
        dsl1.Line_Number__c = '001';
        dsl1.IFEC_DSL__c = dsl.Id;
        dsl1.Del_Date_for_Rollup__c = Date.newInstance(2022, 01, 01);
        insert dsl1; 
        
        dsl.IFEC_DSL__c = null;
        dsl.Delivery_Date__c = Date.today();
        update dsl;
        System.debug('Dsl record is ' +dsl);
        test.stopTest();
    }
}