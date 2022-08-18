/**
 *      @author       Sarah Kennedy
 *      @date         05/14/2020
 *      @description  Service class for Cancel/Replace Contracts
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 05/14/2020         Initial creation
 *      Sarah Kennedy                 06/30/2020         US2071 - removed @Future
 *
 */
global with sharing class L2I_CancelReplaceService {

//    public static void cancelPrior(Set<Id> contractIds) {
//        System.debug('====== Starting L2I_CancelReplaceService.cancelPrior AutoExtend Contracts:' + contractIds);
//
//        if (contractIds.isEmpty()) {
//            System.debug('*** No AutoExtend Contracts are to be processed');
//            return;
//        }
//
//        Map<Id, Map<String, List<OrderItem>>> renewedContractProdCat2OiListMap = new Map<Id, Map<String, List<OrderItem>>>();
//        Map<Id, Map<String, List<SBQQ__Subscription__c>>> renewedContractProdCat2SubListMap = new Map<Id, Map<String, List<SBQQ__Subscription__c>>>();
//        Map<Id, Map<String, Date>> renewedContractProdCat2OrderEffDateMap = new Map<Id, Map<String, Date>>();
//        Map<Id, Date> subsToTerminateMap = new Map<Id, Date>();
//        Map<Id, Date> subOIsToTerminateMap = new Map<Id, Date>();
//
//        try {
//            // get the Renewal Order's orderitems
//            for (OrderItem renewalOrderItem : [
//                  SELECT
//                        Id,
//                        OrderId,
//                        Order.Opportunity.SBQQ__RenewedContract__c,
//                        Order.Opportunity.SBQQ__RenewedContract__r.L2I_ToBeTerminated__c,
//                        Order.Status,
//                        Order.Type,
//                        Order.EffectiveDate,
//                        ServiceDate,
//                        SBQQ__TerminatedDate__c,
//                        Product2.L2I_Sub_Category_2__c,
//                        L2I_blng_MatchingId__c
//                  FROM OrderItem
//                  WHERE Order.Type = 'Renewal'
//                  AND Order.Status = 'Activated'
//                  AND Order.OpportunityId <> NULL
//                  AND Order.Opportunity.SBQQ__RenewedContract__c IN :contractIds
//                  AND L2I_blng_MatchingId__c <> NULL
//            ]) {
//                // save renewal orderitems by renewed contract and prod cat2
//                List<OrderItem> ordItemList = new List<OrderItem>();
//                Id renewedContract = renewalOrderItem.Order.Opportunity.SBQQ__RenewedContract__c;
//                String prodCat2 = renewalOrderItem.Product2.L2I_Sub_Category_2__c;
//                Date effDate = renewalOrderItem.Order.Opportunity.SBQQ__RenewedContract__r.L2I_ToBeTerminated__c;
//                System.debug('*** renewedContract ' + renewedContract);
//                System.debug('*** prodCat2 ' + prodCat2);
//                System.debug('*** effDate ' + effDate);
//
//                if (!renewedContractProdCat2OiListMap.containsKey(renewedContract)) {
//                    renewedContractProdCat2OiListMap.put(renewedContract, new Map<String, List<OrderItem>>());
//                }
//                if (!renewedContractProdCat2OiListMap.get(renewedContract).containsKey(prodCat2)) {
//                    renewedContractProdCat2OiListMap.get(renewedContract).put(prodCat2, new List<OrderItem>());
//                }
//                ordItemList = renewedContractProdCat2OiListMap.get(renewedContract).get(prodCat2);
//                ordItemList.add(renewalOrderItem);
//                renewedContractProdCat2OiListMap.get(renewedContract).put(prodCat2, ordItemList);
//                // save off the Renewal Order's Renewed Contract ToBeTerminated date for terminating renewed subscriptions that have been
//                // removed/replaced from the Renewal Order
//                if (!renewedContractProdCat2OrderEffDateMap.containsKey(renewedContract)) {
//                    renewedContractProdCat2OrderEffDateMap.put(renewedContract, new Map<String, Date>());
//                }
//                if (!renewedContractProdCat2OrderEffDateMap.get(renewedContract).containsKey(prodCat2)) {
//                    renewedContractProdCat2OrderEffDateMap.get(renewedContract).put(prodCat2, effDate);
//                }
//                renewedContractProdCat2OrderEffDateMap.get(renewedContract).put(prodCat2, effDate);
//                System.debug('*** renewedContractProdCat2OrderEffDateMap ' + renewedContractProdCat2OrderEffDateMap);
//            }
//            System.debug('*** renewedContractProdCat2OiListMap.size() ' + renewedContractProdCat2OiListMap.size());
//            System.debug('*** renewedContractProdCat2OrderEffDateMap.size() ' + renewedContractProdCat2OrderEffDateMap.size());
//
//            if (renewedContractProdCat2OiListMap.isEmpty()) {
//                System.debug('***No Activated Renewal Orders with a Contracted Renewal were found"');
//                return;
//            }
//
//            // get the renewed contracts' subscriptions
//            for (SBQQ__Subscription__c renewedContractSubscription : [
//                  SELECT
//                        Id,
//                        SBQQ__Contract__c,
//                        SBQQ__OrderProduct__c,
//                        SBQQ__EndDate__c,
//                        SBQQ__TerminatedDate__c,
//                        SBQQ__SubscriptionType__c,
//                        SBQQ__Product__r.L2I_Sub_Category_2__c,
//                        L2I_blng_MatchingId__c
//                  FROM SBQQ__Subscription__c
//                  WHERE SBQQ__TerminatedDate__c = NULL
//                  AND SBQQ__EndDate__c >= TODAY
//                  AND SBQQ__SubscriptionType__c <> 'One-time'
//                  AND SBQQ__Contract__c IN :renewedContractProdCat2OiListMap.keySet()
//                  AND L2I_blng_MatchingId__c <> NULL
//            ]) {
//                // save renewed subscriptions by renewed contract and prod cat2
//                List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
//                Id renewedContract = renewedContractSubscription.SBQQ__Contract__c;
//                String prodCat2 = renewedContractSubscription.SBQQ__Product__r.L2I_Sub_Category_2__c;
//
//                if (!renewedContractProdCat2SubListMap.containsKey(renewedContract)) {
//                    renewedContractProdCat2SubListMap.put(renewedContract, new Map<String, List<SBQQ__Subscription__c>>());
//                }
//                if (!renewedContractProdCat2SubListMap.get(renewedContract).containsKey(prodCat2)) {
//                    renewedContractProdCat2SubListMap.get(renewedContract).put(prodCat2, new List<SBQQ__Subscription__c>());
//                }
//                subList = renewedContractProdCat2SubListMap.get(renewedContract).get(prodCat2);
//                subList.add(renewedContractSubscription);
//                renewedContractProdCat2SubListMap.get(renewedContract).put(prodCat2, subList);
//            }
//            System.debug('*** renewedContractProdCat2SubListMap.size() ' + renewedContractProdCat2SubListMap.size());
//
//            // read the Renewal Order Items and match to Contracted Subscriptions by matching Id
//            for (Id renewedContractId : renewedContractProdCat2OiListMap.keySet()) {
//                System.debug('*** oi renewedContractId ' + renewedContractId);
//                Map<String, List<OrderItem>> prodCat2OiListMap = renewedContractProdCat2OiListMap.get(renewedContractId);
//                for (String prodCat2 : prodCat2OiListMap.keySet()) {
//                    System.debug('*** oi prodCat2 ' + prodCat2);
//                    List<OrderItem> ordItemList = prodCat2OiListMap.get(prodCat2);
//                    for (OrderItem oi : ordItemList) {
//                        System.debug('*** oi oi ' + oi);
//                        if (renewedContractProdCat2SubListMap.containsKey(renewedContractId)) {
//                            Map<String, List<SBQQ__Subscription__c>> prodCat2SubListMap = renewedContractProdCat2SubListMap.get(renewedContractId);
//                            if (prodCat2SubListMap.containsKey(prodCat2)) {
//                                List<SBQQ__Subscription__c> subList = prodCat2SubListMap.get(prodCat2);
//
//                                for (SBQQ__Subscription__c sub : subList) {
//                                    System.debug('*** oi sub ' + sub);
//                                    if (oi.L2I_blng_MatchingId__c == sub.L2I_blng_MatchingId__c) {
//                                        // Item has not been removed or replaced
//                                        // terminate the subscription and related orderitem if the Renewal Order Start Date is before or equal to the
//                                        // renewed subscription end date
//                                        if (sub.SBQQ__EndDate__c >= oi.ServiceDate) {
//                                            subsToTerminateMap.put(sub.Id, oi.ServiceDate.addDays(-1));
//                                            subOIsToTerminateMap.put(sub.SBQQ__OrderProduct__c, oi.ServiceDate.addDays(-1));
//                                            System.debug('*** terminate sub end date >= oi service date subOIsToTerminateMap ' + subOIsToTerminateMap);
//                                            System.debug('*** terminate sub end date >= oi service date ' + oi.Id + ' ' + oi.L2I_blng_MatchingId__c);
//                                        } else {
//                                            System.debug('*** NOT sub end date >= oi service date ' + oi.Id + ' ' + oi.L2I_blng_MatchingId__c);
//                                        }
//                                        break;
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            System.debug('*** after oiList subsToTerminateMap.size() ' + subsToTerminateMap.size());
//            System.debug('*** after oiList subOIsToTerminateMap.size() ' + subOIsToTerminateMap.size());
//
//            // find Contracted Subscriptions that have no match to the Renewal Order Items by Matching Id
//            for (Id renewedContractId : renewedContractProdCat2SubListMap.keySet()) {
//                System.debug('*** sub renewedContractId ' + renewedContractId);
//                Map<String, List<SBQQ__Subscription__c>> prodCat2SubListMap = renewedContractProdCat2SubListMap.get(renewedContractId);
//                for (String prodCat2 : prodCat2SubListMap.keySet()) {
//                    System.debug('*** sub prodCat2 ' + prodCat2);
//                    List<SBQQ__Subscription__c> subList = prodCat2SubListMap.get(prodCat2);
//                    for (SBQQ__Subscription__c sub : subList) {
//                        System.debug('*** sub sub ' + sub);
//                        if (renewedContractProdCat2OiListMap.containsKey(renewedContractId)) {
//                            Map<String, List<OrderItem>> prodCat2SOiListMap = renewedContractProdCat2OiListMap.get(renewedContractId);
//                            if (prodCat2SOiListMap.containsKey(prodCat2)) {
//                                List<OrderItem> oiList = prodCat2SOiListMap.get(prodCat2);
//                                Boolean foundOi = false;
//                                for (OrderItem oi : oiList) {
//                                    System.debug('*** sub oi ' + oi);
//                                    if (oi.L2I_blng_MatchingId__c == sub.L2I_blng_MatchingId__c) {
//                                        foundOi = true;
//                                        break;
//                                    }
//                                }
//                                // renewed subscription has been removed or replaced with new renewal orderitems
//                                if (!foundOi) {
//                                    System.debug('*** sub oi not found');
//                                    // get the renewal contract's To Be Terminated Date
//                                    if (renewedContractProdCat2OrderEffDateMap.containsKey(renewedContractId)) {
//                                        Map<String, Date> prodCat2OrderEffDateMap = renewedContractProdCat2OrderEffDateMap.get(renewedContractId);
//                                        if (prodCat2OrderEffDateMap.containsKey(prodCat2)) {
//                                            Date effDate = prodCat2OrderEffDateMap.get(prodCat2);
//                                            subsToTerminateMap.put(sub.Id, effDate);
//                                            subOIsToTerminateMap.put(sub.SBQQ__OrderProduct__c, effDate);
//                                            System.debug('*** terminate sub subsToTerminateMap ' + subsToTerminateMap);
//                                            System.debug('*** terminate sub subOIsToTerminateMap ' + subOIsToTerminateMap);
//                                            System.debug('*** terminate sub ' + sub.Id + ' ' + sub.L2I_blng_MatchingId__c);
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            System.debug('*** after subList subsToTerminateMap.size() ' + subsToTerminateMap.size());
//            System.debug('*** after subList subOIsToTerminateMap.size() ' + subOIsToTerminateMap.size());
//
//            List<SBQQ__Subscription__c> subScriptList = new List<SBQQ__Subscription__c>();
//            List<OrderItem> orderItemList = new List<OrderItem>();
//            if (!subsToTerminateMap.isEmpty()) {
//                for (SBQQ__Subscription__c subs : [
//                      SELECT
//                            Id,
//                            SBQQ__TerminatedDate__c
//                      FROM SBQQ__Subscription__c
//                      WHERE Id IN :subsToTerminateMap.keySet()
//                ]) {
//                    subs.SBQQ__TerminatedDate__c = subsToTerminateMap.get(subs.Id);
//                    System.debug('*** Subscription to Cancel: ' + subs);
//                    subScriptList.add(subs);
//                }
//            }
//
//            if (!subOIsToTerminateMap.isEmpty()) {
//                for (OrderItem ordItem : [
//                      SELECT
//                            Id,
//                            SBQQ__TerminatedDate__c
//                      FROM OrderItem
//                      WHERE Id IN :subOIsToTerminateMap.keySet()
//                ]) {
//                    ordItem.SBQQ__TerminatedDate__c = subOIsToTerminateMap.get(ordItem.Id);
//                    System.debug('*** OrderItem to Cancel: ' + ordItem);
//                    orderItemList.add(ordItem);
//                }
//            }
//
//            if (subScriptList.size() > 0) {
//                update subScriptList;
//            }
//
//            if (orderItemList.size() > 0) {
//                update orderItemList;
//            }
//            System.debug('====== Ending L2I_CancelReplaceService.cancelPrior');
//        } catch (Exception e) {
//            String idStr = '';
//            for(String s:contractIds) {
//                idStr += (idStr == ''?'':',')+s;
//            }
//            L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
//                  'Exception occurred running L2I_CancelReplaceService.cancelPrior: ' + ' -' + e.getMessage(),
//                  'Contract', idStr, UserInfo.getUserId(), false);
//            System.debug('*** Exception occurred running L2I_CancelReplaceService.cancelPrior (see System Alerts): ' + e.getMessage());
//        }
//    }
}