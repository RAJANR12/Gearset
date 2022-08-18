public with sharing class DocumentHelper {       
    
    @AuraEnabled
    public static String getContentDetails(String recordId) {
        Set<Id> contentDocumentIdSet = new Set<Id>();
        List<ContentVersionWrapper> cvWrapperList = new List<ContentVersionWrapper>();
        String totalContentVersion ;
        
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
        
        ProcessInstance processInstanceRecord = [SELECT id, 
                                                 CompletedDate,
                                                 CreatedDate,
                                                 Status,
                                                 TargetObjectId 
                                                 FROM   ProcessInstance 
                                                 WHERE  TargetObjectId = :recordId 
                                                 ORDER BY CreatedDate DESC 
                                                 LIMiT 1];
        system.debug('ALL ID Rejected : '+contentDocumentIdSet);
        system.debug('current record : '+processInstanceRecord);
        List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
        
        if(processInstanceRecord.Status == 'Pending'){
            system.debug('pending');
            contentDocumentList = [SELECT ContentDocumentId,
                                   ContentDocument.CreatedDate, 
                                   LinkedEntityId 
                                   FROM   ContentDocumentLink 
                                   WHERE  LinkedEntityId =: recordId AND ContentDocument.CreatedDate < :processInstanceRecord.CreatedDate AND ContentDocumentId NOT IN : contentDocumentIdSet];
            
            system.debug('contentDocumentList :'+contentDocumentList);
        }else  if(processInstanceRecord.Status == 'Rejected'){
            system.debug('rejected');
            contentDocumentList = [SELECT  ContentDocumentId,
                                   ContentDocument.CreatedDate, 
                                   LinkedEntityId 
                                   FROM    ContentDocumentLink 
                                   WHERE   LinkedEntityId =: recordId AND ContentDocument.CreatedDate < :processInstanceRecord.CreatedDate AND ContentDocumentId NOT IN : contentDocumentIdSet];
        }else{
            system.debug('Approved');
            contentDocumentList = [SELECT  ContentDocumentId,
                                   ContentDocument.CreatedDate, 
                                   LinkedEntityId 
                                   FROM    ContentDocumentLink 
                                   WHERE   LinkedEntityId =: recordId AND ContentDocumentId NOT IN : contentDocumentIdSet];
        }
        
        
        system.debug('content :'+contentDocumentList);
        Set<Id> contentDocumentId = new Set<Id>();
        
        for(ContentDocumentLink cdl : contentDocumentList){
            contentDocumentId.add(cdl.ContentDocumentId);
        }
        
        List<ContentVersion> contentVersionList = [SELECT Id, 
                                                   //VersionData, //removed by Jan Geronga for W-004207
                                                   FileType, 
                                                   Title, 
                                                   FileExtension,
                                                   ContentDocument.CreatedBy.Name, 
                                                   ContentDocument.ContentSize,
                                                   CreatedDate, 
                                                   ContentDocumentId,
                                                   ContentDocument.FileType
                                                   FROM  ContentVersion 
                                                   WHERE ContentDocumentId IN : contentDocumentId];
        if(!contentVersionList.isEmpty()){
            for(ContentVersion cvRec: contentVersionList){
                ContentVersionWrapper cvWrapper = new ContentVersionWrapper(cvRec.ContentDocumentId, cvRec.Id, 
                                                                            cvRec.ContentDocument.CreatedBy.Name, cvRec.ContentDocument.ContentSize,
                                                                            cvRec.FileExtension, cvRec.CreatedDate, cvRec.Title, cvRec.ContentDocument.FileType);
                cvWrapperList.add(cvWrapper);
            }                
            
            totalContentVersion = JSON.serialize(cvWrapperList);
        }
        
        //return JSON.serialize(contentVersionList);
        return totalContentVersion;
    }
    
    @AuraEnabled
    public static void deleteContentDocument(String recordId) {
        Database.delete(recordId);
    }
    
    static List<ContentVersion> contentVersionList = new List<ContentVersion>();
    
    @AuraEnabled
    public static String calledAllFiles(String recordId) {
        
        String result = recordId.substring(0,3);
        String totalContentVersion ;
        List<ContentVersionWrapper> cvWrapperList = new List<ContentVersionWrapper>();
        
        if(result == '04i'){
            
            ProcessInstanceWorkitem currentRecord =  [SELECT  id,
                                                      CreatedDate,
                                                      ProcessInstanceId,
                                                      ProcessInstance.CreatedDate,
                                                      ProcessInstance.TargetObjectId,
                                                      ProcessInstance.Status
                                                      FROM    ProcessInstanceWorkitem 
                                                      WHERE   id= :recordId];
            
            if(currentRecord.ProcessInstance.Status != 'Rejected'){                         
                
                List<ContentDocumentLink> contentDocumentList = [SELECT  ContentDocumentId,
                                                                 ContentDocument.CreatedDate, 
                                                                 LinkedEntityId 
                                                                 FROM    ContentDocumentLink 
                                                                 WHERE   LinkedEntityId =: currentRecord.ProcessInstance.TargetObjectId AND ContentDocument.CreatedDate > :currentRecord.ProcessInstance.CreatedDate];
                Set<Id> contentDocumentId = new Set<Id>();
                
                for(ContentDocumentLink cdl : contentDocumentList){
                    // system.debug(cdl.id);
                    contentDocumentId.add(cdl.ContentDocumentId);
                }
                
                List<ContentVersion> contentVersionList = [SELECT  Id, 
                                                           //VersionData, //removed by Jan Geronga for W-004207
                                                           FileType, 
                                                           Title, 
                                                           FileExtension,
                                                           ContentDocument.CreatedBy.Name, 
                                                           ContentDocument.ContentSize,
                                                           CreatedDate, 
                                                           ContentDocumentId, 
                                                           ContentDocument.FileType
                                                           FROM    ContentVersion 
                                                           WHERE   ContentDocumentId IN : contentDocumentId];
                
                //totalContentVersion = JSON.serialize(contentVersionList);
                if(!contentVersionList.isEmpty()){
                    for(ContentVersion cvRec: contentVersionList){
                        ContentVersionWrapper cvWrapper = new ContentVersionWrapper(cvRec.ContentDocumentId, cvRec.Id, 
                                                                                    cvRec.ContentDocument.CreatedBy.Name, cvRec.ContentDocument.ContentSize,
                                                                                    cvRec.FileExtension, cvRec.CreatedDate, cvRec.Title, cvRec.ContentDocument.FileType);
                        cvWrapperList.add(cvWrapper);
                    }                
                    
                    totalContentVersion = JSON.serialize(cvWrapperList);
                }
            }
            
        }else if(result == '04h'){
            
            ProcessInstanceStep currentRecord =  [SELECT  id,
                                                  CreatedDate,
                                                  ProcessInstanceId,
                                                  ProcessInstance.CreatedDate,
                                                  ProcessInstance.CompletedDate,
                                                  ProcessInstance.TargetObjectId,
                                                  ProcessInstance.Status
                                                  FROM    ProcessInstanceStep 
                                                  WHERE   id= :recordId];
            
            List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
            
            if(currentRecord.ProcessInstance.CompletedDate == null){
                
                contentDocumentList = [SELECT ContentDocumentId,
                                       ContentDocument.CreatedDate, 
                                       LinkedEntityId 
                                       FROM   ContentDocumentLink 
                                       WHERE  LinkedEntityId =: currentRecord.ProcessInstance.TargetObjectId AND ContentDocument.CreatedDate > :currentRecord.ProcessInstance.CreatedDate];
                
            }else if(currentRecord.ProcessInstance.CompletedDate != NULL && currentRecord.ProcessInstance.Status != 'Rejected') {
                
                contentDocumentList = [SELECT  ContentDocumentId,
                                       ContentDocument.CreatedDate, 
                                       LinkedEntityId 
                                       FROM    ContentDocumentLink 
                                       WHERE   LinkedEntityId =: currentRecord.ProcessInstance.TargetObjectId AND ContentDocument.CreatedDate > :currentRecord.ProcessInstance.CreatedDate AND ContentDocument.CreatedDate <= :currentRecord.ProcessInstance.CompletedDate ];
                
            }
            
            Set<Id> contentDocumentId = new Set<Id>();
            
            for(ContentDocumentLink cdl : contentDocumentList){
                
                contentDocumentId.add(cdl.ContentDocumentId);                    
            }
            
            List<ContentVersion> contentVersionList = [SELECT  Id, 
                                                       //VersionData, //removed by Jan Geronga for W-004207
                                                       FileType,
                                                       Title,
                                                       FileExtension,
                                                       ContentDocument.CreatedBy.Name,
                                                       ContentDocument.ContentSize,
                                                       CreatedDate, 
                                                       ContentDocumentId,
                                                       ContentDocument.FileType
                                                       FROM    ContentVersion 
                                                       WHERE   ContentDocumentId IN : contentDocumentId];
            
            if(!contentVersionList.isEmpty()){
                for(ContentVersion cvRec: contentVersionList){
                    ContentVersionWrapper cvWrapper = new ContentVersionWrapper(cvRec.ContentDocumentId, cvRec.Id, 
                                                                                cvRec.ContentDocument.CreatedBy.Name, cvRec.ContentDocument.ContentSize,
                                                                                cvRec.FileExtension, cvRec.CreatedDate, cvRec.Title, cvRec.ContentDocument.FileType);
                    cvWrapperList.add(cvWrapper);
                }                
                
                totalContentVersion = JSON.serialize(cvWrapperList);
            }            
            
            //totalContentVersion = JSON.serialize(contentVersionList);
            
        }
        
        return totalContentVersion;
    }
    
    
    
    @AuraEnabled
    public static void rejectApprovalProcess(String workItemId, String rejectComments) {
        
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest req2 =   new Approval.ProcessWorkitemRequest();
        req2.setComments(rejectComments);
        req2.setAction('Reject');
        //req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(workItemId);
        
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        
        System.assertEquals(
            'Rejected', result2.getInstanceStatus(), 
            'Instance Status'+result2.getInstanceStatus());
    }
    
    @AuraEnabled
    public static void approveApprovalProcess(String workItemId, String approveComments) {
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest req2 =   new Approval.ProcessWorkitemRequest();
        req2.setComments(approveComments);
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(workItemId);
        
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        System.debug('approve status'+result2.getInstanceStatus());
        // System.assertEquals(
        //     'Approved', result2.getInstanceStatus(), 
        //    'Instance Status'+result2.getInstanceStatus());
    }
    
    @AuraEnabled
    public static boolean sendEmailWithQuestion(String submitId, String allQuestions, String actualSubmitter) {
        
        User data = [SELECT  Id , 
                     Name, 
                     Email  
                     FROM User 
                     WHERE id= :submitId];
        System.debug('actualsubmitter'+data.Email);
        User submitterdata = [SELECT  Id , 
                              Name, 
                              Email  
                              FROM User 
                              WHERE Id= :actualSubmitter];
        
        List<String> questionByLine     = allQuestions.split('\\?');
        
        String wholeQuestionlinebyline = 'Hello '+data.Name+', <br/><br/><b>Approval submitter</b> :- '+submitterdata.Name+'<br/><br/><b>Previous Approver</b> :- '+data.Name+' <br/><br/><b>Questions</b> :- <br/>';
        for(String s: questionByLine){
            system.debug('all questions'+s);
            wholeQuestionlinebyline += s +'<br/>';
        }
        System.debug('actualsubmitter'+actualSubmitter);
        System.debug('questionByLine'+questionByLine);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {data.Email.remove('.invalid')};
            message.optOutPolicy = 'FILTER';
        message.subject = 'Testing mail :Question on MROD approval';
        message.setHtmlBody(wholeQuestionlinebyline);
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) 
        {
            System.debug('The email was sent successfully.');
        } else 
        {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
        
        return results[0].success;
    }
    
    public class ContentVersionWrapper {
        String ContentDocumentID = '';
        String FileID = '';
        String CreatedBy = '';
        String FileSize = '';
        String FileExtension = '';
        String CreatedDate = '';
        String FileTitle = '';
        String FileType = '';
        
        public ContentVersionWrapper(){}
        
        public ContentVersionWrapper(Id cdId, Id fId, String createdBy, Integer fSize, String fExt, Datetime cDate, String fTitle, String fType){
            ContentDocumentID = cdId+'';
            FileID = fId+'';
            this.CreatedBy = createdBy;
            FileSize = fSize+'';
            FileExtension = fExt;
            CreatedDate = cDate+'';
            FileTitle = fTitle;
            Filetype = ftype;
        }
    }
    
}