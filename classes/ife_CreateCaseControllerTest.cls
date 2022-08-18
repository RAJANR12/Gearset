@isTest
private class ife_CreateCaseControllerTest {
    @isTest
    public static void getAccountIdAndrecordTypeIdTest(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
            
         User userObj = ife_TestDataUtil.CreateUser(true);
         userObj.UserRoleId = portalRole.Id;
         update userObj;
        
        System.runAs ( userObj ) {
                
            Account acc = ife_TestDataUtil.createAccount(true);
            
            Contact con = ife_TestDataUtil.createContact(acc.Id, true);
            
            Profile portalProfile = [SELECT Id FROM Profile where name = 'PAC Customer' limit 1];
            User usr = new User(
            Username = System.now().millisecond() + 'test123458@testpan.com',
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
        ife_CreateCaseController.getAccountIdAndrecordTypeId('Request Priority Upgrade');
            }
    }
   }
    @isTest
    public static void createCaseTest(){
      //   Account accObj = ife_TestDataUtil.createAccount(true);
         
   /*     Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IFE_Priority_Upgrade').getRecordTypeId();
       // Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IFE_Priority_Upgrade').getRecordTypeId();
        Case cases = new Case();
        cases.Status = 'New';
        cases.RecordTypeId = recordTypeId;
        cases.AccountId = accObj.Id;
        
        insert cases;*/
        
         UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
            
         User userObj = ife_TestDataUtil.CreateUser(true);
         userObj.UserRoleId =  portalRole.Id;
         update userObj;
        
        System.runAs ( userObj ) {
                
            Account accObj = ife_TestDataUtil.createAccount(true);
            
            Contact con = ife_TestDataUtil.createContact(accObj.Id, true);
            
            Profile portalProfile = [SELECT Id FROM Profile where name = 'PAC Customer' limit 1];
            User usr = new User(
            Username = System.now().millisecond() + 'test123457@testpan.com',
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
                Case cases = new Case();
                
                Test.startTest();
                ife_CreateCaseController.createCase(cases, 'RequestPriorityUpgrade');
                Test.stopTest();
            }
        }
    }
    
    @isTest
    public static void FileUploadTest(){
         Account accObj = ife_TestDataUtil.createAccount(true);
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = accObj.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Case cases = new Case(Status ='New', Priority = 'Medium', Origin = 'Email');
         insert cases;
        ife_CreateCaseController.FileUpload(documents[0].Id,cases.Id);
    }
    
    @isTest
    public static void deleteDocumentTest(){
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion; 
        
     List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
       ife_CreateCaseController.deleteDocument(documents[0].Id);
    }
    
    @isTest
    public static void sendEmailTest(){
         Case cases = new Case(Status ='New', Priority = 'Medium', Origin = 'Email');
         insert cases;
        
        ife_CreateCaseController createCase = new ife_CreateCaseController();
        ife_CreateCaseController.sendEmail('123',cases.Id);
    }
}