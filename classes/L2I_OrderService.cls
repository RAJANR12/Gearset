/**
 *      @author       Sarah Kennedy
 *      @date         07/16/2020
 *      @description  Service class for Orders
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 07/15/2020         Initial creation
 *
 */
public with sharing class L2I_OrderService {
    public static Set<Id> determineReviseModified(Set<Id> reviseCheckOrderIds) {
        System.debug('*** Starting L2I_OrderService.determineReviseModified ' + reviseCheckOrderIds);
        Map<Id, Map<String, List<OrderItem>>> renewedContractProdCat2OiListMap = new Map<Id, Map<String, List<OrderItem>>>();
        Map<Id, Map<String, Set<Id>>> renewedContractProdCat2OrderListMap = new Map<Id, Map<String, Set<Id>>>();
        Map<Id, Map<String, List<SBQQ__Subscription__c>>> renewedContractProdCat2SubListMap = new Map<Id, Map<String, List<SBQQ__Subscription__c>>>();
        Map<Id, Boolean> ordIdFoundMatchMap = new Map<Id, Boolean>();
        Set<String> prodCat2s = new Set<String>();
        Set<Id> revisedOrderIds = new Set<Id>();
        try {
            // get the Renewal Order's orderitems
            for (OrderItem renewalOrderItem : [
                  SELECT
                        Id,
                        OrderId,
                        Order.Opportunity.SBQQ__RenewedContract__c,
                        Product2.L2I_Sub_Category_2__c,
                        L2I_blng_MatchingId__c
                  FROM OrderItem
                  WHERE OrderId IN :reviseCheckOrderIds
                  AND Order.L2I_Order_Process__c = 'Contract Management'
                  AND Order.Type = 'Renewal'
                  AND L2I_blng_MatchingId__c <> NULL
                  AND SBQQ__ChargeType__c <> 'One-Time'
            ]) {
                // save order map to determine if mismatch between orderitems and subscriptions
                ordIdFoundMatchMap.put(renewalOrderItem.OrderId, true);
                // save renewal orderitems by renewed contract and prod cat2
                List<OrderItem> ordItemList = new List<OrderItem>();
                Set<Id> ordIds = new Set<Id>();
                Id renewedContract = renewalOrderItem.Order.Opportunity.SBQQ__RenewedContract__c;
                String prodCat2 = renewalOrderItem.Product2.L2I_Sub_Category_2__c;
                System.debug('*** renewedContract ' + renewedContract);
                System.debug('*** prodCat2 ' + prodCat2);
                
                if (!renewedContractProdCat2OiListMap.containsKey(renewedContract)) {
                    renewedContractProdCat2OiListMap.put(renewedContract, new Map<String, List<OrderItem>>());
                }
                if (!renewedContractProdCat2OiListMap.get(renewedContract).containsKey(prodCat2)) {
                    renewedContractProdCat2OiListMap.get(renewedContract).put(prodCat2, new List<OrderItem>());
                }
                ordItemList = renewedContractProdCat2OiListMap.get(renewedContract).get(prodCat2);
                ordItemList.add(renewalOrderItem);
                renewedContractProdCat2OiListMap.get(renewedContract).put(prodCat2, ordItemList);
                
                if (!renewedContractProdCat2OrderListMap.containsKey(renewedContract)) {
                    renewedContractProdCat2OrderListMap.put(renewedContract, new Map<String, Set<Id>>());
                }
                if (!renewedContractProdCat2OrderListMap.get(renewedContract).containsKey(prodCat2)) {
                    renewedContractProdCat2OrderListMap.get(renewedContract).put(prodCat2, new Set<Id>());
                }
                ordIds = renewedContractProdCat2OrderListMap.get(renewedContract).get(prodCat2);
                ordIds.add(renewalOrderItem.OrderId);
                renewedContractProdCat2OrderListMap.get(renewedContract).put(prodCat2, ordIds);
                
                prodCat2s.add(prodCat2);
            }
            System.debug('*** renewedContractProdCat2OiListMap.size() ' + renewedContractProdCat2OiListMap.size());
            System.debug('*** renewedContractProdCat2OrderListMap.size() ' + renewedContractProdCat2OiListMap.size());
            
            if (renewedContractProdCat2OiListMap.isEmpty()) {
                System.debug('***No Activated Renewal Orders with a Contracted Renewal were found"');
                return null;
            }
            
            // get the renewed contracts' subscriptions
            for (SBQQ__Subscription__c renewedContractSubscription : [
                  SELECT
                        Id,
                        SBQQ__Contract__c,
                        SBQQ__OrderProduct__c,
                        SBQQ__EndDate__c,
                        SBQQ__TerminatedDate__c,
                        SBQQ__SubscriptionType__c,
                        SBQQ__Product__r.L2I_Sub_Category_2__c,
                        L2I_blng_MatchingId__c
                  FROM SBQQ__Subscription__c
                  WHERE SBQQ__Contract__c IN :renewedContractProdCat2OiListMap.keySet()
                  AND SBQQ__SubscriptionType__c <> 'One-time'
                  AND SBQQ__Product__r.L2I_Sub_Category_2__c IN :prodCat2s
                  AND L2I_blng_MatchingId__c <> NULL
            ]) {
                // save renewed subscriptions by renewed contract and prod cat2
                List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
                Id renewedContract = renewedContractSubscription.SBQQ__Contract__c;
                String prodCat2 = renewedContractSubscription.SBQQ__Product__r.L2I_Sub_Category_2__c;
                
                if (!renewedContractProdCat2SubListMap.containsKey(renewedContract)) {
                    renewedContractProdCat2SubListMap.put(renewedContract, new Map<String, List<SBQQ__Subscription__c>>());
                }
                if (!renewedContractProdCat2SubListMap.get(renewedContract).containsKey(prodCat2)) {
                    renewedContractProdCat2SubListMap.get(renewedContract).put(prodCat2, new List<SBQQ__Subscription__c>());
                }
                subList = renewedContractProdCat2SubListMap.get(renewedContract).get(prodCat2);
                subList.add(renewedContractSubscription);
                renewedContractProdCat2SubListMap.get(renewedContract).put(prodCat2, subList);
            }
            System.debug('*** renewedContractProdCat2SubListMap.size() ' + renewedContractProdCat2SubListMap.size());
            
            // read the Renewal Order Items and match to Contracted Subscriptions by matching Id
            for (Id renewedContractId : renewedContractProdCat2OiListMap.keySet()) {
                System.debug('*** oi renewedContractId ' + renewedContractId);
                Map<String, List<OrderItem>> prodCat2OiListMap = renewedContractProdCat2OiListMap.get(renewedContractId);
                for (String prodCat2 : prodCat2OiListMap.keySet()) {
                    System.debug('*** oi prodCat2 ' + prodCat2);
                    List<OrderItem> ordItemList = prodCat2OiListMap.get(prodCat2);
                    for (OrderItem oi : ordItemList) {
                        System.debug('*** oi oi ' + oi);
                        // if the orderitem's order already had another orderitem mismatch with subscriptions, then don't need to process
                        if (ordIdFoundMatchMap.get(oi.OrderId)) {
                            if (renewedContractProdCat2SubListMap.containsKey(renewedContractId)) {
                                Map<String, List<SBQQ__Subscription__c>> prodCat2SubListMap = renewedContractProdCat2SubListMap.get(renewedContractId);
                                if (prodCat2SubListMap.containsKey(prodCat2)) {
                                    List<SBQQ__Subscription__c> subList = prodCat2SubListMap.get(prodCat2);
                                    Boolean foundMatch = false;
                                    for (SBQQ__Subscription__c sub : subList) {
                                        System.debug('*** oi sub ' + sub);
                                        if (oi.L2I_blng_MatchingId__c == sub.L2I_blng_MatchingId__c) {
                                            // Item has not been removed or replaced
                                            foundMatch = true;
                                            break;
                                        }
                                    }
                                    if (!foundMatch) {
                                        ordIdFoundMatchMap.put(oi.OrderId, false);
                                    }
                                } else {
                                    ordIdFoundMatchMap.put(oi.OrderId, false);
                                }
                            } else {
                                // no sub found
                                ordIdFoundMatchMap.put(oi.OrderId, false);
                            }
                        }
                    }
                }
            }
            System.debug('*** after oiList ordIdFoundMatchMap.size() ' + ordIdFoundMatchMap.size());
            System.debug('*** after oiList ordIdFoundMatchMap ' + ordIdFoundMatchMap);
            
            // find Contracted Subscriptions that have no match to the Renewal Order Items by Matching Id
            for (Id renewedContractId : renewedContractProdCat2SubListMap.keySet()) {
                System.debug('*** sub renewedContractId ' + renewedContractId);
                Map<String, List<SBQQ__Subscription__c>> prodCat2SubListMap = renewedContractProdCat2SubListMap.get(renewedContractId);
                for (String prodCat2 : prodCat2SubListMap.keySet()) {
                    System.debug('*** sub prodCat2 ' + prodCat2);
                    List<SBQQ__Subscription__c> subList = prodCat2SubListMap.get(prodCat2);
                    for (SBQQ__Subscription__c sub : subList) {
                        System.debug('*** sub sub ' + sub);
                        if (renewedContractProdCat2OiListMap.containsKey(renewedContractId)) {
                            Map<String, List<OrderItem>> prodCat2SOiListMap = renewedContractProdCat2OiListMap.get(renewedContractId);
                            if (prodCat2SOiListMap.containsKey(prodCat2)) {
                                List<OrderItem> oiList = prodCat2SOiListMap.get(prodCat2);
                                Boolean foundOi = false;
                                for (OrderItem oi : oiList) {
                                    System.debug('*** sub oi ' + oi);
                                    if (oi.L2I_blng_MatchingId__c == sub.L2I_blng_MatchingId__c) {
                                        foundOi = true;
                                        break;
                                    }
                                }
                                // renewed subscription has been removed or replaced with new renewal orderitems
                                if (!foundOi) {
                                    System.debug('*** sub oi not found');
                                    // find the order
                                    Set<Id> OrdIds = new Set<Id>();
                                    if (renewedContractProdCat2OrderListMap.containsKey(renewedContractId)) {
                                        if (renewedContractProdCat2OrderListMap.get(renewedContractId).containsKey(prodCat2)) {
                                            ordIds = renewedContractProdCat2OrderListMap.get(renewedContractId).get(prodCat2);
                                            System.debug('*** looking for Order ' + ordIds);
                                            for (Id oId : ordIds) {
                                                if (ordIdFoundMatchMap.containsKey(oId)) {
                                                    System.debug('*** found order ' + oId);
                                                    ordIdFoundMatchMap.put(oId, false);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            System.debug('*** after subList ordIdFoundMatchMap' + ordIdFoundMatchMap);
            
            List<Order> updateOrderList = new List<Order>();
            List<Order> autoActivateOrderList = new List<Order>();
            List<Order> revisedOrderList = new List<Order>();
            
            for (Id i : ordIdFoundMatchMap.keySet()) {
                if (!ordIdFoundMatchMap.get(i)) {
                    revisedOrderIds.add(i);
                }
            }
            System.debug('*** finding any revised orders ' + revisedOrderIds);
            if (!revisedOrderIds.isEmpty()) {
                revisedOrderList = [
                      SELECT Id,
                            L2I_Revise_Modified__c
                      FROM Order
                      WHERE Id IN :revisedOrderIds
                ];
                for (Order o : revisedOrderList) {
                    System.debug('*** Setting to revised ' + o);
                    o.L2I_Revise_Modified__c = true;
                    updateOrderList.add(o);
                }
            }
            // set orders to auto-activate
            System.debug('*** finding any auto-activate orders ');
            // find orders that have not been set to Revise Modified
            autoActivateOrderList = [
                  SELECT Id,
                        L2I_Product_Category_2__c, L2I_AutoActivate__c
                  FROM Order
                  WHERE Id NOT IN :revisedOrderIds
                  AND Id IN :reviseCheckOrderIds
                  AND L2I_Product_Category_2__c != 'MCS'
            ];
            for (Order o : autoActivateOrderList) {
                System.debug('*** Setting to autoactivate ' + o);
                o.L2I_AutoActivate__c = true;
                updateOrderList.add(o);
            }
            System.debug('*** updateOrderList.size() ' + updateOrderList.size() );
            if (updateOrderList != null && updateOrderList.size() > 0) {
                update updateOrderList;
            }
            System.debug('*** updateOrderList ' + updateOrderList);
        
        } catch (Exception e) {
            String idStr = '';
            for (String s : reviseCheckOrderIds) {
                idStr += (idStr == '' ? '' : ',') + s;
            }
            L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
                  'Exception occurred running L2I_OrderService.determineReviseModified : ' + ' -' + e.getMessage(),
                  'Order', idStr, UserInfo.getUserId(), false);
            System.debug('*** Exception occurred running L2I_OrderService.determineReviseModified (see System Alerts): ' + e.getMessage());
        }
        return revisedOrderIds;
    }
}