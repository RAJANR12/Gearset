/**
 *      @author       Sarah Kenned7
 *      @date         07/22/2020
 *      @description  L2I_CM_AircraftService_Batch
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                   07/22/2020        Initial scaffold
 *      Sarah Kennedy                   02/03/2021         replace filter for L2I_Product_Category_2__c with L2I_Service_Activation_Type__c
 */
global class L2I_CM_AircraftService_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    private Set<Id> caseIdSets;
    private Boolean hasError;
    private Set<Id> caseIntegrationIds = new Set<Id>();
    
    public L2I_CM_AircraftService_Batch(Set<Id> caseIdSetsParam) {
        caseIdSets = caseIdSetsParam;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('*** Starting L2I_CM_AircraftService_Batch');
        return Database.getQueryLocator(
              'SELECT Id, ' +
                    ' L2I_Aircraft__c, ' +
                    ' L2I_Aircraft__r.Name, ' +
                    ' L2I_Opportunity__r.L2I_Delivery_Schedule__c, ' +
                    ' L2I_Delivery_Schedule_Line__c,  ' +
                    ' L2I_Order__c, ' +
                    ' CaseNumber, ' +
                    ' L2I_Order__r.OrderNumber, ' +
                    ' L2I_Original_Sales_Opportunity__c, ' +
                    ' L2I_Case_Process__c, ' +
                    ' L2I_Product_Category_2__c ' +
                    ' FROM Case ' +
                    ' WHERE Id in: caseIdSets'
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Case> scope) {
        System.debug('*** Executing L2I_CM_AircraftService_Batch');
//        Set<String> allowedProducts = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
//              'Allowed Products');
        Set<String> oppoProductCategories = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
              'Product Category');
        
        Savepoint sp = Database.setSavepoint();
        hasError = false;
        
        try {
            
            Set<Id> aircraftIds = new Set<Id>();
            Set<Id> originalOppIdSet = new Set<Id>();
            Set<Id> orderIdSet = new Set<Id>();
            Set<String> categorySet = new Set<String>();
            List<L2I_ASA__c> newASARecords = new List<L2I_ASA__c>();
            
            for (Case c : scope) {
                aircraftIds.add(c.L2I_Aircraft__c);
                originalOppIdSet.add(c.L2I_Original_Sales_Opportunity__c);
                orderIdSet.add(c.L2I_Order__c);
                categorySet.add(c.L2I_Product_Category_2__c);
                
                System.debug('*** Case Name ' + c.CaseNumber);
                System.debug('*** Case Aircraft ' + c.L2I_Aircraft__c + ' ' + c.L2I_Aircraft__r.Name);
                System.debug('*** Case Order ' + c.L2I_Order__c + ' ' + c.L2I_Order__r.OrderNumber);
                System.debug('*** Case Process ' + c.L2I_Case_Process__c);
            }
            System.debug('*** OrderIdSet ' + orderIdSet);
            
            // get OrderItems for the Orders on the Cases being processed
            List<OrderItem> orderItemList = new List<OrderItem>();
            orderItemList = [
                  SELECT Order.OpportunityId, L2I_Category__c, Id, Product2Id, L2I_ProductName__c, Quantity,
                        L2I_Sub_Category_2__c, SBQQ__Subscription__c, OrderId, PricebookEntry.Product2.L2I_Service_Activation_Type__c,
                        SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Type__c, L2I_Start_Date__c, ServiceDate, EndDate,
                        Order.L2I_Original_Sales_Opportunity__c, L2I_blng_MatchingId__c, SBQQ__QuoteLine__c,
                        Order.L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c, Order.Type, Order.OrderNumber,
                          SBQQ__QuoteLine__r.L2I_Offset_Years__c
                  FROM OrderItem
                  WHERE Order.L2I_Service_Activation_Types__c != NULL
                  AND Order.L2I_Service_Activation_Types__c != ''
                  AND Order.Opportunity.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c = TRUE
                  AND EndDate >= TODAY
                  AND Order.Opportunity.L2I_Product_Category__c IN:oppoProductCategories
                  AND (SBQQ__TerminatedDate__c = NULL OR SBQQ__TerminatedDate__c >= TODAY)
                  AND PricebookEntry.Product2.L2I_Service_Activation_Type__c != NULL
                  AND OrderId IN :orderIdSet
            ];
            System.debug('*** orderItemList.size() ' + orderItemList.size());
            
            Map<Id, List<OrderItem>> orderIdOIsMap = new Map<Id, List<OrderItem>>();
            List<OrderItem> tempList;
            Map<Id, OrderItem> oiMap = new Map<Id, OrderItem>();
            Map<String, OrderItem> matchingIdOIMap = new Map<String, OrderItem>();
            
            for (OrderItem oi : orderItemList) {
                System.debug('*** oi Id ' + oi.Id);
                System.debug('*** oi L2I_ProductName__c ' + oi.L2I_ProductName__c);
                System.debug('*** oi L2I_blng_MatchingId__c ' + oi.L2I_blng_MatchingId__c);
                System.debug('*** oi Order.Type ' + oi.Order.Type);
                System.debug('*** oi Order.OrderNumber ' + oi.Order.OrderNumber);
                if (!orderIdOIsMap.containsKey(oi.OrderId)) {
                    orderIdOIsMap.put(oi.OrderId, new List<OrderItem>());
                }
                tempList = orderIdOIsMap.get(oi.OrderId);
                tempList.add(oi);
                orderIdOIsMap.put(oi.OrderId, tempList);
                
                oiMap.put(oi.Id, oi);
                matchingIdOIMap.put(oi.L2I_blng_MatchingId__c, oi);
            }
            System.debug('*** oiMap.size() ' + oiMap.size());
            System.debug('*** orderIdOIsMap.size() ' + orderIdOIsMap.size());
            
            // get the existing and previous AS records
            List<L2I_Aircraft_Service__c> existingASRecords = new List<L2I_Aircraft_Service__c>();
            existingASRecords = [
                  SELECT Id,
                        Matching_Id__c,
                        Status__c,
                        Aircraft__c,
                        Aircraft__r.Name,
                        Product2__c,
                        Product2__r.L2I_Sub_Category_2__c,
                        Original_Opportunity__c,
                        Original_Opportunity__r.L2I_Opportunity_Number__c
                  FROM L2I_Aircraft_Service__c
                  WHERE Aircraft__c IN:aircraftIds
                  AND Product2__r.L2I_Sub_Category_2__c IN :categorySet
                  AND Status__c NOT IN ('Canceled', 'Deactivated')
                  AND Original_Opportunity__c IN :originalOppIdSet
            ];
            System.debug('*** existingASRecords ' + existingASRecords);
            
            Map<String, Id> existingASMap = new Map<String, Id>();
            Set<Id> existingIdSet = new Set<Id>();
            
            for (L2I_Aircraft_Service__c asTemp : existingASRecords) {
                existingASMap.put(asTemp.Aircraft__c + '' + asTemp.Matching_Id__c, asTemp.Id);
                System.debug('*** AS ' + asTemp.Id + ' ' + asTemp);
                System.debug('*** AS Aircraft ' + asTemp.Aircraft__c + ' ' + asTemp.Aircraft__r.Name);
                System.debug('*** AS existingASMap ' + asTemp.Aircraft__c + '' + asTemp.Matching_Id__c);
                existingIdSet.add(asTemp.Id);
            }
            System.debug('*** existingASMap ' + existingASMap);
            
            // create AS records if they do not exist
            List<L2I_Aircraft_Service__c> newASRecords = new List<L2I_Aircraft_Service__c>();
            
            
            for (Case c : scope) {
                System.debug('*** processing Case for new AS records ' + c);
                
                List<OrderItem> tempOIList = new List<OrderItem> ();
                tempOIList = orderIdOIsMap.get(c.L2I_Order__c);
                if (tempOIList != null && tempOIList.size() > 0) {
                    for (OrderItem oi : tempOIList) {
                        String oiId = oi.Id;
                        String key = c.L2I_Aircraft__c + '' + oiMap.get(oiId).L2I_blng_MatchingId__c;
                        if (existingASMap.get(key) == null) {
                            if (c.L2I_Case_Process__c != 'Cancel') {
                                // don't create new AS records for Cancel
                                L2I_Aircraft_Service__c newAS = new L2I_Aircraft_Service__c();
                                newAS.Aircraft__c = c.L2I_Aircraft__c;
                                newAS.Matching_Id__c = oiMap.get(oiId).L2I_blng_MatchingId__c;
                                newAS.Product2__c = oiMap.get(oiId).Product2Id;
                                newAS.Status__c = 'Pending Activation';
                                newAS.Original_Opportunity__c = c.L2I_Original_Sales_Opportunity__c;
                                // update initial offset years field for Yearly Maintenance Services
                                if (oiMap.get(oiId).PricebookEntry.Product2.L2I_Service_Activation_Type__c == 'Yearly'){
                                    newAS.Initial_Offset_Years__c = oiMap.get(oiId).SBQQ__QuoteLine__r.L2I_Offset_Years__c;
                                }
                                newASRecords.add(newAS);
                                System.debug('*** newASRecord ' + newAS);
                            }
                        }
                    }
                }
            }
            System.debug('*** newASRecords.size() ' + newASRecords.size());
            Set<Id> allASIds = new Set<Id>();
            Set<Id> newASIds = new Set<Id>();
            if (newASRecords.size() > 0) {
                insert newASRecords;
                for (L2I_Aircraft_Service__c asRecord : newASRecords) {
                    newASIds.add(asRecord.Id);
                    allASIds.add(asRecord.Id);
                }
            }
            // add the existing AS records to the new AS records
            allASIds.addAll(existingIdSet);
            // get the old + new list of AS records
            List<L2I_Aircraft_Service__c> allASRecords = new List<L2I_Aircraft_Service__c>();
            allASRecords = [
                  SELECT Id,
                        Matching_Id__c,
                        Status__c,
                        Aircraft__c,
                        Aircraft__r.Name,
                        Product2__c,
                        Product2__r.L2I_Sub_Category_2__c,
                        Original_Opportunity__c,
                        Original_Opportunity__r.L2I_Opportunity_Number__c
                  FROM L2I_Aircraft_Service__c
                  WHERE Id IN:allASIds
            ];
            Map<String, L2I_Aircraft_Service__c> matchingIdASMap = new Map<String, L2I_Aircraft_Service__c>();
            for (L2I_Aircraft_Service__c asRecord : allASRecords) {
                System.debug('*** AS record from current + prev ' + asRecord);
                matchingIdASMap.put(asRecord.Aircraft__c + '' + asRecord.Matching_Id__c, asRecord);
            }
            
            System.debug('*** Processing all Cases, all Aircraft Services');
            Boolean createASA;
            for (Case c : scope) {
                System.debug('*** checking Case ' + c);
                System.debug(' checking for previous' + matchingIdASMap.keySet());
                for (String aircraftMatchingId : matchingIdASMap.keySet()) {
                    L2I_Aircraft_Service__c aserv = matchingIdASMap.get(aircraftMatchingId);
                    System.debug('*** aserv ' + aserv);
                    if (aserv.Product2__r.L2I_Sub_Category_2__c == c.L2I_Product_Category_2__c) {
                        if (aserv.Aircraft__c == c.L2I_Aircraft__c) {
                            createASA = false;
                            System.debug('*** aircraftMatchingId ' + aircraftMatchingId);
                            System.debug('*** matchingIdOIMap ' + matchingIdOIMap);
                            System.debug('*** matchingIdOIMap.containsKey(aserv.Matching_Id__c) ' + matchingIdOIMap.containsKey(aserv.Matching_Id__c));
                            Id oiId = null;
                            if (matchingIdOIMap.containsKey(aserv.Matching_Id__c)) {
                                oiId = matchingIdOIMap.get(aserv.Matching_Id__c).Id;
                            }
                            L2I_ASA__c newASA = new L2I_ASA__c();
                            newASA.Order_Product__c = oiId;
                            newASA.Aircraft_Order__c = c.Id;
                            newASA.Aircraft_Service__c = aserv.Id;
                            // if we just added this AS record then create the ASA
                            if (newASIds.contains(aserv.Id)) {
                                newASA.Action__c = 'Activate';
                                System.debug('*** adding ASA for new AS ' + newASA);
                                createASA = true;
                            } else {
                                // if Revise and AS finds no match in the Order Items by Matching Id
                                // or if this is a Cancel
                                newASA.Order_Product__c = oiId;
                                newASA.Aircraft_Order__c = c.Id;
                                newASA.Aircraft_Service__c = aserv.Id;
                                if (c.L2I_Case_Process__c == 'Revise') {
                                    if (oiId == null && aserv.Status__c == 'Activated') {
                                        newASA.Action__c = 'Deactivate';
                                        createASA = true;
                                    } else if (oiId != null && aserv.Status__c == 'Pending Activation') {
                                        newASA.Action__c = 'Activate';
                                        createASA = true;
                                    }
                                } Else if (c.L2I_Case_Process__c == 'Cancel') {
                
                                    if (aserv.Status__c == 'Activated' ||
                                          aserv.Status__c == 'Pending Activation') {
                                        if (aserv.Status__c == 'Activated') {
                                            newASA.Action__c = 'Deactivate';
                                        }
                                        if (aserv.Status__c == 'Pending Activation') {
                                            newASA.Action__c = 'Cancel';
                                        }
                                        createASA = true;
                                    }
                                }
                            }
                            if (createASA) {
                                newASARecords.add(newASA);
                                System.debug('*** newASA ' + newASA);
                            }
                        }
                    }
                }
            }
            System.debug('*** newASARecords.size() ' + newASARecords.size());
            if (newASARecords.size() > 0) {
                insert newASARecords;
            }
            
            for (Case c : scope) {
                c.L2I_Allow_To_Reprocess__c = false;
            }
            update scope;
        
        } catch (Exception ex) {
            System.debug(' You ran into an issue : ' + ex.getLineNumber() + ' ' + ex.getMessage());
            Database.rollback(sp);
            hasError = true;
            for (Case c : scope) {
                c.L2I_Allow_To_Reprocess__c = true;
            }
            update scope;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('*** Finishing L2I_CM_AircraftService_Batch');
//Calls platform event when there is no error
        if (!hasError) {
            Set<String> skipFulfillmentCategories = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
                  'Skip Fulfillment');
// send the cases to the integration if not Revise Case Process and not a Fulfillment product
            for (Case c : [
                  SELECT Id, L2I_Case_Process__c, L2I_Product_Category_2__c, L2I_Cancel_ASA_Record_Count__c
                  FROM Case
                  WHERE Id IN:caseIdSets
            ]) {
                if (c.L2I_Case_Process__c == 'Revise' &&
                      skipFulfillmentCategories.contains(c.L2I_Product_Category_2__c.toLowerCase()) &&
                      c.L2I_Cancel_ASA_Record_Count__c == 0) {
// skip Integration
                } else {
                    caseIntegrationIds.add(c.Id);
                }
            }
            if (caseIntegrationIds.size() > 0) {
                System.debug('*** caseIntegrationIds ' + caseIntegrationIds);
                L2I_UtilityHelper.createPlatformEvent(caseIntegrationIds);
            }
        }
    }
}