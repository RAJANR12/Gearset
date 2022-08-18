/**
* @Apex Class         : PL_ApprovalReportController
* @Description        : Controller for PL_ApprovalReportControllerPage
* @Author             : Jan Denrick Geronga / Managed Services Simplus
* @Modification Log   :
* Ver       	Date       	  Author              Modification
* W-004439    	May-19-2022   MS Simplus Jan      Initial Version
**/

public with sharing class PL_ApprovalReportController {
    public List<sbaa__Approval__c> approvals;
    public Set<sbaa__Approval__c> listApprovalsForSingleUsers = new Set<sbaa__Approval__c>();
    public List<sbaa__Approval__c> listApprovalsForGroups = new List<sbaa__Approval__c>();
    public List<PendingApprovals> allPendingApprovals {get; set;}
    public Map<Integer, List<PendingApprovals>> mapAllPendingApprovals {get; set;}
    public List<List<PendingApprovals>> fullGenericList{get;set;}
    public Integer numberLimit {get; set;}
    public List<selectOption> records {get; set;}
    public Integer total {get; set;}
    public Integer pageNum {get;set;}
    public List<Pager> pageList {get;set;}
    public Integer totalPage {get;set;}
    public Integer totalResults {get;set;}
    public Boolean showPrevious {get;set;}
    public Boolean showNext {get;set;}
    public Boolean isAll {get;set;}
    
    public PL_ApprovalReportController() {
        total = getApprovalsForGroupUser().size() + getApprovalsForCurrentUser().size();
        approvals = new List<sbaa__Approval__c>();
        getApprovalsForCurrentUser();    
        getApprovalsForGroupUser();    
        listApprovalsForSingleUsers.addAll(listApprovalsForGroups);
        //system.assertEquals(listApprovalsForSingleUsers, null);
        PendingApprovals appWrapper = new PendingApprovals();
        List<PendingApprovals> tempPendingApprovals = appWrapper.processApprovalWrapper(listApprovalsForSingleUsers);
        List<PendingApprovals> tmpPAs = new List<PendingApprovals>();
        Map<Integer, List<PendingApprovals>> mapPAs = new Map<Integer, List<PendingApprovals>>();
        Integer counter = 1;
        Integer page    = 1;
        for(PendingApprovals pa: tempPendingApprovals) {
            tmpPAs.add(pa);
            if( Math.mod(counter, 5) == 0 || counter == tempPendingApprovals.size() ) {
                mapPAs.put(page, tmpPAs);
                tmpPAs = new List<PendingApprovals>();
                page++;
            }
            counter ++;
        }
        this.allPendingApprovals = new List<PendingApprovals>();
        this.totalPage = (Integer)Math.ceil((Double)tempPendingApprovals.size() / (Double)5);
        this.isAll = (tempPendingApprovals.size() == 5)?true:false;
        this.pageNum = 1;
        this.mapAllPendingApprovals = mapPAs;
        this.allPendingApprovals = this.mapAllPendingApprovals.get(this.pageNum);
        updateNumbers();
    }

    public set<sbaa__Approval__c> getApprovalsForCurrentUser() {
        for (sbaa__Approval__c approval : [SELECT Id
                           ,Name
                           ,sbaa__Actions__c
                           ,sbaa__RecordField__c
                           ,sbaa__Approver__r.sbaa__User__c
                           ,sbaa__Approver__r.sbaa__GroupId__c
                           ,CreatedById
                           ,CreatedDate
                           ,P_L_Approval__r.Id
                           ,P_L_Approval__r.Name
                           ,P_L_Approval__r.L2I_Approval_Deal_Opportunity__r.L2I_Deal_Opportunity_Description__c
                           ,P_L_Approval__r.L2I_Approval_Deal_Opportunity__c
                           ,Revision_Status__c
                      FROM sbaa__Approval__c 
                      WHERE (sbaa__Approver__r.sbaa__User__c != null) 
                             AND (sbaa__Status__c = 'Requested') AND sbaa__Archived__c = false AND sbaa__RecordField__c = 'P_L_Approval__c']) {
                                 
            if (approval.sbaa__Approver__r.sbaa__User__c == UserInfo.getUserId()) {
                listApprovalsForSingleUsers.add(approval);
            }
                                 
        }
        return listApprovalsForSingleUsers;
    }
    
    public List<sbaa__Approval__c> getApprovalsForGroupUser() {
        approvals = [SELECT Id
                     ,name
                     ,sbaa__Actions__c
                     ,sbaa__RecordField__c
                     ,sbaa__Approver__r.sbaa__GroupId__c
                     ,CreatedById
                     ,CreatedDate
                     ,P_L_Approval__r.Id
                     ,P_L_Approval__r.Name
                     ,P_L_Approval__r.L2I_Approval_Deal_Opportunity__r.L2I_Deal_Opportunity_Description__c
                     ,P_L_Approval__r.L2I_Approval_Deal_Opportunity__c
                     ,Revision_Status__c
                     FROM sbaa__Approval__c 
                     WHERE (sbaa__Approver__r.sbaa__GroupId__c != null) 
                     AND (sbaa__Status__c = 'Requested') AND sbaa__Archived__c = false AND sbaa__RecordField__c = 'P_L_Approval__c'];
        
        Map<Id,Set<Id>> mapOfGroupIdWithUserId =  new Map<Id,Set<Id>>();
        List<Id> groupID = new List<Id>();
        
        for (sbaa__Approval__c approvals : approvals) {
            if (approvals.sbaa__Approver__r.sbaa__GroupId__c != null) {
                groupID.add(approvals.sbaa__Approver__r.sbaa__GroupId__c);
            }
        }
        
        List<GroupMember> groupMembers = [Select Id
                                                ,group.type
                                                ,UserOrGroupId 
                                            From GroupMember 
                                            where group.id In : groupID];
                                            
        for(GroupMember member : groupMembers) {    
            if (!mapOfGroupIdWithUserId.containsKey(member.group.id)) {
                mapOfGroupIdWithUserId.put(member.group.id , new Set<Id> {member.UserOrGroupId} );
            } else {
                Set<Id> members = mapOfGroupIdWithUserId.get(member.group.id);
                members.add(member.UserOrGroupId);
                mapOfGroupIdWithUserId.put(member.group.id , members);
            }
        }
        
        for (sbaa__Approval__c groupApproval : approvals) {
            if (groupApproval.sbaa__Approver__r.sbaa__GroupId__c != null) {
                Set<Id> usersId = mapOfGroupIdWithUserId.get(groupApproval.sbaa__Approver__r.sbaa__GroupId__c);
                if (usersId != null
                    && !usersId.Isempty() 
                    && usersId.contains(UserInfo.getUserId())) {
                        listApprovalsForGroups.add(groupApproval );
                    } 
            }
        }
        return listApprovalsForGroups;
    }
    
    public PageReference previousPage(){
        this.pageNum = this.pageNum - 1;
        updateNumbers();
        return changeData();
    }
    
    public PageReference nextPage(){
        this.pageNum = this.pageNum + 1;
        updateNumbers();
        return changeData();
    }
    
    public PageReference updatePage(){
        this.updateNumbers();
        return changeData();
    }
    
    public PageReference changeData(){
        this.allPendingApprovals = this.mapAllPendingApprovals.get(this.pageNum);
        return null;
    }
    
    public void updateNumbers() {
       this.pageList = new List<Pager>();
       for(Integer i = 1; i < (this.totalPage + 1); i++){
           Boolean b = (i == pageNum) ? true : false;
           this.pageList.add(new Pager(i, b));
       }
    }
    
    public class Pager{
       public Integer pNum {get;set;}
       public Boolean isActive {get;set;}
       public Pager(Integer num, Boolean active){
           this.pNum = num;
           this.isActive = active;
       }
    }
    
    public class PendingApprovals{
        public sbaa__Approval__c approvalName{get; set;}
        public String relatedTo{get; set;}
        public String relatedToId{get; set;}
        public String groupName{get; set;} // change
        public String groupId{get; set;} // change
        public String creationDate{get; set;} // change
        public String automatedDealDesc{get; set;}
        public String revisionStatus{get; set;}
        public String approvalDealOpptyId{get; set;}
                
        public List<PendingApprovals> processApprovalWrapper(Set<sbaa__Approval__c> approvals) {
            Map<Id,String> mapOfGroupIdWithName = new Map<Id,String>();
            List<String> groupIds = new List<String>();
            List<PendingApprovals> allPendingApprovals = new List<PendingApprovals>();
            for (sbaa__Approval__c approval : approvals) {
                if (approval.sbaa__Approver__r.sbaa__GroupId__c != null) {
                    groupIds.add(approval.sbaa__Approver__r.sbaa__GroupId__c);
                }
            }
            List<Group> groupList = [select id,name from group where id In : groupIds];
            
            for (Group groups : groupList ) {
                mapOfGroupIdWithName.put(groups.Id, groups.Name);      
            }
            
            for (sbaa__Approval__c approval : approvals) {
                PendingApprovals pendingApproval = new PendingApprovals();
                pendingApproval.approvalName = approval;
                pendingApproval.relatedTo = approval.P_L_Approval__r.Name;
                pendingApproval.relatedToId = approval.P_L_Approval__r.Id;
                if (approval.P_L_Approval__r.L2I_Approval_Deal_Opportunity__c != null) {
                    pendingApproval.automatedDealDesc = approval.P_L_Approval__r.L2I_Approval_Deal_Opportunity__r.L2I_Deal_Opportunity_Description__c;
                    pendingApproval.approvalDealOpptyId = approval.P_L_Approval__r.L2I_Approval_Deal_Opportunity__c;
                }
                pendingApproval.revisionStatus = approval.Revision_Status__c;
                
                allPendingApprovals.add(pendingApproval);                          
            }
            return allPendingApprovals;
        }
    }
    
    @InvocableMethod(label='P&L Approval Other Approvers Notification')
    public static void PL_ApprovalInvocableEmailSend (List<FlowInput> inputs) {
        List<String> recipientEmail;
        Id userId;
        String approvalId;
        
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, Description, HtmlValue, DeveloperName,Body
            FROM EmailTemplate
            WHERE DeveloperName = 'P_L_Approval_Other_Approvers_Notification'];
        
        for (FlowInput inId : inputs) {
            recipientEmail = inId.recipientEmail;
            String templateId = emailTemplate.Id;
            userId = inId.userId;
            approvalId = inId.approvalId;
            
            
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, userId, approvalId);
            
            String emailSubject = email.getSubject();
            String emailHTMLBody = email.getHtmlBody();
            
            email.setWhatId(approvalId);
            email.setToAddresses(recipientEmail);
            
            email.setSubject(emailSubject);
            email.setHtmlBody(emailHTMLBody);
            email.saveAsActivity = false;
            
            if (!Test.isRunningTest()) {
                Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    email
                        });
                
                for (Messaging.SendEmailResult rr : r) {
                    if (rr.isSuccess()) {
                        System.debug('Email result ' + rr.IsSuccess());
                    } else {
                        System.debug('Error Email result ' + rr.getErrors());
                    }
                }
            }
        }
    }
    
    public class FlowInput {
        @InvocableVariable public List<String> recipientEmail;
        @InvocableVariable public String approvalId;
        @InvocableVariable public Id userId;
    }
}