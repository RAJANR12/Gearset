public with sharing class L2I_ConnectivityProductUtils {
    public static Boolean DEBUG = true;
    public static L2I_Billing_Model_Config config {
        public get {
            if (config == null) config = L2I_Billing_Model_Config.readConfig();
            return config;
        }
        private set;
    }

    private Map<String, Schema.SObjectField> oiFieldMap {
        private get {
            if (oiFieldMap == null) {
                oiFieldMap = Schema.sObjectType.OrderItem.fields.getMap();
            }
            return oiFieldMap;
        }
        private set;
    }
    private Map<String,Boolean> oiFieldIsUpdateable {
        private get {
            if (oiFieldIsUpdateable == null) oiFieldIsUpdateable = new Map<String,Boolean>();
            return oiFieldIsUpdateable;
        }
        private set;
    }
    private Boolean oiFieldIsUpdateable(String fieldName) {
        if (!oiFieldIsUpdateable.containsKey(fieldName))
            oiFieldIsUpdateable.put(fieldName, oiFieldMap.get(fieldName).getDescribe().isUpdateable());
        return oiFieldIsUpdateable.get(fieldName);
    }

    private Integer RecentUsageDays = 3;
    private Integer RunningPeriodDays = 8;
    private Set<Id> affectedOrderIds;

    private void initialize() {
        affectedOrderIds = new Set<Id>();
    }

    /**
     * L2I_ConnectivityProductUtils Constructor
     * @param recentUsageDays integer number of days to look back for usage activity
     * @param runningPeriodDays integer number of days to use in a daily running average
     * @return List of AFFECTED OrderItems with attributes required to calculate TB consumption
     */
    public L2I_ConnectivityProductUtils(Integer recentUsageDays, Integer runningPeriodDays) {
        initialize();
        RecentUsageDays = recentUsageDays;
        RunningPeriodDays = runningPeriodDays;
    }

    public L2I_ConnectivityProductUtils() {
        initialize();
    }

    /**
     * Total the lifetime usage quantity for L2I_Sub_Category_2__c = 'WiFi' products
     * The query is bounded by looking at the most recent usage record 'Created' or 'Last Modified' date
     * Adds orderIds to the Class variable 'affectedOrderIds'
     * @param mostRecentUsageDate: cutoff to prevent re-processsing products with no recent usage
     * @return Map of OrderItems with an updated 'L2I_Total_Usage__c'
     */
    @testVisible
    private Map<Id,OrderItem> productUsageTotals(Map<Id,OrderItem> productUsageTotals, Integer recentUsageDays) {
        Date mostRecentUsageDate = System.today() - recentUsageDays;
        for(AggregateResult productTotal : [
            SELECT blng__Order__c, blng__OrderProduct__c
                , sum(blng__Quantity__c) totalUsage
            FROM blng__Usage__c
            WHERE blng__Status__c = :config.UsageStatuses
            AND blng__OrderProduct__r.L2I_Sub_Category_2__c = 'WiFi'
            AND IsDeleted = FALSE
            GROUP BY blng__Order__c, blng__OrderProduct__c
            HAVING max(CreatedDate)   >= :mostRecentUsageDate
            OR max(LastModifiedDate)  >= :mostRecentUsageDate
        ]) {
            Id orderItemId = (Id)productTotal.get('blng__OrderProduct__c');
            OrderItem orderItem = productUsageTotals.containsKey(orderItemId)
                ? productUsageTotals.get(orderItemId) : new OrderItem();
            orderItem.Id = orderItemId;
            orderItem.L2I_Total_Usage__c = (Double) productTotal.get('totalUsage');
            productUsageTotals.put(orderItemId,orderItem);
            affectedOrderIds.add((Id) productTotal.get('blng__Order__c')); // Adds multiple OrderIds...
        }
        return productUsageTotals;
    }

    /**
     * Total the usage by product by day for the last "runningPeriodDays"
     * Divide that total by the "runningPeriodDays" to get the running average
     * The calling Flow will use that value to determine a forecasted 100% consumption day
     * Adds orderIds to the Class variable 'affectedOrderIds'
     * @param runningPeriodDays number of days (prior to today) to sum consumption
     * @return Map of OrderItems with an updated 'L2I_RunningDailyUsageAverage__c'
     */
    @testVisible
    private Map<Id,OrderItem> productDailyUsageTotals(Map<Id,OrderItem> productUsageTotals, Integer runningPeriodDays) {
        Date queryDate = System.today() - runningPeriodDays;
        for(AggregateResult productTotal : [
            SELECT blng__Order__c, blng__OrderProduct__c
                , sum(blng__Quantity__c) runningDailyTotal
            FROM blng__Usage__c
            WHERE blng__Status__c = :config.UsageStatuses
            AND blng__OrderProduct__r.L2I_Sub_Category_2__c = 'WiFi'
            AND blng__ProcessingDate__c >= :queryDate
            AND IsDeleted = FALSE
            GROUP BY blng__Order__c, blng__OrderProduct__c, blng__ProcessingDate__c
        ] ) {
            Id orderItemId = (Id)productTotal.get('blng__OrderProduct__c');
            OrderItem orderItem = productUsageTotals.containsKey(orderItemId)
                ? productUsageTotals.get(orderItemId) : new OrderItem();
            orderItem.Id = orderItemId;
            orderItem.L2I_RunningDailyUsageAverage__c = (Decimal)productTotal.get('runningDailyTotal') / runningPeriodDays;
            productUsageTotals.put(orderItemId,orderItem);
            affectedOrderIds.add((Id) productTotal.get('blng__Order__c')); // Adds multiple OrderIds...
        }
        return productUsageTotals;
    }

    /**
     * Terrabyte Model Orders
     * OrderItems for aggregating (WiFi) usage to the TB milestone billing product
     * @param NONE
     * @return List of AFFECTED Terabyte model OrderItems with attributes required to calculate TB consumption
     */
    @testVisible
    private List<OrderItem> tbOrderItems() {
        Set<Id> tbOrderIds = new Set<Id>();
        for (OrderItem oi: [SELECT OrderId FROM OrderItem WHERE L2I_Product_Code__c = :config.TBProductCode])
            tbOrderIds.add(oi.OrderId);
        return [
            SELECT Id, OrderId
                , SBQQ__Status__c
                , blng__InvoiceRunProcessingStatus__c
                , L2I_Product_Code__c
                , L2I_IncludedUsage__c
                , L2I_Total_Usage__c
                , L2I_Renewal_Notification_Percent__c
                , L2I_Renewal_Notification_Email_Sent__c
                , L2I_RunningDailyUsageAverage__c
                , SBQQ__Contract__c
                , EndDate
            FROM OrderItem
            WHERE OrderId IN :tbOrderIds
            AND (L2I_Product_Code__c IN :config.WiFiProductCodes OR L2I_Product_Code__c = :config.TBProductCode)
            AND IsDeleted = FALSE
        ];
    }

    /**
     * Terrabyte Billing Transactions query
     * @param Set of Order Item Ids 
     * @return List of OPEN Billing Transactions
     */
    @testVisible private List<blng__BillingTransaction__c> tbBillingTransactionsQuery(Set<Id> tbOrderItemIds) {
        return [
            SELECT Id
                , blng__OverrideBillingTargetDate__c
                , L2I_Order_Product_Id__c
                , L2I_Threshold_Email_Sent__c
                , L2I_Threshold_Percent__c
            FROM blng__BillingTransaction__c
            WHERE L2I_Order_Product_Id__c in :tbOrderItemIds
            AND L2I_Threshold_Email_Sent__c = false
            AND blng__Status__c = 'Pending'
            AND blng__OverrideStatus__c != 'Cancelled'
            AND blng__BillingTargetDate__c >= TODAY
            AND IsDeleted = FALSE
        ];
    }

    /**
     * Terrabyte Billing Transactions
     * @param List of TB OrderItems to check
     * @return List of OPEN Billing Transactions
     */
    public List<blng__BillingTransaction__c> tbBillingTransactions(Map<Id, OrderItem> affectedTBorderItems) {
        Set<Id> tbOrderItemIds = affectedTBorderItems.keySet();
        List<blng__BillingTransaction__c> milestoneReached = new List<blng__BillingTransaction__c>();
        for (blng__BillingTransaction__c bt: tbBillingTransactionsQuery(tbOrderItemIds)) {
            OrderItem oi = affectedTBorderItems.get(bt.L2I_Order_Product_Id__c);
            if (oi.L2I_IncludedUsage__c == 0) continue;
            if (bt.L2I_Threshold_Percent__c == null || bt.L2I_Threshold_Percent__c == 0) continue;
            Double percentConsumed = oi.L2I_Total_Usage__c / oi.L2I_IncludedUsage__c;
            if ((bt.L2I_Threshold_Percent__c / 100) <= percentConsumed) milestoneReached.add(bt);
        }
        return milestoneReached;
    }

    /**
     * Connectivity Order Items
     * DEPRECATED
     * @param NONE
     * @return List of AFFECTED OrderItems with attributes required to calculate TB consumption
     */
    @testVisible
    private List<OrderItem> affectedOrderProducts() {
        return [
            SELECT Id, OrderId
                , L2I_Product_Code__c
                , L2I_RunningDailyUsageAverage__c
                , L2I_Total_Usage__c, L2I_IncludedUsage__c
                , L2I_Next_Threshold_Percentage__c, L2I_Threshold_Step__c
                , blng__InvoiceRunProcessingStatus__c
                , SBQQ__Contract__c
                , EndDate
            FROM OrderItem
            WHERE L2I_Sub_Category_2__c = 'WiFi'
            AND (L2I_Product_Code__c IN :config.WiFiProductCodes OR L2I_Product_Code__c = :config.TBProductCode)
            AND  OrderId IN :affectedOrderIds
            AND IsDeleted = FALSE
            ORDER BY OrderId
        ];
    }

    /**
     * aggregateTBusage by creating a TB Order Item for update from all (related) TB order items
     * @param NONE
     * @return List of TB Order Items with aggregated values
     */
    @TestVisible private List<OrderItem> aggregatedTBusage() {
        Map<Id, OrderItem> tbOrderItems;
        tbOrderItems = new Map<Id, OrderItem>();    
        for (OrderItem oi: tbOrderItems()) {
            if(DEBUG){System.debug('aggregatedTBusage '+JSON.serializePretty(oi, true));}
            OrderItem newOi;
            if (tbOrderItems.containsKey(oi.OrderId)) {
                newOi = tbOrderItems.get(oi.OrderId);
            } else {
                if(DEBUG){System.debug('aggregatedTBusage new Order: '+oi.OrderId);}
                newOi = new OrderItem(
                    OrderId = oi.OrderId
                    , L2I_Total_Usage__c = 0
                    , L2I_RunningDailyUsageAverage__c = 0
                );
                tbOrderItems.put(oi.OrderId, newOi);
            }
            Map<String,Object> fields = oi.getPopulatedFieldsAsMap();
            if (oi.L2I_Product_Code__c == config.TBProductCode) {
                newOi.Id = oi.Id;
                // Copy all queried fields from the TB OrderItem
                // Skipping any fields that cannot be updated or have existing content
                for (String fieldName: fields.keySet()) {
                    if (!oiFieldIsUpdateable(fieldName)) {
                        if(DEBUG){System.debug('aggregatedTBusage skipping Field: '+fieldName);}
                        continue;
                    }
                    if (newOi.get(fieldName) == null) newOi.put(fieldName,oi.get(fieldName));
                }
                if(DEBUG){System.debug('aggregatedTBusage New OrderItem at TB'+JSON.serializePretty(newOi, true));}
            } else {
                newOi.L2I_Total_Usage__c += fields.containsKey('L2I_Total_Usage__c') ? oi.L2I_Total_Usage__c : 0;
                newOi.L2I_RunningDailyUsageAverage__c += fields.containsKey('L2I_RunningDailyUsageAverage__c') ? oi.L2I_RunningDailyUsageAverage__c : 0;
            }
        }
        return tbOrderItems.values();
    }

    //FIXME Remove after cross ompile
    // public List<OrderItem> execute() {return new List<OrderItem>();}


    /**
     * Primary method to process order product lifetime usage totals
     * @param NONE
     * @return List of AFFECTED OrderItems with attributes required to calculate TB consumption
     */
    public Map<Id, OrderItem> execute() {
        // Order Item map for Usage based products for lifetime usage rollup
        Map<Id,OrderItem> productUsageTotals = new Map<Id,OrderItem>();
        // Compute WiFi usage product lifetime totals
        productUsageTotals = productUsageTotals(productUsageTotals, RecentUsageDays);
        // Compute WiFi usage product running daily average
        productUsageTotals = productDailyUsageTotals(productUsageTotals, RunningPeriodDays);
        // Update product level summations
        update productUsageTotals.values();
        // Return map of TB OrderItems that have been aggregated
        Map<Id, OrderItem> returnMap = new Map<Id, OrderItem>();
        for (OrderItem oi: aggregatedTBusage()) {
            if (oi.L2I_Total_Usage__c > 0) returnMap.put(oi.Id, oi);
            if(DEBUG){System.debug('execute '+JSON.serializePretty(oi, true));}
        }
        return returnMap;
    }
}