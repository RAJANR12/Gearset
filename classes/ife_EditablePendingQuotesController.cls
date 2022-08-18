public class ife_EditablePendingQuotesController{
	@AuraEnabled
	public static string getFeesFromApiCall(String srnumber){
		ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'RepairQuoteRejection'
		                                          LIMIT 1];
		try{
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(integrationMdtObj.URL__c + 'repairQuoteRejection/' +srnumber );
			request.setMethod('GET');
			request.setHeader('client_id', integrationMdtObj.Client_Id__c);
			request.setHeader('client_secret', integrationMdtObj.Client_Secret__c);
			request.setHeader('Accept', '*/*');
			request.setHeader('Connection', 'keep-alive');
			request.setHeader('Content-Type', 'application/json');
			request.setTimeout(120000);
			HttpResponse response = http.send(request);
			System.debug('getBody ==== ' + response.getBody());
            return '{ "RepairQuoteRejections": [ { "received_date": "03/21/2020 12:00:00 AM", "rate": "191.49000000", "fee": "200", "rejection_type": "return" }, { "received_date": "03/21/2020 12:00:00 AM", "rate": "191.49000000", "fee": "191.49000000", "rejection_type": "scrap" } ] }';
		} catch (Exception e){
            System.debug('e ==== ' + e);
			throw new AuraHandledException(e.getMessage());
		}
		
	}
}