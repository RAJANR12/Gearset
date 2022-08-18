public class ife_DownloadDocumentsController{
	public ife_DownloadDocumentsController(){
	}

	@AuraEnabled
	public static List<DataWrapper> getDocuments(){
		List<DataWrapper> dataWrappers = new List<DataWrapper>();
		for (IFE_Document__c document : [SELECT Id, Document_Type__c, Name, Description__c, Revision__c, Document_Number__c, Part_Number__c, (SELECT ContentDocumentId, visibility
		                                                                                                                                      FROM ContentDocumentLinks
		                                                                                                                                      ORDER BY ContentDocument.CreatedDate DESC
		                                                                                                                                      NULLS LAST
		                                                                                                                                      LIMIT 1)
		                                 FROM IFE_Document__c WHERE Document_Type__c = 'Products']){
            DataWrapper wrapperObj = new DataWrapper();
            wrapperObj.Name = document.Name;
            wrapperObj.Revision = document.Revision__c;
            wrapperObj.DocumentNumber = document.Document_Number__c;
			for (ContentDocumentLink att : document.ContentDocumentLinks){
                wrapperObj.AttachmentId = att.ContentDocumentId;

			}
            dataWrappers.add(wrapperObj);
		}
        System.debug('dataWrappers>>>'+dataWrappers);
		return dataWrappers;
	}

	public class DataWrapper{
		@AuraEnabled
		public String Name{ get; set; }

		@AuraEnabled
		public String Revision{ get; set; }

		@AuraEnabled
		public String DocumentNumber{ get; set; }

		@AuraEnabled
		public String AttachmentId{ get; set; }

		public DataWrapper(){
			Name = '';
			Revision = '';
			DocumentNumber = '';
			AttachmentId = '';
		}
	}
}