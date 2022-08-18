public class PL_newViewController{
    
    public L2I_P_L_Approval__c Plapproval        {get;set;}
    public String todaydate{get;set;}
    public List<String> headerName {get;set;}
    public List<String> headerColor {get;set;}
    public List<Decimal> headerNetSales {get;set;}
    public List<Decimal> headerCosts {get;set;}
    public Map<String, Integer> consHeadMap = new Map<String, Integer> ();

    public Map<string,Integer>RowSpanMap{get;set;} 

    public String VerticalHeadercolor {get;set;}
    // New Data loads
 
    public List <PLA_Page_ProductServices_List__c> ProductServicesList {get;set;}
    public List<PLA_Page_ConsolidatedList__c> ProductConsolidateList {get;set;}
    public List<newWrapperConsolidate>  newWrapperConsolidateList {get;set;}
    public List<PLA_Page_ShipsetList__c> ProductShipsetList {get;set;}
    public List<PLA_Page_ShipsetList__c > ProductShipsetList0 {get;set;}
    public List<PLA_Page_Opportunity_List__c> OpportunityList {get;set;}
    public PLA_Page_Header__c header {get;set;}


    // Added by Lipton for W-003855
    public String fileName { get; set; }

    // Added by Lipton for W-003855
    public String xlsHeader
    {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }

    // Added by Lipton for W-003855
    public Boolean renderCalculateButton { get; set; }
    
    public PL_newViewController(ApexPages.StandardController controller) {
        //HardwareTotalSC = 0;
        //AveHardrateTotalSC = 0;
       // HardwareOptyCount = 0;
        RowSpanMap = new Map<string,Integer>();
        Datetime todaydate2 = System.today();
        String Currentdate = todaydate2.format('MM/dd/yyyy');
        todaydate = Currentdate;
       
       // QuoteIds = new Set<Id>();
    

        // New objects for retrieving stored
        ProductServicesList = new List<PLA_Page_ProductServices_List__c>();
        List<PLA_Page_ConsolidatedList__c>  ProductConsolidateList = new List<PLA_Page_ConsolidatedList__c> ();
        newWrapperConsolidateList = new List<newWrapperConsolidate>();
        ProductShipsetList = new List<PLA_Page_ShipsetList__c>();
        ProductShipsetList0 = new List<PLA_Page_ShipsetList__c>();
        OpportunityList = new List<PLA_Page_Opportunity_List__c>();

        

        /* Fetching Value For PL-Approval Record based on Current rec Id*/
        system.debug('Test## controller.getId()=========='+controller.getId());
        Plapproval = [ SELECT Id,Name, ApprovalStatus__c, L2I_Approval_Deal_Opportunity__r.L2I_Opportunity_Number__c,Snapshot_Version__c,
                    L2I_Revision_Status__c,Notes__c,Last_Approved_Date__c, L2I_Approval_Deal_Opportunity__r.L2I_Oppt_Region__c,
                    L2I_Approval_Deal_Opportunity__r.Account.Name,P_L_Version__c,
                    L2I_Approval_Deal_Opportunity__r.Account.L2I_Payment_Term__c,
                    L2I_Approval_Deal_Opportunity__r.Account.Owner.Name, Has_Stored_Calculations__c
                    FROM L2I_P_L_Approval__c 
                    WHERE Id =: controller.getId() LIMIT 1];

        header = [SELECT Name, id, PL_Version__c, Ave_Hard_Rate_TotalSC__c, Program_PBT_Percent__c, Payment_Terms__c, 
                    Program_PAT_Percent__c, Approval_status__c, Account_Name__c,Owner_Name__c, Revision_status__c, Notes__c, 
                    Last_Approved_Date__c, PL_Approval__c 
                    FROM PLA_Page_Header__c 
                    WHERE Pl_Approval__c =: controller.getId() LIMIT 1];

        // Fetching Valuses from the custom objects that store the calculated data
        ProductServicesList = [SELECT Id,Row_Color_Code__c,Sort_Order__c,Name,Gross_Sales__c,Percent_Discount__c,
                                Other_Credits_Amount__c, Reduction_Gross_Sales__c,Net_Sales_Customer__c,Total_Cost__c,
                                Gross_Margin__c,Gross_Margin_Percentage__c,P_L_Approval__c 
                                FROM PLA_Page_ProductServices_List__c
                                WHERE P_L_Approval__c =: controller.getId()
                                ORDER BY Sort_Order__c];

        ProductConsolidateList = [SELECT id, Row_Color_Code__c, Row_Span_Count__c, isCol_Display__c, Name, Group_NameList__c, 
                                    IFE_Hardware0__c,IFE_Services1__c,IFE_SubTotal2__c,IFC_Hardware3__c, IFC_Services4__c,
                                    IFC_SubTotal5__c,DSS6__c,PTS7__c,Total_Program8__c,Net_Sales9__c,Sort_Order__c,
                                    Vertical_Header_Color__c,P_L_Approval__c 
                                    FROM PLA_Page_ConsolidatedList__c 
                                    WHERE P_L_Approval__c = : controller.getId()
                                    ORDER BY Sort_Order__c];

        ProductShipsetList = [SELECT Id, Name, Gross_Sales0__c, Shipset_Discount1__c,Other_Credits2__c, Total_Reduction3__c, 
                                Net_Sales4__c,Cost_Sales_per_Shipset5__c, Gross_Margin6__c, GM_Percentage7__c, Category_Net_Price8__c, 
                                Cost_per_Seat9__c, Sort_Order__c, Row_Color_Code__c, PL_Approval__c 
                                FROM PLA_Page_ShipsetList__c 
                                WHERE PL_Approval__c = : controller.getId()
                                //and Sort_Order__c > 0
                                ORDER BY Sort_Order__c];
        
        Integer pShLastRow = ProductShipsetList.size()-1; // W-004372
        Integer idx = 0; // W-004372
        for (PLA_Page_ShipsetList__c p : ProductShipsetList){
            if(p.sort_Order__c == 0){
                ProductShipsetList0.add(p);
            }
            
            // Added by Lipton for W-003855
            this.fileName = Plapproval.Name;
            this.renderCalculateButton = (Plapproval.ApprovalStatus__c != 'Approved' && Plapproval.ApprovalStatus__c != 'Pending') || !Plapproval.Has_Stored_Calculations__c;

            // W-004372 - Display 0 if SHIPSET DATA field is blank/null
            p.Gross_Sales0__c = String.isNotBlank(p.Gross_Sales0__c) ? p.Gross_Sales0__c : '0';
            p.Shipset_Discount1__c = String.isNotBlank(p.Shipset_Discount1__c) ? p.Shipset_Discount1__c : '0';
            p.Other_Credits2__c = String.isNotBlank(p.Other_Credits2__c) ? p.Other_Credits2__c : '0';
            p.Total_Reduction3__c = String.isNotBlank(p.Total_Reduction3__c) ? p.Total_Reduction3__c : '0';
            p.Net_Sales4__c = String.isNotBlank(p.Net_Sales4__c) ? p.Net_Sales4__c : '0';
            p.Cost_Sales_per_Shipset5__c = String.isNotBlank(p.Cost_Sales_per_Shipset5__c) ? p.Cost_Sales_per_Shipset5__c : '0';
            p.Gross_Margin6__c = String.isNotBlank(p.Gross_Margin6__c) ? p.Gross_Margin6__c : '0';
            // Set null to 0 except last row of GM % per Shipset, Shipset Category Net PRICE per Seat & Shipset COST per Seat
            if(idx != (pShLastRow)){
                p.GM_Percentage7__c = String.isNotBlank(p.GM_Percentage7__c) ? p.GM_Percentage7__c : '0';
                p.Category_Net_Price8__c = String.isNotBlank(p.Category_Net_Price8__c) ? p.Category_Net_Price8__c : '0';
                p.Cost_per_Seat9__c = String.isNotBlank(p.Cost_per_Seat9__c) ? p.Cost_per_Seat9__c : '0';
            }
            idx++;
        }

        OpportunityList = [SELECT id,Name, Aircraft_Type__c,Direct_Buy_Quantity__c,Leased_Aircraft_Quantity__c,
                            Optional_Aircraft_Quantity__c,Production_Retrofit__c,Delivery_Start_Date__c, Delivery_End_Date__c, 
                            Seats_per_Aircraft__c,Initial_Proposal_Date__c,Warranty_Duration__c,PL_Approval__c, PL_Quote__c, PL_Quote__r.Name
                            FROM PLA_Page_Opportunity_List__c
                            WHERE pl_approval__c = : controller.getId()];

        //Convert stng back into a list
        if(ProductConsolidateList.size() > 0){
            for(PLA_Page_ConsolidatedList__c p : ProductConsolidateList){
                // W-004372 - Display 0 if CONSOLIDATED field is blank/null
                p.IFE_Hardware0__c = String.isNotBlank(p.IFE_Hardware0__c) ? p.IFE_Hardware0__c : '0';
                p.IFE_Services1__c = String.isNotBlank(p.IFE_Services1__c) ? p.IFE_Services1__c : '0';
                p.IFE_SubTotal2__c = String.isNotBlank(p.IFE_SubTotal2__c) ? p.IFE_SubTotal2__c : '0';
                p.IFC_Hardware3__c = String.isNotBlank(p.IFC_Hardware3__c) ? p.IFC_Hardware3__c : '0';
                p.IFC_Services4__c = String.isNotBlank(p.IFC_Services4__c) ? p.IFC_Services4__c : '0';
                p.IFC_SubTotal5__c = String.isNotBlank(p.IFC_SubTotal5__c) ? p.IFC_SubTotal5__c : '0';
                p.DSS6__c = String.isNotBlank(p.DSS6__c) ? p.DSS6__c : '0';
                p.PTS7__c = String.isNotBlank(p.PTS7__c) ? p.PTS7__c : '0';
                p.Total_Program8__c = String.isNotBlank(p.Total_Program8__c) ? p.Total_Program8__c : '0';
                p.Net_Sales9__c = String.isNotBlank(p.Net_Sales9__c) ? p.Net_Sales9__c : '0';
                
                newWrapperConsolidate nwrc;
                nwrc = new newWrapperConsolidate(p);
                newWrapperConsolidateList.add(nwrc);
            }
        }
        // W-004372 - Display 0 if Header field is blank/null
        if(header != null){
            header.Ave_Hard_Rate_TotalSC__c = String.isNotBlank(header.Ave_Hard_Rate_TotalSC__c) ? header.Ave_Hard_Rate_TotalSC__c : '0';
            header.Program_PBT_Percent__c = String.isNotBlank(header.Program_PBT_Percent__c) ? header.Program_PBT_Percent__c : '0';
            header.program_PAT_Percent__c = String.isNotBlank(header.program_PAT_Percent__c) ? header.program_PAT_Percent__c : '0';
        }
        // W-004372 - Display 0 if PRODUCTS & SERVICES field is blank/null
        for(PLA_Page_ProductServices_List__c plaPPSL : ProductServicesList){
            plaPPSL.Gross_Sales__c = String.isNotBlank(plaPPSL.Gross_Sales__c) ? plaPPSL.Gross_Sales__c : '0';
            plaPPSL.Percent_Discount__c = String.isNotBlank(plaPPSL.Percent_Discount__c) ? plaPPSL.Percent_Discount__c : '0';
            plaPPSL.Other_Credits_Amount__c = String.isNotBlank(plaPPSL.Other_Credits_Amount__c) ? plaPPSL.Other_Credits_Amount__c : '0';
            plaPPSL.Reduction_Gross_Sales__c = String.isNotBlank(plaPPSL.Reduction_Gross_Sales__c) ? plaPPSL.Reduction_Gross_Sales__c : '0';
            plaPPSL.Net_Sales_Customer__c = String.isNotBlank(plaPPSL.Net_Sales_Customer__c) ? plaPPSL.Net_Sales_Customer__c : '0';
            plaPPSL.Total_Cost__c = String.isNotBlank(plaPPSL.Total_Cost__c) ? plaPPSL.Total_Cost__c : '0';
            plaPPSL.Gross_Margin__c = String.isNotBlank(plaPPSL.Gross_Margin__c) ? plaPPSL.Gross_Margin__c : '0';
            plaPPSL.Gross_Margin_Percentage__c = String.isNotBlank(plaPPSL.Gross_Margin_Percentage__c) ? plaPPSL.Gross_Margin_Percentage__c : '0';
            // W-004435 - Display tech pub/training row color as yellow
            if(plaPPSL.Name.startsWithIgnoreCase('Technical Publication') || plaPPSL.Name.startsWithIgnoreCase('Training')){
                plaPPSL.Row_Color_Code__c = 'background-color: #FFFF00';
            }
        }

        bindConsolidatedHeader();
    }

    public PageReference ViewCalculate(){
        // For opening the View Page /apex/PL_View?id={!PLApproval__c.Approval.Id}
       pageReference pg = new pageReference('/apex/PL_View?Id=' + PlApproval.id);
       return pg.setRedirect(true);
   }

    // Added by Lipton for W-003855
    public PageReference GenerateExcel(){
        return new PageReference('/apex/PL_ViewExcel?Id=' + PlApproval.id);
    }

    public void bindConsolidatedHeader(){
        headerName = new List <String>();
        headerColor = new List <String>();
        headerNetSales = new List <Decimal>();
        headerCosts = new List <Decimal>();

        List <PL_MD__c> pgMDList = [select id, Name, Pillar__c, Product_Group__c, Sort_Order__c,color__c, L2I_Migration_External_Id__c  
                from PL_MD__c Where MD_Type__c = 'Product Group' Order By Sort_Order__c];
        if (pgMDList.size() > 0){
            Integer i = 0;
            for (PL_MD__c pgMD : pgMDList) {
                Decimal netSales = 0;
                Decimal netCost = 0;
                headerNetSales.add(netSales);
                headerCosts.add(netCost);
                system.debug('Header Name '+ pgMd.Product_Group__c);
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

    public class newWrapperConsolidate{
        public PLA_Page_ConsolidatedList__c  Row {get;set;}
        public List<string>lstGN {get;set;}
        public string Name {get;set;}
        public boolean isColDisplay {get;set;}
        public string RowColorCode {get;set;}
        public integer RowSpanCount {get;set;}
        public string IFEHardware {get;set;}
        public string IFEServices {get;set;}
        public string IFESubTotal {get;set;}
        public string IFCHardware {get;set;}
        public string IFCServices {get;set;}
        public string IFCSubTotal {get;set;}
        public string DSS {get;set;}
        public string PTS {get;set;}
        public string TotalProgram {get;set;}
        public string NetSales {get;set;}
        public string VerticalHeaderColor {get;set;}
        public integer lnth {get;set;}
        public string verticalHeader {get;set;}
        
        public newWrapperConsolidate(PLA_Page_ConsolidatedList__c ConRow){
            lstGN = new List<string>();
            PLA_Page_ConsolidatedList__c Row = conRow;
            this.name = row.name;
            this.isColDisplay = row.isCol_Display__c;
            this.RowColorCode = row.Row_Color_Code__c;
            this.RowSpanCount = row.Row_Span_Count__c.intValue();
            // W-004372 - Set to 0 if field is blank/null
            this.IFEHardware = row.IFE_Hardware0__c;
            this.IFEServices = row.IFE_Services1__c;
            this.IFESubTotal = row.IFE_SubTotal2__c;
            this.IFCHardware = row.IFC_Hardware3__c;
            this.IFCServices = row.IFC_Services4__c;
            this.IFCSubTotal = row.IFC_SubTotal5__c;
            this.DSS = row.DSS6__c;
            this.PTS = row.PTS7__c;
            this.TotalProgram = row.Total_Program8__c;
            this.NetSales = row.Net_Sales9__c;
            this.VerticalHeaderColor= row.Vertical_Header_Color__c;
            
            If(ConRow.Group_NameList__c !='' && ConRow.Group_NameList__c != Null ){
                String groupName = ConRow.Group_NameList__c;
                this.lnth = lstGN.size();
                system.debug('**** groupname ' + groupName);
                lstGN = groupName.split(',');
                verticalHeader = groupName.remove(',').reverse();
            }
            
            //this.VerticalHeadercolor = 'width:1%; vertical-align: sub; background-color:'+row.Row_Color_Code__c+' ;height: '+lnth+'px;';
        }
    }
}