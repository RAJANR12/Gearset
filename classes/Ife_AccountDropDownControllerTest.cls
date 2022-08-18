@isTest
private class Ife_AccountDropDownControllerTest {
    @isTest
    public static void getAccountsTest(){
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
            
            List<String> accountRelationshipType = new List<String>{'Ship To'};
                System.debug('accountRelationshipType>>'+accountRelationshipType);
            System.runAs(usr){
                
                L2I_Related_Account__c relatedacc = new L2I_Related_Account__c();
                relatedacc.Relationship_Type__c = 'Ship to';
                relatedacc.Related_To__c = acc.Id;
                relatedacc.Account__c = acc.Id;
                insert relatedacc;
                Test.startTest();
                Ife_AccountDropDownController.getAccounts(accountRelationshipType);
                Test.stopTest();
            }
        }
    }
    @isTest
    public static void getAccountsnullTest(){
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
            
            List<String> accountRelationshipType = new List<String>();
            System.debug('accountRelationshipType>>'+accountRelationshipType);
            System.runAs(usr){
                
                L2I_Related_Account__c relatedacc = new L2I_Related_Account__c();
                relatedacc.Relationship_Type__c = 'Ship to';
                relatedacc.Related_To__c = acc.Id;
                relatedacc.Account__c = acc.Id;
                insert relatedacc;
                Test.startTest();
                Ife_AccountDropDownController accountDropcntrl = new Ife_AccountDropDownController();
                Ife_AccountDropDownController.getAccounts(accountRelationshipType);
                Test.stopTest();
            }
        }
    }
}