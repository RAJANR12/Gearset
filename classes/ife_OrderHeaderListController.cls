public class ife_OrderHeaderListController{
	public ife_OrderHeaderListController(){
	}

	@AuraEnabled(cacheable = true)
	public static String getMYIFEorderHeader(){
		FieldSetWrapper fieldsWrapper = new FieldSetWrapper();
		List<Schema.FieldSetMember> getFields = SObjectType.myIfeOrderHeaders__x.FieldSets.MYIFE_OrderHeaderFields.getFields();
		String query = 'SELECT ';
		for (Schema.FieldSetMember f : getFields){
			query += f.getFieldPath()+', ';
		}
		query += 'Id FROM myIfeOrderHeaders__x LIMIT 20';
		System.debug('***query===>>> ' + query);
		System.debug('*** Database.query(query)===>>> ' + Database.query(query));
		List<myIfeOrderHeaders__x> mYIFEorderHeader = Database.query(query);
		System.debug('***erpOrderStatus===>>> ' + mYIFEorderHeader);
		fieldsWrapper.mYIFEorderHeaderList.addAll(mYIFEorderHeader);
		fieldsWrapper.headerFields.addAll(getFields);
		return JSON.serialize(fieldsWrapper);
	}

	@AuraEnabled(cacheable = true)
	public static OrderHeaderAndOrderLinesWrapper getMYIForderHeaderDetails(String orderHeaderId, Boolean isExternalPage){
		OrderHeaderAndOrderLinesWrapper orderHeaderAndLinesWrapperObj = new OrderHeaderAndOrderLinesWrapper();
		System.debug('orderHeaderId---' + orderHeaderId);
		myIfeOrderHeaders__x orderHeaderObj;
		if (Test.isRunningTest()){

			orderHeaderObj = ife_OrderHeaderListCtrlMockRecords.getRecords();
			System.debug('OrderHeaderObj>>>' + OrderHeaderObj);

		} else{
			if (isExternalPage){
				String customerId = getCurrentUser();
				if (customerId != null){
					System.debug('customerId---' + customerId);
					try{
						orderHeaderObj = [SELECT Id, HEADER_ID__c, ORDER_NUMBER__c, CUSTOMER_NAME__c, CUSTOMER_PO__c, ORDERED_DATE__c, STATUS__c, PROGRAM_NUMBER__c, SALES_ADMIN__c, SPECIAL_QA_INSP__c, SHIPSET__c, FREIGHT_TERMS__c, SHIPMENT_PRIORITY__c, INCO_TERMS__c, BILL_TO__c, PAYMENT_TERMS__c, PRICE_LIST_NAME__c, TOTAL__c
						                  FROM myIfeOrderHeaders__x
						                  WHERE CUSTOMER_ID__c = :customerId AND WEB_ORDER__c = :orderHeaderId  LIMIT 1];
						System.debug('orderHeaderObj test----' + orderHeaderObj);
					} Catch (Exception e){
						
						system.debug('Exception----- ' + e);
						//throw new DMLException('My DML EXCEPTION');
						return null;
					}
				}

			} else{
				orderHeaderObj = [SELECT Id, HEADER_ID__c, ORDER_NUMBER__c, CUSTOMER_NAME__c, CUSTOMER_PO__c, ORDERED_DATE__c, STATUS__c, PROGRAM_NUMBER__c, SALES_ADMIN__c, SPECIAL_QA_INSP__c, SHIPSET__c, FREIGHT_TERMS__c, SHIPMENT_PRIORITY__c, INCO_TERMS__c, BILL_TO__c, PAYMENT_TERMS__c, PRICE_LIST_NAME__c, TOTAL__c
				                  FROM myIfeOrderHeaders__x
				                  WHERE Id = :orderHeaderId  LIMIT 1];
			}
		}

		System.debug('orderHeaderObj---' + orderHeaderObj);

		List<myIfeOrderLines__x> orderLines = [SELECT Id, HEADER_ID__c, LINE_NUMBER__c, ITEM__c, ITEM_DESCRIPTION__c, ORDERED_QUANTITY__c, UOM__c, UNIT_SELLING_PRICE__c, EXTENDED_PRICE__c, CUSTOMER_PO_LINE__c, INSTALL_LOCATION__c, STATUS__c, WAREHOUSE__c, SCHEDULE_SHIP_DATE__c, LINE_ID__c, FULFILLED_QUANTITY__c, DELIVERY_ID__c, SALES_ORDER__c
		                                       FROM myIfeOrderLines__x
		                                       WHERE HEADER_ID__c = :orderHeaderObj.HEADER_ID__c];
		orderHeaderAndLinesWrapperObj.orderHeaderObj = orderHeaderObj;
		orderHeaderAndLinesWrapperObj.orderLineList = orderLines;
		System.debug('orderHeaderAndLinesWrapperObj>>>' + orderHeaderAndLinesWrapperObj);

		return orderHeaderAndLinesWrapperObj;
	}

	public static String getCurrentUser(){
		User userObj = [SELECT Id, Name, Contact.AccountId, Contact.Account.L2I_Customer_ID__c
		                FROM User
		                WHERE Id = :UserInfo.getUserId()];
		if (userObj.Contact.AccountId != null){
			System.debug('Contact.Account.L2I_Customer_ID__c-----' + userObj.Contact.Account.L2I_Customer_ID__c);
			return userObj.Contact.Account.L2I_Customer_ID__c;
		}
		return null;
	}

	@AuraEnabled(cacheable = true)
	public static List<String> getMYIFE_OrderHeaderDetailsFields(){
		List<String> detailsFields = new List<String>();
		for (Schema.FieldSetMember field : SObjectType.myIfeOrderHeaders__x.FieldSets.MYIFE_OrderHeaderDetailsFields.getFields()){
			detailsFields.add(field.getFieldPath());
		}
		System.debug('detailsFields==== ' + detailsFields);
		return detailsFields;
	}

	@AuraEnabled(cacheable = true)
	public static List<myIfeOrderLines__x> getMYIFE_OrderLines(String orderHeaderId){
		List<myIfeOrderLines__x> orderLines = [SELECT ORDERED_QUANTITY__c, WAREHOUSE__c, Id, CurrencyIsoCode, ExternalId, DisplayUrl, EXTENDED_PRICE__c, HEADER_ID__c, ITEM_DESCRIPTION__c, LINE_ID__c, LINE_NUMBER__c, ITEM__c, UOM__c, SCHEDULE_SHIP_DATE__c, UNIT_SELLING_PRICE__c, DELIVERY_ID__c
		                                       FROM myIfeOrderLines__x
		                                       LIMIT 5];
		System.debug('orderLines>>>' + orderLines);
		return orderLines;
	}

	public class FieldSetWrapper{
		@AuraEnabled
		public List<myIfeOrderHeaders__x> mYIFEorderHeaderList{ get; set; }

		@AuraEnabled
		public List<Schema.FieldSetMember> headerFields{ get; set; }

		public FieldSetWrapper(){
			mYIFEorderHeaderList = new List<myIfeOrderHeaders__x>();
			headerFields = new List<Schema.FieldSetMember>();
		}
	}

	public class OrderHeaderAndOrderLinesWrapper{
		@AuraEnabled
		public myIfeOrderHeaders__x orderHeaderObj{ get; set; }

		@AuraEnabled
		public List<myIfeOrderLines__x> orderLineList{ get; set; }

		public OrderHeaderAndOrderLinesWrapper(){
			orderHeaderObj = new myIfeOrderHeaders__x();
			orderLineList = new List<myIfeOrderLines__x>();
		}
	}
}