/**
 *      @author       Andy Fang
 *      @date         04/04/2020
 *      @description  L2I_CaseMgmtCROrderDAO
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                    04/04/2020          Initial scaffold
 *      Sarah Kennedy                07/16/2020          US2104 - add query fields for Revise Modify process
 *                                                          Also removed this class from the L2I_CaseMgmtDAO interface class as the
 *                                                          Order query was moved into L2I_CaseMgmtFrom CROrderBatch
 */

//public with sharing class L2I_CaseMgmtCROrderDAO implements L2I_CaseMgmtDAO {
public with sharing class L2I_CaseMgmtCROrderDAO {
    
//    private Set<String> allowedProducts;
//    private Set<String> oppoProductCategories;
    private Set<String> skipFulfillmentCategories;
    
    public L2I_CaseMgmtCROrderDAO() {
//        allowedProducts = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
//              'Allowed Products');
//        oppoProductCategories = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
//              'Product Category');
        skipFulfillmentCategories = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
              'Skip Fulfillment');
        System.debug('*** skipFulfillmentCategories ' + skipFulfillmentCategories);
    }
//
    //DE417 - Adding End date to the query to ensure order isn't expired
    //Updating query to remove date comparison on the Order level, due to a recursive trigger error

//    public List<Order> getOrderRecords(List<Id> quoteId, List<Id> dslList) {
//        List<Order> orderList = [
//              SELECT Id,
//                    L2I_Original_Sales_Opportunity__c,
//                    L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c,
//                    OpportunityId,
//                    L2I_Product_Category_2__c,
//                    AccountId,
//                    L2I_Revise_Modified__c,
//                    Opportunity.L2I_AutoExtend__c,
//                    Type,
//                    L2I_Order_Process__c,
//                    Opportunity.L2I_Opportunity_Number__c, (select Id from OrderItems where EndDate >= Today)
//              FROM Order
//              WHERE L2I_Product_Category_2__c IN:allowedProducts
//              AND Opportunity.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c = true AND
//              Opportunity.L2I_Product_Category__c IN:oppoProductCategories AND Order.SBQQ__Quote__c IN:quoteId
//        ];
//        List<Order> finalOrderList = new List<Order>();
//
//        for (Order o : orderList) {
//            if (o.OrderItems.size() > 0) {
//                finalOrderList.add(o);
//            }
//        }
//
//        return finalOrderList;
//    }
    
    public List<L2I_DSL__c> getDSLRecords(Set<Id> quoteIds) {
        System.debug('*** L2I_CaseMgmtCROrderDAO.getDSLRecords ' + quoteIds);
        
        List<L2I_DSL__c> dslList = [
              SELECT Id, Aircraft__c, Aircraft__r.Name, Aircraft_Identifier__c, Modified_on_Opportunity__c,
                    Status__c, Original_Opportunity__c
              FROM L2I_DSL__c
              WHERE L2I_Aircraft_Confirmation__c = true
              AND Delivery_Schedule_Header__c IN (
                    SELECT L2I_Delivery_Schedule__c
                    FROM Opportunity
                    WHERE SBQQ__PrimaryQuote__c IN:quoteIds
              )
        ];
        
        //patching IFE records
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
        }
        
        return dslList;
    }
    
    public List<Case> getExistingCaseByDSL(Set<Id> orderIdSets, Set<Id> acIdSets, Set<Id> dslIdSets) {
        System.debug('*** L2I_CaseMgmtCROrderDAO.getExistingCaseByDSL ' + orderIdSets + ' ' + acIdSets + ' ' + dslIdSets);
        List<Case> existingCase = [
              SELECT Id
              FROM Case
              where
              L2I_Order__c IN:orderIdSets AND
              L2I_Aircraft__c IN:acIdSets AND
              L2I_Delivery_Schedule_Line__c IN:dslIdSets
        ];
        
        return existingCase;
    }
    
//    public List<OrderItem> getOrderItemByOrderId(Set<Id> OrderId) {
//        System.debug('*** L2I_CaseMgmtCROrderDAO.getOrderItemByOrderId ' + OrderId);
//              // will clean with minium data
//        List<OrderItem> orderItemList = [
//              SELECT Order.OpportunityId, L2I_Category__c, Id, Product2Id, L2I_ProductName__c, Quantity,
//                    L2I_Sub_Category_2__c, SBQQ__Subscription__c, OrderId, PricebookEntry.Product2.L2I_Service_Activation_Type__c,
//                    SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Type__c, L2I_Start_Date__c, ServiceDate, EndDate,
//                    Order.L2I_Original_Sales_Opportunity__c, L2I_blng_MatchingId__c, SBQQ__QuoteLine__c,
//                    Order.L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c
//              FROM Orderitem
//              WHERE Order.L2I_Product_Category_2__c IN:allowedProducts
//              AND Order.Opportunity.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c = true AND EndDate >= TODAY AND
//              Order.Opportunity.L2I_Product_Category__c IN:oppoProductCategories AND
//              (SBQQ__TerminatedDate__c = null OR SBQQ__TerminatedDate__c >= TODAY) AND
//              PricebookEntry.Product2.L2I_Service_Activation_Type__c != null and OrderId IN:OrderId
//        ];
//
//        return orderItemList;
//        return null;
//    }
    
    public Set<Id> CreateCases(List<L2I_DSL__c> dslList, List<Order> orderList, Set<String> uniqueCaseSet) {
        System.debug('*** CaseMgmtCROrderDao create cases');
        Set<Id> newCaseIds = new Set<Id>();
        List<Case> newCaseList = new List<Case>();
        Map<Id, Order> skipFulfillmentOrderMap = new Map<Id, Order>();
        String caseProcess = '';
        
        for (L2I_DSL__c dslRecord : dslList) {
            
            for (Order orderRecord : orderList) {
                System.debug('*** orderRecord ' + orderRecord);
                caseProcess = getCaseProcess(orderRecord, dslRecord);
                if (caseProcess == 'Skip'){
                    orderRecord.L2I_AutoActivate__c = true;
                    skipFulfillmentOrderMap.put(orderRecord.Id, orderRecord);
                }
                String uniqueKey = orderRecord.Id + '' + dslRecord.Aircraft__c + '' + dslRecord.Id;
                System.debug('*** uniqueKey ' + uniqueKey);
                
                //Only add cases if it's unique based on the unique key above
                if (!uniqueCaseSet.contains(uniqueKey) && caseProcess != '' && caseProcess != 'Skip') {
                    Case acCase = new Case();
                    acCase.L2I_Aircraft__c = dslRecord.Aircraft__c;
                    acCase.L2I_Original_Sales_Opportunity__c = orderRecord.L2I_Original_Sales_Opportunity__c;
                    acCase.L2I_Opportunity__c = orderRecord.OpportunityId;
                    acCase.L2I_Product_Category_2__c = orderRecord.L2I_Product_Category_2__c;
                    acCase.L2I_Order__c = orderRecord.Id;
                    acCase.L2I_Delivery_Schedule_Line__c = dslRecord.Id;
                    acCase.AccountId = orderRecord.AccountId;
                    acCase.Origin = 'CPQ Order';
                    acCase.L2I_Routing_Path__c = 'Order';
                    List<String> parameters = new List<String>();
                    if (dslRecord.Aircraft__r.Name != null) {
                        parameters.add(dslRecord.Aircraft__r.Name);
                    }
                    if (dslRecord.Aircraft__r.Name == null && dslRecord.Aircraft_Identifier__c != null) {
                        parameters.add(dslRecord.Aircraft_Identifier__c);
                    }
                    parameters.add(orderRecord.L2I_Product_Category_2__c);
                    parameters.add(orderRecord.L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c);
                    
                    acCase.Subject = String.format(Label.L2I_Case_Subject, parameters);
                    acCase.L2I_Case_Process__c = caseProcess;
                    
                    newCaseList.add(acCase);
                    
                    // set AutoActivate for Orders with a SkipFulfillment product
                    System.debug('*** checking for skip ' + orderRecord.L2I_Product_Category_2__c.toLowerCase());
                    if (skipFulfillmentCategories.contains(orderRecord.L2I_Product_Category_2__c.toLowerCase()) &&
                          orderRecord.Type == 'Renewal'){
                        System.debug('*** found skip match');
                        orderRecord.L2I_AutoActivate__c = true;
                        skipFulfillmentOrderMap.put(orderRecord.Id, orderRecord);
                    }
                }
            }
        }
        System.debug('*** skipFulfillmentOrderMap.size() ' + skipFulfillmentOrderMap.size());
        if (!skipFulfillmentOrderMap.isEmpty()){
            Database.SaveResult[] skipSR = Database.update(skipFulfillmentOrderMap.values(), false);
            for (Database.SaveResult sr : skipSR) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated AutoActivate on Order: ' + sr.getId());
                } else {
                    // Operation failed, so get all errors
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred updating AutoActivate on Order: ' + err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }
        
        if (newCaseList.size() > 0) {
            Database.SaveResult[] caseSR = Database.insert(newCaseList, false);
            for (Case c : newCaseList) {
                newCaseIds.add(c.Id);
            }
        }
        return newCaseIds;
    }
    
    private String getCaseProcess(Order orderRecord, L2I_DSL__c dslRecord) {
        System.debug('*** orderRecord ' + orderRecord);
        System.debug('*** dslRecord ' + dslRecord);
        String caseProcess = '';
        if (orderRecord.Type == 'New') {     // Sales
            caseProcess = 'New';
        } else if (orderRecord.Type == 'Amendment') {
            caseProcess = 'Cancel';
        } else {        // Renewal/Revise
            System.debug('*** Revise Order Type');
            if (dslRecord.Status__c == NULL ||
                  (dslRecord.Status__c == 'Deactivate' &&
                        dslRecord.Modified_on_Opportunity__c == orderRecord.OpportunityId)) {
                if (dslRecord.Status__c == 'Deactivate'){
                    caseProcess = 'Cancel';
                } else {
                    System.debug('*** dslRecord.Original_Opportunity__c ' + dslRecord.Original_Opportunity__c);
                    if (dslRecord.Original_Opportunity__c == orderRecord.OpportunityId){
                        caseProcess = 'New';
                    } else {
                        System.debug('*** Revise Modified ' + orderRecord.L2I_Revise_Modified__c);
                        if (orderRecord.L2I_Revise_Modified__c){
                            caseProcess = 'Revise';
                        } else {
                            System.debug('*** not new, cancel, revise - check for skip ');
                            System.debug('*** orderRecord.L2I_Product_Category_2__c ' + orderRecord.L2I_Product_Category_2__c.toLowerCase());
                            System.debug('*** skipFulfillmentCategories ' + skipFulfillmentCategories);
                            if (skipFulfillmentCategories.contains(orderRecord.L2I_Product_Category_2__c.toLowerCase())){
                                caseProcess = 'Skip';
                            }
                        }
                    }
                }
            } else {
                System.debug('*** not rcds ');
                System.debug('*** orderRecord.L2I_Product_Category_2__c ' + orderRecord.L2I_Product_Category_2__c.toLowerCase());
                System.debug('*** skipFulfillmentCategories ' + skipFulfillmentCategories);
                if (skipFulfillmentCategories.contains(orderRecord.L2I_Product_Category_2__c.toLowerCase())){
                    caseProcess = 'Skip';
                }
            }
        }
        System.debug('*** caseProcess ' + caseProcess);
        return caseProcess;
    }

}