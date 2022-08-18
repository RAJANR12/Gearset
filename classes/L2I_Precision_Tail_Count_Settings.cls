public with sharing class L2I_Precision_Tail_Count_Settings {
    private static final String sampleJson = '{"WiFiProductCodes":["PA-COPSPHASE1","PA-COPSPAXWHTLST-YYYY","PA-WIFIUSG-YYYY"],"OrderStatuses":["Activated"],"ServiceActivationTypes":["Monthly","Monthly-DR"],"UsageStatuses":["Processed"],"InvoiceRunProcessingStatuses":["Pending Billing"],"ConnectedUsersProductCode":"PA-CPSPERCU-YYYY","ShadowProductCode":"PA-WIFIUSG-YYYY","GBProductCode":"PA-CPSTPAC-YYYY","InvoiceBatch":"Plane Count Products","DefaultDateOffset":-9,"EarliestSummaryStartDate":"2019-02-01"}';
    public static Boolean DEBUG = true;
    public static ConfigurationData CONFIG;
    public ConfigurationData myconfig;

    public class ConfigurationData {
        public List<String> WiFiProductCodes;
        public List<String> WJProductCodes;
        public List<String> ServiceActivationTypes;
        public List<String> OrderStatuses;
        public List<String> UsageStatuses;
        public List<String> InvoiceRunProcessingStatuses;
        public String WestJetProductCode;
        public String ConnectedUsersProductCode;
        public String ShadowProductCode;
        public String WJShadowProductCode;
        public String GBProductCode;
        public String InvoiceBatch;
        public Integer DefaultDateOffset = 0;
        public Date EarliestSummaryStartDate;
        public Date targetDate;
        public Boolean DEBUG = false;
    }
    public L2I_Precision_Tail_Count_Settings() {
        initialize();
    }

    @TestVisible
    private void initialize() {
        List<L2I_JSON_Settings__mdt> records = 
            [SELECT JSON_Representation__c FROM L2I_JSON_Settings__mdt WHERE DeveloperName = 'Precision_Tail_Count_Settings' LIMIT 1];
        myconfig = (L2I_Precision_Tail_Count_Settings.ConfigurationData) JSON.deserialize(
            (records == null || records.size() < 1) ? sampleJson : records[0].JSON_Representation__c
            , ConfigurationData.class
            );
        myconfig.targetDate = System.today() + myconfig.DefaultDateOffset;
        if (myconfig.DEBUG != null && myconfig.DEBUG) DEBUG = true;
        myconfig.DEBUG = DEBUG;
        CONFIG = myconfig;
    }
}