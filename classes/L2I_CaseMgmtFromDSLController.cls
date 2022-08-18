/**
 *      @author       Andy Fang
 *      @date         03/17/2020
 *      @description  L2I_CaseMgmtFromDSLController
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                    03/17/2020         Initial scaffold
 *      Sarah Kennedy                06/10/2020         US1979 changed getOrderRecords to accept List<L2I_DSL__c> instead of List<Id>
 */
global class L2I_CaseMgmtFromDSLController {
    
    // A platform builder will be calling this function
    // The purpose of this cass is to create the case with the associated information for the batch class
    // to process.  The L2I_Related_Order_Item__c fields will contains information for the batch class
    // without running the query once again and it can be used as a validation for troubleshooting.
    
//    @InvocableMethod
//    global static void autoCreateAircraftServices(List<Id> dslIdList) {
//        System.debug('*** L2I_CaseMgmtFromDSLController dslIdList ' + dslIdList.size() + ' ' + dslIdList);
//        Set<Id> newCaseIds = new Set<Id>();
//        L2I_CaseMgmtDSLDAO dsldao = new L2I_CaseMgmtDSLDAO();
//        try {
//            // This process support only aircraft at a time
//            List<L2I_DSL__c> dsLineList = new List<L2I_DSL__c>();
//            dsLineList = dsldao.getDSLRecords(null, dslIdList);
//
//            if (dsLineList.size() > 0) {
//                List<Id> dshList = new List<Id>();
//                Set<Id> acIdSets = new Set<Id>();
//                Set<Id> dslIdSets = new Set<Id>();
//
//                //This is a default delivery scheduler header for aircrafts
//                for (L2I_DSL__c dsl : dsLineList) {
//                    dshList.add(dsl.Delivery_Schedule_Header__c);
//                    acIdSets.add(dsl.Aircraft__c);
//                    dslIdSets.add(dsl.Id);
//                }
//
//                List<Order> orderList = dsldao.getOrderRecords(null, dshList);
//
//                List<Case> existingCase = new List<Case>();
//                existingCase = dsldao.getExistingCaseByDSL(null, acIdSets, dslIdSets);
//
//                Set<String> uniqueCaseSet = New Set<String>();
//
//                //Check only if there is available data to compare with
//                if (existingCase.size() > 0) {
//                    for (case c : existingCase) {
//                        system.debug('Existing is : ' + c.L2I_Aircraft__c + '' + c.L2I_Delivery_Schedule_Line__c);
//                        uniqueCaseSet.add(c.L2I_Aircraft__c + '' + c.L2I_Delivery_Schedule_Line__c);
//                    }
//                }
//
//                if (dshList.size() > 0) {
//                    newCaseIds = dsldao.CreateCases(dsLineList, orderList, uniqueCaseSet);
//                }
//            }
//        } catch (Exception ex) {
//            System.debug('L2I_CaseMgmtFromDSLController has an issue : ' + ex.getMessage());
//        }
//    }

}