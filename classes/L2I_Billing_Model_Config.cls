public with sharing class L2I_Billing_Model_Config {

    public Boolean DEBUG = false;
    public List<String> WiFiProductCodes;
    public List<String> ServiceActivationTypes;
    public List<String> OrderStatuses;
    public List<String> UsageStatuses;
    public List<String> InvoiceRunProcessingStatuses;
    public String ConnectedUsersProductCode;
    public String ShadowProductCode;
    public String GBProductCode;
    public String TBProductCode;
    public String InvoiceBatch;
    public Integer DefaultDateOffset = 0;
    public Date EarliestSummaryStartDate;
    public Date targetDate;


    public static L2I_Billing_Model_Config readConfig() {
        String developerName = 'Precision_Tail_Count_Settings';
        L2I_JSON_Settings__mdt record = [
                SELECT JSON_Representation__c 
                FROM L2I_JSON_Settings__mdt 
                WHERE DeveloperName = :developerName
            ][0];
        String jsonData = record == null ? '' : record.JSON_Representation__c;
        L2I_Billing_Model_Config config = (L2I_Billing_Model_Config) JSON.deserialize(jsonData, L2I_Billing_Model_Config.class);
        config.targetDate = System.today() + config.DefaultDateOffset;
        // if (config.DEBUG != null && config.DEBUG) DEBUG = true;
        return config;
    }
}