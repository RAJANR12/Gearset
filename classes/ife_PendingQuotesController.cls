public class ife_PendingQuotesController{
	public ife_PendingQuotesController(){
	}

	@AuraEnabled
	public static DataWapper getPendingQuotes(){
		DataWapper dataWapperObj = new DataWapper();
		//try{
			String customerId ='';
			User userObj =[SELECT Id ,Name,Contact.AccountId,Contact.Account.L2I_Customer_ID__c FROM User WHERE Id=:UserInfo.getUserId()];
			if(userObj.Contact.Account.L2I_Customer_ID__c != null){
				System.debug('userObj.Contact.Account.L2I_Customer_ID__c----'+userObj.Contact.Account.L2I_Customer_ID__c);
				customerId = userObj.Contact.Account.L2I_Customer_ID__c;
			}  
			System.debug('customerId----'+customerId);
			ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
			                                          FROM ife_Integration__mdt
			                                          WHERE MasterLabel = 'PendingQuotes'
													  LIMIT 1];
			

			String url = integrationMdtObj.URL__c + 'pendingQuotes/'+customerId+'?client_id=' + integrationMdtObj.Client_Id__c + '&client_secret=' + integrationMdtObj.Client_Secret__c;
			System.debug('url RepairDetails---- ' + url);
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(url);
			request.setMethod('GET');
			request.setTimeout(120000);
			HttpResponse response = http.send(request);

			System.debug('REsult---------' + response.getBody());
			//return JSON.serialize(response.getBody());
			dataWapperObj.apiResponse = response.getBody();
			dataWapperObj.SRNumberWithRepairQuoteMap = getRepairQuote();
			dataWapperObj.customerId =  customerId;
			return dataWapperObj;

		/*} catch (Exception e){
			System.debug('e---------' + e);
			String json = '{ "RepairQuoteApprovals": [ { "po_number": "RK0476928", "srnumber": "5460994", "part_number": "REPAIR PN TBD", "part_description": "REPAIR PN TBD", "shop": "PACSS", "state": "Shop Complete", "estimated_charge": 878.00000000, "source": "legacy" }, { "po_number": "RK0476929", "srnumber": "5460996", "part_number": "REPAIR PN TBD", "part_description": "REPAIR PN TBD", "shop": "PACSS", "state": "Shop Complete", "estimated_charge": 1367.00000000, "source": "legacy" }, { "po_number": "RK0476930", "srnumber": "5460998", "part_number": "REPAIR PN TBD", "part_description": "REPAIR PN TBD", "shop": "PACSS", "state": "Shop Complete", "estimated_charge": 1367.00000000, "source": "legacy" }, { "po_number": "RO3707390", "srnumber": "5465632", "part_number": "129778-01", "part_description": "PL3500 PORTABLE LOADER", "shop": "PACSS", "state": "Shop Complete", "estimated_charge": 1062.00000000, "source": "legacy" }, { "po_number": "RO3712205", "srnumber": "5465660", "part_number": "RD-FA3622-01", "part_description": "SEAT POWER MODULE", "shop": "PACSS", "state": "Shop Complete", "estimated_charge": 878.00000000, "source": "legacy" }, { "po_number": "RO3712093", "srnumber": "5465662", "part_number": "REPAIR PN TBD", "part_description": "REPAIR PN TBD", "shop": "PACSS", "state": "Shop Complete", "estimated_charge": 878.00000000, "source": "legacy" }, { "po_number": "RO3712079", "srnumber": "5465664", "part_number": "REPAIR PN TBD", "part_description": "REPAIR PN TBD", "shop": "PACSS", "state": "Shop Complete", "estimated_charge": 684.00000000, "source": "legacy" }, { "po_number": "RO3713513", "srnumber": "10000327", "part_number": "RD-FD7492-01", "part_description": "9-inch Seat Integrated Smart Monitor", "shop": "TAECO", "state": "NA", "estimated_charge": 1806.04000000, "source": "ramco" }, { "po_number": "RO3734050", "srnumber": "10097160", "part_number": "RD-FD8497-01", "part_description": "9-inch In-Arm Smart Monitor", "shop": "TAECO", "state": "ReQuote Approval", "estimated_charge": 2685.36000000, "source": "ramco" }, { "po_number": "RO3734049", "srnumber": "10097159", "part_number": "RD-FD8497-01", "part_description": "9-inch In-Arm Smart Monitor", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 294.00000000, "source": "ramco" }, { "po_number": "RO3734048", "srnumber": "10097158", "part_number": "RD-FD8497-01", "part_description": "9-inch In-Arm Smart Monitor", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 2691.06000000, "source": "ramco" }, { "po_number": "RO3734046", "srnumber": "10097157", "part_number": "RD-FD8497-01", "part_description": "9-inch In-Arm Smart Monitor", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 294.00000000, "source": "ramco" }, { "po_number": "RO3734045", "srnumber": "10097156", "part_number": "RD-FD8497-01", "part_description": "9-inch In-Arm Smart Monitor", "shop": "TAECO", "state": "ReQuote Approval", "estimated_charge": 0.00000000, "source": "ramco" }, { "po_number": "RO3736261", "srnumber": "10096464", "part_number": "RD-FD8497-01", "part_description": "9-inch In-Arm Smart Monitor", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 2686.72000000, "source": "ramco" }, { "po_number": "RO3736260", "srnumber": "10096463", "part_number": "RD-FD8497-01", "part_description": "9-inch In-Arm Smart Monitor", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 513.70000000, "source": "ramco" }, { "po_number": "RO3736259", "srnumber": "10096462", "part_number": "RD-FD8497-01", "part_description": "9-inch In-Arm Smart Monitor", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 2685.36000000, "source": "ramco" }, { "po_number": "RO3736258", "srnumber": "10096461", "part_number": "RD-FD8497-01", "part_description": "9-inch In-Arm Smart Monitor", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 0.00000000, "source": "ramco" }, { "po_number": "RO3717996", "srnumber": "10045682", "part_number": "RD-FD7492-01", "part_description": "9-inch Seat Integrated Smart Monitor", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 1875.24000000, "source": "ramco" }, { "po_number": "RO3718033", "srnumber": "10045518", "part_number": "RD-FD7492-01", "part_description": "9-inch Seat Integrated Smart Monitor", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 1875.24000000, "source": "ramco" }, { "po_number": "RO3732666", "srnumber": "10084870", "part_number": "RD-FA3124-02", "part_description": "DC-SEB", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 1766.43000000, "source": "ramco" }, { "po_number": "RO3734664", "srnumber": "10100130", "part_number": "RD-FJ8884-01", "part_description": "Smart Monitor", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 0.00000000, "source": "ramco" }, { "po_number": "RK0479127", "srnumber": "10094223", "part_number": "RD-FD8497-01", "part_description": "9-inch In-Arm Smart Monitor", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 5995.94000000, "source": "ramco" }, { "po_number": "RO3735207-001", "srnumber": "10091988", "part_number": "RD-FA3124-02", "part_description": "DC-SEB", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 1990.13000000, "source": "ramco" }, { "po_number": "RK0478472", "srnumber": "10066480", "part_number": "RD-FE7820-13", "part_description": "SMART MONITOR", "shop": "TAECO", "state": "ReQuote Approval", "estimated_charge": 4514.78000000, "source": "ramco" }, { "po_number": "RO3737641", "srnumber": "10103144", "part_number": "RD-FD8497-01", "part_description": "9-inch In-Arm Smart Monitor", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 324.00000000, "source": "ramco" }, { "po_number": "RO3739861", "srnumber": "10111743", "part_number": "RD-FE7820-13", "part_description": "SMART MONITOR", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 608.21000000, "source": "ramco" }, { "po_number": "RO3740395", "srnumber": "10114317", "part_number": "RD-FE7820-13", "part_description": "SMART MONITOR", "shop": "TAECO", "state": "Quote Approval", "estimated_charge": 4538.25000000, "source": "ramco" } ] }';
			dataWapperObj.apiResponse = json;
			dataWapperObj.SRNumberWithRepairQuoteMap = getRepairQuote();
			return dataWapperObj;
		}*/
	}

	public static String getRepairQuote(){
		Map<String, IFE_Repair_Quote__c> SRNumberWithRepairQuote = new Map<String, IFE_Repair_Quote__c>();
		for (IFE_Repair_Quote__c rqObj : [SELECT Id,IFE_Status__c,Shop__c, Name, IFE_SR_NUMBER__c, IFE_Action_Date__c, IFE_Decline_Action__c, IFE_Reason_For_Decline__c, Account__c
		                                  FROM IFE_Repair_Quote__c WHERE IFE_SR_NUMBER__c != null] ){
			SRNumberWithRepairQuote.put(rqObj.IFE_SR_NUMBER__c, rqObj);

		}

		return JSON.serialize(SRNumberWithRepairQuote);
	}

	@AuraEnabled
	public static String  createRepairQuote(String jsonObjList){
		System.debug('**---jsonObjList   -- ' + jsonObjList);
		List<IFE_Repair_Quote__c> repairQuoteList = new List<IFE_Repair_Quote__c>();
		List<JsonWrapper> objectList = (List<JsonWrapper>)JSON.deserialize(jsonObjList, List<JsonWrapper>.class);
		System.debug('**---objectList   -- ' + objectList);
		for (JsonWrapper obj : objectList){
			IFE_Repair_Quote__c rqObject = new IFE_Repair_Quote__c();
			if (String.isNotBlank(obj.Id)){
				System.debug('**---obj.Id   -- ' + obj.Id);
				rqObject.Id =String.valueOf(obj.Id);
			}
			if (String.isNotBlank(obj.IFE_SR_NUMBER)){
			rqObject.IFE_SR_NUMBER__c = String.valueOf(obj.IFE_SR_NUMBER);
			}
			//if (String.isNotBlank(obj.IFE_Reason_For_Decline)){
				rqObject.IFE_Reason_For_Decline__c = String.valueOf(obj.IFE_Reason_For_Decline);
			//}
			//if (String.isNotBlank(obj.IFE_Decline_Action)){
				rqObject.IFE_Decline_Action__c = obj.IFE_Decline_Action;
			//}
			rqObject.IFE_Status__c = String.valueOf(obj.IFE_Status);
			rqObject.Shop__c = obj.shop;
			rqObject.Customer_PO_Number__c = obj.customer_PO_Number;
			rqObject.Part_Number__c = obj.part_Number;
			rqObject.Estimate__c = obj.estimate;
			rqObject.Customer_Id__c = obj.customer_Id;
			
			
			repairQuoteList.add(rqObject);
		}
		System.debug('**---repairQuoteList   -- ' + repairQuoteList);
		System.debug('**---size   -- ' + repairQuoteList.size());
		if (!repairQuoteList.isEmpty()){
			upsert repairQuoteList;
			return 'SUCCESS';
		}
		return null;
	}
	public class DataWapper{
		@AuraEnabled
		public String apiResponse{ get; set; }

		@AuraEnabled
		public String SRNumberWithRepairQuoteMap{ get; set; }
		@AuraEnabled
		public String customerId{ get; set; }

		DataWapper(){
			apiResponse = '';
			SRNumberWithRepairQuoteMap = '';
			customerId = '';
		}
	}
	public class JsonWrapper{
		public String Id{ get; set; }
		public String IFE_SR_NUMBER{ get; set; }
		public String IFE_Decline_Action{ get; set; }
		public String IFE_Reason_For_Decline{ get; set; }
		public String IFE_Status{ get; set; }
		public String shop{ get; set; }
		public String customer_PO_Number{ get; set; }
		public String part_Number{ get; set; }
		public String estimate{ get; set; }
		public String customer_Id{ get; set; }
		
		

	 public void JsonWrapper(){
			Id = '';
			IFE_SR_NUMBER = '';
			IFE_Decline_Action = '';
			IFE_Reason_For_Decline='';
			IFE_Status = '';
			IFE_Status = '';
			shop = '';
			customer_PO_Number = '';
			part_Number = '';
			estimate = '';
			customer_Id = '';
		}
	}
}