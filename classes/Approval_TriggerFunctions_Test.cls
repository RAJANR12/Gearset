/**
 * @Description        : Test class for Approval_TriggerFunctions
 * @Author             : Jan Denrick Geronga / Managed Services Simplus
 * @Modification Log   :
 * Ver       	Date       	  Author              Modification
 * W-004155   	Dec-14-2021   MS Simplus Jan      Initial Version
 **/

@isTest(SeeAllData=false)
public class Approval_TriggerFunctions_Test {
    
    @IsTest
    static void setRecordType_Test() {
        //Added by Jan Geronga for W-004266: START
        Account testAccount = new Account(Name = 'testAcc', L2I_Airline_Code__c = 'PAC');
        insert testAccount;
        
        Opportunity testOpportunity = new Opportunity(Name = 'testOpp', 
                                          StageName = 'Open',
                                          CloseDate = Date.today(),
                                          AccountId = testAccount.Id);
        insert testOpportunity;
        
        L2I_P_L_Approval__c pnlApproval = new L2I_P_L_Approval__c(ApprovalStatus__c = null,
                                             L2I_Approval_Deal_Opportunity__c = testOpportunity.Id,
                                             L2I_Revision_Status__c = 'Initial');
        insert pnlApproval;
        //Added by Jan Geronga for W-004266: END
        
        List<sbaa__Approval__c> lApproval = new List<sbaa__Approval__c>();
        sbaa__Approval__c app = new sbaa__Approval__c(
            sbaa__Status__c = 'Requested',
            sbaa__ApprovalStep__c = 1,
            sbaa__RecordField__c = 'P_L_Approval__c',
            P_L_Approval__c = pnlApproval.Id //Added by Jan Geronga for W-004266
        );
        
        lApproval.add(app);
        
        sbaa__Approval__c app1 = new sbaa__Approval__c(
            sbaa__Status__c = 'Requested',
            sbaa__ApprovalStep__c = 1,
            sbaa__RecordField__c = 'Quote__c'
        );
        
        lApproval.add(app1);
        
        sbaa__Approval__c app2 = new sbaa__Approval__c(
            sbaa__Status__c = 'Requested',
            sbaa__ApprovalStep__c = 1,
            sbaa__RecordField__c = 'Opportunity'
        );
        
        lApproval.add(app2);
        
        test.startTest();
        insert lApproval;
        test.stopTest();
    }
}