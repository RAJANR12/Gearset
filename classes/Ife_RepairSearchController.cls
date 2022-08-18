public class Ife_RepairSearchController{
	public Ife_RepairSearchController(){
	}

	@AuraEnabled
	public static String getRepairSearchResults(String selectedAccount, String repairPO, String partNumber, String serialNumber, String srNumber, String repairLocation, String status, String shipdateRangeFrom, String shipdateRangeTo, String isShipDateUsed){

		if (repairPO == null){
			repairPO = '';
		}
		if (partNumber == null){
			partNumber = '';
		}
		if (serialNumber == null){
			serialNumber = '';
		}
		if (srNumber == null){
			srNumber = '';
		}
		if (repairLocation == null){
			repairLocation = '';
		}
		if (status == null){
			status = '';
		}
		if (shipdateRangeFrom == null){
			shipdateRangeFrom = '';
		}
		if (shipdateRangeTo == null){
			shipdateRangeTo = '';
		}
		try{
			ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
			                                          FROM ife_Integration__mdt
			                                          WHERE MasterLabel = 'RepairSearch'
			                                          LIMIT 1];
			System.debug('selectedAccount --- ' + selectedAccount);
			String url = integrationMdtObj.URL__c + 'repairOrdersSearch?OracleCustomerId=' + selectedAccount + '&RepairStatus=' + status + '&RepairPONumber=' + repairPO + '&PartNumber=' + partNumber + '&SerialNumber=' + serialNumber + '&RepairShop=' + repairLocation + '&SRNumber=' + srNumber + '&IsShipDateUsed=' + isShipDateUsed + '&ShipStartDate=' + shipdateRangeFrom + '&ShipEndDate=' + shipdateRangeTo + '&client_id=' + integrationMdtObj.Client_Id__c + '&client_secret=' + integrationMdtObj.Client_Secret__c;

			System.debug('**url- RepairSearch--------' + url);
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(url);
			request.setMethod('GET');
			request.setTimeout(120000);

			HttpResponse response = http.send(request);
			System.debug('response.getBody()---------' + response.getBody());
			if (response.getStatusCode() == 200){
				System.debug('response.getBody()---------' + response.getBody());
				return response.getBody();
			} else{
				System.debug('response.getStatus()---------' + response.getStatus());
				Ife_ErrorLog.createErrorLog('Ife_RepairSearchController',response.getStatus());
				return response.getStatus();
			}
		} catch (Exception e){
			System.debug('e---------' + e);
			Ife_ErrorLog.createErrorLog('Ife_RepairSearchController',e.getMessage());
			return e.getMessage();
		}
	}
}