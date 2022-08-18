/**
 *
 *      @author       Andy Fang
 *      @date         09/24/2019
 *      @description  L2I Usage Summary Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                     09/24/2019         Initial scaffold
 */

public without sharing class L2I_UsageSummary_TriggerHandler extends L2I_TriggerHandler {

    private Map<Id, blng__UsageSummary__c> newSummaryMap;
    private List<blng__UsageSummary__c> newSummaryList;

    private Map<Id, blng__UsageSummary__c> oldSummaryMap;
    private List<blng__UsageSummary__c> oldSummaryList;

    public L2I_UsageSummary_TriggerHandler() {
        this.newSummaryMap = (Map<Id, blng__UsageSummary__c>) Trigger.newMap;
        this.newSummaryList = (List<blng__UsageSummary__c>) Trigger.new;

        this.oldSummaryMap = (Map<Id, blng__UsageSummary__c>) Trigger.oldMap;
        this.oldSummaryList = (List<blng__UsageSummary__c>) Trigger.old;
    }

    public override void beforeInsert() {
        System.debug('======= executing UsageSummary_TriggerHander::beforeInsert()');
        L2I_UsageSummary_TriggerFunctions.copyMatchIDFromOrderItem( newSummaryList );
    }

}