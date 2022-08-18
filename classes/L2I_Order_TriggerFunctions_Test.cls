/**
 *      @author       Sarah Kennedy
 *      @date         03/24/2020
 *      @description  Unit Tests for L2I Opportunity Trigger Functions
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                   03/24/2020         Initial scaffold
 */

@IsTest
private class L2I_Order_TriggerFunctions_Test {
    @TestSetup
    static void testSetup() {
        System.debug('*** Start Order Trigger Functions Setup');
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');

        Test.startTest();
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        Opportunity dealOpp = [SELECT Id FROM Opportunity WHERE RecordType.Developername = 'DEAL' LIMIT 1];
        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
//        ord.EffectiveDate = Date.today().addDays(-3);
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
              Name = 'TestSalesOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOpp.Id,
              L2I_Product_Category__c = 'DSS',
              L2I_Fit_Type__c = 'Initial Sale',
              RecordTypeId = salesId);
        insert salesOppty;

        ord.OpportunityId = salesOppty.Id;
        update ord;
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
              SBQQ__Order__c = ord.Id,
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
        
        SBQQ__Quote__c amendQuote1 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = namedCustomer.Id,
              SBQQ__Opportunity2__c = amend1Opp.Id,
              SBQQ__Primary__c = true
        );
        insert amendQuote1;
        
        amend1Opp.SBQQ__PrimaryQuote__c = amendQuote1.Id;
        update amend1Opp;
    Test.stopTest();
    }
    @IsTest
    static void testObsoleteAmendment2() {
        // Steps:
        // 1. 1st amendment created in setup
        // 2. 2nd amendment created from same contract
        // 3. new order created on 2nd amendment
        // 4. 1st amendment opportunity set to Closed Lost; its quote is set to Obsolete

//        System.debug('*** Sales Opps ' + [SELECT Id, Name, SBQQ__AmendedContract__c from Opportunity where recordtype.developername = 'Sales']);
//        System.debug('*** Amend1 Opps ' + [SELECT Id, Name, SBQQ__AmendedContract__c from Opportunity where recordtype.developername = 'Amendment']);
        String amend1Opp = [SELECT Id, Name, SBQQ__AmendedContract__c from Opportunity where recordtype.developername = 'Amendment'].Id;
        
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        Opportunity salesOppty = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'Sales' AND Name = 'TestSalesOpp' LIMIT 1];
        
        System.debug('*** 1. getQueries ' + LIMITs.getQueries());
        System.debug('*** 1. getLimitQueries ' + LIMITs.getLimitQueries());
        
        String quoteAmendId1 = [
              SELECT Id,
                    RecordType.DeveloperName,
                    SBQQ__AmendedContract__c,
                    SBQQ__PrimaryQuote__c
              FROM Opportunity
              WHERE RecordType.DeveloperName = 'Amendment'
        ].SBQQ__PrimaryQuote__c;
        System.debug('*** quoteAmendId1 ' + quoteAmendId1);
        
        Contract ctr = [
              SELECT Id
              FROM Contract
              LIMIT 1
        ];
        
        System.debug('*** 2. getQueries ' + LIMITs.getQueries());
        System.debug('*** 2. getLimitQueries ' + LIMITs.getLimitQueries());
        
        Test.startTest();
        
        System.debug('*** 3. getQueries ' + LIMITs.getQueries());
        System.debug('*** 3. getLimitQueries ' + LIMITs.getLimitQueries());
        
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Opportunity dealOpp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DEAL' LIMIT 1];
        Id amendId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        Opportunity amend2Opp = new Opportunity(
              Name = 'TestAmend2Opp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = namedCustomer.Id,
              L2I_Parent_Opportunity__c = dealOpp.Id,
              L2I_Product_Category__c = 'DSS',
              SBQQ__AmendedContract__c = ctr.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              RecordTypeId = amendId);
        insert amend2Opp;
        
        System.debug('*** 4. getQueries ' + LIMITs.getQueries());
        System.debug('*** 4. getLimitQueries ' + LIMITs.getLimitQueries());
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = namedCustomer.Id,
              SBQQ__Opportunity2__c = amend2Opp.Id,
              SBQQ__Primary__c = true
        );
        insert quote2;
        
        System.debug('*** 5. getQueries ' + LIMITs.getQueries());
        System.debug('*** 5. getLimitQueries ' + LIMITs.getLimitQueries());
        
        amend2Opp.SBQQ__PrimaryQuote__c = quote2.Id;
        update amend2Opp;
        
        System.debug('*** 6. getQueries ' + LIMITs.getQueries());
        System.debug('*** 6. getLimitQueries ' + LIMITs.getLimitQueries());
        
        Order theTestOrder = new Order(AccountId = namedCustomer.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = amend2Opp.Id,
              SBQQ__Quote__c = quote2.Id,
              L2I_Delivery_Schedule__c = quote2.SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c);
        insert theTestOrder;
        
        System.debug('*** 7. getQueries ' + LIMITs.getQueries());
        System.debug('*** 7. getLimitQueries ' + LIMITs.getLimitQueries());
        
        Test.stopTest();
        
        System.assertEquals(amend1Opp, [SELECT Id FROM Opportunity WHERE StageName = 'Closed Lost'].Id);
        System.assertEquals(quoteAmendId1, [
              SELECT Id, SBQQ__PrimaryQuote__c
              FROM Opportunity
              WHERE StageName = 'Closed Lost'AND SBQQ__PrimaryQuote__r.L2I_Obsolete__c = TRUE
        ].SBQQ__PrimaryQuote__c);
        System.assertEquals(1, [SELECT COUNT() FROM Opportunity WHERE StageName = 'Closed Lost']);
        System.assertEquals(1, [
              SELECT COUNT()
              FROM Opportunity
              WHERE SBQQ__PrimaryQuote__r.L2I_Obsolete__c = TRUE
        ]);
    }
    
    @IsTest
    static void testObsoleteAmendment1() {
        // Steps:
        // 1. 1st amendment created in setup
        // 2. existing order is activated on 1st amendment
        // 3. 2nd amendment created from same contract
        // 4. No amendment opportunity set to Closed Lost; no quote is set to Obsolete
        
        System.debug('*** Sales Opps ' + [SELECT Id, Name, SBQQ__AmendedContract__c from Opportunity where recordtype.developername = 'Sales']);
        System.debug('*** Amend1 Opps ' + [SELECT Id, Name, SBQQ__AmendedContract__c from Opportunity where recordtype.developername = 'Amendment']);
        Opportunity amend1Opp = [SELECT Id, Name, SBQQ__AmendedContract__c, L2I_Delivery_Schedule__c, SBQQ__PrimaryQuote__c from Opportunity where recordtype.developername = 'Amendment' LIMIT 1];
        
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        Opportunity salesOppty = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'Sales' AND Name = 'TestSalesOpp' LIMIT 1];
        
        Contract ctr = [
              SELECT Id
              FROM Contract
              LIMIT 1
        ];
        
        Test.startTest();
        Order theTestOrder = createDraftOrderOnAmendment('TestAmend1Opp');
        theTestOrder.Status = 'Activated';
        update theTestOrder;
        
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Opportunity dealOpp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DEAL' LIMIT 1];
        Id amendId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        Opportunity amend2Opp = new Opportunity(
              Name = 'TestAmend2Opp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = namedCustomer.Id,
              L2I_Parent_Opportunity__c = dealOpp.Id,
              L2I_Product_Category__c = 'DSS',
              SBQQ__AmendedContract__c = ctr.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              RecordTypeId = amendId);
        insert amend2Opp;
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = namedCustomer.Id,
              SBQQ__Opportunity2__c = amend2Opp.Id,
              SBQQ__Primary__c = true
        );
        insert quote2;
        
        amend2Opp.SBQQ__PrimaryQuote__c = quote2.Id;
        update amend2Opp;
        
        Test.stopTest();
        
        System.assertEquals(0, [SELECT COUNT() FROM Opportunity WHERE StageName = 'Closed Lost']);
        System.assertEquals(0, [
              SELECT COUNT()
              FROM Opportunity
              WHERE SBQQ__PrimaryQuote__r.L2I_Obsolete__c = TRUE
        ]);
    
    }
    
    @IsTest
    static void testObsoleteAmendment1B() {
        // Steps:
        // 1. 1st amendment created in setup
        // 2. 2nd amendment created from same contract
        // 3. existing order is activated on 1st amendment
        // 4. 2nd amendment opportunity set to Closed Lost; its quote is set to Obsolete
//
//        System.debug('*** Sales Opps ' + [SELECT Id, Name, SBQQ__AmendedContract__c from Opportunity where recordtype.developername = 'Sales']);
//        System.debug('*** Amend1 Opps ' + [SELECT Id, Name, SBQQ__AmendedContract__c from Opportunity where recordtype.developername = 'Amendment']);
        Opportunity amend1Opp = [SELECT Id, Name, SBQQ__AmendedContract__c, L2I_Delivery_Schedule__c, SBQQ__PrimaryQuote__c from Opportunity where recordtype.developername = 'Amendment' LIMIT 1];
        
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        Opportunity salesOppty = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'Sales' AND Name = 'TestSalesOpp' LIMIT 1];
        
        Contract ctr = [
              SELECT Id
              FROM Contract
              LIMIT 1
        ];
        
        System.debug('*** 1. getQueries ' + LIMITs.getQueries());
        System.debug('*** 1. getLimitQueries ' + LIMITs.getLimitQueries());
        
        Test.startTest();
        
        System.debug('*** 2. getQueries ' + LIMITs.getQueries());
        System.debug('*** 2. getLimitQueries ' + LIMITs.getLimitQueries());
        
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Opportunity dealOpp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DEAL' LIMIT 1];
        Id amendId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        Opportunity amend2Opp = new Opportunity(
              Name = 'TestAmend2Opp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = namedCustomer.Id,
              L2I_Parent_Opportunity__c = dealOpp.Id,
              L2I_Product_Category__c = 'DSS',
              SBQQ__AmendedContract__c = ctr.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              RecordTypeId = amendId);
        insert amend2Opp;
        
        System.debug('*** 3. getQueries ' + LIMITs.getQueries());
        System.debug('*** 3. getLimitQueries ' + LIMITs.getLimitQueries());
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = namedCustomer.Id,
              SBQQ__Opportunity2__c = amend2Opp.Id,
              SBQQ__Primary__c = true
        );
        insert quote2;
        
        System.debug('*** 4. getQueries ' + LIMITs.getQueries());
        System.debug('*** 4. getLimitQueries ' + LIMITs.getLimitQueries());
        
        amend2Opp.SBQQ__PrimaryQuote__c = quote2.Id;
        update amend2Opp;
        Order theTestOrder = createDraftOrderOnAmendment('TestAmend1Opp');
//        theTestOrder.Status = 'Activated';
//        update theTestOrder;
//
//        System.debug('*** 5. getQueries ' + LIMITs.getQueries());
//        System.debug('*** 5. getLimitQueries ' + LIMITs.getLimitQueries());
        
        Test.stopTest();
        
        System.debug('*** 6. getQueries ' + LIMITs.getQueries());
        System.debug('*** 6. getLimitQueries ' + LIMITs.getLimitQueries());
        
        System.assertEquals(amend2Opp.Id, [SELECT Id FROM Opportunity WHERE StageName = 'Closed Lost'].Id);
        System.assertEquals(quote2.Id, [
              SELECT Id, SBQQ__PrimaryQuote__c
              FROM Opportunity
              WHERE StageName = 'Closed Lost'AND SBQQ__PrimaryQuote__r.L2I_Obsolete__c = TRUE
        ].SBQQ__PrimaryQuote__c);
        System.assertEquals(1, [SELECT COUNT() FROM Opportunity WHERE StageName = 'Closed Lost']);
        System.assertEquals(1, [
              SELECT COUNT()
              FROM Opportunity
              WHERE SBQQ__PrimaryQuote__r.L2I_Obsolete__c = TRUE
        ]);
    }
    
    @IsTest
    static void testRefire() {
        
        System.debug('*** Sales Opps ' + [SELECT Id, Name, SBQQ__AmendedContract__c from Opportunity where recordtype.developername = 'Sales']);
        System.debug('*** Amend1 Opps ' + [SELECT Id, Name, SBQQ__AmendedContract__c from Opportunity where recordtype.developername = 'Amendment']);
        Opportunity amend1Opp = [SELECT Id, Name, SBQQ__AmendedContract__c, L2I_Delivery_Schedule__c, SBQQ__PrimaryQuote__c from Opportunity where recordtype.developername = 'Amendment' LIMIT 1];
        
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        Opportunity salesOppty = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'Sales' AND Name = 'TestSalesOpp' LIMIT 1];
        
        Contract ctr = [
              SELECT Id
              FROM Contract
              LIMIT 1
        ];
        
        Test.startTest();
        Order theTestOrder = createDraftOrderOnAmendment('TestAmend1Opp');
        theTestOrder.Status = 'Activated';
        theTestOrder.L2I_IntegrationStatus__c = 'Ready to Integrate';
        update theTestOrder;
        
        Test.stopTest();
    
    }
    
    @IsTest
    static void testRenewalCancel() {
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        Opportunity salesOppty = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'Sales' AND Name = 'TestSalesOpp' LIMIT 1];
    
        Contract ctr = [
              SELECT Id
              FROM Contract
              LIMIT 1
        ];
    
        Test.startTest();
    
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Opportunity dealOpp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DEAL' LIMIT 1];
        Id renewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Opportunity renew2Opp = new Opportunity(
              Name = 'TestRenew2Opp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              AccountId = namedCustomer.Id,
              L2I_Parent_Opportunity__c = dealOpp.Id,
              L2I_Product_Category__c = 'DSS',
              SBQQ__AmendedContract__c = ctr.Id,
              L2I_Delivery_Schedule__c = dsh.Id,
              RecordTypeId = renewId);
        insert renew2Opp;
    
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = namedCustomer.Id,
              SBQQ__Opportunity2__c = renew2Opp.Id,
              SBQQ__Primary__c = true
        );
        insert quote2;
    
        System.debug('*** 4. getQueries ' + LIMITs.getQueries());
        System.debug('*** 4. getLimitQueries ' + LIMITs.getLimitQueries());
    
        renew2Opp.SBQQ__PrimaryQuote__c = quote2.Id;
        update renew2Opp;
        Order theTestOrder = createRenewalOrder('TestRenew2Opp');
        theTestOrder.Status = 'Activated';
        update theTestOrder;
        
        Test.stopTest();
    }
    
    
    private static Order createDraftOrderOnAmendment(String oppAmendName){
        Map<Id, String> prodCategoryMap = new Map<Id, String>();
        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
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
        }
        
        List<PricebookEntry> pbeList = [
              select Id,
                    Product2Id,
                    Pricebook2Id,
                    UnitPrice,
                    IsActive
              from PricebookEntry
              where Product2Id in:prodIdList
        ];
        
        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : pbeList) {
            pricebookMap.put(pbe.Product2Id, pbe);
        }
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        Opportunity oppty = [SELECT Id, SBQQ__PrimaryQuote__c, L2I_Delivery_Schedule__c
        FROM Opportunity WHERE Recordtype.Developername = 'Amendment' AND Name = :oppAmendName LIMIT 1];
        Order theTestOrder = new Order(AccountId = namedCustomer.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = oppty.Id,
              SBQQ__Quote__c = oppty.SBQQ__PrimaryQuote__c,
              L2I_Delivery_Schedule__c = oppty.L2I_Delivery_Schedule__c);
        insert theTestOrder;
        
        // create OrderItems
        List<OrderItem> OrderItemList = new List<OrderItem>();
        blng__BillingRule__c billingrule = [select Id from blng__BillingRule__c where name = 'Non-Billable Product Rule' limit 1];
        for (Id pid : prodIdList) {
            OrderItem theTestOrderItem = new OrderItem(OrderId = theTestOrder.id,
                  Quantity = 1,
                  Product2Id = pid,
                  PricebookEntryId = pricebookMap.get(pid).Id,
                  UnitPrice = pricebookMap.get(pid).UnitPrice,
                  L2I_Sub_Category_2__c = prodCategoryMap.get(pid),
                  SBQQ__ChargeType__c = 'Recurring',
                  SBQQ__BillingFrequency__c = 'Monthly',
                  SBQQ__BillingType__c = 'Advance',
                  blng__BillingRule__c = billingrule.Id,
                  SBQQ__DefaultSubscriptionTerm__c = 24,
                  L2I_blng_MatchingId__c = '00N18000001Vkc2',
                  SBQQ__Activated__c = true);
            OrderItemList.add(theTestOrderItem);
        }
        insert OrderItemList;
        
        return theTestOrder;
    }
    
    private static Order createRenewalOrder(String oppRenewalName) {
        Map<Id, String> prodCategoryMap = new Map<Id, String>();
        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
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
        }
    
        List<PricebookEntry> pbeList = [
              select Id,
                    Product2Id,
                    Pricebook2Id,
                    UnitPrice,
                    IsActive
              from PricebookEntry
              where Product2Id in:prodIdList
        ];
    
        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : pbeList) {
            pricebookMap.put(pbe.Product2Id, pbe);
        }
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        Opportunity oppty = [
              SELECT Id, SBQQ__PrimaryQuote__c, L2I_Delivery_Schedule__c
              FROM Opportunity
              WHERE Recordtype.Developername = 'Renewal' AND Name = :oppRenewalName
              LIMIT 1
        ];
        Order theTestOrder = new Order(AccountId = namedCustomer.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = oppty.Id,
              SBQQ__Quote__c = oppty.SBQQ__PrimaryQuote__c,
              Type = 'Renewal',
              L2I_Delivery_Schedule__c = oppty.L2I_Delivery_Schedule__c);
        insert theTestOrder;
    
        // create OrderItems
        List<OrderItem> OrderItemList = new List<OrderItem>();
        blng__BillingRule__c billingrule = [select Id from blng__BillingRule__c where name = 'Non-Billable Product Rule' limit 1];
        for (Id pid : prodIdList) {
            OrderItem theTestOrderItem = new OrderItem(OrderId = theTestOrder.id,
                  Quantity = 1,
                  Product2Id = pid,
                  PricebookEntryId = pricebookMap.get(pid).Id,
                  UnitPrice = pricebookMap.get(pid).UnitPrice,
                  L2I_Sub_Category_2__c = prodCategoryMap.get(pid),
                  SBQQ__ChargeType__c = 'Recurring',
                  SBQQ__BillingFrequency__c = 'Monthly',
                  SBQQ__BillingType__c = 'Advance',
                  blng__BillingRule__c = billingrule.Id,
                  SBQQ__DefaultSubscriptionTerm__c = 24,
                  L2I_blng_MatchingId__c = '00N18000001Vkc2',
                  SBQQ__Activated__c = true);
            OrderItemList.add(theTestOrderItem);
        }
        insert OrderItemList;
    
        return theTestOrder;
    }
}