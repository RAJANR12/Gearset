@isTest
public class ife_DocumentDetailsControllerTest {
    @isTest public static void getDownloadDocumentTest(){
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData = Blob.valueOf('Test Content');         
        insert cv; 
        
        ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        system.debug('@@@testContent'+testContent);
    	        
        IFE_Document__c ifeDocument = new IFE_Document__c();
        ifeDocument.Description__c = 'Testring--';
        ifeDocument.Revision__c = 'Test';
        ifeDocument.Work_Statement__c = 'dfuyfasuldyFDxbzCsduYfdkdjdgoeudf;odufcvsdygsdfpg';
        ifeDocument.Document_Number__c = 'Test';
        ifeDocument.FIle_Type__c = 'pdf' ;
        ifeDocument.File_Name__c = 'Test';
        insert ifeDocument;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = ifeDocument.Id;
        contentlink.ShareType = 'I'; 
        contentlink.ContentDocumentId = testContent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
		insert contentlink;
    	
        ApexPages.currentPage().getParameters().put('id', String.valueOf(ifeDocument.Id));
        ife_DocumentDetailsController ifeDoc = new ife_DocumentDetailsController();
        ifeDoc.getData();
        
        Test.startTest();
       List<ContentDocument> contentTitle =  ife_DocumentDetailsController.getDownloadDocument(ifeDocument.Id);
        System.assertEquals('test content trigger', contentTitle[0].title );
        Test.stopTest();
    } 
      
}