@IsTest
private class L2I_DSLTriggerFunctions2_Test {

    private static L2I_DataFactory factory;
    private static List<SObject> products;
    private static List<PricebookEntry> pbEntries;

    @testSetup
    static void testBehavior() {

        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_Case_Mgmt_DSL');

        factory = new L2I_DataFactory();

        List<SObject> blng_GLRules = Test.loadData(blng__GLRule__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('GLRule_file'));


        List<SObject> blng_LegalEntities = Test.loadData(blng__LegalEntity__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('LegalEntity_file'));


        List<SObject> blng_financeBooks = Test.loadData(blng__FinanceBook__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('FinanceBook_file'));


        List<SObject> blng_billingRules = Test.loadData(blng__BillingRule__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('BillingRule_file'));


        List<SObject> blng_taxRules = Test.loadData(blng__TaxRule__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('TaxRule_file'));


        List<SObject> blng_revrecRules = Test.loadData(blng__RevenueRecognitionRule__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('RevenueRecognitionRule_file'));


        List<SObject> blng_GLAccounts = Test.loadData(blng__GLAccount__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('GLAccount_file'));


        List<SObject> blng_GLTreatments = Test.loadData(blng__GLTreatment__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('GLTreatment_file'));

        List<SObject> blng_BillingConfig = Test.loadData(blng__BillingConfig__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('BillingConfig_file'));

        products = Test.loadData(Product2.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('Product2_file'));


        pbEntries = new List<PricebookEntry>();
        for (SObject prod : products) {
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                  Product2Id = prod.Id,
                  UnitPrice = 1000,
                  IsActive = true);

            pbEntries.add(pbe);
        }
        insert pbEntries;

        List<PricebookEntry> peList = [select Id, Product2Id, Pricebook2Id from PricebookEntry];
        Map<Id, Id> peIdMap = new Map<Id, Id>();
        for (PricebookEntry p : peList) {
            peIdMap.put(p.Product2Id, p.Id);
//prodCategoryMap.put( p.Id, p.L2I_Sub_Category_2__c );
        }

        List<Product2> prodList = [select Id, Name, L2I_Sub_Category_2__c from Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();

        for (Product2 p : prodList) {
            prodIdMap.put(p.Name, p.Id);
//prodCategoryMap.put( p.Id, p.L2I_Sub_Category_2__c );
        }

        List<SBQQ__Quote__c> quote = [select Id, ApprovalStatus__c, SBQQ__PricebookId__c from SBQQ__Quote__c limit 1];
        quote[0].SBQQ__PricebookId__c = Test.getStandardPricebookId();
        update quote;

        Set<String> ProductNameSet1 = new Set<String>();
//ProductNameSet1.add('Connectivity Bundle');
        ProductNameSet1.add('Toca Boca - Toca Cars');
        ProductNameSet1.add('Nitro Street Run 2');


        List<SBQQ__Cost__c> ctList = new List<SBQQ__Cost__c>();
        for (String s : ProductNameSet1) {
            Id pid = prodIdMap.get(s);
            SBQQ__Cost__c ct = new SBQQ__Cost__c();
            ct.SBQQ__Product__c = prodIdMap.get(s);
            ct.SBQQ__UnitCost__c = 0;
            ct.SBQQ__Active__c = true;

            ctList.add(ct);
        }
        insert ctList;

        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();

        for (String s : ProductNameSet1) {
            Id pid = prodIdMap.get(s);
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(quote[0].Id, pid, null);
            quoteLine.SBQQ__UnitCost__c = 0;
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.SBQQ__RegularPrice__c = 0;
            quoteLine.SBQQ__CustomerPrice__c = 0;
            quoteLine.L2I_On_Doc_Delivery_Day__c = '1';
            quoteLine.SBQQ__BillingFrequency__c = 'Monthly';
            quoteLine.SBQQ__StartDate__c = Date.today();
            quoteLine.SBQQ__EndDate__c = Date.today().addYears(3);
            quoteLine.SBQQ__PricebookEntryId__c = peIdMap.get(pid);
            quoteLine.L2I_Sub_Category_2__c = 'Games';
            quoteLine.L2I_Category__c = 'DSS';

            qlList.add(quoteLine);
        }
        insert qlList;

        quote[0].ApprovalStatus__c = 'Approved';
        quote[0].SBQQ__Primary__c = true;
        quote[0].SBQQ__PriceBook__c = Test.getStandardPricebookId();
        update quote;

    }

    @IsTest
    static void test_validate_DSL_Confirmation() {

        List<SBQQ__QuoteLine__c> qlist = [select id from SBQQ__QuoteLine__c];
        system.assertEquals(qlist.size(), 2);
		Test.startTest();  
        SBQQ__Quote__c olist = [select id, SBQQ__Ordered__c from SBQQ__Quote__c LIMIT 1];
        olist.SBQQ__Ordered__c = true;
        update olist;
        
        Test.stopTest();
             
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Opportunity salesOpp = [SELECT Id, L2I_Delivery_Schedule__c, SBQQ__PrimaryQuote__c FROM Opportunity WHERE Recordtype.Developername = 'Sales' LIMIT 1];
        salesOpp.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOpp;



        List<L2I_DSL__c> dslList = [SELECT Id, Aircraft__c, L2I_Aircraft_Confirmation__c, Original_Opportunity__c FROM L2I_DSL__c WHERE L2I_Aircraft_Confirmation__c != TRUE AND Aircraft__c != NULL LIMIT 1];

        L2I_Aircraft__c ac = [SELECT Id from L2I_Aircraft__c where name = 'Test A/C 2'];
        dslList[0].Aircraft__c = ac.Id;
        dslList[0].L2I_Aircraft_Confirmation__c = true;
        dslList[0].Original_Opportunity__c = salesOpp.Id;
        update dslList[0];

        List<Order> a = [select Id, OpportunityId, L2I_Original_Sales_Opportunity__c, L2I_Product_Category_2__c, Opportunity.L2I_Delivery_Schedule__c from Order];
        system.assertEquals( a.size(), 1 );

        List<Case> c = [select Id, L2I_Activation_Date__c from case];
        system.assertEquals( 1, c.size()  );

//        List<L2I_ASA__c> asa = [select Id from L2I_ASA__c];
//        system.assertEquals( 2, asa.size()  );

//        List<L2I_Aircraft_Service__c> asRecord = [select Id from L2I_Aircraft_Service__c];
//        system.assertEquals( 2, asRecord.size()  );

//        c[0].L2I_Activation_Date__c = Datetime.now();
//        update c;
//
//        List<Case> cUpdated = [select Id, Status from case ];
//        system.assertEquals( 'Closed', cUpdated[0].Status );


    }

    @IsTest
    static void updateDSLNameTest() {
        List<L2I_DSL__c> dslList = [SELECT Id, Aircraft__c, L2I_Aircraft_Confirmation__c, Original_Opportunity__c FROM L2I_DSL__c WHERE L2I_Aircraft_Confirmation__c != TRUE AND Aircraft__c != NULL LIMIT 1];
        L2I_Aircraft__c ac = [SELECT Id from L2I_Aircraft__c where name = 'Test A/C 2'];
        dslList[0].Aircraft__c = ac.Id;
        dslList[0].L2I_Aircraft_Confirmation__c = true;
        dslList[0].PT_Line_Number__c = '01';
        update dslList[0];
    }
    
    @IsTest
    static void testPostChat() {
        Opportunity salesOpp = [SELECT Id, L2I_Delivery_Schedule__c, SBQQ__PrimaryQuote__c FROM Opportunity WHERE Recordtype.Developername = 'Sales' LIMIT 1];
        salesOpp.StageName = 'Quotation';
        String dshId;
        
        Set<String> ids = new Set<String>();
        for (L2I_DSH__c dsh : [SELECT Id FROM L2I_DSH__c]) {
            ids.add(dsh.Id);
            dshId = dsh.Id;
        }
        salesOpp.L2I_Delivery_Schedule__c = dshId;
        update salesOpp;
        
        Test.startTest();
        L2I_DSLTriggerFunctions.postChat(ids);
        Test.stopTest();
    }
}