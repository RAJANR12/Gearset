@isTest
public class ife_DownloadDocumentsControllerTest {
    @isTest
    public static void getDocumentsTest(){
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData = Blob.valueOf('Test Content');         
        insert cv; 
        
        ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        system.debug('@@@testContent'+testContent);
    	        
        String strRecordTypeId = [Select Id From RecordType Where Name = 'Agile Document'].Id;
            
        IFE_Document__c ifeDocument = new IFE_Document__c();
        ifeDocument.Description__c = 'Testring--';
        ifeDocument.Revision__c = 'Test';
        ifeDocument.File_Name__c = 'Test';
        ifeDocument.RecordTypeId = strRecordTypeId;
        ifeDocument.Document_Type__c = 'Products';
        insert ifeDocument;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = ifeDocument.Id;
        contentlink.ShareType = 'I'; 
        contentlink.ContentDocumentId = testContent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
		insert contentlink;
        
        ife_DownloadDocumentsController downloadDocObj = new ife_DownloadDocumentsController();
        List<ife_DownloadDocumentsController.DataWrapper> dw = new List<ife_DownloadDocumentsController.DataWrapper>();
        
       dw =  ife_DownloadDocumentsController.getDocuments();
        System.assertEquals('Test', dw[0].Revision);
       
    }
}