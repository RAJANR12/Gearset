/**
* @File Name          : PT_DeleteAssetsFromCaseControllerTest.cls
* @Description        : Test Class for PT_DeleteAssetsFromCaseController
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@isTest
private with sharing class PT_DeleteAssetsFromCaseControllerTest {

    static L2I_DataFactory dt = new L2I_DataFactory();
    
    @testSetup
    static void testSetup() {
        dt.setupTestContext(null, null, false);
        
        test.startTest();
        Account namedCustomer = dt.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        namedCustomer.L2I_Payment_Term__c = 'NO TERMS';
        insert namedCustomer;
        
        Opportunity dealOppty = dt.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        // Added for W-001727
        Product2 prodSysType = dt.createProduct('9876543','EX3','DSS','Applications', 'X-Series');
        insert prodSysType;
                
        Opportunity salesOppty = dt.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id, dealOppty.Id, 200000, 'DSS');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        
        SBQQ__Quote__c quote = dt.createQuote('draft', namedCustomer.Id, salesOppty.Id, true);
        insert quote;
        
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        
        Set<Id> productIdSet = new Set<Id>();
        Map<Id, String> prodCategoryMap = new Map<Id, String>();
        
        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c from Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();
        List<Product2> updateProdList = new List<Product2>();
        
        for (Product2 p : prodList) {
            p.L2I_Migrate__c = true;
            p.SBQQ__ChargeType__c = 'Usage';
            p.SBQQ__BillingType__c = '';
            p.L2I_Service_Activation_Type__c = 'Monthly';
            updateProdList.add(p);
            prodIdMap.put( p.Name, p.Id );
            prodCategoryMap.put( p.Id, p.L2I_Sub_Category_2__c );
        }
        
        update updateProdList;
        
        Set<String> ProductNameList = new Set<String>();
        
        ProductNameList.add('Toca Boca - Toca Cars');
        Set<Id> prodIdList = New Set<Id>();
        
        for (String s : ProductNameList) {
            Id pid = prodIdMap.get( s );
            prodIdList.add( pid );
            SBQQ__QuoteLine__c quoteLine = dt.createQuoteLine( quote.Id, pid, null );
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.SBQQ__SpecialPrice__c = 5;
            qlList.add(quoteLine);
        }
        insert qlList;
        
        L2I_Aircraft_Type__c att = dt.createAircraftType( namedCustomer.Id, 123456);
        
        insert att;
        
        L2I_DSH__c dsHeaderlList = dt.createDeliverySchedule( namedCustomer.Id, att.Id );
        
        insert dsHeaderlList;
        
        //L2I_DSL__c dsLineList = factory.createDeliveryScheduleLine( dsHeaderlList.Id );
        //insert dsLineList;
        
        //updateDSHToSalesOppo(salesOppty, dsHeaderlList.Id);
        
        List<PricebookEntry> pbeList = [SELECT Id,
              Product2Id,
              Pricebook2Id,
              UnitPrice,
              IsActive
        FROM PricebookEntry
        WHERE Product2Id in: prodIdList];
        
        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : pbeList ){
            pricebookMap.put( pbe.Product2Id, pbe );
        }
        
        Order theTestOrder = new Order(AccountId = namedCustomer.Id,
              PoNumber= 'Test',
              EffectiveDate = Date.today()-2,
              Status='Draft',
              Pricebook2Id=Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOppty.Id,
              SBQQ__Quote__c = quote.Id,
              L2I_Delivery_Schedule__c = dsHeaderlList.Id);
        insert theTestOrder;
        
        List<OrderItem> OrderItemList = new List<OrderItem>();
        blng__BillingRule__c billingrule = [SELECT Id FROM blng__BillingRule__c WHERE name = 'Non-Billable Product Rule' limit 1];
        for (Id pid : prodIdList) {
            OrderItem theTestOrderItem = new OrderItem(OrderId = theTestOrder.id,
                  Quantity = 1,
                  Product2Id = pid,
                  PricebookEntryId = pricebookMap.get(pid).Id,
                  UnitPrice = pricebookMap.get(pid).UnitPrice,
                  L2I_Sub_Category_2__c = prodCategoryMap.get( pid ),
                  SBQQ__ChargeType__c = 'Usage',
                  SBQQ__BillingFrequency__c = 'Monthly',
                  blng__BillingRule__c = billingrule.Id,
                  SBQQ__Status__c = 'Draft',
                  ServiceDate = Date.today()-2,
                  EndDate = Date.today()+363,
                  SBQQ__DefaultSubscriptionTerm__c = 24,
                  L2I_blng_MatchingId__c = '1234567891011');
            OrderItemList.add(theTestOrderItem);
        }
        
        insert OrderItemList;

        PT_Program__c prog1 = new PT_Program__c(Name = 'Test Name', Program_Number__c = 'Test Name', Sales_Opportunity__c = salesOppty.Id);
        insert prog1;

        Case cases = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', PT_Program__c = prog1.Id, PO_Case_Type__c = 'IFEC', AccountId = namedCustomer.Id);
        insert cases;
    
        Asset ast = new Asset(Name = 'AssetName', AccountId = namedCustomer.Id, Product2Id = prodList[0].Id, PT_Program__c = prog1.Id, PT_Case__c = cases.Id);
        insert ast;
        
        Asset parentAst = new Asset(Name = 'AssetName', AccountId = namedCustomer.Id, Product2Id = prodList[0].Id, PT_Program__c = prog1.Id, PT_Case__c = cases.Id, ParentId = ast.Id, SBQQ__OrderProduct__c = OrderItemList[0].Id);
        insert parentAst;
        test.stopTest();
    }

    @isTest
    static void deleteAssetsFromCase() {
        Asset ast = [Select Id From Asset Where ParentId != null LIMIT 1];

        PageReference pageRef = Page.PT_DeleteAssetsFromCase;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', ast.Id);

        Test.startTest();
        PT_DeleteAssetsFromCaseController ctrl = new PT_DeleteAssetsFromCaseController();
        ctrl.deleteAssetsFromCase();
        Test.stopTest();
    }
    
    @isTest
    static void deleteAssetsException() {
        Asset ast = [Select Id, AccountId From Asset Where ParentId != null LIMIT 1];
        Shipping_Method__c sm = new Shipping_Method__c(Name = 'SM1');
        insert sm;
        L2I_Site__c billToSite = B2B_PAC_TestDataFactory.createInsertTestSite(new Account(Id = ast.AccountId));
        L2I_Site__c shipToSite = B2B_PAC_TestDataFactory.createInsertTestSite(new Account(Id = ast.AccountId));
        shipToSite.L2I_Site_Use_Code__c = 'Ship_To';
        update shipToSite;
        
        Case caseRec = [Select Id, Status, PT_PO_Number__c, PT_Order_Type_Context__c, PT_Payment_Term__c, PT_Freight_Terms__c, PT_INCOTERMS__c, PT_PO_Received_Date__c, PT_Ship_to_Customer__c, PT_Ship_to_Location__c, PT_Bill_to_Location__c, PT_Shipping_Method__c From Case LIMIT 1];
        caseRec.Status = 'Ordered';
        caseRec.PT_PO_Number__c = 'PO-1234';
        caseRec.PT_Order_Type_Context__c = 'Standard Stock Order';
        caseRec.PT_Freight_Terms__c = 'Bill Third Party';
        caseRec.PT_PO_Received_Date__c = System.today();
        caseRec.PT_Ship_to_Customer__c = ast.AccountId;
        caseRec.PT_Ship_to_Location__c = shipToSite.Id;
        caseRec.PT_Bill_to_Location__c = billToSite.Id;
        caseRec.PT_Shipping_Method__c = sm.Id;
        update caseRec;

        PageReference pageRef = Page.PT_DeleteAssetsFromCase;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', ast.Id);

        Test.startTest();
        PT_DeleteAssetsFromCaseController ctrl = new PT_DeleteAssetsFromCaseController();
        ctrl.deleteAssetsFromCase();
        Test.stopTest();
    }
}