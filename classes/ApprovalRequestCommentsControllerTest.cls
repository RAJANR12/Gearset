@isTest
public class ApprovalRequestCommentsControllerTest {
	@IsTest
    static void testApprovalComments() {
        PT_SendEmailApprovalPendingMRODTest.testSetup();
        Id user1 = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1].Id;
        
        List<PT_Program__c> progList = [SELECT Id FROM PT_Program__c LIMIT 1];
        List<Id> progListId = new List<Id>();
        
        for(PT_Program__c prog: progList){
            progListId.add(prog.Id);                        
        }
        
        if(!progListId.isEmpty()){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval from test');
            req1.setObjectId(progListId[0]);
            
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(user1);
            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId('Program_MROD_Approval_v3');
            req1.setSkipEntryCriteria(true);      
            
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);         
            
            System.assert(result.isSuccess());
            
            System.assertEquals(
                'Pending', result.getInstanceStatus(), 
                'Instance Status'+result.getInstanceStatus()); 
            
            ApprovalRequestCommentsController ctrl = new ApprovalRequestCommentsController();
            String comments = ctrl.comments;                        
        }
    }
}