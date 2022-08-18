@IsTest
private class L2I_ProcessTailCountBasedOrders_Test {
    @IsTest
    static void testBehavior() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
    
        Id customerRecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID;
        Account acctCustomer = new Account(
              Name = 'Acct1',
              RecordTypeId = customerRecordTypeId);
        insert acctCustomer;
    
        Opportunity dealOppty = new Opportunity(
              Name = 'Deal Opp',
              CloseDate = Date.today(),
              StageName = 'Open'
        );
        insert dealOppty;
    
        Opportunity salesOppty = new Opportunity(
              Name = 'Sales Opp',
              AccountId = acctCustomer.Id,
              RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
              L2I_Product_Category__c = 'DSS',
              CloseDate = Date.today(),
              StageName = 'Quotation',
              L2I_Parent_Opportunity__c = dealOppty.Id
        );
        insert salesOppty;
    
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;
    
        SBQQ__Quote__c qt = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = acctCustomer.Id,
              SBQQ__Opportunity2__c = salesOppty.Id,
              SBQQ__Primary__c = true
        );
        insert qt;
    
        Order ord = new Order(AccountId = acctCustomer.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today() - 2,
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOppty.Id,
              SBQQ__Quote__c = qt.Id,
              L2I_Delivery_Schedule__c = dsh.Id);
        insert ord;
    
        Map<Id, String> prodCategoryMap = new Map<Id, String>();
    
        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();
        List<Product2> updateProdList = new List<Product2>();
    
        for (Product2 p : prodList) {
            p.L2I_Migrate__c = true;
            p.SBQQ__ChargeType__c = 'Usage';
            p.SBQQ__BillingType__c = '';
            p.L2I_Service_Activation_Type__c = 'Monthly';
            updateProdList.add(p);
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }
    
        update updateProdList;
    
        Set<String> ProductNameList = new Set<String>();
    
        ProductNameList.add('Connectivity Services - WiFi');
        Set<Id> prodIdList = New Set<Id>();
    
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        for (String s : ProductNameList) {
            Id pid = prodIdMap.get(s);
            prodIdList.add(pid);
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine(qt.Id, pid, null);
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.SBQQ__SpecialPrice__c = 5;
            qlList.add(quoteLine);
        }
        insert qlList;
        List<PricebookEntry> pbeList = [
              SELECT Id,
                    Product2Id,
                    Pricebook2Id,
                    UnitPrice,
                    IsActive
              FROM PricebookEntry
              WHERE Product2Id IN:prodIdList
        ];
    
        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : pbeList) {
            pricebookMap.put(pbe.Product2Id, pbe);
        }
    
        List<OrderItem> orderItemList = new List<OrderItem>();
        blng__BillingRule__c billingrule = [SELECT Id FROM blng__BillingRule__c WHERE Name = 'Non-Billable Product Rule' LIMIT 1];
        for (Id pid : prodIdList) {
            OrderItem theTestOrderItem = new OrderItem(OrderId = ord.Id,
                  Quantity = 1,
                  Product2Id = pid,
                  PricebookEntryId = pricebookMap.get(pid).Id,
                  UnitPrice = pricebookMap.get(pid).UnitPrice,
                  L2I_Sub_Category_2__c = prodCategoryMap.get(pid),
                  SBQQ__ChargeType__c = 'Usage',
                  SBQQ__BillingFrequency__c = 'Monthly',
                  blng__BillingRule__c = billingrule.Id,
                  SBQQ__Status__c = 'Draft',
                  ServiceDate = Date.today() - 2,
                  EndDate = Date.today() + 363,
                  SBQQ__DefaultSubscriptionTerm__c = 24,
                  blng__BillableUnitPrice__c = 15.00,
                  L2I_blng_MatchingId__c = '1234567891011');
            orderItemList.add(theTestOrderItem);
            System.debug('*** orderItemList[0].L2I_Sub_Category_2__c ' + orderItemList[0].L2I_Sub_Category_2__c);
        }
    
        insert orderItemList;
        System.debug('*** orderItemList[0].Id ' + orderItemList[0].Id);
        System.debug('*** orderItemList[0].OrderId ' + orderItemList[0].OrderId);
        System.debug('*** orderItemList[0].UnitPrice ' + orderItemList[0].UnitPrice);
    
        List<blng__UsageSummary__c> usList = [
              SELECT Id, blng__MatchingId__c, blng__Order__c, blng__InvoiceRunProcessingStatus__c,
                    blng__OrderProduct__c
              FROM blng__UsageSummary__c
        ];
        for (blng__UsageSummary__c us : usList) {
            System.debug('*** us ' + us);
            us.blng__InvoiceRunProcessingStatus__c = 'Pending Billing';
        }
        update usList;
    
        blng__Usage__c thisUsage = new blng__Usage__c(
              blng__StartDateTime__c = DateTime.now()
              , blng__EndDateTime__c = DateTime.now()
              , blng__Status__c = 'Processed'
              , blng__Quantity__c = 5
              , blng__Order__c = ord.Id
              , blng__Account__c = acctCustomer.Id
              , blng__MatchingId__c = '1234567891011'
              , L2I_Tail_Count_Created_By_Usage_Batch__c = true
              , L2I_Actual_Quantity__c = 5
              , blng__OrderProduct__c = orderItemList[0].Id
        );
        insert thisUsage;
        thisUsage.blng__Order__c = ord.Id;
        thisUsage.blng__OrderProduct__c = orderItemList[0].Id;
        update thisUsage;
    
        List<L2I_ProcessTailCountBasedOrders.Requests> intReqList = new List<L2I_ProcessTailCountBasedOrders.Requests>();
        L2I_ProcessTailCountBasedOrders.Requests req = new L2I_ProcessTailCountBasedOrders.Requests();
        req.targetDate = Date.today();
        req.invoiceBatch = null;
        intReqList.add(req);
    
        L2I_ProcessTailCountBasedOrders.ProcessTailCountBasedOrders(intReqList);
    }
}