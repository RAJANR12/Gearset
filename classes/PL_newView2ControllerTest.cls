@isTest
public with sharing class PL_newView2ControllerTest {
   
    private static L2I_P_L_Approval__c plApproval;
    private static void setupHeader(){

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
        insert lstPlmd;

    }
    private static void setupTestData()
    {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        List<PL_MD__c> lstPlmd = new List<PL_MD__c>();
        
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

        PL_MD__c plmd = new PL_MD__c();
        plmd.Name='IFE Hardware';
        plmd.Pillar__c='IFE';
        plmd.Product_Group__c='IFE Hardware';
        plmd.Sort_Order__c=1;
        plmd.Sort_Order__c=90;
        plmd.MD_Type__c ='Product';
        
        PL_Product_Group__c pg = new PL_Product_Group__c();
        pg.PL_MD__c = plmd.id;
        pg.Start_Date__c = system.today().addDays(-1);
        //pg.is_Active__c=true;
        insert pg;       
        
        PL_MD__c PL_MD = new PL_MD__c();
        PL_MD.Name='Administration';
        PL_MD.Sort_Order__c=630;
        PL_MD.color__c='#8da2c1';
        PL_MD.Cost_Allocation__c	='ALLOCATION COST';
        PL_MD.Cost_Allocation_Item__c	='Administration';
        PL_MD.MD_Type__c ='Cost Allocation';
        PL_MD.L2I_Migration_External_Id__c	='CAL-AC-ADMIN';
        insert PL_MD;

        
        PL_CAL__c cal = new PL_CAL__c();
        cal.Percent__c= 10; 
        //cal.Cost_Allocation__c	='ALLOCATION COST';
        //cal.Cost_Allocation_Item__c	='Administration';
        cal.Allocation_Type__c	='% of NET SALES';
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
        PLA_Page_ShipsetList__c row1 = new PLA_Page_ShipsetList__c(name = 'Row 1', PL_Approval__c = plApproval.id, Sort_order__c=0 );
        PLA_Page_ShipsetList__c row2 = new PLA_Page_ShipsetList__c(name = 'Row 2', PL_Approval__c = plApproval.id, Sort_order__c= 2);
        PLA_Page_ShipsetList__c row3 = new PLA_Page_ShipsetList__c(name = 'Row 3', PL_Approval__c = plApproval.id, Sort_order__c= 50);
        shipset.add(row1);
        shipset.Add(row2);
        shipset.Add(row3);
        insert shipset; 
        PLA_Page_ProductServices_List__c  service = new PLA_Page_ProductServices_List__c (name ='Test 4',P_L_Approval__c = plApproval.id );
        insert service; 
        PLA_Page_ConsolidatedList__c consolidated = new PLA_Page_ConsolidatedList__c(name = 'Test1', 
                                                                                    P_L_Approval__c = plApproval.id,
                                                                                    isCol_Display__c = TRUE,
            Row_Color_Code__c = 'blue',
            Row_Span_Count__c = 1,
            IFE_Hardware0__c = '1',
            IFE_Services1__c = '2',
            IFE_SubTotal2__c = '3',
            IFC_Hardware3__c = '4',
            IFC_Services4__c = '5',
            IFC_SubTotal5__c = '6',
            DSS6__c = '7',
            PTS7__c = '8',
            Total_Program8__c= '100',
            Net_Sales9__c= '500',
            Vertical_Header_Color__c= 'blue',
            Group_NameList__c ='A,B,C');
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
        PL_newViewController plview = new PL_newViewController(standardController);
        plview.bindConsolidatedHeader();
     
        Test.stopTest();
       
    }
    @isTest
    private static void TestDataOnLoadWithHeader() 
    {
        Test.startTest();
 
        setupTestData();
        ApexPages.StandardController standardController = new ApexPages.StandardController(plApproval); 
        PL_newViewController plview = new PL_newViewController(standardController);
        setupHeader();
        plview.bindConsolidatedHeader();
     
        Test.stopTest();
       
    }
}