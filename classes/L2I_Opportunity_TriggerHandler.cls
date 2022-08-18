/**
 *      @author       Raj Rajen
 *      @date         07/12/2019
 *      @description  L2I Opportunity Trigger Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/12/2019         Initial scaffold
 *      Sarah Kennedy                 12/12/2019         Added before update and call to validatePLApproval
 *      Sarah Kennedy                 12/01/2019         Added after update call to updatePLApprovalSalesOppDesc
 *      Khrisna Elumba                06/10/2022         W-004450 added updatePLAutomatedSalesOppDesc in After Update
 */
public without sharing class L2I_Opportunity_TriggerHandler extends L2I_TriggerHandler {
    private static FINAL Boolean isPMO = PT_ValidateUserPMOUser.validatePMOUser()[0];

    private Map<Id, Opportunity> newOpportunityMap;
    private List<Opportunity> newOpportunityList;

    private Map<Id, Opportunity> oldOpportunityMap;
    private List<Opportunity> oldOpportunityList;

    public L2I_Opportunity_TriggerHandler() {
        this.newOpportunityMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.newOpportunityList = (List<Opportunity>) Trigger.new;

        this.oldOpportunityMap = (Map<Id, Opportunity>) Trigger.oldMap;
        this.oldOpportunityList = (List<Opportunity>) Trigger.old;
    }

    public override void beforeUpdate() {
        // valid trigger context vars:
        //     newOpportunityList  (modifiable)
        //     newOpportunityMap
        //     oldOpportunityList
        //     oldOpportunityMap
        System.debug('====== executing L2I_Opportunity_TriggerHander::beforeUpdate()');
        //if (!isPMO) {
            L2I_Opportunity_TriggerFunctions.validatePLApproval(newOpportunityList, newOpportunityMap, oldOpportunityMap);
        	L2I_Opportunity_TriggerFunctions.populateOperatorAirlineCode(newOpportunityList, newOpportunityMap, oldOpportunityMap);
        //}
        //L2I_Opportunity_TriggerFunctions.validatePriceOnQuote(newOpportunityList, oldOpportunityMap); // Added by Arun
    }

    public override void afterInsert() {
        // valid trigger context vars:
        //     newOpportunityList  (not modifiable)
        //     newOpportunityMap
        System.debug('====== executing L2I_Opportunity_TriggerHander::afterInsert()');
       // if (!isPMO) {
            L2I_Opportunity_TriggerFunctions.rollupParentOpportunityAmount(newOpportunityList);
            L2I_Opportunity_TriggerFunctions.updateAmendmentRenewalRelatedLists(newOpportunityList);
        //}
    }

    public override void beforeInsert() {
        // valid trigger context vars:
        //     newOpportunityList  (modifiable)
        System.debug('====== executing L2I_Opportunity_TriggerHander::beforeInsert()');
       // if (!isPMO) {
            L2I_Opportunity_TriggerFunctions.updateAmendmentRenewalFields(newOpportunityList);
            L2I_Opportunity_TriggerFunctions.populateOperatorAirlineCode(newOpportunityList);
       // }
    }

    public override void afterUpdate() {
        // valid trigger context vars:
        //     newOpportunityList  (not modifiable)
        //     newOpportunityMap
        //     oldOpportunityList
        //     oldOpportunityMap
        System.debug('======= executing Opportunity_TriggerHander::afterUpdate()');
        if (!Test.isRunningTest()) {
            // if (!isPMO) {
            L2I_Opportunity_TriggerFunctions.rollupParentOpportunityAmount(newOpportunityList,
                  newOpportunityMap,
                  oldOpportunityMap);
       // }
         }
        L2I_Opportunity_TriggerFunctions.updateQuoteShipToBillTo(newOpportunityList,oldOpportunityMap);//Added by Jan Geronga for W-003956
        L2I_Opportunity_TriggerFunctions.updatePLApprovalSalesOppDesc(newOpportunityList, newOpportunityMap, oldOpportunityMap);
        L2I_Opportunity_TriggerFunctions.updatePLAutomatedSalesOppDesc(newOpportunityList, newOpportunityMap, oldOpportunityMap); //W-004450
    }

    /**
    public override void beforeDelete() {
        // valid trigger context vars:
        //     oldOpportunityList
        //     oldOpportunityMap
        System.debug('======= executing Opportunity_TriggerHander::beforeDelete()');
        L2I_Opportunity_TriggerFunctions.rollupParentOpportunityAmount(oldOpportunityList);
    }
    **/

    public override void afterDelete() {
        // valid trigger context vars:
        //     oldOpportunityList
        //     oldOpportunityMap
        System.debug('======= executing Opportunity_TriggerHander::afterDelete()');
        //if (!isPMO) {
            L2I_Opportunity_TriggerFunctions.rollupParentOpportunityAmount(oldOpportunityList);
        //}
    }

    public override void afterUndelete() {
        // valid trigger context vars:
        //     newOpportunityList  (not modifiable)
        //     newOpportunityMap
        System.debug('====== executing L2I_Opportunity_TriggerHander::afterUndelete()');
       // if (!isPMO) {
            L2I_Opportunity_TriggerFunctions.rollupParentOpportunityAmount(newOpportunityList);
        //}
    }

}