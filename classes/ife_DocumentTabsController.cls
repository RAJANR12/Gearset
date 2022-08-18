public class ife_DocumentTabsController{
	@AuraEnabled
	public static string getGCS_Airframe(){
		ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'GCS_Airframe'
		                                          LIMIT 1];

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(integrationMdtObj.URL__c +'gcsAirframe?airline_operator=QATAR AIRWAYS');
		request.setMethod('GET');
		request.setHeader('client_id', integrationMdtObj.Client_Id__c);
		request.setHeader('client_secret', integrationMdtObj.Client_Secret__c);
		request.setHeader('Accept', '*/*');
		request.setHeader('Connection', 'keep-alive');
		request.setHeader('Content-Type', 'application/json');
		request.setTimeout(120000);
		HttpResponse response = http.send(request);
		System.debug('getBody ==== ' + response.getBody());
		return '{ "GCSAirframes": [ { "airframe": "A330-200/-300" }, { "airframe": "B737-600/-700/-800/-900/-900ER" } ] }';
	}
}