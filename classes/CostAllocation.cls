public class CostAllocation{
    public List<WrapperHardWareProduct> HardWareProductList {get;set;}
    
    public List<WrapperConsolidate>  WrapperConsolidateList{get;set;}
    public List<WrapperProductServices>  WrapperProductServicesList{get;set;}
    
    public CostAllocation(){
        HardWareProductList = new List<WrapperHardWareProduct>();
        WrapperConsolidateList = new List<WrapperConsolidate>();
        WrapperProductServicesList = new List<WrapperProductServices>();
        bind_HardWareProductList();
        bind_WrapperConsolidateList();
        bind_WrapperProductServices();
    }
      
    public void bind_HardWareProductList(){
        List<PL_MD__c> lst = [Select Name,MD_Type__c,Sort_Order__c from PL_MD__c Where MD_Type__c = 'Product Summary' and Sort_Order__c <100];
        if(lst.size()>0){
            for(PL_MD__c pl : lst){
                string RowColorCode = 'Yellow'; 
                HardWareProductList.add(new WrapperHardWareProduct(pl.Name,RowColorCode));
            }
        }
        /*
        for (Integer i = 0; i < 10; i++) {
            string RowColorCode = 'Yellow'; 
            if(i==0){
                WrapperDiscountsList.add(new WrapperDiscounts('SeatEnd LRU',RowColorCode));
            }else if(i==1){
                WrapperDiscountsList.add(new WrapperDiscounts('HeadEnd LRU',RowColorCode));
            }else if(i==2){
                WrapperDiscountsList.add(new WrapperDiscounts('Harness',RowColorCode));
            }else if(i==3){
                WrapperDiscountsList.add(new WrapperDiscounts('Structures',RowColorCode));
            }else if(i==4){
                RowColorCode='Green';
                WrapperDiscountsList.add(new WrapperDiscounts('Connectivity',RowColorCode));
            }else if(i==5){
                RowColorCode='Green';
                WrapperDiscountsList.add(new WrapperDiscounts('Mobility',RowColorCode));
            }else if(i==6){
                RowColorCode='Pink';
                WrapperDiscountsList.add(new WrapperDiscounts('Net Shipset Values',RowColorCode));
            }else if(i==7){
                RowColorCode='Gray';
                WrapperDiscountsList.add(new WrapperDiscounts('Per Seat Values',RowColorCode));
            }
        }
        */
    }
    
    public class WrapperHardWareProduct{
        public string ProductSummary{get;set;}
        Public string RowColorCode{get;set;}
        
        public WrapperHardWareProduct(string ProductSummary,string RowColorCode){
            this.ProductSummary= ProductSummary;
            if(RowColorCode=='Yellow')
                this.RowColorCode ='background-color: #f9e664;';
            else if(RowColorCode=='Green')
                this.RowColorCode ='background-color: #74cc47;'; 
            else if(RowColorCode=='Pink')
                this.RowColorCode ='background-color: #fdd39482;'; 
            else if(RowColorCode=='Gray')
                this.RowColorCode ='background-color: #f1f0e8;'; 
            
        }
    }
    
    public void bind_WrapperConsolidateList(){
        List<PL_MD__c> lst = [select Name, Cost_Allocation__c, Cost_Allocation_Item__c, Sort_Order__c from PL_MD__c Where MD_Type__c = 'Cost Allocation' Order By Cost_Allocation__c];
        if(lst.size()>0){
            for(PL_MD__c pl : lst){
                string RowColorCode = 'DarkGray'; 
                WrapperConsolidateList.add(new WrapperConsolidate(pl.Name,RowColorCode));
            }
        }
        
        
        /*
        for (Integer i = 0; i < 10; i++) {
            string RowColorCode = 'Gray'; 
            if(i==0){
                WrapperConsolidateList.add(new WrapperConsolidate('Gross Sales',RowColorCode));
            }else if(i==1){
                WrapperConsolidateList.add(new WrapperConsolidate('Discount & Allowances',RowColorCode));
            }else if(i==2){
                WrapperConsolidateList.add(new WrapperConsolidate('Shipset Credits',RowColorCode));
            }else if(i==3){
                WrapperConsolidateList.add(new WrapperConsolidate('Pct (%) Discount/SS Credits',RowColorCode));
            }else if(i==4){
                RowColorCode='DarkGray';
                WrapperConsolidateList.add(new WrapperConsolidate('Total',RowColorCode));
            }else if(i==5){
                WrapperConsolidateList.add(new WrapperConsolidate('Direct Material Cost',RowColorCode));
            }else if(i==6){
                WrapperConsolidateList.add(new WrapperConsolidate('Harness Cost',RowColorCode));
            }else if(i==7){
                WrapperConsolidateList.add(new WrapperConsolidate('Structures Cost',RowColorCode));
            }
            else if(i==8){
                WrapperConsolidateList.add(new WrapperConsolidate('Other Cost of Sales',RowColorCode));
            }
            else if(i==9){
                RowColorCode='DarkGray';
                WrapperConsolidateList.add(new WrapperConsolidate('Total',RowColorCode));
            }
            
        }
        */
    }
    public class WrapperConsolidate{
         public string ProductSummary{get;set;}
        Public string RowColorCode{get;set;}
        
        public WrapperConsolidate(string ProductSummary,string RowColorCode){
            this.ProductSummary= ProductSummary;
            if(RowColorCode=='DarkGray')
                this.RowColorCode ='background-color: #8da2c1;'; 
            else if(RowColorCode=='Gray')
                this.RowColorCode ='background-color: #f1f0e8;'; 
            
        }
        
    }
    
    
    
    public void bind_WrapperProductServices(){
        
        List<PL_MD__c> lst = [Select Name,MD_Type__c,Sort_Order__c from PL_MD__c Where MD_Type__c = 'Product Summary' and Sort_Order__c >=100];
        if(lst.size()>0){
            for(PL_MD__c pl : lst){
                string RowColorCode = 'Gray'; 
                WrapperProductServicesList.add(new WrapperProductServices(pl.Name,RowColorCode));
            }
        }
        /*
        for (Integer i = 0; i < 10; i++) {
            string RowColorCode = 'Yellow'; 
            if(i==0){
                WrapperProductServicesList.add(new WrapperProductServices('Spares',RowColorCode));
            }else if(i==1){
                WrapperProductServicesList.add(new WrapperProductServices('Interactive Development',RowColorCode));
            }else if(i==2){
                WrapperProductServicesList.add(new WrapperProductServices('DSS Applications',RowColorCode));
            }else if(i==3){
                WrapperProductServicesList.add(new WrapperProductServices('IFC Applications',RowColorCode));
            }else if(i==4){
                RowColorCode='Green';
                WrapperProductServicesList.add(new WrapperProductServices('Media Services',RowColorCode));
            }else if(i==5){
                RowColorCode='Green';
                WrapperProductServicesList.add(new WrapperProductServices('Custom S/W & Other',RowColorCode));
            }else if(i==6){
                RowColorCode='Pink';
                WrapperProductServicesList.add(new WrapperProductServices('Maintenance Services',RowColorCode));
            }else if(i==7){
                RowColorCode='Gray';
                WrapperProductServicesList.add(new WrapperProductServices('Repair Shop Services',RowColorCode));
            }
        }
        */
    }
    
    public class WrapperProductServices{
         public string ProductSummary{get;set;}
        Public string RowColorCode{get;set;}
        
        public WrapperProductServices(string ProductSummary,string RowColorCode){
            this.ProductSummary= ProductSummary;
            if(RowColorCode=='DarkGray')
                this.RowColorCode ='background-color: #8da2c1;'; 
            else if(RowColorCode=='Gray')
                this.RowColorCode ='background-color: #f1f0e8;'; 
            
        }
        
    }
    
    
    
}