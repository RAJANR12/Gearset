@IsTest
private class L2I_QuoteService_Test {

    @IsTest
    static void testQuoteWithDates() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account Name' LIMIT 1];
        Opportunity oppDeal = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'DEAL' LIMIT 1];
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = acct.Id,
              Product_Category__c = 'DSS'
        );
        insert dsh;
        L2I_DSL__c dsl1 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(100)
        );
        insert dsl1;
        L2I_DSL__c dsl1b = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(100),
              Status__c = 'Deleted'
        );
        insert dsl1b;
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(50)
        );
        insert dsl2;
        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity oppty = new Opportunity(
              Name = 'Oppty',
              RecordTypeId = RecordTypeIdOpportunitySales,
              L2I_Product_Category__c = 'DSS',
              StageName = 'Quotation',
              CloseDate = Date.Today(),
              AccountId = acct.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppty;
        // re-add DSH as it is cleared on the Opp on insert to prevent cloning of the Opp and reusing the DSH on multiple Opps
        oppty.L2I_Delivery_Schedule__c = dsh.Id;
        update oppty;
        
        Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;
        SBQQ__Quote__c quote = [
              SELECT
                    Id,
                    SBQQ__StartDate__c,
                    SBQQ__EndDate__c,
                    SBQQ__Opportunity2__c,
                    SBQQ__Opportunity2__r.RecordType.DeveloperName,
                    SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c,
                    SBQQ__SubscriptionTerm__c,
                    L2I_Total_Aircraft_Service_Months__c
              FROM SBQQ__Quote__c
              WHERE Id = :quoteId
        ];
        quote.SBQQ__StartDate__c = Date.Today().addMonths(102);
        quote.SBQQ__EndDate__c = Date.Today().addMonths(152);
        quote.SBQQ__SubscriptionTerm__c = 1;
        quote.SBQQ__Opportunity2__c = oppty.Id;
        update quote;

        Test.startTest();
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quote.Id);
        SBQQ__Quote__c ref = [SELECT Id,L2I_Total_Aircraft_Service_Months__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        System.assertEquals(2, ref.L2I_Total_Aircraft_Service_Months__c);
        Test.stopTest();
    }
    
    @IsTest
    static void testQuoteDelDateLTStartDate() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account Name' LIMIT 1];
        Opportunity oppDeal = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'DEAL' LIMIT 1];
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = acct.Id,
              Product_Category__c = 'DSS'
        );
        insert dsh;
        L2I_DSL__c dsl1 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(2)
        );
        insert dsl1;
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(1)
        );
        insert dsl2;
        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity oppty = new Opportunity(
              Name = 'Oppty',
              RecordTypeId = RecordTypeIdOpportunitySales,
              L2I_Product_Category__c = 'DSS',
              StageName = 'Quotation',
              CloseDate = Date.Today(),
              AccountId = acct.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppty;
        // re-add DSH as it is cleared on the Opp on insert to prevent cloning of the Opp and reusing the DSH on multiple Opps
        oppty.L2I_Delivery_Schedule__c = dsh.Id;
        update oppty;
        
        Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;
        SBQQ__Quote__c quote = [
              SELECT
                    Id,
                    SBQQ__StartDate__c,
                    SBQQ__EndDate__c,
                    SBQQ__Opportunity2__c,
                    SBQQ__Opportunity2__r.RecordType.DeveloperName,
                    SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c,
                    SBQQ__SubscriptionTerm__c,
                    L2I_Total_Aircraft_Service_Months__c
              FROM SBQQ__Quote__c
              WHERE Id = :quoteId
        ];
        quote.SBQQ__StartDate__c = Date.Today().addMonths(5);
        quote.SBQQ__EndDate__c = Date.Today().addMonths(25);
        quote.SBQQ__SubscriptionTerm__c = 1;
        quote.SBQQ__Opportunity2__c = oppty.Id;
        update quote;
        
        Test.startTest();
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quote.Id);
        Test.stopTest();

        System.assertEquals(2, [SELECT Id,L2I_Total_Aircraft_Service_Months__c FROM SBQQ__Quote__c WHERE Id = :quote.Id].L2I_Total_Aircraft_Service_Months__c);
    }
    
    @IsTest
    static void testQuoteNullStartDateSales() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account Name' LIMIT 1];
        Opportunity oppDeal = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'DEAL' LIMIT 1];
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = acct.Id,
              Product_Category__c = 'DSS'
        );
        insert dsh;
        L2I_DSL__c dsl1 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(100)
        );
        insert dsl1;
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(1)
        );
        insert dsl2;
        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity oppty = new Opportunity(
              Name = 'Oppty',
              RecordTypeId = RecordTypeIdOpportunitySales,
              L2I_Product_Category__c = 'DSS',
              StageName = 'Quotation',
              CloseDate = Date.Today(),
              AccountId = acct.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppty;
        // re-add DSH as it is cleared on the Opp on insert to prevent cloning of the Opp and reusing the DSH on multiple Opps
        oppty.L2I_Delivery_Schedule__c = dsh.Id;
        update oppty;
        
        Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;
        SBQQ__Quote__c quote = [
              SELECT
                    Id,
                    SBQQ__StartDate__c,
                    SBQQ__EndDate__c,
                    SBQQ__Opportunity2__c,
                    SBQQ__Opportunity2__r.RecordType.DeveloperName,
                    SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c,
                    SBQQ__SubscriptionTerm__c,
                    L2I_Total_Aircraft_Service_Months__c
              FROM SBQQ__Quote__c
              WHERE Id = :quoteId
        ];
        quote.SBQQ__StartDate__c = null;
        quote.SBQQ__EndDate__c = Date.Today().addMonths(105);
        quote.SBQQ__SubscriptionTerm__c = 1;
        quote.SBQQ__Opportunity2__c = oppty.Id;
        update quote;
        
        Test.startTest();
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quote.Id);
        Test.stopTest();

        System.assertEquals(null, [SELECT Id,L2I_Total_Aircraft_Service_Months__c FROM SBQQ__Quote__c WHERE Id = :quote.Id].L2I_Total_Aircraft_Service_Months__c);
    }
    
    @IsTest
    static void testQuoteNullStartDateAmendment() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account Name' LIMIT 1];
        Opportunity oppDeal = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'DEAL' LIMIT 1];
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = acct.Id,
              Product_Category__c = 'DSS'
        );
        insert dsh;
        L2I_DSL__c dsl1 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(100)
        );
        insert dsl1;
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(1)
        );
        insert dsl2;
        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        Opportunity oppty = new Opportunity(
              Name = 'Oppty',
              RecordTypeId = RecordTypeIdOpportunitySales,
              L2I_Product_Category__c = 'DSS',
              StageName = 'Quotation',
              CloseDate = Date.Today(),
              AccountId = acct.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppty;
        // re-add DSH as it is cleared on the Opp on insert to prevent cloning of the Opp and reusing the DSH on multiple Opps
        oppty.L2I_Delivery_Schedule__c = dsh.Id;
        update oppty;
        
        Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;
        SBQQ__Quote__c quote = [
              SELECT
                    Id,
                    SBQQ__StartDate__c,
                    SBQQ__EndDate__c,
                    SBQQ__Opportunity2__c,
                    SBQQ__Opportunity2__r.RecordType.DeveloperName,
                    SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c,
                    SBQQ__SubscriptionTerm__c,
                    L2I_Total_Aircraft_Service_Months__c
              FROM SBQQ__Quote__c
              WHERE Id = :quoteId
        ];
        quote.SBQQ__StartDate__c = null;
        quote.SBQQ__EndDate__c = Date.Today().addMonths(105);
        quote.SBQQ__SubscriptionTerm__c = 1;
        quote.SBQQ__Opportunity2__c = oppty.Id;
        update quote;
        
        Test.startTest();
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quote.Id);
        Test.stopTest();

        System.assertEquals(109, [SELECT Id,L2I_Total_Aircraft_Service_Months__c FROM SBQQ__Quote__c WHERE Id = :quote.Id].L2I_Total_Aircraft_Service_Months__c);
    }

    @IsTest
    static void testQuoteNullForecastedDateSales() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account Name' LIMIT 1];
        Opportunity oppDeal = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'DEAL' LIMIT 1];
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = acct.Id,
              Product_Category__c = 'DSS'
        );
        insert dsh;
        L2I_DSL__c dsl1 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl1;
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl2;
        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity oppty = new Opportunity(
              Name = 'Oppty',
              RecordTypeId = RecordTypeIdOpportunitySales,
              L2I_Product_Category__c = 'DSS',
              StageName = 'Quotation',
              CloseDate = Date.Today(),
              AccountId = acct.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppty;
        // re-add DSH as it is cleared on the Opp on insert to prevent cloning of the Opp and reusing the DSH on multiple Opps
        oppty.L2I_Delivery_Schedule__c = dsh.Id;
        update oppty;
        
        Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;
        SBQQ__Quote__c quote = [
              SELECT
                    Id,
                    SBQQ__StartDate__c,
                    SBQQ__EndDate__c,
                    SBQQ__Opportunity2__c,
                    SBQQ__Opportunity2__r.RecordType.DeveloperName,
                    SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c,
                    SBQQ__SubscriptionTerm__c,
                    L2I_Total_Aircraft_Service_Months__c
              FROM SBQQ__Quote__c
              WHERE Id = :quoteId
        ];
        quote.SBQQ__StartDate__c = Date.Today();
        quote.SBQQ__EndDate__c = Date.Today().addMonths(105);
        quote.SBQQ__SubscriptionTerm__c = 1;
        quote.SBQQ__Opportunity2__c = oppty.Id;
        update quote;
        
        Test.startTest();
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quote.Id);
        Test.stopTest();

        System.assertEquals(2, [SELECT Id,L2I_Total_Aircraft_Service_Months__c FROM SBQQ__Quote__c WHERE Id = :quote.Id].L2I_Total_Aircraft_Service_Months__c);
    }
    
    @IsTest
    static void testNullStartDateNullForecastAmendment() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account Name' LIMIT 1];
        Opportunity oppDeal = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'DEAL' LIMIT 1];
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = acct.Id,
              Product_Category__c = 'DSS'
        );
        insert dsh;
        L2I_DSL__c dsl1 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl1;
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(1)
        );
        insert dsl2;
        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        Opportunity oppty = new Opportunity(
              Name = 'Oppty',
              RecordTypeId = RecordTypeIdOpportunitySales,
              L2I_Product_Category__c = 'DSS',
              StageName = 'Quotation',
              CloseDate = Date.Today(),
              AccountId = acct.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppty;
        // re-add DSH as it is cleared on the Opp on insert to prevent cloning of the Opp and reusing the DSH on multiple Opps
        oppty.L2I_Delivery_Schedule__c = dsh.Id;
        update oppty;
        
        Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;
        SBQQ__Quote__c quote = [
              SELECT
                    Id,
                    SBQQ__StartDate__c,
                    SBQQ__EndDate__c,
                    SBQQ__Opportunity2__c,
                    SBQQ__Opportunity2__r.RecordType.DeveloperName,
                    SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c,
                    SBQQ__SubscriptionTerm__c,
                    L2I_Total_Aircraft_Service_Months__c
              FROM SBQQ__Quote__c
              WHERE Id = :quoteId
        ];
        quote.SBQQ__StartDate__c = null;
        quote.SBQQ__EndDate__c = Date.Today().addMonths(5);
        quote.SBQQ__SubscriptionTerm__c = 1;
        quote.SBQQ__Opportunity2__c = oppty.Id;
        update quote;
        
        Test.startTest();
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quote.Id);
        Test.stopTest();

        System.assertEquals(4, [SELECT Id,L2I_Total_Aircraft_Service_Months__c FROM SBQQ__Quote__c WHERE Id = :quote.Id].L2I_Total_Aircraft_Service_Months__c);
    }
    
    @IsTest
    static void testQuoteAmendment() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account Name' LIMIT 1];
        Opportunity oppDeal = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'DEAL' LIMIT 1];
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = acct.Id,
              Product_Category__c = 'DSS'
        );
        insert dsh;
        L2I_DSL__c dsl1 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(100)
        );
        insert dsl1;
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(1)
        );
        insert dsl2;
        Id RecordTypeIdOpportunityAmendment = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        Opportunity oppty = new Opportunity(
              Name = 'Oppty',
              RecordTypeId = RecordTypeIdOpportunityAmendment,
              L2I_Product_Category__c = 'DSS',
              StageName = 'Quotation',
              CloseDate = Date.Today(),
              AccountId = acct.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppty;
        // re-add DSH as it is cleared on the Opp on insert to prevent cloning of the Opp and reusing the DSH on multiple Opps
        oppty.L2I_Delivery_Schedule__c = dsh.Id;
        update oppty;
        
        Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;
        SBQQ__Quote__c quote = [
              SELECT
                    Id,
                    SBQQ__StartDate__c,
                    SBQQ__EndDate__c,
                    SBQQ__Opportunity2__c,
                    SBQQ__Opportunity2__r.RecordType.DeveloperName,
                    SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c,
                    SBQQ__SubscriptionTerm__c,
                    L2I_Total_Aircraft_Service_Months__c
              FROM SBQQ__Quote__c
              WHERE Id = :quoteId
        ];
        quote.SBQQ__StartDate__c = Date.Today();
        quote.SBQQ__EndDate__c = Date.Today().addMonths(105);
        quote.SBQQ__SubscriptionTerm__c = 1;
        quote.SBQQ__Opportunity2__c = oppty.Id;
        update quote;
        
        Test.startTest();
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quote.Id);
        Test.stopTest();

        System.assertEquals(109, [SELECT Id,L2I_Total_Aircraft_Service_Months__c FROM SBQQ__Quote__c WHERE Id = :quote.Id].L2I_Total_Aircraft_Service_Months__c);
    }
    
    @IsTest
    static void testNullQuoteId() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account Name' LIMIT 1];
        Opportunity oppDeal = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'DEAL' LIMIT 1];
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = acct.Id,
              Product_Category__c = 'DSS'
        );
        insert dsh;
        L2I_DSL__c dsl1 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(100)
        );
        insert dsl1;
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(1)
        );
        insert dsl2;
        Id RecordTypeIdOpportunityAmendment = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        Opportunity oppty = new Opportunity(
              Name = 'Oppty',
              RecordTypeId = RecordTypeIdOpportunityAmendment,
              L2I_Product_Category__c = 'DSS',
              StageName = 'Quotation',
              CloseDate = Date.Today(),
              AccountId = acct.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppty;
        // re-add DSH as it is cleared on the Opp on insert to prevent cloning of the Opp and reusing the DSH on multiple Opps
        oppty.L2I_Delivery_Schedule__c = dsh.Id;
        update oppty;
        
        Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;
        SBQQ__Quote__c quote = [
              SELECT
                    Id,
                    SBQQ__StartDate__c,
                    SBQQ__EndDate__c,
                    SBQQ__Opportunity2__c,
                    SBQQ__Opportunity2__r.RecordType.DeveloperName,
                    SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c,
                    SBQQ__SubscriptionTerm__c,
                    L2I_Total_Aircraft_Service_Months__c
              FROM SBQQ__Quote__c
              WHERE Id = :quoteId
        ];
        quote.SBQQ__StartDate__c = Date.Today();
        quote.SBQQ__EndDate__c = Date.Today().addMonths(5);
        quote.SBQQ__SubscriptionTerm__c = 1;
        quote.SBQQ__Opportunity2__c = oppty.Id;
        update quote;
        Boolean gotError = false;
        Id nullId = null;
        Test.startTest();
        try {
            L2I_QuoteService.calculateTotalAircraftServiceMonths(nullId);
        } catch (Exception e) {
            gotError = true;
        }
        Test.stopTest();
        System.assert(gotError);
    }

    @IsTest
    static void testNullQuote() {
        SBQQ__Quote__c nullQuote = new SBQQ__Quote__c();
        nullQuote = null;
        Boolean gotError = false;
        Test.startTest();
        try {
            L2I_QuoteService.calculateTotalAircraftServiceMonths(nullQuote);
        } catch (Exception e) {
            gotError = true;
        }
        Test.stopTest();
        System.assert(gotError);
    }

    @IsTest
    static void testNotDSS() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account Name' LIMIT 1];
        Opportunity oppDeal = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'DEAL' LIMIT 1];
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = acct.Id,
              Product_Category__c = 'PTS'
        );
        insert dsh;
        L2I_DSL__c dsl1 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(100)
        );
        insert dsl1;
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(1)
        );
        insert dsl2;
        Id RecordTypeIdOpportunityAmendment = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        Opportunity oppty = new Opportunity(
              Name = 'Oppty',
              RecordTypeId = RecordTypeIdOpportunityAmendment,
              L2I_Parent_Opportunity__c = oppDeal.Id,
              L2I_Product_Category__c = 'PTS',
              StageName = 'Quotation',
              CloseDate = Date.Today(),
              AccountId = acct.Id,
              L2I_Delivery_Schedule__c = dsh.Id
        );
        insert oppty;
        // re-add DSH as it is cleared on the Opp on insert to prevent cloning of the Opp and reusing the DSH on multiple Opps
        oppty.L2I_Delivery_Schedule__c = dsh.Id;
        update oppty;
        
        Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;
        SBQQ__Quote__c quote = [
              SELECT
                    Id,
                    SBQQ__StartDate__c,
                    SBQQ__EndDate__c,
                    SBQQ__Opportunity2__c,
                    SBQQ__Opportunity2__r.RecordType.DeveloperName,
                    SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c,
                    SBQQ__SubscriptionTerm__c,
                    L2I_Total_Aircraft_Service_Months__c
              FROM SBQQ__Quote__c
              WHERE Id = :quoteId
        ];
        quote.SBQQ__StartDate__c = Date.Today();
        quote.SBQQ__EndDate__c = Date.Today().addMonths(5);
        quote.SBQQ__SubscriptionTerm__c = 1;
        quote.SBQQ__Opportunity2__c = oppty.Id;
        update quote;

        Test.startTest();
        // L2I_QuoteService.calculateTotalAircraftServiceMonths(quoteId);
        L2I_TotalAircraftServiceMonthsController.calculateServiceMonths(quote.Id);
        Test.stopTest();

        System.assertEquals(null, [SELECT Id,L2I_Total_Aircraft_Service_Months__c FROM SBQQ__Quote__c WHERE Id = :quote.Id].L2I_Total_Aircraft_Service_Months__c);
    }
    
    @IsTest
    static void testNullTerm() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account Name' LIMIT 1];
        Opportunity oppDeal = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'DEAL' LIMIT 1];
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = acct.Id,
              Product_Category__c = 'DSS'
        );
        insert dsh;
        L2I_DSL__c dsl1 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(100)
        );
        insert dsl1;
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(1)
        );
        insert dsl2;
        Id RecordTypeIdOpportunityAmendment = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        Opportunity oppty = new Opportunity(
              Name = 'Oppty',
              RecordTypeId = RecordTypeIdOpportunityAmendment,
              L2I_Product_Category__c = 'DSS',
              StageName = 'Quotation',
              CloseDate = Date.Today(),
              AccountId = acct.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              L2I_Parent_Opportunity__c = oppDeal.Id
        );
        insert oppty;
        // re-add DSH as it is cleared on the Opp on insert to prevent cloning of the Opp and reusing the DSH on multiple Opps
        oppty.L2I_Delivery_Schedule__c = dsh.Id;
        update oppty;
        
        Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;
        SBQQ__Quote__c quote = [
              SELECT
                    Id,
                    SBQQ__StartDate__c,
                    SBQQ__EndDate__c,
                    SBQQ__Opportunity2__c,
                    SBQQ__Opportunity2__r.RecordType.DeveloperName,
                    SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c,
                    SBQQ__SubscriptionTerm__c,
                    L2I_Total_Aircraft_Service_Months__c
              FROM SBQQ__Quote__c
              WHERE Id = :quoteId
        ];
        quote.SBQQ__StartDate__c = Date.Today();
        quote.SBQQ__EndDate__c = Date.Today().addMonths(5);
        quote.SBQQ__SubscriptionTerm__c = null;
        quote.SBQQ__Opportunity2__c = oppty.Id;
        update quote;
        
        Test.startTest();
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quote.Id);
        Test.stopTest();

        System.assertEquals(4, [SELECT Id,L2I_Total_Aircraft_Service_Months__c FROM SBQQ__Quote__c WHERE Id = :quote.Id].L2I_Total_Aircraft_Service_Months__c);
    }
    
    
    /*
    @IsTest
    static void testQuoteWithDatesBookings2() {
        // testing US2034
        L2I_DataFactory dt = new L2I_DataFactory();
        
        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC System Administrator');
        User salesUser = dt.createTestUser(null, salesProfile.Id, 'Sales', 'User');
        insert salesUser;
        
        test.startTest();  
        System.runAs(salesUser) {
            Account custAcct = dt.createCustomerAccount();
            insert custAcct;
            
            Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
            insert dealOpp;
            Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Quotation', 15, custAcct.Id, dealOpp.Id);
            salesOpp.L2I_Product_Category__c = 'DSS';
            insert salesOpp;
            //        salesOpp.StageName = 'Quotation';
            //        update salesOpp;
            System.debug('*** Sales Opp ' + salesOpp);
            SBQQ__Quote__c quote = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
            quote.L2I_Reviewed_PO_Required__c = true;
            insert quote;
            SBQQ__QuoteTemplate__c qtemplate = new SBQQ__QuoteTemplate__c(Name = 'Test Template');
            insert qtemplate;
            SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
                Name = 'ALT'
            );
            insert sg;
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c(
                SBQQ__SolutionGroup__c = sg.Id,
                SBQQ__Quote__c = quote.Id
            );
            insert qlg;
            
            Product2 product = dt.createProduct('99999802', 'MediaServices', null, null, null);
            product.productCode = 'MCS BUNDLE';
            insert product;
            Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
            
            SBQQ__QuoteLine__c ql = dt.createQuoteLine(quote.Id, prod.Id, null);
            ql.SBQQ__Group__c = qlg.Id;
            insert ql;
            
            L2I_DSH__c dsh = new L2I_DSH__c(
                Account__c = custAcct.Id,
                Product_Category__c = 'DSS'
            );
            insert dsh;
            L2I_DSL__c dsl1 = new L2I_DSL__c(
                Delivery_Schedule_Header__c = dsh.Id,
                Delivery_Date__c = Date.Today().addMonths(5)
            );
            insert dsl1;
            salesOpp.L2I_Delivery_Schedule__c = dsh.Id;
            salesOpp.SBQQ__PrimaryQuote__c = quote.Id;
            update salesOpp;
            
            L2I_DSL__c dsl1b = new L2I_DSL__c(
                Delivery_Schedule_Header__c = dsh.Id,
                Delivery_Date__c = Date.Today().addMonths(5),
                Status__c = 'Deleted'
            );
            insert dsl1b;
            L2I_DSL__c dsl1c = new L2I_DSL__c(
                Delivery_Schedule_Header__c = dsh.Id,
                Delivery_Date__c = Date.Today().addMonths(5),
                Original_Opportunity__c = salesOpp.Id
            );
            insert dsl1c;
            L2I_DSL__c dsl1d = new L2I_DSL__c(
                Delivery_Schedule_Header__c = dsh.Id,
                Delivery_Date__c = Date.Today().addMonths(5),
                Modified_on_Opportunity__c = salesOpp.Id
            );
            insert dsl1d;
            L2I_DSL__c dsl2 = new L2I_DSL__c(
                Delivery_Schedule_Header__c = dsh.Id,
                Delivery_Date__c = Date.Today().addMonths(50)
            );
            insert dsl2;
            L2I_DSL__c dsl3 = new L2I_DSL__c(
                Delivery_Schedule_Header__c = dsh.Id,
                Delivery_Date__c = Date.Today().addMonths(20)
            );
            insert dsl3;
            L2I_DSL__c dsl4 = new L2I_DSL__c(
                Delivery_Schedule_Header__c = dsh.Id,
                Delivery_Date__c = Date.Today().addMonths(24)
            );
            insert dsl4;
            Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
            Opportunity oppty = new Opportunity(
                Name = 'Oppty',
                RecordTypeId = RecordTypeIdOpportunitySales,
                L2I_Product_Category__c = 'DSS',
                StageName = 'Quotation',
                CloseDate = Date.Today(),
                AccountId = custAcct.Id,
                L2I_Delivery_Schedule__c = dsh.Id,
                L2I_Parent_Opportunity__c = dealOpp.Id
            );
            insert oppty;
            // re-add DSH as it is cleared on the Opp on insert to prevent cloning of the Opp and reusing the DSH on multiple Opps
            oppty.L2I_Delivery_Schedule__c = dsh.Id;
            update oppty;
            
            quote.SBQQ__StartDate__c = Date.Today().addMonths(102);
            quote.SBQQ__EndDate__c = Date.Today().addMonths(152);
            quote.SBQQ__SubscriptionTerm__c = 1;
            update quote;
            
            System.debug('*** salesOpp ' + salesOpp);
            Order ord = new Order(AccountId = custAcct.Id,
                                  PoNumber = 'Test',
                                  EffectiveDate = Date.today(),
                                  Status = 'Draft',
                                  Pricebook2Id = Test.getStandardPricebookId(),
                                  blng__BillingDayOfMonth__c = '30',
                                  OpportunityId = salesOpp.Id,
                                  SBQQ__Quote__c = quote.Id,
                                  L2I_Delivery_Schedule__c = dsh.Id,
                                  L2I_AutoActivate__c = true,
                                  L2I_Product_Category_2__c = 'games',
                                  L2I_Order_Process__c = 'Contract Management',
                                  Type = 'New');
            insert ord;
            
            Contract ctr = new Contract(AccountId = custAcct.Id, SBQQ__Order__c = ord.Id, SBQQ__Opportunity__c = salesOpp.Id, SBQQ__RenewalOpportunity__c = salesOpp.Id, SBQQ__Quote__c = quote.Id,
                                        Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(), CurrencyIsoCode = 'USD', ContractTerm = 24,
                                        StartDate = Date.today().addMonths(3), SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
                                        SBQQ__DefaultRenewalPartners__c = true, SBQQ__DefaultRenewalContactRoles__c = true);
            insert ctr;
            Opportunity dealOpp2 = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DEAL' LIMIT 1];
            Id renewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            Opportunity renew2Opp = new Opportunity(
                Name = 'TestRenew2Opp',
                StageName = 'Quotation',
                CloseDate = Date.today(),
                AccountId = custAcct.Id,
                L2I_Parent_Opportunity__c = dealOpp2.Id,
                L2I_Product_Category__c = 'DSS',
                SBQQ__RenewedContract__c = ctr.Id,
                L2I_Delivery_Schedule__c = dsh.Id,
                RecordTypeId = renewId);
            insert renew2Opp;
            L2I_DSL__c dsl1e = new L2I_DSL__c(
                Delivery_Schedule_Header__c = dsh.Id,
                Delivery_Date__c = Date.Today().addMonths(5),
                Original_Opportunity__c = renew2Opp.Id
            );
            insert dsl1e;
            L2I_DSL__c dsl1f = new L2I_DSL__c(
                Delivery_Schedule_Header__c = dsh.Id,
                Delivery_Date__c = Date.Today().addMonths(5),
                Modified_on_Opportunity__c = renew2Opp.Id
            );
            insert dsl1f;
            
            SBQQ__Quote__c quote2 = new SBQQ__Quote__c(
                RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
                SBQQ__Account__c = custacct.Id,
                SBQQ__Opportunity2__c = renew2Opp.Id,
                SBQQ__Primary__c = true,
                SBQQ__StartDate__c = Date.today().addMonths(22)
            );
            insert quote2;
            
            
            renew2Opp.SBQQ__PrimaryQuote__c = quote2.Id;
            update renew2Opp;
            
            L2I_QuoteService.calculateTotalAircraftServiceMonths(quote2.Id);
            
            
            System.assertEquals(5,
                                [SELECT Id, L2I_Bookings_Adj_Subscription_Term__c FROM SBQQ__Quote__c WHERE Id = :quote2.Id].L2I_Bookings_Adj_Subscription_Term__c);
            System.assertEquals(0,
                                [SELECT Id, L2I_Booking_Adj_AC_Service_Months__c FROM SBQQ__Quote__c WHERE Id = :quote2.Id].L2I_Booking_Adj_AC_Service_Months__c);
        }
            
        
        
        Test.stopTest();
    }*/
    
    @IsTest
    static void testSubscriptionTotalACServMths() {
        // testing US2034
        L2I_DataFactory dt = new L2I_DataFactory();
        
        Account custAcct = dt.createCustomerAccount();
        insert custAcct;
        Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
        insert dealOpp;
        Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Quotation', 15, custAcct.Id, dealOpp.Id);
        salesOpp.L2I_Product_Category__c = 'DSS';
        insert salesOpp;
        SBQQ__Quote__c quote = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__StartDate__c = Date.Today().addMonths(102);
        quote.SBQQ__EndDate__c = Date.Today().addMonths(152);
        quote.SBQQ__SubscriptionTerm__c = 1;
        insert quote;
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = custAcct.Id,
              Product_Category__c = 'DSS'
        );
        insert dsh;
        L2I_DSL__c dsl1 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(5)
        );
        insert dsl1;
        salesOpp.L2I_Delivery_Schedule__c = dsh.Id;
        salesOpp.SBQQ__PrimaryQuote__c = quote.Id;
        update salesOpp;
        
        L2I_DSL__c dsl1b = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(5),
              Status__c = 'Deleted'
        );
        insert dsl1b;
        L2I_DSL__c dsl1c = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(5),
              Original_Opportunity__c = salesOpp.Id
        );
        insert dsl1c;
        L2I_DSL__c dsl1d = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(5),
              Modified_on_Opportunity__c = salesOpp.Id
        );
        insert dsl1d;
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(50)
        );
        insert dsl2;
        L2I_DSL__c dsl3 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(20)
        );
        insert dsl3;
        L2I_DSL__c dsl4 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(24)
        );
        insert dsl4;
        
        Order ord = new Order(AccountId = custAcct.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOpp.Id,
              SBQQ__Quote__c = quote.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              L2I_AutoActivate__c = true,
              L2I_Product_Category_2__c = 'games',
              L2I_Order_Process__c = 'Contract Management',
              Type = 'New');
        insert ord;
        Contract ctr = new Contract(AccountId = custAcct.Id, SBQQ__Order__c = ord.Id, SBQQ__Opportunity__c = salesOpp.Id, SBQQ__RenewalOpportunity__c = salesOpp.Id, SBQQ__Quote__c = quote.Id,
              Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(), CurrencyIsoCode = 'USD', ContractTerm = 24,
              StartDate = Date.today().addMonths(3), SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
              SBQQ__DefaultRenewalPartners__c = true, SBQQ__DefaultRenewalContactRoles__c = true);
        insert ctr;
        
        Product2 product = dt.createProduct('99999802', 'MediaServices', null, null, null);
        product.productCode = 'MCS BUNDLE';
        insert product;
        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
        
        SBQQ__QuoteLine__c ql = dt.createQuoteLine(quote.Id, prod.Id, null);
        ql.L2I_CPQMultiplier__c = 'Contracted Shipments';
        ql.L2I_Number_of_Shipments__c = 5;
        ql.SBQQ__SubscriptionTerm__c = 12;
        ql.L2I_MonthlyPrice2__c = 20;
        insert ql;
        
        Test.startTest();
        
        List<OrderItem> oiList = new List<OrderItem>();
        oiList = [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c];
        
        Id renewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Opportunity renew2Opp = new Opportunity(
              Name = 'TestRenew2Opp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = custAcct.Id,
              L2I_Parent_Opportunity__c = dealOpp.Id,
              L2I_Product_Category__c = 'DSS',
              SBQQ__RenewedContract__c = ctr.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              RecordTypeId = renewId);
        insert renew2Opp;
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = custAcct.Id,
              SBQQ__Opportunity2__c = renew2Opp.Id,
              SBQQ__Primary__c = true,
              SBQQ__SubscriptionTerm__c = 12,
              SBQQ__StartDate__c = Date.today().addMonths(22)
        );
        insert quote2;
        renew2Opp.SBQQ__PrimaryQuote__c = quote2.Id;
        update renew2Opp;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
            SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
            obj.SBQQ__Account__c = custacct.Id;
            obj.SBQQ__Product__c = oi.Product2Id;
            obj.SBQQ__Contract__c = ctr.Id;
            obj.SBQQ__Quantity__c = 10.00;
            obj.SBQQ__ProductSubscriptionType__c = 'Renewable';
            obj.SBQQ__SubscriptionType__c = 'Renewable';
            obj.SBQQ__SubscriptionEndDate__c = Date.today().addDays(5);
            obj.SBQQ__OrderProduct__c = oi.Id;
            obj.L2I_blng_MatchingId__c = oi.L2I_blng_MatchingId__c;
            obj.SBQQ__QuoteLine__c = ql.Id;
            subList.add(obj);
        }
        insert subList;
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quote2.Id);
        Test.stopTest();
        
        System.assertEquals(0,
              [SELECT Id, L2I_Bookings_Adj_Amount__c FROM SBQQ__Quote__c WHERE Id = :quote2.Id].L2I_Bookings_Adj_Amount__c);
    }
    
    @IsTest
    static void testSubscriptionContractedShipments2() {
        // testing US2034
        L2I_DataFactory dt = new L2I_DataFactory();
        
        Account custAcct = dt.createCustomerAccount();
        insert custAcct;
        Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
        insert dealOpp;
        Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Quotation', 15, custAcct.Id, dealOpp.Id);
        salesOpp.L2I_Product_Category__c = 'DSS';
        insert salesOpp;
        SBQQ__Quote__c quote = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__StartDate__c = Date.Today().addMonths(102);
        quote.SBQQ__EndDate__c = Date.Today().addMonths(152);
        quote.SBQQ__SubscriptionTerm__c = 1;
        insert quote;
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = custAcct.Id,
              Product_Category__c = 'DSS'
        );
        insert dsh;
        L2I_DSL__c dsl1 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(5)
        );
        insert dsl1;
        salesOpp.L2I_Delivery_Schedule__c = dsh.Id;
        salesOpp.SBQQ__PrimaryQuote__c = quote.Id;
        update salesOpp;
        
        L2I_DSL__c dsl1b = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(5),
              Status__c = 'Deleted'
        );
        insert dsl1b;
        L2I_DSL__c dsl1c = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(5),
              Original_Opportunity__c = salesOpp.Id
        );
        insert dsl1c;
        L2I_DSL__c dsl1d = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(5),
              Modified_on_Opportunity__c = salesOpp.Id
        );
        insert dsl1d;
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(50)
        );
        insert dsl2;
        L2I_DSL__c dsl3 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(20)
        );
        insert dsl3;
        L2I_DSL__c dsl4 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(24)
        );
        insert dsl4;
        
        Order ord = new Order(AccountId = custAcct.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOpp.Id,
              SBQQ__Quote__c = quote.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              L2I_AutoActivate__c = true,
              L2I_Product_Category_2__c = 'games',
              L2I_Order_Process__c = 'Contract Management',
              Type = 'New');
        insert ord;
        Contract ctr = new Contract(AccountId = custAcct.Id, SBQQ__Order__c = ord.Id, SBQQ__Opportunity__c = salesOpp.Id, SBQQ__RenewalOpportunity__c = salesOpp.Id, SBQQ__Quote__c = quote.Id,
              Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(), CurrencyIsoCode = 'USD', ContractTerm = 24,
              StartDate = Date.today().addMonths(3), SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
              SBQQ__DefaultRenewalPartners__c = true, SBQQ__DefaultRenewalContactRoles__c = true);
        insert ctr;
        
        Product2 product = dt.createProduct('99999802', 'MediaServices', null, null, null);
        product.productCode = 'MCS BUNDLE';
        insert product;
        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
        
        SBQQ__QuoteLine__c ql = dt.createQuoteLine(quote.Id, prod.Id, null);
        ql.L2I_CPQMultiplier__c = 'Contracted Shipments';
        ql.L2I_Number_of_Shipments__c = 5;
        ql.SBQQ__SubscriptionTerm__c = 12;
        ql.L2I_MonthlyPrice2__c = 20;
        insert ql;
        
        Test.startTest();
        
        List<OrderItem> oiList = new List<OrderItem>();
        oiList = [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c];
        
        Id renewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Opportunity renew2Opp = new Opportunity(
              Name = 'TestRenew2Opp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = custAcct.Id,
              L2I_Parent_Opportunity__c = dealOpp.Id,
              L2I_Product_Category__c = 'DSS',
              SBQQ__RenewedContract__c = ctr.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              RecordTypeId = renewId);
        insert renew2Opp;
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = custAcct.Id,
              SBQQ__Opportunity2__c = renew2Opp.Id,
              SBQQ__Primary__c = true,
              SBQQ__SubscriptionTerm__c = 12,
              SBQQ__StartDate__c = Date.today().addMonths(22)
        );
        insert quote2;
        renew2Opp.SBQQ__PrimaryQuote__c = quote2.Id;
        update renew2Opp;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
            SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
            obj.SBQQ__Account__c = custacct.Id;
            obj.SBQQ__Product__c = oi.Product2Id;
            obj.SBQQ__Contract__c = ctr.Id;
            obj.SBQQ__Quantity__c = 10.00;
            obj.SBQQ__ProductSubscriptionType__c = 'Renewable';
            obj.SBQQ__SubscriptionType__c = 'Renewable';
            obj.SBQQ__SubscriptionEndDate__c = Date.today().addDays(5);
            obj.SBQQ__OrderProduct__c = oi.Id;
            obj.L2I_blng_MatchingId__c = oi.L2I_blng_MatchingId__c;
            obj.SBQQ__QuoteLine__c = ql.Id;
            subList.add(obj);
        }
        insert subList;
        
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quote2.Id);
        Test.stopTest();
        
        System.assertEquals(58, // Updated from 42 to 58 by Khrisna for W-003955
              [SELECT Id, L2I_Total_Aircraft_Service_Months__c FROM SBQQ__Quote__c WHERE Id = :quote2.Id].L2I_Total_Aircraft_Service_Months__c);
    }
    
    @IsTest
    static void testSubscriptionQuoteSubTerm() {
        // testing US2034
        L2I_DataFactory dt = new L2I_DataFactory();
        
        Account custAcct = dt.createCustomerAccount();
        insert custAcct;
        Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
        insert dealOpp;
        Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Quotation', 15, custAcct.Id, dealOpp.Id);
        salesOpp.L2I_Product_Category__c = 'DSS';
        insert salesOpp;
        SBQQ__Quote__c quote = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__StartDate__c = Date.Today().addMonths(102);
        quote.SBQQ__EndDate__c = Date.Today().addMonths(152);
        quote.SBQQ__SubscriptionTerm__c = 1;
        insert quote;
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = custAcct.Id,
              Product_Category__c = 'DSS'
        );
        insert dsh;
        L2I_DSL__c dsl1 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(5)
        );
        insert dsl1;
        salesOpp.L2I_Delivery_Schedule__c = dsh.Id;
        salesOpp.SBQQ__PrimaryQuote__c = quote.Id;
        update salesOpp;
        
        L2I_DSL__c dsl1b = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(5),
              Status__c = 'Deleted'
        );
        insert dsl1b;
        L2I_DSL__c dsl1c = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(5),
              Original_Opportunity__c = salesOpp.Id
        );
        insert dsl1c;
        L2I_DSL__c dsl1d = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(5),
              Modified_on_Opportunity__c = salesOpp.Id
        );
        insert dsl1d;
        L2I_DSL__c dsl2 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(50)
        );
        insert dsl2;
        L2I_DSL__c dsl3 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(20)
        );
        insert dsl3;
        L2I_DSL__c dsl4 = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              Delivery_Date__c = Date.Today().addMonths(24)
        );
        insert dsl4;
        
        Order ord = new Order(AccountId = custAcct.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOpp.Id,
              SBQQ__Quote__c = quote.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              L2I_AutoActivate__c = true,
              L2I_Product_Category_2__c = 'games',
              L2I_Order_Process__c = 'Contract Management',
              Type = 'New');
        insert ord;
        Contract ctr = new Contract(AccountId = custAcct.Id, SBQQ__Order__c = ord.Id, SBQQ__Opportunity__c = salesOpp.Id, SBQQ__RenewalOpportunity__c = salesOpp.Id, SBQQ__Quote__c = quote.Id,
              Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(), CurrencyIsoCode = 'USD', ContractTerm = 24,
              StartDate = Date.today().addMonths(3), SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
              SBQQ__DefaultRenewalPartners__c = true, SBQQ__DefaultRenewalContactRoles__c = true);
        insert ctr;
        
        Product2 product = dt.createProduct('99999802', 'MediaServices', null, null, null);
        product.productCode = 'MCS BUNDLE';
        insert product;
        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
        
        SBQQ__QuoteLine__c ql = dt.createQuoteLine(quote.Id, prod.Id, null);
        ql.L2I_CPQMultiplier__c = 'Contracted Shipments';
        ql.L2I_Number_of_Shipments__c = 5;
        ql.SBQQ__SubscriptionTerm__c = 12;
        ql.L2I_MonthlyPrice2__c = 20;
        insert ql;
        
        Test.startTest();
        
        List<OrderItem> oiList = new List<OrderItem>();
        oiList = [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c];
        
        Id renewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Opportunity renew2Opp = new Opportunity(
              Name = 'TestRenew2Opp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = custAcct.Id,
              L2I_Parent_Opportunity__c = dealOpp.Id,
              L2I_Product_Category__c = 'DSS',
              SBQQ__RenewedContract__c = ctr.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              RecordTypeId = renewId);
        insert renew2Opp;
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = custAcct.Id,
              SBQQ__Opportunity2__c = renew2Opp.Id,
              SBQQ__Primary__c = true,
              SBQQ__SubscriptionTerm__c = 12,
              SBQQ__StartDate__c = Date.today().addMonths(22)
        );
        insert quote2;
        renew2Opp.SBQQ__PrimaryQuote__c = quote2.Id;
        update renew2Opp;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
            SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
            obj.SBQQ__Account__c = custacct.Id;
            obj.SBQQ__Product__c = oi.Product2Id;
            obj.SBQQ__Contract__c = ctr.Id;
            obj.SBQQ__Quantity__c = 10.00;
            obj.SBQQ__ProductSubscriptionType__c = 'Renewable';
            obj.SBQQ__SubscriptionType__c = 'Renewable';
            obj.SBQQ__SubscriptionEndDate__c = Date.today().addDays(5);
            obj.SBQQ__OrderProduct__c = oi.Id;
            obj.L2I_blng_MatchingId__c = oi.L2I_blng_MatchingId__c;
            obj.SBQQ__QuoteLine__c = ql.Id;
            subList.add(obj);
        }
        insert subList;
        
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quote2.Id);
        Test.stopTest();
        
        System.assertEquals(23,
              [SELECT Id, L2I_Booking_Adj_AC_Service_Months__c FROM SBQQ__Quote__c WHERE Id = :quote2.Id].L2I_Booking_Adj_AC_Service_Months__c);
    }
    
    @IsTest
    static void testSubscriptionACQty() {
        // testing US2034
        L2I_DataFactory dt = new L2I_DataFactory();
        
        Account custAcct = dt.createCustomerAccount();
        insert custAcct;
        Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
        insert dealOpp;
        Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Quotation', 15, custAcct.Id, dealOpp.Id);
        salesOpp.L2I_Product_Category__c = 'DSS';
        insert salesOpp;
        System.debug('*** Sales Opp ' + salesOpp);
        SBQQ__Quote__c quote = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
        quote.L2I_Reviewed_PO_Required__c = true;
        insert quote;
        SBQQ__QuoteTemplate__c qtemplate = new SBQQ__QuoteTemplate__c(Name = 'Test Template');
        insert qtemplate;
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c(
              SBQQ__SolutionGroup__c = sg.Id,
              SBQQ__Quote__c = quote.Id
        );
        insert qlg;
        
        Product2 product = dt.createProduct('99999802', 'MediaServices', null, null, null);
        product.productCode = 'MCS BUNDLE';
        insert product;
        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
        
        SBQQ__QuoteLine__c ql = dt.createQuoteLine(quote.Id, prod.Id, null);
        ql.SBQQ__Group__c = qlg.Id;
        insert ql;
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = custAcct.Id,
              Product_Category__c = 'DSS'
        );
        insert dsh;
        
        quote.SBQQ__StartDate__c = Date.Today().addMonths(102);
        quote.SBQQ__EndDate__c = Date.Today().addMonths(152);
        quote.SBQQ__SubscriptionTerm__c = 1;
        update quote;
        
        System.debug('*** salesOpp ' + salesOpp);
        Order ord = new Order(AccountId = custAcct.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOpp.Id,
              SBQQ__Quote__c = quote.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              L2I_AutoActivate__c = true,
              L2I_Product_Category_2__c = 'games',
              L2I_Order_Process__c = 'Contract Management',
              Type = 'New');
        insert ord;
        
        Contract ctr = new Contract(AccountId = custAcct.Id, SBQQ__Order__c = ord.Id, SBQQ__Opportunity__c = salesOpp.Id, SBQQ__RenewalOpportunity__c = salesOpp.Id, SBQQ__Quote__c = quote.Id,
              Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(), CurrencyIsoCode = 'USD', ContractTerm = 24,
              StartDate = Date.today().addMonths(3), SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
              SBQQ__DefaultRenewalPartners__c = true, SBQQ__DefaultRenewalContactRoles__c = true);
        insert ctr;
        Test.startTest();
        
        List<OrderItem> oiList = new List<OrderItem>();
        oiList = [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c];
        Id renewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Opportunity renew2Opp = new Opportunity(
              Name = 'TestRenew2Opp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = custAcct.Id,
              L2I_Parent_Opportunity__c = dealOpp.Id,
              L2I_Product_Category__c = 'DSS',
              SBQQ__RenewedContract__c = ctr.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              RecordTypeId = renewId);
        insert renew2Opp;
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = custAcct.Id,
              SBQQ__Opportunity2__c = renew2Opp.Id,
              SBQQ__Primary__c = true,
              SBQQ__StartDate__c = Date.today().addMonths(22)
        );
        insert quote2;
        renew2Opp.SBQQ__PrimaryQuote__c = quote2.Id;
        update renew2Opp;
        
        ql.L2I_CPQMultiplier__c = 'AC Qty';
        ql.L2I_Number_of_Shipments__c = 5;
        ql.SBQQ__SubscriptionTerm__c = 12;
        ql.L2I_MonthlyPrice2__c = 20;
        update ql;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
            SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
            obj.SBQQ__Account__c = custAcct.Id;
            obj.SBQQ__Product__c = oi.Product2Id;
            obj.SBQQ__Contract__c = ctr.Id;
            obj.SBQQ__Quantity__c = 10.00;
            obj.SBQQ__ProductSubscriptionType__c = 'Renewable';
            obj.SBQQ__SubscriptionType__c = 'Renewable';
            obj.SBQQ__SubscriptionEndDate__c = Date.today().addDays(5);
            obj.SBQQ__OrderProduct__c = oi.Id;
            obj.L2I_blng_MatchingId__c = oi.L2I_blng_MatchingId__c;
            obj.SBQQ__QuoteLine__c = ql.Id;
            subList.add(obj);
        }
        insert subList;
        
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quote2.Id);
        Test.stopTest();
        
        System.assertEquals(0,
              [SELECT Id, L2I_Bookings_Adj_Amount__c FROM SBQQ__Quote__c WHERE Id = :quote2.Id].L2I_Bookings_Adj_Amount__c);
    }
    
    
    @IsTest
    static void testSubscriptionElse() {
        // testing US2034
        L2I_DataFactory dt = new L2I_DataFactory();
        
        Account custAcct = dt.createCustomerAccount();
        insert custAcct;
        Opportunity dealOpp = dt.createDealOpportunity('DealOpp', 'Open', 15, custAcct.Id);
        insert dealOpp;
        Opportunity salesOpp = dt.createSalesOpportunity('SalesOpp', 'Quotation', 15, custAcct.Id, dealOpp.Id);
        salesOpp.L2I_Product_Category__c = 'DSS';
        insert salesOpp;
//        salesOpp.StageName = 'Quotation';
//        update salesOpp;
        System.debug('*** Sales Opp ' + salesOpp);
        SBQQ__Quote__c quote = dt.createQuote('draft', custAcct.Id, salesOpp.Id, true);
        quote.L2I_Reviewed_PO_Required__c = true;
        insert quote;
        SBQQ__QuoteTemplate__c qtemplate = new SBQQ__QuoteTemplate__c(Name = 'Test Template');
        insert qtemplate;
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'ALT'
        );
        insert sg;
        SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c(
              SBQQ__SolutionGroup__c = sg.Id,
              SBQQ__Quote__c = quote.Id
        );
        insert qlg;
        
        Product2 product = dt.createProduct('99999802', 'MediaServices', null, null, null);
        product.productCode = 'MCS BUNDLE';
        insert product;
        Product2 prod = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
        
        SBQQ__QuoteLine__c ql = dt.createQuoteLine(quote.Id, prod.Id, null);
        ql.SBQQ__Group__c = qlg.Id;
        insert ql;
        L2I_DSH__c dsh = new L2I_DSH__c(
              Account__c = custAcct.Id,
              Product_Category__c = 'DSS'
        );
        insert dsh;
        
        quote.SBQQ__StartDate__c = Date.Today().addMonths(102);
        quote.SBQQ__EndDate__c = Date.Today().addMonths(152);
        quote.SBQQ__SubscriptionTerm__c = 1;
        update quote;
        
        System.debug('*** salesOpp ' + salesOpp);
        Order ord = new Order(AccountId = custAcct.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOpp.Id,
              SBQQ__Quote__c = quote.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              L2I_AutoActivate__c = true,
              L2I_Product_Category_2__c = 'games',
              L2I_Order_Process__c = 'Contract Management',
              Type = 'New');
        insert ord;
        
        Contract ctr = new Contract(AccountId = custAcct.Id, SBQQ__Order__c = ord.Id, SBQQ__Opportunity__c = salesOpp.Id, SBQQ__RenewalOpportunity__c = salesOpp.Id, SBQQ__Quote__c = quote.Id,
              Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(), CurrencyIsoCode = 'USD', ContractTerm = 24,
              StartDate = Date.today().addMonths(3), SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
              SBQQ__DefaultRenewalPartners__c = true, SBQQ__DefaultRenewalContactRoles__c = true);
        insert ctr;
        Test.startTest();
        
        List<OrderItem> oiList = new List<OrderItem>();
        oiList = [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c];
        System.debug('----- oiList: ' + oiList);
        Id renewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Opportunity renew2Opp = new Opportunity(
              Name = 'TestRenew2Opp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = custAcct.Id,
              L2I_Parent_Opportunity__c = dealOpp.Id,
              L2I_Product_Category__c = 'DSS',
              SBQQ__RenewedContract__c = ctr.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              RecordTypeId = renewId);
        insert renew2Opp;
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = custAcct.Id,
              SBQQ__Opportunity2__c = renew2Opp.Id,
              SBQQ__Primary__c = true,
              SBQQ__StartDate__c = Date.today().addMonths(22)
        );
        insert quote2;
        renew2Opp.SBQQ__PrimaryQuote__c = quote2.Id;
        update renew2Opp;
        ql.L2I_Number_of_Shipments__c = 5;
        ql.SBQQ__SubscriptionTerm__c = 12;
        ql.L2I_MonthlyPrice2__c = 20;
        
        update ql;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
            SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
            obj.SBQQ__Account__c = custAcct.Id;
            obj.SBQQ__Product__c = oi.Product2Id;
            obj.SBQQ__Contract__c = ctr.Id;
            obj.SBQQ__Quantity__c = 10.00;
            obj.SBQQ__ProductSubscriptionType__c = 'Renewable';
            obj.SBQQ__SubscriptionType__c = 'Renewable';
            obj.SBQQ__SubscriptionEndDate__c = Date.today().addDays(5);
            obj.SBQQ__OrderProduct__c = oi.Id;
            obj.L2I_blng_MatchingId__c = oi.L2I_blng_MatchingId__c;
            obj.SBQQ__QuoteLine__c = ql.Id;
            subList.add(obj);
        }
        insert subList;
        
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quote2.Id);
        Test.stopTest();
        
        System.assertEquals(0,
              [SELECT Id, L2I_Bookings_Adj_Amount__c FROM SBQQ__Quote__c WHERE Id = :quote2.Id].L2I_Bookings_Adj_Amount__c);
    }
    
//    @isTest
//    static void testBuildRev() {
//        L2I_DataFactory factory = new L2I_DataFactory();
//
//        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
//        insert acc;
//        System.assert(acc.Id != null, 'Named Customer Account must have an Id');
//
//        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
//        insert dealOpp;
//        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');
//
//        L2I_DSH__c dsh = new L2I_DSH__c(
//              Account__c = acc.Id,
//              Product_Category__c = 'IFEC'
//        );
//        insert dsh;
//
//        L2I_Aircraft_Type__c atype = new L2I_Aircraft_Type__c(
//              Name = 'F-18TestThis',
//              L2I_PAC_Type_Designator__c = 'ABCD',
//              L2I_Model__c = 'GT',
//              Manufacturer__c = acc.Id,
//              L2I_Aircraft_Type__c = 'MyTest',
//              L2I_Is_Active__c = true,
//              L2I_Manufacturer_Party_ID__c = 123456,
//              L2I_Make__c = 'ABC',
//              L2I_Series__c = 'DEF'
//        );
//        insert atype;
//
//        L2I_Aircraft__c ac = new L2I_Aircraft__c(
//              L2I_Aircraft_Status__c = 'In Service',
//              Name = 'Test A/C 1',
//              L2I_GPIN__c = 'A319-1100',
//              L2I_Operator__c = acc.Id,
//              L2I_Serial_Number__c = 'abc12289',
//              L2I_Aircraft_Delivery_Date__c = DATE.today().addDays(30),
//              Aircraft_Type__c = atype.Id,
//              L2I_Approved__c = true
//        );
//        insert ac;
//
//        L2I_Aircraft__c ac2 = new L2I_Aircraft__c(
//              L2I_Aircraft_Status__c = 'In Service',
//              Name = 'Test A/C 2',
//              L2I_GPIN__c = 'A319-1100',
//              L2I_Operator__c = acc.Id,
//              L2I_Serial_Number__c = 'abc12289',
//              L2I_Aircraft_Delivery_Date__c = DATE.today().addDays(30),
//              Aircraft_Type__c = atype.Id,
//              L2I_Approved__c = true
//        );
//        insert ac2;
//
//        L2I_DSL__c dsl = new L2I_DSL__c(
//              Delivery_Schedule_Header__c = dsh.Id,
//              Delivery_Date__c = Date.Today().addMonths(100),
//              Aircraft__c = ac2.Id
//        );
//        insert dsl;
//
//        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Delivery', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
//        salesOpp.L2I_Product_Category__c = 'IFEC';
//        salesOpp.PT_Part_List_Name__c = 'PL Name';
//        insert salesOpp;
//        salesOpp.L2I_Delivery_Schedule__c = dsh.Id;
//        update salesOpp;
//
//        SBQQ__Quote__c quote = factory.createQuote('draft', acc.Id, salesOpp.Id, false);
//        insert quote;
//
//        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
//              Name = 'ALT'
//        );
//        insert sg;
//        SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c(
//              SBQQ__SolutionGroup__c = sg.Id,
//              SBQQ__Quote__c = quote.Id
//        );
//        insert qlg;
//
//        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test Billable Rule', blng__InitialBillingTrigger__c = 'Order Product Activation Date', blng__PartialPeriodTreatment__c = 'Separate', blng__AmendmentBillCycleDateAlignment__c = 'Align to original Order Product', blng__GenerateInvoices__c = 'No', blng__Active__c = True);
//        insert billingRule;
//
//        blng__RevenueRecognitionRule__c revRec = new blng__RevenueRecognitionRule__c(name = 'Test Revenue Recognition Rule', blng__Active__c = true, blng__CreateRevenueSchedule__c = 'No');
//        insert revRec;
//
//        blng__TaxRule__c taxRule = new blng__TaxRule__c(Name = 'Test tax Rule', blng__Active__c = true, blng__TaxableYesNo__c = 'No');
//        insert taxRule;
//
//        List<Product2> products = new List<Product2>();
//        Product2 testProd = factory.createProduct('905647-TEST10', 'Test product', 'IFEC', 'IFE HW', '');
//        testProd.blng__BillingRule__c = billingRule.Id;
//        testProd.blng__RevenueRecognitionRule__c = revRec.Id;
//        testProd.blng__TaxRule__c = taxRule.Id;
//        products.add(testProd);
//        insert products;
//
//        List<PricebookEntry> entries = new List<PricebookEntry>();
//        for (SObject prod : products) {
//            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
//            entries.add(pbe);
//        }
//        insert entries;
//
//        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
//
//        for (Product2 prod : products) {
//            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(quote.Id, prod.Id, null);
//            quoteLine.SBQQ__Quantity__c = 1;
//            quoteLine.SBQQ__Group__c = qlg.Id;
//            qlList.add(quoteLine);
//        }
//        insert qlList;
//
//        L2I_QuoteService.processApprovedPartsList(quote.Id);
//        Test.startTest();
//        L2I_DSL__c dsl1 = new L2I_DSL__c(
//              Delivery_Schedule_Header__c = dsh.Id,
//              Delivery_Date__c = Date.Today().addMonths(100),
//              Aircraft__c = ac.Id
//        );
//        insert dsl1;
//
//        SBQQ__Quote__c newQuote = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c FROM SBQQ__Quote__c WHERE SBQQ__Source__c <> NULL LIMIT 1];
//
//        List<SBQQ__QuoteLine__c> qlineList = [SELECT Id, SBQQ__Quantity__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :newQuote.Id];
//        qlineList[0].SBQQ__Quantity__c = 2;
//        update qlineList;
//
//        try {
//            L2I_QuoteService.processApprovedPartsList(newQuote.Id);
//        } catch (Exception e){
//
//        }
//        Test.stopTest();
//        //System.TypeException: Methods defined as TestMethod do not support Web service callouts
//
//    }
}