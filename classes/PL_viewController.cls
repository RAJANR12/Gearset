public class PL_viewController{
    
    public L2I_P_L_Approval__c Plapproval        {get;set;}
    public String VerticalHeadercolor {get;set;}
    public List<L2I_P_L_Sales_Opportunity__c> oppslst {get;set;}
    public String todaydate{get;set;}
    public Set<Id> QuoteIds {get;set;}
    public Decimal HardwareTotalSC {get;set;}
    public Decimal AveHardrateTotalSC {get;set;}
    public Decimal HardwareOptyCount {get;set;}
    public Decimal VariableRiskContingency {get;set;}
    public Decimal OnePAHeadQuarter {get;set;}
    public Decimal SGNAAdminFee {get;set;}

    public List<String> headerName {get;set;}
    public List<String> headerColor {get;set;}
    public List<Decimal> headerNetSales {get;set;}
    public List<Decimal> headerCosts {get;set;}
    public Map<String, Integer> consHeadMap = new Map<String, Integer> ();

    public Map<string,Integer>RowSpanMap{get;set;}

    public List<WrapperProduct> ProductList {get;set;}
    public List<WrapperProduct> ProductList0 {get;set;}
    public List<WrapperProduct> ProductList2 {get;set;}

    public List<WrapperConsolidate>  WrapperConsolidateList{get;set;}
    public Map<String, WrapperConsolidate> wrpConsMap{get;set;}

    public List<WrapperProductServices>  WrapperProductServicesList{get;set;}

    public Decimal prgGrossTotal {get;set;}
    public Decimal prgNetSalesTotal {get;set;}
    public Decimal prgProfitBeforeTax {get;set;}
    public Decimal prgPBTPercent {get;set;}
    public Decimal prgPATPercent {get;set;}
    public Decimal corpTaxRate {get;set;}


    public List <PL_MD__c> psPLMDList {get;set;}
    public List <PL_PS__c> psQPSList {get;set;}

    public List <PLA_Page_ProductServices_List__c> storedProductServicesList {get;set;}
    public Boolean isInsert {get;set;}
    public Boolean isInsertConsolidated {get;set;}
    public Boolean isInsertProduct {get;set;}
    public Boolean isInsertOpportunity {get;set;}
  

    public Map<string, PLA_Page_ProductServices_List__c> ProductServicesMap = new Map<string, PLA_Page_ProductServices_List__c>();
    public List<PLA_Page_ProductServices_List__c> updateProductServicesList {get;set;}

    public Map<string, PLA_Page_ConsolidatedList__c> ProductConsolidatedMap = new Map<string, PLA_Page_ConsolidatedList__c>();
    public List<PLA_Page_ConsolidatedList__c> ProductConsolidatedList {get;set;}
    public List<PLA_Page_ConsolidatedList__c> updateProductConsolidatedList {get;set;}

    public Map<string, PLA_Page_ShipsetList__c > ProductMap = new Map<string, PLA_Page_ShipsetList__c >();
    public List<PLA_Page_ShipsetList__c > ProductShipsetList {get;set;}
    public List<PLA_Page_ShipsetList__c > updateProductList {get;set;}
    public List<PLA_Page_ShipsetList__c > ProductShipsetList0 {get;set;}

    public Map<string, PLA_Page_Opportunity_List__c> OpportunityListMap = new Map<string, PLA_Page_Opportunity_List__c>();
    public List<PLA_Page_Opportunity_List__c> OpportunityList {get;set;}
    public List<PLA_Page_Opportunity_List__c> insertOpportunityList {get;set;}
    public List<PLA_Page_Header__c> ApprovalHeaderList {get;set;}
    
    public String fileName { get; set; }

    public PL_viewController(ApexPages.StandardController controller) {
        HardwareTotalSC = 0;
        AveHardrateTotalSC = 0;
        HardwareOptyCount = 0;
        VariableRiskContingency = 0;
        OnePAHeadQuarter = 0;
        SGNAAdminFee = 0;
        RowSpanMap = new Map<string,Integer>();
        Datetime todaydate2 = System.today();
        String Currentdate = todaydate2.format('MM/dd/yyyy');
        todaydate = Currentdate;
        ProductList = new List<WrapperProduct>();//OptionalAircraftQuantity=0;
        ProductList0 = new List<WrapperProduct>();
        ProductList2 = new List<WrapperProduct>();
        QuoteIds = new Set<Id>();
        WrapperConsolidateList = new List<WrapperConsolidate>();
        wrpConsMap = new Map<String, WrapperConsolidate>();
        WrapperProductServicesList = new List<WrapperProductServices>();
        prgGrossTotal = 0;
        prgNetSalesTotal = 0;
        prgPBTPercent = 0;
        prgPATPercent = 0;
        prgProfitBeforeTax = 0;
        corpTaxRate = L2I_GeneralSettings.getCorporateTaxRate();

        psPLMDList = PL_Utils.getProductSummaryMasterDataList();
       
        
        //New Objects added to store calculated data
        storedProductServicesList = new List<PLA_Page_ProductServices_List__c>();
        updateProductServicesList = new List<PLA_Page_ProductServices_List__c>();
        ProductServicesMap = new Map<string, PLA_Page_ProductServices_List__c>();

        ProductConsolidatedMap = new Map<string, PLA_Page_ConsolidatedList__c>();
        ProductConsolidatedList = new List<PLA_Page_ConsolidatedList__c>();
        updateProductConsolidatedList = new List<PLA_Page_ConsolidatedList__c>();

        ProductMap = new Map<string, PLA_Page_ShipsetList__c>();
        ProductShipsetList = new List<PLA_Page_ShipsetList__c>();
        updateProductList = new List<PLA_Page_ShipsetList__c>();
        ProductShipsetList0 = new List<PLA_Page_ShipsetList__c>();

        OpportunityListMap = new Map<string, PLA_Page_Opportunity_List__c>();
        OpportunityList = new List<PLA_Page_Opportunity_List__c>();
        insertOpportunityList = new List<PLA_Page_Opportunity_List__c>(); 
        ApprovalHeaderList = new List<PLA_Page_Header__c>();
        
        //List<PL_MD__c> plMDList = [SELECT id, Name, Product_Group__c, Sort_Order__c, L2I_Migration_External_Id__c, Color__c
       // FROM PL_MD__C Where MD_Type__c = 'Product Summary' order by Sort_Order__c];
        
        /* Fetching Value For PL-Approval Record based on Current rec Id*/
        system.debug('Test## controller.getId()=========='+controller.getId());
        Plapproval = [ SELECT Id,Name,L2I_Approval_Deal_Opportunity__r.L2I_Oppt_Region__c,
                      L2I_Approval_Deal_Opportunity__r.L2I_Opportunity_Number__c,Snapshot_Version__c,  
                      ApprovalStatus__c,L2I_Revision_Status__c,Notes__c,Last_Approved_Date__c,
                      L2I_Approval_Deal_Opportunity__r.Account.Name,P_L_Version__c,
                      L2I_Approval_Deal_Opportunity__r.Account.L2I_Payment_Term__c, L2I_Financials_Included__c,
                      L2I_Approval_Deal_Opportunity__r.Account.Owner.Name, Has_Stored_Calculations__c,
                      PL_T_GR__c, PL_T_NR__c, PL_T_CD__c, PL_T_GM__c, PL_T_GM_P__c, PL_T_MP__c,
                      PL_T_MP_P__c, PL_T_CM__c, PL_T_CM_P__c, PL_T_PTP__c, PL_T_PTP_P__c, PL_Total_Cost__c,
                        PL_IFE_GR__c, PL_IFE_NR__c, PL_IFE_CD__c, PL_IFE_GM__c, PL_IFE_GM_P__c, PL_IFE_MP__c,
                        PL_IFE_MP_P__c, PL_IFE_CM__c, PL_IFE_CM_P__c, PL_IFE_PTP__c, PL_IFE_PTP_P__c, PL_IFE_Cost__c,
                        PL_IFC_GR__c, PL_IFC_NR__c, PL_IFC_CD__c, PL_IFC_GM__c, PL_IFC_GM_P__c, PL_IFC_MP__c,
                        PL_IFC_MP_P__c, PL_IFC_CM__c, PL_IFC_CM_P__c, PL_IFC_PTP__c, PL_IFC_PTP_P__c, PL_IFC_Cost__c,
                        PL_DSS_GR__c, PL_DSS_NR__c, PL_DSS_CD__c, PL_DSS_GM__c, PL_DSS_GM_P__c, PL_DSS_MP__c,
                        PL_DSS_MP_P__c, PL_DSS_CM__c, PL_DSS_CM_P__c, PL_DSS_PTP__c, PL_DSS_PTP_P__c, PL_DSS_Cost__c,
                        PL_PTS_GR__c, PL_PTS_NR__c, PL_PTS_CD__c, PL_PTS_GM__c, PL_PTS_GM_P__c, PL_PTS_MP__c,
                        PL_PTS_MP_P__c, PL_PTS_CM__c, PL_PTS_CM_P__c, PL_PTS_PTP__c, PL_PTS_PTP_P__c, PL_PTS_Cost__c,
                        P_L_Variance__c, //Added by Jan Geronga for W-008314
                        P_L_VarianceRecord__c, //Added by Jan Geronga for W-003998
                        PL_PTS_Fixed_Cost__c //Added by Alvin for W-004366
                      FROM L2I_P_L_Approval__c WHERE Id =: controller.getId() limit 1];

        this.fileName = Plapproval.Name;
        
        ApprovalHeaderList = [Select id, name, PL_Version__c, Ave_Hard_Rate_TotalSC__c, Program_PBT_Percent__c, Payment_Terms__c, 
                        Program_PAT_Percent__c, Approval_status__c, Account_Name__c,Owner_Name__c, Revision_status__c, Notes__c, 
                        Last_Approved_Date__c, PL_Approval__c 
                        from PLA_Page_Header__c 
                        WHERE Pl_Approval__c =: controller.getId()  ];
        

        If(ApprovalHeaderList.size()== 0){
                System.debug('If size == 0');
                PLA_Page_Header__c header = new PLA_Page_Header__c();
                header.Name = Plapproval.name;
                header.PL_Version__c = plApproval.P_L_Version__c;    
                header.Payment_Terms__c =Plapproval.L2I_Approval_Deal_Opportunity__r.Account.L2I_Payment_Term__c;
                header.Approval_status__c = PlApproval.ApprovalStatus__c;
                header.Account_Name__c = Plapproval.L2I_Approval_Deal_Opportunity__r.Account.Name;
                header.Owner_Name__c = Plapproval.L2I_Approval_Deal_Opportunity__r.Account.Owner.Name;
                header.Revision_status__c =Plapproval.L2I_Revision_Status__c;
                header.Notes__c = Plapproval.notes__c;
                header.Last_Approved_Date__c = Plapproval.Last_Approved_Date__c?.Date();
                header.PL_Approval__c = controller.getId() ;
                ApprovalHeaderList.add(header);

        } else if (ApprovalHeaderList.size()>1) {
                ApprovalheaderList[0].Name = Plapproval.name;
                ApprovalheaderList[0].PL_Version__c = plApproval.P_L_Version__c;          
                ApprovalheaderList[0].Payment_Terms__c =Plapproval.L2I_Approval_Deal_Opportunity__r.Account.L2I_Payment_Term__c;           
                ApprovalheaderList[0].Approval_status__c = PlApproval.ApprovalStatus__c;
                ApprovalheaderList[0].Account_Name__c = Plapproval.L2I_Approval_Deal_Opportunity__r.Account.Name;
                ApprovalheaderList[0].Owner_Name__c = Plapproval.L2I_Approval_Deal_Opportunity__r.Account.Owner.Name;
                ApprovalheaderList[0].Revision_status__c =Plapproval.L2I_Revision_Status__c;
                ApprovalheaderList[0].Notes__c = Plapproval.notes__c;
                ApprovalheaderList[0].Last_Approved_Date__c = Plapproval.Last_Approved_Date__c?.Date();
                System.debug('*** Updated new Header record');
            }
            

        // Set up data from stored objects 
        storedProductServicesList = [Select id, Row_Color_Code__c,Sort_Order__c,Name,Gross_Sales__c,Percent_Discount__c,Other_Credits_Amount__c,Reduction_Gross_Sales__c,
                        Net_Sales_Customer__c,Total_Cost__c, Gross_Margin__c,Gross_Margin_Percentage__c,P_L_Approval__c 
                        from PLA_Page_ProductServices_List__c  
                        where P_L_Approval__c = : Plapproval.id 
                        order by Sort_Order__c];   

        ProductConsolidatedList = [Select id, Row_Color_Code__c, Row_Span_Count__c, isCol_Display__c, Name, Group_NameList__c, IFE_Hardware0__c,IFE_Services1__c, 
                        IFE_SubTotal2__c,IFC_Hardware3__c, IFC_Services4__c,IFC_SubTotal5__c,DSS6__c,PTS7__c,Total_Program8__c,Net_Sales9__c,Sort_Order__c, Vertical_Header_Color__c, 
                        P_L_Approval__c from PLA_Page_ConsolidatedList__c 
                        where P_L_Approval__c = : Plapproval.id  
                        order by Sort_Order__c];   

         ProductShipsetList = [Select Id, Name, Gross_Sales0__c, Shipset_Discount1__c,Other_Credits2__c, Total_Reduction3__c, 
                        Net_Sales4__c,Cost_Sales_per_Shipset5__c, Gross_Margin6__c, GM_Percentage7__c, Category_Net_Price8__c, Cost_per_Seat9__c, Sort_Order__c, 
                        Row_Color_Code__c, PL_Approval__c from PLA_Page_ShipsetList__c 
                        where PL_Approval__c = : Plapproval.id 
                        And Sort_Order__c > 0  
                        order by Sort_Order__c];

        ProductShipsetList0 = [Select Id, Name, Gross_Sales0__c, Shipset_Discount1__c,Other_Credits2__c, Total_Reduction3__c, 
                            Net_Sales4__c,Cost_Sales_per_Shipset5__c, Gross_Margin6__c, GM_Percentage7__c, Category_Net_Price8__c, Cost_per_Seat9__c, Sort_Order__c, 
                            Row_Color_Code__c, PL_Approval__c from PLA_Page_ShipsetList__c 
                            where PL_Approval__c = : Plapproval.id  
                            And Sort_Order__c = 0 
                            order by Sort_Order__c];
        OpportunityList = [Select id,Name, Aircraft_Type__c,Direct_Buy_Quantity__c,Leased_Aircraft_Quantity__c,Optional_Aircraft_Quantity__c,
                            Production_Retrofit__c,Delivery_Start_Date__c, Delivery_End_Date__c, Seats_per_Aircraft__c,
                            Initial_Proposal_Date__c,Warranty_Duration__c,PL_Approval__c , Program_Number__c, Parts_List_Revision__c, Opportunity_Number__c                        
                            from PLA_Page_Opportunity_List__c
                            where pl_approval__c = :PlApproval.id ];
        System.debug('*** Finished Getting data');

        If(storedProductServicesList.size() >0 ){
            for(PLA_Page_ProductServices_List__c  p : storedProductServicesList ){
                ProductServicesMap.put(p.name, p);
                isInsert = False ;
                // START W-004435 - Update tech pub/training row color to yellow
                if((p.Name.startsWithIgnoreCase('Technical Publication') || p.Name.startsWithIgnoreCase('Training'))
                    && p.Row_Color_Code__c != null && !p.Row_Color_Code__c?.contains('#FFFF00')){
                    p.Row_Color_Code__c = 'background-color: #FFFF00';
                } // END W-004435
            }      
        }else {
            isInsert = True;}

        If(ProductConsolidatedList.size() >0 ){
            isInsertConsolidated = False;
            for(PLA_Page_ConsolidatedList__c   p : ProductConsolidatedList){
                ProductConsolidatedMap.put(p.name, p);      
            } 
        } else {
            isInsertConsolidated = True;
        }

        If(ProductShipsetList.size() >0 ){
            isInsertProduct = False;
            for(PLA_Page_ShipsetList__c   p : ProductShipsetList){
                ProductMap.put(p.name, p);      
            } 
        } else {
            isInsertProduct = True;
        }
        If(ProductShipsetList0.size() >0 ){
            for(PLA_Page_ShipsetList__c   p : ProductShipsetList0){
                ProductMap.put(p.name, p);      
            } 
        } 
        If(OpportunityList.size() <1 ){
            isInsertOpportunity = true;
        } 
        System.debug('*** Finished setting');
        
        
        List<L2I_P_L_Sales_Opportunity__c> l2ISalesOpportunityLst= new List<L2I_P_L_Sales_Opportunity__c>();
        List<L2I_P_L_Sales_Opportunity__c> l2ISalesOpportunityLst2= new List<L2I_P_L_Sales_Opportunity__c>();
        // Get the PL Sales Opportunities
        l2ISalesOpportunityLst=[Select id, name, L2I_Sales_Opportunity__c, L2I_Sales_Opportunity__r.name, L2I_Sales_Opportunity__r.L2I_AircraftType__c,
                                L2I_Sales_Opportunity__r.L2I_Fit_Type__c,L2I_Sales_Opportunity__r.L2I_Delivery_End_Date__c, 
                                L2I_Sales_Opportunity__r.L2I_First_Delivery_Date__c, L2I_Sales_Opportunity__r.L2I_Aircraft_Quantity__c,
                                L2I_Sales_Opportunity__r.L2I_Leased_Aircraft_Quantity__c, L2I_Sales_Opportunity__r.L2I_Firm_Buy_AC_Qty__c,
                                L2I_Sales_Opportunity__r.L2I_Warranty__c, L2I_Sales_Opportunity__r.L2I_Program_Num__c, 
                                L2I_Sales_Opportunity__r.SBQQ__PrimaryQuote__r.L2I_Optional_Aircraft_Quantity__c,
                                L2I_Sales_Opportunity__r.SBQQ__PrimaryQuote__r.L2I_Total_Seat_Count__c, L2I_Sales_Opportunity__r.L2I_Product_Category__c,
                                L2I_Sales_Opportunity__r.SBQQ__PrimaryQuote__r.L2I_Proposal_Due_Date__c, Opportunity_Number__c,
                                L2I_Sales_Opportunity__r.SBQQ__PrimaryQuote__c, L2I_Sales_Opportunity__r.L2I_Program_Num__r.name, L2I_Sales_Opportunity__r.PT_Part_List_Name_Rev__c,
                                Variable_Risk_Contingency__c, One_PA_Headquarter_Fee__c, SGNA_Admin_Fee__c, PL_Quote_Lookup__c,PL_Quote_Lookup__r.Name,
                                PL_Quote_Lookup__r.L2I_Optional_Aircraft_Quantity__c,
                                PL_Quote_Lookup__r.L2I_Total_Seat_Count__c,
                                PL_Quote_Lookup__r.L2I_Proposal_Due_Date__c
                                FROM L2I_P_L_Sales_Opportunity__c
                                where L2I_P_L_Approval__c =: controller.getId()];
        
        //system.debug('l2ISalesOpportunityLst' + l2ISalesOpportunityLst);
        //system.debug('l2ISalesOpportunityLstPlaceee' + l2ISalesOpportunityLst[0].L2I_Sales_Opportunity__r.SBQQ__PrimaryQuote__c);
        if(l2ISalesOpportunityLst!=null && l2ISalesOpportunityLst.size()>0) {

            // for(opportunity oops : l2ISalesOpportunityLst){
            //        oops.L2I_First_Delivery_Date__c = oops.L2I_First_Delivery_Date__c;
            //       l2ISalesOpportunityLst2.add(oops);
            //     }
            // Calculate hardware Opportunity Count and Hardware Total Seat Count from Opportunity Seat Count
            oppslst = l2ISalesOpportunityLst;
            For (L2I_P_L_Sales_Opportunity__c plopp : oppslst) {
                IF (plopp.L2I_Sales_Opportunity__r.SBQQ__PrimaryQuote__c != NULL) {
                    //QuoteIds.add(plopp.L2I_Sales_Opportunity__r.SBQQ__PrimaryQuote__c);
                    QuoteIds.add(plopp.PL_Quote_Lookup__c);
                    if(plopp.L2I_Sales_Opportunity__r.L2I_Product_Category__c =='PTS'){
                        if(plopp.Variable_Risk_Contingency__c != null){ //W-004407
                            VariableRiskContingency = plopp.Variable_Risk_Contingency__c ;
                        }
                        if(plopp.One_PA_Headquarter_Fee__c != null){ //W-004407
                            OnePAHeadQuarter = plopp.One_PA_Headquarter_Fee__c ;
                        }
                        if(plopp.SGNA_Admin_Fee__c != null){ //W-004407
                            SGNAAdminFee = plopp.SGNA_Admin_Fee__c ;
                        }
                    }
                    if (plopp.L2I_Sales_Opportunity__r.L2I_Product_Category__c == 'IFEC') {
                        HardwareOptyCount += 1;
                        if (plopp.PL_Quote_Lookup__r.L2I_Total_Seat_Count__c != null) {
                            //HardwareTotalSC += plopp.L2I_Sales_Opportunity__r.SBQQ__PrimaryQuote__r.L2I_Total_Seat_Count__c;
                            HardwareTotalSC += plopp.PL_Quote_Lookup__r.L2I_Total_Seat_Count__c;
                        }
                    }
                }
            }
            // Store the data
            system.debug('Store Opportunity Data');
            If(oppslst.size()>0){
                for(L2I_P_L_Sales_Opportunity__c plopp : oppslst){
                    PLA_Page_Opportunity_List__c p = new PLA_Page_Opportunity_List__c();
                    decimal quantity = 0;
                    p.Aircraft_Type__c = plopp.L2I_Sales_Opportunity__r.L2I_AircraftType__c;
                    quantity = plopp.L2I_Sales_Opportunity__r.L2I_Firm_Buy_AC_Qty__c;
                    p.Direct_Buy_Quantity__c = quantity?.toPlainString();
                    quantity = plopp.L2I_Sales_Opportunity__r.L2I_Leased_Aircraft_Quantity__c;
                    p.Leased_Aircraft_Quantity__c = quantity?.toPlainString();
                    //quantity = plopp.L2I_Sales_Opportunity__r.SBQQ__PrimaryQuote__r.L2I_Optional_Aircraft_Quantity__c;
                    quantity = plopp.PL_Quote_Lookup__r.L2I_Optional_Aircraft_Quantity__c;
                    p.Optional_Aircraft_Quantity__c = quantity?.toPlainString();
                    p.Production_Retrofit__c = plopp.L2I_Sales_Opportunity__r.L2I_Fit_Type__c;
                    p.Delivery_Start_Date__c = plopp.L2I_Sales_Opportunity__r.L2I_First_Delivery_Date__c; 
                    p.Delivery_End_Date__c = plopp.L2I_Sales_Opportunity__r.L2I_Delivery_End_Date__c;
                    //quantity = plopp.L2I_Sales_Opportunity__r.SBQQ__PrimaryQuote__r.L2I_Total_Seat_Count__c;
                    quantity = plopp.PL_Quote_Lookup__r.L2I_Total_Seat_Count__c;
                    p.Seats_per_Aircraft__c = quantity?.toPlainString();
                    //p.Initial_Proposal_Date__c = plopp.L2I_Sales_Opportunity__r.SBQQ__PrimaryQuote__r.L2I_Proposal_Due_Date__c; 
                    p.Initial_Proposal_Date__c = plopp.PL_Quote_Lookup__r.L2I_Proposal_Due_Date__c; 
                    p.Warranty_Duration__c = plopp.L2I_Sales_Opportunity__r.L2I_Warranty__c; 
                    p.Program_Number__c = plopp.L2I_Sales_Opportunity__r.L2I_Program_Num__r.name;
                    system.debug('Program Number ' + plopp.L2I_Sales_Opportunity__r.L2I_Program_Num__r.name);
                    p.Parts_List_Revision__c =plopp.L2I_Sales_Opportunity__r.PT_Part_List_Name_Rev__c;
                    p.Opportunity_Number__c = plopp.Opportunity_Number__c;
                    p.PL_Approval__c =  controller.getId(); 
                    p.PL_Sales_Opportunity__c = plopp.id;
                    p.Opportunity__c =plopp.L2I_Sales_Opportunity__c;
                    p.PL_Quote__c = plopp.PL_Quote_Lookup__c;
                    p.name = plopp.L2I_Sales_Opportunity__r.name;
                    insertOpportunityList.add(p);                  
                } 
            }
            //Calulate Avg Seat Count
            if (HardwareOptyCount > 0) {
                AveHardrateTotalSC = HardwareTotalSC / HardwareOptyCount;
                AveHardrateTotalSC = AveHardrateTotalSC.setScale(2);
                If(ApprovalHeaderList.size() >0){
                    ApprovalHeaderList[0].Ave_Hard_Rate_TotalSC__c = AveHardrateTotalSC?.toPlainString();
                }
            }

            //SYSTEM.debug('QUOTE LIST: ' + QuoteIds);
            //SYSTEM.debug('HARDWARE OPTY COUNT: ' + HardwareOptyCount);
            //SYSTEM.debug('HardwareTotalSC' + HardwareTotalSC);
            //SYSTEM.debug('AveHardrateTotalSC' + AveHardrateTotalSC);

            psQPSList = PL_Utils.getQuoteProductSummaryList(QuoteIds);

            bind_ProductList();

            bindConsolidatedHeader();

            bind_WrapperConsolidateList();

            bind_WrapperProductServices();
           
        }
    }
    public PageReference OpenView(){
        // For opening the View Page /apex/PL_View?id={!PLApproval__c.Approval.Id}
       pageReference pg = new pageReference('/apex/PL_newView?Id=' + PlApproval.id);
       return pg.setRedirect(true);
   }
   public PageReference GenerateExcel(){
    return new PageReference('/apex/PL_CalculateExcel?Id=' + PlApproval.id);
    }
    public void updatePLApproval(){
        system.debug('*** Called Update ');
        // Update consolidated Fields section total fields
        // update  net revenue
        system.debug('Empty Wrapper ' + wrpConsMap.isEmpty());
        If(!wrpConsMap.isEmpty()){
        Plapproval.PL_T_NR__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-SALES-TOT').lstValuesDec, 8);
       
        // update  gross revenue
        Plapproval.PL_T_GR__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-SALES-GROSS').lstValuesDec, 8);
        // update Credits and Discounts
        Plapproval.PL_T_CD__c = Plapproval.PL_T_GR__c - Plapproval.PL_T_NR__c;
        // update total cost
        Plapproval.PL_Total_Cost__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-TOT').lstValuesDec, 8);

        // update  Gross Margin
        Plapproval.PL_T_GM__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-GM').lstValuesDec, 8);

        // update  Marignal Profit
        Plapproval.PL_T_MP__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-VC-MP').lstValuesDec, 8);
        // update  Contribution Margin
        Plapproval.PL_T_CM__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-DF-DCM').lstValuesDec, 8);
        // update  Contribution Margin
        Plapproval.PL_T_PTP__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-AC-PBT').lstValuesDec, 8);
        // update  Gross Margin %
        Plapproval.PL_T_GM_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-GM-PCT').lstValuesDec, 8);
        // update  Marignal Profit %
        Plapproval.PL_T_MP_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-VC-MP-PCT').lstValuesDec, 8);
        // update  Contribution Margin %
        Plapproval.PL_T_CM_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-DF-CM-PCT').lstValuesDec, 8);
        // update  Contribution Margin %
        Plapproval.PL_T_PTP_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-AC-PTP-PCT').lstValuesDec, 8);


        // Update IFE Fields section fields
        // update  net revenue
        Plapproval.PL_IFE_NR__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-SALES-TOT').lstValuesDec, 2);
        // update  gross revenue
        Plapproval.PL_IFE_GR__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-SALES-GROSS').lstValuesDec, 2);
        // Update Financials Included
        Plapproval.L2I_Financials_Included__c ='';
        If (Plapproval.PL_IFE_GR__c > 0){Plapproval.L2I_Financials_Included__c = 'IFEC;'; }
        // update total cost
        Plapproval.PL_IFE_Cost__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-TOT').lstValuesDec, 2);
        // update Credits and Discounts
        Plapproval.PL_IFE_CD__c = Plapproval.PL_IFE_GR__c - Plapproval.PL_IFE_NR__c;
        // update  Gross Margin
        Plapproval.PL_IFE_GM__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-GM').lstValuesDec, 2);
        // update  Marignal Profit
        Plapproval.PL_IFE_MP__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-VC-MP').lstValuesDec, 2);
        // update  Contribution Margin
        Plapproval.PL_IFE_CM__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-DF-DCM').lstValuesDec, 2);
        // update  Contribution Margin
        Plapproval.PL_IFE_PTP__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-AC-PBT').lstValuesDec, 2);
        // update  Gross Margin %
        Plapproval.PL_IFE_GM_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-GM-PCT').lstValuesDec, 2);
        // update  Marignal Profit %
        Plapproval.PL_IFE_MP_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-VC-MP-PCT').lstValuesDec, 2);
        // update  Contribution Margin %
        Plapproval.PL_IFE_CM_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-DF-CM-PCT').lstValuesDec, 2);
        // update  Contribution Margin %
        Plapproval.PL_IFE_PTP_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-AC-PTP-PCT').lstValuesDec, 2);


        // Update IFC Fields section fields
        // update  net revenue
        Plapproval.PL_IFC_NR__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-SALES-TOT').lstValuesDec, 5);
        // update  gross revenue
        Plapproval.PL_IFC_GR__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-SALES-GROSS').lstValuesDec, 5);
        //Update Finacials Included
        If (Plapproval.PL_IFC_GR__c > 0){Plapproval.L2I_Financials_Included__c =  Plapproval.L2I_Financials_Included__c + 'IFEC;'; }
        // update Credits and Discounts
        Plapproval.PL_IFC_CD__c = Plapproval.PL_IFC_GR__c - Plapproval.PL_IFC_NR__c;
        // update total cost
        Plapproval.PL_IFC_Cost__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-TOT').lstValuesDec, 5);
        // update  Gross Margin
        Plapproval.PL_IFC_GM__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-GM').lstValuesDec, 5);
        // update  Marignal Profit
        Plapproval.PL_IFC_MP__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-VC-MP').lstValuesDec, 5);
        // update  Contribution Margin
        Plapproval.PL_IFC_CM__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-DF-DCM').lstValuesDec, 5);
        // update  Contribution Margin
        Plapproval.PL_IFC_PTP__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-AC-PBT').lstValuesDec, 5);
        // update  Gross Margin %
        Plapproval.PL_IFC_GM_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-GM-PCT').lstValuesDec, 5);
        // update  Marignal Profit %
        Plapproval.PL_IFC_MP_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-VC-MP-PCT').lstValuesDec, 5);
        // update  Contribution Margin %
        Plapproval.PL_IFC_CM_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-DF-CM-PCT').lstValuesDec, 5);
        // update  Contribution Margin %
        Plapproval.PL_IFC_PTP_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-AC-PTP-PCT').lstValuesDec, 5);


        // Update DSS Fields section fields
        // update  net revenue
        Plapproval.PL_DSS_NR__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-SALES-TOT').lstValuesDec, 6);
        // update  gross revenue
        Plapproval.PL_DSS_GR__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-SALES-GROSS').lstValuesDec, 6);
        //Update Financials Included
        If (Plapproval.PL_DSS_GR__c > 0){Plapproval.L2I_Financials_Included__c =  Plapproval.L2I_Financials_Included__c + 'DSS;'; }
        // update total cost
        Plapproval.PL_DSS_Cost__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-TOT').lstValuesDec, 6);
        // update Credits and Discounts
        Plapproval.PL_DSS_CD__c = Plapproval.PL_DSS_GR__c - Plapproval.PL_DSS_NR__c;
        // update  Gross Margin
        Plapproval.PL_DSS_GM__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-GM').lstValuesDec, 6);
        // update  Marignal Profit
        Plapproval.PL_DSS_MP__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-VC-MP').lstValuesDec, 6);
        // update  Contribution Margin
        Plapproval.PL_DSS_CM__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-DF-DCM').lstValuesDec, 6);
        // update  Contribution Margin
        Plapproval.PL_DSS_PTP__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-AC-PBT').lstValuesDec, 6);
        // update  Gross Margin %
        Plapproval.PL_DSS_GM_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-GM-PCT').lstValuesDec, 6);
        // update  Marignal Profit %
        Plapproval.PL_DSS_MP_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-VC-MP-PCT').lstValuesDec, 6);
        // update  Contribution Margin %
        Plapproval.PL_DSS_CM_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-DF-CM-PCT').lstValuesDec, 6);
        // update  Contribution Margin %
        Plapproval.PL_DSS_PTP_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-AC-PTP-PCT').lstValuesDec, 6);


        // Update PTS Fields section fields
        // update  net revenue
        Plapproval.PL_PTS_NR__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-SALES-TOT').lstValuesDec, 7);
        // update  gross revenue
        Plapproval.PL_PTS_GR__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-SALES-GROSS').lstValuesDec, 7);
        //Update Finacials Included
        If (Plapproval.PL_PTS_GR__c > 0){Plapproval.L2I_Financials_Included__c =  Plapproval.L2I_Financials_Included__c + 'PTS;'; }
        // update total cost
        Plapproval.PL_PTS_Cost__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-TOT').lstValuesDec, 7);
        // update PTS Fixed Cost
        Plapproval.PL_PTS_Fixed_Cost__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-DF-TOT').lstValuesDec, 7);
        // update Credits and Discounts
        Plapproval.PL_PTS_CD__c = Plapproval.PL_PTS_GR__c - Plapproval.PL_PTS_NR__c;
        // update  Gross Margin
        Plapproval.PL_PTS_GM__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-GM').lstValuesDec, 7);
        // update  Marignal Profit
        Plapproval.PL_PTS_MP__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-VC-MP').lstValuesDec, 7);
        // update  Contribution Margin
        Plapproval.PL_PTS_CM__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-DF-DCM').lstValuesDec, 7);
        // update  Contribution Margin
        Plapproval.PL_PTS_PTP__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-AC-PBT').lstValuesDec, 7);
        // update  Gross Margin %
        Plapproval.PL_PTS_GM_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-COGS-GM-PCT').lstValuesDec, 7);
        // update  Marignal Profit %
        Plapproval.PL_PTS_MP_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-VC-MP-PCT').lstValuesDec, 7);
        // update  Contribution Margin %
        Plapproval.PL_PTS_CM_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-DF-CM-PCT').lstValuesDec, 7);
        // update  Contribution Margin %
        Plapproval.PL_PTS_PTP_P__c = PL_Utils.getDecimalValuefromList(wrpConsMap.get('CAL-AC-PTP-PCT').lstValuesDec, 7);
        }
        PlApproval.Has_Stored_Calculations__c = True;

        //Added by Jan Geronga for W-008314: Start
        for(L2I_P_L_Approval__c var : [SELECT Id, PL_T_PTP_P__c FROM L2I_P_L_Approval__c WHERE 
                                       L2I_Approval_Deal_Opportunity__c =: Plapproval.L2I_Approval_Deal_Opportunity__c AND ApprovalStatus__c = 'Approved'
                                       AND Last_Approved_Date__c != null ORDER BY Last_Approved_Date__c DESC LIMIT 1]){
                                           if(var.Id != Plapproval.Id){
                                               Plapproval.P_L_Variance__c = Plapproval.PL_T_PTP_P__c - var.PL_T_PTP_P__c;
                                               Plapproval.P_L_VarianceRecord__c = var.Id; //Added by Jan Geronga for W-003998
                                           }
                                       }
        //Added by Jan Geronga for W-008314: End

        update Plapproval;
        
        if(ApprovalHeaderList.size()>0){
            upsert ApprovalHeaderList;
        }
        
        System.debug('Opportunity Size ' +OpportunityList.size() );
        If(OpportunityList.size() >0  ){
            delete OpportunityList;
            OpportunityList.clear();
            
        }
      
        If(insertOpportunityList.size()> 0 ){
            upsert insertOpportunityList;
            isInsertOpportunity = false;
        }
        system.debug('*** Insert **** Size of Product List ' + storedProductServicesList.size() );
        if(storedProductServicesList.size()> 0 ){
           //Insert storedProductServicesList;
            //system.debug('*** Insert ****');
            upsert storedProductServicesList;
        } //else {

            //update updateProductServicesList;
        //}
        
        
        system.debug('*** Insert **** Size of Consolidated  List ' + ProductConsolidatedList.size() );
        If(isInsertConsolidated && ProductConsolidatedList.size() > 0){
            insert ProductConsolidatedList;
        }  else if(updateProductConsolidatedList.size()>0){
            update updateProductConsolidatedList;
        }  


        system.debug('*** Insert **** Size of ProductShipset List ' + ProductShipsetList.size() );
        system.debug('*** Insert **** Size of Product List ' + ProductList.size() );
       
        If(isInsertProduct && ProductList.size() > 0){
            system.debug('*** Insert **** Size of Product List ' + ProductShipsetList.size() );
           insert ProductShipsetList;
        }  else if(updateProductList.size()>0){
            update updateProductList;
        }   

    }


    // SHIPSET GRID DATA BINDING
    public void bind_ProductList(){

        if(psPLMDList.size()>0){
            string RowColorCode ='';
            //Decimal TotalSeatCount =0;
            Decimal GrossSalesPerSS_Total=0;
            Decimal DiscountToBeAppliedToShipset_Total=0;
            Decimal OtherShipsetLevelCredits_Total=0;
            Decimal TotalReductionOfGrossSales_Total=0;
            Decimal NetSalesPerShipsetToCustomer_Total=0;
            Decimal CostOfSalesPerShipset_Total=0;
            Decimal GrossMarginPerShipSet_Total=0;
            //Decimal GMPerShipSet_Total=0;
            Decimal ShipSetCategoryNetPricePerSeat_Total=0;
            Decimal ShipSetCostPerSeat_Total=0;

            Map<string, WrapperProduct> MapPLMD = new Map<string, WrapperProduct>();

            for(PL_MD__c pl : psPLMDList){
                if (pl.Sort_Order__c < 100) {
                    WrapperProduct wrpP = new WrapperProduct();
                    wrpP.ProductSummaryName = pl.name;
                    wrpP.RowColorCode = 'background-color: ' + pl.Color__c;
                    MapPLMD.put(pl.Name, wrpP);
                    ProductList.add(wrpP);
                    //system.debug('pl.Name===' + pl);
                }
            }
            system.debug('MapPLMD==='+MapPLMD);

            for(PL_PS__c ps: psQPSList){
                    if (ps.Sort_Order__c < 100 ) {
                    Decimal L2I_Aircraft_Quantity=0;
                    Decimal Credit=0;
                    //SYSTEM.debug('INSIDE 2ND FOR LOOP FOR SHIPSET DATA====' + ps);
                    if(ps.Quote__r.L2I_Aircraft_Quantity__c !=null && ps.Quote__r.L2I_Aircraft_Quantity__c > 0) {
                        L2I_Aircraft_Quantity = ps.Quote__r.L2I_Aircraft_Quantity__c;

                        if (ps.Gross_Sales__c != 0 && ps.Gross_Sales__c != null) {
                            MapPLMD.get(ps.Product_Summary__r.Name).GrossSalesPerSS += ps.Gross_Sales__c / L2I_Aircraft_Quantity;
                            GrossSalesPerSS_Total += ps.Gross_Sales__c / L2I_Aircraft_Quantity;
                        }
                        if (ps.Discount__c != 0 && ps.Discount__c != null) {
                            MapPLMD.get(ps.Product_Summary__r.Name).DiscountToBeAppliedToShipset += ps.Discount__c / L2I_Aircraft_Quantity;
                            DiscountToBeAppliedToShipset_Total += ps.Discount__c / L2I_Aircraft_Quantity;
                        }
                        if (ps.Credit__c != 0 && ps.Credit__c != null) {
                            MapPLMD.get(ps.Product_Summary__r.Name).OtherShipsetLevelCredits += ps.Credit__c / L2I_Aircraft_Quantity;
                            OtherShipsetLevelCredits_Total += ps.Credit__c / L2I_Aircraft_Quantity;
                        }
                        if (ps.ps_NS_to_Cust__c != 0 && ps.ps_NS_to_Cust__c != null) {
                            MapPLMD.get(ps.Product_Summary__r.Name).NetSalesPerShipsetToCustomer += ps.ps_NS_to_Cust__c / L2I_Aircraft_Quantity;
                            NetSalesPerShipsetToCustomer_Total += ps.ps_NS_to_Cust__c / L2I_Aircraft_Quantity;
                        }
                        if (ps.Cost__c != null && ps.Cost__c != 0) {
                            MapPLMD.get(ps.Product_Summary__r.Name).CostOfSalesPerShipset += ps.Cost__c / L2I_Aircraft_Quantity;
                            CostOfSalesPerShipset_Total += ps.Cost__c / L2I_Aircraft_Quantity;
                        }
                        if (ps.ps_GM__c != null && ps.ps_GM__c != 0) {
                            MapPLMD.get(ps.Product_Summary__r.Name).GrossMarginPerShipSet += ps.ps_GM__c / L2I_Aircraft_Quantity;
                            GrossMarginPerShipSet_Total += ps.ps_GM__c / L2I_Aircraft_Quantity;
                        }

                        if (ps.Red_in_GS__c != null && ps.Red_in_GS__c != 0) {
                            MapPLMD.get(ps.Product_Summary__r.Name).TotalReductionOfGrossSales += ps.Red_in_GS__c / L2I_Aircraft_Quantity;
                            TotalReductionOfGrossSales_Total += ps.Red_in_GS__c / L2I_Aircraft_Quantity;
                        }

                        //if (MapPLMD.get(ps.Product_Summary__r.Name).GrossSalesPerSS > 0 && MapPLMD.get(ps.Product_Summary__r.Name).GrossMarginPerShipSet > 0) {
                        //    MapPLMD.get(ps.Product_Summary__r.Name).GMPerShipSet = ((MapPLMD.get(ps.Product_Summary__r.Name).GrossMarginPerShipSet / MapPLMD.get(ps.Product_Summary__r.Name).GrossSalesPerSS) * 100).setScale(2);
                        //}
                        // //}
                        ////}
                        // once same product summary loop is finished calculate per ship set values.
                        if (AveHardrateTotalSC > 0) {
                            MapPLMD.get(ps.Product_Summary__r.Name).ShipSetCategoryNetPricePerSeat = (MapPLMD.get(ps.Product_Summary__r.Name).NetSalesPerShipsetToCustomer / AveHardrateTotalSC).setScale(2) ;
                        }
                        if (AveHardrateTotalSC > 0) {
                            MapPLMD.get(ps.Product_Summary__r.Name).ShipSetCostPerSeat = (MapPLMD.get(ps.Product_Summary__r.Name).CostOfSalesPerShipset / AveHardrateTotalSC).setScale(2);
                        }
                    }
                }
            }
            //For loop End calcuations for totals 'Net per shipset''
            RowColorCode = 'Pink';
            if (AveHardrateTotalSC > 0) {
                if (NetSalesPerShipsetToCustomer_Total != 0) {
                    ShipSetCategoryNetPricePerSeat_Total = (NetSalesPerShipsetToCustomer_Total / AveHardrateTotalSC).setScale(2);
                }
                if (CostOfSalesPerShipset_Total !=0 ) {
                    ShipSetCostPerSeat_Total = (CostOfSalesPerShipset_Total / AveHardrateTotalSC).setScale(2);
                }
            }
            //if (GrossSalesPerSS_Total != 0 && GrossMarginPerShipSet_Total != 0) {
            //    GMPerShipSet_Total = (GrossMarginPerShipSet_Total / GrossSalesPerSS_Total) * 100;
            //}
            ProductList.add(new WrapperProduct(RowColorCode,'Net Shipset Values',GrossSalesPerSS_Total.setScale(2),DiscountToBeAppliedToShipset_Total.setScale(2),
                    OtherShipsetLevelCredits_Total.setScale(2),TotalReductionOfGrossSales_Total.setScale(2),NetSalesPerShipsetToCustomer_Total.setScale(2),
                    CostOfSalesPerShipset_Total.setScale(2),GrossMarginPerShipSet_Total.setScale(2),
                    ShipSetCategoryNetPricePerSeat_Total.setScale(2),ShipSetCostPerSeat_Total.setScale(2)));
            
            //------calculation of "Per Seat Values"-------------------------------------------------------------
            Decimal GrossSalesPerSSTotal = 0;
            Decimal DiscountToBeAppliedToShipsetTotal= 0;
            Decimal OtherShipsetLevelCreditsTotal=0;
            Decimal TotalReductionOfGrossSalesTotal=0;
            Decimal NetSalesPerShipsetToCustomerTotal=0;
            Decimal CostOfSalesPerShipsetTotal=0;
            Decimal GrossMarginPerShipSetTotal=0;
            //Decimal GMPerShipSetTotal=0;
            Decimal ShipSetCategoryNetPricePerSeatTotal=0;
            Decimal ShipSetCostPerSeatTotal=0;
            if(AveHardrateTotalSC >0 ){
                RowColorCode = 'Gray';
                GrossSalesPerSSTotal = GrossSalesPerSS_Total/AveHardrateTotalSC;
                DiscountToBeAppliedToShipsetTotal= DiscountToBeAppliedToShipset_Total/AveHardrateTotalSC;
                OtherShipsetLevelCreditsTotal=OtherShipsetLevelCredits_Total/AveHardrateTotalSC;
                TotalReductionOfGrossSalesTotal=TotalReductionOfGrossSales_Total/AveHardrateTotalSC;
                NetSalesPerShipsetToCustomerTotal=NetSalesPerShipsetToCustomer_Total/AveHardrateTotalSC;
                CostOfSalesPerShipsetTotal=CostOfSalesPerShipset_Total/AveHardrateTotalSC;
                GrossMarginPerShipSetTotal=GrossMarginPerShipSet_Total/AveHardrateTotalSC;
                //if (GrossSalesPerSSTotal !=0 && GrossMarginPerShipSetTotal != 0){
                //    GMPerShipSetTotal=(GrossMarginPerShipSetTotal/GrossSalesPerSSTotal)*100;
                //}
                ShipSetCategoryNetPricePerSeatTotal = NetSalesPerShipsetToCustomerTotal;
                ShipSetCostPerSeatTotal=CostOfSalesPerShipsetTotal;
            }
            ProductList.add(new WrapperProduct(RowColorCode,'Per Seat Values',GrossSalesPerSSTotal.setScale(2),DiscountToBeAppliedToShipsetTotal,OtherShipsetLevelCreditsTotal,TotalReductionOfGrossSalesTotal,NetSalesPerShipsetToCustomerTotal.setScale(2),CostOfSalesPerShipsetTotal,GrossMarginPerShipSetTotal,ShipSetCategoryNetPricePerSeatTotal,ShipSetCostPerSeatTotal));

            for (WrapperProduct wrpf : ProductList) {
                wrpf.finalizeWrp();
            }
            // Store the data
            System.debug('*** Calculating Product List');
            If(isInsertProduct && ProductList.size()>0){
                integer sortorder = 1;
                for (wrapperproduct wrpf : ProductList){
                    PLA_Page_ShipsetList__c p = new PLA_Page_ShipsetList__c();
                    p.name = wrpf.ProductSummaryName;
                    p.Row_Color_Code__c = wrpf.RowColorCode;
                    p.Gross_Sales0__c = wrpf.StrValuesList[0];
                    p.Shipset_Discount1__c = wrpf.StrValuesList[1];
                    p.Other_Credits2__c = wrpf.StrValuesList[2];
                    p.Total_Reduction3__c= wrpf.StrValuesList[3];
                    p.Net_Sales4__c = wrpf.StrValuesList[4]; 
                    p.Cost_Sales_per_Shipset5__c =  wrpf.StrValuesList[5];
                    p.Gross_Margin6__c = wrpf.StrValuesList[6];
                    p.GM_Percentage7__c = wrpf.StrValuesList[7];
                    p.Category_Net_Price8__c = wrpf.StrValuesList[8];
                    p.Cost_per_Seat9__c = wrpf.StrValuesList[9];
                    p.sort_Order__c = sortorder;
                    p.PL_Approval__c = Plapproval.id;
                    ProductShipsetList.add(p);
                    sortorder++;
                }
            } else if (!isInsertProduct && ProductList.size()>0){
                integer sortorder = 1;
             for( wrapperproduct wrpf : ProductList){
                    system.debug('xxx Updating Shipset');
                   If (wrpf.ProductSummaryName != null){
                    PLA_Page_ShipsetList__c p = ProductMap.get(wrpf.ProductSummaryName);
                    p.Gross_Sales0__c = wrpf.StrValuesList[0];
                    p.name = wrpf.ProductSummaryName;
                    p.Shipset_Discount1__c = wrpf.StrValuesList[1];
                    p.Other_Credits2__c = wrpf.StrValuesList[2];
                    p.Total_Reduction3__c= wrpf.StrValuesList[3];
                    p.Net_Sales4__c = wrpf.StrValuesList[4]; 
                    p.Cost_Sales_per_Shipset5__c =  wrpf.StrValuesList[5];
                    p.Gross_Margin6__c = wrpf.StrValuesList[6];
                    p.GM_Percentage7__c = wrpf.StrValuesList[7];
                    p.Category_Net_Price8__c = wrpf.StrValuesList[8];
                    p.Cost_per_Seat9__c = wrpf.StrValuesList[9];
                    p.sort_Order__c = sortorder;
                    p.PL_Approval__c = Plapproval.id;
                    updateProductList.add(p);
                    sortorder++;
                   }
             }
             System.debug('*** Finished  Product List');
            }
            //-------Calculation of "Calculated %'s at Gross" Row---------------------------------------------
            DiscountToBeAppliedToShipsetTotal= 0;
            OtherShipsetLevelCreditsTotal=0;
            TotalReductionOfGrossSalesTotal=0;
            NetSalesPerShipsetToCustomerTotal=0;
            CostOfSalesPerShipsetTotal=0;
            GrossMarginPerShipSetTotal=0;
            //GMPerShipSetTotal=0;
            ShipSetCostPerSeatTotal=0;
            if(GrossSalesPerSS_Total != 0 ){

                DiscountToBeAppliedToShipsetTotal= (DiscountToBeAppliedToShipset_Total/GrossSalesPerSS_Total)*100;//GrossSalesPerSS_Total;
                OtherShipsetLevelCreditsTotal= (OtherShipsetLevelCredits_Total/GrossSalesPerSS_Total)*100;//GrossSalesPerSS_Total;
                TotalReductionOfGrossSalesTotal=(TotalReductionOfGrossSales_Total/GrossSalesPerSS_Total)*100;//GrossSalesPerSS_Total;
                NetSalesPerShipsetToCustomerTotal=(NetSalesPerShipsetToCustomer_Total/GrossSalesPerSS_Total)*100;//GrossSalesPerSS_Total;
                CostOfSalesPerShipsetTotal=(CostOfSalesPerShipset_Total/GrossSalesPerSS_Total)*100;//GrossSalesPerSS_Total;
                GrossMarginPerShipSetTotal=(GrossMarginPerShipSet_Total/GrossSalesPerSS_Total)*100;//GrossSalesPerSS_Total;
                //GMPerShipSetTotal=(GrossMarginPerShipSet_Total/GrossSalesPerSS_Total)*100;//GrossSalesPerSS_Total;
                ShipSetCategoryNetPricePerSeatTotal=(ShipSetCategoryNetPricePerSeat_Total/GrossSalesPerSS_Total)*100;//GrossSalesPerSS_Total;
                ShipSetCostPerSeatTotal=(ShipSetCostPerSeat_Total/GrossSalesPerSS_Total)*100;//GrossSalesPerSS_Total;
            }
            ProductList0.add(new WrapperProduct(RowColorCode,'Calculated Shipset Discounts',100,DiscountToBeAppliedToShipsetTotal,OtherShipsetLevelCreditsTotal,TotalReductionOfGrossSalesTotal,NetSalesPerShipsetToCustomerTotal.setScale(2),CostOfSalesPerShipsetTotal,GrossMarginPerShipSetTotal,ShipSetCategoryNetPricePerSeatTotal,ShipSetCostPerSeatTotal));
            ProductList2.add(new WrapperProduct(RowColorCode,'Calculated %s at Gross',100,DiscountToBeAppliedToShipsetTotal,OtherShipsetLevelCreditsTotal,TotalReductionOfGrossSalesTotal,NetSalesPerShipsetToCustomerTotal.setScale(2),CostOfSalesPerShipsetTotal,GrossMarginPerShipSetTotal,ShipSetCategoryNetPricePerSeatTotal,ShipSetCostPerSeatTotal));
           
            
            System.debug('*** Calculating Product List');
            If(ProductList0.size()>0 && isInsertProduct){
                PLA_Page_ShipsetList__c p = new PLA_Page_ShipsetList__c();
                wrapperproduct wrpf = ProductList0[0];
                p.name = wrpf.ProductSummaryName;
                p.Row_Color_Code__c = wrpf.RowColorCode;
                p.Gross_Sales0__c = wrpf.GrossSalesPerSS.toPlainString() +'%';
                p.Shipset_Discount1__c = wrpf.DiscountToBeAppliedToShipset.toPlainString()+'%';
                p.Other_Credits2__c = wrpf.OtherShipsetLevelCredits.toPlainString()+'%';
                p.Total_Reduction3__c= wrpf.TotalReductionOfGrossSales.toPlainString()+'%';
                p.Net_Sales4__c = wrpf.NetSalesPerShipsetToCustomer.toPlainString()+'%'; 
                p.Cost_Sales_per_Shipset5__c =  wrpf.CostOfSalesPerShipset.toPlainString()+'%';
                p.Gross_Margin6__c = wrpf.GrossMarginPerShipSet.toPlainString()+'%';
                p.sort_Order__c = 0;
                p.PL_Approval__c = Plapproval.id;
                ProductShipsetList.add(p); 
            } 
            
            else  If (ProductList0.size() >0 && !isInsertProduct){
                wrapperproduct wrpf = ProductList0[0];
                PLA_Page_ShipsetList__c up = new PLA_Page_ShipsetList__c();
                up = ProductMap.get(wrpf.ProductSummaryName);
                up.Gross_Sales0__c = wrpf.GrossSalesPerSS.toPlainString()+'%';
                up.Shipset_Discount1__c = wrpf.DiscountToBeAppliedToShipset.toPlainString()+'%';
                up.Other_Credits2__c = wrpf.OtherShipsetLevelCredits.toPlainString()+'%';
                up.Total_Reduction3__c= wrpf.TotalReductionOfGrossSales.toPlainString()+'%';
                up.Net_Sales4__c = wrpf.NetSalesPerShipsetToCustomer.toPlainString()+'%'; 
                up.Cost_Sales_per_Shipset5__c =  wrpf.CostOfSalesPerShipset.toPlainString()+'%';
                up.Gross_Margin6__c = wrpf.GrossMarginPerShipSet.toPlainString()+'%';
                updateProductList.add(up);
            }  
            
            
          
            If(ProductList2.size()>0 && isInsertProduct){
                PLA_Page_ShipsetList__c p2 = new PLA_Page_ShipsetList__c();
                wrapperproduct wrp = ProductList2[0];
                wrp = ProductList2[0];
                p2.name = wrp.ProductSummaryName;
                p2.Row_Color_Code__c = wrp.RowColorCode;
                p2.Gross_Sales0__c = wrp.GrossSalesPerSS.toPlainString()+'%';
                p2.Shipset_Discount1__c = wrp.DiscountToBeAppliedToShipset.toPlainString()+'%';
                p2.Other_Credits2__c = wrp.OtherShipsetLevelCredits.toPlainString()+'%';
                p2.Total_Reduction3__c= wrp.TotalReductionOfGrossSales.toPlainString()+'%';
                p2.Net_Sales4__c = wrp.NetSalesPerShipsetToCustomer.toPlainString()+'%'; 
                p2.Cost_Sales_per_Shipset5__c =  wrp.CostOfSalesPerShipset.toPlainString()+'%';
                p2.Gross_Margin6__c = wrp.GrossMarginPerShipSet.toPlainString()+'%';
                p2.sort_Order__c = 30;
                p2.PL_Approval__c = Plapproval.id;
                ProductShipsetList.add(p2);

            } else if (ProductList2.size()>0 && !isInsertProduct){
                PLA_Page_ShipsetList__c up2 = new PLA_Page_ShipsetList__c();
                wrapperproduct wrp = ProductList2[0];
                up2 = ProductMap.get(wrp.ProductSummaryName);
                up2.Gross_Sales0__c = wrp.GrossSalesPerSS.toPlainString();
                up2.Shipset_Discount1__c = wrp.DiscountToBeAppliedToShipset.toPlainString();
                up2.Other_Credits2__c = wrp.OtherShipsetLevelCredits.toPlainString();
                up2.Total_Reduction3__c= wrp.TotalReductionOfGrossSales.toPlainString();
                up2.Net_Sales4__c = wrp.NetSalesPerShipsetToCustomer.toPlainString(); 
                up2.Cost_Sales_per_Shipset5__c =  wrp.CostOfSalesPerShipset.toPlainString();
                up2.Gross_Margin6__c = wrp.GrossMarginPerShipSet.toPlainString();
                updateProductList.add(up2);
            } 
            System.debug('*** Calculating Product List2');
            //-----Calculation of "Calculated %'s at Net" Row-----------------------------
            DiscountToBeAppliedToShipsetTotal= 0;
            OtherShipsetLevelCreditsTotal=0;
            TotalReductionOfGrossSalesTotal=0;
            NetSalesPerShipsetToCustomerTotal=0;
            CostOfSalesPerShipsetTotal=0;
            GrossMarginPerShipSetTotal=0;
            //GMPerShipSetTotal=0;
            ShipSetCategoryNetPricePerSeatTotal=0;
            ShipSetCostPerSeatTotal=0;
            if(NetSalesPerShipsetToCustomer_Total >0){

                DiscountToBeAppliedToShipsetTotal= DiscountToBeAppliedToShipset_Total/NetSalesPerShipsetToCustomer_Total;
                OtherShipsetLevelCreditsTotal=OtherShipsetLevelCredits_Total/NetSalesPerShipsetToCustomer_Total;
                TotalReductionOfGrossSalesTotal=TotalReductionOfGrossSales_Total/NetSalesPerShipsetToCustomer_Total;
                CostOfSalesPerShipsetTotal=CostOfSalesPerShipset_Total/NetSalesPerShipsetToCustomer_Total;
                GrossMarginPerShipSetTotal=GrossMarginPerShipSet_Total/NetSalesPerShipsetToCustomer_Total;
                //GMPerShipSetTotal=GMPerShipSet_Total/NetSalesPerShipsetToCustomer_Total;
                ShipSetCategoryNetPricePerSeatTotal=ShipSetCategoryNetPricePerSeat_Total/NetSalesPerShipsetToCustomer_Total;
                ShipSetCostPerSeatTotal=ShipSetCostPerSeat_Total/NetSalesPerShipsetToCustomer_Total;                                
            } 
        }
        
        
    }


    public class WrapperProduct{
        Public string RowColorCode{get;set;}
        public string ProductSummaryName{get;set;}
        
        public Decimal GrossSalesPerSS{get;set;}
        public Decimal DiscountToBeAppliedToShipset{get;set;}
        public Decimal OtherShipsetLevelCredits{get;set;}
        public Decimal TotalReductionOfGrossSales{get;set;}
        public Decimal NetSalesPerShipsetToCustomer{get;set;}
        public Decimal CostOfSalesPerShipset{get;set;}
        public Decimal GrossMarginPerShipSet{get;set;}
        public Decimal GMPerShipSet{get;set;}
        public Decimal ShipSetCategoryNetPricePerSeat{get;set;}
        public Decimal ShipSetCostPerSeat{get;set;}

        public List <String> StrValuesList {get; set;}
        //public List <String> DecValueList {get; set; }
        
        public WrapperProduct(string RowColorCode,string ProductSummaryName,Decimal GrossSalesPerSS,Decimal DiscountToBeAppliedToShipset,Decimal OtherShipsetLevelCredits,Decimal TotalReductionOfGrossSales,Decimal NetSalesPerShipsetToCustomer,Decimal CostOfSalesPerShipset,Decimal GrossMarginPerShipSet,Decimal ShipSetCategoryNetPricePerSeat,Decimal ShipSetCostPerSeat){
            initializeValueList();

            this.ProductSummaryName= ProductSummaryName;
            if(RowColorCode=='Yellow')
                this.RowColorCode ='background-color: #FFFF00;';
            else if(RowColorCode=='Green')
                this.RowColorCode ='background-color: #74cc47;'; 
            else if(RowColorCode=='Pink')
                this.RowColorCode ='background-color: #FFE5B4;'; 
            else if(RowColorCode=='Gray')
                this.RowColorCode ='background-color: #f1f0e8;';
            else this.RowColorCode = 'background-color: ' + RowColorCode;
            
            this.GrossSalesPerSS=GrossSalesPerSS;
            this.DiscountToBeAppliedToShipset=DiscountToBeAppliedToShipset.setScale(2);
            this.OtherShipsetLevelCredits=OtherShipsetLevelCredits.setScale(2);
            this.TotalReductionOfGrossSales=TotalReductionOfGrossSales.setScale(2);
            this.NetSalesPerShipsetToCustomer=NetSalesPerShipsetToCustomer;
            this.CostOfSalesPerShipset=CostOfSalesPerShipset.setScale(2);
            this.GrossMarginPerShipSet=GrossMarginPerShipSet.setScale(2);
            //this.GMPerShipSet=GMPerShipSet.setScale(2);
            this.GMPerShipSet = 0.00;
            this.ShipSetCategoryNetPricePerSeat=ShipSetCategoryNetPricePerSeat.setScale(2);
            this.ShipSetCostPerSeat=ShipSetCostPerSeat.setScale(2);

        }

        public WrapperProduct() {
            this.ProductSummaryName = '';
            this.RowColorCode = '';
            initializeValueList();
            this.GrossSalesPerSS = 0;
            this.DiscountToBeAppliedToShipset = 0;
            this.OtherShipsetLevelCredits = 0;
            this.TotalReductionOfGrossSales = 0;
            this.NetSalesPerShipsetToCustomer = 0;
            this.CostOfSalesPerShipset = 0;
            this.GrossMarginPerShipSet = 0;
            this.GMPerShipSet = 0;
            this.ShipSetCategoryNetPricePerSeat = 0;
            this.ShipSetCostPerSeat = 0;
        }
        public void finalizeWrp(){
            //this.StrGrossSales = pl_utils.getDisplayStrValue(this.GrossSales);
            //this.StrGM = this.GM.setScale(2).format() + '%';

            this.StrValuesList[0] = pl_utils.getDisplayStrValue(this.GrossSalesPerSS);
            this.StrValuesList[1] = pl_utils.getDisplayStrValue(this.DiscountToBeAppliedToShipset);
            this.StrValuesList[2] = pl_utils.getDisplayStrValue(this.OtherShipsetLevelCredits);
            this.StrValuesList[3] = pl_utils.getDisplayStrValue(this.TotalReductionOfGrossSales);
            this.StrValuesList[4] = pl_utils.getDisplayStrValue(this.NetSalesPerShipsetToCustomer);
            this.StrValuesList[5] = pl_utils.getDisplayStrValue(this.CostOfSalesPerShipset);
            this.StrValuesList[6] = pl_utils.getDisplayStrValue(this.GrossMarginPerShipSet);
            if (this.NetSalesPerShipsetToCustomer != 0 && this.GrossMarginPerShipSet != 0) {
                this.StrValuesList[7] = ((this.GrossMarginPerShipSet / this.NetSalesPerShipsetToCustomer) * 100).format() + '%' ;
            }else {
                this.StrValuesList[7] = '0' ; // W-004372 Set to 0.00%
            }
            this.StrValuesList[8] = pl_utils.getDisplayStrValue(this.ShipSetCategoryNetPricePerSeat);
            this.StrValuesList[9] = pl_utils.getDisplayStrValue(this.ShipSetCostPerSeat);
        }

        public void initializeValueList() {
            this.StrValuesList = new List <String> ();
            //DecValueList = new List <String> ();
            for (Integer i = 0; i < 10; i++){
                String StrValue = '0'; // W-004372 Set to 0
                //Decimal decValue = 0;
                StrValuesList.add(StrValue);
                //DecValueList.add(decValue);
            }
        }
    }

    public void bindConsolidatedHeader(){
        headerName = new List <String>();
        headerColor = new List <String>();
        headerNetSales = new List <Decimal>();
        headerCosts = new List <Decimal>();

        List <PL_MD__c> pgMDList = [select id, Name, Pillar__c, Product_Group__c, Sort_Order__c,color__c, 
        L2I_Migration_External_Id__c  from PL_MD__c Where MD_Type__c = 'Product Group' Order By Sort_Order__c];
        if (pgMDList.size() > 0){
            Integer i = 0;
            for (PL_MD__c pgMD : pgMDList) {
                Decimal netSales = 0;
                Decimal netCost = 0;
                headerNetSales.add(netSales);
                headerCosts.add(netCost);
                headerName.add(pgMd.Product_Group__c);
                headerColor.add('background-color:' + pgMd.color__c + ';');
                consHeadMap.put(pgMd.L2I_Migration_External_Id__c, i);
                i++;
            }
        } else {
            headerName.add('IFE Hardware');
            consHeadMap.put('IFE-H',0);
            headerNetSales.add(0);
            headerCosts.add(0);

            headerName.add('IFE Services');
            consHeadMap.put('IFE-S',1);
            headerNetSales.add(0);
            headerCosts.add(0);

            headerName.add('Subtotal : IFE');
            consHeadMap.put('IFE-T',2);
            headerNetSales.add(0);
            headerCosts.add(0);

            headerName.add('IFC Hardware');
            consHeadMap.put('IFC-H',3);
            headerNetSales.add(0);
            headerCosts.add(0);

            headerName.add('IFC Services');
            consHeadMap.put('IFC-S',4);
            headerNetSales.add(0);
            headerCosts.add(0);

            headerName.add('Subtotal : IFC');
            consHeadMap.put('IFC-T',5);
            headerNetSales.add(0);
            headerCosts.add(0);

            headerName.add('DSS');
            consHeadMap.put('DSS',6);
            headerNetSales.add(0);
            headerCosts.add(0);

            headerName.add('PTS');
            consHeadMap.put('PTS',7);
            headerNetSales.add(0);
            headerCosts.add(0);

            headerName.add('TOTAL PROGRAM');
            consHeadMap.put('TotProg',8);
            headerNetSales.add(0);
            headerCosts.add(0);

            headerName.add('Pct(%) of Net Sales');
            consHeadMap.put('pct',9);
            headerNetSales.add(0);
            headerCosts.add(0);

            headerColor.add('');
            headerColor.add('');
            headerColor.add('');
            headerColor.add('');
            headerColor.add('');
            headerColor.add('');
            headerColor.add('');
            headerColor.add('');
            headerColor.add('');
            headerColor.add('');

        }
    }


    public void bind_WrapperConsolidateList(){

        // create data sets for consolidated rows
        // If you add Calculate_Display = True to query then the formulas  calculate
        List<PL_MD__c> lst = [select Name, Cost_Allocation__c, Cost_Allocation_Item__c, Sort_Order__c, color__c, 
        L2I_Migration_External_Id__c  from PL_MD__c Where MD_Type__c = 'Cost Allocation'  Order By Sort_Order__c ];

        if(lst.size()>0){
            Integer RowSpanCount=0;
            string GNameOld='';
            Integer count=0;

            for(PL_MD__c pl : lst){
                if(RowSpanMap.containsKey(pl.Cost_Allocation__c)){
                    Integer RowCount =  RowSpanMap.get(pl.Cost_Allocation__c);
                    RowCount = RowCount+1;
                    RowSpanMap.put(pl.Cost_Allocation__c,RowCount);    
                }else{ RowSpanMap.put(pl.Cost_Allocation__c,1); }
            }
            
            GNameOld='';
            count=0;
            string RowColorCode1 = '';
            for(PL_MD__c consRow : lst){
                //system.debug('=========================================================');
                string RowColorCode = '';
                string GName = consRow.Cost_Allocation__c;
                if(string.isNotEmpty(consRow.color__c)) {
                    RowColorCode = consRow.color__c;
                }
                if(consRow.Sort_Order__c==150){
                    RowColorCode1 = consRow.color__c;
                }
                
                //system.debug('ChekkkColo' + RowColorCode1  );
                if(GNameOld != GName){
                    GNameOld = GName; 
                    if(count >0){}else{
                        count=count+1;
                    }
                }else{ GName=''; }
                
                if(RowSpanMap.containsKey(GName)){
                    RowSpanCount =  RowSpanMap.get(GName);
                }else{ RowSpanCount=0; }

                List<string> Gnlst = new List<string>();
                string lstGNRowCss='';
                if(string.isNotEmpty(GName)){
                    string myName = GName.reverse();
                    String[] stringCharacters = myName.split('');
                    Integer lnth = stringCharacters.size();
                    lnth  = 15*lnth;
                    //system.debug('RowColorCode1::' + RowColorCode1);
                    VerticalHeadercolor = 'width:1%; vertical-align: sub; background-color:'+RowColorCode1+' ;height: '+lnth+'px;';
                    
                    lstGNRowCss='width:1%; vertical-align: sub; background-color:'+RowColorCode+' ;height: '+lnth+'px;';
                    if(stringCharacters.size()>0){
                        for(Integer i=0; i<stringCharacters.size(); i++){
                            Gnlst.add(stringCharacters[i]);
                        }
                    }
                }

                WrapperConsolidate wrp;
                if(consRow.Name.containsIgnoreCase('Total')){
                    wrp = new WrapperConsolidate(consRow.L2I_Migration_External_Id__c, headerName.Size(), consRow.Name,RowSpanCount,RowColorCode,'',new List<string>(),'');
                }else{
                    wrp = new WrapperConsolidate(consRow.L2I_Migration_External_Id__c, headerName.Size(), consRow.Name,RowSpanCount,RowColorCode,GName,Gnlst,lstGNRowCss);
                }
                WrapperConsolidateList.add(wrp);
                wrpConsMap.put(consRow.L2I_Migration_External_Id__c, wrp);
            }
            try{
                // now bind the data on to the cost allocation row wrappers
                bind_consProductSummary();

                // now bind cost allocation %
                bind_consCostAllocations();

                // Initialize totals for all wrapper
                for (WrapperConsolidate wrpInst : WrapperConsolidateList){
                    // initialize Margin rows
                    if (wrpInst.CostAllKey == 'CAL-COGS-GM' || wrpInst.CostAllKey == 'CAL-VC-MP' || wrpInst.CostAllKey == 'CAL-DF-DCM' || wrpInst.CostAllKey == 'CAL-AC-PBT'){
                        initializeMargins(wrpInst);
                    }

                    wrpInst.initializeTotals();

                    if (!wrpInst.percentage){
                        // Calculate % column for non percent rows
                        if (wrpInst.CostAllKey.contains('-SALES-')){
                            // update pct column for Sales Section using prgGrossTotal
                            wrpInst.lstValuesDec[9] = (wrpInst.lstValuesDec[8] / prgGrossTotal) *100;
                        } else {
                            // update pct column for non Sales Sections using prgNetSalesTotal
                            wrpInst.lstValuesDec[9] = (wrpInst.lstValuesDec[8] / prgNetSalesTotal) *100;
                        }
                    }
                }

                // initialize percent rows data after all $s have been processed.
                initializeMarginPercents();

                // get program profit before tax
                prgProfitBeforeTax = wrpConsMap.get('CAL-AC-PBT').lstValuesDec[8];
                if (prgProfitBeforeTax != 0 && prgNetSalesTotal !=0 ) {
                    prgPBTPercent = ((prgProfitBeforeTax / prgNetSalesTotal) * 100).setScale(2);
                    prgPATPercent = (((100-corpTaxRate) * prgProfitBeforeTax) / prgNetSalesTotal).setScale(2);
                    if(ApprovalHeaderList.size()> 0){
                        ApprovalHeaderList[0].Program_PAT_Percent__c = prgPATPercent?.ToPlainString();
                        ApprovalHeaderList[0].Program_PBT_Percent__c = prgPBTPercent?.ToPlainString();
                    }
                }

                // finalize wrapper for display
                for (WrapperConsolidate wrpInst : WrapperConsolidateList){
                    wrpInst.finalizeWrp();
                }
                System.debug('*** Calculating Consolidated List');
                If(isInsertConsolidated && WrapperConsolidateList.size()>0){
                    integer sortOrder = 0;
                    for(WrapperConsolidate w : WrapperConsolidateList){
                        system.debug('Creating insert records ' + sortOrder);
                        PLA_Page_ConsolidatedList__c p = new   PLA_Page_ConsolidatedList__c ();
                        String convertList ='';
                        sortOrder++;

                        p.Row_Color_Code__c = w.RowColorCode;
                        p.Row_Span_Count__c = w.RowSpanCount;
                        p.isCol_Display__c = w.isColDisplay;
                        p.Name = w.CostAllocationName;
                        if(w.lstgn.size()> 0){
                            for(string s : w.lstGN){
                                convertList = ConvertList + s + ',';
                            }         
                            p.Group_NameList__c = convertList.RemoveEnd(',');
                        }
                        p.IFE_Hardware0__c = w.lstValuesStr[0];
                        p.IFE_Services1__c = w.lstValuesStr[1];
                        p.IFE_SubTotal2__c = w.lstValuesStr[2];
                        p.IFC_Hardware3__c = w.lstValuesStr[3];
                        p.IFC_Services4__c = w.lstValuesStr[4];
                        p.IFC_SubTotal5__c = w.lstValuesStr[5];
                        p.DSS6__c = w.lstValuesStr[6];
                        p.PTS7__c = w.lstValuesStr[7];
                        p.Total_Program8__c = w.lstValuesStr[8];
                        p.Net_Sales9__c = w.lstValuesStr[9];
                        p.Sort_Order__c = sortOrder;
                        p.P_L_Approval__c =  plApproval.id;
                        p.Vertical_Header_Color__c = VerticalHeaderColor;
                        ProductConsolidatedList.add(p);
                    }
                } else if (!isInsertConsolidated && WrapperConsolidateList.size()>0) {
                    for (WrapperConsolidate w :WrapperConsolidateList) {
                        PLA_Page_ConsolidatedList__c p = new   PLA_Page_ConsolidatedList__c ();
                        p = ProductConsolidatedMap.get(w.CostAllocationName);
                        if(p != null) {  // W-004372 added null check
                            p.IFE_Hardware0__c = w.lstValuesStr[0];
                            p.IFE_Services1__c = w.lstValuesStr[1];
                            p.IFE_SubTotal2__c = w.lstValuesStr[2];
                            p.IFC_Hardware3__c = w.lstValuesStr[3];
                            p.IFC_Services4__c = w.lstValuesStr[4];
                            p.IFC_SubTotal5__c = w.lstValuesStr[5];
                            p.DSS6__c = w.lstValuesStr[6];
                            p.PTS7__c = w.lstValuesStr[7];
                            p.Total_Program8__c = w.lstValuesStr[8];
                            p.Net_Sales9__c = w.lstValuesStr[9];
                            p.Vertical_Header_Color__c = VerticalHeaderColor;
                            updateProductConsolidatedList.add(p);
                        }
                    }
                }
                System.debug(' Finished Calculating Consolidate List');
            } catch(Exception ex){
                System.debug('*** Exception ' + ex.getMessage());
            }
        }
        // WINote Create Rows in Wrapper Custom Object  // Populate the Group Name Field as is empty on the second row of group
    }

    public void initializeMarginPercents(){
        for (WrapperConsolidate wrp : WrapperConsolidateList) {
            if (wrp.percentage) {
                for (Integer i = 0; i< consHeadMap.size() -1 ;i++) {
                    Decimal Value1 = 0;
                    Decimal Value2 = 0;
                    if (wrp.CostAllKey.contains('-SALES-')) { // values for percent Discount/credit
                        Value1 = (wrpConsMap.get('CAL-SALES-DISCOUNT').lstValuesDec[i] + wrpConsMap.get('CAL-SALES-CREDITS').lstValuesDec[i]);
                        Value2 = wrpConsMap.get('CAL-SALES-GROSS').lstValuesDec[i];
                    } else {
                        Value2 = wrpConsMap.get('CAL-SALES-TOT').lstValuesDec[i];
                        if (wrp.CostAllKey.contains('-COGS-')) { // values for percent of Gross Margin
                            Value1 = (wrpConsMap.get('CAL-COGS-GM').lstValuesDec[i]);
                        }else if (wrp.CostAllKey.contains('-VC-')) { // values for percent of Marginal Profit
                            Value1 = (wrpConsMap.get('CAL-VC-MP').lstValuesDec[i]);
                        }else if (wrp.CostAllKey.contains('-DF-')) { // values for percent of contribution margin
                            Value1 = (wrpConsMap.get('CAL-DF-DCM').lstValuesDec[i]);
                        }else if (wrp.CostAllKey.contains('-AC-')) { // values for percent of profit before tax
                            Value1 = (wrpConsMap.get('CAL-AC-PBT').lstValuesDec[i]);
                        }
                    }
                    if (Value1 != 0 && Value2 != 0) {
                        wrp.lstValuesDec[i] = (Value1 / Value2) * 100;
                    }
                }
            }
        }
    }

    public void initializeMargins(WrapperConsolidate wrp){
            // initialize Margin cells if (wrpInst.CostAllKey == 'CAL-COGS-GM' || wrpInst.CostAllKey == 'CAL-VC-MP'
            //                            || wrpInst.CostAllKey == 'CAL-DF-DCM' || wrpInst.CostAllKey == 'CAL-AC-PBT'){
            for (Integer i = 0; i< consHeadMap.size() -1 ;i++) {
                if (i != 2 && i != 5 && i < 8) {
                    if (wrp.CostAllKey == 'CAL-COGS-GM') {
                        // Initialize Gross Margin for true headers
                        wrp.lstValuesDec[i] = wrpConsMap.get('CAL-SALES-TOT').lstValuesDec[i] - wrpConsMap.get('CAL-COGS-TOT').lstValuesDec[i];
                    } else if (wrp.CostAllKey == 'CAL-VC-MP') { // initialize Marginal Profit
                        wrp.lstValuesDec[i] = wrpConsMap.get('CAL-COGS-GM').lstValuesDec[i] - wrpConsMap.get('CAL-VC-TOT').lstValuesDec[i];
                    } else if (wrp.CostAllKey == 'CAL-DF-DCM') { // initialize Direct Contribution Margin
                        wrp.lstValuesDec[i] = wrpConsMap.get('CAL-VC-MP').lstValuesDec[i] - wrpConsMap.get('CAL-DF-TOT').lstValuesDec[i];
                    } else if (wrp.CostAllKey == 'CAL-AC-PBT') { // initialize Direct Contribution Margin
                        wrp.lstValuesDec[i] = wrpConsMap.get('CAL-DF-DCM').lstValuesDec[i] - wrpConsMap.get('CAL-AC-TOT').lstValuesDec[i];
                    }
                }
            }
    }

    public void bind_consCostAllocations(){
        // Calculate the values here
        decimal calPercent = 0;
        system.debug('*** 1 Starting Bind Cost Allocations');
        for( PL_CAL__c cal : [select Id, Percent__c, Allocation_Type__c,  pl_MD__r.l2I_Migration_External_ID__c,
                        Product_Group__r.pl_MD__r.l2I_Migration_External_ID__c, PG_Name__c, Sort_Order__c,
                        Cost_Allocation__c, Cost_Allocation_Item__c, name
                        from PL_CAL__c Where Product_Group__r.is_Active__c = true and Percent__c > 0 and  Calculate_Display__c != false
                        Order by Product_Group__r.pl_MD__r.sort_Order__c, pl_MD__r.sort_Order__c])
       
        
        {
            calPercent = cal.Percent__c;

            if (cal.Percent__c > 0 && !cal.pl_MD__r.l2I_Migration_External_ID__c.contains('COGS')){
                Integer colHeadIndex = consHeadMap.get(cal.Product_Group__r.pl_MD__r.l2I_Migration_External_ID__c);
                system.debug('index is ' + colHeadIndex);
                WrapperConsolidate wrp = wrpConsMap.get(cal.pl_MD__r.l2I_Migration_External_ID__c);
                WrapperConsolidate wrpTot; // VC-DF-AC

                if (cal.pl_MD__r.l2I_Migration_External_ID__c.contains('-VC-')){
                    wrpTot = wrpConsMap.get('CAL-VC-TOT');
                } else if (cal.pl_MD__r.l2I_Migration_External_ID__c.contains('-DF-')){
                    wrpTot = wrpConsMap.get('CAL-DF-TOT');
                } else if (cal.pl_MD__r.l2I_Migration_External_ID__c.contains('-AC-')) {
                    wrpTot = wrpConsMap.get('CAL-AC-TOT');
                }
                if (cal.Allocation_Type__c == '% of NET SALES' && headerNetSales[colHeadIndex] !=0 && cal.Cost_Allocation_Item__c != 'PTS Total Line Maintenance'){
                    if(cal.PG_Name__c == 'PTS' && cal.Cost_Allocation_Item__c == 'Variable Risk/Contingency' && VariableRiskContingency != 0 ){ //W-004407
                        calPercent = VariableRiskContingency;
                    } 
                    if(cal.PG_Name__c == 'PTS' && cal.Cost_Allocation_Item__c == 'One PA Headquarter Fee' && OnePAHeadQuarter != 0 ){ //W-004407
                        calPercent = OnePAHeadQuarter;
                    } 
                    if(cal.PG_Name__c == 'PTS' && cal.Cost_Allocation_Item__c == 'SGNA Admin Fee' && SGNAAdminFee != 0 ){ //W-004407
                        calPercent = SGNAAdminFee;
                    } 
                    wrp.lstValuesDec[colHeadIndex] = (headerNetSales[colHeadIndex] * calPercent) / 100;
                    wrpTot.lstValuesDec[colHeadIndex] += (headerNetSales[colHeadIndex] * calPercent) / 100;
                }
                if(cal.PG_Name__c == 'PTS' && cal.Cost_Allocation_Item__c == 'PTS Total Line Maintenance' ){
                        wrp.lstValuesDec[colHeadIndex] = wrpConsMap.get('CAL-DF-PTLM').lstValuesDec[colHeadIndex];
                        wrpTot.lstValuesDec[colHeadIndex] += wrpConsMap.get('CAL-DF-PTLM').lstValuesDec[colHeadIndex];
                } else if (cal.Allocation_Type__c == '% of COST' && headerCosts[colHeadIndex] !=0 ) {
                    wrp.lstValuesDec[colHeadIndex] = (headerCosts[colHeadIndex] * calPercent) / 100;
                    wrpTot.lstValuesDec[colHeadIndex] += (headerCosts[colHeadIndex] * calPercent) / 100;
                }
            }
        }
    }

    // method to map product summary data to consolidated wrappers.
    public void bind_consProductSummary(){
        // read all quote product summary data psQPSList

        if (psQPSList.size() > 0) {
            //System.debug('psQPSList.size() :' + psQPSList.size());
            for (PL_PS__c qPS : psQPSList) {
                // get the column header index based on product group to header map
                Integer consHeaderIndex = 0;
                consHeaderIndex = consHeadMap.Get(qPS.Product_Group__r.PL_MD__r.L2I_Migration_External_Id__c);

                // Set gross Sales amount
                if (qPS.Gross_Sales__c != 0 && qPS.Gross_Sales__c != null) {
                    wrpConsMap.get('CAL-SALES-GROSS').lstValuesDec[consHeaderIndex] += qPS.Gross_Sales__c;
                    prgGrossTotal += qPS.Gross_Sales__c;
                }

                // Set gross discount
                if (qPS.Discount__c != 0 && qPS.Discount__c != null) {
                    wrpConsMap.get('CAL-SALES-DISCOUNT').lstValuesDec[consHeaderIndex] += qPS.Discount__c;
                }

                // Set gross discount
                if (qPS.Credit__c != 0 && qPS.Credit__c != null) {
                    wrpConsMap.get('CAL-SALES-CREDITS').lstValuesDec[consHeaderIndex] += qPS.Credit__c;
                }

                // Set Total Sales
                if (qPS.ps_NS_to_Cust__c != 0 && qPS.ps_NS_to_Cust__c != null) {
                    wrpConsMap.get('CAL-SALES-TOT').lstValuesDec[consHeaderIndex] += qPS.ps_NS_to_Cust__c;
                    prgNetSalesTotal += qPS.ps_NS_to_Cust__c;
                    headerNetSales[consHeaderIndex] += qPS.ps_NS_to_Cust__c;
                }

                // Set Costs , CAL-COGS-TOT
                if (qPS.Cost__c != 0 && qPS.Cost__c != null) {
                    if (qPS.Product_Summary__r.L2I_Migration_External_Id__c == 'IFE-H-Harness'){
                        wrpConsMap.get('CAL-COGS-HC').lstValuesDec[consHeaderIndex] += qPS.Cost__c;
                    } else if (qPS.Product_Summary__r.L2I_Migration_External_Id__c == 'IFE-H-Structure') {
                        wrpConsMap.get('CAL-COGS-SC').lstValuesDec[consHeaderIndex] += qPS.Cost__c;
                    } else {
                        wrpConsMap.get('CAL-COGS-DMSC').lstValuesDec[consHeaderIndex] += qPS.Cost__c;
                    }
                    if (qPS.Product_Summary__r.L2I_Migration_External_Id__c == 'PTS-Maint') {
                        wrpConsMap.get('CAL-COGS-DMSC').lstValuesDec[consHeaderIndex] = qPS.Cost__c - qPS.Line_Maintenance_Cost__c;
                        wrpConsMap.get('CAL-DF-PTLM').lstValuesDec[consHeaderIndex] = qPS.Line_Maintenance_Cost__c;
                    }
                    // update the total row
                    wrpConsMap.get('CAL-COGS-TOT').lstValuesDec[consHeaderIndex] += qPS.Cost__c - qPS.Line_Maintenance_Cost__c;
                    headerCosts[consHeaderIndex] += qPS.Cost__c;
                }
                /* Commented out for W-004366
                // Set other cost of sales -  CAL_COGS__c
                if (qPS.CAL_COGS__c != 0 && qPS.CAL_COGS__c != null) {
                    wrpConsMap.get('CAL-COGS-OCOS').lstValuesDec[consHeaderIndex] += qPS.CAL_COGS__c;
                    wrpConsMap.get('CAL-COGS-TOT').lstValuesDec[consHeaderIndex] += qPS.CAL_COGS__c;

                    //System.debug('qPS.CAL_COGS__c : ' + qPS.CAL_COGS__c);
                    //System.debug('cogs total for the row : ' + wrpConsMap.get('CAL-COGS-OCOS').lstValuesDec[consHeaderIndex]);
                    //System.debug('cogs total for the COGS TOT : ' + wrpConsMap.get('CAL-COGS-TOT').lstValuesDec[consHeaderIndex]);

                }*/

                // Set warranty Cost CAL-VC-WARRANTY, CAL-VC-TOT
                if (qPS.Warranty_Cost__c != 0 && qPS.Warranty_Cost__c != null) {
                    wrpConsMap.get('CAL-VC-WARRANTY').lstValuesDec[consHeaderIndex] += qPS.Warranty_Cost__c;
                    wrpConsMap.get('CAL-VC-TOT').lstValuesDec[consHeaderIndex] += qPS.Warranty_Cost__c;
                }

            } // end for loop Quote product Summary/

            // to do -- Process Product Group cost allocations for each product summary based $
        }

    }

    public class WrapperConsolidate{
        public string GroupName{get;set;}
        public Integer RowSpanCount{get;set;}
        public boolean isColDisplay{get;set;}
        public string ProductSummary{get;set;}
        public string CostAllocationName{get;set;}
        Public string RowColorCode{get;set;}
        public List<string>lstGN{get;set;}
        public string lstGNRowCss{get;set;}
        public Boolean percentage{get;set;}

        public List <String> lstValuesStr {get;set;}
        public List <Decimal> lstValuesDec {get;set;}

        public String CostAllKey {get;set;}

        public WrapperConsolidate(String CAKey, Integer colHeaders, String CostAllocationName, Integer RowSpanCount, String RowColorCode, 
                                    String GroupName, List<String> Gnlst, String lstGNRowCss){
            this.lstValuesStr = new List <String> ();
            this.lstValuesDec = new List <Decimal>();

            for (Integer i = 0; i < colHeaders; i++) {
                Decimal cellValueDec = 0.00;
                String cellValueStr = '';

                this.lstValuesStr.add(cellValueStr);
                this.lstValuesDec.add(cellValueDec);
            }

            this.CostAllKey = CAKey;
            this.percentage = CAKey.contains('-PCT');
            this.CostAllocationName = CostAllocationName;
            this.RowColorCode ='background-color:'+RowColorCode+' ;'; 
            
            this.GroupName= GroupName;
            this.lstGN = Gnlst;
            this.lstGNRowCss = lstGNRowCss;
            this.RowSpanCount = RowSpanCount;
            if(!string.isEmpty(GroupName)){
                this.isColDisplay=true;
            }else{
                this.isColDisplay=false; 
            }
        }

        public void initializeTotals(){
            try{
                // W-004361 Commented out to allow 0 and negative values
                //if (this.lstValuesDec[0] > 0 || this.lstValuesDec[1] >0){
                this.lstValuesDec[2] = this.lstValuesDec[0] + this.lstValuesDec[1];
                //} // W-004361
                //if (this.lstValuesDec[3] > 0 || this.lstValuesDec[4] >0){
                this.lstValuesDec[5] = this.lstValuesDec[3] + this.lstValuesDec[4];
                //} // W-004361

                this.lstValuesDec[8] = this.lstValuesDec[2] + this.lstValuesDec[5] + this.lstValuesDec[6] + this.lstValuesDec[7];
            }
            catch(Exception ex){}
        }

        public void finalizeWrp(){
            for (Integer i = 0; i< this.lstValuesStr.size();i++){
                if (this.lstValuesDec[i] != 0 && this.lstValuesDec[i] != null) {
                    String strValue = '';
                    if (this.percentage || i == 9){
                        //Decimal decValue = this.lstValuesDec[i].setScale(2);
                        //String strValue = String.valueOf(decValue);
                        strValue = this.lstValuesDec[i].setScale(2).format() + '%';
                    } else {
                        strValue =  pl_utils.getDisplayStrValue(this.lstValuesDec[i]);
                    }
                    this.lstValuesStr[i] = strValue;
                }else{this.lstValuesStr[i] = '0';} // W-004372 Set to 0
            }
        }
    }

    public void bind_WrapperProductServices(){
        
        if(psPLMDList.size()>0){
            //string SummaryName=pl.Name;
            Decimal GrossSales_Total =0;
            Decimal DiscountAmount_Total =0;
            Decimal OtherCreditsAmount_Total =0;
            Decimal ReductionOfGrossSales_Total =0;
            Decimal NetSalesToCustomer_Total =0;
            Decimal TotalCost_Total =0;
            Decimal GrossMargin_Total =0;
            string RowColorCode ='';
            
            Map<String, WrapperProductServices> wrpMap = new MAP<String, WrapperProductServices> ();
            for(PL_MD__c pl : psPLMDList) {
                if (pl.Sort_Order__c >=100) {
                    WrapperProductServices wrpPL = new WrapperProductServices();
                    wrpPL.ProductSummary = pl.name;
                    wrpPL.RowColorCode = 'background-color: ' + pl.Color__c;
                    wrpMap.put(pl.Name, wrpPL);
                    WrapperProductServicesList.add(wrpPL);
                }
            }

            for(PL_PS__c ps: psQPSList){
                if (ps.Sort_Order__c >= 100) {
                    if (ps.Credit__c != null) {
                        wrpMap.Get(ps.Product_Summary__r.name).OtherCreditsAmount += ps.Credit__c;
                        OtherCreditsAmount_Total += ps.Credit__c;
                    }

                    if (ps.Discount__c != null) {
                        wrpMap.Get(ps.Product_Summary__r.name).PercentDiscount += ps.Discount__c;
                        DiscountAmount_Total += ps.Discount__c;
                    }

                    if (ps.ps_NS_to_Cust__c != null) {
                        wrpMap.Get(ps.Product_Summary__r.name).NetSalesToCustomer += ps.ps_NS_to_Cust__c;
                        NetSalesToCustomer_Total += ps.ps_NS_to_Cust__c;
                    }
                    if (ps.Cost__c != null) {
                        wrpMap.Get(ps.Product_Summary__r.name).TotalCost += ps.Cost__c;
                        TotalCost_Total += ps.Cost__c;
                    }
                    if (ps.Gross_Sales__c != null) {
                        wrpMap.Get(ps.Product_Summary__r.name).GrossSales += ps.Gross_Sales__c;
                        GrossSales_Total += ps.Gross_Sales__c;
                    }

                    if (ps.Red_in_GS__c != null) {
                        //ReductionOfGrossSales += Discount + Credit;
                        wrpMap.Get(ps.Product_Summary__r.name).ReductionOfGrossSales += ps.Red_in_GS__c;
                        ReductionOfGrossSales_Total += ps.Red_in_GS__c;
                    }

                    if (ps.ps_GM__c != null) {
                        wrpMap.Get(ps.Product_Summary__r.name).GrossMargin += ps.ps_GM__c ;
                        GrossMargin_Total += ps.ps_GM__c;
                    }
                }
            }

            RowColorCode = 'DarkGray';
            
            WrapperProductServicesList.add(new WrapperProductServices(RowColorCode,'TOTAL-Non Shipset',GrossSales_Total,DiscountAmount_Total,OtherCreditsAmount_Total,ReductionOfGrossSales_Total,NetSalesToCustomer_Total,TotalCost_Total, GrossMargin_Total));
            // finalize wapper for display
            for (WrapperProductServices wrpf :WrapperProductServicesList) {
                wrpf.finalizeWrp();   
            } 
            If(isInsert && WrapperProductServicesList.size()>0 )  {
                integer rowCount =0;
                for (WrapperProductServices wrpf :WrapperProductServicesList) {
                    system.debug('*** creating stored row');
                    PLA_Page_ProductServices_List__c ps = new PLA_Page_ProductServices_List__c();
                    ps.row_color_code__c = wrpf.RowColorCode;
                    rowCount++  ;   
                    ps.Sort_Order__c = rowCount;
                    ps.name = wrpf.ProductSummary;
                    ps.Gross_Sales__c = wrpf.StrGrossSales;
                    ps.Percent_Discount__c =  wrpf.StrPercentDiscount;
                    ps.Other_Credits_Amount__c = wrpf.StrOtherCreditsAmount;
                    ps.Reduction_Gross_Sales__c =  wrpf.StrReductionOfGrossSales;
                    ps.Net_Sales_Customer__c =  wrpf.StrNetSalesToCustomer;
                    ps.Total_Cost__c = wrpf.StrTotalCost;
                    ps.Gross_Margin__c = wrpf.StrGrossMargin;
                    ps.Gross_Margin_Percentage__c =  wrpf.StrGM;
                    ps.P_L_Approval__c = Plapproval.id ;
                    system.debug('*** ' + ps.name);
                    storedProductServicesList.add(ps);    
                }                      
            } else if  (!isInsert && WrapperProductServicesList.size()>0 ) {

                for (WrapperProductServices wrpf :WrapperProductServicesList) {

                    PLA_Page_ProductServices_List__c ps = new  PLA_Page_ProductServices_List__c (); 
                    ps = ProductServicesMap.get(wrpf.ProductSummary);
                    if(ps != null) { // W-004372 added null check
                        ps.Gross_Sales__c = wrpf.StrGrossSales;
                        ps.Percent_Discount__c =  wrpf.StrPercentDiscount;
                        ps.Other_Credits_Amount__c = wrpf.StrOtherCreditsAmount;
                        ps.Reduction_Gross_Sales__c =  wrpf.StrReductionOfGrossSales;
                        ps.Net_Sales_Customer__c =  wrpf.StrNetSalesToCustomer;
                        ps.Total_Cost__c = wrpf.StrTotalCost;
                        ps.Gross_Margin__c = wrpf.StrGrossMargin;
                        ps.Gross_Margin_Percentage__c =  wrpf.StrGM;
                        ps.Row_Color_Code__c = wrpf.RowColorCode; // W-004435
                        updateProductServicesList.add(ps);
                    }
                }
            } 

        }    
        
       
    }
    
    public class WrapperProductServices {
        public string RowColorCode { get; set; }
        public string ProductSummary { get; set; }
        public Decimal GrossSales { get; set; }
        public String StrGrossSales {get; set; }

        public Decimal PercentDiscount { get; set; }
        public String strPercentDiscount { get; set; }

        public Decimal OtherCreditsAmount { get; set; }
        public String StrOtherCreditsAmount { get; set; }

        public Decimal ReductionOfGrossSales { get; set; }
        public String StrReductionOfGrossSales { get; set; }

        public Decimal NetSalesToCustomer { get; set; }
        public String StrNetSalesToCustomer { get; set; }

        public Decimal TotalCost { get; set; }
        public String StrTotalCost { get; set; }

        public Decimal GrossMargin { get; set; }
        public String StrGrossMargin { get; set; }

        //Public Decimal GM { get; set; }
        public String StrGM {get; set;}

        public List <String> args {get;set;}

        public WrapperProductServices(string RowColorCode, string ProductSummary, Decimal GrossSales, Decimal PercentDiscount, Decimal OtherCreditsAmount, Decimal ReductionOfGrossSales, Decimal NetSalesToCustomer, Decimal TotalCost, Decimal decGrossMargin) {
            this.ProductSummary = ProductSummary;
            if (RowColorCode == 'DarkGray') {
                this.RowColorCode = 'background-color: #8da2c1;';
            } else {
                this.RowColorCode = 'background-color: ' + RowColorCode;
            }
            this.GrossSales = GrossSales;

            this.PercentDiscount = PercentDiscount;
            this.OtherCreditsAmount = OtherCreditsAmount;
            this.ReductionOfGrossSales = ReductionOfGrossSales;
            this.NetSalesToCustomer = NetSalesToCustomer;
            this.TotalCost = TotalCost;
            this.GrossMargin = decGrossMargin;
        }
        public WrapperProductServices() {
            this.ProductSummary = '';
            this.RowColorCode = '';
            this.GrossSales = 0;

            this.PercentDiscount = 0;
            this.OtherCreditsAmount = 0;
            this.ReductionOfGrossSales = 0;
            this.NetSalesToCustomer = 0;
            this.TotalCost = 0;
            this.GrossMargin = 0;
            //this.GM = 0;
        }

        public void finalizeWrp(){
            this.StrGrossSales = pl_utils.getDisplayStrValue(this.GrossSales);
            this.strPercentDiscount = pl_utils.getDisplayStrValue(this.PercentDiscount);
            this.StrOtherCreditsAmount = pl_utils.getDisplayStrValue(this.OtherCreditsAmount);
            this.StrReductionOfGrossSales = pl_utils.getDisplayStrValue(this.ReductionOfGrossSales);
            this.StrNetSalesToCustomer = pl_utils.getDisplayStrValue(this.NetSalesToCustomer);
            this.StrTotalCost = pl_utils.getDisplayStrValue(this.TotalCost);
            this.StrGrossMargin = pl_utils.getDisplayStrValue(this.GrossMargin);
            if (this.GrossMargin != 0 && this.NetSalesToCustomer !=0){
                this.StrGM = ((this.GrossMargin / this.NetSalesToCustomer) * 100).setScale(2).format() + '%';
            } else {
                this.StrGM = '0'; // W-004372 Set to 0.00%
            }
        }
        
    }
}