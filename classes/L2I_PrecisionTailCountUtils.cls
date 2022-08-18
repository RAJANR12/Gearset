/**
 *      @author       Dan Morris
 *      @date         05/18/2020
 *      @description  L2I Precision Tail Count Usage
 *
 *      This Apex class has structures and methods to facilitate enhanced billing models
 *      -  Rollup the 'Actual Usage' Field and calculate a variance amount
 *      -  Calculate the GB credit amount
 *      -  Create Usage records to record the activity
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Dan Morris                   05/18/2020         Initial scaffold
 *      Dan Morris                   05/21/2020         Major refactor into separate L2I_OrderData class
 *
 */


public class L2I_PrecisionTailCountUtils {

    private static final String sampleJson = '{"WiFiProductCodes":["PA-COPSPHASE1","PA-COPSPAXWHTLST-YYYY","PA-WIFIUSG-YYYY"],"OrderStatuses":["Activated"],"ServiceActivationTypes":["Monthly","OneTime","Yearly"],"UsageStatuses":["Processed"],"InvoiceRunProcessingStatuses":["Pending Billing"],"ConnectedUsersProductCode":"PA-CPSPERCU-YYYY","ShadowProductCode":"PA-WIFIUSG-YYYY","GBProductCode":"PA-CPSTPAC-YYYY","InvoiceBatch":"Plane Count Products","DefaultDateOffset":-9,"EarliestSummaryStartDate":"2019-02-01"}';
    public static Boolean DEBUG = true;

    public static ConfigurationData myConfig;
    private static List<String> errorMessages {
        get { if (errorMessages==null){errorMessages=new List<String>();}return errorMessages;}
        private set;
    }
    public static void queueErrorMessage(String error) {errorMessages.add(error);}
    public static List<String> getErrorMessages() {return errorMessages;}

    // Map of OrderItems with Custom Models 
    // Need dirty flag so that we can only update the changes...
    @TestVisible
    private Map<Id,OrderItem> orderItemsWithCustomModels;

    @TestVisible
    private void initialize() {
        List<L2I_JSON_Settings__mdt> records = 
            [SELECT JSON_Representation__c FROM L2I_JSON_Settings__mdt WHERE DeveloperName = 'Precision_Tail_Count_Settings' LIMIT 1];
        myConfig = (L2I_PrecisionTailCountUtils.ConfigurationData) JSON.deserialize(
            (records == null || records.size() < 1) ? sampleJson : records[0].JSON_Representation__c
            , ConfigurationData.class
            );
        myConfig.targetDate = System.today() + myConfig.DefaultDateOffset;
        if (myConfig.DEBUG != null && myConfig.DEBUG) DEBUG = true;
    }

    public L2I_PrecisionTailCountUtils() {
        initialize();
        if (DEBUG) {System.debug('This is my blank constructor');}
    }

    public L2I_PrecisionTailCountUtils(Date endDate) {
        initialize();
        if (endDate != null) myConfig.targetDate = endDate;
        if (DEBUG) {System.debug('This is my date constructor');}
    }

    public L2I_PrecisionTailCountUtils(Date endDate, Boolean debug) {
        initialize();
        if (endDate != null) myConfig.targetDate = endDate;
        DEBUG = myConfig.DEBUG = debug;
        if (DEBUG) {System.debug('This is my date/debug constructor');}
    }

    public L2I_PrecisionTailCountUtils(Date endDate, String batchName) {
        initialize();
        if (endDate != null) myConfig.targetDate = endDate;
        if (batchName!= null) myConfig.InvoiceBatch = batchName;
        DEBUG = myConfig.DEBUG = true;
        if (DEBUG) {System.debug('This is my date/batch constructor');}
    }

    @TestVisible
    private class ConfigurationData {
        List<String> WiFiProductCodes;
        List<String> WJProductCodes;
        List<String> ServiceActivationTypes;
        List<String> OrderStatuses;
        List<String> UsageStatuses;
        List<String> InvoiceRunProcessingStatuses;
        String WestJetProductCode;
        String ConnectedUsersProductCode;
        String ShadowProductCode;
        String WJShadowProductCode;
        String GBProductCode;
        String InvoiceBatch;
        Integer DefaultDateOffset = 0;
        Date EarliestSummaryStartDate;
        Date targetDate;
        Boolean DEBUG = false;
    }

    // Separate this logic to facilitate testing capability
	@TestVisible
    private void processUsage(L2I_OrderUsageData us) {
        
        // Usage data is processed by Usage Summary period across all "related" products in an Order
        // The functionality mimics the behavior you would get from consumption schedules
        // Consumption schedules are not being used due to several (current) limitations...

        L2I_OrderData orderData = L2I_OrderData.findOrderData(us);
        if (orderData == null) return;
        if (DEBUG) {System.debug('processUsages orderKey:'+orderData.getMapKey()+' this Product Code '+us.productCode);}
        
        //TODO:: Abstract shadow product source identification
        if (myConfig.WiFiProductCodes.contains((String)us.productCode)) {
            if (DEBUG) {System.debug('WiFi Processing: '+us.orderId+' :: '+us.productCode);}
            orderData.setWiFi(us,myConfig.ShadowProductCode == us.productCode); //"WiFi" product
        } else if (myConfig.ConnectedUsersProductCode == us.productCode) {
            if (DEBUG) {System.debug('Connected User Processing: '+us.orderId+' :: '+us.productCode);}
            orderData.setConnectedUser(us);
        } else {
            if (DEBUG) {System.debug('Service Processing: '+us.orderId+' :: '+us.productCode);}
            if (us.actualQuantity == null || us.actualQuantity == 0) {
                System.debug(logginglevel.ERROR,'*** L2I_PrecisionTailCountUtils.processUsage - L2I_Actual_Quantity__c cannot be NULL: '+us.orderId+' :: '+us.productCode+' :: '+us.usageSummaryId);
                return;  // Can't affect precision unless this field is populated
            }
            orderData.setPlaneCount(us, (us.productCode == myConfig.GBProductCode), (us.productCode == myConfig.WestJetProductCode)); 
        }
        //if (DEBUG) {System.debug('MinGB Processing: '+us.orderId+' :: '+us.productCode);}
        //orderData.setMinGBPerTail(us); // Added by Arun to set the Minimum GB Per Tail value
   }
    
	@TestVisible
    private void processUsages() {
        // Loop through parsed query result
        for(AggregateResult usageSummary : productUsageList()) {
            processUsage(L2I_OrderUsageData.parse(usageSummary));
        }
    }

    //  Make sure that the shadow order products are NOT collected in this query!!!
    //TODO:: Honor the blng__OverrideSummaryEndDate__c. Make sure that related order products have the same override!!!
    @TestVisible
    private List<AggregateResult> productUsageList() {
        System.debug('L2I_PrecisionTailCountUtils:productUsageList: TargetDate: '+myConfig.targetDate+' Earliest Summary Start: '+myConfig.EarliestSummaryStartDate);
        System.debug('L2I_PrecisionTailCountUtils:productUsageList: blng__Status__c IN '+myConfig.UsageStatuses);
        System.debug('L2I_PrecisionTailCountUtils:productUsageList: blng__OrderProduct__r.L2I_Service_Activation_Type__c IN '+myConfig.ServiceActivationTypes);
        System.debug('L2I_PrecisionTailCountUtils:productUsageList: blng__OrderProduct__r.L2I_Product_Code__c IN '+myConfig.WiFiProductCodes);
        System.debug('L2I_PrecisionTailCountUtils:productUsageList: blng__UsageSummary__r.blng__InvoiceRunProcessingStatus__c IN '+myConfig.InvoiceRunProcessingStatuses);
        List<AggregateResult> queryResults = [
            SELECT blng__Order__c, blng__OrderProduct__c, blng__UsageSummary__c
                , blng__UsageSummary__r.blng__SummaryStartDate__c
                , blng__UsageSummary__r.blng__SummaryEndDate__c
                , blng__UsageSummary__r.blng__MatchingId__c
                , blng__OrderProduct__r.L2I_Has_Rate_Schedule__c
                , blng__OrderProduct__r.L2I_Model_Type__c
                , MAX(blng__UsageSummary__r.blng__UnitPrice__c) unitPrice
                , MAX(blng__UsageSummary__r.blng__Subtotal__c) subTotal
                , MAX(blng__OrderProduct__r.L2I_Product_Code__c) productCode
                , MAX(blng__OrderProduct__r.L2I_IncludedUsage__c) includedUsage
                , MAX(blng__OrderProduct__r.L2I_Megabyte_Definition__c) L2I_Megabyte_Definition__c
                , MAX(blng__OrderProduct__r.L2I_Minimum_GB_Per_Tail__c) L2I_Minimum_GB_Per_Tail__c
                , SUM(blng__Quantity__c) totalQuantity
                , SUM(L2I_Actual_Quantity__c) totalActualQuantity
                , SUM(L2I_Active_Flight_Count__c) totalActiveFlightCount
            FROM blng__Usage__c
            WHERE blng__Status__c IN :myConfig.UsageStatuses
            AND blng__Order__r.Status in :myConfig.OrderStatuses
            AND (
                blng__OrderProduct__r.L2I_Service_Activation_Type__c IN :myConfig.ServiceActivationTypes
                OR blng__OrderProduct__r.L2I_Product_Code__c IN :myConfig.WiFiProductCodes
                OR blng__OrderProduct__r.L2I_Product_Code__c = :myConfig.ConnectedUsersProductCode
            )
            AND blng__UsageSummary__r.L2I_True_Up_Created__c = FALSE
            AND blng__OrderProduct__r.L2I_Source_OrderProduct__c = NULL
            AND blng__UsageSummary__r.blng__InvoiceRunProcessingStatus__c IN :myConfig.InvoiceRunProcessingStatuses
            AND blng__UsageSummary__r.blng__SummaryEndDate__c < :myConfig.targetDate
            AND blng__UsageSummary__r.blng__SummaryStartDate__c >= :myConfig.EarliestSummaryStartDate
            AND IsDeleted = FALSE
            GROUP BY blng__Order__c, blng__OrderProduct__c, blng__UsageSummary__c
                , blng__UsageSummary__r.blng__SummaryStartDate__c
                , blng__UsageSummary__r.blng__SummaryEndDate__c
                , blng__UsageSummary__r.blng__MatchingId__c
                , blng__OrderProduct__r.L2I_Has_Rate_Schedule__c
                , blng__OrderProduct__r.L2I_Model_Type__c
            HAVING SUM(L2I_Actual_Quantity__c) > 0 OR SUM(blng__Quantity__c) > 0
        ];
        System.debug('L2I_PrecisionTailCountUtils:productUsageList: Query result line count: '+queryResults.size());
        return queryResults;
    }

	@TestVisible
    private void processBillingModels() {
        // This will create Usage credits for GB Orders
        for ( L2I_OrderData od : L2I_OrderData.getBillingModelOrders()) {
            if (DEBUG) {System.debug('L2I_PrecisionTailCountUtils:processBillingModels: ' + od.getMapKey());}

            if (od.isLegacyGB()) {
                od.createLegacyGBcredit();
                if (DEBUG) {System.debug('L2I_PrecisionTailCountUtils:processBillingModels: Legacy GB  '+od.matchingId);}
            } else if (od.isAverageGBwithOverage()) {
                if (DEBUG) {System.debug('L2I_PrecisionTailCountUtils:processBillingModels: Average GB w/Overage '+od.matchingId+' ');}
                // Check for a custom Model - no model means we need to create a model and a shadow order
                if (!od.isCustomModel()) od.createAverageGBwithOverageModel();
                // We call getTier even though this is a single tier model to build the usage summary
                L2I_Custom_Model__mdt tier = od.getTier(1);
                od.aggregateWiFiUsage();
                od.createAverageGBcredit(tier.Id);
            } else if (od.isWJModel()) {
                System.debug('L2I_PrecisionTailCountUtils:WJModel processing'); // Arun
                // get the JSON Model tier for total MB to bill
                L2I_Custom_Model__mdt tier = od.getTier(od.getTotalWiFiQuantity() - od.includedUsageQuantity());
                if (tier != null) {
                    od.aggregateWiFiUsage();
                    od.createUsageForWJ(tier.Id);
                } else {
                    System.debug(logginglevel.ERROR, 'L2I_PrecisionTailCountUtils:processBillingModels: Unable to identify WestJet Custom Model TIER');
                }
            } else if (od.isConnectedUser()) {
                // AA model
                if (od.getTier(od.averageUsersPerFlight()) != null) {
                    od.processConnectedUserUsage();
                    od.closeWiFiUsageSummary(myConfig.ShadowProductCode);
                } else {
                    System.debug(logginglevel.ERROR, 'L2I_PrecisionTailCountUtils:processBillingModels: Unable to identify Connected User Custom Model TIER');
                }
            } else {
                if (od.isTieredGB()) { 
                    //  Tiered GB
                    //FIXME: HARDCODED TIER FLOOR
                    //Double UALFLOOR = 150;
                    Double UALFLOOR = od.getMinGBPerTail(); // Added by Arun
                    // System.debug('UALFLOOR: '+UALFLOOR);
                    // System.debug('averageGBperTail() A: '+od.averageGBperTail());
                    Double avgGBperTail = od.averageGBperTail() < UALFLOOR ? UALFLOOR : od.averageGBperTail();
                    if (od.getTier(avgGBperTail) != null) {
                        od.aggregateWiFiUsage();
                        od.applyFloorQuantity(UALFLOOR);
                    } else {
                        System.debug(logginglevel.ERROR, 'L2I_PrecisionTailCountUtils:processBillingModels: Unable to identify Average GB Custom Model TIER');
                    }
                } else {
                    System.debug(logginglevel.ERROR, 'L2I_PrecisionTailCountUtils:processBillingModels: Unable to select a billing model removing order: '+od.orderId);
                    L2I_OrderData.deleteAffectedOrderId(od.orderId);
                }
            }
        }
    }

    // This logic relies on Orders split by L2I_Sub_Category_2__c to link Order Products
	@TestVisible
    private void buildOrderData() {
        if (DEBUG) {System.debug(myConfig);}

        // Collect all Orders by Usage Period to be billed
        // Identifies order products by usages within the usage summary period
        // Identify and mark Orders that require extra billing processing
        processUsages();

        // Walk through each order that we collected and set the order product to be used for the shadow process
        //FIXME
        L2I_OrderData.assignWJSource(myConfig.ShadowProductCode, myConfig.WJShadowProductCode);

        // FIXME:: After processing all usage order products, validate order can be processed
        // and all order products have been accounted for.

        // Grab all of the Orders that have custom models
        L2I_OrderData.processJSONmodels();

        //Run through the Orders for custom billing
        processBillingModels();

    }

    public List<L2I_OrderData> getAllOrders() {
        buildOrderData();
        return L2I_OrderData.getAllOrders();
    }
    public List<L2I_OrderData> getBillingModelOrders() {
        buildOrderData();
        return L2I_OrderData.getBillingModelOrders();
    }

    public String getOrderDataAsJson() {
        buildOrderData();
        return JSON.serializePretty(L2I_OrderData.getAllOrders());
    }

    // This logic relies on Orders split by L2I_Sub_Category_2__c to link Order Products
    public void execute() {

        buildOrderData();

        //Create (shadow) Order Products and update JSON
        L2I_OrderData.executeUpdates();

        System.debug('L2I_PrecisionTailCountUtils.execute usageSummary updates '+L2I_OrderData.usageSummaries.size());
        System.debug('L2I_PrecisionTailCountUtils.execute usage count '+L2I_OrderData.trueUpUsages.size());
        System.debug('L2I_PrecisionTailCountUtils.execute Error Messages '+L2I_PrecisionTailCountUtils.getErrorMessages().size());
        for (String err: L2I_PrecisionTailCountUtils.getErrorMessages()) {
            System.debug('L2I_PrecisionTailCountUtils.execute Error Messages '+err);
        }
    }
  
}