/**
 *      @author       Raj Rajen
 *      @date         07/28/2019
 *      @description  Helper class that wraps L2I_General_Settings__mdt
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/28/2019         Initial creation
 *      Arun                          07/30/2019         Added getPlaceholderProductCodes method
 *      Arun                          08/04/2019         Added getAccountRecordTypeNames method
 *      Andy                          08/08/2019         Added getAircraftServiceAllowedProducts method
 *      Arun                          09/19/2019         Added getOpportunityTypeForPORequired method
 *      Arun                          11/22/2019         Added getProductsForDebitNotes method
 *      Arun                          12/2/2019         Added getPmAmount method
 *      Arun                          12/2/2019         Added getOperationsAmount method
 *      Arun                          12/2/2019         Added getEquipmentAmount method
 *      Arun                          12/2/2019         Added getRackSetupFee method
 */
global class L2I_GeneralSettings {
    // IMPORTANT : Note that this approach assumes that MyDomain has been setup

    static L2I_General_Settings__mdt GS_MDT;

    static {
        GS_MDT = null;

        String mdtKey = 'Common';


        List<L2I_General_Settings__mdt> genSettings = [select Id,
                                                              DeveloperName,
                                                              Allowed_Product_Categories__c,
                                                              Disallowed_Product_Categories__c,
                                                              System_Alert_Recipients__c,
                                                              System_Alert_Sender__c,
                                                              Aircraft_Services_Allowed_Products__c,
                                                              Order_Activation_Schedule_Job_Offset_Min__c,
                                                              Enable_Order_Activation_Logging__c,
                                                              Fire_PE_on_Aircraft_Service_Activation__c,
                                                                PL_Corporate_Tax_Rate__c
                                                         from L2I_General_Settings__mdt
                                                        where DeveloperName =: mdtKey
                                                        limit 1];

        if (!genSettings.isEmpty()) {
            GS_MDT = genSettings.get(0);
            System.debug('====== Retrieved General Setting :' + GS_MDT.DeveloperName);
        }
    }

    public static L2I_General_Settings__mdt getGeneralSetting() {
        return GS_MDT;
    }

    public static Decimal getCorporateTaxRate(){
        Decimal rate = 0.00;
        if (GS_MDT == null) {
            return rate;
        } else {
            return GS_MDT.PL_Corporate_Tax_Rate__c;
        }
    }


    public static Set<String> getAllowedProducts() {
        Set<String> allowedProducts = new Set<String>();
        if (GS_MDT == null) return allowedProducts;

        List<String> rows = GS_MDT.Allowed_Product_Categories__c.split('\n');

        for (String row : rows) {
            if (row.trim().length() > 0) {
                allowedProducts.add(row.trim().toLowerCase());
            }
        }

        return allowedProducts;
    }

    public static Set<String> getDisallowedProducts() {
        Set<String> disallowedProducts = new Set<String>();
        if (GS_MDT == null) return disallowedProducts;

        List<String> rows = GS_MDT.Disallowed_Product_Categories__c.split('\n');

        for (String row : rows) {
            if (row.trim().length() > 0) {
                disallowedProducts.add(row.trim().toLowerCase());
            }
        }

        return disallowedProducts;
    }


    public static Set<String> getSystemAlertRecipients() {
        Set<String> alertRecipients = new Set<String>();
        if (GS_MDT == null) return alertRecipients;

        List<String> rows = GS_MDT.System_Alert_Recipients__c.split('\n');

        for (String row : rows) {
            if (row.trim().length() > 0) {
                alertRecipients.add(row.trim().toLowerCase());
            }
        }

        return alertRecipients;
    }

    public static String getSystemAlertSender() {
        return GS_MDT != null ? GS_MDT.System_Alert_Sender__c : null;
    }

    public static Integer getOrderActivationScheduleJobOffsetMinutes() {
        return GS_MDT != null ? Integer.valueOf(GS_MDT.Order_Activation_Schedule_Job_Offset_Min__c) : 1;
    }

    /*
    public static Set<String> getPlaceholderProductCodes() {
        Set<String> partProductCodes = new Set<String>();
        if (GS_MDT == null) return partProductCodes;
        for(String s: GS_MDT.L2I_Placeholder_Parts__c.split('\n')) {
            partProductCodes.add(s.trim().toLowerCase());
        }
        return partProductCodes;
    }

    public static Set<String> getAccountRecordTypeNames() {
        Set<String> accRecTypes = new Set<String>();
        if (GS_MDT == null) return accRecTypes;
        for(String s: GS_MDT.Excluded_AccountRecordTypes__c.split('\n')) {
            accRecTypes.add(s.trim());
        }
        return accRecTypes;
    }
*/

    public static Set<String> getAircraftServiceAllowedProducts() {
        Set<String> aircraftServiceProducts = new Set<String>();
        if (GS_MDT == null) return aircraftServiceProducts;
        for(String s: GS_MDT.Aircraft_Services_Allowed_Products__c.split('\n')) {
            aircraftServiceProducts.add(s.trim());
        }
        return aircraftServiceProducts;
    }

    public static Boolean getEnableOrderActivationLoggingFlag() {
        // if no instance of the MDT exists, we return true, otherwise whatever value is set is returned.
        return GS_MDT != null ? GS_MDT.Enable_Order_Activation_Logging__c : true;
    }

    /* CANNOT UPDATE CustomMetadataTypes via DML statements. Need to use the Metadata API for that
    public static void setEnableOrderActivationLoggingFlag(Boolean isEnabled) {
        if (GS_MDT != null) {
            GS_MDT.Enable_Order_Activation_Logging__c = isEnabled;
            update GS_MDT;
        }
    }
    */

    public static Boolean shouldFirePEonAircraftServiceActivation() {
        // if no instance of the MDT exists, we return true, otherwise whatever value is set is returned.
        return GS_MDT != null ? GS_MDT.Fire_PE_on_Aircraft_Service_Activation__c : true;
    }
    /*
    public static Set<String> getOpportunityTypeForPORequired() {
        Set<String> oppTypes = new Set<String>();
        if (GS_MDT == null) return oppTypes;
        for(String s: GS_MDT.OpportunityTypeExcluded_PORequired__c.split('\n')) {
            oppTypes.add(s.trim());
        }
        return oppTypes;
    }
    
    public static Set<String> getProductsForDebitNotes() {
        Set<String> products = new Set<String>();
        if (GS_MDT == null) return products;
        for(String s: GS_MDT.L2I_DebitNotes_CreationProducts__c.split('\n')) {
            products.add(s.trim());
        }
        return products;
    }
    
    public static Decimal getPmAmount() {
        if (GS_MDT == null) return null;
        return GS_MDT.L2I_PM_Amount__c;
    }
    
    public static Decimal getOperationsAmount() {
        if (GS_MDT == null) return null;
        return GS_MDT.L2I_Operations_Amount__c;
    }
    
    public static Decimal getEquipmentAmount() {
        if (GS_MDT == null) return null;
        return GS_MDT.L2I_Equipment_Amount__c;
    }
    
    public static Decimal getRackSetupFee() {
        if (GS_MDT == null) return null;
        return GS_MDT.L2I_Rack_SetupFee__c;
    }
*/
}