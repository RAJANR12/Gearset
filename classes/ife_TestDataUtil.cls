@isTest
public class ife_TestDataUtil {
     
    public static Account createAccount(boolean isInsert){
        Account accVariable = new Account();
        accVariable.name = 'Acc Tets';
                
        if(isInsert){
            insert accVariable;
        }
        return accVariable;
    }
    public static Contact createContact(String accId, boolean isInsert){
        
            Contact con = new Contact();
                con.LastName = 'Name';
                con.AccountId = accId;
                con.lastName = 'Testing LastName';
                con.IFE_Sales_Access__c = true;
                con.IFE_Document_Access__c = true;
                con.IFE_Maintenance_Access__c = true;
                con.IFE_Repair_Access__c = true;
                con.IFE_B2B_Access__c = true;   
                
        if(isInsert){
           insert con; 
        }
        return con;
    } 
    public static User CreateUser( boolean isInsert){
      Profile profileId = [Select Id from Profile where name = 'System Administrator'];
        //  Account acc = ife_TestDataUtil.createAccount(true);
        //  Contact con = ife_TestDataUtil.createContact(acc.id, true);
        User usr = new User();
        usr.LastName = 'Testing';
        usr.FirstName='test';
        usr.Alias = 'pbhar';
        usr.Email = 'Pranav.Bhardwaj@asdf.com';
        usr.Username = System.now().millisecond() + 'test2@testpan.com';
        usr.ProfileId = profileId.id;
        usr.TimeZoneSidKey = 'GMT';
        usr.LanguageLocaleKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LocaleSidKey = 'en_US';
    //    usr.ContactId = con.Id;
        if(isInsert){
            insert usr;
        }
       return usr; 
    }
    public static L2I_Related_Account__c createRelatedAccount(String accId, boolean isInsert){
        L2I_Related_Account__c relAccount = new L2I_Related_Account__c();
        relAccount.Account__c = accId;
        relAccount.Related_To__c = accId;
        relAccount.Relationship_Type__c = 'Both';
        
        if(isInsert){
            insert relAccount;
        }
        return relAccount;
    }
}