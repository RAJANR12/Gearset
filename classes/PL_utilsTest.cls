@IsTest
private with sharing class PL_utilsTest
{
    private static L2I_P_L_Approval__c plApproval;
    private static void setupTestData()
    {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        // factory.setupAccountThruOrder(null, null, false, 'Activated');
        
        List<PL_MD__c> lstPlmd = new List<PL_MD__c>();
        PL_MD__c plmd = new PL_MD__c();
        plmd.Name='IFE Hardware';
        plmd.Pillar__c='IFE';
        plmd.Product_Group__c='IFE Hardware';
        plmd.Sort_Order__c=1;
        //plmd.Sub_Total_Label__c='IFE';
        plmd.MD_Type__c ='Product Group';
        lstPlmd.add(plmd);
        
        PL_MD__c plmd1 = new PL_MD__c();
        plmd1.Name='IFE Services';
        plmd1.Pillar__c='IFE';
        plmd1.Product_Group__c='IFE Hardware';
        plmd1.Sort_Order__c=2;
        //plmd1.Sub_Total_Label__c='IFE';
        plmd1.MD_Type__c ='Product Group';
        lstPlmd.add(plmd1);
        
        PL_MD__c plmd2 = new PL_MD__c();
        plmd2.Name='IFC Hardware';
        plmd2.Pillar__c='IFC';
        plmd2.Product_Group__c='IFC Hardware';
        plmd2.Sort_Order__c=3;
        //plmd2.Sub_Total_Label__c='IFC';
        plmd2.MD_Type__c ='Product Group';
        lstPlmd.add(plmd2);
        
        PL_MD__c plmd3 = new PL_MD__c();
        plmd3.Name='IFC Services';
        plmd3.Pillar__c='IFC';
        plmd3.Product_Group__c='IFC Hardware';
        plmd3.Sort_Order__c=4;
        //plmd3.Sub_Total_Label__c='IFC';
        plmd3.MD_Type__c ='Product Group';
        lstPlmd.add(plmd3);
        
        PL_MD__c plmd4 = new PL_MD__c();
        plmd4.Name='DSS';
        plmd4.Pillar__c='DSS';
        plmd4.Product_Group__c='IFE Hardware';
        plmd4.Sort_Order__c=5;
        //plmd4.Sub_Total_Label__c='IFE';
        plmd4.MD_Type__c ='Product Group';
        lstPlmd.add(plmd4);
        
        PL_MD__c plmd5 = new PL_MD__c();
        plmd5.Name='PTS';
        plmd5.Pillar__c='PTS';
        plmd5.Product_Group__c='IFE Hardware';
        plmd5.Sort_Order__c=6;
        //plmd5.Sub_Total_Label__c='IFE';
        plmd5.MD_Type__c ='Product Group';
        lstPlmd.add(plmd5);
        
        PL_MD__c plmd6 = new PL_MD__c();
        plmd6.Name='PTS';
        plmd6.Pillar__c='PTS';
        plmd6.Product_Group__c='IFE Hardware';
        plmd6.Sort_Order__c=6;
        //plmd6.Sub_Total_Label__c='IFE';
        plmd6.MD_Type__c ='Product Summary';
        // lstPlmd.add(plmd6);
        
        PL_MD__c plmd7 = new PL_MD__c();
        plmd7.Name='DSS';
        plmd7.Pillar__c='DSS';
        plmd7.Product_Group__c='IFE Hardware';
        plmd7.Sort_Order__c=105;
        //plmd7.Sub_Total_Label__c='IFE';
        plmd7.MD_Type__c ='Product Summary';
        //lstPlmd.add(plmd7);
        
        //---------------------------------
        PL_MD__c Prod = new PL_MD__c();
        Prod.Name='SEATEND LRU';
        Prod.Pillar__c='PTS';
        Prod.Product_Group__c='IFE Hardware';
        Prod.Sort_Order__c=6;
        Prod.L2I_Migration_External_Id__c = 'IFE-S-Other';
        //Prod.Sub_Total_Label__c='IFE';
        Prod.MD_Type__c ='Product Summary';
        lstPlmd.add(Prod);
        
        PL_MD__c plmd8 = new PL_MD__c();
        plmd8.Name='Connectivity';
        plmd8.Pillar__c='PTS';
        plmd8.Product_Group__c='IFC Hardware';
        plmd8.Sort_Order__c=6;
        plmd8.L2I_Migration_External_Id__c = 'IFC-H-Wifi';
        //Prod.Sub_Total_Label__c='IFE';
        plmd8.MD_Type__c ='Product Summary';
        lstPlmd.add(plmd8);
        insert lstPlmd;
        
        PL_Product_Group__c pg = new PL_Product_Group__c();
        pg.PL_MD__c = plmd.id;
        pg.Start_Date__c = system.today().addDays(-1);
        insert pg;    
        
        PL_Product_Group__c pg2 = new PL_Product_Group__c();
        pg2.PL_MD__c = plmd2.id;
        pg2.Start_Date__c = system.today().addDays(-1);
        insert pg2;    
        
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
        
        
        List<SBQQ__Quote__c> lstquotes = new List<SBQQ__Quote__c>();  
        List<Id> lstquotesid = new List<Id>(); 
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Type__c='Quote';
        quote.SBQQ__Opportunity2__c=salesOppty.id;
        insert quote;
        
        lstquotes.add(quote);
        lstquotesid.add(quote.id);
        
        Product2 product = factory.createProduct('99999802', 'MediaServices', null, null, null);
        product.productCode = 'MCS BUNDLE';
        insert product;
        Product2 prod2 = [Select Id From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
        
        SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
            Name = 'ALT'
        );
        insert sg;
        SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c(
            SBQQ__SolutionGroup__c = sg.Id, SBQQ__Quote__c = quote.Id, Name = 'ALT'
        );
        insert qlg;
        list<SBQQ__QuoteLine__c> sbqqlinelst = new list<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = factory.createQuoteLine(quote.Id, prod2.Id, null);
        ql.L2I_CPQMultiplier__c = 'Contracted Shipments';
        ql.L2I_Number_of_Shipments__c = 5;
        ql.SBQQ__SubscriptionTerm__c = 12;
        ql.L2I_MonthlyPrice2__c = 20;
        ql.SBQQ__Group__c = qlg.Id;
        ql.SBQQ__Product__c = prod2.id;
        ql.SBQQ__ListPrice__c = 20.0;
        ql.L2I_TotalCostperAircraft2__c =20.0;
        ql.SBQQ__UnitCost__c = 5.00;
        SBQQ__QuoteLine__c ql1 = factory.createQuoteLine(quote.Id, prod2.Id, null);
        ql1.L2I_CPQMultiplier__c = 'AC Qty';
        ql1.L2I_Number_of_Shipments__c = 5;
        ql1.L2I_Service_Activation_Type__c = 'OneTime';
        ql1.SBQQ__SubscriptionTerm__c = 12;
        ql1.L2I_MonthlyPrice2__c = 20;
        ql1.SBQQ__Group__c = qlg.Id;
        ql1.SBQQ__Product__c = prod2.id;
        ql1.SBQQ__ListPrice__c = 20.0;
        ql1.L2I_TotalCostperAircraft2__c =20.0;
        ql1.SBQQ__UnitCost__c = 5.00;
        SBQQ__QuoteLine__c ql21 = factory.createQuoteLine(quote.Id, prod2.Id, null);
        ql21.L2I_CPQMultiplier__c = 'Total AC Service Months';
        ql21.L2I_Number_of_Shipments__c = 5;
        ql21.SBQQ__SubscriptionTerm__c = 12;
        ql21.L2I_MonthlyPrice2__c = 20;
        ql21.SBQQ__Group__c = qlg.Id;
        ql21.SBQQ__Product__c = prod2.id;
        ql21.SBQQ__ListPrice__c = 20.0;
        ql21.L2I_TotalCostperAircraft2__c =20.0;
        ql21.L2I_MonthlyPrice2__c = 5;
        ql21.SBQQ__UnitCost__c = 5.00;
        SBQQ__QuoteLine__c ql3 = factory.createQuoteLine(quote.Id, prod2.Id, null);
        ql3.L2I_CPQMultiplier__c = 'Total AC Service Years';
        ql3.L2I_Number_of_Shipments__c = 5;
        ql3.SBQQ__SubscriptionTerm__c = 12;
        ql3.L2I_MonthlyPrice2__c = 20;
        ql3.SBQQ__Group__c = qlg.Id;
        ql3.SBQQ__Product__c = prod2.id;
        ql3.SBQQ__ListPrice__c = 20.0;
        ql3.L2I_TotalCostperAircraft2__c =20.0;
        ql3.L2I_MonthlyPrice2__c = 2;
        ql3.SBQQ__UnitCost__c = 5.00;
        SBQQ__QuoteLine__c ql4 = factory.createQuoteLine(quote.Id, prod2.Id, null);
        ql4.L2I_CPQMultiplier__c = 'Annual Subscription Term';
        ql4.L2I_Number_of_Shipments__c = 5;
        ql4.SBQQ__SubscriptionTerm__c = 12;
        ql4.L2I_MonthlyPrice2__c = 20;
        ql4.SBQQ__Group__c = qlg.Id;
        ql4.SBQQ__Product__c = prod2.id;
        ql4.SBQQ__ListPrice__c = 20.0;
        ql4.L2I_TotalCostperAircraft2__c =20.0;
        ql4.L2I_MonthlyPrice2__c = 3;
        ql4.SBQQ__UnitCost__c = 5.00;
        SBQQ__QuoteLine__c ql5 = factory.createQuoteLine(quote.Id, prod2.Id, null);
        ql5.L2I_CPQMultiplier__c = 'Quote Subscription Term';
        ql5.L2I_Number_of_Shipments__c = 5;
        ql5.SBQQ__SubscriptionTerm__c = 12;
        ql5.L2I_MonthlyPrice2__c = 20;
        ql5.SBQQ__Group__c = qlg.Id;
        ql5.SBQQ__Product__c = prod2.id;
        ql5.SBQQ__ListPrice__c = 20.0;
        ql5.L2I_TotalCostperAircraft2__c =20.0;
        ql5.L2I_MonthlyPrice2__c = 3;
        ql5.SBQQ__UnitCost__c = 5.00;
        sbqqlinelst.add(ql);
        sbqqlinelst.add(ql1);
        sbqqlinelst.add(ql21);
        sbqqlinelst.add(ql3);
        sbqqlinelst.add(ql4);
        sbqqlinelst.add(ql5);
        insert sbqqlinelst;
        
        List<PL_PS__c> lstPs = new List<PL_PS__c>();
        PL_PS__c plps = new PL_PS__c();
        plps.Name='IFE Hardware';
        
        plps.Cost__c=500;
        plps.Credit__c=100;
        plps.Quote__c=quote.Id;
        plps.Gross_Sales__c=5000;
        plps.Net_Sales__c=4500;
        
        lstPs.add(plps);
        plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
        insert plApproval;
        
        L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOppty.Id);
        insert plSalesOpp;
        // Order ord1 = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
        SBQQ__Quote__c q1 = [
            SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            LIMIT 1
        ];
        Contract ctr = new Contract(
            AccountId = acctCustomer.Id,
            // SBQQ__Order__c = ord1.Id,
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
        salesOppty.SBQQ__RenewedContract__c = ctr.Id;
        update salesOppty;
        list<SBQQ__Subscription__c> sbqqsublst = new list<SBQQ__Subscription__c>();
        SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
        obj.SBQQ__Account__c = acctCustomer.Id;
        obj.SBQQ__Product__c = prod2.Id;
        obj.SBQQ__Contract__c = ctr.Id;
        obj.SBQQ__Quantity__c = 10.00;
        obj.SBQQ__ProductSubscriptionType__c = 'Renewable';
        obj.SBQQ__SubscriptionType__c = 'Renewable';
        obj.SBQQ__QuoteLine__c = ql.Id;
        SBQQ__Subscription__c obj1 = new SBQQ__Subscription__c();
        obj1.SBQQ__Account__c = acctCustomer.Id;
        obj1.SBQQ__Product__c = prod2.Id;
        obj1.SBQQ__Contract__c = ctr.Id;
        obj1.SBQQ__Quantity__c = 10.00;
        obj1.SBQQ__ProductSubscriptionType__c = 'Renewable';
        obj1.SBQQ__SubscriptionType__c = 'Renewable';
        obj1.SBQQ__QuoteLine__c = ql1.Id;
        SBQQ__Subscription__c obj2 = new SBQQ__Subscription__c();
        obj2.SBQQ__Account__c = acctCustomer.Id;
        obj2.SBQQ__Product__c = prod2.Id;
        obj2.SBQQ__Contract__c = ctr.Id;
        obj2.SBQQ__Quantity__c = 10.00;
        obj2.SBQQ__ProductSubscriptionType__c = 'Renewable';
        obj2.SBQQ__SubscriptionType__c = 'Renewable';
        obj2.SBQQ__QuoteLine__c = ql21.Id;
        SBQQ__Subscription__c obj3 = new SBQQ__Subscription__c();
        obj3.SBQQ__Account__c = acctCustomer.Id;
        obj3.SBQQ__Product__c = prod2.Id;
        obj3.SBQQ__Contract__c = ctr.Id;
        obj3.SBQQ__Quantity__c = 10.00;
        obj3.SBQQ__ProductSubscriptionType__c = 'Renewable';
        obj3.SBQQ__SubscriptionType__c = 'Renewable';
        obj3.SBQQ__QuoteLine__c = ql3.Id;
        SBQQ__Subscription__c obj4 = new SBQQ__Subscription__c();
        obj4.SBQQ__Account__c = acctCustomer.Id;
        obj4.SBQQ__Product__c = prod2.Id;
        obj4.SBQQ__Contract__c = ctr.Id;
        obj4.SBQQ__Quantity__c = 10.00;
        obj4.SBQQ__ProductSubscriptionType__c = 'Renewable';
        obj4.SBQQ__SubscriptionType__c = 'Renewable';
        obj4.SBQQ__QuoteLine__c = ql4.Id;
        SBQQ__Subscription__c obj5 = new SBQQ__Subscription__c();
        obj5.SBQQ__Account__c = acctCustomer.Id;
        obj5.SBQQ__Product__c = prod2.Id;
        obj5.SBQQ__Contract__c = ctr.Id;
        obj5.SBQQ__Quantity__c = 10.00;
        obj5.SBQQ__ProductSubscriptionType__c = 'Renewable';
        obj5.SBQQ__SubscriptionType__c = 'Renewable';
        obj5.SBQQ__QuoteLine__c = ql5.Id;
        sbqqsublst.add(obj4);// rename 
        sbqqsublst.add(obj5);
        sbqqsublst.add(obj2);
        sbqqsublst.add(obj3);
        sbqqsublst.add(obj);
        sbqqsublst.add(obj1);
        insert sbqqsublst;
        
    }
    
    @isTest
    private static void TestDataOnLoad() 
    {
        Test.startTest();
        
        setupTestData();
        test.stopTest();
        List<SBQQ__Quote__c> lstquotes = new List<SBQQ__Quote__c>(); 
        List<Id> lstquotesid = new List<Id>(); 
        lstquotes = [Select id from SBQQ__Quote__c];
        for(SBQQ__Quote__c qts : lstquotes ){
            lstquotesid.add(qts.id);
        }
        
        PL_Utils.createPLData(lstquotesid);
        PL_UtilsFunctions plutilfuncspbj = new PL_UtilsFunctions(lstquotesid[0]);
        plutilfuncspbj.delQuotePSData(lstquotesid[0]);
        plutilfuncspbj.createQuotePSData();
        plutilfuncspbj.NonShipsetCreditSpread();
        plutilfuncspbj.WarrantyCostSpread();
        plutilfuncspbj.ShipsetCreditSpread();
        plutilfuncspbj.getQPSRecord(null);
        
        List<PL_PS__c> plpslst = [Select id,Name, Product_Summary__r.name, Cost__c, Credit__c, Discount__c,
                        Red_in_GS__c, ps_NS_to_Cust__c, ps_GM__c, Gross_Sales__c, Net_Sales__c, Product_Group__c,
                        Product_Summary__c, Quote__c, Quote__r.L2I_Aircraft_Quantity__c, Quote__r.L2I_Total_Seat_Count__c,
                        Sort_Order__c from PL_PS__c limit 1];
        system.debug('checkkk' + plpslst);
        System.assert(plpslst.size()>0);
        system.assertEquals(6, plpslst[0].Sort_Order__c);
        
    }
    
    @isTest
    private static void TestCreateQuotePSData()
    {
        Test.startTest();
        setupTestData();
        Test.stopTest();
        SBQQ__Quote__c qt  = [Select id, L2I_Booking_Adj_AC_Service_Months__c, L2I_Bookings_Adj_Subscription_Term__c from SBQQ__Quote__c];
        qt.L2I_Booking_Adj_AC_Service_Months__c = 2;
        qt.L2I_Bookings_Adj_Subscription_Term__c = 3;
        update qt;
        PL_UtilsFunctions plu = new PL_UtilsFunctions(qt.Id);
        plu.createQuotePSData();
        System.assertNotEquals(0, [SELECT Cost__c, Net_Sales__c, Gross_Sales__c FROM PL_PS__c LIMIT 1].Cost__c);
        System.assertNotEquals(0, [SELECT Cost__c, Net_Sales__c, Gross_Sales__c FROM PL_PS__c LIMIT 1].Net_Sales__c);
        System.assertNotEquals(0, [SELECT Cost__c, Net_Sales__c, Gross_Sales__c FROM PL_PS__c LIMIT 1].Net_Sales__c);
    }
    
    @isTest
    private static void TestDeleteQuotePSData()
    {
        Test.startTest();
        setupTestData();
        Test.stopTest();
        SBQQ__Quote__c qt  = [Select id, L2I_Booking_Adj_AC_Service_Months__c, L2I_Bookings_Adj_Subscription_Term__c from SBQQ__Quote__c];
        qt.L2I_Booking_Adj_AC_Service_Months__c = 2;
        qt.L2I_Bookings_Adj_Subscription_Term__c = 3;
        update qt;
        PL_UtilsFunctions plu = new PL_UtilsFunctions(qt.Id);
        plu.delQuotePSData(qt.Id);
        System.assertEquals(0, [SELECT COUNT() FROM PL_PS__c WHERE Quote__c = :qt.Id]);
    }
    
    @isTest
    private static void TestCreateQuotePSData2()
    {        
        setupTestData();  
        Test.startTest();
        L2I_DataFactory factory = new L2I_DataFactory();
        
        SBQQ__Quote__c qt  = [Select id, L2I_Booking_Adj_AC_Service_Months__c, L2I_Bookings_Adj_Subscription_Term__c from SBQQ__Quote__c];
        PL_MD__c ps = [SELECT Id FROM PL_MD__c WHERE MD_Type__c = 'Product Summary' AND Name = 'Connectivity' LIMIT 1]; 
        Product2 prod2 = [Select Id,PL_Product_Summary__c From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
        prod2.PL_Product_Summary__c = ps.Id;
        update prod2;
        
        SBQQ__QuoteLine__c ql = factory.createQuoteLine(qt.Id, prod2.Id, null);
        ql.L2I_CPQMultiplier__c = 'Contracted Shipments';
        ql.L2I_Number_of_Shipments__c = 5;
        ql.SBQQ__SubscriptionTerm__c = 12;
        ql.L2I_MonthlyPrice2__c = 20;
        ql.SBQQ__Product__c = prod2.id;
        ql.SBQQ__ListPrice__c = 20.0;
        ql.L2I_TotalCostperAircraft2__c = 20.0;
        ql.SBQQ__UnitCost__c = 5.00;
        insert ql; 

        PL_UtilsFunctions plu = new PL_UtilsFunctions(qt.Id);
        plu.createQuotePSData();
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM PL_PS__c WHERE Quote__c =: qt.Id ]);
    }
    
    @isTest
    private static void TestCreateQuotePSData3()
    {        
        setupTestData();        
        
        Test.startTest();
        L2I_DataFactory factory = new L2I_DataFactory();        
        
        SBQQ__Quote__c qt  = [Select id, L2I_Booking_Adj_AC_Service_Months__c, L2I_Bookings_Adj_Subscription_Term__c from SBQQ__Quote__c];
        Product2 prod2 = [Select Id,PL_Product_Summary__c From Product2 Where productCode = 'MCS BUNDLE' LIMIT 1];
        
        SBQQ__QuoteLine__c ql = factory.createQuoteLine(qt.Id, prod2.Id, null);
        ql.L2I_CPQMultiplier__c = 'Contracted Shipments';
        ql.L2I_Number_of_Shipments__c = 5;
        ql.SBQQ__SubscriptionTerm__c = 12;
        ql.L2I_MonthlyPrice2__c = 20;
        ql.SBQQ__Product__c = prod2.id;
        ql.SBQQ__ListPrice__c = 20.0;
        ql.L2I_TotalCostperAircraft2__c =20.0;
        ql.SBQQ__UnitCost__c = 5.00;
        insert ql; 

        PL_UtilsFunctions plu = new PL_UtilsFunctions(qt.Id);
        plu.createQuotePSData();
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM PL_PS__c WHERE Quote__c =: qt.Id ]);
    }
}