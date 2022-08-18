@isTest
private with sharing class ife_SearchDeliveryDetailsControllerTest {
    @isTest private static void ife_SearchDeliveryDetailsControllerTest(){
        ife_SearchDeliveryDetailsController ife = new ife_SearchDeliveryDetailsController();
    }
    @isTest private static void getAccountsTest(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        User usrr = ife_TestDataUtil.CreateUser(true);
        usrr.UserRoleId = portalRole.Id;
        update usrr;
        System.runAs (usrr) {
                
            Account acc = ife_TestDataUtil.createAccount(true);
            
            Contact con = ife_TestDataUtil.createContact(acc.Id, true);
            
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
               ife_SearchDeliveryDetailsController.getAccounts();
            Test.stopTest();
            }
       }
    }
    @isTest private static void getRelatedAccountsTest(){
       Account acc = ife_TestDataUtil.createAccount(true);
       L2I_Related_Account__c relaccount = ife_TestDataUtil.createRelatedAccount(acc.Id, true);
       ife_SearchDeliveryDetailsController.getRelatedAccounts(acc.Id);
    }
    @isTest private static void getMYIFDeliveryDetailsTest(){
        ife_SearchDeliveryDetailsController.getMYIFDeliveryDetails('133','123','123','123','123','123','Test');
        
    }
    @isTest private static void getMYIFdelivery(){
    /*    MyIFECarrierRedirect__mdt mdt  = new MyIFECarrierRedirect__mdt();
        mdt.NamespacePrefix = '123';
        mdt.RedirectURL__c = 'https://Goggle.com??Test0';
        mdt.MasterLabel = 'Test';
        insert mdt;
	*/
        ife_SearchDeliveryDetailsController.getMYIFdelivery('123','Test');
    }  
	@isTest private static void getMYIFdeliveryDetailLine(){
        ife_SearchDeliveryDetailsController.getMYIFdeliveryDetailLine('123','Test','123');
    }  
    
}