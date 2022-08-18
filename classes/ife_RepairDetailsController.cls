public with sharing class ife_RepairDetailsController{
	public ife_RepairDetailsController(){
	}

	@AuraEnabled
	public static String getRepairDetails(String SRNumber){

		ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'RepairDetails'
		                                          LIMIT 1];

		String url = integrationMdtObj.URL__c + 'repairSRDetail/' + SRNumber + '?client_id=' + integrationMdtObj.Client_Id__c + '&client_secret=' + integrationMdtObj.Client_Secret__c;
		System.debug('url RepairDetails---- ' + url);
		try{
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(url);
			request.setMethod('GET');
			request.setTimeout(120000);
			HttpResponse response = http.send(request);

			System.debug('REsult---------' + response.getBody());
			if (response.getStatusCode() == 200){
				System.debug('response.getBody()---------' + response.getBody());
				return response.getBody();
			} else{
				System.debug('response.getStatus()---------' + response.getStatus());
				Ife_ErrorLog.createErrorLog('ife_RepairDetailsController', response.getStatus());
				return response.getStatus();
			}
		} catch (Exception e){
			System.debug('e---------' + e);
			Ife_ErrorLog.createErrorLog('ife_RepairDetailsController', e.getMessage());
			return e.getMessage();
		}
	}
}