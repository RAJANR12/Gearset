/**
 * Created by sanjay.singhal on 10/23/20.
 *      @author       Sanjay Singhal
 *      @date         10/23/2020
 *      @description  Service class for P&L calculations and Data management
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sanjay Singhal                10/23/2020         Initial creation
 *      MS KElumba                    03/28/2022         W-004372 Set null value to 0 on P&L View
 */

global class PL_Utils {

    public static List <String> args =  new String[]{'0','number','###,###,##0'};


    //Main Method to Create P&L data when quote is finalized
    @InvocableMethod(label='Calculate P&L Summary Data')
    public static void createPLData(List <ID> QuoteId) {
        System.debug('*** Starting PL_Utils.createPLData for QuoteID :' + QuoteId + '***');

        //createPLData(quoteId[0]);
        PL_UtilsFunctions plFunctions = new PL_UtilsFunctions(QuoteId[0]);
        // if there are quote line which can be proceseed.
        if (plFunctions.myQL.size() > 0){

            if (plFunctions.psMDMap.size() > 0 && plFunctions.pgMap.size() > 0) {
                // delete Quote Product Summaries
                plFunctions.delQuotePSData(quoteId[0]);

                // Process and create Product Summaries based on Quote line.
                plFunctions.createQuotePSData();
                
                // Process for update on the junction object:
                plFunctions.updatePLSalesOpp();

                //finished processing
                System.debug('PL_Utils : Finished processing createPLData()');

            } else {
                System.debug('PL_Utils : unable to find Product Summary or Prroduct Group data');
            }
        }
    }

    public static List <PL_MD__c> getProductSummaryMasterDataList(){
        // Initialize LIst
        List<PL_MD__c> plMDList = [SELECT id, Name, Product_Group__c, Sort_Order__c, L2I_Migration_External_Id__c, Color__c
        FROM PL_MD__C Where MD_Type__c = 'Product Summary' order by Sort_Order__c];

        return plMDList;
    }

    Public Static Map <String, PL_MD__c> getProductSummaryMasterDataMap(){
        Map <String, PL_MD__c> psMDMap = new Map <String, PL_MD__c> ();
        for (PL_MD__c psMD : getProductSummaryMasterDataList()) {
            psMDMap.put(psMD.L2I_Migration_External_Id__c, psMD);
        }
        return psMDMap;
    }

    public static Map <String, PL_Product_Group__c> getProductGroupMDMap(){
        Map <String, PL_Product_Group__c> pgMDMap = new  Map <String, PL_Product_Group__c> ();
        for (PL_Product_Group__c activePG : [SELECT id, Name, Product_Group__c FROM PL_Product_Group__c Where Is_Active__c = TRUE]) {
            pgMDMap.put(activePG.Product_Group__c.trim(), activePG);
        }
        return pgMDMap;
    }

    public static Map <String, SBQQ__SolutionGroup__c> getInstallLocationMap(){
        Map <String, SBQQ__SolutionGroup__c> iLMap = new  Map <String, SBQQ__SolutionGroup__c> ();
        // Updated by Lipton for W-004443
        // Added a Translated_Value__c in the query fields
        for (SBQQ__SolutionGroup__c il : [SELECT id, Name, PL_PS__c, PL_PS__r.Name, PL_PS__r.L2I_Migration_External_Id__c, PL_PS__r.Translated_Value__c  FROM SBQQ__SolutionGroup__c Where Name != null]) {
            ilMap.put(il.Name.trim(), il);
        }
        return iLMap;
    }

    /* commented out as this is not being used.
    public static Map <String, String> GetProduct2InstallLocationMap(Set <Id> myQLProdIds, Set <String> myQLInstLocs){
        Map <String, String> pil2psMap = new Map <String, String>();

        // get Product+:+installloc 2 PS map
        if (myQLInstLocs.size() > 0 && myQLProdIds.size() > 0) {
            // get productinstallloc to product summary if quote lines have install locatitons.
            for (PL_IL2PS__c ilps : [SELECT PL_PS__c, PL_PS__r.name,  PL_PS__r.L2I_Migration_External_Id__c, Product__c, Inst_loc__r.name
                                     FROM PL_IL2PS__c Where Product__c in :myQLProdIds and Inst_loc__r.name in :myQLInstLocs]){

                pil2psMap.put(ilps.Product__c+':'+ilps.Inst_loc__r.name.trim(), ilps.PL_PS__r.L2I_Migration_External_Id__c);
            }
        }
        return pil2psMap;
    }
    */

    public static List <PL_PS__c> getQuoteProductSummaryList(Set <Id> QuoteIds) {
        List<PL_PS__c> lstPS = [
                SELECT Id, Name, Product_Summary__r.name, Cost__c, Line_Maintenance_Cost__c,  Credit__c, Discount__c,
                        Red_in_GS__c, ps_NS_to_Cust__c, ps_GM__c, Gross_Sales__c, Net_Sales__c, Product_Group__c,
                        Product_Summary__c, Quote__c, Quote__r.L2I_Aircraft_Quantity__c, Quote__r.L2I_Total_Seat_Count__c,
                        Sort_Order__c, Product_Summary__r.L2I_Migration_External_Id__c, Warranty_Cost__c,
                        Product_Group__r.PL_MD__r.L2I_Migration_External_Id__c, CAL_COGS__c
                FROM PL_PS__c WHERE Quote__c IN :QuoteIds];
        system.debug('Test## QuoteIds===='+QuoteIds);
        system.debug('Test## ===='+lstPS);
        return lstPS;
    }

    public static String getDisplayStrValue(Decimal decValue){
        String strValue = '';
        // W-004372 Display 0
        if (decValue == 0 || decValue == null) {
            return '0';
        }
        //if (decValue !=0) { // W-004372
            strValue = String.format(decValue.setScale(0).format(), args);
        //}  // W-004372
        return strValue;
    }

    public Static Decimal getDecimalValuefromList(List <Decimal> lstDec, Integer ind){
        if (lstDec[ind] != null && lstDec[ind] !=0) {
            return lstDec[ind];
        } else {
            return 0;
        }
    }
}