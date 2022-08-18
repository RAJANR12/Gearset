/**
 *      @author       Andy Fang
 *      @date         03/17/2020
 *      @description  L2I_CaseMgmtFromCROrderController
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                    03/17/2020         Initial scaffold
 *      Sarah Kennedy                06/10/2020         US1979 changed getOrderRecords to accept List<L2I_DSL__c> instead of List<Id>
 *      Sarah Kennedy                07/16/2020         US2104 Aircraft Changes -  Also removed this class from the
 *                                                          L2I_CaseMgmtDAO interface class as the
 *                                                          Order query was moved into L2I_CaseMgmtFromCROrderBatch
 *      Sarah Kennedy                 02/03/2021        replace filter for L2I_Product_Category_2__c with L2I_Service_Activation_Type__c
 */

public class L2I_CaseMgmtFromCROrderController {
    
    // This class is being called via L2I_CaseMgmtFromCROrderBatch after completion of the Order Activation Batch
    
    public Set<Id> autoCreateAircraftServices(List<Order> orderList) {
//        Set<String> allowedProducts;
        Set<String> oppoProductCategories;
//        allowedProducts = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
//              'Allowed Products');
        oppoProductCategories = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
              'Product Category');
        
        System.debug('*** in autoCreateAircraftServices ');
        Set<Id> newCaseIds = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();
        L2I_CaseMgmtCROrderDAO crOrderDAO = new L2I_CaseMgmtCROrderDAO();
        List<Order> caseOrderList = new List<Order>();
        try {
            System.debug('*** orderList ' + orderList); // passed from L2I_CaseMgmtFromCROrderBatch
            System.debug('*** orderList.size() ' + orderList.size());
            // set the Revise Modified and Auto Activate values on the orders
            Set<Id> reviseCheckIds = new Set<Id>();
            for (Order ord : orderList) {
                if (ord.Type == 'Renewal') {
                    reviseCheckIds.add(ord.Id);
                }
            }
            // determine if a revise order has been modified or needs to be auto-activated
            Set<Id> revisedOrderIds = new Set<Id>();
            if (!reviseCheckIds.isEmpty()) {
                revisedOrderIds = L2I_OrderService.determineReviseModified(reviseCheckIds);
                if (revisedOrderIds != null && revisedOrderIds.size() > 0){
                    // update the L2I_Revise_Modified__c field on the Orders in memory only (as it was already updated above
                    for (Order o : orderList) {
                        if (revisedOrderIds.contains(o.Id)){
                            o.L2I_Revise_Modified__c = true;
                        }
                    }
                }
            }
            
            // whittle down the order list to just those allowed for Case processing
            for (Order ord : orderList) {
//                System.debug('*** allowedProducts ' + allowedProducts);
                System.debug('*** oppoProductCategories ' + oppoProductCategories);
                System.debug('*** ord.Opportunity.L2I_Product_Category__c ' + ord.Opportunity.L2I_Product_Category__c);
                System.debug('*** ord.L2I_Product_Category_2__c ' + ord.L2I_Product_Category_2__c);
                System.debug('*** ord.L2I_Order_Process__c ' + ord.L2I_Order_Process__c);
                System.debug('*** ord.Opportunity.L2I_AutoExtend__c ' + ord.Opportunity.L2I_AutoExtend__c);
//                if (allowedProducts.contains(ord.L2I_Product_Category_2__c.toLowerCase()) &&
                   if (!String.isBlank(ord.L2I_Service_Activation_Types__c) &&
                      oppoProductCategories.contains(ord.Opportunity.L2I_Product_Category__c) &&
                      ord.L2I_Order_Process__c == 'Contract Management') {
                    quoteIds.add(ord.SBQQ__Quote__c);
                    caseOrderList.add(ord);
                }
            }
            System.debug('*** caseOrderList ' + caseOrderList);
            System.debug('*** caseOrderList.size() ' + caseOrderList.size() );

            List<L2I_DSL__c> dslList = crOrderDAO.getDSLRecords(quoteIds);
            System.debug('*** dslList ' + dslList);
    
            //To getting existing case record with the OrderID, ACID, DSLID
            Set<Id> orderIdSets = new Set<Id>();
            Set<Id> acIdSets = new Set<Id>();
            Set<Id> dslIdSets = new Set<Id>();
            
            for (Order o : caseOrderList) {
                orderIdSets.add(o.Id);
            }
            
            for (L2I_DSL__c dsl : dslList) {
                acIdSets.add(dsl.Aircraft__c);
                dslIdSets.add(dsl.Id);
            }
            
            List<Case> existingCase = crOrderDAO.getExistingCaseByDSL(orderIdSets, acIdSets, dslIdSets);
            System.debug('*** existingCase ' + existingCase);
            
            Set<String> uniqueCaseSet = new Set<String>();
            
            //Check only if there is available data to compare with
            if (existingCase.size() > 0) {
                for (Case c : existingCase) {
                    System.debug('*** Existing is : ' + c.L2I_Order__c + '' + c.L2I_Aircraft__c + '' + c.L2I_Delivery_Schedule_Line__c);
                    uniqueCaseSet.add(c.L2I_Order__c + '' + c.L2I_Aircraft__c + '' + c.L2I_Delivery_Schedule_Line__c);
                }
            }
            System.debug('*** uniqueCaseSet ' + uniqueCaseSet);
            
            if (dslList.size() > 0) {
                newCaseIds = crOrderDAO.CreateCases(dslList, caseOrderList, uniqueCaseSet);
                System.debug('*** newCaseIds ' + newCaseIds);
            }
        } catch (Exception ex) {
            system.debug('*** ' + ex.getLineNumber() + ' : You ran into an issue ' + ex.getMessage());
        }
        return newCaseIds;
    }
}