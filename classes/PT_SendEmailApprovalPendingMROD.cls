global class PT_SendEmailApprovalPendingMROD {
    
    @InvocableMethod(label='Send Approval Email Notification')
    public static void getProgramRecord(List<Id> progRecIds){
        
        PT_Program__c progRec = [SELECT Id,MROD_Approval_Step__c, MROD_Approval_Status__c, Program_Number__c, Program_Manager__c, Program_Manager__r.Email, Principal_Program_Manager__r.Email,
                                 PMO_Regional_Director__r.Email
                                 FROM PT_Program__c  WHERE Id IN: progRecIds LIMIT 1];
        sendEmailApproval(progRec, true);
    }
    
    @future(callout=true)
    public static void sendApprovalEmail(List<Id> progRecIds){
        
        PT_Program__c progRec = [SELECT Id,MROD_Approval_Step__c, MROD_Approval_Status__c, Program_Number__c, Program_Manager__c, Program_Manager__r.Email, Principal_Program_Manager__r.Email,
                                 PMO_Regional_Director__r.Email
                                 FROM PT_Program__c  WHERE Id IN: progRecIds LIMIT 1];
        sendEmailApproval(progRec, false);
    }
    
    public static void sendEmailApproval(PT_Program__c progRec, Boolean flowSource){
        
        
        try {
            // generate the XLS ===========================================
            
            if(flowSource){
                String nowt = System.now() + '';            
                nowt = nowt.remove(':');
                nowt = nowt.remove('-');
                nowt = nowt.deleteWhitespace();
                
                System.debug('*** generating xls');
                PageReference xls;
                xls = Page.PT_PendingMRODChanges;
                System.debug('*** xls ' + xls);
                String fileNameX = 'DRAFT_'+progRec.Program_Number__c+'_'+'Rev'+'_'+progRec.MROD_Approval_Status__c +'_'+nowt +'.xls';
                xls.getParameters().put('id', progRec.Id);
                
                Blob bodyXLS;
                // attach to Opportunity
                if (Test.isRunningTest()) {
                    bodyXLS = blob.valueOf('Unit.Test');
                } else {
                    bodyXLS = xls.getContent();
                }
                /*System.debug('*** bodyXLS ' + bodyXLS);
                Attachment attachmentXLS = new Attachment();
                attachmentXLS.ParentId = progRec.Id;
                attachmentXLS.Name = fileNameX;
                attachmentXLS.Body = bodyXLS; //This creates the XLS content
                insert attachmentXLS;
                System.debug('*** attachmentXLS ' + attachmentXLS);*/
                
                ContentVersion contentVersion_1 = new ContentVersion(
                    Title= fileNameX, 
                    PathOnClient = fileNameX,
                    VersionData = bodyXLS, 
                    origin = 'H'
                );
                insert contentVersion_1;
                
                ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                                   FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
                
                ContentDocumentLink contentlink = new ContentDocumentLink();
                contentlink.LinkedEntityId = progRec.Id;
                contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
                contentlink.ShareType = 'V';
                insert contentlink;                                
                
            }
            
            //query the email template
            EmailTemplate emailTemplate = [
                SELECT Id, Subject, Description, HtmlValue, DeveloperName,Body
                FROM EmailTemplate
                WHERE DeveloperName = 'Prgm_MROD_Rev_Submit_for_Approval_VFPage'
            ];
            
            String templateId = emailTemplate.Id;
            String userId = progRec.Program_Manager__c;
            String emailAddr = progRec.Program_Manager__r.Email;
            String whatId = progRec.Id;
            //
            if(progRec.MROD_Approval_Step__c == 'PM Approval'){
                emailAddr = progRec.Principal_Program_Manager__r.Email;
            }
            else if(progRec.MROD_Approval_Step__c == 'PPM Approval'){
                emailAddr = progRec.PMO_Regional_Director__r.Email;
            }
            
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, userId, whatId);
            
            /*Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setContentType('application/vnd.ms-excel');
            efa.setFileName(fileNameX);
            efa.body = bodyXLS;*/
            
            String emailSubject = email.getSubject();
            String emailHTMLBody = email.getHtmlBody();
            
            //        email.setTargetObjectId(userId);
            List<String> sendTo = new List<String>();
            sendTo.add(emailAddr);
            email.setToAddresses(sendTo);
            
            email.setSubject(emailSubject);
            email.setHtmlBody(emailHTMLBody);
            email.saveAsActivity = false;
            
            Set<Messaging.EmailFileAttachment> fileSet = attachedUploadedFile(progRec.Id);
            List<Messaging.EmailFileAttachment> files = new List<Messaging.EmailFileAttachment>();
            if(!fileSet.isEmpty()){
                files.addAll(fileSet);
            }
            //files.add(efa);
            
            email.setFileAttachments(files);
            
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
        } catch (Exception e) {
            System.debug('*** Error generating Pending XLS Part List document: ' + e.getMessage());
        }
        // ================================================================
    }
    
    private static Set<Messaging.EmailFileAttachment> attachedUploadedFile(Id prgRecId){
        Set<Messaging.EmailFileAttachment> files = new Set<Messaging.EmailFileAttachment>();
        Set<Id> contentDocumentIdSet = getRejectedFile(prgRecId);
        
         ProcessInstance processInstanceRecord = [SELECT Id, 
                                                        CompletedDate,
                                                        CreatedDate,
                                                        Status,
                                                        TargetObjectId 
                                                 FROM   ProcessInstance 
                                                 WHERE  TargetObjectId = :prgRecId 
                                                 ORDER BY CreatedDate DESC 
                                                 LIMIT 1];
        
        if(processInstanceRecord != NULL){
            if(processInstanceRecord.Status == 'Pending'){
                Set<Id> contentDocumentSet = new Set<Id>(); 
                for(ContentDocumentLink doc : [SELECT ContentDocumentId, ContentDocument.Title, Id, LinkedEntityId, ShareType FROM ContentDocumentLink 
                                               WHERE LinkedEntityId =: prgRecId AND ContentDocument.CreatedDate > :processInstanceRecord.CreatedDate AND ContentDocumentId NOT IN : contentDocumentIdSet] )  {
                    contentDocumentSet.add(doc.ContentDocumentId);
                }
                
                if(!contentDocumentSet.isEmpty()){
                    List<ContentVersion> contentVersionFile = [SELECT VersionData, Title, FileType FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentSet AND IsLatest = true];
                    
                    //For each content version file get the file name, extension, version and add into the attachment list called 'attach'
                    for(ContentVersion file : contentVersionFile){
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        
                        List<String> parts = file.title.split('\\.');
                        String fileExt = '';
                        if(!parts.isEmpty() && parts.size() > 1){
                            fileExt = parts[parts.size()-1];
                        }                         
                        
                        if(String.isBlank(fileExt)){
                            String ext = '';
                            
                            System.debug('file.FileType >>> ' + file.FileType);
                            ext = file.FileType == 'EXCEL'? 'xls' : ext;
                            ext = file.FileType == 'WORD_X'? 'docx' : ext;
                            ext = file.FileType == 'PDF'? 'pdf' : ext;
                            ext = ext == '' ? file.FileType : ext;
                            
                            efa.setFileName(file.title+'.'+ext);
                            efa.setBody(file.VersionData);                            
                        } else {
                            efa.setFileName(file.title);
                            efa.setBody(file.VersionData);
                        }                        
                                                                        
                        files.add(efa);
                    }  
                }
                
            }            
        }
        
        return files;
    }
    
    private static Set<Id> getRejectedFile(Id recordId){
        Set<Id> contentDocumentIdSet = new Set<Id>();
        
        List<ProcessInstance> rejectedProcessInstanceList = [SELECT id, 
                                                       CompletedDate,
                                                       CreatedDate,
                                                       Status,
                                                       TargetObjectId 
                                                FROM   ProcessInstance 
                                                WHERE  TargetObjectId = :recordId AND Status ='Rejected'];

        if(!rejectedProcessInstanceList.isEmpty()) {
            
        
        List<ContentDocumentLink> rejectedContentDocumentList = new List<ContentDocumentLink>();
        for(ProcessInstance objProc : rejectedProcessInstanceList){                
            
                    rejectedContentDocumentList.addAll([SELECT ContentDocumentId,
                                                               ContentDocument.CreatedDate, 
                                                               LinkedEntityId 
                                                        FROM   ContentDocumentLink 
                                                        WHERE  LinkedEntityId =:recordId AND ContentDocument.CreatedDate < :objProc.CompletedDate AND ContentDocument.CreatedDate > :objProc.CreatedDate ]);
        
                //system.debug('ALL rejectedContentDocumentList : '+rejectedContentDocumentList);     
        }
            for(ContentDocumentLink proInObject : rejectedContentDocumentList){
                        
                    contentDocumentIdSet.add(proInObject.ContentDocumentId);
            }
            
        }//end if
        
        return contentDocumentIdSet;
    }
}