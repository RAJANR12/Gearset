@isTest
public class ife_OrderHeaderListControllerTest {

    @isTest 
    public static void getMYIFEorderHeaderTest(){
        ife_OrderHeaderListController orderHeder = new ife_OrderHeaderListController();
        
        Test.startTest();
        String orderHeader =  ife_OrderHeaderListController.getMYIFEorderHeader();
        System.assertNotEquals(null, orderHeader);
        Test.stopTest();
    }
    
    @isTest
    public static void getMYIFE_OrderHeaderDetailsFieldsTest(){
        Test.startTest();
       List<String> orderHeaderdetails =  ife_OrderHeaderListController.getMYIFE_OrderHeaderDetailsFields();
         System.assertNotEquals(null, orderHeaderdetails);
        Test.stopTest();
    }
    
    @isTest
    public static void getMYIForderHeaderDetailsTest(){
        ife_OrderHeaderListController.getMYIForderHeaderDetails('123',true);
    }
    
   @isTest
    public static void getMYIFE_OrderLinesTest(){ 
        ife_OrderHeaderListController.getMYIFE_OrderLines('1234');
    }
    
    @isTest
    public static void getCurrentUserTest(){
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
             ife_OrderHeaderListController.getCurrentUser();
            Test.stopTest();
            }
        }
    }
}