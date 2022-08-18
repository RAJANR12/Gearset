public class ife_PackSlipReportController{
	public String deliveryId{ get; set; }

	public HeaderWrapper headerObj{ get; set; }

	public Boolean isDisplay{ get; set; }

	public String logoName{ get; set; }

	public String shopAddress{ get; set; }

	public String shopTeleFax{ get; set; }

	public Integer recordPerPage{ get; set; }

	public Integer totalRecords{ get; set; }

	public Integer breakBeforLastPage{ get; set; }

	public ife_PackSlipReportController(){
		deliveryId = ApexPages.currentPage().getParameters().get('id');
		isDisplay = true;
		logoName = '';
		shopAddress = '';
		shopTeleFax = '';
		recordPerPage = 4;
		totalRecords = 0;
		breakBeforLastPage = 0;
	}

	public void getPageValue(){
		ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'PackSlipReport'
		                                          LIMIT 1];
		try{
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(integrationMdtObj.URL__c + 'myIfePackSlipReport?deliveryId='+deliveryId);
			request.setMethod('GET');
			request.setHeader('client_id', integrationMdtObj.Client_Id__c);
			request.setHeader('client_secret', integrationMdtObj.Client_Secret__c);
			request.setHeader('Accept', '*/*');
			request.setHeader('Connection', 'keep-alive');
			request.setHeader('Content-Type', 'application/json');
			request.setTimeout(120000);
			HttpResponse response = http.send(request);
			System.debug('getBody ==== ' + response.getBody());
			JSONWrapper JSONWrapperObj = (JSONWrapper)System.JSON.deserialize(response.getBody(), JSONWrapper.class);
			System.debug('JSONWrapperObj>>' + JSONWrapperObj);
			headerObj = JSONWrapperObj.Header;
			totalRecords = headerObj.lines.size();
			System.debug('headerObj-----' + headerObj);
			if (math.mod(totalRecords, recordPerPage) == 0){
				breakBeforLastPage = totalRecords - 1;
			}

			System.debug('headerObj>>' + headerObj);
			if (headerObj.H_ORDER_TYPE_ID == 1515 || headerObj.H_ORDER_TYPE_ID == 1516){
				logoName = 'Panasonic Transportation Systems Company';
				shopAddress = 'Division of Panasonic Avionics Corporation 121 Whittendale Drive, Building 1,Moorestown, NJ 08057, U.S.A.';
				shopTeleFax = 'Telephone: (856) 866-8720 Fax: (856) 866-8743&#39;';

			} else{
				logoName = 'Panasonic Avionics Corporation';
				shopAddress = '3303 Monte Villa Parkway, Bothell, WA 98021, U.S.A.';
				shopTeleFax = 'Telephone: (425) 415-9000 Fax: (425) 487-0776;';

			}
		} catch (Exception e){
			System.debug('e---------' + e);
			isDisplay = false;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '' + e));
			/*String json = '{ "Header": { "DELIVERY_ID": 944390537, "C_SHIP_DATE": "2005-09-29T18:05:47", "NUMBER_OF_LPN": null, "C_DELIVERY_NAME": "944390537", "C_WAYBILL": "705404376445", "C_GROSS_WEIGHT": 416, "C_WEIGHT_UOM": "Kg", "C_VOLUME": 56, "C_VOLUME_UOM_CODE": "Bx", "TRIP_NAME": "619021", "CF_FROM_LOCATION": "OSAKA", "C_TO_ADDRESS_1": "C/O AIRBUS COM", "CF_TO_ADDR_2": "USINE CLEMENT ADER AVENUE JEAN MONNET", "CF_TO_ADDR_3": "MAGASIN 7P2-TIT CC60Q", "CF_TO_ADDR_4": null, "CF_TO_CITY": "COLOMIERS 31770, FR", "CF_TERM": "30 NET -a", "CF_FREIGHT_CARRIER": "FEDEX", "CF_FREIGHT_TERMS": "PA Pays Freight (old)", "CONSIGNEE_NAME": "QATAR AIRWAYS", "CP_PACKING_INSTRUCTIONS": "DHL ACCT# 961085829", "CF_FOB": null, "F_BILL_TO_CUST_NAME": "QATAR AIRWAYS", "CP_WAREHOUSE_NAME": "OSAKA", "CP_WAREHOUSE_CODE": "OSA", "lines": [ { "CF_ITEM_NUM": "RD-AX7675-51", "C_SO_NUMBER": "1536600", "LINE_NUM": 73, "C_ITEM_DESCRIPTION": "PRAM", "C_SHIP_QTY": 1, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "EE", "CF_PO_LINE_NUM": "35", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "EAR99/JPN" }, { "CF_ITEM_NUM": "RD-AA8234-01", "C_SO_NUMBER": "1536600", "LINE_NUM": 74, "C_ITEM_DESCRIPTION": "CPMS MEMORY EXPANSION UNIT III (CMEU III)", "C_SHIP_QTY": 2, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "EE", "CF_PO_LINE_NUM": "22", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "9A991.d/JPN" }, { "CF_ITEM_NUM": "RD-AA8064-01", "C_SO_NUMBER": "1536600", "LINE_NUM": 75, "C_ITEM_DESCRIPTION": "LAN HUB", "C_SHIP_QTY": 1, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "EE", "CF_PO_LINE_NUM": "19", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "EAR99/JPN" }, { "CF_ITEM_NUM": "RD-AA5009-02", "C_SO_NUMBER": "1536600", "LINE_NUM": 76, "C_ITEM_DESCRIPTION": "RF DISTRIBUTION AMP", "C_SHIP_QTY": 2, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "EE", "CF_PO_LINE_NUM": "15", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "EAR99/JPN" }, { "CF_ITEM_NUM": "RD-AX7095-01", "C_SO_NUMBER": "1536600", "LINE_NUM": 77, "C_ITEM_DESCRIPTION": "CD REPRODUCER", "C_SHIP_QTY": 1, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "EE", "CF_PO_LINE_NUM": "34", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "EAR99/JPN" }, { "CF_ITEM_NUM": "RD-AA5101-10", "C_SO_NUMBER": "1536600", "LINE_NUM": 50, "C_ITEM_DESCRIPTION": "TAPPING UNIT", "C_SHIP_QTY": 9, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "OH", "CF_PO_LINE_NUM": "16", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "9A991.d/JPN" }, { "CF_ITEM_NUM": "RD-AV7151-01", "C_SO_NUMBER": "1536600", "LINE_NUM": 53, "C_ITEM_DESCRIPTION": "LCD MONITOR", "C_SHIP_QTY": 5, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "OH", "CF_PO_LINE_NUM": "30", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "9A991.d/JPN" }, { "CF_ITEM_NUM": "RD-AV9818-01", "C_SO_NUMBER": "1536600", "LINE_NUM": 55, "C_ITEM_DESCRIPTION": "LCD MONITOR", "C_SHIP_QTY": 9, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "OH", "CF_PO_LINE_NUM": "32", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "EAR99/JPN" }, { "CF_ITEM_NUM": "RD-AA2904-02", "C_SO_NUMBER": "1536600", "LINE_NUM": 56, "C_ITEM_DESCRIPTION": "TERM PLUG", "C_SHIP_QTY": 6, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "OH", "CF_PO_LINE_NUM": "8", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "EAR99/JPN" }, { "CF_ITEM_NUM": "RD-AX7092-01", "C_SO_NUMBER": "1536600", "LINE_NUM": 58, "C_ITEM_DESCRIPTION": "CD REPRODUCER", "C_SHIP_QTY": 2, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "LRU", "CF_PO_LINE_NUM": "33", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "EAR99/JPN" }, { "CF_ITEM_NUM": "RD-AA5007-13", "C_SO_NUMBER": "1536600", "LINE_NUM": 59, "C_ITEM_DESCRIPTION": "ENHANCED VIDEO SYSTEM CTRL UNIT", "C_SHIP_QTY": 1, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "LRU", "CF_PO_LINE_NUM": "14", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "9A991.d/JPN" }, { "CF_ITEM_NUM": "RD-AA5002-25", "C_SO_NUMBER": "1536600", "LINE_NUM": 60, "C_ITEM_DESCRIPTION": "VIDEO MODULATOR UNIT (VMU)", "C_SHIP_QTY": 1, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "LRU", "CF_PO_LINE_NUM": "13", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "EAR99/JPN" }, { "CF_ITEM_NUM": "RD-AV1216-01", "C_SO_NUMBER": "1536600", "LINE_NUM": 61, "C_ITEM_DESCRIPTION": "HI-8 VIDEO CASSETTE PLAYER", "C_SHIP_QTY": 3, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "LRU", "CF_PO_LINE_NUM": "29", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "EAR99/JPN" }, { "CF_ITEM_NUM": "RD-AA3643-05", "C_SO_NUMBER": "1536600", "LINE_NUM": 62, "C_ITEM_DESCRIPTION": "DSEBI", "C_SHIP_QTY": 3, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "LRU", "CF_PO_LINE_NUM": "11", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "9A991.d/JPN" }, { "CF_ITEM_NUM": "RD-AA8044-01", "C_SO_NUMBER": "1536600", "LINE_NUM": 64, "C_ITEM_DESCRIPTION": "CD-ROM UNIT", "C_SHIP_QTY": 1, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "LRU", "CF_PO_LINE_NUM": "17", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "EAR99/JPN" }, { "CF_ITEM_NUM": "RD-AA3902-01", "C_SO_NUMBER": "1536600", "LINE_NUM": 65, "C_ITEM_DESCRIPTION": "TOKEN RING INTERFACE BOX", "C_SHIP_QTY": 1, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "LRU", "CF_PO_LINE_NUM": "12", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "9A991.d/JPN" }, { "CF_ITEM_NUM": "RD-AA2902-01", "C_SO_NUMBER": "1536600", "LINE_NUM": 67, "C_ITEM_DESCRIPTION": "TERMINATION PLUG, IVASEB", "C_SHIP_QTY": 1, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "LRU", "CF_PO_LINE_NUM": "7", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "EAR99/JPN" }, { "CF_ITEM_NUM": "RD-AT1004-13", "C_SO_NUMBER": "1536600", "LINE_NUM": 71, "C_ITEM_DESCRIPTION": "CABIN TELECOMMUNICATION UNIT", "C_SHIP_QTY": 1, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "EE", "CF_PO_LINE_NUM": "28", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "9A991.d/JPN" }, { "CF_ITEM_NUM": "RD-AA3501-02", "C_SO_NUMBER": "1536600", "LINE_NUM": 79, "C_ITEM_DESCRIPTION": "QAM MODULATOR UNIT II", "C_SHIP_QTY": 4, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "EE2", "CF_PO_LINE_NUM": "10", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "9A991.d/JPN" }, { "CF_ITEM_NUM": "RD-AA8341-02", "C_SO_NUMBER": "1536600", "LINE_NUM": 80, "C_ITEM_DESCRIPTION": "HDDA", "C_SHIP_QTY": 3, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "EE2", "CF_PO_LINE_NUM": "23", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "9A991.d/JPN" }, { "CF_ITEM_NUM": "RD-AA8210-01", "C_SO_NUMBER": "1536600", "LINE_NUM": 81, "C_ITEM_DESCRIPTION": "FIBER CHANNEL HUB", "C_SHIP_QTY": 2, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "EE2", "CF_PO_LINE_NUM": "21", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "EAR99/JPN" }, { "CF_ITEM_NUM": "RD-AA5101-10", "C_SO_NUMBER": "1536600", "LINE_NUM": 50, "C_ITEM_DESCRIPTION": "TAPPING UNIT", "C_SHIP_QTY": 1, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "OH", "CF_PO_LINE_NUM": "16", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "9A991.d/JPN" } ] } }';
			 JSONWrapper JSONWrapperObj = (JSONWrapper)System.JSON.deserialize(json, JSONWrapper.class);
			 headerObj = JSONWrapperObj.Header;
			 if (headerObj.H_ORDER_TYPE_ID == 1515 || headerObj.H_ORDER_TYPE_ID == 1516){
			 logoName = 'Panasonic Transportation Systems Company';
			 shopAddress = 'Division of Panasonic Avionics Corporation 121 Whittendale Drive, Building 1,Moorestown, NJ 08057, U.S.A.';
			 shopTeleFax = 'Telephone: (856) 866-8720 Fax: (856) 866-8743&#39;';

			 } else{
			 logoName = 'Panasonic Avionics Corporation';
			 shopAddress = '3303 Monte Villa Parkway, Bothell, WA 98021, U.S.A.';
			 shopTeleFax = 'Telephone: (425) 415-9000 Fax: (425) 487-0776;';

			 }*/

		}
	}

	public class JSONWrapper{
		
		public HeaderWrapper Header{ get; set; }
	}

	public class HeaderWrapper{
		
		public String C_SO_NUMBER{ get; set; }

		public String CF_PROGRAM_TYPE{ get; set; }

		public String CF_ULT_TO_ADDR1{ get; set; }

		public String CF_ULT_TO_ADDR2{ get; set; }

		public String CF_ULT_TO_ADDR3{ get; set; }

		public String CF_ULT_TO_ADDR4{ get; set; }

		public String CF_ULT_TO_CITY_STATE_ZIP{ get; set; }

		public String CP_SHIPPING_INSTRUCTIONS{ get; set; }

		public String CP_ORIG_SYS_DOCUMENT_REF{ get; set; }

		public String CF_SHIP_SET{ get; set; }

		public String CF_TAIL_NUMBER{ get; set; }

		public String CF_PROGRAM_NUMBER{ get; set; }

		public String CF_SHIP_TO_CONTACT{ get; set; }

		public String CP_SHIP_TO_PHONE_NO{ get; set; }

		public Integer H_ORDER_TYPE_ID{ get; set; }

		public Integer DELIVERY_ID{ get; set; }

		public String C_SHIP_DATE{ get; set; }

		public String NUMBER_OF_LPN{ get; set; }

		public String C_DELIVERY_NAME{ get; set; }

		public String C_WAYBILL{ get; set; }

		public Integer C_GROSS_WEIGHT{ get; set; }

		public String C_WEIGHT_UOM{ get; set; }

		public Integer C_VOLUME{ get; set; }

		public String C_VOLUME_UOM_CODE{ get; set; }

		public String TRIP_NAME{ get; set; }

		public String CF_FROM_LOCATION{ get; set; }

		public String C_TO_ADDRESS_1{ get; set; }

		public String CF_TO_ADDR_2{ get; set; }

		public String CF_TO_ADDR_3{ get; set; }

		public String CF_TO_ADDR_4{ get; set; }

		public String CF_TO_CITY{ get; set; }

		public String CF_TERM{ get; set; }

		public String CF_FREIGHT_CARRIER{ get; set; }

		//FEDEX
		public String CF_FREIGHT_TERMS{ get; set; }

		public String CONSIGNEE_NAME{ get; set; }

		public String CP_PACKING_INSTRUCTIONS{ get; set; }

		public String CF_FOB{ get; set; }

		public String F_BILL_TO_CUST_NAME{ get; set; }

		public String CP_WAREHOUSE_NAME{ get; set; }

		public String CP_WAREHOUSE_CODE{ get; set; }

		public LinesWapper[] lines{ get; set; }
	}

	public class LinesWapper{
		public String CF_ITEM_NUM{ get; set; }

		public String C_SO_NUMBER{ get; set; }

		public Integer LINE_NUM{ get; set; }

		public String C_ITEM_DESCRIPTION{ get; set; }

		public Integer C_SHIP_QTY{ get; set; }

		public String C_REQ_QTY_UOM{ get; set; }

		public String CF_INST_LOCATION{ get; set; }

		public String CF_PO_LINE_NUM{ get; set; }

		public String CF_REF_PO{ get; set; }

		public String CF_REF_IPO{ get; set; }

		public String CF_LPN_NAME{ get; set; }

		public String CP_DEST_SUB_INV{ get; set; }

		public String CF_LINE_NOTES{ get; set; }

		public String CF_CUST_PO_NUM{ get; set; }

		public String CF_ECCN_NUM{ get; set; }
	}
}