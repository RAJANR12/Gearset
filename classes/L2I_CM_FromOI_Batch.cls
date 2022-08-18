/**
 *      @author       Andy Fang
 *      @date         03/17/2020
 *      @description  L2I_CM_FromOI_Batch
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                    03/17/2020         Initial scaffold
 */
global class L2I_CM_FromOI_Batch {
//global class L2I_CM_FromOI_Batch implements Database.Batchable<sObject>, Database.Stateful {
//
//    private Id quoteId;
//    private Set<Id> caseIdSets;
//    private Boolean hasError;
//
//    public L2I_CM_FromOI_Batch(Set<Id> caseIdSetsParam) {
//        caseIdSets = caseIdSetsParam;
//    }
//
//    //needs to update query
//    global Database.QueryLocator start(Database.BatchableContext bc) {
//        return Database.getQueryLocator(
//              'SELECT Id, L2I_Aircraft__c, L2I_Opportunity__r.L2I_Delivery_Schedule__c,  ' +
//                    ' L2I_Order__c, L2I_Original_Sales_Opportunity__c, L2I_Product_Category_2__c FROM Case WHERE Id in: caseIdSets'
//        );
//
//    }
//
//    global void execute(Database.BatchableContext bc, List<Case> scope) {
//
//        Savepoint sp = Database.setSavepoint();
//        hasError = false;
//
//        try {
//            L2I_CaseMgmtCROrderDAO crOrderDAO = new L2I_CaseMgmtCROrderDAO();
//
//            //Possible Step 2
//            //Create ASA
//            // To create ASA record for each order item per case.
//            Set<Id> aircraftIds = new Set<Id>();
//            Set<Id> originalOppIdSet = new Set<Id>();
//            Set<Id> OrderIdSet = New Set<Id>();
//
//            List<L2I_ASA__c> newASARecords = new List<L2I_ASA__c>();
//            Set<Id> oiSet = new Set<Id>();
//            Set<String> categroySet = new Set<String>();
//            //Set<Id> orderIdSet = new Set<Id>();
//
//            for (Case c : scope) {
//                aircraftIds.add(c.L2I_Aircraft__c);
//                originalOppIdSet.add(c.L2I_Original_Sales_Opportunity__c);
//                OrderIdSet.add(c.L2I_Order__c);
//                categroySet.add(c.L2I_Product_Category_2__c);
//            }
//
//            List<OrderItem> orderItemList = crOrderDAO.getOrderItemByOrderId(OrderIdSet);
//            System.debug('*** orderItemList ' + orderItemList);
//
//            Map<Id, Set<Id>> orderIdOrderItemsMap = new Map<Id, Set<Id>>();
//
//            //This variable is to use for calculation for Order to order item mapping
//            Set<Id> uniqueOrderIds = new Set<Id>();
//            Set<Id> orderItemsSet = new Set<Id>();
//            Map<Id, Orderitem> oiProductMap = new Map<Id, Orderitem>();
//            Set<String> matchingIdSet = new Set<String>();
//
//            for (OrderItem oi : orderItemList) {
//                //Part 1 of looping through order -> order item
//                System.debug('*** uniqueOrderIds ' + uniqueOrderIds);
//                if (uniqueOrderIds.contains(oi.OrderId)) {
//                    Set<Id> tempSet = OrderIdOrderItemsMap.get(oi.OrderId);
//                    tempSet.add(oi.Id);
//                    OrderIdOrderItemsMap.put(oi.OrderId, tempSet);
//                } else {
//                    uniqueOrderIds.add(oi.OrderId);
//                    orderItemsSet = new Set<Id>();
//                    orderItemsSet.add(oi.Id);
//                    OrderIdOrderItemsMap.put(oi.OrderId, orderItemsSet);
//                }
//                //Part 2 to loop through prod map and matching Id
//                oiProductMap.put(oi.Id, oi);
//                matchingIdSet.add(oi.L2I_blng_MatchingId__c);
//            }
//            System.debug('*** matchingIdSet ' + matchingIdSet);
//            System.debug('*** oiProductMap ' + oiProductMap);
//            System.debug('*** OrderIdOrderItemsMap ' + OrderIdOrderItemsMap);
//
//            //Existing AS record
//            List<L2I_Aircraft_Service__c> existingASRecords = [
//                  SELECT Id, Matching_Id__c, Aircraft__c
//                  FROM L2I_Aircraft_Service__c
//                  WHERE Aircraft__c IN:aircraftIds AND Matching_Id__c IN:matchingIdSet
//            ];
//            System.debug('*** existingASRecords ' + existingASRecords);
//
//            Map<String, Id> existingASMap = new Map<String, Id>();
//            //Only for order creation
//
//            for (L2I_Aircraft_Service__c asTemp : existingASRecords) {
//                existingASMap.put(asTemp.Aircraft__c + '' + asTemp.Matching_Id__c, asTemp.Id);
//            }
//            System.debug('*** existingASMap ' + existingASMap);
//
//            //Create AS record
//            List<L2I_Aircraft_Service__c> newASRecords = new List<L2I_Aircraft_Service__c>();
//            Set<Id> existingIdSet = new Set<Id>();
//
//            for (Case c : scope) {
//                System.debug('*** processing Case ' + c);
//                Set<Id> temp = new Set<Id>();
//                temp = OrderIdOrderItemsMap.get(c.L2I_Order__c);
//                if (temp != NULL && !temp.isEmpty()) {
//                    for (String oiId : temp) {
//                        String key = c.L2I_Aircraft__c + '' + oiProductMap.get(oiId).L2I_blng_MatchingId__c;
//                        if (existingASMap.get(key) == null) {
//                            L2I_Aircraft_Service__c newAS = new L2I_Aircraft_Service__c();
//                            newAS.Aircraft__c = c.L2I_Aircraft__c;
//                            newAS.Matching_Id__c = oiProductMap.get(oiId).L2I_blng_MatchingId__c;
//                            newAS.Product2__c = oiProductMap.get(oiId).Product2Id;
//                            newAS.Status__c = 'Pending Activation';
//                            newASRecords.add(newAS);
//                        } else {
//                            existingIdSet.add(existingASMap.get(key));
//                        }
//                    }
//                }
//            }
//
//            Database.SaveResult[] srList = Database.insert(newASRecords, false);
//            Set<Id> UpdatedId = new Set<Id>();
//
//            for (Database.SaveResult sr : srList) {
//                if (sr.isSuccess()) {
//                    UpdatedId.add(sr.getId());
//                }
//            }
//
//            //Update ASA with AS ID
//            UpdatedId.addAll(existingIdSet);
//
//            // Being of Req 06
//            Set<String> as_Filter =
//                  L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
//                        'AS Filter');
//
//            List<L2I_Aircraft_Service__c> oldASRecords = [
//                  SELECT Id, Matching_Id__c, Status__c, Aircraft__c
//                  FROM L2I_Aircraft_Service__c
//                  WHERE id IN:UpdatedId AND Status__c NOT IN:as_Filter
//            ];
//            // End of Req 06
//
//            Map<String, L2I_Aircraft_Service__c> MatchingIdASMap = new Map<String, L2I_Aircraft_Service__c>();
//
//            for (L2I_Aircraft_Service__c asRecord : oldASRecords) {
//                MatchingIdASMap.put(asRecord.Aircraft__c + '' + asRecord.Matching_Id__c, asRecord);
//            }
//
//            for (Case c : scope) {
//                Set<Id> temp = new Set<Id>();
//                temp = OrderIdOrderItemsMap.get(c.L2I_Order__c);
//                if (temp != NULL && !temp.isEmpty()) {
//                    for (Id oi : temp) {
//                        if (MatchingIdASMap.get(c.L2I_Aircraft__c + '' + oiProductMap.get(oi).L2I_blng_MatchingId__c) != null) {
//                            oiSet.add(oi);
//                            L2I_ASA__c newASA = new L2I_ASA__c();
//                            newASA.Order_Product__c = oi;
//                            newASA.Aircraft_Order__c = c.Id;
//                            newASA.Aircraft_Service__c = MatchingIdASMap.get(c.L2I_Aircraft__c + '' + oiProductMap.get(oi).L2I_blng_MatchingId__c).Id;
//                            //newASA.Action__c = 'Activate';
//                            // Begin of Req 07
//                            if (oiProductMap.get(oi) != Null && (Integer) oiProductMap.get(oi).Quantity == 1) {
//                                if (MatchingIdASMap.get(c.L2I_Aircraft__c + '' + oiProductMap.get(oi).L2I_blng_MatchingId__c) != null &&
//                                      MatchingIdASMap.get(c.L2I_Aircraft__c + '' + oiProductMap.get(oi).L2I_blng_MatchingId__c).Status__c == 'Pending Activation') {
//                                    newASA.Action__c = 'Activate';
//                                }
//                                if (MatchingIdASMap.get(c.L2I_Aircraft__c + '' + oiProductMap.get(oi).L2I_blng_MatchingId__c) != null &&
//                                      MatchingIdASMap.get(c.L2I_Aircraft__c + '' + oiProductMap.get(oi).L2I_blng_MatchingId__c).Status__c == 'Activated') {
//                                    newASA.Action__c = 'No Action';
//                                    //DE433 Marking the action as completed for case closure
//                                    newASA.Status__c = 'Completed';
//                                }
//                            } else if (oiProductMap.get(oi) != Null && (Integer) oiProductMap.get(oi).Quantity == -1) {
//                                if (MatchingIdASMap.get(c.L2I_Aircraft__c + '' + oiProductMap.get(oi).L2I_blng_MatchingId__c) != null &&
//                                      MatchingIdASMap.get(c.L2I_Aircraft__c + '' + oiProductMap.get(oi).L2I_blng_MatchingId__c).Status__c == 'Activated') {
//                                    newASA.Action__c = 'Deactivate';
//                                }
//                                if (MatchingIdASMap.get(c.L2I_Aircraft__c + '' + oiProductMap.get(oi).L2I_blng_MatchingId__c) != null &&
//                                      MatchingIdASMap.get(c.L2I_Aircraft__c + '' + oiProductMap.get(oi).L2I_blng_MatchingId__c).Status__c == 'Deactivated') {
//                                    newASA.Action__c = 'No Action';
//                                    //DE433 Marking the action as completed for case closure
//                                    newASA.Status__c = 'Completed';
//                                }
//                                if (MatchingIdASMap.get(c.L2I_Aircraft__c + '' + oiProductMap.get(oi).L2I_blng_MatchingId__c) != null &&
//                                      MatchingIdASMap.get(c.L2I_Aircraft__c + '' + oiProductMap.get(oi).L2I_blng_MatchingId__c).Status__c == 'Canceled') {
//                                    newASA.Action__c = 'No Action';
//                                    //DE433 Marking the action as completed for case closure
//                                    newASA.Status__c = 'Completed';
//                                }
//                                if (MatchingIdASMap.get(c.L2I_Aircraft__c + '' + oiProductMap.get(oi).L2I_blng_MatchingId__c) != null &&
//                                      MatchingIdASMap.get(c.L2I_Aircraft__c + '' + oiProductMap.get(oi).L2I_blng_MatchingId__c).Status__c == 'Pending Activation') {
//                                    newASA.Action__c = 'Cancel';
//                                }
//                            }
//                            // End of Req 07
//                            newASARecords.add(newASA);
//                        }
//                    }
//                }
//            }
//
//            Database.SaveResult[] asaList = Database.insert(newASARecords, false);
//
//            //L2I_Opportunity__r = orignial sales
//            //need to update opporturnity
//
//            List<OrderItem> previousOrderItems = [
//                  SELECT Id, Product2Id, EndDate
//                  from OrderItem
//                  WHERE order.L2I_Original_Sales_Opportunity__c IN:originalOppIdSet AND
//                  (SBQQ__TerminatedDate__c = null OR SBQQ__TerminatedDate__c >= TODAY) AND
//                  Order.L2I_Product_Category_2__c IN:categroySet AND orderId NOT IN:
//                        orderIdSet
//            ];
//
//            List<OrderItem> currentOrderItems = [
//                  select Id, Product2Id, serviceDate
//                  from OrderItem
//                  where order.L2I_Original_Sales_Opportunity__c in:originalOppIdSet
//                  and Order.L2I_Product_Category_2__c in:categroySet and orderId in:
//                        orderIdSet
//            ];
//
//            Map<Id, Date> previousProductIdMap = new Map<Id, Date>();
//            Map<Id, Date> currentProductIdMap = new Map<Id, Date>();
//
//            for (OrderItem oi : previousOrderItems) {
//                previousProductIdMap.put(oi.Product2Id, oi.EndDate);
//            }
//
//            for (OrderItem oi : currentOrderItems) {
//                currentProductIdMap.put(oi.Product2Id, oi.serviceDate);
//            }
//
//            Set<Id> removedIds = new Set<Id>();
//
//            for (Id porderId : previousProductIdMap.keySet()) {
//                if (currentProductIdMap.get(porderId) != null) {
//                    if (previousProductIdMap.get(porderId) <= currentProductIdMap.get(porderId))
//                        removedIds.add(porderId);
//                } else {
//                    removedIds.add(porderId);
//                }
//            }
//
//            //locate exiting AS ID information
//
////            List<L2I_ASA__c> removedASADetails = [
////                  select Id, Aircraft_Service__c, Aircraft_Service__r.Aircraft__c,
////                        Aircraft_Service__r.Product2__c, Aircraft_Service__r.Sub_Category_2__c
////                  from L2I_ASA__c
////                  where Action__c = 'Activate' and Aircraft_Service__r.Aircraft__c in:aircraftIds
////                  And Aircraft_Service__r.Product2__c IN:removedIds
////            ];
//            //Id would be ac+prod -> as id
//            //acid+prodId -> object ( obj.asID , obj.subcate)
//            //locate order
//            Map<String, Id> orderIDMap = new Map<String, Id>();
//            for (Case c : scope) {
//                orderIDMap.put(c.L2I_Aircraft__c + c.L2I_Product_Category_2__c, c.Id);
//            }
//
//            List<L2I_ASA__c> removedASAList = new List<L2I_ASA__c>();
//
//            for (Id acid : aircraftIds) {
//                for (Id rid : removedIds) {
//                    L2I_ASA__c asa = new L2I_ASA__c();
//                    asa.Aircraft_Order__c = acid;
//                    asa.Order_Product__c = rid;
//                    if (orderIDMap.get(acid + '' + rid) != null)
//                        asa.Aircraft_Service__c = orderIDMap.get(acid + '' + rid);
//                    asa.Action__c = 'Deactivate';
//                    removedASAList.add(asa);
//                }
//            }
//
//            Database.SaveResult[] removedASAInsertList = Database.insert(removedASAList, false);
//
//            for (Case c : scope) {
//                c.L2I_Allow_To_Reprocess__c = false;
//            }
//            update scope;
//
//        } catch (Exception ex) {
//            system.debug(' You ran into an issue : ' + ex.getLineNumber() + ' ' + ex.getMessage());
//            Database.rollback(sp);
//            hasError = true;
//            for (Case c : scope) {
//                c.L2I_Allow_To_Reprocess__c = true;
//            }
//            update scope;
//
//        }
//    }
//
//    global void finish(Database.BatchableContext bc) {
//        //Calls platform event when there is no error
//        if (!hasError) {
//            if (caseIdSets.size() > 0) {
//                L2I_UtilityHelper.createPlatformEvent(caseIdSets);
//            }
//        }
//    }

}