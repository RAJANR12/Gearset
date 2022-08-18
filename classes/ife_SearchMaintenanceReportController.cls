public class ife_SearchMaintenanceReportController {
    public ife_SearchMaintenanceReportController() {

    }
    @AuraEnabled(cacheable=true)
    public static List<Account>  getAccounts(){
        User userObj =[SELECT Id ,Name,Contact.AccountId,Contact.Account.L2I_Customer_ID__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(userObj.Contact.AccountId != null){
            System.debug('userObj.Contact.AccountId----'+userObj.Contact.AccountId);
           return getRelatedAccounts(userObj.Contact.AccountId);
        }  
        else{
           return getRelatedAccounts(null);
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> getRelatedAccounts(String accountId){
        Set<String> accountIds = new Set<String>();
        if(String.isNotBlank(accountId)){
            accountIds.add(accountId);
            for(L2I_Related_Account__c  relatedAccount :[SELECT Id, Related_To__c ,Relationship_Type__c
                                        FROM L2I_Related_Account__c 
                                        WHERE Account__c =: accountId])
            {
                System.debug('relatedAccount.Related_To__c ----'+relatedAccount.Related_To__c);
                accountIds.add(relatedAccount.Related_To__c);
            }
        }
        System.debug('accountIds ----'+accountIds);
        if(!accountIds.isEmpty()){
            List<Account> accounts = [SELECT Id, Name,L2I_Customer_ID__c FROM Account WHERE Id=:accountIds AND L2I_Customer_ID__c != null];
            System.debug('accounts 1----'+accounts);
            
            return accounts;
        }
        else{
            List<Account> accounts = [SELECT Id, Name,L2I_Customer_ID__c FROM Account WHERE L2I_Customer_ID__c != null];
            System.debug('accounts 2----'+accounts);
           
            return accounts;

        }
    }
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getFilesMaintenanceReport(String maintenanceReportId){
        System.debug('maintenanceReportId---- '+maintenanceReportId);
        List<ContentDocument> ContentDocumentList = new List<ContentDocument>();
       for(ContentDocumentLink contentDocumentLink :[SELECT ContentDocumentId ,ContentDocument.Title 
                                                        FROM ContentDocumentLink 
                                                         WHERE LinkedEntityId =: maintenanceReportId]){
        System.debug('contentDocumentLink.ContentDocument---- '+contentDocumentLink.ContentDocument);
        ContentDocumentList.add(contentDocumentLink.ContentDocument);
        }
        System.debug('ContentDocumentList---- '+ContentDocumentList);
        System.debug('ContentDocumentList--size-- '+ContentDocumentList.size());
        if(ContentDocumentList.size() == 0){
            throw new AuraHandledException('No Record Found..'); 
         }
         //System.debug('ContentDocumentList---- '+ContentDocumentList);
         return ContentDocumentList;
    }
    @AuraEnabled(cacheable=true)
    public static DataWrapper getMaintenanceReport(){
    
        DataWrapper dataWrapperObj = new DataWrapper();
        List<Account> accList = getAccounts();
        System.debug('accList>>>'+accList);
         List<Maintenance_Report__c> maintenanceReportList = new List<Maintenance_Report__c>();
      
         for(Maintenance_Report__c oCon : [SELECT Name, Id, Account__c, Year__c, Maintenance_Date__c, Report_Type__c  
                                            FROM Maintenance_Report__c WHERE Account__c =: accList[0].Id
                                            ORDER BY CreatedDate DESC LIMIT 5]){
                maintenanceReportList.add(oCon);
         }
          /*if(maintenanceReportList.size() == 0){
             throw new AuraHandledException('No Record Found..'); 
          }*/
        if(!accList.isEmpty()){
            dataWrapperObj.selectedAccount = accList[0].Id;
        }
        accList.sort();
        dataWrapperObj.maintenanceReports = maintenanceReportList;
        dataWrapperObj.accounts =  accList;
         return dataWrapperObj;
    }
    @AuraEnabled(cacheable=true)
    public static List<Maintenance_Report__c> getSearchMaintenanceReport(String  yearValue,String monthValue, String accountId){

        Date startDate  =date.valueOf(yearValue+'-'+monthValue+'-01');
        Date endDate = startDate.addMonths(1).addDays(-1);
         List<Maintenance_Report__c> maintenanceReportList = new List<Maintenance_Report__c>();
      
         for(Maintenance_Report__c oCon : [SELECT Name, Id, Account__c, Year__c, Maintenance_Date__c, Report_Type__c
                                            FROM Maintenance_Report__c
                                            WHERE Maintenance_Date__c >= :startDate AND Maintenance_Date__c <= :endDate AND Account__c =: accountId LIMIT 5]){
                maintenanceReportList.add(oCon);
         }
         System.debug('maintenanceReportList=='+maintenanceReportList);
          if(maintenanceReportList.size() == 0){
             throw new AuraHandledException('No Record Found..'); 
          }
         return maintenanceReportList;
    }
    public class DataWrapper{
        @AuraEnabled
        public List<Maintenance_Report__c> maintenanceReports {get;set;}
        @AuraEnabled
        public List<Account> accounts {get;set;}
        @AuraEnabled
        public string selectedAccount {get;set;}
        public DataWrapper(){
            maintenanceReports = new List<Maintenance_Report__c>();
            accounts = new List<Account>();
            selectedAccount = '';
        }

    }
}