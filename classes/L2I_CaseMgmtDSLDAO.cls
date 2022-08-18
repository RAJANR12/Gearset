/**
 *      @author       Andy Fang
 *      @date         04/04/2020
 *      @description  L2I_CaseMgmtDSLDAO
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                    04/04/2020         Initial scaffold
 *      Sarah Kennedy                06/10/2020         US1979
 *      Sarah Kennedy                07/17/2020         US2125 - DSL.originalopportunity ordered condition added
 *      Sarah Kennedy                07/17/2020         US2125 - code moved to DSL trigger
 */

public with sharing class L2I_CaseMgmtDSLDAO {
    
//    private Set<String> allowedProducts;
//    private Set<String> oppoProductCategories;
//
//    public L2I_CaseMgmtDSLDAO() {
////        allowedProducts = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
////              'Allowed Products');
////        oppoProductCategories = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
////              'Product Category');
//    }
//
//    //DE417 - Adding End date to the query to ensure order isn't expired
//    public List<Order> getOrderRecords(List<Id> quoteId, List<Id> dshIds) {
//        // find the latest Opportunity by Original
//
//        List<Order> orderList = [
//              SELECT Id,
//                    L2I_Original_Sales_Opportunity__c,
//                    L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c,
//                    OpportunityId,
//                    L2I_Product_Category_2__c,
//                    AccountId, (select Id from OrderItems where EndDate >= Today)
//              FROM Order
//              WHERE L2I_Terminated__c = false
//              AND Type IN ('New', 'Renewal')
//              AND Opportunity.L2I_Delivery_Schedule__c IN:dshIds
//              AND L2I_Product_Category_2__c IN:allowedProducts
//              AND Opportunity.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c = true
//              AND Opportunity.L2I_Product_Category__c IN:oppoProductCategories
//        ];
//
//        List<Order> finalOrderList = new List<Order>();
//
//        for (Order o : orderList) {
//            if (o.OrderItems.size() > 0) {
//                System.debug('*** o ' + o);
//                finalOrderList.add(o);
//            }
//        }
//        System.debug('*** L2I_CaseMgmtDSLDAO getOrders FinalOrderList ' + finalOrderList.size());
//
//        return finalOrderList;
//    }
//
//    public List<L2I_DSL__c> getDSLRecords(List<Id> quoteId, List<Id> dslIds) {
//
//        List<L2I_DSL__c> dslList = [
//              SELECT Aircraft__c, Aircraft__r.Name, Delivery_Schedule_Header__c,
//                    Aircraft_Identifier__c, Original_Opportunity__c,
//                    Original_Opportunity__r.L2I_Original_Opportunity__c
//              FROM L2I_DSL__c
//              WHERE Id IN:dslIds
//              AND L2I_Aircraft_Confirmation__c = TRUE
//              AND Original_Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c = true
//        ];
//
//        //patching IFE records
//        Map<String, Id> ACNameIDMap = new Map<String, Id>();
//        Set<String> ACNameSets = new Set<String>();
//
//        for (L2I_DSL__c dsl : dslList) {
//            if (dsl.Aircraft__c == null && dsl.Aircraft_Identifier__c != null) {
//                ACNameSets.add(dsl.Aircraft_Identifier__c);
//            }
//        }
//
//        if (ACNameSets.size() > 0) {
//            List<L2I_Aircraft__c> acInfo = [SELECT Id, Name from L2I_Aircraft__c WHERE Name IN:ACNameSets];
//            for (L2I_Aircraft__c ac : acInfo) {
//                ACNameIDMap.put(ac.Name, ac.Id);
//            }
//        }
//
//        for (L2I_DSL__c dsl : dslList) {
//            if (dsl.Aircraft__c == null && dsl.Aircraft_Identifier__c != null) {
//                dsl.Aircraft__c = ACNameIDMap.get(dsl.Aircraft_Identifier__c);
//            }
//            System.debug('*** dsl ' + dsl);
//        }
//        System.debug('*** L2I_CaseMgmtDSLDAO getDSLRecords dslList ' + dslList.size());
//
//        return dslList;
//    }
//
//    public List<Case> getExistingCaseByDSL(Set<Id> orderIdSets, Set<Id> acIdSets, Set<Id> dslIdSets) {
//
//        List<Case> existingCase = [
//              SELECT Id
//              FROM Case
//              where
//              L2I_Order__c = NULL AND
//              L2I_Aircraft__c IN:acIdSets AND
//              L2I_Delivery_Schedule_Line__c IN:dslIdSets
//        ];
//
//        for (Case c : existingCase) {
//            System.debug('*** existingCase ' + c);
//        }
//        return existingCase;
//    }
//
////    public List<OrderItem> getOrderItemByOrderId(Set<Id> OrderId) {
////        List<Orderitem> orderItemList = [
////              SELECT Order.OpportunityId, L2I_Category__c, Id, Product2Id, L2I_ProductName__c, Quantity,
////                    L2I_Sub_Category_2__c, SBQQ__Subscription__c, OrderId, PricebookEntry.Product2.L2I_Service_Activation_Type__c,
////                    SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Type__c, L2I_Start_Date__c, ServiceDate, EndDate,
////                    Order.L2I_Original_Sales_Opportunity__c, L2I_blng_MatchingId__c, SBQQ__QuoteLine__c,
////                    Order.L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c
////              FROM Orderitem
////              WHERE Order.L2I_Product_Category_2__c IN:allowedProducts
////              AND Order.Opportunity.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c = true AND EndDate >= TODAY AND
////              Order.Opportunity.L2I_Product_Category__c IN:oppoProductCategories AND
////              (SBQQ__TerminatedDate__c = null OR SBQQ__TerminatedDate__c >= TODAY) AND
////              PricebookEntry.Product2.L2I_Service_Activation_Type__c != null AND OrderId IN:OrderId
////              order by Quantity desc
////        ];
////
////        for (OrderItem oi : orderItemList) {
////            System.debug('*** oi ' + oi);
////        }
////        return orderItemList;
////        return null;
////    }
////
//    public Set<Id> CreateCases(List<L2I_DSL__c> dslList, List<Order> orderList, Set<String> uniqueCaseSet) {
//        System.debug('*** L2I_CaseMgmtDSLDAO CreateCases ');
//        //Combine order into the respective records
//        Map<String, Set<Id>> categoryOrderMap = new Map<String, Set<Id>>();
//        Set<String> categorySet = new Set<String>();
//        Id oppoId;
//        Id originaloppId;
//        String originaloppoNumber;
//        Id accountId;
//        Set<Id> newCaseIds = new Set<Id>();
//
//        //Possible bug -> case already created regardless of quantity
//        for (Order o : orderList) {
//            System.debug('*** CreateCases orderList ' + o);
//            if (originaloppId == null &&
//                  o.L2I_Original_Sales_Opportunity__c != null) {
//                oppoId = o.OpportunityId;
//                originaloppId = o.L2I_Original_Sales_Opportunity__c;
//                originaloppoNumber = o.L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c;
//                accountId = o.AccountId;
//            }
//
//            if (categorySet.contains(o.L2I_Product_Category_2__c)) {
//                Set<Id> temp = categoryOrderMap.get(o.L2I_Product_Category_2__c);
//                temp.add(o.Id);
//                categoryOrderMap.put(o.L2I_Product_Category_2__c, temp);
//            } else {
//                categorySet.add(o.L2I_Product_Category_2__c);
//                Set<Id> orderIdSet = new Set<Id>();
//                orderIdSet.add(o.Id);
//                categoryOrderMap.put(o.L2I_Product_Category_2__c, orderIdSet);
//            }
//        }
//
//        // Based on each category, it will create a case at the per aircraft level
//        // It will also set the related order Item fields for future references
//        // ( L2I_Related_Order_Item__c ) This field doesn't show to the end user.
//        // It also set the case L2I_Routing_Path__c to be DSL
//        // If the case contain only one order, it will maintain the order ID, otherwise it will be blank
//        List<Case> newCaseList = new List<Case>();
//        System.debug('*** CreateCase uniqueCaseSet ' + uniqueCaseSet.size() + ' ' + uniqueCaseSet);
//        for (L2I_DSL__c dsl : dslList) {
//            Id acId = dsl.Aircraft__c;
//            Id dslId = dsl.Id;
//
//            for (String s : categorySet) {
//                System.debug('*** Category ' + s);
//                String uniqueKey = dsl.Aircraft__c + '' + dsl.Id;
//                System.debug('*** CreateCases uniqueKey ' + uniqueKey);
//
//                // To ensure the product has an actual order item to associate with the category
//                if (!uniqueCaseSet.contains(uniqueKey)) {
//                    Case acCase = new Case();
//                    acCase.L2I_Aircraft__c = acId;
//                    acCase.L2I_Original_Sales_Opportunity__c = originaloppId;
//                    acCase.L2I_Opportunity__c = oppoId;
//                    acCase.L2I_Product_Category_2__c = s;
//                    acCase.L2I_Related_Order__c = JSON.serialize(categoryOrderMap.get(s));
//                    //acCase.L2I_Related_Order_Item__c = JSON.serialize(categoryOrderMap.get(s));
//                    acCase.AccountId = accountId;
//                    acCase.L2I_Routing_Path__c = 'DSL';
//
//                    acCase.L2I_Delivery_Schedule_Line__c = dslId;
//                    acCase.Origin = 'CPQ Order';
//                    List<String> parameters = new List<String>();
//                    if (dsl.Aircraft__r.Name != null) {
//                        parameters.add(dsl.Aircraft__r.Name);
//                    }
//                    if (dsl.Aircraft__r.Name == null && dsl.Aircraft_Identifier__c != null) {
//                        parameters.add(dsl.Aircraft_Identifier__c);
//                    }
//                    parameters.add(s);
//                    parameters.add(originaloppoNumber);
//
//                    acCase.Subject = String.format(Label.L2I_Case_Subject, parameters);
//
//                    newCaseList.add(acCase);
//                }
//            }
//        }
//        if (newCaseList.size() > 0) {
//            System.debug('*** Inserting Cases ' + newCaseList.size() + ' ' + newCaseList);
//            insert newCaseList;
//            for (Case c : newCaseList) {
//                newCaseIds.add(c.Id);
//            }
//        }
//        return newCaseIds;
//    }
}