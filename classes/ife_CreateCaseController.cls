public class ife_CreateCaseController{
    public ife_CreateCaseController(){
    }

    @AuraEnabled
    public static DataWapper getAccountIdAndrecordTypeId(String callFrom){
        DataWapper dataWapperObj = new DataWapper();
        User userObj = [SELECT Id, Name, Contact.AccountId, Contact.Account.L2I_Customer_ID__c
                        FROM User
                        WHERE Id = :UserInfo.getUserId()];
        String accountId = '';
        Id recordTypeId;
        if (userObj.Contact.AccountId != null){
            accountId = userObj.Contact.AccountId;
            System.debug('userObj.Contact.AccountId----' + userObj.Contact.AccountId);
        }
        if (callFrom == 'Request Priority Upgrade'){
            recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('IFE_Priority_Upgrade').getRecordTypeId();
        }
        if (callFrom == 'Email Repair Shop'){
            recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('IFE_Shop_Support').getRecordTypeId();
        }
        dataWapperObj.accountId = accountId;
        dataWapperObj.recordTypeId = recordTypeId;

        return dataWapperObj;
    }

    @AuraEnabled
    public static String createCase(Case caseObj, String callFrom){
        User userObj = [SELECT Id, Name, Contact.AccountId, Contact.Account.L2I_Customer_ID__c
                        FROM User
                        WHERE Id = :UserInfo.getUserId()];
        String accountId = '';
        Id recordTypeId;
        if (userObj.Contact.AccountId != null){
            accountId = userObj.Contact.AccountId;
            System.debug('userObj.Contact.AccountId----' + userObj.Contact.AccountId);
        }
        if (callFrom == 'RequestPriorityUpgrade'){
            recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('IFE_Priority_Upgrade').getRecordTypeId();
        }
        if (callFrom == 'EmailRepairShop'){
            recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('IFE_Shop_Support').getRecordTypeId();
        }

        System.debug('recordTypeId --- ' + recordTypeId);
        caseObj.accountId = accountId;
        caseObj.RecordTypeId = recordTypeId;

        System.debug('caseObj --- ' + caseObj);
        System.debug('callFrom --- ' + callFrom);
        if (caseObj != null){
            insert caseObj;
            Case newCreatedcaseObj = [SELECT Id, CaseNumber
                                      FROM Case
                                      WHERE Id = :caseObj.Id];
            return newCreatedcaseObj.CaseNumber;
        }
        return null;
    }

    @AuraEnabled
    public static void FileUpload(string docId, string caseId){

        system.debug('DocId' + docId);
        system.debug('caseId' + caseId);
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = docId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        cdl.LinkedEntityId = caseId;
        insert cdl;
    }

    @AuraEnabled
    public static void deleteDocument(string docId){
        ContentDocument contentDocumentOnj = [SELECT Id FROM ContentDocument WHERE Id=:docId ];
        if(ContentDocumentOnj !=null){
            System.debug('** ==contentDocumentOnj  '+contentDocumentOnj);
            delete contentDocumentOnj;
        }
    }

    @AuraEnabled
    public static void sendEmail(string docId, string caseId){
        ife_SendEmailWithAttachment.sendEmailWithAttachment(docId, caseId);
    }

    public class DataWapper{
        @AuraEnabled
        public String accountId{ get; set; }

        @AuraEnabled
        public String recordTypeId{ get; set; }

        public DataWapper(){
            accountId = '';
            recordTypeId = '';
        }
    }
}