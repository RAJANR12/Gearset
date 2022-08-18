@isTest(SeeAllData=false)
private class L2I_QuoteExtController_Test {

    @testSetup
    private static void setupData() {

        List<Product2> prods = new List<Product2>();
        prods.add(new product2(Name = 'Connectivity', productCode = 'ConnectivitySvcsWiFi-Bundle', L2I_Inventory_Item_Id__c = '99999801'));
        prods.add(new product2(Name = 'MediaServices', productCode = 'MediaSvcs-Bundle', L2I_Inventory_Item_Id__c = '99999802'));
        prods.add(new product2(Name = 'MediaServices', productCode = 'LiveTV-Bundle', L2I_Inventory_Item_Id__c = '99999803'));
        insert prods;

    }

    testMethod static void testSubmit() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.L2I_Reviewed_PO_Required__c = true;
        insert quote;

        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();

        System.assertEquals('Approved', quote.ApprovalStatus__c);
    }

    testMethod static void testRecall() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;

        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onRecall();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();

        System.assertEquals('Recalled', quote.ApprovalStatus__c);
    }

    @isTest
    private static void testMediaServices() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;

        Product2 prod = [Select Id From Product2 Where productCode = 'MediaSvcs-Bundle' LIMIT 1];
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = prod.Id);
        insert ql;

        Product2 prodY = new product2(Name = 'Test YYY', productCode = 'TEST-Prod-YYYY', L2I_Inventory_Item_Id__c = '99999804');
        insert prodY;

        List<SBQQ__QuoteLine__c> qls = new List<SBQQ__QuoteLine__c>();
        qls.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__RequiredBy__c = ql.Id, SBQQ__Product__c = prodY.Id));
        insert qls;

        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Media Services')) b = true;
        }
        system.assert(b);
    }

    @isTest
    private static void testConnectivity() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;

        Product2 prod = [Select Id From Product2 Where productCode = 'ConnectivitySvcsWiFi-Bundle' LIMIT 1];
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = prod.Id);
        insert ql;

        Product2 prodY = new product2(Name = 'Test YYY', productCode = 'TEST-Prod-YYYY', L2I_Inventory_Item_Id__c = '99999804');
        insert prodY;

        List<SBQQ__QuoteLine__c> qls = new List<SBQQ__QuoteLine__c>();
        qls.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__RequiredBy__c = ql.Id, SBQQ__Product__c = prodY.Id));
        insert qls;

        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Connectivity')) b = true;
        }
        system.assert(b);
    }

    @isTest
    private static void testLiveTelevision() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;

        Product2 prod = [Select Id From Product2 Where productCode = 'LiveTV-Bundle' LIMIT 1];
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = prod.Id);
        insert ql;

        Product2 prodY = new product2(Name = 'Test YYY', productCode = 'TEST-Prod-YYYY', L2I_Inventory_Item_Id__c = '99999804');
        insert prodY;

        List<SBQQ__QuoteLine__c> qls = new List<SBQQ__QuoteLine__c>();
        qls.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__RequiredBy__c = ql.Id, SBQQ__Product__c = prodY.Id));
        insert qls;

        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Live Television')) b = true;
        }
        system.assert(b);
    }

    @isTest
    private static void testPlaceholderPartValidation() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;

        Product2 prodY = new product2(Name = 'Test YYY', productCode = 'TBD-Recurring', L2I_Inventory_Item_Id__c = '99999804');
        insert prodY;

        List<SBQQ__QuoteLine__c> qls = new List<SBQQ__QuoteLine__c>();
        qls.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = prodY.Id));
        insert qls;

        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().containsIgnoreCase('price for placeholder')) b = true;
        }
        system.assert(b);
    }
}