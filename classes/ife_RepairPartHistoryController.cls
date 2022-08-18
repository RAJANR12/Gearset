public class ife_RepairPartHistoryController{
	public ife_RepairPartHistoryController(){
	}

	@AuraEnabled(cacheable = true)
	public static String getRepairPartHistory(String partNumber , String serialNumber){
        System.debug('**partNumber  '+partNumber);
		System.debug('**serialNumber  '+serialNumber);
		if(partNumber == null){
			partNumber = '';
		}
		if(serialNumber == null){
			serialNumber = '';
		}
		//try{
			ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
			                                          FROM ife_Integration__mdt
			                                          WHERE MasterLabel = 'RepairPartHistory'
			                                          LIMIT 1];

			String url = integrationMdtObj.URL__c+'partNumber='+partNumber+'&serialNumber='+serialNumber+'&client_id='+integrationMdtObj.Client_Id__c+'&client_secret='+integrationMdtObj.Client_Secret__c;
			System.debug('**url RepairPartHistory---- ' + url);
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(url);
			request.setMethod('GET');
			request.setTimeout(120000);
			HttpResponse response = http.send(request);

			System.debug('REsult---------' + response.getBody());
			return  response.getBody();

		/*} catch (Exception e){
			System.debug('e---------' + e);
			String json = '{ "RepairPartHistoryDetails": [ { "SerialNumber": "F543016", "PartNumber": "RD-FD7492-01", "PartDescription": "9-inch Seat Integrated Smart Monitor", "PartMod": "1", "ActionDate": "Sep 20 2017 ", "ActionTaken": "Repair", "Source": "Panasonic Repair", "Location": "TAECO" } ] }';
			return json;
		}*/
	}
}