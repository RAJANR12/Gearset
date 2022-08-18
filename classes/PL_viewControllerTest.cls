@IsTest
private with sharing class PL_viewControllerTest
{
    private static L2I_P_L_Approval__c plApproval;
    private static void setupTestData()
    {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        List<PL_MD__c> lstPlmd = new List<PL_MD__c>();
        PL_MD__c plmd = new PL_MD__c();
        plmd.Name='IFE Hardware';
        plmd.Pillar__c='IFE';
        plmd.Product_Group__c='IFE Hardware';
        plmd.Sort_Order__c=1;
        plmd.Sort_Order__c=90;
        plmd.MD_Type__c ='Product Group';
        lstPlmd.add(plmd);
       
        PL_MD__c plmd1 = new PL_MD__c();
        plmd1.Name='IFE Services';
        plmd1.Pillar__c='IFE';
        plmd1.Product_Group__c='IFE Hardware';
        plmd1.Sort_Order__c=2;
        plmd1.Sort_Order__c=80;
        plmd1.MD_Type__c ='Product Group';
        lstPlmd.add(plmd1);
        
        PL_MD__c plmd2 = new PL_MD__c();
        plmd2.Name='IFC Hardware';
        plmd2.Pillar__c='IFC';
        plmd2.Product_Group__c='IFC Hardware';
        plmd2.Sort_Order__c=3;
        plmd2.Sort_Order__c=70;
        plmd2.MD_Type__c ='Product Group';
        lstPlmd.add(plmd2);
        
        PL_MD__c plmd3 = new PL_MD__c();
        plmd3.Name='IFC Services';
        plmd3.Pillar__c='IFC';
        plmd3.Product_Group__c='IFC Hardware';
        plmd3.Sort_Order__c=4;
        plmd3.Sort_Order__c=60;
        plmd3.MD_Type__c ='Product Group';
        lstPlmd.add(plmd3);
        
        PL_MD__c plmd4 = new PL_MD__c();
        plmd4.Name='DSS';
        plmd4.Pillar__c='DSS';
        plmd4.Product_Group__c='IFE Hardware';
        plmd4.Sort_Order__c=5;
        plmd4.Sort_Order__c=500;
        plmd4.MD_Type__c ='Product Group';
        lstPlmd.add(plmd4);
        
        PL_MD__c plmd5 = new PL_MD__c();
        plmd5.Name='PTS';
        plmd5.Pillar__c='PTS';
        plmd5.Product_Group__c='IFE Hardware';
        plmd5.Sort_Order__c=6;
        plmd5.Sort_Order__c=500;
        plmd5.MD_Type__c ='Product Group';
        lstPlmd.add(plmd5);
        
        PL_MD__c plmd6 = new PL_MD__c();
        plmd6.Name='PTS';
        plmd6.Pillar__c='PTS';
        plmd6.Product_Group__c='IFE Hardware';
        plmd6.Sort_Order__c=6;
        plmd6.Sort_Order__c=500;
        plmd6.MD_Type__c ='Product Summary';
        lstPlmd.add(plmd6);
        
        PL_MD__c plmd7 = new PL_MD__c();
        plmd7.Name='DSS';
        plmd7.Pillar__c='DSS';
        plmd7.Product_Group__c='IFE Hardware';
        plmd7.Sort_Order__c=105;
        plmd7.Sort_Order__c=500;
        plmd7.MD_Type__c ='Product Summary';
        lstPlmd.add(plmd7);
        
        PL_MD__c plmd8 = new PL_MD__c();
        plmd8.Name='DSS';
        plmd8.Pillar__c='DSS';
        plmd8.Product_Group__c='IFE Hardware';
        plmd8.Sort_Order__c=105;
        plmd7.Sort_Order__c=500;
        plmd8.MD_Type__c ='-PCT';
        //lstPlmd.add(plmd8);
        
        insert lstPlmd;
        //---------------------------------
        List<PL_MD__c> lstPlSum = new List<PL_MD__c>();
        PL_MD__c Prod = new PL_MD__c();
        Prod.Name='SEATEND LRU';
        Prod.Pillar__c='PTS';
        Prod.Product_Group__c='IFE Hardware';
        Prod.Sort_Order__c=6;
        Prod.MD_Type__c ='Product Summary';
        lstPlSum.add(Prod);
        
        insert lstPlSum;
        //----------------------------------------------------------------
        
        List<PL_MD__c> lstcost = new List<PL_MD__c>();
        PL_MD__c ProdSum1 = new PL_MD__c();
        ProdSum1.Name='Gross Sales';
        ProdSum1.Pillar__c='PTS';
        ProdSum1.Product_Group__c='IFE Hardware';
        ProdSum1.Sort_Order__c=6;
        ProdSum1.L2I_Migration_External_Id__c='CAL-COGS-GM';
        ProdSum1.MD_Type__c ='Cost Allocation';
        ProdSum1.Cost_Allocation__c='Gross Sales';
        ProdSum1.color__c='#8da2c1';
        lstcost.add(ProdSum1);
        
        PL_MD__c ProdSum11 = new PL_MD__c();
        ProdSum11.Name='Gross';
        ProdSum11.Pillar__c='PTS';
        ProdSum11.Product_Group__c='IFE Hardware';
        ProdSum11.Sort_Order__c=6;
        ProdSum11.color__c='#8da2c1';
        ProdSum11.L2I_Migration_External_Id__c='-SALES-';
        ProdSum11.MD_Type__c ='Cost Allocation';
        ProdSum11.Cost_Allocation__c='Gross Sales';
        lstcost.add(ProdSum11);
        
        PL_MD__c ProdSum2 = new PL_MD__c();
        ProdSum2.Name='Discount & Allowances';
        ProdSum2.Pillar__c='PTS';
        ProdSum2.Product_Group__c='IFE Hardware';
        ProdSum2.Sort_Order__c=6;
        ProdSum2.L2I_Migration_External_Id__c='123456782-PCT';
        ProdSum2.MD_Type__c ='Cost Allocation';
        ProdSum2.color__c='#8da2c1';
        lstcost.add(ProdSum2);
        
        PL_MD__c ProdSum3 = new PL_MD__c();
        ProdSum3.Name='Pct (%) Discount/Credits';
        ProdSum3.Pillar__c='PTS';
        ProdSum3.Product_Group__c='IFE Hardware';
        ProdSum3.Sort_Order__c=6;
        ProdSum3.L2I_Migration_External_Id__c='CAL-AC-PBT';
        ProdSum3.MD_Type__c ='Cost Allocation';
        ProdSum3.color__c='#8da2c1';
        lstcost.add(ProdSum3);
        
        PL_MD__c ProdSum4 = new PL_MD__c();
        ProdSum4.Name='TOTAL - SALES';
        ProdSum4.Pillar__c='PTS';
        ProdSum4.Product_Group__c='IFE Hardware';
        ProdSum4.Sort_Order__c=6;
        ProdSum4.L2I_Migration_External_Id__c='123456784-PCT';
        ProdSum4.MD_Type__c ='Cost Allocation';
        ProdSum4.color__c='#8da2c1';
        ProdSum4.Sort_Order__c=500;
        lstcost.add(ProdSum4);
        insert lstcost;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Type__c='Quote';
        //quote.L2I_Total_Seat_Count__c='190';
        insert quote;
        
        PL_Product_Group__c pg = new PL_Product_Group__c();
        pg.PL_MD__c = plmd.id;
        pg.Start_Date__c = system.today().addDays(-1);
        //pg.is_Active__c=true;
        insert pg;       
        
        PL_MD__c PL_MD = new PL_MD__c();
        PL_MD.Name='Administration';
        PL_MD.Sort_Order__c=630;
        PL_MD.color__c='#8da2c1';
        PL_MD.Cost_Allocation__c    ='ALLOCATION COST';
        PL_MD.Cost_Allocation_Item__c   ='Administration';
        PL_MD.MD_Type__c ='Cost Allocation';
        PL_MD.L2I_Migration_External_Id__c  ='CAL-AC-ADMIN';
        insert PL_MD;
        
        PL_CAL__c cal = new PL_CAL__c();
        cal.Percent__c= 10; 
        //cal.Cost_Allocation__c    ='ALLOCATION COST';
        //cal.Cost_Allocation_Item__c   ='Administration';
        cal.Allocation_Type__c  ='% of NET SALES';
        cal.pl_MD__c=PL_MD.id;  
        cal.Product_Group__c=pg.id;
        Insert cal;
        
        List<PL_PS__c> lstPs = new List<PL_PS__c>();
        PL_PS__c plps = new PL_PS__c();
        plps.Name='IFE Hardware';       
        plps.Cost__c=500;
        plps.Credit__c=100;
        plps.Quote__c=quote.Id;
        plps.Gross_Sales__c=5000;
        plps.Net_Sales__c=4500;
        plps.Product_Group__c=pg.Id;
        plps.Product_Summary__c=lstPlSum[0].id;
        lstPs.add(plps);
        
        PL_PS__c plps2 = new PL_PS__c();
        plps2.Name='IFE Services';       
        plps2.Cost__c=500;
        plps2.Credit__c=100;
        plps2.Quote__c=quote.Id;
        plps2.Gross_Sales__c=5000;
        plps2.Net_Sales__c=4500;
        plps2.Product_Group__c=pg.Id;
        plps2.Product_Summary__c=lstPlSum[0].id;
        lstPs.add(plps2);
        Insert lstPs;
        
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
        
         plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
        insert plApproval;
   
        L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOppty.Id);
        insert plSalesOpp;
        List<PLA_Page_ShipsetList__c> shipset = new List<PLA_Page_ShipsetList__c>();
        PLA_Page_ShipsetList__c row1 = new PLA_Page_ShipsetList__c(name = 'IFE Hardware', PL_Approval__c = plApproval.id, Sort_order__c=0 );
        PLA_Page_ShipsetList__c row2 = new PLA_Page_ShipsetList__c(name = 'IFC Hardware', PL_Approval__c = plApproval.id, Sort_order__c= 2);
        PLA_Page_ShipsetList__c row3 = new PLA_Page_ShipsetList__c(name = 'IFE Services', PL_Approval__c = plApproval.id, Sort_order__c= 50);

        shipset.add(row1);
        shipset.Add(row2);
        shipset.Add(row3);
        //insert shipset; 
        PLA_Page_ProductServices_List__c service = new PLA_Page_ProductServices_List__c (name ='Training',P_L_Approval__c = plApproval.id, Row_Color_Code__c ='#000'); // W-004435 Updated
        insert service; 
        PLA_Page_ConsolidatedList__c consolidated = new PLA_Page_ConsolidatedList__c(name = 'Test1', P_L_Approval__c = plApproval.id);
        insert consolidated;
        PLA_Page_Header__c  header = new PLA_Page_Header__c (name = 'Test2', Pl_Approval__c  = plApproval.id);
        insert header;   
        PLA_Page_Opportunity_List__c opportunity = new  PLA_Page_Opportunity_List__c(name = 'Test5',pl_approval__c = PlApproval.id  );
        insert opportunity;     
      
    }
    private static void setupTestDataNoHeader()
    {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        List<PL_MD__c> lstPlmd = new List<PL_MD__c>();
        
        
        //---------------------------------------------------------------
        List<PL_MD__c> lstcost = new List<PL_MD__c>();
        PL_MD__c ProdSum1 = new PL_MD__c();
        ProdSum1.Name='Gross Sales';
        ProdSum1.Pillar__c='PTS';
        ProdSum1.Product_Group__c='IFE Hardware';
        ProdSum1.Sort_Order__c=6;
        ProdSum1.L2I_Migration_External_Id__c='CAL-COGS-GM';
        ProdSum1.MD_Type__c ='Cost Allocation';
        ProdSum1.Cost_Allocation__c='Gross Sales';
        ProdSum1.color__c='#8da2c1';
        lstcost.add(ProdSum1);
        
        PL_MD__c ProdSum11 = new PL_MD__c();
        ProdSum11.Name='Gross';
        ProdSum11.Pillar__c='PTS';
        ProdSum11.Product_Group__c='IFE Hardware';
        ProdSum11.Sort_Order__c=6;
        ProdSum11.color__c='#8da2c1';
        ProdSum11.L2I_Migration_External_Id__c='-SALES-';
        ProdSum11.MD_Type__c ='Cost Allocation';
        ProdSum11.Cost_Allocation__c='Gross Sales';
        lstcost.add(ProdSum11);
        
        PL_MD__c ProdSum2 = new PL_MD__c();
        ProdSum2.Name='Discount & Allowances';
        ProdSum2.Pillar__c='PTS';
        ProdSum2.Product_Group__c='IFE Hardware';
        ProdSum2.Sort_Order__c=6;
        ProdSum2.L2I_Migration_External_Id__c='123456782-PCT';
        ProdSum2.MD_Type__c ='Cost Allocation';
        ProdSum2.color__c='#8da2c1';
        lstcost.add(ProdSum2);
        
        PL_MD__c ProdSum3 = new PL_MD__c();
        ProdSum3.Name='Pct (%) Discount/Credits';
        ProdSum3.Pillar__c='PTS';
        ProdSum3.Product_Group__c='IFE Hardware';
        ProdSum3.Sort_Order__c=6;
        ProdSum3.L2I_Migration_External_Id__c='CAL-AC-PBT';
        ProdSum3.MD_Type__c ='Cost Allocation';
        ProdSum3.color__c='#8da2c1';
        lstcost.add(ProdSum3);
        
        PL_MD__c ProdSum4 = new PL_MD__c();
        ProdSum4.Name='TOTAL - SALES';
        ProdSum4.Pillar__c='PTS';
        ProdSum4.Product_Group__c='IFE Hardware';
        ProdSum4.Sort_Order__c=6;
        ProdSum4.L2I_Migration_External_Id__c='123456784-PCT';
        ProdSum4.MD_Type__c ='Cost Allocation';
        ProdSum4.color__c='#8da2c1';
        ProdSum4.Sort_Order__c=500;
        lstcost.add(ProdSum4);
        insert lstcost;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Type__c='Quote';
        //quote.L2I_Total_Seat_Count__c='190';
        insert quote;
        
         
        
        PL_MD__c PL_MD = new PL_MD__c();
        PL_MD.Name='Administration';
        PL_MD.Sort_Order__c=630;
        PL_MD.color__c='#8da2c1';
        PL_MD.Cost_Allocation__c    ='ALLOCATION COST';
        PL_MD.Cost_Allocation_Item__c   ='Administration';
        PL_MD.MD_Type__c ='Cost Allocation';
        PL_MD.L2I_Migration_External_Id__c  ='CAL-AC-ADMIN';
        insert PL_MD;

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
        
         plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
        insert plApproval;
   
        L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOppty.Id);
        insert plSalesOpp;
        List<PLA_Page_ShipsetList__c> shipset = new List<PLA_Page_ShipsetList__c>();
        PLA_Page_ShipsetList__c row1 = new PLA_Page_ShipsetList__c(name = 'Row 1', PL_Approval__c = plApproval.id, Sort_order__c=0 );
        PLA_Page_ShipsetList__c row2 = new PLA_Page_ShipsetList__c(name = 'Row 2', PL_Approval__c = plApproval.id, Sort_order__c= 2);
        PLA_Page_ShipsetList__c row3 = new PLA_Page_ShipsetList__c(name = 'Row 3', PL_Approval__c = plApproval.id, Sort_order__c= 50);

        shipset.add(row1);
        shipset.Add(row2);
        shipset.Add(row3);
        insert shipset; 
        PLA_Page_ProductServices_List__c  service = new PLA_Page_ProductServices_List__c (name ='Test 4',P_L_Approval__c = plApproval.id );
        insert service; 
        PLA_Page_ConsolidatedList__c consolidated = new PLA_Page_ConsolidatedList__c(name = 'Test1', P_L_Approval__c = plApproval.id);
        insert consolidated;
        PLA_Page_Header__c  header = new PLA_Page_Header__c (name = 'Test2', Pl_Approval__c  = plApproval.id);
        insert header;   
        PLA_Page_Opportunity_List__c opportunity = new  PLA_Page_Opportunity_List__c(name = 'Test5',pl_approval__c = PlApproval.id  );
        insert opportunity;     
      
    }

    @isTest
    private static void TestDataOnLoad() 
    {
        Test.startTest();
 
        setupTestData();
        ApexPages.StandardController standardController = new ApexPages.StandardController(plApproval); 
        PL_viewController plview = new PL_viewController(standardController);
        plview.initializeMarginPercents();
        //plview.bind_ProductList();
        Test.stopTest();
       
    }
    @isTest
    private static void TestDataOnLoadnoHeader() 
    {
        Test.startTest();
 
        setupTestDataNoHeader();
        ApexPages.StandardController standardController = new ApexPages.StandardController(plApproval); 
        PL_viewController plview = new PL_viewController(standardController);
        Test.stopTest();
       
    }
   
    @isTest
   private static void TestDataOnLoad2() 
    {
        Test.startTest();
 
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        List<PL_MD__c> lstPlmd = new List<PL_MD__c>();
        
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
        //Prod.Sub_Total_Label__c='IFE';
        Prod.MD_Type__c ='Product Summary';
        lstPlmd.add(Prod);
          
        insert lstPlmd;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Type__c='Quote';
        //quote.L2I_Total_Seat_Count__c='190';
        insert quote;
      
        
        List<PL_PS__c> lstPs = new List<PL_PS__c>();
        PL_PS__c plps = new PL_PS__c();
        plps.Name='IFE Hardware';
       
        plps.Cost__c=500;
        plps.Credit__c=100;
        plps.Quote__c=quote.Id;
        plps.Gross_Sales__c=5000;
        plps.Net_Sales__c=4500;
        //plps.Product_Group__c='Product Summary';
        //plps.Product_Summary__c='';
        //plps.Quote__c=500;
        //plps.Total_Cost__c=100;
        //plps.Sort_Order__c=1;
        
        lstPs.add(plps);
        
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
        

        plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
        insert plApproval;
        
        L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOppty.Id);
        insert plSalesOpp;

        PLA_Page_ConsolidatedList__c consolidated = new PLA_Page_ConsolidatedList__c(name = 'Test1', P_L_Approval__c = plApproval.id);
        insert consolidated;
        PLA_Page_Header__c  header = new PLA_Page_Header__c (name = 'Test2', Pl_Approval__c  = plApproval.id);
        insert header;
       
       
        PLA_Page_Opportunity_List__c opportunity = new  PLA_Page_Opportunity_List__c(name = 'Test5',pl_approval__c = PlApproval.id  );
        insert opportunity;                   
                       
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(plApproval); 
        PL_viewController plview = new PL_viewController(standardController);
        
        Test.stopTest();
       
    }
    //*/
    
    
    @isTest
    private static void TestDataOnLoad3() 
    {
        Test.startTest();
 
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        List<PL_MD__c> lstPlmd = new List<PL_MD__c>();
        PL_MD__c plmd = new PL_MD__c();
        plmd.Name='SEATEND LRU';
        plmd.Product_Group__c='IFE Hardware';
        plmd.Sort_Order__c=1;
        plmd.L2I_Migration_External_Id__c   ='IFE-H-Seatend';
        plmd.Color__c='#FFFF00';                
        plmd.MD_Type__c ='Product Summary';
        lstPlmd.add(plmd); 
        
        PL_MD__c plmd2 = new PL_MD__c();
        plmd2.Name='HEADEND LRU';
        plmd2.Product_Group__c='IFE Hardware';
        plmd2.Sort_Order__c=2;
        plmd2.L2I_Migration_External_Id__c  ='IFE-H-Headend';
        plmd2.Color__c='#FFFF00';                
        plmd2.MD_Type__c ='Product Summary';
        lstPlmd.add(plmd2);
        
         PL_MD__c plmd3 = new PL_MD__c();
        plmd3.Name='HARNESS';
        plmd3.Product_Group__c='IFE Hardware';
        plmd3.Sort_Order__c=3;
        plmd3.L2I_Migration_External_Id__c  ='IFE-H-Harness';
        plmd3.Color__c='#FFFF00';                
        plmd3.MD_Type__c ='Product Summary';
        lstPlmd.add(plmd3);
        
        PL_MD__c plmd4 = new PL_MD__c();
        plmd4.Name='STRUCTURES';
        plmd4.Product_Group__c='IFE Hardware';
        plmd4.Sort_Order__c=4;
        plmd4.L2I_Migration_External_Id__c  ='IFE-H-Structure';
        plmd4.Color__c='#FFFF00';                
        plmd4.MD_Type__c ='Product Summary';
        lstPlmd.add(plmd4);
        
        PL_MD__c plmd101 = new PL_MD__c();
        plmd101.Name='Spares';
        plmd101.Product_Group__c='IFE Services';
        plmd101.Sort_Order__c=101;
        plmd101.L2I_Migration_External_Id__c    ='IFE-S-Spares';
        plmd101.Color__c='#FFFF00';                
        plmd101.MD_Type__c ='Product Summary';
        lstPlmd.add(plmd101);
        
        PL_MD__c plmd109 = new PL_MD__c();
        plmd109.Name='Extended Warranty';
        plmd109.Product_Group__c='IFE Services';
        plmd109.Sort_Order__c=109;
        plmd109.L2I_Migration_External_Id__c    ='IFE-S-Warranty';
        plmd109.Color__c='#FFFF00';                
        plmd109.MD_Type__c ='Product Summary';
        lstPlmd.add(plmd109);
        
        
        insert lstPlmd;
       
      
        //PL_Product_Group__c pg = new PL_Product_Group__c();
        ////pg.PL_MD__c = lstPlmd[0].id;
        //pg.Start_Date__c = system.today().addDays(-1);
        ////pg.is_Active__c=true;
        //insert pg;  
        
      /*  
        
        PL_CAL__c cal = new PL_CAL__c();
        cal.Percent__c= 10; 
        cal.Allocation_Type__c='ALLOCATION COST';
        cal.pl_MD__c=plmd.id;
        cal.Product_Group__c=pg.id;
      
        
        */
        
                
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        quote1.SBQQ__Type__c='Quote';
       
        insert quote1;

        Id customerRecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID;
         Account acctCustomer = new Account(
              Name = 'Acct1',
              RecordTypeId = customerRecordTypeId);
        insert acctCustomer;
        
        Opportunity dealOppty = new Opportunity(
              Name = 'Deal Opp',
              CloseDate = Date.today(),
              StageName = 'Open',
            SBQQ__PrimaryQuote__c =quote1.id 
        );               
        insert dealOppty;
        
         Opportunity salesOppty = new Opportunity(
              Name = 'Sales Opp',
              AccountId = acctCustomer.Id,
              RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
              L2I_Product_Category__c = 'DSS',
              CloseDate = Date.today(),
              StageName = 'Quotation',
              L2I_Parent_Opportunity__c = dealOppty.Id,
             L2I_AircraftQuantity__c =5
        );
        insert salesOppty;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Type__c='Quote';
        quote.SBQQ__Opportunity2__c=salesOppty.id;
        insert quote;
        
        /*
        List<PL_PS__c> lstPs = new List<PL_PS__c>();
        PL_PS__c plps = new PL_PS__c();
        plps.Name='IFE Hardware';       
        plps.Cost__c=500;
        plps.Credit__c=100;
        plps.Quote__c=quote.Id;
        //plps.Discount__c=10;
        //plps.Red_in_GS__c=0;
        //plps.ps_NS_to_Cust__c=0;
        plps.Gross_Sales__c=5000;
        plps.Net_Sales__c=4500;
        //plps.Product_Group__c=pg.Id;
        plps.Product_Summary__c=plApproval.id;
        lstPs.add(plps);
        //Insert lstPs;
        */
     
        plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
        insert plApproval;
        
        L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOppty.Id);
        insert plSalesOpp;        
        
     
        ApexPages.StandardController standardController = new ApexPages.StandardController(plApproval); 
        PL_viewController plview = new PL_viewController(standardController);
        plview.initializeMarginPercents();

     /*  List<PL_MD__c> plMDList = [SELECT id, Name, MD_Type__c,Product_Group__c, Sort_Order__c, L2I_Migration_External_Id__c, Color__c
                                  FROM PL_MD__C Where MD_Type__c = 'Product Summary' order by Sort_Order__c limit 1];
        
        system.assert(plMDList.size()>0);
       
        system.assertEquals('SEATEND LRU', plMDList[0].Name);
        system.assertEquals('IFE Hardware', plMDList[0].Product_Group__c);
        system.assertEquals('Product Summary', plMDList[0].MD_Type__c);*/

        Test.stopTest();
       
    }
    
    @isTest
    private static void TestUpdatePLApproval() {
        Test.startTest();
        L2I_DataFactory factory = new L2I_DataFactory();
        setupTestData();
        Test.stopTest();
        
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        Opportunity salesOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Sales' LIMIT 1];
        plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
        insert plApproval;
        L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOppty.Id);
        insert plSalesOpp;
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(plApproval);
        PL_viewController plview = new PL_viewController(standardController);
        List<PL_viewController.WrapperConsolidate> WrapperConsolidateList = new List<PL_viewController.WrapperConsolidate>();
        Map<String, PL_viewController.WrapperConsolidate> wrpConsMap2 = new Map<String, PL_viewController.WrapperConsolidate>();
    
        List<Decimal> lstVal = new List<Decimal>{1,2,3,4,5,6,7,8,9,10};
        
        PL_viewController.WrapperConsolidate wrp = new PL_viewController.WrapperConsolidate('CAL-SALES-TOT', 1, 'A', 2, 'red', 'gname',new List<String>{''}, '');
        wrp.lstValuesDec = lstVal;
        WrapperConsolidateList.add(wrp);
        wrpConsMap2.put('CAL-SALES-TOT', wrp);
    
        wrp = new PL_viewController.WrapperConsolidate('CAL-SALES-GROSS', 1, 'A', 2, 'red', 'gname',new List<String>{''}, '');
        wrp.lstValuesDec = lstVal;
        WrapperConsolidateList.add(wrp);
        wrpConsMap2.put('CAL-SALES-GROSS', wrp);
    
        wrp = new PL_viewController.WrapperConsolidate('CAL-COGS-TOT', 1, 'A', 2, 'red', 'gname',new List<String>{''}, '');
        wrp.lstValuesDec = lstVal;
        WrapperConsolidateList.add(wrp);
        wrpConsMap2.put('CAL-COGS-TOT', wrp);
    
        wrp = new PL_viewController.WrapperConsolidate('CAL-COGS-GM', 1, 'A', 2, 'red', 'gname',new List<String>{''}, '');
        wrp.lstValuesDec = lstVal;
        WrapperConsolidateList.add(wrp);
        wrpConsMap2.put('CAL-COGS-GM', wrp);
    
        wrp = new PL_viewController.WrapperConsolidate('CAL-VC-MP', 1, 'A', 2, 'red', 'gname',new List<String>{''}, '');
        wrp.lstValuesDec = lstVal;
        WrapperConsolidateList.add(wrp);
        wrpConsMap2.put('CAL-VC-MP', wrp);
    
        wrp = new PL_viewController.WrapperConsolidate('CAL-DF-DCM', 1, 'A', 2, 'red', 'gname',new List<String>{''}, '');
        wrp.lstValuesDec = lstVal;
        WrapperConsolidateList.add(wrp);
        wrpConsMap2.put('CAL-DF-DCM', wrp);
        
        wrp = new PL_viewController.WrapperConsolidate('CAL-DF-TOT', 1, 'A', 2, 'red', 'gname',new List<String>{''}, '');
        wrp.lstValuesDec = lstVal;
        WrapperConsolidateList.add(wrp);
        wrpConsMap2.put('CAL-DF-TOT', wrp);
    
        wrp = new PL_viewController.WrapperConsolidate('CAL-COGS-GM', 1, 'A', 2, 'red', 'gname',new List<String>{''}, '');
        wrp.lstValuesDec = lstVal;
        WrapperConsolidateList.add(wrp);
        wrpConsMap2.put('CAL-COGS-GM', wrp);
    
        wrp = new PL_viewController.WrapperConsolidate('CAL-AC-PBT', 1, 'A', 2, 'red', 'gname',new List<String>{''}, '');
        wrp.lstValuesDec = lstVal;
        WrapperConsolidateList.add(wrp);
        wrpConsMap2.put('CAL-AC-PBT', wrp);
    
        wrp = new PL_viewController.WrapperConsolidate('CAL-COGS-GM-PCT', 1, 'A', 2, 'red', 'gname',new List<String>{''}, '');
        wrp.lstValuesDec = lstVal;
        WrapperConsolidateList.add(wrp);
        wrpConsMap2.put('CAL-COGS-GM-PCT', wrp);
    
        wrp = new PL_viewController.WrapperConsolidate('CAL-VC-MP-PCT', 1, 'A', 2, 'red', 'gname',new List<String>{''}, '');
        wrp.lstValuesDec = lstVal;
        WrapperConsolidateList.add(wrp);
        wrpConsMap2.put('CAL-VC-MP-PCT', wrp);
    
        wrp = new PL_viewController.WrapperConsolidate('CAL-DF-CM-PCT', 1, 'A', 2, 'red', 'gname',new List<String>{''}, '');
        wrp.lstValuesDec = lstVal;
        WrapperConsolidateList.add(wrp);
        wrpConsMap2.put('CAL-DF-CM-PCT', wrp);
        
        wrp = new PL_viewController.WrapperConsolidate('CAL-AC-PTP-PCT', 1, 'A', 2, 'red', 'gname',new List<String>{''}, '');
        wrp.lstValuesDec = lstVal;
        WrapperConsolidateList.add(wrp);
        wrpConsMap2.put('CAL-AC-PTP-PCT', wrp);
        
        plview.wrpConsMap = wrpConsMap2;

        plview.updatePLApproval();
        
        System.assertEquals(9, plview.Plapproval.PL_T_NR__c);
        System.assertEquals(3, plview.Plapproval.PL_IFE_NR__c);
        System.assertEquals(6, plview.Plapproval.PL_IFC_NR__c);
        System.assertEquals(7, plview.Plapproval.PL_DSS_NR__c);
        System.assertEquals(8, plview.Plapproval.PL_PTS_NR__c);
    }
    
    @isTest
    private static void TestBindProduct() {
        Test.startTest();
        L2I_DataFactory factory = new L2I_DataFactory();
        setupTestData();
        Test.stopTest();
    
        Opportunity dealOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Deal' LIMIT 1];
        Opportunity salesOppty = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Sales' LIMIT 1];
        plApproval = factory.createPLApproval(dealOppty.Id, 'Approved');
        insert plApproval;
        L2I_P_L_Sales_Opportunity__c plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOppty.Id);
        insert plSalesOpp;
    
        ApexPages.StandardController standardController = new ApexPages.StandardController(plApproval);
        PL_viewController plview = new PL_viewController(standardController);
        List<PL_viewController.WrapperConsolidate> WrapperConsolidateList = new List<PL_viewController.WrapperConsolidate>();
        Map<String, PL_viewController.WrapperConsolidate> wrpConsMap2 = new Map<String, PL_viewController.WrapperConsolidate>();
        
        plView.AveHardrateTotalSC = 10;
        
        plView.psPLMDList = [SELECT ID, Name, Color__c, Sort_Order__c FROM  PL_MD__c];
        plView.psQPSList = [SELECT Id, Sort_Order__c, Quote__r.L2I_Aircraft_Quantity__c, Gross_Sales__c, Discount__c, Credit__c,
              ps_NS_to_Cust__c, Cost__c, ps_GM__c, Red_in_GS__c, Product_Summary__r.Name FROM PL_PS__c];
        plView.bind_ProductList();
        //Test.stopTest();
        
    }
  
}