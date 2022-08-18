@isTest
public class DocumentHelperTest {
    
    
    @isTest static Approval.ProcessResult testMethod1() {
        
        List<User> userlist = [SELECT Id, name, Profile.name FROM User WHERE Profile.name='System Administrator' and IsActive = true limit 2];
        User user1 = userlist[0];
        User user2= userlist[1];
        PT_Program__c objprogram = new PT_Program__c(Name = 'Test Program', 
                                                     Program_Method__c = 'PMO',
                                                     Program_Number__c ='Test Program',
                                                     Program_Manager__c = user1.id,
                                                     Principal_Program_Manager__c = user1.id,
                                                     PMO_Regional_Director__c = user1.id);
        insert objProgram;
        
        
        L2I_DSH__c objDS = new L2I_DSH__c();
        insert objDs;
        
        L2I_DSL__c objAdd = new L2I_DSL__c(PT_Program__c = objprogram.id, Delivery_Schedule_Header__c = objDS.id);
        insert objAdd;
        
        date mydate = date.parse('05/11/2020');
        PT_Install_Location__c objLocation = new PT_Install_Location__c(ShipSet__c = objAdd.id , Pending_MROD__c = mydate);
        insert objLocation;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval from test');
        req1.setObjectId(objprogram.id);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(user2.Id);
        //req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Program_MROD_Approval_v3');
        req1.setSkipEntryCriteria(true);      
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);         
        
        System.assert(result.isSuccess());
        
        System.assertEquals(
            'Pending', result.getInstanceStatus(), 
            'Instance Status'+result.getInstanceStatus()); 
        
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(result.instanceid, yesterday);  
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = objprogram.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        System.assertEquals(contentlink.ContentDocumentId,contentVersion_2.ContentDocumentId );
        
        Datetime man = Datetime.now();
        Test.setCreatedDate(contentVersion_2.Id, man);  
        
        
        return result;
    }
    
    @isTest static void testMethodReject(){
        
        Approval.ProcessResult result = testMethod1();
        
        System.assertEquals(
            'Pending', result.getInstanceStatus(), 
            'Instance Status'+result.getInstanceStatus()); 
        
        system.debug('work items in pending'+result.getNewWorkitemIds());              
        
        PT_Program__c objprogram2 = [SELECt id from PT_Program__c where name = 'Test Program']; 
        
        list<ContentDocumentLink> contentlink = [select id, contentdocumentid,ContentDocument.CreatedDate, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :objprogram2.id ];
        
        System.debug('contentlink'+contentlink);   
        String contentVersionData = DocumentHelper.getContentDetails(objprogram2.id) == NULL ? '': DocumentHelper.getContentDetails(objprogram2.id);
        System.debug('contentVersionData --- '+contentVersionData); 
        system.assertEquals( false , contentVersionData.contains(contentlink[0].contentdocumentid) );
        
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        String contentVersionDataOfWorkItem = DocumentHelper.calledAllFiles(newWorkItemIds.get(0));
        System.debug('cintent version data'+contentVersionDataOfWorkItem);
        System.assertEquals( True , contentVersionDataOfWorkItem.contains(contentlink[0].contentdocumentid) );      
        
        
        System.debug('work items in reject'+result.getNewWorkitemIds());
        
        DocumentHelper.rejectApprovalProcess(newWorkItemIds.get(0),'rejecting request');
        
        // Instantiate the new ProcessWorkitemRequest object and populate it
        /*Approval.ProcessWorkitemRequest req2 =   new Approval.ProcessWorkitemRequest();
        req2.setComments('rejecting request.');
        req2.setAction('Reject');
        //req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        
        System.assertEquals(
        'Rejected', result2.getInstanceStatus(), 
        'Instance Status'+result2.getInstanceStatus());*/
        
        //PT_Program__c objprogram3= [SELECt id from PT_Program__c where name = 'Test Program']; 
        
        //list<ContentDocumentLink> contentlink2= [select id, contentdocumentid, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :objprogram2.id limit 1 ];
        
        
        String contentVersionData2 = DocumentHelper.getContentDetails(objprogram2.id) == NULL ? '': DocumentHelper.getContentDetails(objprogram2.id);
        System.assertEquals( false , contentVersionData2.contains(contentlink[0].contentdocumentid) );
        
        List<ProcessInstanceStep> currentRecord =  [SELECT  id,
                                                    CreatedDate,
                                                    ProcessInstanceId,
                                                    ProcessInstance.CreatedDate,
                                                    ProcessInstance.CompletedDate,
                                                    ProcessInstance.TargetObjectId 
                                                    FROM    ProcessInstanceStep 
                                                    WHERE   ProcessInstanceId = :result.getInstanceId() 
                                                    AND   ProcessInstance.TargetObjectId = :objprogram2.Id];
        
        system.debug('curent in test class :'+currentRecord);
        
        Test.startTest();
        String contentVersionDataOfProcessInstance = DocumentHelper.calledAllFiles(currentRecord[0].id);
        // System.assertEquals( True , contentVersionDataOfProcessInstance.contains(contentlink[0].contentdocumentid) ); 
        System.assertEquals( True , contentVersionDataOfProcessInstance == null); 
        Test.stopTest(); 
        
        
        // DocumentHelper.deleteContentDocument(contentlink[0].contentdocumentid);   
        // List<ContentDocumentLink> obj = [select id, contentdocumentid, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :objprogram2.id limit 1 ];
        
        // system.assertEquals(0,obj.size());
        
        
    }

    @isTest static void testMethodReject2(){
        
        Approval.ProcessResult result = testMethod1();
        
        System.assertEquals(
            'Pending', result.getInstanceStatus(), 
            'Instance Status'+result.getInstanceStatus()); 
        
        system.debug('work items in pending'+result.getNewWorkitemIds());              
        
        PT_Program__c objprogram2 = [SELECt id from PT_Program__c where name = 'Test Program']; 
        
        list<ContentDocumentLink> contentlink = [select id, contentdocumentid,ContentDocument.CreatedDate, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :objprogram2.id ];
        
        System.debug('contentlink'+contentlink);   
        String contentVersionData = DocumentHelper.getContentDetails(objprogram2.id) == NULL ? '': DocumentHelper.getContentDetails(objprogram2.id);
        System.debug('contentVersionData --- '+contentVersionData); 
        system.assertEquals( false , contentVersionData.contains(contentlink[0].contentdocumentid) );
        
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        String contentVersionDataOfWorkItem = DocumentHelper.calledAllFiles(newWorkItemIds.get(0));
        System.debug('cintent version data'+contentVersionDataOfWorkItem);
        System.assertEquals( True , contentVersionDataOfWorkItem.contains(contentlink[0].contentdocumentid) );      
        
        
        System.debug('work items in reject'+result.getNewWorkitemIds());
        
        // DocumentHelper.rejectApprovalProcess(newWorkItemIds.get(0),'rejecting request');
        
        // Instantiate the new ProcessWorkitemRequest object and populate it
        /*Approval.ProcessWorkitemRequest req2 =   new Approval.ProcessWorkitemRequest();
        req2.setComments('rejecting request.');
        req2.setAction('Reject');
        //req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        
        System.assertEquals(
        'Rejected', result2.getInstanceStatus(), 
        'Instance Status'+result2.getInstanceStatus());*/
        
        //PT_Program__c objprogram3= [SELECt id from PT_Program__c where name = 'Test Program']; 
        
        //list<ContentDocumentLink> contentlink2= [select id, contentdocumentid, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :objprogram2.id limit 1 ];
        
        
        String contentVersionData2 = DocumentHelper.getContentDetails(objprogram2.id) == NULL ? '': DocumentHelper.getContentDetails(objprogram2.id);
        System.assertEquals( false , contentVersionData2.contains(contentlink[0].contentdocumentid) );
        
        List<ProcessInstanceStep> currentRecord =  [SELECT  id,
                                                    CreatedDate,
                                                    ProcessInstanceId,
                                                    ProcessInstance.CreatedDate,
                                                    ProcessInstance.CompletedDate,
                                                    ProcessInstance.TargetObjectId 
                                                    FROM    ProcessInstanceStep 
                                                    WHERE   ProcessInstanceId = :result.getInstanceId() 
                                                    AND   ProcessInstance.TargetObjectId = :objprogram2.Id];
        
        system.debug('curent in test class :'+currentRecord);
        
        Test.startTest();
        String contentVersionDataOfProcessInstance = DocumentHelper.calledAllFiles(currentRecord[0].id);
        System.assertEquals( True , contentVersionDataOfProcessInstance.contains(contentlink[0].contentdocumentid) ); 
        // System.assertEquals( True , contentVersionDataOfProcessInstance == null); 
        Test.stopTest(); 
        
        
        DocumentHelper.deleteContentDocument(contentlink[0].contentdocumentid);   
        List<ContentDocumentLink> obj = [select id, contentdocumentid, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :objprogram2.id limit 1 ];
        
        system.assertEquals(0,obj.size());
        
        
    }
    
    /*@isTest static void testMethodApprove(){

    Approval.ProcessResult result = testMethod1();       
    
    
    pt_Program__c objprogram2 = [SELECt id,Program_Manager__c,Principal_Program_Manager__c from PT_Program__c where name = 'Test Program'];
    
    
    List<Id> newWorkItemIds = result.getNewWorkitemIds();
    
    system.debug('work items in approve'+result.getNewWorkitemIds());
    
    // Instantiate the new ProcessWorkitemRequest object and populate it
    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
    req2.setComments('Approving request.');
    req2.setAction('Approve');
    //q2.setNextApproverIds(objprogram2.Principal_Program_Manager__c);
    
    // Use the ID from the newly created item to specify the item to be worked
    req2.setWorkitemId(newWorkItemIds.get(0));
    
    system.debug('req2'+req2);
    // Submit the request for approval
    Approval.ProcessResult result2 =  Approval.process(req2);
    
    system.debug('result2'+result2);
    system.debug('status of'+result2.getInstanceStatus());
    // Verify the results
    System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
    
    System.assertEquals(
    'Approved', result2.getInstanceStatus(), 
    'Instance Status'+result2.getInstanceStatus());
    
    
    list<ContentDocumentLink> contentlink2= [select id, contentdocumentid, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :objprogram2.id limit 1 ];
    
    
    String contentVersionData2= DocumentHelper.getContentDetails(objprogram2.id);
    system.assertEquals( true , contentVersionData2.contains(contentlink2[0].contentdocumentid) );
    
    
    }*/
    @isTest static void testSendEmail(){
        User user1 = [SELECT Id, name, Profile.name FROM User WHERE Profile.name='System Administrator' and IsActive = true limit 1];
        boolean result4 = DocumentHelper.sendEmailWithQuestion(user1.Id,'what is shipset value?', user1.Id);
        
        System.assertEquals( True ,result4 );
    }
    
    
}