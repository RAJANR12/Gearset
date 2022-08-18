/**
 * @Description        : Handler for Approval_Trigger
 * @Author             : Jan Denrick Geronga / Managed Services Simplus
 * @Modification Log   :
 * Ver       	Date       	  Author              Modification
 * W-004155   	Dec-14-2021   MS Simplus Jan      Initial Version
 **/

public without sharing class Approval_TriggerHandler extends L2I_TriggerHandler {
    private List<sbaa__Approval__c> newApprovalList;
    private Map<Id, sbaa__Approval__c> oldApprovalMap;

    public Approval_TriggerHandler() {
        this.newApprovalList = (List<sbaa__Approval__c>) Trigger.new;
        this.oldApprovalMap = (Map<Id, sbaa__Approval__c>) Trigger.oldMap;
    }
    
    public override void beforeInsert() {
        Approval_TriggerFunctions.setRecordType(newApprovalList);
        Approval_TriggerFunctions.copyFieldValues(newApprovalList);// Added by Jan Geronga for W-004266
    }
}