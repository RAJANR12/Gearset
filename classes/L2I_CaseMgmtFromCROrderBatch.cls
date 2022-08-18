/**
 *      @author       Sarah Kennedy
 *      @date         07/16/2020
 *      @description  L2I_CaseMgmtFromCROrderBatch - Process Orders that have been created from Create Order flow
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                   07/15/2020          Initial scaffold
 *      Sarah Kennedy                   02/03/2021        added fields to query ' L2I_Service_Activation_Types__c, L2I_Feature_ID__c, L2I_Feature_Name__c'
 */

global class L2I_CaseMgmtFromCROrderBatch implements Database.Batchable<sObject>, Database.Stateful {
    private List<Id> quoteIds;
    private Set<Id> allNewCaseIds = new Set<Id>();
    
    public L2I_CaseMgmtFromCROrderBatch(List<Id> quoteIdList) {
        quoteIds = quoteIdList;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('*** Starting L2I_CaseMgmtFromCROrderBatch');
        //DE417 - Adding End date to the query to ensure order isn't expired
        //Updating query to remove date comparison on the Order level, due to a recursive trigger error
        String query = 'SELECT Id, ' +
              ' L2I_Original_Sales_Opportunity__c, ' +
              ' L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c, ' +
              ' OpportunityId, ' +
              ' SBQQ__Quote__c, ' +
              ' Type, ' +
              ' Opportunity.L2I_AutoExtend__c, ' +
              ' Opportunity.L2I_Opportunity_Number__c, ' +
              ' Opportunity.L2I_Product_Category__c, '+
              ' L2I_Order_Process__c, ' +
              ' L2I_Revise_Modified__c, ' +
              ' L2I_Product_Category_2__c, ' +
              ' L2I_Service_Activation_Types__c, L2I_Feature_ID__c, L2I_Feature_Name__c, ' +
              ' AccountId, ' +
              ' ( select Id from OrderItems where EndDate >= Today ) ' +
              ' FROM Order ' +
              ' WHERE Opportunity.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c = true ' +
              ' AND Opportunity.L2I_AutoExtend__c = false ' +
              ' AND SBQQ__Quote__c IN:quoteIds ' ;
        System.debug('*** query ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Order> scope) {
        System.debug('*** Executing L2I_CaseMgmtFromCROrderBatch orders ' + scope);
        Set<Id> newCaseIds = new Set<Id>();

        L2I_CaseMgmtFromCROrderController b = new L2I_CaseMgmtFromCROrderController();
        newCaseIds = b.autoCreateAircraftServices(scope);
        System.debug('*** Cases created ' + newCaseIds);
        allNewCaseIds.addAll(newCaseIds);
    }
    
    global void finish(Database.BatchableContext bc) {
//        System.debug('*** L2I_CaseMgmtFromCROrderBatch finish ');
        System.debug('*** L2I_CaseMgmtFromCROrderBatch finish allCases ' + allNewCaseIds);
        Integer BatchSize = Integer.valueOf (
              L2I_JSON_Settings.getSpecificSetting('Aircraft_Services_Management_Settings',
                    'BatchSize'));

        if (!allNewCaseIds.isEmpty()) {
            L2I_CM_AircraftService_Batch b = new L2I_CM_AircraftService_Batch (allNewCaseIds);
            Database.executeBatch(b, BatchSize);
        }
    }
}