@isTest
public class ife_VerticalNavControllerTest {
    @isTest 
    	static void getSalesAccessTest(){
		UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		system.debug('portalRole is ' + portalRole);
            
         User userObj = ife_TestDataUtil.CreateUser(true);
         userObj.UserRoleId =  portalRole.Id;
         update userObj;
        
        System.runAs ( userObj ) {
                
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
            Contact cons =  ife_VerticalNavController.getSalesAccess();
            System.assertNotEquals(null, con);
            Test.stopTest();
            }
        }
   }
     @isTest 
    	static void getSalesAccessnullTest(){
              Test.startTest();
               ife_VerticalNavController.getSalesAccess();
            Test.stopTest();
        }
}