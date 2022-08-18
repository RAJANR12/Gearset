/**
* @Apex Class         : PL_ApprovalReportController_Test
* @Description        : Test class for PL_ApprovalReportController
* @Author             : Jan Denrick Geronga / Managed Services Simplus
* @Modification Log   :
* Ver       	Date       	  Author              Modification
* W-004439    	May-24-2022   MS Simplus Jan      Initial Version
**/

@isTest
public class PL_ApprovalReportController_Test {
    private static L2I_DataFactory factory = new L2I_DataFactory();
    private static PL_ApprovalReportController cls = new PL_ApprovalReportController();
    
    @isTest
    public static void getApprovalsForCurrentUser_Test(){
        List<sbaa__Approver__c> approvers = new List<sbaa__Approver__c>();
        List<String> recipientEmail = new List<String>();
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'PAC Sales'].Id;
        User u = factory.createTestUser(null, profileId, 'User1', 'Test');
        insert u;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
            insert namedCustomer;
            
            Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
            insert dealOppty;
            
            L2I_P_L_Approval__c pla = factory.createPLApproval(dealOppty.Id, 'Pending');
            pla.L2I_Revision_Status__c = 'Initial';
            insert pla;
            
            Group testGroup = new Group(Name='TestGroup', DeveloperName='TestGroup12345');
            insert testGroup;
            
            
            GroupMember gm = new GroupMember(GroupId = testGroup.Id, UserOrGroupId = UserInfo.getUserId());
            insert gm;
            
            
            sbaa__Approver__c approver = new sbaa__Approver__c(Name = 'Test', sbaa__User__c = u.Id);
            approvers.add(approver);
            
            sbaa__Approver__c approver1 = new sbaa__Approver__c(Name = 'Test', sbaa__GroupId__c = testGroup.Id);
            approvers.add(approver1);
            
            insert approvers;
            
            sbaa__ApprovalRule__c rule = new sbaa__ApprovalRule__c(Name = 'Test', sbaa__Active__c = true, sbaa__TargetObject__c = 'L2I_P_L_Approval__c');
            insert rule;
            
            Id recordTypeId = Schema.SObjectType.sbaa__Approval__c.getRecordTypeInfosByDeveloperName().get('P_L_Approval').getRecordTypeId();
            
            sbaa__Approval__c app = new sbaa__Approval__c(sbaa__Status__c = 'Requested', sbaa__ApprovalStep__c = 2, sbaa__RecordField__c = 'P_L_Approval__c', 
                                                          sbaa__Rule__c = rule.Id, RecordTypeId = recordTypeId, sbaa__Archived__c = false, sbaa__Approver__c = approvers[0].Id,
                                                          P_L_Approval__c = pla.Id);
            insert app;
            
            sbaa__Approval__c app1 = new sbaa__Approval__c(sbaa__Status__c = 'Requested', sbaa__ApprovalStep__c = 2, sbaa__RecordField__c = 'P_L_Approval__c', 
                                                           sbaa__Rule__c = rule.Id, RecordTypeId = recordTypeId, sbaa__Archived__c = false, sbaa__Approver__c = approvers[1].Id);
            insert app1;
            
        }
        
        sbaa__Approval__c app = [SELECT Id, Name, Automated_Deal_Opportunity_Description__c, Revision_Status__c, CreatedDate FROM sbaa__Approval__c WHERE P_L_Approval__c != null LIMIT 1];
        L2I_P_L_Approval__c pla = [SELECT Id, Name FROM L2I_P_L_Approval__c LIMIT 1];
        
        recipientEmail.add('email@test.com');
        
        PL_ApprovalReportController.FlowInput fi = new PL_ApprovalReportController.FlowInput();
        fi.recipientEmail = recipientEmail;
        fi.approvalId = app.Id;
        fi.userId = u.Id;
        
        PL_ApprovalReportController.PendingApprovals pApprovals = new PL_ApprovalReportController.PendingApprovals();
        pApprovals.approvalName = app;
        pApprovals.relatedTo = pla.Name;
        pApprovals.relatedToId = pla.Id;
        pApprovals.groupName = pla.Name;
        pApprovals.groupId = pla.Id;
        pApprovals.creationDate = String.valueOf(app.CreatedDate);
        pApprovals.automatedDealDesc = app.Automated_Deal_Opportunity_Description__c;
        pApprovals.revisionStatus = app.Revision_Status__c;
        pApprovals.approvalDealOpptyId = app.Automated_Deal_Opportunity_Description__c;
        
        PL_ApprovalReportController.Pager pGer = new PL_ApprovalReportController.Pager(1, false);
        
        Test.startTest();
        System.runAs (u) {
            cls.getApprovalsForCurrentUser();
        }
        cls.getApprovalsForGroupUser();
        PL_ApprovalReportController.PL_ApprovalInvocableEmailSend(new List<PL_ApprovalReportController.FlowInput>{fi});
        Test.stopTest();
    }
    
    @isTest
    public static void Page_Test(){
        cls.previousPage();
        cls.nextPage();
        cls.updatePage();
        cls.changeData();
        
    }
}