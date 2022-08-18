@isTest
private class ife_DocumentSendEmailBatchTest {
    public static String CRON_EXP = '0 0 22 * * ? *';
    
    @isTest
    public static void executeTest1(){
        
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
                LanguageLocaleKey = 'en_US',
                IFE_Email_Opt_In__c = true);
            
            insert usr;
            
            String strRecordTypeId = [Select Id From RecordType Where Name = 'Technical Publication'].Id;
            
            IFE_Document__c ifeDocument = new IFE_Document__c();
            ifeDocument.Description__c = 'Testring--';
            ifeDocument.Revision__c = 'Test';
            ifeDocument.File_Name__c = 'Test';
            ifeDocument.RecordTypeId = strRecordTypeId;
            ifeDocument.Document_Type__c = 'Technical Publication';
            ifeDocument.Document_Modified_Date__c = Date.today();
            insert ifeDocument;
            
            
            IFE_Document_Account__c docAccount = new IFE_Document_Account__c();
            docAccount.IFE_Document__c = ifeDocument.Id;
            docAccount.Account__c = acc.Id;
            insert docAccount;
            
            Test.startTest();
            ife_DocumentSendEmailBatch docSendEmail = new ife_DocumentSendEmailBatch();
            Database.executeBatch(docSendEmail);
            
            String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, docSendEmail);
            Test.stopTest();
        }
    }
}