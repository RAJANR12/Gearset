/**
 *      @author       Nitin Gupta
 *      @date         10/29/2020
 *      @description  Create Orders Controller Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Nitin Gupta                10/29/2020        Initial creation
 */


public class PT_CreateOrderControllerHandler {
    public static List<Asset> caseAssets = new List <Asset>();
    public static Map<String, List<Asset>> assetsCCCMap = new Map<String, List<Asset>>();
    public static Id acctId;

    public static void createOrderFromCase(Id caseId) {
        Id priceBookId;
        Case c = [Select Id, AccountId, OwnerId FROM Case WHERE Id = :caseId];
        acctId = c.AccountId;
        caseAssets = [SELECT Id, PT_CCC__c, PT_Order_Splitting__c, Product2Id, Quantity, SBQQ__ChargeType__c, SBQQ__UnitCost__c,
                        SBQQ__QuoteLine__r.SBQQ__PricebookEntryId__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__PriceBook__c, PT_Order_Quantity__c,
                        SBQQ__QuoteLine__r.SBQQ__NetPrice__c // Added by Lipton for W-003637
                        FROM Asset
                        WHERE PT_Case__c = :caseId];
        
        System.debug('ChecaseAssets' + caseAssets);
        
        if (caseAssets.size() > 0) {
            priceBookId = caseAssets[0].SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__PriceBook__c;

        }
        System.debug('Cheeeee' + caseAssets[0].SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__PriceBook__c);
        System.debug('AssetCAses::' + caseAssets);
        System.debug('priceBookIdChk::' + priceBookId);
        Set<Id> prodIdList = New Set<Id>();
        for (Asset ast : caseAssets) {
            if(assetsCCCMap.containsKey(ast.PT_Order_Splitting__c)) {
                assetsCCCMap.get(ast.PT_Order_Splitting__c).add(ast);
            } else {
                assetsCCCMap.put(ast.PT_Order_Splitting__c, new List<Asset> {ast});
            }
            prodIdList.add(ast.Product2Id);
        }

        /*
        List<Pricebook2> pb = [SELECT Id, L2I_Migration_External_Id__c FROM Pricebook2 WHERE L2I_IFEC_Default_Pricebook__c = TRUE LIMIT 1];
            if (pb.size() == 1) {
                priceBookId = pb[0].Id;
            }
        */
  system.debug('CheckassetsCCCMap::' + assetsCCCMap);
        blng__BillingRule__c billingrule = [ SELECT Id FROM blng__BillingRule__c WHERE Name = 'Non-Billable Product Rule' LIMIT 1];

        List<Order> insertOrders = new List<Order>();
        List<OrderItem> insertOrderItems = new List<OrderItem>();
        for (String ccc : assetsCCCMap.keySet()) {
            insertOrders.add(new Order(
                    AccountId = acctId,
                    EffectiveDate = Date.today(),
                    Status = 'Draft',
                    Name = ccc,
                    blng__BillingDayOfMonth__c = '1',
                    Pricebook2Id = priceBookId,
                    SBQQ__PriceCalcStatus__c = 'Completed',
                    L2I_Order_Process__c = 'Program Table',
                    PT_Case__c = caseId,
                    PT_Integration_Status__c = 'Ready to Integrate',
                    OwnerId = c.OwnerId // Added by Arun - 01.13.21
                ));
        }
        system.debug('CheckinsertOrders::' + insertOrders);
        if (insertOrders.size() > 0) {
            insert insertOrders;
            //publishCreateOrder(insertOrders); // Added by Arun
        }
        Map<String, Id> orderIdCCCMap = new Map<String, Id>();
        for (Order ord : insertOrders) {
            orderIdCCCMap.put(ord.Name, ord.Id);
        }

        List<PricebookEntry> pbeList = [select Id,
                                               Product2Id,
                                               Pricebook2Id,
                                               UnitPrice,
                                               IsActive
                                          from PricebookEntry
                                         where Product2Id in: prodIdList];
        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : pbeList ){
            pricebookMap.put( pbe.Product2Id, pbe );
        }

        for (String ccc : assetsCCCMap.keySet()) {
            for (Asset ast : assetsCCCMap.get(ccc)) {
                    insertOrderItems.add(new OrderItem(
                                            OrderId = orderIdCCCMap.get(ccc),
                                            //Quantity = ast.Quantity, // Commented by Arun - 01.13.21
                                            Quantity = ast.PT_Order_Quantity__c, // Added by Arun - 01.13.21
                                            Product2Id = ast.Product2Id,
                                            SBQQ__ChargeType__c = 'One-Time',
                                            SBQQ__Asset__c = ast.id,
                                            PricebookEntryId = ast.SBQQ__QuoteLine__r.SBQQ__PricebookEntryId__c,
                                            UnitPrice = ast.SBQQ__QuoteLine__r.SBQQ__NetPrice__c, // Added by Lipton for W-003637
                                            // UnitPrice = pricebookMap.get(ast.Product2Id).UnitPrice,
                                            blng__BillingRule__c = billingrule.id
                    ));
            }
        }
        
        system.debug('ChekkinsertOrderItems' + insertOrderItems);
        if (insertOrderItems.size() > 0) {
            insert insertOrderItems;
            // Once Order and Order items are inserted, update the the case status to "Ordered".
            c.Status = 'Ordered';
            update c;
        }
        List<Asset> assetsToUpdate = new List<Asset>();
        for (OrderItem oi : insertOrderItems) {
            assetsToUpdate.add(new Asset (Id = oi.SBQQ__Asset__c, SBQQ__OrderProduct__c = oi.Id));
        }

        if (assetsToUpdate.size() > 0) {
            update assetsToUpdate;
        }
    }

    // Added by Arun
    // public static void publishCreateOrder(List<Order> orders) {
    //     Map<String, PT_Create_Order__e> createOrders = new Map<String, PT_Create_Order__e >();
    //     Set<String> orderHeaderStatus = new Set<String>{'CLOSED','BOOKED','PENDING APPROVAL','CANCELLED','ENTERED','APPROVED'};
    //     for(Order order: orders) {
    //         if(order.PT_Integration_Status__c == 'Ready to Integrate' && !orderHeaderStatus.contains(order.PT_Ext_Order_Header_Status__c)) {
    //             createOrders.put(order.Id, new PT_Create_Order__e(L2I_OrderId__c = order.Id, L2I_Order_Process__c = 'Program Table'));
    //         }
    //     }
    //     if(!createOrders.isEmpty()) { EventBus.publish(createOrders.values());}
    // }
}