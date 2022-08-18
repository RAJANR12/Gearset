public class ife_SOReportController{
	public fromJSON fromJSONObj{ get; set; }

	public cls_Header headerObj{ get; set; }
	public Date todayDate{
		get{
			return Date.today();
		}
	}

	public String logoName{ get; set; }

	public String shopAddress{ get; set; }

	public String shopTeleFax{ get; set; }
	public String headerId{ get; set; }

	public Integer recordPerPage { get; set; }
	public Integer totalRecords { get; set; }
	public Integer breakBeforLastPage{ get; set; }
	public Boolean isDisplay {get;set;}

	public ife_SOReportController(){
		headerId = ApexPages.currentPage().getParameters().get('id');
		fromJSONObj = new fromJSON();
		headerObj = new cls_Header();
		logoName = '';
		shopAddress = '';
		shopTeleFax = '';
		recordPerPage = 12;
		totalRecords = 0;
		breakBeforLastPage = 0;
		isDisplay = true;
	}

	public void getPageValue(){
		System.debug('orderHeaderId====='+headerId);
		ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'Acknowlegement'
		                                          LIMIT 1];
		try{

			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(integrationMdtObj.URL__c + 'myIfeOrderAcknowledgementReport?headerId='+headerId);
			request.setMethod('GET');
			request.setHeader('client_id', integrationMdtObj.Client_Id__c);
			request.setHeader('client_secret', integrationMdtObj.Client_Secret__c);
			request.setHeader('Accept', '*/*');
			request.setHeader('Connection', 'keep-alive');
			request.setHeader('Content-Type', 'application/json');
			request.setTimeout(120000);
			HttpResponse response = http.send(request);
			System.debug('getBody ==== ' + response.getBody());
			
			fromJSONObj = (fromJSON)System.JSON.deserialize(response.getBody(), fromJSON.class);
			headerObj = fromJSONObj.Header;
			totalRecords = fromJSONObj.lines.size();
			System.debug('headerObj-----'+headerObj);
			if (math.mod(totalRecords, recordPerPage) == 0){
				breakBeforLastPage = totalRecords - 2;
			}
			if (math.mod(totalRecords, recordPerPage) == recordPerPage-1){
				breakBeforLastPage = totalRecords - 1;
			}
			if (headerObj.H_ORDER_TYPE_ID == 1515 || headerObj.H_ORDER_TYPE_ID == 1516){
				logoName = 'Panasonic Transportation Systems Company';
				shopAddress = 'Division of Panasonic Avionics Corporation 121 Whittendale Drive, Building 1, Moorestown, NJ 08057, U.S.A.';
				shopTeleFax = 'Telephone: (856) 866-8720 Fax: (856) 866-8743';

			} else{
				logoName = 'Panasonic Avionics Corporation';
				shopAddress = '3303 Monte Villa Parkway, Bothell, WA 98021, U.S.A.';
				shopTeleFax = 'Telephone: (425) 415-9000 Fax: (425) 487-0776';
			}
		} catch (Exception e){
			isDisplay = false;
			System.debug('e---------' + e);
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,''+e));
			/*String json = '{ "Header": { "RP_TAXABLE_AMOUNT": 0, "B_COUNTRY_NAME": "US", "HEADER_ID": 390537, "BILL_TO_LOCATION": "HOUSTON, TEXAS, RS", "F_AC_NUMBER": null, "ORDER_NUMBER": 1227937, "PAYMENT_TERMS": "30 NET -a", "S_CITY_ST_ZIP": "JEDDAH,-21231", "CF_SR_NUMBER": "594897", "BILL_CUSTOMER": "SAUDI ARABIAN AIRLINES", "F_SO_CONTACT": null, "B_ADDRESS3": null, "H_ORDER_TYPE_ID": 1044, "B_ADDRESS4": null, "B_ADDRESS1": "ACCOUNTS PAYABLE - DFO", "B_ADDRESS2": "12555 NORTH BOROUGH", "FREIGHT_TERMS": null, "S_COUNTRY_NAME": "SA", "F_AC_TYPE": null, "ORDER_DATE": "13-MAR-02", "S_ADDRESS4": null, "CF_HDR_HOLD": 0, "CARRIER": null, "CURRENCY1": "USD", "S_ADDRESS2": null, "S_ADDRESS3": null, "PURCHASE_ORDER": "2302629", "CF_DSP_EXTND_AMT": null, "S_ADDRESS1": "PROCUREMENT DEPT", "SHIP_TO_LOCATION": "PROCUREMENT DEPT,SAUDI ARABIA,RS", "ATTRIBUTE1": null, "FOB": null, "SHIP_CUSTOMER": "SAUDI ARABIAN AIRLINES", "B_CITY_ST_ZIP1": "HOUSTON,,77067" }, "lines": [ { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "TOTAL OUT-OF-WARRANTY REPAIR", "QUANTITY_ORDERED": 1, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0.0001, "UNIT": "EACH", "SHIP_NUMBER": 3, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 },{ "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "TOTAL OUT-OF-WARRANTY REPAIR", "QUANTITY_ORDERED": 1, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0.0001, "UNIT": "EACH", "SHIP_NUMBER": 3, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "ZONE INTERFACE UNIT", "QUANTITY_ORDERED": 1, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 1, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "TOTAL OUT-OF-WARRANTY REPAIR", "QUANTITY_ORDERED": 1, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0.0001, "UNIT": "EACH", "SHIP_NUMBER": 2, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 }, { "DECODE_SUBSTR_UPPER_P_PRINT_DE": null, "ITEM_DESCRIPTION2": "Value for Service Shipments", "QUANTITY_ORDERED": 3330, "CF_LINE_HOLD": 0, "C_EXTENDED_PRICE_DSP": 0, "SELLING_PRICE": 0, "UNIT": "EACH", "SHIP_NUMBER": 4, "SCHEDULE_DATE": "13-MAR-02", "HEADER_ID": 390537 } ] }';
			fromJSONObj = (fromJSON)System.JSON.deserialize(json, fromJSON.class);
			headerObj = fromJSONObj.Header;
			totalRecords = fromJSONObj.lines.size();
			if (math.mod(totalRecords, recordPerPage) == 0){
				breakBeforLastPage = totalRecords - 2;
			}
			if (math.mod(totalRecords, recordPerPage) == recordPerPage-1){
				breakBeforLastPage = totalRecords - 1;
			}
			if (headerObj.H_ORDER_TYPE_ID == 1515 || headerObj.H_ORDER_TYPE_ID == 1516){
				logoName = 'Panasonic Transportation Systems Company';
				shopAddress = 'Division of Panasonic Avionics Corporation 121 Whittendale Drive, Building 1, Moorestown, NJ 08057, U.S.A.';
				shopTeleFax = 'Telephone: (856) 866-8720 Fax: (856) 866-8743';

			} else{
				logoName = 'Panasonic Avionics Corporation';
				shopAddress = '3303 Monte Villa Parkway, Bothell, WA 98021, U.S.A.';
				shopTeleFax = 'Telephone: (425) 415-9000 Fax: (425) 487-0776';
			}*/

		}
	}

	public class fromJSON{
		public cls_Header Header{ get; set; }

		public cls_lines[] lines{ get; set; }
	}

	public class cls_Header{
		public Integer RP_TAXABLE_AMOUNT{ get; set; }
		public String B_COUNTRY_NAME{ get; set; }
		public Integer HEADER_ID{ get; set; }
		public String BILL_TO_LOCATION{ get; set; }
		public String F_AC_NUMBER{ get; set; }
		public Integer ORDER_NUMBER{ get; set; }
		public String PAYMENT_TERMS{ get; set; }
		public String S_CITY_ST_ZIP{ get; set; }
		public String CF_SR_NUMBER{ get; set; }

		public String BILL_CUSTOMER{ get; set; }
		public String F_SO_CONTACT{ get; set; }
		public String B_ADDRESS3{ get; set; }
		public Integer H_ORDER_TYPE_ID{ get; set; }
		public String B_ADDRESS4{ get; set; }
		public String B_ADDRESS1{ get; set; }
		public String B_ADDRESS2{ get; set; }
		public String FREIGHT_TERMS{ get; set; }
		public String S_COUNTRY_NAME{ get; set; }
		public String F_AC_TYPE{ get; set; }
		public String ORDER_DATE{ get; set; }
		public String S_ADDRESS4{ get; set; }
		public Integer CF_HDR_HOLD{ get; set; }
		public String CARRIER{ get; set; }
		public String CURRENCY1{ get; set; }
		public String S_ADDRESS2{ get; set; }
		public String S_ADDRESS3{ get; set; }
		public String PURCHASE_ORDER{ get; set; }
		public Double CF_DSP_EXTND_AMT{ get; set; }
		public String S_ADDRESS1{ get; set; }
		public String SHIP_TO_LOCATION{ get; set; }
		public String ATTRIBUTE1{ get; set; }
		public String FOB{ get; set; }
		public String SHIP_CUSTOMER{ get; set; }
		public String B_CITY_ST_ZIP1{ get; set; }		
	}
	public class cls_lines{
		public String DECODE_SUBSTR_UPPER_P_PRINT_DE{ get; set; }
		public String ITEM_DESCRIPTION2{ get; set; }
		public Integer QUANTITY_ORDERED{ get; set; }
		public Integer CF_LINE_HOLD{ get; set; }
		public Double C_EXTENDED_PRICE_DSP{ get; set; }
		public Double SELLING_PRICE{ get; set; }
		public String UNIT{ get; set; }
		public Integer SHIP_NUMBER{ get; set; }
		public String SCHEDULE_DATE{ get; set; }
		public Integer HEADER_ID{ get; set; }
	}

	public static fromJSON parse(String json){
		return (fromJSON)System.JSON.deserialize(json, fromJSON.class);
	}
}