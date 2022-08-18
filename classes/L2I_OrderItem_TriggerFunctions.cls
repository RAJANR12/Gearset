/**
 *      @author       Raj Rajen
 *      @date         07/28/2019
 *      @description  L2I Order Item Trigger Functions
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/28/2019         Initial scaffold
 *      Raj Rajen                     09/16/2019         Included PB logic
 *      Raj Rajen                     09/17/2019         Included Workflow Rule logic
 *      Sarah Kennedy                 01/08/2020         Removed L2I_WiFi_Order_Product__c per US1170-TA2410
 *      Raj Rajen                     03/24/2020         Added InvoiceBatch enhancements as per US US1680-TA2877
 *      Raj Rajen                     03/31/2020         Removed old commented out code fragments.
 *      Sarah Kennedy                 04/08/2020         US1724 Updates to Inventory Group Id
 *      Sarah Kennedy                 04/17/2020         DE423 to use L2I_CCC_Suffix__c instead of L2I_CCC__c
 *      Andy Fang                     04/21/2020         DE417 Update Order Product End Date to Order
 *      Andy Fang                     05/08/2019         Remove DE417 method due to recursive calls
 */
public without sharing class L2I_OrderItem_TriggerFunctions {

    private static final Map<String, String> campaignType       = L2I_JSON_Settings.getSettings('OrderItem_Campaign_Type_Settings');
    private static final Map<String, String> revenueType        = L2I_JSON_Settings.getSettings('OrderItem_Revenue_Type_Settings');
    private static final Map<String, String> goalType           = L2I_JSON_Settings.getSettings('OrderItem_Goal_Type_Settings');
    private static final Map<String, String> invoiceBatchLookup = L2I_JSON_Settings.getSettings('InvoiceBatch_Settings');

    public static void updateDeliverySchedulefromOrder(List<OrderItem> newOrderItems){
        Set <Id> reqInsertedOrderIds = new Set<Id>();
        Map <Id, Order> ordMap = new Map<Id, Order>();

        //Gather unique list of orders
        for (OrderItem ordItem : newOrderItems){
            if (! reqInsertedOrderIds.contains(ordItem.OrderId)){
                reqInsertedOrderIds.add( ordItem.OrderId );
            }
        }
        // during before insert trigger order formula fields are not available hence need to query orders
        // Retrive Order Fields for contract Management order process orders only
        List<Order> ordList = [ SELECT Id, L2I_Delivery_Schedule__c, L2I_Order_Process__c FROM Order
        WHERE id IN: reqInsertedOrderIds and L2I_Delivery_Schedule__c != null and L2I_Order_Process__c = 'Contract Management'];

        if (ordList.size()>0) {
            // Populate Order Map
            System.debug('======= Order Item Trigger Before Insert Order Query Count ======:' +ordList.size());
            for (Order ord : ordList) {
                ordMap.put(ord.Id, ord);
            }

            // Process all new Items and set delivery schedule field
            for (OrderItem ordItem : newOrderItems) {
                Order ord = ordMap.get(ordItem.OrderId);
                if (ord != null) {
                    if (ordItem.L2I_Delivery_Schedule__c == null) {
                        ordItem.L2I_Delivery_Schedule__c = ord.L2I_Delivery_Schedule__c;
                    }
                }
            }
        }
    }
// This method is only needed for Contract Management or Advertising Brands Process can be skipped for Shadow and PT
    public static void updateAllFieldsOnParent(List<OrderItem> newOrderItemList) {
        System.debug('====== Number of order items to set delivery schedule on :' + newOrderItemList.size());

        Set<Id> affectedOrderItems = new Set<Id>();
        Set<Id> referencedParentOrders = new Set<Id>();
        for (OrderItem oitem : newOrderItemList) {
            if (oitem.L2I_Order_Process__c == 'Contract Management' || oitem.L2I_Order_Process__c == 'Advertising Brand') {
                affectedOrderItems.add(oitem.Id);
                referencedParentOrders.add(oitem.OrderId);
            }
        }

        System.debug('====== Number of unique parent orders : ' + referencedParentOrders.size());
        //Map<Id, Id> orderDSHLookup = new Map<Id, Id>();
        //List<Order> parentOrders = new List<Order>([select Id,
        //                                                   blng__InvoiceBatch__c,
        //                                                   L2I_Delivery_Schedule__c,
        //                                                   L2I_Product_Category_2__c,
        //                                                   L2I_Media_Frequency__c,
        //                                                   L2I_PO_Required__c,
        //                                                   L2I_WiFi_Order_Product__c
        //                                              from Order
        //                                             where Id in :referencedParentOrders]);
        List<Order> parentOrders = new List<Order>([select Id,
                                                           blng__InvoiceBatch__c, L2I_Feature_ID__c,
                                                           //L2I_Delivery_Schedule__c,
                                                           L2I_Product_Category_2__c, L2I_Service_Activation_Types__c,
                                                           L2I_Media_Frequency__c, L2I_Feature_Name__c,
                                                           L2I_PO_Required__c,
                                                            L2I_Order_Process__c
                                                      from Order
                                                     where Id in :referencedParentOrders]);

        //for (Order ord : parentOrders) {
        //    orderDSHLookup.put(ord.Id, ord.L2I_Delivery_Schedule__c);
        //}
        //System.debug('======= Number of orderDSH lookup entries :' + orderDSHLookup.size());

        //List<OrderItem> createdOrderItems = new List<OrderItem>([select Id,
        //                                                                OrderId,
        //                                                                L2I_Sub_Category_2__c,
        //                                                                L2I_Delivery_Schedule__c,
        //                                                                L2I_PO_Required__c,
        //                                                                L2I_Frequency__c,
        //                                                                L2I_Product_Code__c,
        //                                                                EndDate
        //                                                           from OrderItem
        //                                                          where Id in :affectedOrderItems]);

        Map<Id, String> orderProductCategoryMap = new Map<Id, String>();
        Map<Id, Boolean> orderPOrequiredMap = new Map<Id, Boolean>();
        Map<Id, String> orderMediaFrequencyMap = new Map<Id, String>();
        //Map<Id, Id> orderWifiProductIdMap = new Map<Id, Id>();
        Map<Id, String> orderInvoiceBatchMap = new Map<Id, String>();
        Map<Id, Date> orderIdEndDateMap = new Map<Id, Date>();
        Map<Id, String> orderSATypeMap = new Map<Id, String>();
        Map<Id, String> orderFeatureIDMap = new Map<Id, String>();
        Map<Id, String> orderFeatureNameMap = new Map<Id, String>();



        for (OrderItem oitem : newOrderItemList) {
            //Id dshId = orderDSHLookup.get(oitem.OrderId);
            //oitem.L2I_Delivery_Schedule__c = dshId;

            orderProductCategoryMap.put(oitem.OrderId, oitem.L2I_Sub_Category_2__c);
            orderFeatureIDMap.Put(oitem.OrderId, oitem.L2I_Feature_ID__c);
            orderFeatureNameMap.Put(oitem.OrderId, oitem.L2I_Feature_Name__c);
            STRING SAType = '';
            if (orderSATypeMap.get(oitem.OrderId) != null ){
                SAType = orderSATypeMap.get(oitem.OrderId);
            }
            SAType = L2I_DealSummaryFunctions.AppendValue2(SAType, oitem.L2I_Service_Activation_Type__c, '', true, ',');
            orderSATypeMap.put(oitem.OrderId, SAType);

            if (oitem.L2I_PO_Required__c != null) {
                orderPOrequiredMap.put(oitem.OrderId, oitem.L2I_PO_Required__c);
            }
            if (oitem.L2I_Frequency__c != null) {
                orderMediaFrequencyMap.put(oitem.OrderId, oitem.L2I_Frequency__c);
            }
            //if ('PA-WIFIUSG-YYYY'.equalsIgnoreCase(oitem.L2I_Product_Code__c)) {
            //    orderWifiProductIdMap.put(oitem.OrderId, oitem.Id);
            //}
            //[RR] Old logic for InvoiceBatch set up on Order
            //[RR]if ('PA-CPSTPFL-YYYY'.equalsIgnoreCase(oitem.L2I_Product_Code__c) && 'WiFi'.equalsIgnoreCase(oitem.L2I_Sub_Category_2__c)) {
            //[RR]    orderInvoiceBatchMap.put(oitem.OrderId, 'TB Plan');
            //[RR]}
            //[RR]if ('MCS'.equalsIgnoreCase(oitem.L2I_Sub_Category_2__c)) {
            //[RR]    orderInvoiceBatchMap.put(oitem.OrderId, 'MCS');
            //[RR]}
            //
            // New logic as per TA-2162
            if ('PA-CPSTPFL-YYYY'.equalsIgnoreCase(oitem.L2I_Product_Code__c)) {
                orderInvoiceBatchMap.put(oitem.OrderId, 'TB Plan');
            // Added by Arun
            } else if('PA-CPSULFL-YYYY'.equalsIgnoreCase(oitem.L2I_Product_Code__c)) {
                orderInvoiceBatchMap.put(oitem.OrderId, 'WiFi Non Plane Count');
            } else {
                String existingInvoiceBatch = orderInvoiceBatchMap.get(oitem.OrderId);
                // Arun - Added new condition for WiFi Non Plane Count
                if (existingInvoiceBatch != null && (existingInvoiceBatch.equalsIgnoreCase('TB Plan') || existingInvoiceBatch.equalsIgnoreCase('WiFi Non Plane Count'))) {
                    continue;
                } else {
                    // String subCategory = oitem.L2I_Sub_Category_2__c;
                    // String invoiceBatchSetting = null;
                    // if (invoiceBatchLookup.containsKey(subCategory)) {
                    //     invoiceBatchSetting = invoiceBatchLookup.get(subCategory);
                    // }
                    // orderInvoiceBatchMap.put(oitem.OrderId, invoiceBatchSetting);
                    orderInvoiceBatchMap.put(oitem.OrderId, 'Posted Invoice'); // Added by Arun - 01.19.21
                }
            }

        }

        //System.debug('====== Number of order items to update with DSH info :' + newOrderItemListOrderItems.size());
        //if (!createdOrderItems.isEmpty()) {
            //update createdOrderItems;

            // Keep track of MCS orders
            Set<Id> mcsOrders = new Set<Id>();
            // Keep track of Advertising Orders
            Set<Id> advOrders = new Set<Id>();

            // Now update the parent Orders with the ProductCategory from their respective OrderItems
            Boolean parentRequiresUpdate = false;

            for (Order ord : parentOrders) {
                String productCategory = orderProductCategoryMap.get(ord.Id);
                if (orderFeatureIDMap.get(ord.id) != null){
                    ord.l2I_Feature_ID__c =  orderFeatureIDMap.get(ord.id);
                }
                if (orderFeatureNameMap.get(ord.id) != null){
                    ord.l2I_Feature_Name__c =  orderFeatureNameMap.get(ord.id);
                }
                if (orderSATypeMap.get(ord.id) != null){
                    ord.L2I_Service_Activation_Types__c =  orderSATypeMap.get(ord.id);
                }

                if (productCategory != null) {
                    ord.L2I_Product_Category_2__c = productCategory;
                    parentRequiresUpdate = true;
                    if (productCategory.equalsIgnoreCase('mcs')) {
                        mcsOrders.add(ord.Id);
                    }
                    if (productCategory.containsIgnoreCase('advertisers/brands')) {
                        if (productCategory.equalsIgnoreCase('advertisers/brands') ||
                            productCategory.equalsIgnoreCase('advertising') ) {
                                advOrders.add(ord.Id);
                            }
                    }                    
                }

                Boolean poRequired = orderPOrequiredMap.get(ord.Id);
                if (poRequired) {
                    ord.L2I_PO_Required__c = poRequired;
                    parentRequiresUpdate = true;
                }
                String mediaFrequency = orderMediaFrequencyMap.get(ord.Id);
                if (mediaFrequency != null) {
                    ord.L2I_Media_Frequency__c = mediaFrequency;
                    parentRequiresUpdate = true;
                }
                //Id wifiProductId = orderWifiProductIdMap.get(ord.Id);
                //if (wifiProductId != null) {
                //    ord.L2I_WiFi_Order_Product__c = wifiProductId;
                //    parentRequiresUpdate = true;
                //}
                String invoiceBatch = orderInvoiceBatchMap.get(ord.Id);
                System.debug('====== UPDATING ord.blng__InvoiceBatch__c as "' + invoiceBatch + '"');
                if (invoiceBatch != null) {
                    ord.blng__InvoiceBatch__c = invoiceBatch;
                    parentRequiresUpdate = true;
                }

            }

            if (parentRequiresUpdate) {
                System.debug('====== Updating Product Category, PO Required & Media Frequency fields (as needed) for Orders from OrderItem trigger');
                System.debug('====== Additionally also updating WiFi Order Product and Invoice Batch (as needed) for Orders from OrderItem trigger');
                update parentOrders;

                // Parent orders have been updated, if there were any MCS orders, then we should
                // fire the Platform Event for DSS Integration.

                if (!mcsOrders.isEmpty()) {
                    //List<L2I_Order_Create_Media__e> ocmList = new List<L2I_Order_Create_Media__e>();
                    //for (Id oid : mcsOrders) {
                    //    System.debug('======= Setting up Order Create Media Platform Event for Order Id :' + oid);
                    //    L2I_Order_Create_Media__e ocm = new L2I_Order_Create_Media__e();
                    //    ocm.RecordID__c = oid;
                    //    ocmList.add(ocm);
                    //}
                    //
                    //System.debug('======= Publishing ' + ocmList.size() + ' DSS Order Create Platform Event(s)');
                    //if ( ocmList.size() > 0 ) {
                    //    EventBus.publish( ocmList );
                    //}
                    //
                    L2I_FireDSSPlatformEvents dssEventsQueueable = new L2I_FireDSSPlatformEvents(mcsOrders);
                    Id jobId = System.enqueueJob(dssEventsQueueable);
                    System.debug('====== DSS PlatformEvent Queueable Job ' + jobId + ' has been submitted');
                }
                if ( !advOrders.isEmpty() ) {
                    L2I_FireAdvertisePlatformEvents advEventsQueueable = new L2I_FireAdvertisePlatformEvents(advOrders);
                    Id jobId = System.enqueueJob(advEventsQueueable);
                    System.debug('====== Advertising PlatformEvent Queueable Job ' + jobId + ' has been submitted');
                }
            }
        //}

    }
// skip for Shadow and PT orders.
    public static void setFieldsOnCreation(List<OrderItem> newOrderItemList) {
        System.debug('====== L2I_OrderItem_TriggerFunctions::setFieldsOnCreation() processing :' + newOrderItemList.size() + ' OrderItems');

        L2I_Billing_IDs__c bids = L2I_Billing_IDs__c.getOrgDefaults();

        String X100_on_Activation_Treatment_ID    = bids.X100_on_Activation_Treatment_ID__c;
        String Billable_Product_Treatment_ID      = bids.Billable_Product_Treatment_ID__c;
        String Quarterly_Treatment_ID             = bids.Quarterly_Treatment_ID__c;
        String Semi_Annual_Treatment_ID           = bids.Semi_Annual_Treatment_ID__c;
        String Tri_Annual_Treatment_ID            = bids.Tri_Annual_Treatment_ID__c;
        String TB_Product_ID                      = bids.TB_Product_ID__c;

        String Billable_Product_Rule_ID                 = bids.Billable_Product_Rule_ID__c;
        String Billable_Product_Rule_Semi_Annual_ID     = bids.Billable_Product_Rule_Semi_Annual_ID__c;
        String Billable_Product_Rule_Tri_Annual_ID      = bids.Billable_Product_Rule_Tri_Annual_ID__c;
        String Billable_Product_Rule_100_ID             = bids.Billable_Product_Rule_100_ID__c;
        String Billable_Product_Rule_Quarterly_ID       = bids.Billable_Product_Rule_Quarterly_ID__c;

        String boingoAccountId    = Label.L2I_Boingo_Account_Id;
        String ipassAccountId     = Label.L2I_iPass_Account_Id;
        String defaultLegalEntity = Label.L2I_Default_Legal_Entity_Id;


        Set<Id> affectedProductIds = new Set<Id>();
        Set<Id> affectedOrderItemIds = new Set<Id>();
        Map<Id, Id> productBillingRuleLookup = new Map<Id, Id>();

        for (OrderItem oitem : newOrderItemList) {
            if (oitem.L2I_Order_Process__c == 'Contract Management' || oitem.L2I_Order_Process__c == 'Advertising Brand') {
                affectedProductIds.add(oitem.Product2Id);
                affectedOrderItemIds.add(oitem.Id);
            }
        }
        // Process records only if There are affected order Items to be processed
        if (affectedOrderItemIds.size() >0) {
            List<Product2> affectedProducts = new List<Product2>([select Id, blng__BillingRule__c from Product2 where Id in :affectedProductIds]);
            for (Product2 prod : affectedProducts) {
                productBillingRuleLookup.put(prod.Id, prod.blng__BillingRule__c);
            }

            List<OrderItem> affectedOrderItemList = new List<OrderItem>([
                    select Id,
                            OrderId,
                            blng__InvoiceGroupId__c,
                            blng__InvoiceGrouping__c,
                            blng__LegalEntity__c,
                            Product2Id,
                            Quantity,
                            L2I_blng_MatchingId__c,
                            L2I_CCC__c,
                            L2I_CCC_Suffix__c,
                            L2I_Connecctivity_Frequency__c,
                            L2I_ProductName__c,
                            L2I_Product_Code__c,
                            L2I_Campaign_Type__c,
                            L2I_Revenue_Type__c,
                            L2I_Goal_Type__c,
                            L2I_IncludedUsage__c,
                            SBQQ__QuoteLine__r.L2I_IncludedUsage__c,
                            SBQQ__QuoteLine__r.L2I_Connecctivity_Frequency__c,
                            blng__BillingTreatment__c,
                            blng__BillingAccount__c,
                            blng__IncludedUsage__c,
                            blng__BillingRule__c,
                            Order.OpportunityId,
                            Order.L2I_Original_Sales_Opportunity__c,
                            Product2.L2I_Sub_Category_2__c,
                            Product2.L2I_Feature_ID__c,
                            Order.Type
                    from OrderItem
                    where Id in :affectedOrderItemIds
            ]);


            for (OrderItem oitem : affectedOrderItemList) {
                // (1) Set Order Product Values
                // RR 02/12/2020 - TA2623 (US 1278) Update Code to Populate Invoice Group ID for Media Set Spare Copies Order Items
//            if ('PA-MCS17SPR-001'.equalsIgnoreCase(oitem.L2I_Product_Code__c)) {
//                oitem.blng__InvoiceGroupId__c = oitem.OrderId + ':' + oitem.L2I_CCC__c + ':' + oitem.L2I_blng_MatchingId__c;
//            } else {
//                oitem.blng__InvoiceGroupId__c = oitem.OrderId + ':' + oitem.L2I_CCC__c;
//            }
                //
                // SK 4/7 changes for US1725
                if (oitem.Order.Type != 'Amendment') {
                    if ('PA-MCS17SPR-001'.equalsIgnoreCase(oitem.L2I_Product_Code__c) ||
                          'PA-MCS20USPR-001'.equalsIgnoreCase(oitem.L2I_Product_Code__c) ) {
                        oitem.blng__InvoiceGroupId__c = oitem.Order.OpportunityId + ':' + oitem.Product2.L2I_Feature_ID__c + ':' + oitem.L2I_CCC_Suffix__c + ':' + oitem.L2I_blng_MatchingId__c;
                    } else {
                        oitem.blng__InvoiceGroupId__c = oitem.Order.OpportunityId + ':' + oitem.Product2.L2I_Feature_ID__c + ':' + oitem.L2I_CCC_Suffix__c;
                    }
                } else {
                    if ('PA-MCS17SPR-001'.equalsIgnoreCase(oitem.L2I_Product_Code__c) ||
                          'PA-MCS20USPR-001'.equalsIgnoreCase(oitem.L2I_Product_Code__c)) {
                        oitem.blng__InvoiceGroupId__c = oitem.Order.L2I_Original_Sales_Opportunity__c + ':' + oitem.Product2.L2I_Feature_ID__c + ':' + oitem.L2I_CCC_Suffix__c + ':' + oitem.L2I_blng_MatchingId__c;
                    } else {
                        oitem.blng__InvoiceGroupId__c = oitem.Order.L2I_Original_Sales_Opportunity__c + ':' + oitem.Product2.L2I_Feature_ID__c + ':' + oitem.L2I_CCC_Suffix__c;
                    }
                }
                oitem.blng__InvoiceGrouping__c = 'Invoice Group ID';
                oitem.blng__LegalEntity__c = defaultLegalEntity;


                // (2) Set Billing Treatment for TB Product if no billing rule exists
                Id billingRule = productBillingRuleLookup.get(oitem.Product2Id);
                if (oitem.Product2Id == TB_Product_ID) {
                    String connFreq = oitem.SBQQ__QuoteLine__r.L2I_Connecctivity_Frequency__c;
                    System.debug('====== Setting Billing Rule for TB_Product. Connectivity Frequency is : ' + connFreq);
                    switch on connFreq {
                        when 'Annually(1)' {
                            oitem.blng__BillingRule__c = Billable_Product_Rule_100_ID;
                            System.debug('====== Setting Billing Rule Value as X100 value : ' + Billable_Product_Rule_100_ID);
                        }
                        when 'Semi-Annual(2)' {
                            oitem.blng__BillingRule__c = Billable_Product_Rule_Semi_Annual_ID;
                            System.debug('====== Setting Billing Rule Value as Quarterly value : ' + Billable_Product_Rule_Semi_Annual_ID);
                        }when 'Tri-Annual(3)' {
                            oitem.blng__BillingRule__c = Billable_Product_Rule_Tri_Annual_ID;
                            System.debug('====== Setting Billing Rule Value as Quarterly value : ' + Billable_Product_Rule_Tri_Annual_ID);
                        }
                        when 'Quarterly(4)' {
                            oitem.blng__BillingRule__c = Billable_Product_Rule_Quarterly_ID;
                            System.debug('====== Setting Billing Rule Value as Quarterly value : ' + Billable_Product_Rule_Quarterly_ID);
                        }
                        when else {
                            oitem.blng__BillingRule__c = Billable_Product_Rule_ID;
                            System.debug('====== Setting Billing Rule Value as default value : ' + Billable_Product_Rule_ID);
                        }
                    }
                }

                // (3) Set Boingo Billing Account
                if ('PA-CHTSPTBG-YYYY'.equalsIgnoreCase(oitem.L2I_Product_Code__c)) {
                    oitem.blng__BillingAccount__c = boingoAccountId;
                    //System.debug('====== Setting Boingo Account Id');
                }

                // (4) Set iPass Billing Account
                if ('PA-CHTSPTIPS-YYYY'.equalsIgnoreCase(oitem.L2I_Product_Code__c)) {
                    oitem.blng__BillingAccount__c = ipassAccountId;
                    //System.debug('====== Setting iPass Account Id');
                }

                // Workflow rule: Update Adv Order Product Type Fields Based on Product
                if (oitem.Quantity > 0) {
                    String productName = oitem.L2I_ProductName__c;
                    if (campaignType.containsKey(productName)) {
                        oitem.L2I_Campaign_Type__c = campaignType.get(oitem.L2I_ProductName__c);
                    }
                    if (revenueType.containsKey(productName)) {
                        oitem.L2I_Revenue_Type__c = revenueType.get(oitem.L2I_ProductName__c);
                    }
                    if (goalType.containsKey(productName)) {
                        oitem.L2I_Goal_Type__c = goalType.get(oitem.L2I_ProductName__c);
                    }
                }

                // Workflow rule: L2I Copy Included Usage on Order Product
                if ('PA-MCS17V0VRG-001'.equalsIgnoreCase(oitem.L2I_Product_Code__c) ||
                        'PA-MCS17A0VRG-001'.equalsIgnoreCase(oitem.L2I_Product_Code__c)) {
                    oitem.blng__IncludedUsage__c = oitem.SBQQ__QuoteLine__r.L2I_IncludedUsage__c;
                }
            }

            if (!affectedOrderItemList.isEmpty()) {
                update affectedOrderItemList;
                System.debug('====== Updated ' + affectedOrderItemList.size() + ' OrderItems after creation');
            }
        }
    }

    //DE 417 - Update the end date on parent order if the end date is greater than existing date
    //Removing the trigger update due to a recursive call to the parent record
    /*
    public static void updateEndDateOnParentAfterUpdate(List<OrderItem> newOrderItemList, Map<Id, OrderItem> oldOrderItemMap ) {

        Map<Id, Date> orderIdEndDateMap = new Map<Id, Date>();

        for ( OrderItem oitem : newOrderItemList ){
            if ( oldOrderItemMap.get(oitem.id) != null &&
                 oldOrderItemMap.get(oitem.id).EndDate != null &&
                 oitem.EndDate != oldOrderItemMap.get(oitem.id).EndDate  ) {
                if (orderIdEndDateMap.get(oitem.OrderId) != null) {
                    if (oitem.EndDate > orderIdEndDateMap.get(oitem.OrderId)) {
                        orderIdEndDateMap.put (oitem.OrderId, oitem.EndDate);
                    }
                } else {
                    orderIdEndDateMap.put (oitem.OrderId, oitem.EndDate);
                }
            }
        }

        if ( orderIdEndDateMap.size() > 0 ) {
            List<Order> affectedOrderList = [
                    SELECT Id, L2I_Order_End_date__c
                    FROM Order
                    WHERE Id IN :orderIdEndDateMap.keyset()
            ];
            List<Order> updatedOrderList = new List<Order>();

            for (Order ord : affectedOrderList) {
                if (orderIdEndDateMap.get(ord.Id) != null) {
                    if (ord.L2I_Order_End_date__c < orderIdEndDateMap.get(ord.Id)) {
                        ord.L2I_Order_End_date__c = orderIdEndDateMap.get(ord.Id);
                        updatedOrderList.add(ord);
                    }
                }
            }

            if (updatedOrderList.size() > 0) {
                update updatedOrderList;
            }
        }

    }

     */

    /**
    * @description 
    * To populate L2I_Price_List_ID__c on OrderItem from Opportunity.PT_Price_List__c.PT_EBS_PriceList__c
    * Changing PT_EBS_PriceList__c to L2I_Header_ExternalId__c
    * @author Arun | 01-27-2021 
    * @param List<OrderItem> newOrderItemList 
    **/
    public static void populateLisPriceId(List<OrderItem> newOrderItemList) {
        Map<Id, String> orderToPriceListMap = new Map<Id, String>();
        for(OrderItem item: newOrderItemList) {
            orderToPriceListMap.put(item.OrderId, null);
        }

        for(Order order: [Select Id, OpportunityId, Opportunity.PT_Price_List__c, Opportunity.PT_Price_List__r.L2I_Header_ExternalId__c From Order Where Id IN :orderToPriceListMap.keySet()]) {
            if(order.OpportunityId != null && order.Opportunity.PT_Price_List__c != null && !String.isBlank(order.Opportunity.PT_Price_List__r.L2I_Header_ExternalId__c)) {
                orderToPriceListMap.put(order.Id, order.Opportunity.PT_Price_List__r.L2I_Header_ExternalId__c);
            } else {
                orderToPriceListMap.remove(order.Id);
            }
        }

        for(OrderItem item: newOrderItemList) {
            if(orderToPriceListMap.containsKey(item.OrderId)) {
                try{
                    item.L2I_Price_List_ID__c = Decimal.valueOf(orderToPriceListMap.get(item.OrderId));
                } catch (Exception e) { System.debug('failed to convert '+item.OrderId+':'+orderToPriceListMap.get(item.OrderId)+' to decimal value'); }
            }
        }
    }
}