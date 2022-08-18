public class ife_CustomerInvoiceController{
	public JSONWrapper JSONWrapperObj{ get; set; }

	public Date todayDate{
		get{
			return Date.today();
		}
	}

	public HeaderWrapper headerObj{ get; set; }

	public String pageLogo{ get; set; }
	public String headerId{ get; set; }
	public String lineId{ get; set; }
	
	public String shopAddress{ get; set; }

	public String shopTeleFsx{ get; set; }

	public Integer totalRecords{ get; set; }

	public Integer breakBeforLastPage{ get; set; }
	public Boolean isDisplay {get;set;}

	public ife_CustomerInvoiceController(){
		headerId = ApexPages.currentPage().getParameters().get('id');
		lineId = ApexPages.currentPage().getParameters().get('lineId');
		JSONWrapperObj = new JSONWrapper();
		headerObj = new HeaderWrapper();
		pageLogo = '';
		shopAddress = '';
		shopTeleFsx = '';
		totalRecords = 0;
		breakBeforLastPage = 0;
		isDisplay = true;
	}

	public void getPageValue(){
		ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'invoiceReport'
		                                          LIMIT 1];
		System.debug('integrationMdtObj.URL__c ==== ' + integrationMdtObj.URL__c);
		try{

			Http http = new Http();
			HttpRequest request = new HttpRequest();
			System.debug('headerId---------' + headerId);
			System.debug('lineId---------' + lineId);
			request.setEndpoint(integrationMdtObj.URL__c + 'myIfeInvoiceReport?orderNumber='+headerId+'&orderLineId='+lineId+'&orderSource=RAMCO');
			
			request.setMethod('GET');
			request.setHeader('client_id', integrationMdtObj.Client_Id__c);
			request.setHeader('client_secret', integrationMdtObj.Client_Secret__c);
			request.setHeader('Accept', '*/*');
			request.setHeader('Connection', 'keep-alive');
			request.setHeader('Content-Type', 'application/json');
			request.setTimeout(120000);
			HttpResponse response = http.send(request);
			System.debug('getBody ==== ' + response.getBody());
			JSONWrapperObj = (JSONWrapper)System.JSON.deserialize(response.getBody(), JSONWrapper.class);
			headerObj = JSONWrapperObj.Header;
			totalRecords = JSONWrapperObj.lines.size();
			if (math.mod(totalRecords, 6) == 0){
				breakBeforLastPage = totalRecords - 2;
			}
			if (math.mod(totalRecords, 6) == 5){
				breakBeforLastPage = totalRecords - 1;
			}
			if (headerObj.CF_CUSTTRXTYPE_ID == 1299 || headerObj.CF_CUSTTRXTYPE_ID == 1300){
				pageLogo = 'Panasonic Transportation Systems Company';
				shopAddress = 'Division of Panasonic Avionics Corporation 121 Whittendale Drive, Building';
				shopTeleFsx = 'Telephone: (856) 866-8720 Fax: (856) 866-8743';
			} else{
				pageLogo = 'Panasonic Avionics Corporation';
				shopTeleFsx = 'Telephone: (425) 415-9000 Fax: (425) 487-0776';
			}

		} catch (Exception e){
			System.debug('e---------' + e);
			isDisplay = false;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,''+e));
			/*String json = '{"Header": { "CP_INCIDENT_NUM": null, "CUSTOMER_NUMBER": "4908", "CF_WAYBILL": "422761171447", "ORDER_NUMBER": "3740716", "TRX_TYPE_NAME": null, "REPORT_ALL_AMOUNT": 19000, "LINE_ID": "13737750", "C_BILL_TO_CONCATENATED": "Attn: Accounts Payable VIETNAM AIRLINES PASSENGER SERVICE DEPARTMENT, SERVICE COST MGT (HDQHHVN) 200 NGUYEN SON STREET LONG BIEN DISTRICT HANOI Viet Nam", "CP_FREIGHT_CODE": "Bill Third Party", "INVOICE_CURRENCY_CODE": "USD", "CP_PROGRAM_NUMBER": "CVNMCS01ME", "CP_TAIL_NUMBER": null, "CF_DATABASE": "PLMTST", "PURCHASE_ORDER_NUMBER": "VN/PAC-06/2020", "CP_SHIP_TO_CONCATENATED": "VAN ANH VIETNAM AIRLINES 414 NGUYEN VAN CU STR LONG BIEN DISTRICT HANOI Viet Nam", "SHIP_VIA_DESCRIPTION": "Fedex - Domestic Services", "CF_INCIDENT_ITEM": null, "H_ORDER_TYPE_ID": 1857, "REPORT_ITEM_AMOUNT": 19000, "BILL_TO_ATTN": null, "REPORT_TAX_AMOUNT": 0, "CP_LOT_OR_SERIAL_NO": null, "REPORT_FREIGHT_AMOUNT": 0, "TRX_DATE": "18-MAR-20", "CF_CUSTTRXTYPE_ID": 13001, "CF_DELIVERY_NUMBER": "972337241", "INV_SALES_ORDER": 3740716, "TERM_NAME": "30 NET -a", "CP_REMIT_TO_CONCATENATED": "Panasonic Avionics Corporation n P.O. Box 894503 LOS ANGELES CA 90189-4503 United States", "TRX_NUMBER": "14953089", "CF_LOCATION": null, "SHIP_VIA": "FDX", "SHIP_DATE_ACTUAL": "18-MAR-2020" }, "lines": [ { "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": " CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 } ] }';
			JSONWrapperObj = (JSONWrapper)System.JSON.deserialize(json, JSONWrapper.class);
			headerObj = JSONWrapperObj.Header;
			totalRecords = JSONWrapperObj.lines.size();
			if (math.mod(totalRecords, 6) == 0){
				breakBeforLastPage = totalRecords - 2;
			}
			if (math.mod(totalRecords, 6) == 5){
				breakBeforLastPage = totalRecords - 1;
			}
			if (headerObj.CF_CUSTTRXTYPE_ID == 1299 || headerObj.CF_CUSTTRXTYPE_ID == 1300){
				pageLogo = 'Panasonic Transportation Systems Company';
				shopAddress = 'Division of Panasonic Avionics Corporation 121 Whittendale Drive, Building';
				shopTeleFsx = 'Telephone: (856) 866-8720 Fax: (856) 866-8743';
			} else{
				pageLogo = 'Panasonic Avionics Corporation';
				shopTeleFsx = 'Telephone: (425) 415-9000 Fax: (425) 487-0776';
			}*/


		}
	}

	public class JSONWrapper{
		public HeaderWrapper Header{ get; set; }

		public LinesWapper[] lines{ get; set; }
	}
	public class HeaderWrapper{
		public String CP_INCIDENT_NUM{ get; set; }

		public String CUSTOMER_NUMBER{ get; set; }

		public String CF_WAYBILL{ get; set; }

		public String ORDER_NUMBER{ get; set; }

		public String TRX_TYPE_NAME{ get; set; }

		public Integer REPORT_ALL_AMOUNT{ get; set; }

		public String LINE_ID{ get; set; }

		public String C_BILL_TO_CONCATENATED{ get; set; }

		public String INVOICE_CURRENCY_CODE{ get; set; }

		public String CP_PROGRAM_NUMBER{ get; set; }

		public String CP_TAIL_NUMBER{ get; set; }

		public String CF_DATABASE{ get; set; }

		public String PURCHASE_ORDER_NUMBER{ get; set; }

		public String CP_SHIP_TO_CONCATENATED{ get; set; }

		public String SHIP_VIA_DESCRIPTION{ get; set; }

		public String CF_INCIDENT_ITEM{ get; set; }

		public Integer H_ORDER_TYPE_ID{ get; set; }

		public Integer REPORT_ITEM_AMOUNT{ get; set; }

		public String BILL_TO_ATTN{ get; set; }

		public Integer REPORT_TAX_AMOUNT{ get; set; }

		public String CP_LOT_OR_SERIAL_NO{ get; set; }

		public Integer REPORT_FREIGHT_AMOUNT{ get; set; }

		public String TRX_DATE{ get; set; }

		public Integer CF_CUSTTRXTYPE_ID{ get; set; }

		public String CF_DELIVERY_NUMBER{ get; set; }

		public Integer INV_SALES_ORDER{ get; set; }

		public String TERM_NAME{ get; set; }

		public String CP_REMIT_TO_CONCATENATED{ get; set; }

		public String TRX_NUMBER{ get; set; }

		public String CF_LOCATION{ get; set; }

		public String SHIP_VIA{ get; set; }

		public String SHIP_DATE_ACTUAL{ get; set; }

		public String CP_FREIGHT_CODE{ get; set; }
	}

	public class LinesWapper{
		public String PO_LINE_REF{ get; set; }

		public String LINE_UOM{ get; set; }

		public Integer LINE_NUMBER{ get; set; }

		public String LINE_TYPE{ get; set; }

		public String ORDER_NUMBER{ get; set; }

		public String LINE_ITEM_DESCRIPTION{ get; set; }

		public String ORD_COMMENTS{ get; set; }

		public Integer LINE_QTY_ORDERED{ get; set; }

		public Integer LINE_EXTENDED_AMOUNT{ get; set; }

		public Integer LINE_ID{ get; set; }

		public Integer LINE_UNIT_SELLING_PRICE{ get; set; }
	}
}