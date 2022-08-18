@isTest
private class L2I_SalesOrderSearchControllerTest {
    @isTest
    public static void downloadCSVTest(){
        Account testAccount = new Account(
            Name = 'BRITISH AIRWAYS CORP',
            L2I_Payment_Term__c = '30 NET -a',
            L2I_Customer_Group__c = 'External',
            L2I_Customer_ID__c = '1083',
            L2I_Party_Id__c = '1083',
            L2I_Region__c = 'Europe',
            L2I_Operator_Number__c = 'BA',
            L2I_Airline_Code__c = 'BAW',
            AccountNumber = '1058',
            L2I_Account_Status__c = 'Active'
        );
        insert testAccount;
        
        Test.startTest();
        //Updated by Jan for W-004376 - added testAccount.L2I_Customer_ID__c
        List<myIfeOrderHeaders__x> MYIFEorderHeaders = L2I_SalesOrderSearchController.downloadCSV('test','test','test','test','test','1083',testAccount.L2I_Customer_ID__c,'test','test',12,12);
        System.assertEquals(0, MYIFEorderHeaders.size());
        Test.stopTest(); 
    }
    
    @isTest
    public static void getSearchERPOrderStatusByCustomerPOTest(){
        L2I_SalesOrderSearchController salesOrderSearch = new L2I_SalesOrderSearchController();
        L2I_SalesOrderSearchController.getSearchERPOrderStatusByCustomerPO('123');
    }
    
    @isTest
    public static void getERPOrderStatusForAccountTest(){
         Test.startTest();
       List<myIfeOrderHeaders__x> MYIFEorderHeaders =  L2I_SalesOrderSearchController.getERPOrderStatusForAccount('12');
        System.assertEquals(0, MYIFEorderHeaders.size());
        Test.stopTest();
       
    }
    
    @isTest
    public static void getERPOrderStatusTest(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        User userObj = ife_TestDataUtil.CreateUser(true);
        userObj.UserRoleId =  portalRole.Id;
        update userObj;
        
        System.runAs (userObj) {
            
            Account acc = ife_TestDataUtil.createAccount(true);
            
            Contact con = ife_TestDataUtil.createContact(acc.Id, true);
             //Added by Jan for W-004376: Start
            con.IFE_Email_Verified__c = true;
            con.Email = 'test12345@test.com';
            update con;
            //Added by Jan for W-004376: Stop
            
            Profile portalProfile = [SELECT Id FROM Profile where name = 'PAC Customer' limit 1];
            User usr = new User(
                Username = System.now().millisecond() + 'test12345@test.com',
                ContactId = con.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US');
            
            insert usr;
            
            System.runAs(usr){
                Test.startTest();
            //    L2I_SalesOrderSearchController salesorder = new L2I_SalesOrderSearchController();
                L2I_SalesOrderSearchController.getERPOrderStatus();
            //    System.assertEquals(salesorder.shipToCustomerName, 'Ship to');
                Test.stopTest();
            }
        }
    }

    @isTest
    public static void getSearchERPOrderQueryTest(){
        Test.startTest();
       List<myIfeOrderHeaders__x> MYIFEorderHeaders = L2I_SalesOrderSearchController.getSearchERPOrderQuery('123');
        System.assertEquals(0, MYIFEorderHeaders.size());
        Test.stopTest();
    }
    
    @isTest
    public static void getSearchERPOrderStatusTest(){
        Account acc = ife_TestDataUtil.createAccount(true);
        acc.L2I_Customer_ID__c = '1083';
        update acc;
        
        L2I_Related_Account__c relatedacc = new L2I_Related_Account__c();
        relatedacc.Relationship_Type__c = 'Ship To';
        relatedacc.Account__c = acc.Id;
        relatedacc.Related_To__c = acc.Id;
        insert relatedacc;
        
        
        L2I_SalesOrderSearchController.getSearchERPOrderStatus('salesOrderNumber', 'eCommerceNumber', 'customerPo', 'programNumber', 'shipToCustomerName', 'tailNumber', acc.L2I_Customer_ID__c, 'orderStatusSerach', 'orderCustomerName', 123, 12);
    }
	
	@isTest
	public static void getRelatedAccountTest() {
		Map<String, String> accountIdWithRelationshipTypeMap = new Map<String, String>();
		accountIdWithRelationshipTypeMap = L2I_SalesOrderSearchController.getRelatedAccount('0018A00000LBYg0QAH',true);
		Test.startTest();
        //Added by Jan for W-004376: Start
        L2I_SalesOrderSearchController.getRelatedAccount_1('0018A00000LBYg0QAH',true);
        L2I_SalesOrderSearchController.getShipToCustomerNameByCountactAccountId('0018A00000LBYg0QAH');
        L2I_SalesOrderSearchController.getShipToCustomerList('0018A00000LBYg0QAH');
        L2I_SalesOrderSearchController.getUserInfo();
        //Added by Jan for W-004376: Stop
		System.assertEquals('{0018A00000LBYg0QAH=Ship To}', accountIdWithRelationshipTypeMap.toString());
		Test.StopTest();
	}
	
	@isTest
    public static void getSearchERPOrderStatusBoeingTest(){
		Account acc = ife_TestDataUtil.createAccount(true);
        acc.L2I_Customer_ID__c = '1516';
        update acc;
        
        L2I_Related_Account__c relatedacc = new L2I_Related_Account__c();
        relatedacc.Relationship_Type__c = 'Ship To';
        relatedacc.Account__c = acc.Id;
        relatedacc.Related_To__c = acc.Id;
        insert relatedacc;
		
        Test.startTest();
        L2I_SalesOrderSearchController.getSearchERPOrderStatus('salesOrderNumber', 'eCommerceNumber', 'customerPo', 'programNumber', 'shipToCustomerName', 'tailNumber', acc.L2I_Customer_ID__c, 'orderStatusSerach', 'orderCustomerName', 123, 12);
		Test.StopTest();
    }
}