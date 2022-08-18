public without sharing class L2I_SalesOrderSearchController{
	public L2I_SalesOrderSearchController(){
	}

	@AuraEnabled
	public static List<myIfeOrderHeaders__x> downloadCSV(String salesOrderNumber, String customerPo, String eCommerceNumber, String programNumber, String shipToCustomerName, String tailNumber, String selectedCustomerId, String orderStatusSerach, String orderCustomerName, Integer offset, Integer limits){
		System.debug('offset --- ' + offset);
		System.debug('limits --- ' + limits);

		System.debug('selectedCustomerId --- ' + selectedCustomerId);
		String whereClause = '';
		Integer queryLimit = 5;
		if (String.isNotBlank(selectedCustomerId)){
			Account accObj = [SELECT Id
			                  FROM Account
			                  WHERE L2I_Customer_ID__c = :selectedCustomerId
			                  LIMIT 1];
			Map<String, String> accountIdWithRelationshipTypeMap = getRelatedAccount(accObj.Id, false);
			//searchDatawrapperObj.shipToCustomerName = getShipToCustomerName(accountIdWithRelationshipTypeMap.keySet());

			if (whereClause != ''){
				whereClause += ' AND CUSTOMER_ID__c =: selectedCustomerId';
			} else{
				whereClause = ' CUSTOMER_ID__c =: selectedCustomerId';
			}
		}

		if (String.isNotBlank(salesOrderNumber)){
			queryLimit = 2000;
			if (whereClause != ''){
				whereClause += ' AND SALES_ORDER__c =: salesOrderNumber';
			} else{
				whereClause = ' SALES_ORDER__c =: salesOrderNumber';
			}
		}

		if (String.isNotBlank(customerPo)){
			queryLimit = 2000;
			if (whereClause != ''){
				whereClause += ' AND CUSTOMER_PO__c =: customerPo';
			} else{
				whereClause = ' CUSTOMER_PO__c =: customerPo';
			}
		}

		if (String.isNotBlank(programNumber)){
			queryLimit = 2000;
			if (whereClause != ''){
				whereClause += ' AND PROGRAM_NUMBER__c =: programNumber';
			} else{
				whereClause = ' PROGRAM_NUMBER__c =: programNumber';
			}
		}

		if (String.isNotBlank(shipToCustomerName)){
			queryLimit = 2000;
			if (whereClause != ''){
				whereClause += ' AND SHIP_TO_CUSTOMER_NAME__c=: shipToCustomerName';
			} else{
				whereClause = ' SHIP_TO_CUSTOMER_NAME__c=: shipToCustomerName';
			}
		}

		if (String.isNotBlank(tailNumber)){
			queryLimit = 2000;
			if (whereClause != null){
				whereClause += ' AND TAIL_NUMBER__c=: tailNumber';
			} else{
				whereClause = ' TAIL_NUMBER__c=: tailNumber';
			}
		}

		if (String.isNotBlank(orderStatusSerach)){
			queryLimit = 2000;
			if (whereClause != null){
				whereClause += ' AND STATUS__c=: orderStatusSerach';
			} else{
				whereClause = ' STATUS__c=: orderStatusSerach';
			}
		}
		if (String.isNotBlank(orderCustomerName)){
			queryLimit = 2000;
			if (whereClause != null){
				whereClause += ' AND CUSTOMER_NAME__c=: orderCustomerName';
			} else{
				whereClause = ' CUSTOMER_NAME__c=: orderCustomerName';
			}
		}
        if (String.isNotBlank(eCommerceNumber)){
			queryLimit = 2000;
			if (whereClause != null){
				whereClause += ' AND WEB_ORDER__c =: eCommerceNumber';
			} else{
				whereClause = ' WEB_ORDER__c =: eCommerceNumber';
			}
		}

		System.debug('whereClause--- ' + whereClause);
		String stringQuery = 'SELECT SALES_ORDER__c, CUSTOMER_PO__c, WEB_ORDER__c, ORDER_TYPE__c, ORDERED_DATE__c, STATUS__c, CUSTOMER_NAME__c,SHIP_TO_CUSTOMER_NAME__c, HEADER_ID__c, Id  FROM myIfeOrderHeaders__x WHERE ' + whereClause + ' ORDER BY ORDERED_DATE__c  DESC LIMIT ' + limits + ' offset ' + offset;
		//String stringQuery = 'SELECT SALES_ORDER__c,CUSTOMER_PO__c, ORDER_TYPE__c, ORDERED_DATE__c, STATUS__c, CUSTOMER_NAME__c,SHIP_TO_CUSTOMER_NAME__c, HEADER_ID__c, Id FROM myIfeOrderHeaders__x WHERE ' + whereClause + ' ORDER BY ORDERED_DATE__c  DESC LIMIT 2000';
		System.debug('stringQuery--- ' + stringQuery);
		List<myIfeOrderHeaders__x> MYIFEorderHeaders = Database.query(stringQuery);
		System.debug('stringQuery--- ' + stringQuery);
		System.debug('MYIFEorderHeaders--- ' + MYIFEorderHeaders);
		/*List<myIfeOrderHeaders__x> MYIFEorderHeaders = [SELECT SHIP_TO_CUSTOMER_NAME__c, SALES_ORDER__c, CUSTOMER_PO__c, ORDER_TYPE__c, ORDERED_DATE__c, HEADER_ID__c, STATUS__c, CUSTOMER_NAME__c, Id
		                                                FROM myIfeOrderHeaders__x
		                                                ORDER BY ORDERED_DATE__c DESC
		                                                LIMIT 2000];
		System.debug('MYIFEorderHeaders size  ' + MYIFEorderHeaders.size());*/

		return MYIFEorderHeaders;
	}

	@AuraEnabled
	public static StatusByCustomerPoWrapper getSearchERPOrderStatusByCustomerPO(String headerId){
		System.System.debug('customerPo---- ' + headerId);
		StatusByCustomerPoWrapper wrapperObj = new StatusByCustomerPoWrapper();
		List<myIfeOrderHeaders__x> myIfeOrderHeaders = [SELECT ORDER_TYPE__c, Customer_PO__c, HEADER_ID__c, WEB_ORDER__c
		                                                FROM myIfeOrderHeaders__x
		                                                WHERE HEADER_ID__c = :headerId
		                                                LIMIT 1];
		System.System.debug('myIfeOrderHeaders.HEADER_ID__c---- ' + headerId);

		List<myIfeDeliveries__x> myIfeDeliveries = [SELECT ACTUAL_SHIP_DATE__c, SHIP_TO_LOCATION__c, SHIP_FROM__c, WAYBILL__c
		                                            FROM myIfeDeliveries__x
		                                            WHERE ORDER_HEADER_ID__c = :headerId
		                                            LIMIT 1];

		List<myIfeOrderLines__x> myIfeOrderLines = [SELECT SALES_ORDER__c, LINE_NUMBER__c, ITEM__c, ITEM_DESCRIPTION__c, ORDERED_QUANTITY__c, UOM__c, FULFILLED_QUANTITY__c, UNIT_SELLING_PRICE__c, EXTENDED_PRICE__c, STATUS__c, SCHEDULE_SHIP_DATE__c, DELIVERY_ID__c
		                                            FROM myIfeOrderLines__x
		                                            WHERE HEADER_ID__c = :headerId];
		System.System.debug('myIfeOrderHeaders---- ' + myIfeOrderHeaders);
		System.System.debug('myIfeDeliveries---- ' + myIfeDeliveries);
		System.System.debug('myIfeOrderLines---- ' + myIfeOrderLines);
		if (!myIfeOrderHeaders.isEmpty()){
			wrapperObj.myIfeOrderHeader = myIfeOrderHeaders[0];
		}
		if (!myIfeDeliveries.isEmpty()){
			wrapperObj.myIfeDeliverie = myIfeDeliveries[0];
		}
		wrapperObj.myIfeOrderLines = myIfeOrderLines;
		return wrapperObj;
	}

	public class StatusByCustomerPoWrapper{
		@AuraEnabled
		public myIfeOrderHeaders__x myIfeOrderHeader{ get; set; }

		@AuraEnabled
		public myIfeDeliveries__x myIfeDeliverie{ get; set; }

		@AuraEnabled
		public List<myIfeOrderLines__x> myIfeOrderLines{ get; set; }

		public StatusByCustomerPoWrapper(){
			myIfeOrderHeader = new myIfeOrderHeaders__x();
			myIfeDeliverie = new myIfeDeliveries__x();
			myIfeOrderLines = new List<myIfeOrderLines__x>();
		}
	}

	@AuraEnabled
	public static List<myIfeOrderHeaders__x> getERPOrderStatusForAccount(String selectedCustomerId){

		System.debug('accountObj=== ' + selectedCustomerId);
		List<myIfeOrderHeaders__x> MYIFEorderHeaders = [SELECT SALES_ORDER__c, CUSTOMER_PO__c, ORDER_TYPE__c, ORDERED_DATE__c, HEADER_ID__c, Status__c, CUSTOMER_NAME__c, Id, WEB_ORDER__c 
		                                                FROM myIfeOrderHeaders__x
		                                                WHERE CUSTOMER_ID__c = :selectedCustomerId
		                                                LIMIT 20];
		System.debug('MYIFEorderHeaders=== ' + MYIFEorderHeaders);
		return MYIFEorderHeaders;
	}

	@AuraEnabled
	public static Datawrapper getERPOrderStatus(){
		Datawrapper datawrapperObj = new Datawrapper();
		User userObj = [SELECT Id, Name, Contact.AccountId, Contact.Account.L2I_Customer_ID__c
		                FROM User
		                WHERE Id = :UserInfo.getUserId()];
		System.debug('User Information ===>' + UserInfo.getUserId());
		System.debug('Contact.AccountId ===>' + userObj.Contact.AccountId);
		if (userObj.Contact.AccountId != null){
			Map<String, String> accountIdWithRelationshipTypeMap = getRelatedAccount(userObj.Contact.AccountId, true);
			//Set<String> accountIds = new Set<String>{userObj.Contact.AccountId};
			Set<String> accountIdsForShipToCustomerName = new Set<String>();

			/*for (L2I_Related_Account__c relatedAccount : [SELECT Id, Related_To__c, Relationship_Type__c
			 FROM L2I_Related_Account__c
			 WHERE Account__c = :userObj.Contact.AccountId]){
			 accountIds.add(relatedAccount.Related_To__c);
			 if (relatedAccount.Relationship_Type__c == 'Ship To'){
			 accountIdsForShipToCustomerName.add(relatedAccount.Related_To__c);

			 }
			 }*/
			for (String key : accountIdWithRelationshipTypeMap.keySet()){
				if (accountIdWithRelationshipTypeMap.get(key) == 'Ship To'){
					accountIdsForShipToCustomerName.add(key);
				}

			}
			List<Account> accounts = [SELECT Id, Name, L2I_Customer_ID__c
			                          FROM Account
			                          WHERE Id = :accountIdWithRelationshipTypeMap.keySet() AND L2I_Customer_ID__c != null];
			accounts.sort();
			System.debug('Get Accounts ---> ' + accounts.ToString());
			datawrapperObj.selectedAccount = userObj.Contact.Account.L2I_Customer_ID__c;
			datawrapperObj.MYIFEorderHeaders = getSearchERPOrderQuery(userObj.Contact.Account.L2I_Customer_ID__c);
			datawrapperObj.accounts = accounts;
			datawrapperObj.shipToCustomerName = getShipToCustomerName(accountIdsForShipToCustomerName);
			//datawrapperObj.shipToCustomerName = getShipToCustomerNameByCountactAccountId(userObj.Contact.AccountId);
			//datawrapperObj.shipToCustomerName = getRelatedAccount_1(userObj.Contact.AccountId,true);
			//datawrapperObj.shipToCustomerName = getShipToCustomerList(userObj.Contact.AccountId);
			datawrapperObj.userObjContactAccountId = userObj.Contact.AccountId;
		} else{
			/*
			List<Account> accounts = [SELECT Id, Name, L2I_Customer_ID__c
			                          FROM Account
			                          WHERE L2I_Customer_ID__c != null];
			accounts.sort();
			datawrapperObj.selectedAccount = accounts[0].L2I_Customer_ID__c;
			datawrapperObj.MYIFEorderHeaders = getSearchERPOrderQuery(accounts[0].L2I_Customer_ID__c);
			datawrapperObj.accounts = accounts;*/
			// datawrapperObj.shipToCustomerName = getShipToCustomerName(new Set<String>());


		}

        System.debug('datawrapperObj>>>'+datawrapperObj);
		return datawrapperObj;
	}

	public static Map<String, String> getRelatedAccount(String accountId, Boolean isAccount){
		Map<String, String> accountIdWithRelationshipTypeMap = new Map<String, String>();

		accountIdWithRelationshipTypeMap.put(accountId, 'Ship To');
		for (L2I_Related_Account__c relatedAccount : [SELECT Id, Related_To__c, Relationship_Type__c
		                                              FROM L2I_Related_Account__c
		                                              WHERE Account__c = :accountId]){

			if (relatedAccount.Relationship_Type__c == 'Ship To'){
				accountIdWithRelationshipTypeMap.put(relatedAccount.Related_To__c, 'Ship To');

			} else{
				if (isAccount){
					accountIdWithRelationshipTypeMap.put(relatedAccount.Related_To__c, '');
				}
			}
		}
        System.debug('accountIdWithRelationshipTypeMap>>'+accountIdWithRelationshipTypeMap);
		return accountIdWithRelationshipTypeMap;
	}
	
	public static Set<String> getRelatedAccount_1(String accountId, Boolean isAccount){
		Set<String> accountIds = new Set<String>();
		Set<String> accountNames = new Set<String>();
		if (String.isNotBlank(accountId)){
			accountIds.add(accountId);
			for (L2I_Related_Account__c relatedAccount : [SELECT Id, Related_To__c, Relationship_Type__c
			                                              FROM L2I_Related_Account__c
			                                              WHERE Account__c = :accountId]){
				if (relatedAccount.Related_To__c == 'Ship To'){
					accountIds.add(relatedAccount.Related_To__c);
				}
			}
		}
		if (!accountIds.isEmpty()){
			for (Account account : [SELECT Id, Name, L2I_Customer_ID__c
			                          FROM Account
			                          WHERE Id = :accountIds AND L2I_Customer_ID__c != null])
			{
				accountNames.Add(account.Name);
			} 
		}
		return accountNames;
	}
	
	public static Set<String> getShipToCustomerNameByCountactAccountId(String accountId){
		Set<String> shipToAccounts = new Set<String>();
		shipToAccounts.Add(accountId);
		for (L2I_Related_Account__c relatedAccount : [SELECT Id, Related_To__c, Relationship_Type__c
		                                              FROM L2I_Related_Account__c
		                                              WHERE Account__c = :accountId and Relationship_Type__c = 'Ship To']){
            shipToAccounts.Add(relatedAccount.Related_To__c);
		}
		Set<String> shipToCustomerName = getShipToCustomerName(shipToAccounts);
		return shipToCustomerName;
	}

	public static List<myIfeOrderHeaders__x> getSearchERPOrderQuery(String accountCustomerId){
		System.debug('accountCustomerId ==== ' + accountCustomerId);
		List<myIfeOrderHeaders__x> MYIFEorderHeaders = [SELECT SHIP_TO_CUSTOMER_NAME__c, SALES_ORDER__c, CUSTOMER_PO__c, ORDER_TYPE__c, ORDERED_DATE__c, HEADER_ID__c, STATUS__c, CUSTOMER_NAME__c, Id, WEB_ORDER__c
		                                                FROM myIfeOrderHeaders__x
		                                                WHERE CUSTOMER_ID__c = :accountCustomerId
		                                                ORDER BY ORDERED_DATE__c DESC
		                                                LIMIT 5];

		return MYIFEorderHeaders;
	}

	public static Set<String> getShipToCustomerName(Set<String> accountCustomerId){


		System.debug('**accountCustomerId ==== ' + accountCustomerId);
		Set<String> shipToCustomerNames = new Set<String>();
		if (!accountCustomerId.isEmpty()){
			for (AggregateResult accObj : [SELECT Name
			                               FROM Account
			                               WHERE Id = :accountCustomerId
			                               GROUP BY Name]){
				shipToCustomerNames.add(String.valueof(accObj.get('Name')));
			}
		}
		/*else{
		 Set<String> ids = new Set<String>();
		 for(L2I_Related_Account__c  relatedAccount :[SELECT Id, Related_To__c ,Relationship_Type__c
		 FROM L2I_Related_Account__c
		 WHERE Relationship_Type__c = 'Ship To'])
		 {
		 ids.add(relatedAccount.Related_To__c);
		 }

		 for(AggregateResult accObj : [SELECT Name FROM Account WHERE Id =:ids GROUP BY Name])
		 {
		 shipToCustomerNames.add(String.valueof(accObj.get('Name')));
		 }
		 }*/
		System.debug('shipToCustomerNames ==== ' + shipToCustomerNames);
		return shipToCustomerNames;
	}

	
	@AuraEnabled
	public static SearchDatawrapper getSearchERPOrderStatus(String salesOrderNumber, String eCommerceNumber, String customerPo, String programNumber, String shipToCustomerName, String tailNumber, String selectedCustomerId, String orderStatusSerach, String orderCustomerName, Integer offset, Integer limits){
		SearchDatawrapper searchDatawrapperObj = new SearchDatawrapper();
		System.debug('offset --- ' + offset);
		System.debug('limits --- ' + limits);

		System.debug('selectedCustomerId --- ' + selectedCustomerId);
		String whereClause = '';
		Integer queryLimit = 5;
		if (String.isNotBlank(selectedCustomerId)){
			Account accObj = [SELECT Id
			                  FROM Account
			                  WHERE L2I_Customer_ID__c = :selectedCustomerId
			                  LIMIT 1];
			Map<String, String> accountIdWithRelationshipTypeMap = getRelatedAccount(accObj.Id, false);
			searchDatawrapperObj.shipToCustomerName = getShipToCustomerName(accountIdWithRelationshipTypeMap.keySet());

			if (whereClause != ''){
				whereClause += ' AND CUSTOMER_ID__c =: selectedCustomerId';
			} else{
				whereClause = ' CUSTOMER_ID__c =: selectedCustomerId';
			}
		}

		if (String.isNotBlank(salesOrderNumber)){
			queryLimit = 2000;
			if (whereClause != ''){
				whereClause += ' AND SALES_ORDER__c =: salesOrderNumber';
			} else{
				whereClause = ' SALES_ORDER__c =: salesOrderNumber';
			}
		}

		if (String.isNotBlank(customerPo)){
			queryLimit = 2000;
			if (whereClause != ''){
				whereClause += ' AND CUSTOMER_PO__c =: customerPo';
			} else{
				whereClause = ' CUSTOMER_PO__c =: customerPo';
			}
		}

		if (String.isNotBlank(programNumber)){
			queryLimit = 2000;
			if (whereClause != ''){
				whereClause += ' AND PROGRAM_NUMBER__c =: programNumber';
			} else{
				whereClause = ' PROGRAM_NUMBER__c =: programNumber';
			}
		}

		if (String.isNotBlank(shipToCustomerName)){
			queryLimit = 2000;
			if (whereClause != ''){
				whereClause += ' AND SHIP_TO_CUSTOMER_NAME__c=: shipToCustomerName';
			} else{
				whereClause = ' SHIP_TO_CUSTOMER_NAME__c=: shipToCustomerName';
			}
		}

		if (String.isNotBlank(tailNumber)){
			queryLimit = 2000;
			if (whereClause != null){
				whereClause += ' AND TAIL_NUMBER__c=: tailNumber';
			} else{
				whereClause = ' TAIL_NUMBER__c=: tailNumber';
			}
		}

		if (String.isNotBlank(orderStatusSerach)){
			queryLimit = 2000;
			if (whereClause != null){
				whereClause += ' AND STATUS__c=: orderStatusSerach';
			} else{
				whereClause = ' STATUS__c=: orderStatusSerach';
			}
		}
		if (String.isNotBlank(orderCustomerName)){
			queryLimit = 2000;
			if (whereClause != null){
				whereClause += ' AND CUSTOMER_NAME__c=: orderCustomerName';
			} else{
				whereClause = ' CUSTOMER_NAME__c=: orderCustomerName';
			}
		}
        if (String.isNotBlank(eCommerceNumber)){
			queryLimit = 2000;
			if (whereClause != null){
				whereClause += ' AND WEB_ORDER__c=: eCommerceNumber';
			} else{
				whereClause = ' WEB_ORDER__c=: eCommerceNumber';
			}
		}

		System.debug('whereClause--- ' + whereClause);
		String stringQuery = 'SELECT SALES_ORDER__c, WEB_ORDER__c, CUSTOMER_PO__c, ORDER_TYPE__c, ORDERED_DATE__c, STATUS__c, CUSTOMER_NAME__c,SHIP_TO_CUSTOMER_NAME__c, HEADER_ID__c, Id FROM myIfeOrderHeaders__x WHERE ' + whereClause + ' AND ORDER_TYPE__c != \'Invoice Only Order\' ORDER BY ORDERED_DATE__c  DESC LIMIT ' + limits + ' offset ' + offset;
		System.debug('stringQuery--- ' + stringQuery);
		List<myIfeOrderHeaders__x> MYIFEorderHeaders = Database.query(stringQuery);
		System.debug('stringQuery--- ' + stringQuery);
		System.debug('MYIFEorderHeaders--- ' + MYIFEorderHeaders);
		searchDatawrapperObj.MYIFEorderHeaders = MYIFEorderHeaders;
		return searchDatawrapperObj;
	}

    @AuraEnabled
	public static string getUserInfo()
	{
         User userObj = [SELECT Id, Name, Contact.AccountId, Contact.Account.L2I_Customer_ID__c
		                FROM User
		                WHERE Id = :UserInfo.getUserId()];
		  return userObj.Contact.AccountId;
	}
	
	public static Set<String> getShipToCustomerList(string accountId)
	{
        Map<String, String> accountIdWithRelationshipTypeMap = getRelatedAccount(accountId, true);
        Set<String> accountIds = new Set<String>{accountId};
        Set<String> accountIdsForShipToCustomerName = new Set<String>();
        for (String key : accountIdWithRelationshipTypeMap.keySet()){
            if (accountIdWithRelationshipTypeMap.get(key) == 'Ship To'){
                accountIdsForShipToCustomerName.add(key);
            }
        }
		Set<String> shipToCustomerNamelist = getShipToCustomerName(accountIdsForShipToCustomerName);
		return shipToCustomerNamelist;
	}
	
	public class Datawrapper{
		@AuraEnabled
		public List<myIfeOrderHeaders__x> MYIFEorderHeaders{ get; set; }

		@AuraEnabled
		public List<Account> accounts{ get; set; }

		@AuraEnabled
		public String selectedAccount{ get; set; }

		@AuraEnabled
		public Set<String> shipToCustomerName{ get; set; }
		
		@AuraEnabled
		public String userObjContactAccountId{ get; set; }
        
        @AuraEnabled
		public Integer recordCount{ get; set; }

		public Datawrapper(){
			MYIFEorderHeaders = new List<myIfeOrderHeaders__x>();
			accounts = new List<Account>();
			selectedAccount = '';
			shipToCustomerName = new Set<String>();
			userObjContactAccountId = '';
            recordCount = 0;
		}
	}

	public class SearchDatawrapper{
		@AuraEnabled
		public List<myIfeOrderHeaders__x> MYIFEorderHeaders{ get; set; }

		@AuraEnabled
		public Set<String> shipToCustomerName{ get; set; }

		public SearchDatawrapper(){
			MYIFEorderHeaders = new List<myIfeOrderHeaders__x>();
			shipToCustomerName = new Set<String>();
		}
	}

}