/**
 *      @author       
 *      @date         
 *      @description  PT_PartsListApproval 
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *		--								--					Initial
 *		QOng							Sept-1-2021			W-003749 - Updated to include the Changes for CR PPL Type
 */
public without sharing class PT_PartsListApproval {
    
   /**
    * @Method Name        : processPartsListApproval
    * @Description        : This method updates the Opportunity and Generates File upon approval of Parts List modification
    * @Author             : 
    * @Modification Log   : 
    * Ver       	Date       	  	Author              Modification
    * --			--			  	--				    Initial Version
    * 				Sept-1-2021		MS Simplus QOng		W-003749 Formatting for CR PPL Type
    **/
    @InvocableMethod(Label = 'Parts List Approval')
    public static void processPartsListApproval(List<PLApprovalParams> params) {
        String oppId = params[0].oppId;
        String submitterComments = params[0].comments;
        // Submit the Approval Request
        // Opportunity cannot have queues (will be GA in Summer '21).
        // The requirement is to allow Approval by any PM but only send an Approval email to the Program's PM Mgr
        // This could be accomplished by specifying the Related User for the PM Mgr, and the PM queue to allow other PMs
        // to approve, also, but with no email sent to the queue members (controlled by the queue not sending emails)
        // But cannot do that in configuration with the Opportunity (due to no Opportunity queue allowed), but
        // we can do it via Apex
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
        QueueSobject qo = [SELECT Queue.Id, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName = 'Program_PM_PPM_Queue' LIMIT 1];
    
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments(submitterComments);
        req1.setObjectId(oppId);
        req1.setProcessDefinitionNameOrId('Part_List_Approval2');
        // setNextApproverIds only allows a single entry
        req1.setNextApproverIds(new List<Id>{
              qo.Queue.Id
        });
        approvalRequestList.add(req1);
        // Submit the approval request for the Opportunity
        System.debug('*** req1 ' + req1);
        Approval.ProcessResult result = Approval.process(req1);
        System.debug('*** result ' + result);
    
        Opportunity opp = [
              SELECT Id, Name, PT_Program_Mgr__r.Email, PT_Program_Mgr__r.Name,
                    PT_PL_Approval_Approver__r.Name, PT_PL_Approval_Approver_Comments__c,
                    PT_PL_Approval_Submitter__r.Name, PT_PL_Approval_Submitter_Comments__c,
                    PT_Part_List_Name__c, PT_Revised_Parts_List_Version_Trans__c, PT_Is_PPL__c, PT_Pending_Parts_List__c,
                    PT_PL_Approval_Date__c, PT_Part_List_Name_Rev__c, PT_Parts_List_Revision_Number__c, PT_PPL_Type__c,
                    PT_Part_List_Document_Generated__c, PT_PL_Batch_In_Process__c, PT_Principal_Prgrm_Mgr__c, L2I_Program_Num__r.Principal_Program_Manager__c,
            		PT_CR_Parts_List_Revision_Number__c, L2I_Program_Num__r.Name
              FROM Opportunity
              WHERE Id = :oppId
        ];
        Integer nextRevNumber = Integer.valueOf(opp.PT_Parts_List_Revision_Number__c == null ? 1 : (opp.PT_Parts_List_Revision_Number__c + 1));
        
        //W-003749
        if('CR' == opp.PT_PPL_Type__c){
            nextRevNumber = Integer.valueOf(opp.PT_CR_Parts_List_Revision_Number__c == null ? 1 : (opp.PT_CR_Parts_List_Revision_Number__c + 1));
        }
        
        String revTrans = PT_Program_Utils.revisionCharacter(Integer.valueOf(nextRevNumber));
        String revName = opp.PT_Part_List_Name__c + '_' + revTrans;
        if (opp.PT_Is_PPL__c) {
            revName = revName + ' (' + opp.PT_PPL_Type__c + ')';
            //W-003749
            if(opp.PT_PPL_Type__c == 'CR'){
                revName = 'CR-'+opp.L2I_Program_Num__r.Name+'-'+opp.PT_Parts_List_Revision_Number__c+'_'+revTrans;
            }
        }
        opp.PT_Pending_Parts_List__c = revName;
        opp.PT_Part_List_Document_Generated__c = false;
        opp.PT_PL_Document_Generation_Status__c = 'In Progress'; // Added by Khrisna for W-003113
        opp.PT_PL_Batch_In_Process__c = true;
        opp.PT_Principal_Prgrm_Mgr__c = opp.L2I_Program_Num__r.Principal_Program_Manager__c;
        update opp;
        // generate the PDF
        PageReference pdf;
        pdf = Page.PT_PartsListPDFPending;
        String fileName = revName + ' Pending.pdf';
        pdf.getParameters().put('id', opp.Id);
        pdf.getParameters().put('status', 'Pending');
        pdf.getParameters().put('nextRev', revTrans);
    
        // attach to Opportunity
        Blob bodyPDF;
        if (Test.isRunningTest()) {
            bodyPDF = blob.valueOf('Unit.Test');
        } else {
            bodyPDF = pdf.getContent();
        }
        Attachment attachmentPDF = new Attachment();
        attachmentPDF.ParentId = opp.Id;
        attachmentPDF.Name = fileName;
        attachmentPDF.Body = bodyPDF; //This creates the PDF content
        insert attachmentPDF;
    
    
        // generate the XLS ===========================================
        try {
            System.debug('*** generating xls');
            PageReference xls;
//            xls = Page.PT_PartsListXLSPending;
            xls = Page.PT_PartsListMSXLSPending;
            System.debug('*** xls ' + xls);
            String fileNameX = revName + ' PendingXLS.xls';
            xls.getParameters().put('id', opp.Id);
            xls.getParameters().put('status', 'Pending');
            xls.getParameters().put('nextRev', revTrans);
    
            Blob bodyXLS;
            // attach to Opportunity
            if (Test.isRunningTest()) {
                bodyXLS = blob.valueOf('Unit.Test');
            } else {
                bodyXLS = xls.getContent();
            }
            System.debug('*** bodyXLS ' + bodyXLS);
            Attachment attachmentXLS = new Attachment();
            attachmentXLS.ParentId = opp.Id;
            attachmentXLS.Name = fileNameX;
            attachmentXLS.Body = bodyXLS; //This creates the XLS content
            insert attachmentXLS;
            System.debug('*** attachmentXLS ' + attachmentXLS);
        } catch (Exception e) {
            System.debug('*** Error generating Pending XLS Part List document: ' + e.getMessage());
        }
        // ================================================================
    
    
        // send email to the PM user on the Opportunity
        System.debug('*** Sending email to : ' + opp.PT_Program_Mgr__c);
        EmailTemplate emailTemplate = [
              SELECT Id, Subject, Description, HtmlValue, DeveloperName,Body
              FROM EmailTemplate
              WHERE DeveloperName = 'Part_List_Submit_for_Approval'
        ];
        String templateId = emailTemplate.Id;
        String userId = opp.PT_Program_Mgr__c;
        String emailAddr = opp.PT_Program_Mgr__r.Email;
        String whatId = opp.Id;
    
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, userId, whatId);
        // attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setContentType('application/pdf');
        efa.setFileName(opp.PT_Pending_Parts_List__c + ' Pending.pdf');
//        efa.setInline(false);
        efa.body = bodyPDF;
    
        String emailSubject = email.getSubject();
        String emailHTMLBody = email.getHtmlBody();

//        email.setTargetObjectId(userId);
        List<String> sendTo = new List<String>();
        sendTo.add(emailAddr);
        email.setToAddresses(sendTo);
    
        email.setSubject(emailSubject);
        email.setHtmlBody(emailHTMLBody);
        email.saveAsActivity = false;
    
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{
              efa
        });
    
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
        
        // create a task for the PM
//        System.debug('*** Creating task for : ' + userId);
//        Task tsk = new Task();
//        tsk.Subject = 'Approval Requested for Parts List - ' + opp.PT_Part_List_Name_Rev__c;
//        tsk.WhatId = whatId;
//        tsk.OwnerId = userId;
//        tsk.Status = 'In Progress';
//        tsk.ActivityDate = Date.today();
//        insert tsk;
    }
    
    public class PLApprovalParams {
        @InvocableVariable public String oppId;
        @InvocableVariable public String comments;
    }
}