@IsTest
private class L2I_BypassTriggers_Test {
    @IsTest
    static void testTriggers() {
        L2I_Trigger_Settings__c settings = new L2I_Trigger_Settings__c(
              SetupOwnerId = UserInfo.getUserId(),
              Disable_DSH__c = true,
              Disable_DSL__c = true,
              Disable_Aircraft__c = true,
              Disable_AircraftService__c = true,
              Disable_Case__c = true,
              Disable_AircraftServiceAction__c = true,
              Disable_Opportunity__c = true,
              Disable_Order__c = true,
              Disable_Quote__c = true,
              Disable_OrderItem__c = true,
              Disable_QuoteLine__c = true,
              Disable_PLSalesOpportunity__c = true,
              Disable_Attachment__c = true,
              Disable_PMO_Groups__c = true,
              Disable_ContentVersion__c = true,
              Disable_InstallLoc__c = true
        );
        insert settings;
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
    
//        Attachment attach=new Attachment();
//        attach.Name='Unit Test Attachment Anon';
//        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
//        attach.body=bodyBlob;
//        attach.parentId=salesOppty.id;
//        insert attach;
        
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;
        
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        L2I_Aircraft_Type__c att = factory.createAircraftType(acctCustomer.Id, 123456);
        insert att;
        
        L2I_Aircraft__c ac = factory.createAircraft(att.Id, 'Name', '2333-11131133114499999988888805', acctCustomer.Id);
        insert ac;
        
        L2I_Aircraft_Service__c arcs = new L2I_Aircraft_Service__c(
              Aircraft__c = ac.Id
        );
        insert arcs;
        
        Case cse = new Case();
        insert cse;
        
        L2I_ASA__c asa = new L2I_ASA__c(
              Aircraft_Order__c = cse.Id,
              Aircraft_Service__c = arcs.Id
        );
        insert asa;
        
        delete ac;
        
        SBQQ__Quote__c qt = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = acctCustomer.Id,
              SBQQ__Opportunity2__c = salesOppty.Id,
              SBQQ__Primary__c = true
        );
        insert qt;
//
//        ContentVersion cVer = new ContentVersion();
//        cVer.ContentLocation = 'S';             // document is in Salesforce
//        cVer.PathOnClient = attach.Name;        // filename with extension
//        cVer.Title = attach.Name;
//        cVer.VersionData = attach.Body;
//        cVer.PT_IntegrationType__c = 'CPL';
//        cVer.tagCsv = 'SBQQ__Quote__c:' + qt.Id;
//        cVer.FirstPublishLocationId = attach.ParentId;  // creates ContentDocumentLink also
//        insert cVer;

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
        
        ProductNameList.add('Toca Boca - Toca Cars');
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
    
        Order ord = new Order(AccountId = acctCustomer.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today() - 2,
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '20',
              OpportunityId = salesOppty.Id,
              SBQQ__Quote__c = qt.Id,
              L2I_Delivery_Schedule__c = dsh.Id);
        insert ord;
    
//        List<OrderItem> orderItemList = new List<OrderItem>();
//        blng__BillingRule__c billingrule = [SELECT Id FROM blng__BillingRule__c WHERE Name = 'Non-Billable Product Rule' LIMIT 1];
//        for (Id pid : prodIdList) {
//            OrderItem theTestOrderItem = new OrderItem(OrderId = ord.Id,
//                  Quantity = 1,
//                  Product2Id = pid,
//                  PricebookEntryId = pricebookMap.get(pid).Id,
//                  UnitPrice = pricebookMap.get(pid).UnitPrice,
//                  L2I_Sub_Category_2__c = prodCategoryMap.get( pid ),
//                  SBQQ__ChargeType__c = 'Usage',
//                  SBQQ__BillingFrequency__c = 'Monthly',
//                  blng__BillingRule__c = billingrule.Id,
//                  SBQQ__Status__c = 'Draft',
//                  ServiceDate = Date.today()-2,
//                  EndDate = Date.today()+363,
//                  SBQQ__DefaultSubscriptionTerm__c = 24,
//                  L2I_blng_MatchingId__c = '1234567891011');
//            orderItemList.add(theTestOrderItem);
//        }

//        insert orderItemList;
    
        L2I_P_L_Approval__c plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
        insert plApproval;
    
        L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOppty.Id);
        insert plSalesOpp;
    
        PT_PMO_Groups__c pg = new PT_PMO_Groups__c(
              Name = 'pgName',
              Group_Type__c = 'Group'
        );
        insert pg;
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
                Name = 'CW',
                ShipSet__c = dsl.Id
        );
        insert instLoc;
    }
}