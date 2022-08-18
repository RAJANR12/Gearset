/**
 *      @author       Sarah Kennedy
 *      @date         02/18/2020
 *      @description  Service class for DSL object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/05/2020         Initial creation
 *      Sarah Kennedy                 02/03 20201        replace filter for L2I_Product_Category_2__c with L2I_Service_Activation_Type__c
 *
 */
public with sharing class L2I_DSLService {
    
    public static List<L2I_DSL__c> pruneDSLList(List<L2I_DSL__c> dslList, Id currentOpptyId) {
        // return the list of DSLs that we want to display
        List<L2I_DSL__c> dslsToReturnList = new List<L2I_DSL__c>();
        
        // select the DSLs to display
        for (L2I_DSL__c dsl : dslList) {
//            System.debug('*** currentOpptyId ' + currentOpptyId);
//            System.debug('*** prune dsl prodcat ' + dsl.Delivery_Schedule_Header__r.Product_Category__c);
//            System.debug('*** prune dsl Original_Opportunity__c ' + dsl.Original_Opportunity__c);
//            if (dsl.Delivery_Schedule_Header__r.Product_Category__c == 'DSS' ||
//                  dsl.Delivery_Schedule_Header__r.Product_Category__c == 'PTS') {
////                if (dsl.Original_Opportunity__c == currentOpptyId) {
//                    dslsToReturnList.add(dsl);
//                } else {
//                    if (dsl.Original_Opportunity__r.StageName == 'Pending Close' ||
//                          dsl.Original_Opportunity__r.StageName == 'Closed Won') {
//                        dslsToReturnList.add(dsl);
//                    }
//                }
//            } else {
//                dslsToReturnList.add(dsl);
//            }
            dslsToReturnList.add(dsl);    //Show all DSLs (US2020)
        }
        return dslsToReturnList;
    }
    
    public static Set<Id> countCases4DSLAircraft(Map<Id, Id> dslAircraftMap) {
        // return any DSLs that have any Cases created
        System.debug('*** dslAircraftMap ' + dslAircraftMap);
        Set<Id> dslIds = new Set<Id>();
        AggregateResult [] results = [
              SELECT COUNT(Id), L2I_Aircraft__c, L2I_Delivery_Schedule_Line__c
              FROM Case
              WHERE L2I_Delivery_Schedule_Line__c IN :dslAircraftMap.keySet()
              AND L2I_Aircraft__c IN :dslAircraftMap.values()
              GROUP BY L2I_Delivery_Schedule_Line__c, L2I_Aircraft__c
              HAVING COUNT(Id) > 0
        ];
        for (AggregateResult ar : results) {
            dslIds.add((Id)ar.get('L2I_Delivery_Schedule_Line__c'));
        }
        return dslIds;
    }
    
    public static void createCasesFromDSLs(List<L2I_DSL__c> newDSLList, Map<Id, L2I_DSL__c> newDSLMap, Map<Id, L2I_DSL__c> oldDSLMap) {
        System.debug('*** L2I_DSLService - createCasesFromDSLs');
        Set<Id> dslIds = new Set<Id>();
        Set<Id> newCaseIds = new Set<Id>();
        Map<Id, List<Order>> origSalesOppOrderMap = new Map<Id, List<Order>>();
        // get confirmed DSLs
        for (L2I_DSL__c dsl : newDSLList) {
            L2I_DSL__c oldDSL = oldDSLMap.get(dsl.Id);
            L2I_DSL__c newDSL = newDSLMap.get(dsl.Id);
            
            if (newDSL.L2I_Aircraft_Confirmation__c == true &&
                  newDSL.L2I_Aircraft_Confirmation__c != oldDSL.L2I_Aircraft_Confirmation__c) {
                dslIds.add(dsl.Id);
            }
        }
        // get DSL details
        List<L2I_DSL__c> dsLineList = new List<L2I_DSL__c>();
        dsLineList = getDSLRecords(dslIds);
        
        if (dsLineList.size() > 0) {
            Set<Id> dshList = new Set<Id>();
            Set<Id> dslIdSets = new Set<Id>();
            
            for (L2I_DSL__c dsl : dsLineList) {
                dshList.add(dsl.Delivery_Schedule_Header__c);
                dslIdSets.add(dsl.Id);
            }
            // get the Order details
            if (dshList.size() > 0) {
                origSalesOppOrderMap = getOrderRecords(dshList);
            }
            
            if (dshList.size() > 0) {
                newCaseIds = createCases(dsLineList, origSalesOppOrderMap);
            }
        }
    
    }
    
    private static List<L2I_DSL__c> getDSLRecords(Set<Id> dslIds) {
        List<L2I_DSL__c> dslList = [
              SELECT Aircraft__c, Aircraft__r.Name, Delivery_Schedule_Header__c,
                    Aircraft_Identifier__c, Original_Opportunity__c,
                    Original_Opportunity__r.L2I_Original_Opportunity__c,
                    Original_Opportunity__r.L2I_Quote_Ordered__c
              FROM L2I_DSL__c
              WHERE Id IN:dslIds
              AND L2I_Aircraft_Confirmation__c = true
              AND Original_Opportunity__r.L2I_Quote_Ordered__c = true
        
        ];
        
        //get IFEC aircraft
        Map<String, Id> ACNameIDMap = new Map<String, Id>();
        Set<String> ACNameSets = new Set<String>();
        
        for (L2I_DSL__c dsl : dslList) {
            if (dsl.Aircraft__c == null && dsl.Aircraft_Identifier__c != null) {
                ACNameSets.add(dsl.Aircraft_Identifier__c);
            }
        }
        
        if (ACNameSets.size() > 0) {
            List<L2I_Aircraft__c> acInfo = [SELECT Id, Name from L2I_Aircraft__c WHERE Name IN:ACNameSets];
            for (L2I_Aircraft__c ac : acInfo) {
                ACNameIDMap.put(ac.Name, ac.Id);
            }
        }
        
        for (L2I_DSL__c dsl : dslList) {
            if (dsl.Aircraft__c == null && dsl.Aircraft_Identifier__c != null) {
                dsl.Aircraft__c = ACNameIDMap.get(dsl.Aircraft_Identifier__c);
            }
            System.debug('*** dsl ' + dsl);
        }
        System.debug('*** getDSLRecords dslList ' + dslList.size());
        
        return dslList;
    }
    
    private static Map<Id, List<Order>> getOrderRecords(Set<Id> dshIds) {
//        Set<String> allowedProducts;
        Set<String> oppoProductCategories;
        Map<Id, List<Order>> origSalesOppOrderMap = new Map<Id, List<Order>>();
        Map<Id, Map<DateTime, Id>> origSalesDateOpp = new Map<Id, Map<DateTime, Id>>();
        Map<Id, DateTime> origSalesDate = new Map<Id, DateTime>();
        Map<Id, Id> origSalesOppId = new Map<Id, Id>();
        List<Order> newRenewOrderList = new List<Order>();
        
//        allowedProducts = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
//              'Allowed Products');
        oppoProductCategories = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
              'Product Category');
        
        List<Order> orderList = new List<Order>();


        orderList = [
              SELECT Id,
                    L2I_Original_Sales_Opportunity__c, Type,
                    L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c,
                    OpportunityId,
                    Opportunity.CreatedDate,
                    L2I_Product_Category_2__c,
                    AccountId, (select Id from OrderItems where EndDate >= Today)
              FROM Order
              WHERE L2I_Terminated__c = false
              AND Opportunity.L2I_Delivery_Schedule__c IN:dshIds
              AND Type IN ('New', 'Renewal')
              AND L2I_Service_Activation_Types__c != NULL
              AND L2I_Service_Activation_Types__c != ''
              AND Opportunity.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c = true
              AND Opportunity.L2I_Product_Category__c IN:oppoProductCategories
        ];
        // get the latest opp for each origSalesOpp based on the opp createdDate
        for (Order o : orderList) {
            System.debug('*** o ' + o);
            if (!origSalesDateOpp.containsKey(o.L2I_Original_Sales_Opportunity__c)) {
                origSalesDate.put(o.L2I_Original_Sales_Opportunity__c, o.Opportunity.CreatedDate);
                origSalesOppId.put(o.L2I_Original_Sales_Opportunity__c, o.OpportunityId);
            }
            if (o.Opportunity.CreatedDate > origSalesDate.get(o.L2I_Original_Sales_Opportunity__c)) {
                origSalesDate.put(o.L2I_Original_Sales_Opportunity__c, o.Opportunity.CreatedDate);
                origSalesOppId.put(o.L2I_Original_Sales_Opportunity__c, o.OpportunityId);
            }
        }
        
        System.debug('*** origSalesDate ' + origSalesDate);
        System.debug('*** origSalesOppId ' + origSalesOppId);
        // get orders for only the latest Opp for each origSalesOpp
        for (Order o : orderList) {
            List<Order> ordList = new List<Order>();
            // only get the latest orders for each origSalesOpp
            System.debug('*** o.L2I_Original_Sales_Opportunity__c ' + o.L2I_Original_Sales_Opportunity__c);
            System.debug('*** o.OpportunityId ' + o.OpportunityId);
            // find the latest Opp for the orig Sales Opp - and get those orders
            if (origSalesOppId.containsKey(o.L2I_Original_Sales_Opportunity__c) &&
                  origSalesOppId.get(o.L2I_Original_Sales_Opportunity__c) == o.OpportunityId) {
                System.debug('*** adding order ' + o);
                if (!origSalesOppOrderMap.containsKey(o.L2I_Original_Sales_Opportunity__c)) {
                    origSalesOppOrderMap.put(o.L2I_Original_Sales_Opportunity__c, new List<Order>());
                }
                ordList = origSalesOppOrderMap.get(o.L2I_Original_Sales_Opportunity__c);
                ordList.add(o);
                origSalesOppOrderMap.put(o.L2I_Original_Sales_Opportunity__c, ordList);
            }
        }
        
        System.debug('*** getOrders origSalesOppOrderMap size ' + origSalesOppOrderMap.size());
        
        return origSalesOppOrderMap;
    }
    
    private static Set<Id> CreateCases(List<L2I_DSL__c> dslList, Map<Id, List<Order>> origSalesOppOrderMap) {
        System.debug('*** createCases ');
        Set<Id> newCaseIds = new Set<Id>();
        List<Case> newCaseList = new List<Case>();
        
        for (L2I_DSL__c dsl : dslList) {
            Id origSalesOpp;
            if (dsl.Original_Opportunity__c != NULL) {
                if (dsl.Original_Opportunity__r.L2I_Original_Opportunity__c == NULL) {
                    // for Sales
                    origSalesOpp = dsl.Original_Opportunity__c;
                } else {
                    // for Revise
                    origSalesOpp = dsl.Original_Opportunity__r.L2I_Original_Opportunity__c;
                
                }
            }
            System.debug('*** origSalesOpp ' + origSalesOpp);
            List<Order> orderList = new List<Order>();
            if (origSalesOppOrderMap.containsKey(origSalesOpp)) {
                orderList = origSalesOppOrderMap.get(origSalesOpp);
                
                for (Order o : orderList) {
                    System.debug('*** create cases o ' + o);
                    Case acCase = new Case();
                    acCase.L2I_Aircraft__c = dsl.Aircraft__c;
                    acCase.L2I_Original_Sales_Opportunity__c = o.L2I_Original_Sales_Opportunity__c;
                    acCase.L2I_Opportunity__c = o.OpportunityId;
                    acCase.L2I_Product_Category_2__c = o.L2I_Product_Category_2__c;
                    acCase.L2I_Order__c = o.Id;
                    acCase.AccountId = o.AccountId;
                    acCase.L2I_Case_Process__c = 'New';
                    acCase.L2I_Delivery_Schedule_Line__c = dsl.Id;
                    acCase.Origin = 'CPQ Order';
                    acCase.L2I_Routing_Path__c = 'DSL';
                    List<String> parameters = new List<String>();
                    if (dsl.Aircraft__r.Name != null) {
                        parameters.add(dsl.Aircraft__r.Name);
                    }
                    if (dsl.Aircraft__r.Name == null && dsl.Aircraft_Identifier__c != null) {
                        parameters.add(dsl.Aircraft_Identifier__c);
                    }
                    parameters.add(o.L2I_Product_Category_2__c);
                    parameters.add(o.L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c);
                    
                    acCase.Subject = String.format(Label.L2I_Case_Subject, parameters);
                    
                    newCaseList.add(acCase);
                }
            }
        }
        
        if (newCaseList.size() > 0) {
            System.debug('*** Inserting Cases ' + newCaseList.size() + ' ' + newCaseList);
            insert newCaseList;
            for (Case c : newCaseList) {
                newCaseIds.add(c.Id);
            }
        }
        return newCaseIds;
    }
}