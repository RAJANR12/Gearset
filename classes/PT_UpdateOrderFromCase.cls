/**
 * Created By Arun - 01-22-2021
 * To update the OrderItem quantity with Asset PT_Order_Quantity__c
 * To create new Orders and OrderItems for new assets based on Order Splitting
 */

global class PT_UpdateOrderFromCase {

    @InvocableMethod
    public static void updateOrders(List<FlowInput> inputs) {
        String caseId;
        Id priceBookId;
        List<Asset> assets = new List<Asset>();
        List<Order> newOrders = new List<Order>();
        List<OrderItem> items = new List<OrderItem>();
        Map<Id, Order> ordersToUpdate = new Map<Id, Order>();
        Map<Id, OrderItem> orderItemsToUpdate = new Map<Id, OrderItem>();
        Map<Id, Order> ordersToIntegrate = new Map<Id, Order>();

        try {
            for(FlowInput inId : inputs) {
                caseId = inId.caseId;
                System.debug(caseId);
            }

            Case c = [Select Id, AccountId, OwnerId FROM Case WHERE Id = :caseId];

            assets = new List<Asset>([SELECT Id, PT_Order_Quantity__c, SBQQ__OrderProduct__c, SBQQ__OrderProduct__r.OrderId,
                                        SBQQ__OrderProduct__r.Quantity, SBQQ__OrderProduct__r.Order.PT_Ext_Order_Header_Status__c,
                                        SBQQ__OrderProduct__r.Order.PT_Integration_Status__c, PT_CCC__c, PT_Order_Splitting__c,
                                        Product2Id, Quantity, SBQQ__ChargeType__c, SBQQ__UnitCost__c, SBQQ__QuoteLine__r.SBQQ__PricebookEntryId__c,
                                        SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__PriceBook__c
                                        FROM Asset
                                        WHERE PT_Case__c =: caseId AND
                                            SBQQ__OrderProduct__r.Order.PT_Ext_Order_Header_Status__c != 'CLOSED' AND
                                            SBQQ__OrderProduct__r.Order.PT_Ext_Order_Header_Status__c != 'CANCELLED']);

            if(assets.size() > 0) {
                priceBookId = assets[0].SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__PriceBook__c;
            }

            Set<Id> prodIdList = new Set<Id>();
            Set<Id> newAssets = new Set<Id>();
            Map<String, Id> ordersMap = new Map<String, Id>();
            Map<String, List<Asset>> assetsCCCMap = new Map<String, List<Asset>>();

            for(Asset asset: assets) {
                // Pushlish events for all the orders associated with case
                if(asset.SBQQ__OrderProduct__r.OrderId != null && !ordersToIntegrate.containsKey(asset.SBQQ__OrderProduct__r.OrderId)) {
                    ordersToIntegrate.put(asset.SBQQ__OrderProduct__r.OrderId, new Order(
                                            Id = asset.SBQQ__OrderProduct__r.OrderId,
                                            PT_Integration_Status__c = asset.SBQQ__OrderProduct__r.Order.PT_Integration_Status__c,
                                            PT_Ext_Order_Header_Status__c = asset.SBQQ__OrderProduct__r.Order.PT_Ext_Order_Header_Status__c));
                }

                // update the OrderItem quantity with Asset PT_Order_Quantity__c if it's different
                if(asset.SBQQ__OrderProduct__c != null && asset.PT_Order_Quantity__c != asset.SBQQ__OrderProduct__r.Quantity) {
                    //items.add(new OrderItem(Id = asset.SBQQ__OrderProduct__c, Quantity = asset.SBQQ__OrderProduct__r.Quantity));
                    orderItemsToUpdate.put(asset.SBQQ__OrderProduct__c, new OrderItem(Id = asset.SBQQ__OrderProduct__c, Quantity = asset.PT_Order_Quantity__c));
                    ordersToUpdate.put(asset.SBQQ__OrderProduct__r.OrderId, new Order(Id = asset.SBQQ__OrderProduct__r.OrderId, PT_Integration_Status__c = 'Ready to Integrate'));
                }

                if(asset.SBQQ__OrderProduct__c != null) {
                    ordersMap.put(asset.PT_Order_Splitting__c, asset.SBQQ__OrderProduct__r.OrderId);
                } else {
                    if(assetsCCCMap.containsKey(asset.PT_Order_Splitting__c)) {
                        assetsCCCMap.get(asset.PT_Order_Splitting__c).add(asset);
                    } else {
                        assetsCCCMap.put(asset.PT_Order_Splitting__c, new List<Asset> {asset});
                    }
                    newAssets.add(asset.Id);
                }

                prodIdList.add(asset.Product2Id);
            }

            // create orders
            for (String ccc : assetsCCCMap.keySet()) {
                if(ordersMap.containsKey(ccc)) { continue; }

                newOrders.add(createNewOrder(ccc, c, priceBookId, 'Ready to Integrate'));
            }
            newOrders.addAll(ordersToUpdate.values());

            system.debug('newOrders:' + newOrders);
            system.debug('ordersToIntegrate:' + ordersToIntegrate);
            if (newOrders.size() > 0) {
                upsert newOrders;
                //PT_CreateOrderControllerHandler.publishCreateOrder(newOrders);
            }
            // pusblish create order event
            if(!ordersToIntegrate.isEmpty()) { publishCreateOrder(ordersToIntegrate.values()); }

            for(Order order: newOrders) {
                ordersMap.put(order.Name, order.Id);
            }

            // Create OrderItems
            blng__BillingRule__c blngRule = [ SELECT Id FROM blng__BillingRule__c WHERE Name = 'Non-Billable Product Rule' LIMIT 1];

            Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
            for(PricebookEntry pbe : [select Id, Product2Id, Pricebook2Id, UnitPrice, IsActive from PricebookEntry where Product2Id in: prodIdList]){
                pricebookMap.put(pbe.Product2Id, pbe);
            }

            for(String ccc : assetsCCCMap.keySet()) {
                for(Asset ast : assetsCCCMap.get(ccc)) {
                    items.add(createNewOrderItem(ordersMap.get(ccc), ast, pricebookMap.get(ast.Product2Id).UnitPrice, blngRule));
                }
            }
            items.addAll(orderItemsToUpdate.values());

            system.debug('items: '+items);
            if (items.size() > 0) {
                upsert items;
            }

            // Update Assets with specific OrderItem
            List<Asset> assetsToUpdate = new List<Asset>();
            for (OrderItem oi : items) {
                if(!newAssets.contains(oi.SBQQ__Asset__c)) { continue; }
                assetsToUpdate.add(new Asset (Id = oi.SBQQ__Asset__c, SBQQ__OrderProduct__c = oi.Id));
            }

            if (assetsToUpdate.size() > 0) {
                update assetsToUpdate;
            }

        } catch (DMLException e) {
            System.debug('DML Exception error: ' + e);
            throw new AuraHandledException('There was an error in Assigning CPL: ' + e.getMessage());
        }
    }

    public class FlowInput {
        @InvocableVariable
        public String caseId;
    }

    /**
    * @description
    * @author Arun | 01-22-2021
    * @param String orderName
    * @param Case c
    * @param Id priceBookId
    * @return Order
    **/
    public static Order createNewOrder(String orderName, Case c, Id priceBookId, String integrationStatus) {
        return new Order(AccountId = c.AccountId, EffectiveDate = Date.today(), Status = 'Draft', Name = orderName, blng__BillingDayOfMonth__c = '1', Pricebook2Id = priceBookId, SBQQ__PriceCalcStatus__c = 'Completed', L2I_Order_Process__c = 'Program Table', PT_Case__c = c.Id, OwnerId = c.OwnerId, PT_Integration_Status__c = integrationStatus);
    }

    /**
    * @description
    * @author Arun | 01-22-2021
    * @param Id orderId
    * @param Asset ast
    * @param Decimal unitPrice
    * @param blng__BillingRule__c blngRule
    * @return OrderItem
    **/
    public static OrderItem createNewOrderItem(Id orderId, Asset ast, Decimal unitPrice, blng__BillingRule__c blngRule) {
        return new OrderItem(OrderId = orderId, Quantity = (ast.PT_Order_Quantity__c == null ? 1 : ast.PT_Order_Quantity__c), Product2Id = ast.Product2Id, SBQQ__ChargeType__c = 'One-Time', SBQQ__Asset__c = ast.id, PricebookEntryId = ast.SBQQ__QuoteLine__r.SBQQ__PricebookEntryId__c, UnitPrice = unitPrice, blng__BillingRule__c = blngRule.id);
    }

    // Added by Arun
    public static void publishCreateOrder(List<Order> orders) {
        Map<String, PT_Create_Order__e> createOrders = new Map<String, PT_Create_Order__e >();
        Set<String> orderHeaderStatus = new Set<String>{'CLOSED','CANCELLED'};
        for(Order order: orders) {
            //if(order.PT_Integration_Status__c != 'Ready to Integrate') { continue; }

            if(!orderHeaderStatus.contains(order.PT_Ext_Order_Header_Status__c)) {
                createOrders.put(order.Id, new PT_Create_Order__e(L2I_OrderId__c = order.Id, L2I_Order_Process__c = 'Program Table'));
            }
        }
        if(!createOrders.isEmpty()) { EventBus.publish(createOrders.values());}
    }
}