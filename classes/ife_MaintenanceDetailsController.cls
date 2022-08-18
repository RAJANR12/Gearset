public with sharing class ife_MaintenanceDetailsController{
	public MaintenanceDetailsWapper dataWapperObj{ get; set; }

	public ife_MaintenanceDetailsController(){
		dataWapperObj = new MaintenanceDetailsWapper();
	}
	public void getMaintenanceDetails(){

		ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'MaintenanceDetail'
		                                          LIMIT 1];
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(integrationMdtObj.URL__c + 'MaintenanceDetail?FmrId=LP023008346&FmrStation=SIN');
		request.setMethod('GET');
		request.setHeader('client_id', integrationMdtObj.Client_Id__c);
		request.setHeader('client_secret', integrationMdtObj.Client_Secret__c);
		request.setHeader('Accept', '*/*');
		request.setHeader('Connection', 'keep-alive');
		request.setHeader('Content-Type', 'application/json');
		request.setTimeout(120000);
		HttpResponse response = http.send(request);
		System.debug('getBody ==== ' + response.getBody());
		String json = '{"PerfFmrDetail":[{"fmr_id":"LP027030126","fmr_station":"SIN","airline":"Singapore Airlines","fmr_tail_no":"9V-SMY","fmr_flight_no_in":"SQ037-10-LAX","arr_from":"LAX","fmr_schd_arrvd":"10/11/2020 8:15:00 AM","fmr_actl_arrvd":"10/11/2020 8:15:00 AM","fmr_flight_no_out":"SQ038","fmr_dept_to":"LAX","fmr_schd_dept":"10/11/2020 5:0:00 PM","fmr_actl_dept":"10/11/2020 5:0:00 PM","fmr_qmp":"00:07:46","msr":"Taufiq Rahmat ","fmr_fan":null,"fmr_far":null,"fmr_fa_trng":null,"bite":null,"sweep":"QMP","FmrUdfRecs":{"PerfFmrUdfRecs":[{"udf_seq":"8","udf_tag":"Closed","udf_desc":"CARRIED OUT 21K IFE FUNCT CHK FOUND SATIS.","udf_text":"CARRIED OUT 21K IFE FUNCT CHK FOUND SATIS."}]},"arr_code":"LAX","arr_seq":"1","arr_date":"10/11/2020 8:15:00 AM","tailnum":"9V-SMY","arr_flight_no":"SQ037-10-LAX","fmr_airline":"SQ","Defects":[{"PerfDefects":[{"afffunc":"D-INTERACTIVE","defectstation":"SIN","status":"Closed","defecttype":"A-LOGBOOK","defnum":"9V-SMY_IDL000023-9V-SMY_IDL000023","logpage":"9V-SMY_IDL000023","logitem":"9V-SMY_IDL000023","reason":null,"paxabuse":"N","deferred":"No","resets":null,"description":"Screen stuck at loading page, unable to go to home page. Attached picture. Video PA ok Able to play video from CMT","afflocs":"21K","defectseq":"8","faultfound":"0","PerfGetDefectUdfRecs":[{"def_udf_tag":"Closed","def_udf_desc":"CARRIED OUT 21K IFE FUNCT CHK FOUND SATIS.","def_udf_text":"CARRIED OUT 21K IFE FUNCT CHK FOUND SATIS."}],"PerfGetActionsRecs":[{"act_seq":"10","takenby":"SIN","asactiontaken":"CARRIED OUT 21K IFE FUNCT CHK FOUND SATIS.","act_time":null,"actiondescription":"Closed","PerfParts":[{"fmr_id":null,"fmr_station":null,"def_seq":null,"act_seq":null,"prt_no_on":null,"prt_serial_on":null,"prt_mod_on":null,"prt_no_off":null,"prt_mod_off":null,"prt_serial_off":null,"nomenclature":null,"removalreason":null,"prt_mro":null}]}]}]}]}]}';
		dataWapperObj = (MaintenanceDetailsWapper)System.JSON.deserialize(json, MaintenanceDetailsWapper.class);
		System.debug('dataWapperObj===='+dataWapperObj.PerfFmrDetail[0].fmr_id);
	}
	
	public class MaintenanceDetailsWapper{
		public cls_PerfFmrDetail[] PerfFmrDetail{ get; set; }
	}

	public class cls_PerfFmrDetail{
		public String fmr_id{ get; set; }

		public String fmr_station{ get; set; }

		public String airline{ get; set; }

		public String fmr_tail_no{ get; set; }

		public String fmr_flight_no_in{ get; set; }

		public String arr_from{ get; set; }

		public String fmr_schd_arrvd{ get; set; }

		public String fmr_actl_arrvd{ get; set; }

		public String fmr_flight_no_out{ get; set; }

		public String fmr_dept_to{ get; set; }

		public String fmr_schd_dept{ get; set; }

		public String fmr_actl_dept{ get; set; }

		public String fmr_qmp{ get; set; }

		public String msr{ get; set; }

		public String fmr_fan{ get; set; }

		public String fmr_far{ get; set; }

		public String fmr_fa_trng{ get; set; }

		public String bite{ get; set; }

		public String sweep{ get; set; }

		public cls_FmrUdfRecs FmrUdfRecs{ get; set; }

		public String arr_code{ get; set; }

		public String arr_seq{ get; set; }

		public String arr_date{ get; set; }

		public String tailnum{ get; set; }

		public String arr_flight_no{ get; set; }

		public String fmr_airline{ get; set; }

		public cls_Defects[] Defects{ get; set; }
	}

	public class cls_FmrUdfRecs{
		public cls_PerfFmrUdfRecs[] PerfFmrUdfRecs{ get; set; }
	}
	public class cls_PerfFmrUdfRecs{
		public String udf_seq{ get; set; }

		public String udf_tag{ get; set; }

		public String udf_desc{ get; set; }

		public String udf_text{ get; set; }

		
	}
	
	public class cls_Defects{
		public cls_PerfDefects[] PerfDefects{ get; set; }
	}
	public class cls_PerfDefects{
		public String afffunc{ get; set; }

		public String defectstation{ get; set; }

		public String status{ get; set; }

		public String defecttype{ get; set; }

		public String defnum{ get; set; }

		public String logpage{ get; set; }

		public String logitem{ get; set; }

		public String reason{ get; set; }

		public String paxabuse{ get; set; }

		public String deferred{ get; set; }

		public String resets{ get; set; }

		public String description{ get; set; }

		public String afflocs{ get; set; }

		public String defectseq{ get; set; }

		public String faultfound{ get; set; }

		public cls_PerfGetDefectUdfRecs[] PerfGetDefectUdfRecs{ get; set; }

		public cls_PerfGetActionsRecs[] PerfGetActionsRecs{ get; set; }
	}

	public class cls_PerfGetDefectUdfRecs{
		public String def_udf_tag{ get; set; }

		public String def_udf_desc{ get; set; }

		public String def_udf_text{ get; set; }
	}
	public class cls_PerfGetActionsRecs{
		public String act_seq{ get; set; }

		public String takenby{ get; set; }

		public String asactiontaken{ get; set; }

		public String act_time{ get; set; }

		public String actiondescription{ get; set; }

		public cls_PerfParts[] PerfParts{ get; set; }
	}

	public class cls_PerfParts{
		public String fmr_id{ get; set; }

		public String fmr_station{ get; set; }

		public String def_seq{ get; set; }

		public String act_seq{ get; set; }

		public String prt_no_on{ get; set; }

		public String prt_serial_on{ get; set; }

		public String prt_mod_on{ get; set; }

		public String prt_no_off{ get; set; }

		public String prt_mod_off{ get; set; }

		public String prt_serial_off{ get; set; }

		public String nomenclature{ get; set; }

		public String removalreason{ get; set; }

		public String prt_mro{ get; set; }
	}
	
	/*public void getMaintenanceDetails(){
		ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'MaintenanceDetail'
		                                          LIMIT 1];
												  Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(integrationMdtObj.URL__c + 'MaintenanceDetail?FmrId=LP023008346&FmrStation=SIN');
			request.setMethod('GET');
			request.setHeader('client_id', integrationMdtObj.Client_Id__c);
			request.setHeader('client_secret', integrationMdtObj.Client_Secret__c);
			request.setHeader('Accept', '**');
			request.setHeader('Connection', 'keep-alive');
			request.setHeader('Content-Type', 'application/json');
			request.setTimeout(120000);
			HttpResponse response = http.send(request);
			System.debug('getBody ==== ' + response.getBody());

		System.debug('Call getMaintenanceDetails');
		String perfFmrHeaderDataJson = '{ "PerfFmrHeaderData": [ { "fmr_id": "LP029059769", "fmr_station": "SIN", "airline": "Singapore Airlines", "fmr_tail_no": "9V-SMD", "fmr_flight_no_in": "SIN", "arr_from": "SIN", "fmr_schd_arrvd": "11/7/2020 10:28:00 PM", "fmr_actl_arrvd": "11/7/2020 10:28:00 PM", "fmr_flight_no_out": "SQ297", "fmr_dept_to": "CHC", "fmr_schd_dept": "11/8/2020 11:0:00 PM", "fmr_actl_dept": "11/8/2020 11:0:00 PM", "fmr_qmp": "00:23:32", "msr": "Teng Hwee Leo ", "fmr_fan": null, "fmr_far": null, "fmr_fa_trng": null, "bite": null, "sweep": "QMP" } ] }';
		PerfFmrHeaderData perfFmrHeaderDataObj = (PerfFmrHeaderData)System.JSON.deserialize(perfFmrHeaderDataJson, PerfFmrHeaderData.class);
		dataWapperObj.perfFmrHeaderDataObj = perfFmrHeaderDataObj.PerfFmrHeaderData[0];
		String jerfGetActionsRecsJson = '{ "PerfGetActionsRecs": [ { "act_seq": "1", "takenby": "SIN", "asactiontaken": "ROUTINE CHECK CARRIED OUT IAW INS/GEN/994, SATIS", "act_time": null, "actiondescription": "Closed" } ] }';
		PerfGetActionsRecs perfGetActionsRecsObj = (PerfGetActionsRecs)System.JSON.deserialize(jerfGetActionsRecsJson, PerfGetActionsRecs.class);
		System.debug('perfGetActionsRecsObj   ' + perfGetActionsRecsObj);
		dataWapperObj.perfGetActionsRecsObj = perfGetActionsRecsObj.PerfGetActionsRecs[0];
		String perfDefectsJson = '{ "PerfDefects": [ { "afffunc": "B-VIDEO", "defectstation": "SIN", "status": "Deferred", "defecttype": "A-LOGBOOK", "defnum": "9V-SMD_IDL000045-9V-SMD_IDL000045", "logpage": "9V-SMD_IDL000045", "logitem": "9V-SMD_IDL000045", "reason": "DNT", "paxabuse": "N", "deferred": "Yes", "resets": null, "description": "DURING POWER UP FOUND 15K NIL POWER", "afflocs": "15K", "defectseq": "1", "faultfound": "0" }, { "afffunc": null, "defectstation": "SIN", "status": "Closed", "defecttype": "Singapore Airlines Power Up Check", "defnum": "N/A", "logpage": null, "logitem": null, "reason": null, "paxabuse": null, "deferred": "No", "resets": null, "description": "Singapore Airlines Power Up Check", "afflocs": null, "defectseq": "2", "faultfound": null } ] }';
		PerfDefects perfDefectsObj = (PerfDefects)System.JSON.deserialize(perfDefectsJson, PerfDefects.class);
		dataWapperObj.perfDefectsList = perfDefectsObj.PerfDefects;
		String perfFmrUdfRecsJson = '{ "PerfFmrUdfRecs": [ { "udf_seq": "1", "udf_tag": "Closed", "udf_desc": "ROUTINE CHECK CARRIED OUT IAW INS/GEN/994, SATIS", "udf_text": "ROUTINE CHECK CARRIED OUT IAW INS/GEN/994, SATIS" } ] }';
		PerfFmrUdfRecs perfFmrUdfRecsObj = (PerfFmrUdfRecs)System.JSON.deserialize(perfFmrUdfRecsJson, PerfFmrUdfRecs.class);
		dataWapperObj.PerfFmrUdfRecs = perfFmrUdfRecsObj.PerfFmrUdfRecs;
	}

	public class MaintenanceDetailsWapper{
		public cls_PerfFmrHeaderData perfFmrHeaderDataObj{ get; set; }

		public cls_PerfGetActionsRecs perfGetActionsRecsObj{ get; set; }

		public cls_PerfDefects[] perfDefectsList{ get; set; }

		public cls_PerfFmrUdfRecs[] PerfFmrUdfRecs{ get; set; }
	}

	public class PerfFmrHeaderData{
		public cls_PerfFmrHeaderData[] PerfFmrHeaderData;

	}

	public class cls_PerfFmrHeaderData{
		public String fmr_id{ get; set; }

		public String fmr_station{ get; set; }

		public String airline{ get; set; }

		public String fmr_tail_no{ get; set; }

		public String fmr_flight_no_in{ get; set; }

		public String arr_from{ get; set; }

		public String fmr_schd_arrvd{ get; set; }

		public String fmr_actl_arrvd{ get; set; }

		public String fmr_flight_no_out{ get; set; }

		public String fmr_dept_to{ get; set; }

		public String fmr_schd_dept{ get; set; }

		public String fmr_actl_dept{ get; set; }

		public String fmr_qmp{ get; set; }

		public String msr{ get; set; }

		public String fmr_fan{ get; set; }

		public String fmr_far{ get; set; }

		public String fmr_fa_trng{ get; set; }

		public String bite{ get; set; }

		public String sweep{ get; set; }
	}

	public class PerfGetActionsRecs{
		public cls_PerfGetActionsRecs[] PerfGetActionsRecs{ get; set; }
	}

	public class cls_PerfGetActionsRecs{
		public String act_seq{ get; set; }

		public String takenby{ get; set; }

		public String asactiontaken{ get; set; }

		public String act_time{ get; set; }

		public String actiondescription{ get; set; }
	}

	public class PerfDefects{
		public cls_PerfDefects[] PerfDefects{ get; set; }
	}

	public class cls_PerfDefects{
		public String afffunc{ get; set; }

		public String defectstation{ get; set; }

		public String status{ get; set; }

		public String defecttype{ get; set; }

		public String defnum{ get; set; }

		public String logpage{ get; set; }

		public String logitem{ get; set; }

		public String reason{ get; set; }

		public String paxabuse{ get; set; }

		public String deferred{ get; set; }

		public String resets{ get; set; }

		public String description{ get; set; }

		public String afflocs{ get; set; }

		public String defectseq{ get; set; }

		public String faultfound{ get; set; }
	}

	public class PerfFmrUdfRecs{
		public cls_PerfFmrUdfRecs[] PerfFmrUdfRecs;

	}

	public class cls_PerfFmrUdfRecs{
		public String udf_seq{ get; set; }

		public String udf_tag{ get; set; }

		public String udf_desc{ get; set; }

		public String udf_text{ get; set; }
	}*/
}