@isTest
private class L2I_LwcListController_Test {
    private static L2I_DataFactory factory;
    private static List<SObject> products;
    private static List<PricebookEntry> pbEntries;
    private static List<Product2> prodList;
    private static Set<Id> prodIdList;
    private static Map<Id, PricebookEntry> peIdMap;
    private static Map<Id, String> prodCategoryMap;
//
//    @testSetup
//    static void testBehavior() {
    static void setupTestContext() {
        
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_Case_Mgmt_Order');
        
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
        
        List<PricebookEntry> peList = [select Id, Product2Id, Pricebook2Id, UnitPrice from PricebookEntry];
        peIdMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry p : peList) {
            peIdMap.put(p.Product2Id, p);
        }
        
        prodCategoryMap = new Map<Id, String>();
        prodList = [select Id, Name, L2I_Sub_Category_2__c from Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();
        
        for (Product2 p : prodList) {
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }
        
        
        List<SBQQ__Quote__c> quote = [select Id, ApprovalStatus__c, SBQQ__PricebookId__c from SBQQ__Quote__c limit 1];
        quote[0].SBQQ__PricebookId__c = Test.getStandardPricebookId();
        update quote;
        
        Set<String> ProductNameSet1 = new Set<String>();
//        ProductNameSet1.add('Toca Boca - Toca Cars');
//        ProductNameSet1.add('Nitro Street Run 2');
        ProductNameSet1.add('Panasonic Wi-Fi - Monthly Data Connection to the Aircraft, Tiered Plan per Aircraft');
        
        
        List<SBQQ__Cost__c> ctList = new List<SBQQ__Cost__c>();
        prodIdList = New Set<Id>();
        for (String s : ProductNameSet1) {
            Id pid = prodIdMap.get(s);
            prodIdList.add(pid);
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
            quoteLine.SBQQ__PricebookEntryId__c = peIdMap.get(pid).Id;
            quoteLine.L2I_Sub_Category_2__c = prodCategoryMap.get(pid);
            quoteLine.L2I_Category__c = 'DSS';
            
            qlList.add(quoteLine);
        }
        insert qlList;
    
    }
    
    @IsTest
    static void testConfigResults() {
        setupTestContext();
        
        List<SBQQ__QuoteLine__c> qlList = [SELECT Id, SBQQ__Product__c from SBQQ__QuoteLine__c];
        System.debug('*** qlList ' + qlList);
        
        String configVals = qlList[0].Id + ',Non-CPQ Line,SBQQ__QuoteLine__c,undefined,undefined,undefined,undefined,undefined,' +
              'L2I_Rate_Schedule_1,undefined,undefined,L2I_Rate_Schedule_Model,' + qlList[0].SBQQ__Product__c + ',undefined';
        String configValsNoModel = qlList[0].Id + ',Non-CPQ Line,SBQQ__QuoteLine__c,undefined,undefined,undefined,undefined,undefined,' +
              'L2I_Rate_Schedule_1,undefined,undefined,undefined,' + qlList[0].SBQQ__Product__c + ',undefined';
        String configValsFieldSet = qlList[0].Id + ',Non-CPQ Line,SBQQ__QuoteLine__c,SBQQ__LineEditor,undefined,undefined,undefined,undefined,' +
              'L2I_Rate_Schedule_1,undefined,undefined,L2I_Rate_Schedule_Model,' + qlList[0].SBQQ__Product__c + ',undefined';
        String configValsAddl = qlList[0].Id + ',Non-CPQ Line,SBQQ__QuoteLine__c,undefined,undefined,undefined,undefined,undefined,' +
              'L2I_Rate_Schedule_1,undefined,undefined,L2I_Rate_Schedule_Model,' + qlList[0].SBQQ__Product__c + ',SBQQ__ProductName__c';
        
        L2I_LwcListController.getTopRecordWrapper(configValsAddl);
        L2I_LwcListController.getTopRecordWrapper(configVals);
        L2I_LwcListController.getTopRecordWrapper(configValsFieldSet);
        L2I_LwcListController.getColumnHeaderProperties(configVals);
//        L2I_LwcListController.getColumnHeaderProperties(configValsNoModel);
        L2I_LwcListController.getRows(configVals);
//        L2I_LwcListController.getRows(configValsNoModel);
        
        List<L2I_Custom_Model__mdt> cmList = new List<L2I_Custom_Model__mdt>();
        L2I_Custom_Model__mdt cm = [
              SELECT Id, L2I_Per_Unit_Price__c, L2I_Product_Id__c, L2I_Parent__c, L2I_Lower_Bound__c
              FROM L2I_Custom_Model__mdt
              LIMIT 1
        ];
        cm.L2I_Per_Unit_Price__c = 3.0000;
        cm.L2I_Product_Id__c = qlList[0].SBQQ__Product__c;
        cm.L2I_Parent__c = qlList[0].Id;
        cm.L2I_Lower_Bound__c = 1;
        cmList.add(cm);
        L2I_LwcListController.saveRecords(cmList, null, qlList[0].Id, true, 'L2I_Rate_Schedule_Model');
    
    }
    
    @IsTest
    static void envTest() {
        L2I_LwcListController c = new L2I_LwcListController();
        Test.startTest();
        L2I_DataFactory factory = new L2I_DataFactory();
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
              Name = 'TestSalesOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = salesId);
        insert salesOppty;
        
        
        L2I_LwcListController.getEnvironmentName();
        
        Test.stopTest();
    }
}