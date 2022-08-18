public class ife_CommercialInvoiceController{
	public JSONWrapper JSONWrapperObj{ get; set; }
	public String headerId{ get; set; }
	public HeaderWrapper headerObj{ get; set; }

	public Integer recordPerPage{ get; set; }

	public Integer totalRecords{ get; set; }

	public Integer breakBeforLastPage{ get; set; }

	public Boolean isDisplay{ get; set; }

	public ife_CommercialInvoiceController(){
		headerId = ApexPages.currentPage().getParameters().get('id');
		JSONWrapperObj = new JSONWrapper();
		headerObj = new HeaderWrapper();
		recordPerPage = 5;
		totalRecords = 0;
		breakBeforLastPage = 0;
		isDisplay = true;
	}

	public void getPageValue(){
		ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'CommercialInvoiceReport'
		                                          LIMIT 1];
		System.debug('***  -- integrationMdtObj----' + integrationMdtObj);
		try{
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(integrationMdtObj.URL__c + 'myIfeCommercialInvoiceReport?deliveryId='+headerId+'&otmShipmentId=');
			//request.setEndpoint('https://dev-commonfunctions-experience-api.us-w1.cloudhub.io/api/myIfeCommercialInvoiceReport?deliveryId='+headerId+'&otmShipmentId=');
			request.setMethod('GET');
			request.setHeader('client_id', integrationMdtObj.Client_Id__c);
			request.setHeader('client_secret', integrationMdtObj.Client_Secret__c);
			request.setHeader('Accept', '*/*');
			request.setHeader('Connection', 'keep-alive');
			request.setHeader('Content-Type', 'application/json');
			request.setTimeout(120000);
			System.debug('request ==== ' + request);
			HttpResponse response = http.send(request);
			System.debug('getBody ==== ' + response.getBody());
			JSONWrapperObj = (JSONWrapper)System.JSON.deserialize(response.getBody(), JSONWrapper.class);
			system.debug('@@@JSONWrapperObj' + JSONWrapperObj);
			headerObj = JSONWrapperObj.Header;
			system.debug('@@@headerObj' + headerObj);
			totalRecords = JSONWrapperObj.lines.size();
			system.debug('@@@totalRecords' + totalRecords);
			if (math.mod(totalRecords, recordPerPage) == 0){
				breakBeforLastPage = totalRecords - 1;
			}
			/*if (math.mod(totalRecords, recordPerPage) == recordPerPage - 1){
				breakBeforLastPage = totalRecords - 1;
			}*/

		} catch (Exception e){
			isDisplay = false;
			System.debug('e---------' + e);

			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '' + e));
			/*String json = '{ "Header": { "CF_ULT_SHIP_ADDR2": "LONG BIEN DISTRICT", "CF_ULTIMATE_SHIP_TO": "VIETNAM AIRLINES", "CF_ULTI_BILLCITYSTATEZIP": "HANOI,  ", "CF_FREIGHT_TERMS_CODE": "BILL THIRD PARTY ", "DELIVERY_ID": 972337241, "CF_WAYBILL": "422761171447", "CF_1STDEST_CUSTOMER1": "VIETNAM AIRLINES", "CURRENCY_CODE": "USD", "CF_BILL_COUNTRY": "Viet Nam", "CF_1STDEST_ADDRESS3": null, "CPP_IMPORTED_FROM": null, "CF_1STDEST_ADDRESS1": "901 W ARBOR VITAE ST", "CF_1STDEST_ADDRESS2": "901 W ARBOR VITAE ST", "CP_DUB_SHIPFROM_ADD1": "PANASONIC AVIONICS CORP.", "C_SHIP_VIA": "FDX-Pri. Overnight", "CF_1STDEST_BILLCITYSTATEZIP": "INGLEWOOD, CA 90301", "WT_UOM_CODE": " ", "CP_DUB_SHIPFROM_ADD3": "STRUCTURES DEPARTMENT", "CF_ACTUAL_REP_TOTAL": 170, "CP_DUB_SHIPFROM_ADD2": "26111 ENTERPRISE WAY", "GROSS_WEIGHT": null, "FOB_CODE": "EXW", "CF_BILL_CUSTOMER": "VIETNAM AIRLINES", "CP_DUB_SHIPFROM_ADD4": "50590005", "CF_BILL_CITYSTATEZIP": "HANOI,  ", "C_NUM_BOXES": "1.818 KG / 1", "CF_ORG_CODE": "Panasonic Avionics Corporation", "CF_1STDEST_COUNTRY": "US", "WEIGHT_UOM_CODE": null, "CF_1STDEST_CUSTOMER": "EDDY ZHANG", "F_DELIVERY_NAME": "5405885", "CP_DUB_SHIPFROM_CITY_STATE": "LAKE FOREST, CA 92630-8400", "SHIP_VIA": "000001_FDX_A_PRI", "CF_ULTI_SHIP_ADDR3": null, "CF_BILL_ADDRESS1": "PASSENGER SERVICE DEPARTMENT, SERVICE COST MGT", "CF_BILL_ADDRESS2": "(HDQHHVN)", "CF_ULTI_SHIP_ADDR1": "414 NGUYEN VAN CU STR", "CF_BILL_ADDRESS3": "200 NGUYEN SON STREET", "CP_DUB_SHIPFROM_COUNTRY": "United States", "CF_ULTI_COUNTRY": "Viet Nam", "SHIP_DATE": "2020-03-18T14:10:56" }, "lines": [ { "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" },{ "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" },{ "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" },{ "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" },{ "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" },{ "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" },{ "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" },{ "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" },{ "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" },{ "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" },{ "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" },{ "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" },{ "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" },{ "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" },{ "CF_COUNTRY_OF_ORIGIN": "SG", "CF_UNIT_WEIGHT": null, "CF_ECCN": "EAR99", "SOURCE_UOM": "EA", "CF_ITEM_NAME": "CVNMCS01-0021", "CF_ATTR7": "CVNMCS01-0021", "CF_EL1_NEW": null, "C_ITEM_COST_FMT": 170, "CF_HARMONIZED1": "8471704065", "CF_EL2_NEW": null, "UNIT_OF_MEASURE": "EA", "C_ITEM_DISP": null, "C_EXT_COST_FMT": 170, "ORDER_NUM": "3740716", "CATEGORY": "DEFAULT", "NVL_WDD_SHIPPED_QUANTITY_WDD_R": 1, "SOURCE_CODE": "OE", "PO": "VN/PAC-06/2020" } ] }';
			JSONWrapperObj = (JSONWrapper)System.JSON.deserialize(json, JSONWrapper.class);
			headerObj = JSONWrapperObj.Header;
			totalRecords = JSONWrapperObj.lines.size();
			if (math.mod(totalRecords, recordPerPage) == 0){
				breakBeforLastPage = totalRecords - 1;
			}
			
			System.debug('JSONWrapperObj ==== ' + JSONWrapperObj);
			System.debug('lines ==== ' + JSONWrapperObj.lines);*/


		}
	}

	public class JSONWrapper{
		public HeaderWrapper Header{ get; set; }

		public LinesWapper[] lines{ get; set; }
	}

	public class HeaderWrapper{
		public String CF_ULT_SHIP_ADDR2{ get; set; }
		public String CF_ULTIMATE_SHIP_TO{ get; set; }
		public String CF_ULTI_BILLCITYSTATEZIP{ get; set; }
		public String CF_FREIGHT_TERMS_CODE{ get; set; }
		public Integer DELIVERY_ID{ get; set; }
		public String CF_WAYBILL{ get; set; }
		public String CF_1STDEST_CUSTOMER1{ get; set; }
		public String CURRENCY_CODE{ get; set; }
		public String CF_BILL_COUNTRY{ get; set; }
		public String CF_1STDEST_ADDRESS3{ get; set; }
		public String CPP_IMPORTED_FROM{ get; set; }
		public String CF_1STDEST_ADDRESS1{ get; set; }
		public String CF_1STDEST_ADDRESS2{ get; set; }
		public String CP_DUB_SHIPFROM_ADD1{ get; set; }
		public String C_SHIP_VIA{ get; set; }
		public String CF_1STDEST_BILLCITYSTATEZIP{ get; set; }
		public String WT_UOM_CODE{ get; set; }
		public String CP_DUB_SHIPFROM_ADD3{ get; set; }
		public Integer CF_ACTUAL_REP_TOTAL{ get; set; }
		public String CP_DUB_SHIPFROM_ADD2{ get; set; }
		public String GROSS_WEIGHT{ get; set; }
		public String FOB_CODE{ get; set; }
		public String CF_BILL_CUSTOMER{ get; set; }
		public String CP_DUB_SHIPFROM_ADD4{ get; set; }
		public String CF_BILL_CITYSTATEZIP{ get; set; }
		public String C_NUM_BOXES{ get; set; }
		public String CF_ORG_CODE{ get; set; }
		public String CF_1STDEST_COUNTRY{ get; set; }
		public String WEIGHT_UOM_CODE { get; set; }
		public String CF_1STDEST_CUSTOMER{ get; set; }
		public String F_DELIVERY_NAME{ get; set; }
		public String CP_DUB_SHIPFROM_CITY_STATE{ get; set; }
		public String SHIP_VIA{ get; set; }
		public String CF_ULTI_SHIP_ADDR3 { get; set; }
		public String CF_BILL_ADDRESS1{ get; set; }
		public String CF_BILL_ADDRESS2{ get; set; }
		public String CF_ULTI_SHIP_ADDR1{ get; set; }
		public String CF_BILL_ADDRESS3{ get; set; }
		public String CP_DUB_SHIPFROM_COUNTRY { get; set; }
		public String CF_ULTI_COUNTRY { get; set; }
		public String SHIP_DATE { get; set; }




		
	}

	public class LinesWapper{
		public String CF_COUNTRY_OF_ORIGIN{ get; set; }
		public String CF_UNIT_WEIGHT{ get; set; }
		public String CF_ECCN{ get; set; }
		public String SOURCE_UOM{ get; set; }
		public String CF_ITEM_NAME{ get; set; }
		public String CF_ATTR7{ get; set; }
		public String CF_EL1_NEW{ get; set; }
		public Integer C_ITEM_COST_FMT{ get; set; }
		public String CF_HARMONIZED1{ get; set; }
		public String CF_EL2_NEW { get; set; }
		public String UNIT_OF_MEASURE{ get; set; }
		public String C_ITEM_DISP{ get; set; }
		public Integer C_EXT_COST_FMT{ get; set; }
		public String ORDER_NUM{ get; set; }
		public String CATEGORY{ get; set; }
		public Integer NVL_WDD_SHIPPED_QUANTITY_WDD_R{ get; set; }
		public String SOURCE_CODE{ get; set; }
		public String PO{ get; set; }
		public String Program{ get; set; }
		public String Shipset{ get; set; }
		public String Tail{ get; set; }
		
	}
}