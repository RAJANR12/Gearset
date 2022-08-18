public with sharing class ife_RepairDashboardController{
	@AuraEnabled
	public static String getRepairDashboard(){
		try{
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint('https://ltipac-preprod.lb.anypointdns.net/dev-ramco-system-api/api/repairCounts/1080?client_id=5211c7c8d45f4fdd889202d838f4a65b&client_secret=ED8EE7D90ed843c18dF39cA0D5d94685.');
			request.setMethod('GET');
			request.setTimeout(120000);
			HttpResponse response = http.send(request);
            System.debug('getBody ==== ' + response.getBody());
            return response.getBody();
		} catch (Exception e){
			System.debug('error---'+e);
            return '{ "RepairCounts": [ { "RepairOpenCount": "1114", "RepairClosedCount": "0", "QuoteApprovalCount": "20", "ModApprovalCount": "0" } ] }';
		}
    }
}