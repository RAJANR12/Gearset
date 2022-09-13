public with sharing class MS_TEST_CLASS1 {

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


    public static MS_TEST_CLASS1 readConfig() {
        String developerName = 'Precision_Tail_Count_Settings';
        L2I_JSON_Settings__mdt record = [
                SELECT JSON_Representation__c 
                FROM L2I_JSON_Settings__mdt 
                WHERE DeveloperName = :developerName
            ][0];
        String jsonData = record == null ? '' : record.JSON_Representation__c;
        MS_TEST_CLASS1 config = (MS_TEST_CLASS1) JSON.deserialize(jsonData, MS_TEST_CLASS1.class);
        config.targetDate = System.today() + config.DefaultDateOffset;
        // if (config.DEBUG != null && config.DEBUG) DEBUG = true;
        return config;
    }
}