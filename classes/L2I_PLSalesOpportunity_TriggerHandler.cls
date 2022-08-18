/**
 *      @author       Raj Rajen
 *      @date         03/24/2020
 *      @description  L2I PLSalesOpportunity Trigger Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     03/24/2020         Initial scaffold
 *      Francis Macam                 11/17/2021         Added updatePLApprovalSalesOppDesc in After Insert, Update, Delete, Undelete
 *      Khrisna Elumba                06/10/2022         W-004450 added updatePLAutomatedSalesOppDesc in After Insert, Update, Delete, Undelete
 */
public without sharing class L2I_PLSalesOpportunity_TriggerHandler extends L2I_TriggerHandler {

    private Map<Id, L2I_P_L_Sales_Opportunity__c> newPLSalesOpptyMap;
    private List<L2I_P_L_Sales_Opportunity__c> newPLSalesOpptyList;

    private Map<Id, L2I_P_L_Sales_Opportunity__c> oldPLSalesOpptyMap;
    private List<L2I_P_L_Sales_Opportunity__c> oldPLSalesOpptyList;

    public L2I_PLSalesOpportunity_TriggerHandler() {
        this.newPLSalesOpptyMap = (Map<Id, L2I_P_L_Sales_Opportunity__c>) Trigger.newMap;
        this.newPLSalesOpptyList = (List<L2I_P_L_Sales_Opportunity__c>) Trigger.new;

        this.oldPLSalesOpptyMap = (Map<Id, L2I_P_L_Sales_Opportunity__c>) Trigger.oldMap;
        this.oldPLSalesOpptyList = (List<L2I_P_L_Sales_Opportunity__c>) Trigger.old;
    }
    
    public override void beforeInsert() {
        System.debug('====== executing L2I_PLSalesOpportunity_TriggerHander::beforeInsert()');
        L2I_PLSalesOpportunity_TriggerFunctions.updateQuoteLookup(newPLSalesOpptyList);
    }

    public override void afterInsert() {
        // valid trigger context vars:
        //     newPLSalesOpptyList  (not modifiable)
        //     newPLSalesOpptyMap
        System.debug('====== executing L2I_PLSalesOpportunity_TriggerHander::afterInsert()');

        L2I_PLSalesOpportunity_TriggerFunctions.updatePLApprovalFinancials(newPLSalesOpptyList);
        L2I_PLSalesOpportunity_TriggerFunctions.updatePTSStation(newPLSalesOpptyList);//Added by Jan Geronga for W-003016
        L2I_PLSalesOpportunity_TriggerFunctions.updatePLApprovalSalesOppDesc(newPLSalesOpptyList);
        L2I_PLSalesOpportunity_TriggerFunctions.updatePLAutomatedSalesOppDesc(newPLSalesOpptyList);//W-004450
    }


    public override void afterUpdate() {
        // valid trigger context vars:
        //     newPLSalesOpptyList  (not modifiable)
        //     newPLSalesOpptyMap
        //     oldPLSalesOpptyList
        //     oldPLSalesOpptyMap
        System.debug('======= executing L2I_PLSalesOpportunity_TriggerHander::afterUpdate()');

        L2I_PLSalesOpportunity_TriggerFunctions.updatePLApprovalFinancials(newPLSalesOpptyList,
                                                                           newPLSalesOpptyMap,
                                                                           oldPLSalesOpptyMap);
        L2I_PLSalesOpportunity_TriggerFunctions.updatePLApprovalSalesOppDesc(newPLSalesOpptyList,
                                                                             newPLSalesOpptyMap,
                                                                             oldPLSalesOpptyMap);
        L2I_PLSalesOpportunity_TriggerFunctions.updatePLAutomatedSalesOppDesc(newPLSalesOpptyList); //W-004450
    }

    public override void afterDelete() {
        // valid trigger context vars:
        //     oldPLSalesOpptyList
        //     oldPLSalesOpptyMap
        System.debug('======= executing L2I_PLSalesOpportunity_TriggerHander::afterDelete()');

        L2I_PLSalesOpportunity_TriggerFunctions.updatePLApprovalFinancials(oldPLSalesOpptyList);
        L2I_PLSalesOpportunity_TriggerFunctions.updatePLApprovalSalesOppDesc(oldPLSalesOpptyList);
        L2I_PLSalesOpportunity_TriggerFunctions.updatePLAutomatedSalesOppDesc(oldPLSalesOpptyList);//W-004450
    }

    public override void afterUndelete() {
        // valid trigger context vars:
        //     newPLSalesOpptyList  (not modifiable)
        //     newPLSalesOpptyMap
        System.debug('====== executing L2I_PLSalesOpportunity_TriggerHander::afterUndelete()');

        L2I_PLSalesOpportunity_TriggerFunctions.updatePLApprovalFinancials(newPLSalesOpptyList);
        L2I_PLSalesOpportunity_TriggerFunctions.updatePLAutomatedSalesOppDesc(newPLSalesOpptyList);//W-004450
    }

}