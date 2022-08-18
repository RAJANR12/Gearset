public with sharing class L2I_OrderData {

    private static Boolean DEBUG = true;

    /**
     * @description: static map to track each class instantiation - Order to be billed by period.
     * Note: Map Key is the Order Id and the Usage Summary End Date
     * Note: The object collects related orderitems for custom processing 
     */
    private static Map<String, L2I_OrderData> orderDataMap;

    @TestVisible
    private static Map<Id,Order> orderMap {
        get {
            if (orderMap==null) {
                orderMap = new Map<Id,Order>(L2I_CustomModelUtils.getOrders(getAffectedOrderIds()));
                // Walk the map and add the shadow order into the source order
                for (Order o: orderMap.values()) {
                    if (o.L2I_SourceOrder_Id__c != null) {
                        if (orderMap.containsKey(o.L2I_SourceOrder_Id__c)) {
                            orderMap.get(o.L2I_SourceOrder_Id__c).L2I_Shadow_Order__r = o;
                        } else {
                            System.debug(logginglevel.ERROR,'L2I_OrderData.orderMap: Could not locate source order in map');
                        }
                    }
                }
            }
            return orderMap;
        }
        private set;
    }
    public static Order getSourceOrder(Id orderId) {
        if (orderMap.containsKey(orderId)) {
            Order o = orderMap.get(orderId);
            return o.L2I_SourceOrder_Id__c == null ? o : null;
        }
        return null;
    }
    //Using the source order, retrieve the existing shadow order or create a new one
    public static Order getShadowOrder(Id orderId) {
        if (orderMap.containsKey(orderId)) {
            Order o = orderMap.get(orderId);
            if (orderMap.containsKey(o.L2i_Shadow_Order__c)) {
                if (DEBUG) {System.debug('L2I_OrderData.getShadowOrder: retrieved '+orderMap.get(o.L2i_Shadow_Order__c));}
                setAffectedOrderId(o.L2I_Shadow_Order__c);
                return orderMap.get(o.L2i_Shadow_Order__c);
            }
            Map<String, Object> orderAttributes = new Map<String, Object>( o.getPopulatedFieldsAsMap() );
            if (!orderAttributes.containsKey('L2I_Shadow_Order__r')) {
                o.L2I_Shadow_Order__r = L2I_CustomModelUtils.createShadowOrder(o);
                if (DEBUG) {System.debug('L2I_OrderData.getShadowOrder: Creating '+o.L2I_Shadow_Order__r);}
            }
            return o.L2I_Shadow_Order__r;
        }
        System.debug(logginglevel.ERROR,'L2I_OrderData.getShadowOrder: Cannot locate source order '+orderId);
        return null;
    }
    /**
     * @description Self filling map that indentifies existing, relevant shadow products
     * @description Map Key is the matching ID (Tier ID)
     */
    @TestVisible
    private static Map<Id,OrderItem> shadowOrderItems {
        get {
            if (shadowOrderItems == null) {
                shadowOrderItems = new Map<Id,OrderItem>();
                for (OrderItem oi: [
                    SELECT Id, OrderId, L2I_blng_MatchingId__c 
                    FROM OrderItem
                    WHERE L2I_Source_OrderProduct__c IN :sourceOrderItemIdMap.values()
                ]) {
                    setAffectedOrderId(oi.OrderId);
                    shadowOrderItems.put(oi.L2I_blng_MatchingId__c, oi);
                }
                if (DEBUG) {System.debug('L2I_OrderData.shadowOrderItems: records '+shadowOrderItems.size());}
            }
            return shadowOrderItems;
        }
        private set;
    }

    // Map of OrderItems with Custom Models 
    @TestVisible
    private static Map<Id,OrderItem> orderItemsWithCustomModels {
        get {
            if (orderItemsWithCustomModels == null) {
                orderItemsWithCustomModels = new Map<Id,OrderItem>([
                    SELECT Id, OrderId, L2I_Rate_Schedule_JSON__c 
                    FROM OrderItem
                    WHERE isDeleted = false AND OrderId IN :L2I_OrderData.getAffectedOrderIds()
                    AND L2I_Has_Rate_Schedule__c = true
                ]);
                if (DEBUG) {System.debug('L2I_OrderData.orderItemsWithCustomModels: records '+orderItemsWithCustomModels.size());}
            }
            return orderItemsWithCustomModels;
        }
        private set;
    }
    // Custom Model Map - unique per OrderItem
    private static Map<Id,List<L2I_Custom_Model__mdt>> customModels{
        get {
            if (customModels == null) customModels = new Map<Id,List<L2I_Custom_Model__mdt>>();
            return customModels;
        }
        private set;
    }

    // accumulate orderItem Ids for SOQL bulkify
    // Map of the OrderID and its Source OrderItem
    @TestVisible
    private static Map<Id,Id> sourceOrderItemIdMap {
        get {
            if (sourceOrderItemIdMap == null) sourceOrderItemIdMap = new Map<Id,Id>();
            return sourceOrderItemIdMap;
        }
        private set;
    }

    // Order Items used for shadowing
    // Id is OrderItem Id
    private static Map<Id, OrderItem> sourceOrderProductMap{
        get {
            if (sourceOrderProductMap == null) {
                sourceOrderProductMap = new Map<Id, OrderItem>(L2I_CustomModelUtils.getSourceOrderItems(sourceOrderItemIdMap.values()));
            }
            return sourceOrderProductMap;
        }
        private set;
    }
    /**
     * @description Set of Ids of the Orders that are to be billed
     */
    private static Set<Id> affectedOrderIds{
        get {
            if (affectedOrderIds == null) affectedOrderIds = new Set<Id>();
            return affectedOrderIds;
        }
        private set;
    }
    public static Set<Id> getAffectedOrderIds() {return affectedOrderIds;}
    public static void setAffectedOrderId(Id orderId) {
        if (DEBUG) {System.debug('L2I_OrderData.setAffectedOrderId: ID: '+orderId+' :: '+JSON.serializePretty(affectedOrderIds, true));}
        affectedOrderIds.add(orderId);
    }
    public static void deleteAffectedOrderId(Id orderId) {
        if (DEBUG) {System.debug('L2I_OrderData.deleteAffectedOrderId: ID: '+orderId+' :: '+JSON.serializePretty(affectedOrderIds, true));}
        affectedOrderIds.remove(orderId);
    }

    // Usage Summary pre-rated value mods due to quantity rounding
    @TestVisible
    public static List<blng__UsageSummary__c> usageSummaries{
        get {
            if (usageSummaries == null) usageSummaries = new List<blng__UsageSummary__c>();
            return usageSummaries;
        }
        private set;
    }

    // Usages to be applied:
    //   Included usage credits (Legacy GB)
    //   Force update to the Pre-rated Usage Summaries
    //   Shadow product summary usages
    @TestVisible
    public static List<blng__Usage__c> trueUpUsages{
        get {
            if (trueUpUsages == null) trueUpUsages = new List<blng__Usage__c>();
            return trueUpUsages;
        }
        private set;
    }

    public Id orderId {public get; private set;}
    private Date summaryStartDate;
    private Date summaryEndDate;
    private Datetime endDateTime;
    private Boolean hasWifi;
    private Boolean hasGB;
    private Boolean hasConnectedUser;
    private Boolean hasWJModel; 
    private Boolean hasCustomModel;
    private Boolean isAverageGBModel;
    private Boolean isTieredGBModel;
    private L2I_OrderUsageData planeCountUsage;
    private L2I_OrderUsageData sourceProductUsage;
    private Map<String,L2I_OrderUsageData> WiFiUsage;
    private Double  totalActualQuantity;
//    private Double  totalWiFiQuantity;
    private Double  includedUsagePerTail;
    private Double  bandwidthMultiplier;
    public String  matchingId  {public get; private set;}
    private OrderItem shadowProductSource; // Quoted product that will be shadowed
    private OrderItem shadowProduct;
    private L2I_Custom_Model__mdt selectedTier;
    private Double  minGBPerTail; // Added by Arun
//dan    private Double  totalWJQuantity; // Added by Arun
    //private Map<String,L2I_OrderUsageData> WJUsage; // Added by Arun
    
    public L2I_OrderData(Id orderId, Date startDate, Date endDate) {
        this.hasGB = false;
        this.hasConnectedUser = false;
        this.hasWifi = false;
        this.hasWJModel = false;
        this.hasCustomModel = false;
        this.isAverageGBModel = false;
        this.isTieredGBModel = false;
        this.totalActualQuantity = 0;
//        this.totalWiFiQuantity = 0;
        this.includedUsagePerTail = 0;
        this.bandwidthMultiplier = 1000; //default, but need from OrderItem
        this.orderId = orderId;
        this.summaryStartDate = startDate;
        this.summaryEndDate = endDate;
        this.endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day());
        this.minGBPerTail = 0; // Added by Arun // Do we want this to be null to know that it is not needed?
//        this.totalWJQuantity = 0; // Added by Arun
    }

    public static List<L2I_OrderData> getAllOrders() {
        return orderDataMap == null ? new List<L2I_OrderData>() : orderDataMap.values();
    }

    public static List<L2I_OrderData> getBillingModelOrders() {
        List<L2I_OrderData> orders = new List<L2I_OrderData>();
        for ( L2I_OrderData od : L2I_OrderData.getAllOrders()) {
            if (!(od.isAverageGBwithOverage() || od.isCustomModel())) continue;
            if (!(od.hasPlaneCountProduct() || od.hasSourceProduct())) {
                System.debug(logginglevel.ERROR, 'L2I_OrderData:getBillingModelOrders: Incomplete Order Data for '+od.getMapKey()+' removing ORDER');
                L2I_OrderData.deleteAffectedOrderId(od.orderId);
                continue;
            }
            orders.add(od);
        }
        return orders;
    }

    public static L2I_OrderData findOrderData(L2I_OrderUsageData us) {
        if (us == null)
            return null;
        if (orderDataMap == null)
            orderDataMap = new Map<String, L2I_OrderData>();
        if (!orderDataMap.containsKey(us.mapKey()))
            orderDataMap.put(us.mapKey(), new L2I_OrderData(us.orderId, us.summaryStartDate, us.summaryEndDate));
        return orderDataMap.get(us.mapKey());
    }

    /**
     * @description: method to create a Custom (Billing) Model 
     * Necessary for the Average GB product with aggregation
     * Use the source wifi product to get pricing information
     * Store the custom model on the plane count product as per convention
     */
    public void createAverageGBwithOverageModel() {
        selectedTier = singleTier(unitPrice());
        //Serialize the tier and queue update to the plane count product...
        List<L2I_Custom_Model__mdt> tiers = new List<L2I_Custom_Model__mdt>{selectedTier};
        String fieldJson = JSON.serialize(tiers, true);
        OrderItem sobj = new OrderItem(
            Id = planeCountProductId()
            , L2I_Has_Rate_Schedule__c = true
            , L2I_Rate_Schedule_JSON__c = fieldJson
        );
        L2I_CustomModelUtils.queueUpdateRecord(sobj);
        // Now let's get a shadow order/product
        L2I_OrderData.processJSONmodel(planeCountProductId(),orderId,fieldJson);
//        L2I_OrderData.processJSONmodel(sourceProductId(),sourceProductUsage.orderId,fieldJson);
    }

    private L2I_Custom_Model__mdt singleTier(Double unitPrice) {
        Schema.DescribeSObjectResult customModelMdtDescribe = L2I_Custom_Model__mdt.sObjectType.getDescribe();
        String keyPrefix = customModelMdtDescribe.getKeyPrefix();
        Id fakeId = L2I_ApexUtils.create18CharFakeId(keyPrefix);
        selectedTier = new L2I_Custom_Model__mdt(Id = fakeId, L2I_Lower_Bound__c = 1, L2I_Upper_Bound__c = null, L2I_Per_Unit_Price__c = unitPrice);
        return selectedTier;
    }

    private static void processJSONmodel(Id orderItemId, Id orderId, String customModel) {
        Id sourceOrderItemId = sourceOrderItemIdMap.get(orderId);
        if (sourceOrderItemId == null) {
            System.debug('L2I_OrderData.parseJSONmodels: No Source Item for Order: '+(orderId));
            return;
        }
        
        OrderItem theSourceOrderItem = sourceOrderProductMap.get(sourceOrderItemId);
//        if (DEBUG) {System.debug('L2I_OrderData.parseJSONmodels: orderItem'+JSON.serializePretty(oi, true));}
        List<L2I_Custom_Model__mdt> tiers = (List<L2I_Custom_Model__mdt>)JSON.deserialize(customModel, List<L2I_Custom_Model__mdt>.class);
        if (DEBUG) {System.debug('L2I_OrderData.parseJSONmodels:'+JSON.serializePretty(tiers, true));}
        // Make sure each tier has a shadow product
        for (L2I_Custom_Model__mdt tier: tiers) {
            if (shadowOrderItems.containsKey(tier.Id))  continue;
            // We get the entire object less ID. But nothing to do with it until we match it to a tier
            // FIXME   -  we can double pass it
            OrderItem tierShadowProduct = createShadowOrderProduct(theSourceOrderItem, tier);
            shadowOrderItems.put(tier.Id, tierShadowProduct);
            if (DEBUG) {System.debug('L2I_OrderData.parseJSONmodels - Added OrderItem:'+JSON.serializePretty(tierShadowProduct, true));}
        }
        customModels.put(orderItemId,tiers); // Store models with plane count orderitem id
    }

    /**
     * @description: method to initialize custom model based orders 
     *   Parse the rating tiers
     *   Ensure each tier has a shadow product (under a shadow order)
     *
     */
    public static void processJSONmodels() {
        for ( OrderItem oi: orderItemsWithCustomModels.values()) {
            processJSONmodel(oi.Id, oi.OrderId, oi.L2I_Rate_Schedule_JSON__c);
        }
    }
    
    public static void assignWJSource(String ShadowProductCode, String WJShadowProductCode) {   
        for ( L2I_OrderData od : L2I_OrderData.getAllOrders()) {
            if (od.isWJModel() && od.WiFiUsage != null) {
                System.debug('Assigning Source order: WJModel '+od.WiFiUsage);
                for (String key: od.WiFiUsage.keySet()) {
                    // Remove the WiFi product, it is excluded
                    if (ShadowProductCode == key) od.WiFiUsage.remove(key);
                    // Set the Shadow Product to the WJShadowProductCode
                    if (WJShadowProductCode == key) od.setSourceProduct(od.WiFiUsage.get(key));
                }
            } 
        }
    }

    // this method will build a shadow OrderItem if required,
    private static OrderItem createShadowOrderProduct(OrderItem sourceOrderItem, L2I_Custom_Model__mdt tier) {
        if (DEBUG){System.debug('L2I_OrderData.createShadowOrderProduct Source: '+sourceOrderItem);}
        Order shadowOrder = getShadowOrder(sourceOrderItem.OrderId);
        //FIXME there should not be a way to have a null shadowOrder...
        OrderItem newShadowProduct = L2I_CustomModelUtils.initializeShadowOrderItemFromTier(shadowOrder, sourceOrderItem, tier);        
        if (DEBUG){System.debug('L2I_OrderData.createShadowOrderProduct Object: '+newShadowProduct);}
        return newShadowProduct;
    }

    public static void queueUsageSummaryUpdate(blng__UsageSummary__c record) {
        if (DEBUG){System.debug('L2I_OrderData.queueUsageSummaryUpdate Object: '+record);}
        usageSummaries.add(record);
    }

    public void queueUsageUpdate(blng__Usage__c record) {
        if (DEBUG){System.debug('L2I_OrderData.queueUsageUpdate Object: '+record);}
        trueUpUsages.add(record);
    }

    public void setSourceProduct(L2I_OrderUsageData ud) {
        if (DEBUG) {System.debug('L2I_OrderData.setSourceProduct:Source Product identified: '+ud);}
        sourceProductUsage = ud;
        sourceOrderItemIdMap.put(ud.orderId, ud.orderItemId);
        //if (DEBUG){System.debug('L2I_OrderData.setSourceProduct sourceOrderItemIdMap: '+sourceOrderItemIdMap);}
    }

    public void setConnectedUser(L2I_OrderUsageData ud) {
        hasConnectedUser = true;
        hasCustomModel = ud.hasRateSchedule;
        setSourceProduct(ud);  // the source product for this model is this connected user
    }

    public void setWiFi(L2I_OrderUsageData ud,Boolean isSource){
        if (WiFiUsage == null) {
            WiFiUsage = new Map<String,L2I_OrderUsageData>();
        }
        WiFiUsage.put(ud.productCode,ud);
//        totalWiFiQuantity += ud.quantity;
        // We store all Wifi products, but we cannot process them unless we have a source level product...
        if (isSource && ! isConnectedUser()) {
            // This is the key to process wifi usage.
            // FIXME TODO change the methodology to mark the aggregation (source) product. This will allow usage to be processed on the associated records even if there is not any usage on the aggregation product.
            hasWifi = true;
            setSourceProduct(ud);  // We will have to identify the correct WiFi Product to source after reading all products
            // System.debug('MinGB Processing A: '+ud.orderId+' :: '+ud.productCode); // Added by Arun
            // setMinGBPerTail(ud); // Added by Arun to set the Minimum GB Per Tail value
        }
    }

    public void setPlaneCount(L2I_OrderUsageData ud, Boolean hasGB, Boolean hasWJModel) {
        if (DEBUG) {System.debug('L2I_OrderData.setPlaneCount:MapKey: '+getMapKey()+' Product: '+ud.productCode);}
        this.planeCountUsage = ud;
        this.totalActualQuantity = ud.actualQuantity;
        this.hasWJModel = hasWJModel;
        this.hasGB = hasGB;
        this.hasCustomModel = ud.hasRateSchedule;
        // Field OrderItem.L2I_Model_Type__c is null or 'Average GB per Tail with Overage'
        // It is horrible to hardcode a picklist value, but here we are...
        this.isAverageGBModel = hasGB && ud.modelType == 'Average GB per Tail with Overage';
        this.isTieredGBModel = hasGB && ud.modelType == 'Average GB per Tail - Tiered';
        if (ud.bandwidthMultiplier != null) this.bandwidthMultiplier = ud.bandwidthMultiplier;
        if (ud.minGBPerTail != null) this.minGBPerTail = ud.minGBPerTail;
        if (ud.includedUsagePerTail != null) this.includedUsagePerTail = ud.includedUsagePerTail;
        L2I_OrderData.setAffectedOrderId(this.orderId);
        adjustUsageSummary(ud);
    }

    /**
     * @description Method to 'correct' rounding errors on a usage summary
     * The daily active aircraft mediation process uses a days in the month fraction
     * to count the number of active planes per month. The mediation process stores a 9 decimal
     * quantity value in the L2I_Actual_Quantity__c field. This method will update the usage summary
     * (if necessary) and will create a zero quantity usage record to force the rating process
     * (???Do we need to force the batch rating process???)
     */
    private void adjustUsageSummary(L2I_OrderUsageData ud) {
        Double preRatedAmount = usageRoundingAdjustment(ud);
        if (math.abs(preRatedAmount) < .01) {
            // Don't need an offset, but we do need to mark the usage summary as having been processed
            queueUsageSummaryUpdate(new blng__UsageSummary__c(
                Id = ud.usageSummaryId
                , L2I_Actual_Quantity__c = ud.actualQuantity
                , L2I_True_Up_Created__c = true
            ));
        } else {
            // Create an offset to correct rounding errors in fractional daily plane counts
            queueUsageSummaryUpdate(new blng__UsageSummary__c(
                Id = ud.usageSummaryId
                , L2I_Actual_Quantity__c = ud.actualQuantity
                , blng__PreratedAmount__c = preRatedAmount
                , L2I_True_Up_Created__c = true
            ));
            // Apply an zero quantity usage to force a recalculation
            queueUsageUpdate(L2I_CustomModelUtils.usageRecord(
                ud.matchingId, endDateTime, endDateTime, 0, null, 'force usage summary recalculation'
            ));
        }
    }

    private Double usageRoundingAdjustment(L2I_OrderUsageData ud) {
        return ((ud.actualQuantity * ud.unitPrice) - ud.subTotal);
    }

    public String getMapKey() {
        return (String) this.orderId + this.summaryEndDate.format();
    }

    public void closeUsageSummary(Id usageSummaryId) {
        // Mark the Usage Summary of the source to close the period (prevent additional usage records)
        queueUsageSummaryUpdate(new blng__UsageSummary__c(
            Id = usageSummaryId
            , blng__InvoiceRunProcessingStatus__c = 'Will Not Invoice'
            , L2I_True_Up_Created__c = true
        ));
    }

    public void processConnectedUserUsage() {
        L2I_OrderUsageData ud = sourceProductUsage;
        queueUsageUpdate(L2I_CustomModelUtils.usageRecord(
            selectedTier.Id, endDateTime, endDateTime
            , ud.quantity, null
            , 'Summarized Usage from product: ' + ud.productCode
        ));
        // Mark the Usage Summary of the source to close the period (prevent additional usage records)
        closeUsageSummary(ud.usageSummaryId);
    }

    public void closeWiFiUsageSummary(String productCode) {
        for (L2I_OrderUsageData ud: WiFiUsage.values()) {
            if (productCode == ud.productCode) closeUsageSummary(ud.usageSummaryId);
        }
    }

    public void applyFloorQuantity(Double floorQuantity) {
        // Create an adjustment usage record if the committed volume has not been reached
        Double floorAdjustment = floorQuantityInMB(floorQuantity) - totalWiFiQuantity();
        if (floorAdjustment > 0)
            queueUsageUpdate(L2I_CustomModelUtils.usageRecord(
                selectedTier.Id, endDateTime, endDateTime
                , floorAdjustment, null
                , 'Committed (floor) Usage adjustment'
            ));
    }

    public void aggregateWiFiUsage() {
        for (L2I_OrderUsageData ud: WiFiUsage.values()) {
            // Create a usage record for each consumption source product
            queueUsageUpdate(L2I_CustomModelUtils.usageRecord(
                selectedTier.Id, endDateTime, endDateTime
                , ud.quantity, null
                , 'Summarized Usage from product: ' + ud.productCode + ' Usage Summary ' + ud.usageSummaryId
            ));
            // Mark the source Usage Summary as processed
            closeUsageSummary(ud.usageSummaryId);
        }
    }

    public Datetime getEndDatetime() { return this.endDateTime; }

    public Boolean hasPlaneCountProduct() { return planeCountUsage != null; }

    public Id planeCountProductId() { return hasPlaneCountProduct() ? planeCountUsage.orderItemId : null; }

    public Boolean hasSourceProduct() { return sourceProductUsage != null; }

    public Id sourceProductId() { return hasSourceProduct() ? sourceProductUsage.orderItemId : null; }

    public Boolean isLegacyGB() { return hasGB && hasWifi && hasSourceProduct() && ! hasCustomModel && WiFiUsage.size() == 1; }

    public Boolean isWJModel() { return hasWJModel; }

    public Boolean isTieredGB() { return hasGB && hasWifi && isTieredGBModel; }

    public Boolean isAverageGBwithOverage() { return hasGB && hasWifi && isAverageGBModel; }

    public Boolean isCustomModel() { return hasCustomModel && hasWifi; }

    public Boolean isConnectedUser() { return hasConnectedUser; }

    public Double includedUsageQuantity() { return includedUsagePerTail * totalActualQuantity; }

    public Double includedUsageAmount() { return includedUsageQuantity() * unitPrice(); }

    private Double unitPrice() { return sourceProductUsage != null ? sourceProductUsage.unitPrice : 0; }

    private Double subtotal() {
        // for Legacy GB, provide the Usage Summary (rated) subtotal
        if (isLegacyGB()) return sourceProductUsage != null ? sourceProductUsage.subtotal : 0;
        // for aggregated GB, calculate the (flat) rate of included usage times unit price
        return totalWiFiQuantity() * (sourceProductUsage != null ? sourceProductUsage.unitPrice : 0);
    }

    private Double totalWiFiQuantity() {
        Double total = 0;
        for (L2I_OrderUsageData ud: WiFiUsage.values()) total += ud.quantity;
        return total;
    }
    public Double getTotalWiFiQuantity() { return totalWiFiQuantity(); }


    public void createLegacyGBcredit() { preRatedUsageCredit(sourceProductUsage.matchingId); }
    public void createAverageGBcredit(String matchingId) { preRatedUsageCredit(matchingId); }
    // GB credit for included usage per tail
    public void preRatedUsageCredit(String matchingId) {
        Double creditAmount = -1 * (subTotal() < includedUsageAmount() ? subTotal() : includedUsageAmount());
        blng__Usage__c record = L2I_CustomModelUtils.usageRecord(
            matchingId
            , endDateTime, endDateTime, null
            , creditAmount
            , 'Average GB per Tail with Overage included usage credit adjustment'
        );
        queueUsageUpdate(record);
    }

    public Double totalBandwithInMB() {
        Double totalBandwith = 0;
        for (L2I_OrderUsageData obj: WiFiUsage.values()) {
            totalBandwith += obj.quantity;
        }
        return totalBandwith;
    }

    public Double totalBandwithInGB() {
        return totalBandwithInMB() / bandwidthMultiplier;
    }

    public Double averageGBperTail() {
        return totalBandwithInGB() / totalActualQuantity;
    }

    public Double floorQuantityInMB(Double floorInAverageGBperTail) {
        return floorInAverageGBperTail * bandwidthMultiplier * totalActualQuantity;
    }

    public Double averageUsersPerFlight() {
        if (sourceProductUsage.flightCount == null || sourceProductUsage.flightCount == 0) {
            System.debug(logginglevel.ERROR,'L2I_OrderData.averageUsersPerFlight: Invalid flight count '+this);
            return 1;
        }
        return sourceProductUsage.quantity / sourceProductUsage.flightCount;
    }

    private L2I_Custom_Model__mdt selectTier(Double quantity) {
        quantity = quantity.round();
        Id modelId = isConnectedUser() ? sourceProductId() : planeCountProductId();
        if (!customModels.containsKey(modelId)) {
            System.debug(logginglevel.ERROR,'L2I_OrderData.selectTier: No model for '+this);
            return null;
        }
        for (L2I_Custom_Model__mdt tier: customModels.get(modelId)) {
            System.debug('Order: '+orderId+' Quantity: '+quantity+' Lower: '+tier.L2I_Lower_Bound__c+' Upper: '+tier.L2I_Upper_Bound__c);
            if ( quantity >= tier.L2I_Lower_Bound__c ) {
                if (tier.L2I_Upper_Bound__c == null || tier.L2I_Upper_Bound__c >= quantity) {
                    System.debug('Order: '+orderId+' Quantity: '+quantity+' priceTier: '+tier);
                    return tier;
                }
            }
        }
        // This is by definition an error... Might should throw an assert
        System.debug(logginglevel.ERROR,'L2I_OrderData.selectTier: Cannot select a price tier for '+quantity+' '+this);
        return null;
    }

    // This method MUST be invoked AFTER ALL affected Orders have been processed
    // We have to walk all of the Orders to find all possible shadow products
    public L2I_Custom_Model__mdt getTier(Double quantity) {
        selectedTier = selectTier(quantity);
        if (selectedTier == null)  {
            // This is by definition an error... Might should throw an assert
            System.debug(logginglevel.ERROR,'L2I_OrderData.getTier: Cannot select a price tier for '+quantity+' '+this);
            return null;
        }
            
        //Do we have a shadow product already?
        //Otherwise we will get ALL source products - same cost
        if (!shadowOrderItems.containsKey(selectedTier.Id)) {
            // Refactoring this - creating all shadow products in the beginning...
            shadowProduct = L2I_OrderData.createShadowOrderProduct(sourceOrderProductMap.get(sourceProductId()), selectedTier);
            System.debug(logginglevel.ERROR,'L2I_OrderData.getTier: Missing shadow product '+this);
        }
        else { shadowProduct = shadowOrderItems.get(selectedTier.Id); }
        blng__UsageSummary__c us = L2I_CustomModelUtils.buildUsageSummary(shadowProduct,summaryStartDate,summaryEndDate,selectedTier.L2I_Per_Unit_Price__c);
        if (us == null)
            System.debug('L2I_OrderData.getTier: Failed to generate UsageSummary record');

        if (DEBUG) {
            System.debug('L2I_OrderData.getTier: selected Tier '+selectedTier);
            System.debug('L2I_OrderData.getTier: Usage Summary '+us);
        }
        return selectedTier;
    }

    private static void setShadowOrderLookups() {
        for (Order o: orderMap.values()) {
            if (o.L2I_SourceOrder_Id__c != null) continue;
            if (o.L2i_Shadow_Order__c != null) continue;
            Map<String, Object> orderAttributes = new Map<String, Object>( o.getPopulatedFieldsAsMap() );
            if (orderAttributes.containsKey('L2I_Shadow_Order__r')) {
                setAffectedOrderId(o.L2I_Shadow_Order__r.Id);
                L2I_CustomModelUtils.queueUpdateRecord(
                    new Order(Id = o.Id, L2i_Shadow_Order__c = o.L2I_Shadow_Order__r.Id)
                );
                if (DEBUG) {System.debug('L2I_OrderData.setShadowOrderLookups: Order '+JSON.serialize(o, true));}
            } else {
                if (DEBUG) {System.debug('L2I_OrderData.setShadowOrderLookups: Order without shadow '+JSON.serialize(o, true));}
            }
        }
    }

    public static void executeUpdates() {
        Integer n;

        //Need to figure out how to inactivate orders before inserting
        n = L2I_CustomModelUtils.insertRecords();
        if (DEBUG) {System.debug('L2I_OrderData.executeUpdates: Inserted '+n+' records');}

        //Now we have SHADOW ORDERS, let's update the Orders...
        L2I_OrderData.setShadowOrderLookups();        

        n = L2I_CustomModelUtils.updateRecords();
        if (DEBUG) {System.debug('L2I_OrderData.executeUpdates: Updated '+n+' records');}
    }

    // Added by Arun - to get the Minimum GB Per Tail value for an OrderItem
    public Double getMinGBPerTail() { return this.minGBPerTail; }


    // Added by Arun - to create usage record for WJ product
public void createUsageForWJ(String matchingId) { preRatedUsageCredit(matchingId); }

}

// end of file