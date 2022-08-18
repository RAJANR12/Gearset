public with sharing class PTI_CreateProgramController {
    private Id plApprovalId;
    public static Boolean hasError = false;
    public static String hasErrorMessage;
    public static Map<Id, Opportunity> mapIFECOpp = new Map<Id, Opportunity>();
    public static List<Id> listIFECOpp = new List<Id>();
    public static Map<Id, Opportunity> mapDSSOpp = new Map<Id, Opportunity>();
    public static List<Id> listDSSOpp = new List<Id>();
    public static Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>();
    public static Map<Id, SBQQ__Quote__c> mapQuote = new Map<Id, SBQQ__Quote__c>();
    public static List<Id> listOpp = new List<Id>();
    public static List<Id> listQuote = new List<Id>();
    public static Map<Id,L2I_P_L_Sales_Opportunity__c > mapJuncSalesOpp  = new Map<Id,L2I_P_L_Sales_Opportunity__c >();
    public static Map<Id, L2I_P_L_Sales_Opportunity__c > mapJuncQuote = new Map<Id, L2I_P_L_Sales_Opportunity__c >();
    public static Map<Id,PTI_Program_Data_Header__c> insertProgramDataHeader  = new Map<Id,PTI_Program_Data_Header__c>();
    public static Map<Id,List<PTI_Program_Data_Line__c>> insertProgramDataLines  = new Map<Id,List<PTI_Program_Data_Line__c>>();
    public static List<PTI_Program_Data_Line__c> insertPDL = new List<PTI_Program_Data_Line__c>();
    public static Id firstIFECOpp = null;
    public static Set<String> earliestOnlyMethod = new Set<String>{'AIRLINE','INTERACTIVE','GAME','COPY','LANGUAGE','CITY','AIRPORT','VIDEO','BUNDLE','CITY/LANGUAGE','PORTAL','RESOLUTION','FONT','APPLICATION','REQUEST','CONTENT SERVICE PROVIDER','FLIGHT PEOPLE','SYSTEM TYPE','OS / INTERACTIVE','HOUR','PER PUBLISHER SITE','VENDOR'};
    public static Set<String> eachProgramMethod = new Set<String>{'AIRCRAFT','USER','FLEET','AIRCRAFT TYPE','SYSTEM TYPE','DATABASE','UNIT','SW BUILD','INTEGRATION'};
    public class myException extends Exception {} 
    
    // W-004411
    // Description: Used by Create Program from P&L flow
    @InvocableMethod(label= 'Create Program')
    public static void onCreateProgramFromFlow(List<Id> recordIds) {
        Map<Id,L2I_P_L_Sales_Opportunity__c > mapSalesOppJunc = new Map<Id,L2I_P_L_Sales_Opportunity__c > ([SELECT ID, L2I_P_L_Approval__c, L2I_Sales_Opportunity__c, L2I_Product_Category__c, L2I_Sales_Opportunity__r.StageName, PL_Quote_Lookup__c, L2I_Sales_Opportunity__r.L2I_Aircraft_Type__r.Available_in_Oracle_PT__c FROM L2I_P_L_Sales_Opportunity__c WHERE L2I_P_L_Approval__c =:recordIds AND L2I_Sales_Opportunity__r.Change_Request__c = FALSE  ORDER BY  L2I_Sales_Opportunity__r.L2I_First_Delivery_Date__c  ]);
           
           for(L2I_P_L_Sales_Opportunity__c  plSalesOpp : mapSalesOppJunc.values() ){
               if(plSalesOpp.L2I_Product_Category__c == 'IFEC' && plSalesOpp.L2I_Sales_Opportunity__r.StageName != 'Handoff' ){
                   hasError = true;
                   hasErrorMessage = '\nIFEC Sales Opportunities connected to the P&L record should be in Handoff stage';
               }
               
               if (plSalesOpp.L2I_Sales_Opportunity__r.L2I_Aircraft_Type__r.Available_in_Oracle_PT__c == false){
                   hasError = true;
                   hasErrorMessage = '\nAircraft Type is not available in Oracle';
               }
               
               if(plSalesOpp.L2I_Product_Category__c == 'IFEC'){
                   if(firstIFECOpp == null){
                       firstIFECOpp = plSalesOpp.L2I_Sales_Opportunity__c;
                   }
                   listIFECOpp.add(plSalesOpp.L2I_Sales_Opportunity__c);
                   listOpp.add(plSalesOpp.L2I_Sales_Opportunity__c);
                   listQuote.add(plSalesOpp.PL_Quote_Lookup__c );
                   mapJuncSalesOpp.put(plSalesOpp.L2I_Sales_Opportunity__c,plSalesOpp);
                   mapJuncQuote.put(plSalesOpp.PL_Quote_Lookup__c, plSalesOpp);
               } else if(plSalesOpp.L2I_Product_Category__c == 'DSS'){
                   listDSSOpp.add(plSalesOpp.L2I_Sales_Opportunity__c);
                   listOpp.add(plSalesOpp.L2I_Sales_Opportunity__c);
                   listQuote.add(plSalesOpp.PL_Quote_Lookup__c);
                   mapJuncSalesOpp.put(plSalesOpp.L2I_Sales_Opportunity__c,plSalesOpp);
                   mapJuncQuote.put(plSalesOpp.PL_Quote_Lookup__c, plSalesOpp);
               }
               
               
           }
           
        
        if(hasError){
            throw new myException(hasErrorMessage); 
        } else {
        
           if(!listOpp.isEmpty()){
               mapOpp = new Map<Id, Opportunity>([SELECT ID, L2I_Product_Category__c, L2I_First_Delivery_Date__c FROM Opportunity  WHERE ID IN: listOpp ORDER BY L2I_First_Delivery_Date__c ]);
           }
           
           if(!mapOpp.isEmpty()){
               for(Opportunity opp: mapOpp.values()){
                   if(opp.L2I_Product_Category__c  == 'IFEC'){
                       PTI_Program_Data_Header__c pdh = new PTI_Program_Data_Header__c();
                       pdh.PTI_P_L_Approval__c =  mapJuncSalesOpp.get(opp.Id).L2I_P_L_Approval__c;   
                       pdh.PTI_P_L_Sales_Opportunity__c = mapJuncSalesOpp.get(opp.Id).Id;  
                       pdh.Sent_To_Oracle__c = true;
                       insertProgramDataHeader.put(mapJuncSalesOpp.get(opp.Id).Id,pdh);
                   } else if(opp.L2I_Product_Category__c  == 'DSS'){
                       //Program Data Header is not created for DSS, assign to earliest IFEC delivery date/ or logic for Recurring and Usage Charge type
                   }
               }
           }
           
           //insert Program Data Header Level = Per Program
           if(!insertProgramDataHeader.isEmpty()){
               insert insertProgramDataHeader.values();
           }
           
           
           //Query related quotes of P_L_Sales_Opportunity (Junction)
           if(!listQuote.isEmpty()){
               mapQuote = new Map<Id, SBQQ__Quote__c>([SELECT ID, SBQQ__Opportunity2__r.L2I_First_Delivery_Date__c,L2I_Opportunity_Product_Category_Value__c, SBQQ__Opportunity2__r.Change_Request__c,  (SELECT ID,InstallLocationName__c, SBQQ__Group__r.SBQQ__SolutionGroup__r.Oracle_PT_Translated_Location__c, L2I_Product_Code__c, SBQQ__ProductName__c,SBQQ__UnitCost__c, SBQQ__ListPrice__c, L2I_Net_Unit_Price_Rounded__c, L2I_MonthlyPrice__c,  SBQQ__EffectiveQuantity__c, L2I_Primary_Charge_Method__c, L2I_Sub_Category_2__c, SBQQ__ProductFamily__c, L2I_CCC_Suffix__c, SBQQ__Product__r.L2I_PMO_Install_Code__c, PT_Proposed_Part_Code__c, PT_Proposed_Part_Nomenclature__c, SBQQ__Quote__r.Name  FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE ID IN: listQuote ORDER BY SBQQ__Opportunity2__r.L2I_First_Delivery_Date__c ]);
                   for(SBQQ__Quote__c quote : mapQuote.values()){
                       List<PTI_Program_Data_Line__c> listPDL = new List<PTI_Program_Data_Line__c>();
                                  if(!quote.SBQQ__LineItems__r.isEmpty()){
                                      for(SBQQ__QuoteLine__c ql: quote.SBQQ__LineItems__r){
                                      System.Debug('here1>>>'+ quote );
                                      System.Debug('here2>>> '+ ql);
                                           if((quote.L2I_Opportunity_Product_Category_Value__c == 'IFEC' && ql.InstallLocationName__c == null) || (quote.L2I_Opportunity_Product_Category_Value__c == 'DSS' && ql.SBQQ__Product__r.L2I_PMO_Install_Code__c == null)){
                                               hasError = true;
                                               hasErrorMessage = 'IFEC Opportunity and any related DSS Opportunity quote lines should have PMO Install code assigned';
                                           } else if(quote.L2I_Opportunity_Product_Category_Value__c == 'DSS'  && ql.L2I_Primary_Charge_Method__c == null && ql.L2I_Sub_Category_2__c !='MCS' ){
                                               hasError = true;
                                               hasErrorMessage =  ' \n'+ ql.L2I_Product_Code__c + ' does not have a Primary Charge Method\n';
                                           } else if(quote.L2I_Opportunity_Product_Category_Value__c == 'IFEC' ){
                                               PTI_Program_Data_Line__c pdl = new PTI_Program_Data_Line__c();
                                               pdl.PTI_Install_Location__c = ql.SBQQ__Group__r.SBQQ__SolutionGroup__r.Oracle_PT_Translated_Location__c;
                                               if( ql.L2I_Product_Code__c == 'IFE MISCELLANEOUS' ){
                                                   pdl.PTI_Part_Number__c = ql.PT_Proposed_Part_Code__c;
                                                   pdl.PTI_Part_Description__c = ql.PT_Proposed_Part_Nomenclature__c;
                                               } else {
                                                   pdl.PTI_Part_Number__c = ql.L2I_Product_Code__c;
                                                   pdl.PTI_Part_Description__c = ql.SBQQ__ProductName__c;
                                               }
                                               pdl.PTI_Quantity__c = ql.SBQQ__EffectiveQuantity__c; // Default to 1 for DSS
                                               pdl.PTI_Unit_Price__c = ql.SBQQ__ListPrice__c == null ? 0 : ql.SBQQ__ListPrice__c;
                                               pdl.PTI_Unit_Net__c = ql.L2I_Net_Unit_Price_Rounded__c;
                                               pdl.PTI_Unit_Cost__c = ql.SBQQ__UnitCost__c;
                                               pdl.PTI_Config_Number__c = 'Config1'; //Config1
                                               pdl.PTI_P_L_Program_Data_Header__c = insertProgramDataHeader.get(mapJuncQuote.get(quote.Id).Id).Id;
                                               if( insertProgramDataLines.get(pdl.PTI_P_L_Program_Data_Header__c) != null){
                                                       listPDL = insertProgramDataLines.get(pdl.PTI_P_L_Program_Data_Header__c);
                                                       listPDL.add(pdl);
                                                       insertProgramDataLines.put(pdl.PTI_P_L_Program_Data_Header__c ,listPDL);
                                               } else{
                                                       listPDL.add(pdl);
                                                       insertProgramDataLines.put(pdl.PTI_P_L_Program_Data_Header__c, listPDL);
                                               }
                                               insertPDL.add(pdl);
                                           } else if(quote.L2I_Opportunity_Product_Category_Value__c == 'DSS' ){
                                               if( ql.L2I_Sub_Category_2__c == 'MCS' || ql.L2I_Sub_Category_2__c == 'WIFI' || ql.SBQQ__ProductFamily__c == 'Advertisers/Brands'  ||  ql.L2I_CCC_Suffix__c == 'BUNDLE PRODUCT'  ){
                                                   // do nothing, line is ignored
                                                   System.Debug('here3>>>'+ ql);
                                               } else {
                                                   PTI_Program_Data_Line__c pdl = new PTI_Program_Data_Line__c();
                                                   pdl.PTI_Install_Location__c = ql.SBQQ__Product__r.L2I_PMO_Install_Code__c;
                                                   pdl.PTI_Part_Number__c = ql.L2I_Product_Code__c;
                                                   pdl.PTI_Part_Description__c = ql.SBQQ__ProductName__c;
                                                   pdl.PTI_Quantity__c = 1; // Default to 1 for DSS
                                                   pdl.PTI_Unit_Price__c = ql.L2I_MonthlyPrice__c;
                                                   pdl.PTI_Unit_Net__c = ql.L2I_MonthlyPrice__c;
                                                   pdl.PTI_Unit_Cost__c = ql.SBQQ__UnitCost__c;
                                                   pdl.PTI_Config_Number__c = 'Config1'; //Config1
                                                   pdl.PTI_Related_Quotes__c = ql.SBQQ__Quote__r.Name;
                                                   if(earliestOnlyMethod.contains(ql.L2I_Primary_Charge_Method__c.toUpperCase() ) ){
                                                       pdl.PTI_P_L_Program_Data_Header__c = insertProgramDataHeader.get(mapJuncSalesOpp.get(firstIFECOpp).Id).Id; // for One Time Charge Type                                                       
                                                   System.Debug('here4>>>'+ pdl);
                                                       insertPDL.add(pdl);
                                                   } else if(eachProgramMethod.contains(ql.L2I_Primary_Charge_Method__c.toUpperCase() )){
                                                       for(Id idOpp : listIFECOpp){
                                                           PTI_Program_Data_Line__c pdlRecurring = new PTI_Program_Data_Line__c();
                                                           pdlRecurring.PTI_Install_Location__c = ql.SBQQ__Product__r.L2I_PMO_Install_Code__c;
                                                           pdlRecurring.PTI_Part_Number__c = ql.L2I_Product_Code__c;
                                                           pdlRecurring.PTI_Part_Description__c = ql.SBQQ__ProductName__c;
                                                           pdlRecurring.PTI_Quantity__c = 1; // Default to 1 for DSS
                                                           pdlRecurring.PTI_Unit_Price__c = ql.L2I_MonthlyPrice__c;
                                                           pdlRecurring.PTI_Unit_Net__c = ql.L2I_MonthlyPrice__c;
                                                           pdlRecurring.PTI_Unit_Cost__c = ql.SBQQ__UnitCost__c;
                                                           pdlRecurring.PTI_Config_Number__c = 'Config1'; //Config1
                                                           pdlRecurring.PTI_P_L_Program_Data_Header__c = insertProgramDataHeader.get(mapJuncSalesOpp.get(idOpp).Id).Id; // for Each Program
                                                           insertPDL.add(pdlRecurring);
                                                           System.Debug('here5>>>'+ pdlRecurring);
                                                       }
                                                       
                                                       
                                                   }
                                               }
                                              
                                           }
                                      }
                                  }
                                  
                                  
                       if(!listPDL.isEmpty()){
                           insertProgramDataLines.put(mapJuncQuote.get(quote.Id).Id,listPDL);
                       }
                   }
           }
           
           if(hasError){
               delete insertProgramDataHeader.values();
                throw new myException(hasErrorMessage); 
           } else {
               //insert Program Data Line Level = Per Header
               if(!insertPDL.isEmpty()){
                   insert insertPDL;
               }
               
               //publish Program Data Header platform event
               List<PTI_Program_Data_Header__c>  pdhList = new List<PTI_Program_Data_Header__c>();
               pdhList.addall(insertProgramDataHeader.values());
               publishProgramDataHeader(pdhList);
           }
           
        }
        
    }
    
    
    public static void publishProgramDataHeader(List<PTI_Program_Data_Header__c> pdhList){
        
        //publish platform event for each program data header 
           for( PTI_Program_Data_Header__c pdh:  pdhList){
                    PTI_Program__e ptiProgram = new PTI_Program__e (Program_Header__c = pdh.Id);
            
                    Database.SaveResult sr = EventBus.publish(ptiProgram);
            
                    if (sr.isSuccess()) {
                        System.debug('====== Successfully published Program event');
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('====== Platform Event Publish Program returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                        }
                    }
               
           }
          
        
    }
    
    
   
    
    
    
}