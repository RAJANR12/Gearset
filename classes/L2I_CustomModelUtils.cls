/**
 * Class to work with Rate Schedule JSON tiers that live on Order Items
 * 
 * Created: 04.08.2020
 */
public without sharing class L2I_CustomModelUtils {
    private static final String COMMA = ',';
    public static Boolean DEBUG = true;

    // Manage deactivating and activating Orders...
    private static Set<Order> deacts {
        get{if (deacts==null)deacts=new Set<Order>();return deacts;}
        private set;
    }
    private static Set<Order> processDeacts() {
        if (deacts.size()<1) return deacts;
        for (Order o: deacts) {
            o.Status = 'Draft';
        }
        if (DEBUG) System.debug('L2I_CustomModelUtils.processDeacts: Deactivating'+JSON.serializePretty(deacts,true));
        List<Order> sobjs = new List<Order>();
        sobjs.addAll(deacts);
        updateSObjects(sobjs);
        return deacts;
    }
    private static Set<Order> reacts {
        get{if (reacts==null)reacts=new Set<Order>();return reacts;}
        private set;
    }
    private static Set<Order> processReacts() {
        if (reacts.size()<1) return reacts;
        for (Order o: reacts) {
            if (o.Id == null) System.debug(logginglevel.ERROR, 'L2I_CustomModelUtils.processReacts: No ID'+JSON.serializePretty(o,true));
            else o.Status = 'Activated';
        }
        if (DEBUG) System.debug('L2I_CustomModelUtils.processReacts: Activating'+JSON.serializePretty(reacts,true));
        List<Order> sobjs = new List<Order>();
        sobjs.addAll(reacts);
        updateSObjects(sobjs);
        return reacts;
    }
    // Accumulate record data for bulk DML insert
    private static List<SObject> priceTierToInsert {
        get {if (priceTierToInsert == null) priceTierToInsert = new List<SObject>();return priceTierToInsert;}
        private set;
    }
    // Accumulate record data for bulk DML insert
    private static List<SObject> orderToInsert {
        get {if (orderToInsert == null) orderToInsert = new List<SObject>();return orderToInsert;}
        private set;
    }
    // Accumulate record data for bulk DML insert
    private static List<SObject> orderItemToInsert {
        get {if (orderItemToInsert == null) orderItemToInsert = new List<SObject>();return orderItemToInsert;}
        private set;
    }
    // Accumulate record data for bulk DML insert
    private static List<SObject> usageSummaryToInsert {
        get {if (usageSummaryToInsert == null) usageSummaryToInsert = new List<SObject>();return usageSummaryToInsert;}
        private set;
    }
    // Accumulate record data for bulk DML insert
    private static List<SObject> priceScheduleToInsert {
        get {if (priceScheduleToInsert == null) priceScheduleToInsert = new List<SObject>();return priceScheduleToInsert;}
        private set;
    }
    // Accumulate record data for bulk DML insert
    private static List<SObject> recordsToInsert {
        get {if (recordsToInsert == null) recordsToInsert = new List<SObject>();return recordsToInsert;}
        private set;
    }
    // Accumulate record data for bulk DML update
    private static List<SObject> recordsToUpdate  {
        get {if (recordsToUpdate == null) recordsToUpdate = new List<SObject>();return recordsToUpdate;}
        private set;
    }

    // constructor
    public L2I_CustomModelUtils() {
        
    }

	@TestVisible
    private static Integer insertSObjects(List<SObject> sobjs) {
        if (sobjs == null) {
            if (DEBUG) System.debug('L2I_CustomModelUtils.insertSObjects: No records to insert');
            return 0;
        }
        if (DEBUG) System.debug('L2I_CustomModelUtils.insertSObjects: Number of records to insert '+sobjs.size());
        if (DEBUG) {
            for (SObject sobj: sobjs) {
                System.debug('L2I_CustomModelUtils.insertSObjects: '+sobj.getSObjectType()+'  :::  '+JSON.serializePretty(sobj, true));
            }
        }
        //Create (shadow) Order Products 
        try {
            insert sobjs;
        } catch(DmlException e) {
            L2I_PrecisionTailCountUtils.queueErrorMessage('L2I_CustomModelUtils.insertSObjects: ERROR: ' + e.getMessage());
            if (DEBUG) System.debug('L2I_CustomModelUtils.insertSObjects: ERROR: ' + e.getMessage());
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                System.debug('L2I_CustomModelUtils.insertSObjects: ERROR: ' + e.getDmlMessage(i)); 
                System.debug(':::'+e.getDmlFieldNames(i));
                L2I_PrecisionTailCountUtils.queueErrorMessage('L2I_CustomModelUtils.insertSObjects: '+i+' '+ e.getDmlFieldNames(i));

            }
        }
        return sobjs.size();
    }

	@TestVisible
    private static Integer updateSObjects(List<SObject> sobjs) {
        if (sobjs == null) {
            if (DEBUG) System.debug('L2I_CustomModelUtils.updateSObjects: No records to update');
            return 0;
        }
        if (DEBUG) System.debug('L2I_CustomModelUtils.updateSObjects: Number of records to update '+sobjs.size());
        if (DEBUG) {
            for (SObject sobj: sobjs) {
                System.debug('L2I_CustomModelUtils.updateSObjects: '+sobj.getSObjectType()+'  :::  '+JSON.serializePretty(sobj, true));
            }
        }
    
        //Execute updates
        try {
            update sobjs;
        } catch(DmlException e) {
            L2I_PrecisionTailCountUtils.queueErrorMessage('L2I_CustomModelUtils.updateSObjects: ERROR'+e.getMessage());
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                System.debug('L2I_CustomModelUtils.updateSObjects: An error has occurred: ' + e.getDmlMessage(i)); 
                System.debug(':::'+e.getDmlFieldNames(i));
                L2I_PrecisionTailCountUtils.queueErrorMessage('L2I_CustomModelUtils.updateSObjects: '+i+' '+e.getDmlFieldNames(i));
            }
        }
        return sobjs.size();
    }

    public static void queueInsertRecord(SObject sobj) {
        recordsToInsert.add(sobj);
        if (DEBUG) System.debug('L2I_CustomModelUtils.queueInsertRecord: '+JSON.serializePretty(sobj,true));
    }

    public static void queueUpdateRecord(SObject sobj) {
        recordsToUpdate.add(sobj);
        if (DEBUG) System.debug('L2I_CustomModelUtils.queueUpdateRecord: '+JSON.serializePretty(sobj,true));
    }

    public static List<SObject> listSObjectInserts() {
        // Build the insert list
        List<SObject> sobjs = priceScheduleToInsert;
        sobjs.addAll(priceTierToInsert);
        sobjs.addAll(orderToInsert);
        sobjs.addAll(orderItemToInsert);
        sobjs.addAll(usageSummaryToInsert);
        sobjs.addAll(recordsToInsert);
        return sobjs;
    }

    public static Integer insertRecords(){
        processDeacts();
        
        return insertSObjects(listSObjectInserts());
    }

    public static Integer updateRecords(){
        Integer updateCount = updateSObjects(recordsToUpdate);
        // We will also handle reactivations here.
        // Even though the same object could be in both lists, it cannot be reliably updated together
        updateCount += processReacts().size();
        return updateCount;
    }

    /**
     * @description: method to collect source orders for creating shadow orders
     * @param orderIDs sourceOrderIds: the source order Id for creating the shadow
     * @return List<Order> sourceOrders: source Orders to clone
     */
    public static List<Order> getOrders(Set<Id> orderIds) {
        List<Order> orders = [
            SELECT Id
                , AccountId
                , blng__BillingAccount__c
                , blng__BillingDayOfMonth__c
                , blng__InvoiceBatch__c
                , CurrencyIsoCode
                , EffectiveDate
                , EndDate
                , L2I_Product_Category_2__c
                , L2I_Shadow_Order__c
                , L2I_SourceOrder_Id__c
                , OpportunityId
                , Pricebook2Id
                , SBQQ__PaymentTerm__c
                , Status
            FROM  Order
            WHERE isDeleted = false 
            AND (Id  IN :orderIds OR L2I_SourceOrder_Id__c IN :orderIds)
        ];
        return orders;
    }

    /**
     * @description: Method to create a shadow Order
     * @param Order sourceOrder: Order to clone
     * @return Order: Order SObject ready to be inserted.
     */
    public static Order createShadowOrder(Order sourceOrder) {
        Order theShadow = sourceOrder.clone();
        theShadow.L2I_Order_Process__c = 'Shadow';
        theShadow.L2I_SourceOrder_Id__c = sourceOrder.Id;
        theShadow.IsReductionOrder = false;
        theShadow.Type = 'New';
        theShadow.SBQQ__PriceCalcStatus__c = 'Completed';
        theShadow.Status = 'Draft';
        orderToInsert.add(theShadow);
        return theShadow;
    }

    /**
     * @description: method to collect one or more order products that will be used for building shadow products
     *   Note: each Rate Schedule tier conceives a shadow Order Item
     * @param OrderItemIds sourceOrderItem: the source order item Id for creating the shadow
     * @return List<OrderItem> sourceOrderItem: source Order Items to clone
     */
    public static List<OrderItem> getSourceOrderItems(List<Id> orderItemIds) {
        System.debug('CustomModelUtils.getSourceOrderItems() Ids: ' + orderItemIds);
        return [
            SELECT Id, PricebookEntryId, Product2Id
            , OrderId
            , blng__BillableUnitPrice__c, blng__LegalEntity__c
            , blng__BillingGLRule__c, blng__BillingGLTreatment__c
            , blng__RevenueRecognitionRule__c, blng__TaxRule__c
            , blng__BillingRule__c, blng__BillingTreatment__c
            , blng__InvoiceGroupId__c, blng__InvoiceGrouping__c
            , L2I_blng_MatchingId__c
            , L2I_CCC__c
            , L2I_CCC_Suffix__c
            , L2I_Line_Type_ID__c
            , L2I_Order_Type_Context__c
            , L2I_Order_Type_ID__c
            , L2I_PACRevSharePerc__c
            , L2I_Price_List_ID__c
            , L2I_Product_Code__c
            , L2I_RevShare__c
            , L2I_VendorRevSharePerc__c
            , L2I_Category__c
            , L2I_Sub_Category_1__c, L2I_Sub_Category_2__c, L2I_Sub_Category3__c
            , L2I_Frequency__c
            , L2I_Megabyte_Definition__c
            , L2I_On_Doc_Delivery_Day__c
            , L2I_Product_Code_Int__c
            , L2I_ProductName__c
            , L2I_Shipment_Type__c
            , Quantity
            , UnitPrice
            , SBQQ__Activated__c
            , SBQQ__ChargeType__c
            , SBQQ__RequiredBy__c
            , SBQQ__Status__c
            , SBQQ__BundleRoot__c
            , SBQQ__SubscriptionPricing__c
            , Order.Status
            , L2I_Minimum_GB_Per_Tail__c // Added by Arun
            FROM OrderItem
            WHERE isDeleted = false  AND  Id in :orderItemIds
        ];
    }

    public static blng__UsageSummary__c buildUsageSummary(OrderItem oi, Date startDate, Date endDate, Decimal price) {
        blng__UsageSummary__c us = new blng__UsageSummary__c(
            blng__MatchingId__c = oi.L2I_blng_MatchingId__c
            ,blng__Order__c = oi.OrderId
            ,blng__SummaryStartDate__c = startDate
            ,blng__SummaryEndDate__c = endDate
            ,blng__UnitPrice__c = price
            ,blng__Status__c = 'New'
            ,blng__Source__c = 'External'
            ,blng__InvoiceRunProcessingStatus__c = 'Pending Billing'
            ,blng__InvoiceRunStatusIndex__c = 'Pending Billing'
            ,blng__Notes__c = 'Shadow product usage summary, created by L2I process'
        );
        // Tie our Usage Summary to our Order Item
        if (oi.Id == null) {  //record in memory
            // Reference object for OrderItem in memory...
            us.blng__OrderProduct__r = new OrderItem(L2I_blng_MatchingId__c = oi.L2I_blng_MatchingId__c);
        } else {  //record in database
            us.blng__OrderProduct__c = oi.Id;  
        }
        usageSummaryToInsert.add(us);
        return us;
    }
	@TestVisible
    private static void buildPriceObjects(OrderItem oi, L2I_Custom_Model__mdt tier) {
        String tierName = tier.L2I_Lower_Bound__c.format();
        if (tier.L2I_Upper_Bound__c == null) tierName += '+';
        else tierName += ' - ' + tier.L2I_Upper_Bound__c.format();

        SBQQ__PriceTier__c pt = new SBQQ__PriceTier__c(
            Name = tierName,
            SBQQ__Number__c = 0,
            SBQQ__PriceModel__c = 'Per Unit',
            SBQQ__LowerBound__c = 1,
            SBQQ__Price__c = tier.L2I_Per_Unit_Price__c
        );

        // Price Schedule reference object for OrderItem and Price Tier
        oi.SBQQ__PriceSchedule__r =  pt.SBQQ__PriceSchedule__r = new SBQQ__PriceSchedule__c(L2I_External_Id__c = oi.L2I_blng_MatchingId__c);

        SBQQ__PriceSchedule__c ps = new SBQQ__PriceSchedule__c(
            Name = tierName
            ,SBQQ__PriceType__c = 'Volume'
            ,SBQQ__DiscountUnit__c = 'Percent'
            ,SBQQ__Order__c = oi.OrderId
            ,L2I_External_Id__c = oi.L2I_blng_MatchingId__c 
        );
        // Must add the objects in specific order so the reference objects exist
        // We need the orderitem to look up to the price schedule in this create cycle
        // Even though there is a lookup from price schedule to orderitem - will address later if necessary
        priceScheduleToInsert.add(ps);
        orderItemToInsert.add(oi);
        priceTierToInsert.add(pt);
    }

    /**
     * @description: method to initialize (but not insert yet) a shadow Order Item in memory. 
     *   Note: each Rate Schedule tier conceives a shadow Order Item
     *
     * @param OrderItem sourceOrderItem: the source order item for creating the shadow
     * @param L2I_Custom_Model__mdt tier: the Rate Schedule tier to parse from the source order item
     * @return OrderItem shadowOrderItem: a shadow Order Item to insert
     * TODO:: Create fieldset to allow clone updates to be data driven
     */
    public static OrderItem initializeShadowOrderItemFromTier(OrderItem sourceOrderItem, L2I_Custom_Model__mdt tier) {
        //FIXME - we should not be using this method - we should only use Shadow orders
        System.debug('CustomModelUtils.initializeShadowOrderItemFromTier() tier: ' + tier);
        if (sourceOrderItem.Order != null && sourceOrderItem.Order.Status == 'Activated') {
            deacts.add(new Order(Id = sourceOrderItem.OrderId, Status = 'Draft'));
            reacts.add(new Order(Id = sourceOrderItem.OrderId, Status = 'Activated'));
        }
        return createShadowOrderItem(sourceOrderItem, tier);
    }

    // This method will create a shadow order with shadow orderitems
    public static OrderItem initializeShadowOrderItemFromTier(Order shadowOrder, OrderItem sourceOrderItem, L2I_Custom_Model__mdt tier) {
        System.debug('CustomModelUtils.initializeShadowOrderItemFromTier() tier: ' + tier);
        OrderItem shadowOrderItem;
        if (shadowOrder.Id != null) {
            if (shadowOrder.Status == 'Activated') {
                deacts.add(shadowOrder);
                reacts.add(shadowOrder);
            }
            shadowOrderItem = createShadowOrderItem(sourceOrderItem, tier);
            shadowOrderItem.OrderId = shadowOrder.Id;
        } else {
            OrderItem oi;
            Map<String, Object> tmp = new Map<String, Object>( sourceOrderItem.getPopulatedFieldsAsMap() );
            tmp.remove( 'OrderId' );
            oi = (OrderItem) JSON.deserialize( JSON.serialize( tmp ), OrderItem.class );
            shadowOrderItem = createShadowOrderItem(oi, tier);
            shadowOrderItem.Order = new Order(L2I_SourceOrder_Id__c = shadowOrder.L2I_SourceOrder_Id__c);
            reacts.add(shadowOrder);
        }
        return shadowOrderItem;
    }

    public static OrderItem createShadowOrderItem(OrderItem sourceOrderItem, L2I_Custom_Model__mdt tier) {
        System.debug('CustomModelUtils.initializeShadowOrderItemFromTier() tier: ' + tier);
        OrderItem shadowOrderItem = sourceOrderItem.clone();
        // We will take it from the source... //shadowOrderItem.blng__BillingRule__c = BillableProductRule;
        shadowOrderItem.SBQQ__BillingFrequency__c = 'Invoice Plan'; //Custom Usage summaries
        shadowOrderItem.blng__BillableUnitPrice__c = tier.L2I_Per_Unit_Price__c;
        shadowOrderItem.L2I_Source_OrderProduct__c = sourceOrderItem.Id;
        shadowOrderItem.L2I_blng_MatchingId__c = tier.Id; //this is the external ID...
        //shadowOrderItem.L2I_Minimum_GB_Per_Tail__c = sourceOrderItem.L2I_Minimum_GB_Per_Tail__c; // Added By Arun - to set the L2I_Minimum_GB_Per_Tail__c for shadowOrderItem
        //Create Price Schedule and Price Tier from custom price tier
        buildPriceObjects(shadowOrderItem, tier);
        return shadowOrderItem;
    }

    public static blng__Usage__c usageRecord(String matchingId, Datetime startDate, Datetime endDate, Double quantity, Double preRatedAmount, String notes) {
        blng__Usage__c thisUsage = new blng__Usage__c(
            blng__MatchingId__c = matchingId
            ,blng__StartDateTime__c = startDate
            ,blng__EndDateTime__c = endDate
            ,blng__Quantity__c = quantity
            ,blng__PreratedAmount__c = preRatedAmount
            ,L2I_True_Up_Record__c = true
            , blng__Notes__c = notes
        );
        System.debug('Usage Record: '+thisUsage);
        return thisUsage;
    }

    /**
     * @description: method to parse the custom model into an object. 
     *
     * @param OrderItem sourceOrderItem: the source order item 
     * @return List<L2I_Custom_Model__mdt> tiers: the Rate Schedule tiers parsed from the source Order Item
     */
    public static List<L2I_Custom_Model__mdt> parseRateScheduleJson(OrderItem sourceOrderItem) {
        System.debug('L2I_CustomModelUtils.parseRateScheduleJson() sourceOrderItem: ' + sourceOrderItem);
        String rateScheduleJson = sourceOrderItem.L2I_Rate_Schedule_JSON__c;
        List<L2I_Custom_Model__mdt> tiers = rateScheduleJson == null ? null : (List<L2I_Custom_Model__mdt>)JSON.deserialize(rateScheduleJson, List<L2I_Custom_Model__mdt>.class);
        return tiers;
    }

}

// end of file