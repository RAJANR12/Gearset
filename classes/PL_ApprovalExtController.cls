public with sharing class PL_ApprovalExtController {
    private Id plApprovalId;
    public PL_ApprovalExtController(ApexPages.StandardController stdController) {
        plApprovalId = stdController.getId();
    }
    public PageReference onSubmit() {
    if (plApprovalId != null) {
            SBAA.ApprovalAPI.submit(plApprovalId, SBAA__Approval__c.P_L_Approval__c);
        }
        return new PageReference('/' + plApprovalId);
    }
    public PageReference onRecall() {
        if (plApprovalId != null) {
            SBAA.ApprovalAPI.recall(plApprovalId, SBAA__Approval__c.P_L_Approval__c);
        }
        return new PageReference('/' + plApprovalId);
    }

    // W-001995
    // Description: Used by Submit P&L Approval flow
    @InvocableMethod(label= 'Submit for Approval')
    public static void onSubmitFromFlow(List<Id> recordIds) {
        SBAA.ApprovalAPI.submit(recordIds[0], SBAA__Approval__c.P_L_Approval__c);
    }
}