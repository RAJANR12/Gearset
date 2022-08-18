@IsTest
private class L2I_QuoteLineService_Test {
    @IsTest
    static void testService() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
    
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
    
        SBQQ__Quote__c quot = [SELECT Id FROM SBQQ__Quote__c];
    
        // create Quotelines
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        Map<Id, String> prodCategoryMap = new Map<Id, String>();
        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
        for(Product2 prod :prodList){
            prod.L2I_Category__c = 'IFEC';
        }
        update prodlist;
        
        Map<String, Id> prodIdMap = new Map<String, Id>();
        for (Product2 p : prodList) {
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }
        Set<String> ProductNameList = new Set<String>();
        ProductNameList.add('Live Television - Monthly Additional Satellite Capacity - per aircraft');
        Set<Id> prodIdList = New Set<Id>();
        for (String s : ProductNameList) {
            Id pid = prodIdMap.get(s);
            prodIdList.add(pid);
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(quot.Id, pid, null);
            qlList.add(quoteLine);
            
        }
        insert qlList;
        
        L2I_QuoteLineService.setMatchingIds(new Set<Id>{quot.Id});
    
        for (SBQQ__QuoteLine__c ql2 : [SELECT Id, L2I_blng_MatchingId__c FROM SBQQ__QuoteLine__c ]){
            System.assertEquals(ql2.Id, ql2.L2I_blng_MatchingId__c);
        }
    }
    
    @IsTest
    static void testServiceRenewed() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        SBQQ__Quote__c quot = [SELECT Id FROM SBQQ__Quote__c];
        
        // create Quotelines
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        Map<Id, String> prodCategoryMap = new Map<Id, String>();
        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
        for(Product2 prod :prodList){
            prod.L2I_Category__c = 'IFEC';
        }
        update prodlist;
        Map<String, Id> prodIdMap = new Map<String, Id>();
        for (Product2 p : prodList) {
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }
        Set<String> ProductNameList = new Set<String>();
        ProductNameList.add('Live Television - Monthly Additional Satellite Capacity - per aircraft');
        Set<Id> prodIdList = New Set<Id>();
        for (String s : ProductNameList) {
            Id pid = prodIdMap.get(s);
            prodIdList.add(pid);
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(quot.Id, pid, null);
            qlList.add(quoteLine);
        }
        insert qlList;
        
        Map<String, String> qLineSubMap = new Map<String, String>();
        List<SBQQ__Subscription__c> subcList = new List<SBQQ__Subscription__c>();
        for (SBQQ__QuoteLine__c ql1 : [SELECT Id FROM SBQQ__QuoteLine__c]){
            SBQQ__Subscription__c subc = new SBQQ__Subscription__c(
                  SBQQ__QuoteLine__c = ql1.Id,
                  L2I_blng_MatchingId__c = ql1.Id,
                  SBQQ__Quantity__c = 1
            );
            subcList.add(subc);
        }
        insert subcList;
        for (SBQQ__Subscription__c subc2 : [SELECT Id, SBQQ__QuoteLine__c FROM SBQQ__Subscription__c]){
            qLineSubMap.put(subc2.SBQQ__QuoteLine__c, subc2.Id);
        }
    
        List<SBQQ__QuoteLine__c> ql3List = new List<SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c ql3 : [SELECT Id FROM SBQQ__QuoteLine__c]) {
            ql3.SBQQ__RenewedSubscription__c = qLineSubMap.get(ql3.Id);
            ql3List.add(ql3);
        }
        update ql3List;
        
        L2I_QuoteLineService.setMatchingIds(new Set<Id>{quot.Id});
        
        for (SBQQ__QuoteLine__c ql2 : [SELECT Id, L2I_blng_MatchingId__c FROM SBQQ__QuoteLine__c ]){
            System.assertEquals(ql2.Id, ql2.L2I_blng_MatchingId__c);
        }
    }
    
    @IsTest
    static void testServiceAmended() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        SBQQ__Quote__c quot = [SELECT Id FROM SBQQ__Quote__c];
        
        // create Quotelines
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        Map<Id, String> prodCategoryMap = new Map<Id, String>();
        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
        for(Product2 prod :prodList){
            prod.L2I_Category__c = 'IFEC';
        }
        update prodlist;
        Map<String, Id> prodIdMap = new Map<String, Id>();
        for (Product2 p : prodList) {
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }
        Set<String> ProductNameList = new Set<String>();
        ProductNameList.add('Live Television - Monthly Additional Satellite Capacity - per aircraft');
        Set<Id> prodIdList = New Set<Id>();
        for (String s : ProductNameList) {
            Id pid = prodIdMap.get(s);
            prodIdList.add(pid);
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(quot.Id, pid, null);
            qlList.add(quoteLine);
        }
        insert qlList;
        
        Map<String, String> qLineSubMap = new Map<String, String>();
        List<SBQQ__Subscription__c> subcList = new List<SBQQ__Subscription__c>();
        for (SBQQ__QuoteLine__c ql1 : [SELECT Id FROM SBQQ__QuoteLine__c]){
            SBQQ__Subscription__c subc = new SBQQ__Subscription__c(
                  SBQQ__QuoteLine__c = ql1.Id,
                  L2I_blng_MatchingId__c = ql1.Id,
                  SBQQ__Quantity__c = 1
            );
            subcList.add(subc);
        }
        insert subcList;
        for (SBQQ__Subscription__c subc2 : [SELECT Id, SBQQ__QuoteLine__c FROM SBQQ__Subscription__c]){
            qLineSubMap.put(subc2.SBQQ__QuoteLine__c, subc2.Id);
        }
        
        List<SBQQ__QuoteLine__c> ql3List = new List<SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c ql3 : [SELECT Id FROM SBQQ__QuoteLine__c]) {
            ql3.SBQQ__UpgradedSubscription__c = qLineSubMap.get(ql3.Id);
            ql3List.add(ql3);
        }
        update ql3List;
        
        L2I_QuoteLineService.setMatchingIds(new Set<Id>{quot.Id});
        
        for (SBQQ__QuoteLine__c ql2 : [SELECT Id, L2I_blng_MatchingId__c FROM SBQQ__QuoteLine__c ]){
            System.assertEquals(ql2.Id, ql2.L2I_blng_MatchingId__c);
        }
    }
    
    
    @IsTest
    static void testNoLines() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
    
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        SBQQ__Quote__c quot = [SELECT Id FROM SBQQ__Quote__c];
        L2I_QuoteLineService.setMatchingIds(new Set<Id>{quot.Id});
    }
    
    @IsTest
    static void testNoQuotes() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        L2I_QuoteLineService.setMatchingIds(new Set<Id>());
    }
}