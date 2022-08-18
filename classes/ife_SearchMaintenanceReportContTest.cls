@isTest
private class ife_SearchMaintenanceReportContTest {
    
    @isTest
    public static void getMaintenanceReportTest(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        User userObj = ife_TestDataUtil.CreateUser(true);
        userObj.UserRoleId =  portalRole.Id;
        update userObj;
        
        System.runAs ( userObj ) {
            
            Account acc = ife_TestDataUtil.createAccount(true);
            acc.L2I_Customer_ID__c = '123';
            update acc;
            
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
                
                L2I_Related_Account__c relatedacc = new L2I_Related_Account__c();
                relatedacc.Relationship_Type__c = 'Ship to';
                relatedacc.Related_To__c = acc.Id;
                relatedacc.Account__c = acc.Id;
                insert relatedacc;
                
                Maintenance_Report__c maintenanceReportObj = new Maintenance_Report__c();
                maintenanceReportObj.Account__c = acc.Id;
                maintenanceReportObj.Name = 'test';
                insert maintenanceReportObj;
                
                Test.startTest();
                ife_SearchMaintenanceReportController.getMaintenanceReport();
                Test.stopTest();
            }
        }
    }    
    @isTest
    public static void getSearchMaintenanceReportTest(){
        Account acc = ife_TestDataUtil.createAccount(true);
        
        Maintenance_Report__c maintenanceReportObj = new Maintenance_Report__c();
        maintenanceReportObj.Account__c = acc.Id;
        maintenanceReportObj.Name = 'test';
        maintenanceReportObj.Maintenance_Date__c = System.today();
        insert maintenanceReportObj;
        
        String yearValue = String.valueOf(System.Today().year());
        String monthValue = String.valueOf(System.today().month());
        ife_SearchMaintenanceReportController.getSearchMaintenanceReport(yearValue,monthValue,acc.Id);
    }
    
    @isTest
    public static void getFilesMaintenanceReportTest(){
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData = Blob.valueOf('Test Content');         
        insert cv; 
        
        ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        system.debug('@@@testContent'+testContent);
        
        String strRecordTypeId = [Select Id From RecordType Where Name = 'Agile Document'].Id;
        
        IFE_Document__c ifeDocument = new IFE_Document__c();
        ifeDocument.Description__c = 'Testring--';
        ifeDocument.Revision__c = 'Test';
        ifeDocument.File_Name__c = 'Test';
        ifeDocument.RecordTypeId = strRecordTypeId;
        ifeDocument.Document_Type__c = 'Products';
        insert ifeDocument;
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = ifeDocument.Id;
        contentlink.ShareType = 'I'; 
        contentlink.ContentDocumentId = testContent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        ife_SearchMaintenanceReportController.getFilesMaintenanceReport(contentlink.LinkedEntityId);
    }
}