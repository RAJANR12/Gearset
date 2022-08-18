public class ife_DocumentDetailsController{
	public String name{ get; set; }

	public String objId{ get; set; }

	public IFE_Document__c documentObj{ get; set; }

	public String downloadDocumentLink{ get; set; }

	public ife_DocumentDetailsController(){
		objId = ApexPages.currentPage().getParameters().get('id');
		documentObj = new IFE_Document__c();
		downloadDocumentLink = '';
	}

	public void getData(){
		documentObj = [SELECT Id, Description__c, Revision__c, Work_Statement__c, Document_Number__c, Folder_Number__c, Folder_Version__c, FIle_Type__c, File_Name__c
		               FROM IFE_Document__c
		               WHERE Id = :objId
		               LIMIT 1];
		ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'AgileDocument'
		                                          LIMIT 1];
		downloadDocumentLink = integrationMdtObj.URL__c + 'agileDocument/' + documentObj.Folder_Number__c + ':' + documentObj.Folder_Version__c + ':' + documentObj.File_Name__c;
	}

	@AuraEnabled
	public static List<ContentDocument> getDownloadDocument(String documentId){
		System.debug('***documentId====' + documentId);
		List<ContentDocument> ContentDocumentList = new List<ContentDocument>();
		for (ContentDocumentLink contentDocumentLink : [SELECT ContentDocumentId, ContentDocument.Title
		                                                FROM ContentDocumentLink
		                                                WHERE LinkedEntityId = :documentId]){
			System.debug('contentDocumentLink.ContentDocument---- ' + contentDocumentLink.ContentDocument);
			ContentDocumentList.add(contentDocumentLink.ContentDocument);
		}
		System.debug('ContentDocumentList>>>' + ContentDocumentList);
		return ContentDocumentList;
	}

	@AuraEnabled
	public static String urlDownloadDocument(String folderNumber, String folderVersion, String fileName){
		ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'AgileDocument'
		                                          LIMIT 1];
		String url = integrationMdtObj.URL__c + 'agileDocument/' + folderNumber + ':' + folderVersion + ':' + fileName;
		return url;
	}
}