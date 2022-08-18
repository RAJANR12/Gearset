public class ife_GCS_DocumentsController{
	@AuraEnabled
	public static String getGCS_Document(String airFrame){
		ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'Gcs_Document'
		                                          LIMIT 1];
		try{
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(integrationMdtObj.URL__c + 'gcsDocument?airFrame=' + airFrame);
			request.setMethod('GET');
			request.setHeader('client_id', integrationMdtObj.Client_Id__c);
			request.setHeader('client_secret', integrationMdtObj.Client_Secret__c);
			request.setHeader('Accept', '*/*');
			request.setHeader('Connection', 'keep-alive');
			request.setHeader('Content-Type', 'application/json');
			request.setTimeout(120000);
			HttpResponse response = http.send(request);
			System.debug('getBody ==== ' + response.getBody());
			if (response.getStatusCode() == 200){
				return response.getBody();
			} else{
				System.debug('response.getStatus()---------' + response.getStatus());
				Ife_ErrorLog.createErrorLog('ife_GCS_DocumentsController', response.getStatus());
				return response.getStatus();
			}

		} catch (Exception e){
			System.debug('e---------' + e);
			Ife_ErrorLog.createErrorLog('ife_GCS_DocumentsController', e.getMessage());
			return e.getMessage();
		}
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