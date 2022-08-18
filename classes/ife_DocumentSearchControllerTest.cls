@isTest public class ife_DocumentSearchControllerTest {
    @isTest public static void ife_DocumentSearchControllerTest(){
        ife_DocumentSearchController controller = new ife_DocumentSearchController();
        ife_DocumentSearchController.getDocumentTypeValue();
    }
    
    @isTest public static void getDocumentSearchResultTest(){  
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
                
                IFE_Document__c ifeDocument = new IFE_Document__c();
                ifeDocument.Name = 'Test';
                ifeDocument.Part_Number__c = '1234';
                ifeDocument.Document_Number__c = '1234';
                // ifeDocument.Document_Type__c = 'GCS';
                ifeDocument.Description__c = 'Testing for a ifeDocument';
                insert ifeDocument;  
                
                IFE_Part__c  ifePart = new IFE_Part__c();
                ifePart.Name = 'Test ifePart';
                insert ifePart;
                
                IFE_Part_Document__c partDocument = new IFE_Part_Document__c();
                partDocument.IFE_Document__c = ifeDocument.Id;
                partDocument.IFE_Part__c = ifePart.Id;
                insert partDocument;
                
                IFE_Part_Overide__c partOveride = new IFE_Part_Overide__c();
                partOveride.Account__c = acc.id;
                partOveride.IFE_Part__c = ifePart.Id;
                partOveride.Override__c = 'Add';
                insert partOveride;
                
             /*   IFE_Document_Account__c docAccount = new IFE_Document_Account__c();
                docAccount.IFE_Document__c = ifeDocument.Id;
                docAccount.Account__c = acc.ID;
                insert docAccount;*/
                
                Test.startTest(); 
                ife_DocumentSearchController.getDocumentSearchResult(ifeDocument.Part_Number__c, ifeDocument.Part_Description__c, ifeDocument.Document_Number__c, ifeDocument.Document_Type__c,'2020-12-24', '2020-12-24');
                Test.stopTest();
            }
        }  
    }
}