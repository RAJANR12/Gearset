public class ife_SendEmailWithAttachment {
  
    public static void sendEmailWithAttachment(String docId, String ifeCase) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Case>  cases = [SELECT id, Subject, Description, IFE_Repair_Shop__c,RecordType.DeveloperName 
                             FROM Case 
                             WHERE id = :ifeCase];
        
        if(cases.size() < 1){
            return;
        }
        String UserEmail = UserInfo.getUserEmail();
        System.Debug('UserEmail-' + UserEmail);
        System.Debug('CaseId '+ifeCase +' '+docId);
        List<ifeRepairShop__mdt> repairShops = [SELECT MasterLabel, Shop_Email__c
                                                FROM ifeRepairShop__mdt];
        Map<String,String> repairShopToEMail = new Map<String,String>();
        
        for (ifeRepairShop__mdt repairShop : repairShops){
            repairShopToEmail.put(repairShop.MasterLabel, repairShop.Shop_Email__c);
        }

        if(String.isBlank(cases[0].IFE_Repair_Shop__c) ||
                    repairShopToEmail.containsKey(cases[0].IFE_Repair_Shop__c) == false){
            return;
        }
        
        String description = cases[0].RecordType.DeveloperName == 'IFE_Priority_Upgrade'?
                                    '<p>The following user has requested a priority upgrade':
                                    '<p>The following user has sent an email';

        description += '<br/> Name: '+ UserInfo.getName();
        description += '<br/> Email: '+ UserInfo.getUserEmail()+'</p><br/>';
        description += '<p>'+cases[0].description+'</p>';

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSubject(cases[0].Subject);
        message.setHtmlBody(description);  
        message.setToAddresses(new String[] {repairShopToEmail.get(cases[0].IFE_Repair_Shop__c)});
        //message.setToAddresses(new String[] {'mayank.srivastava@panasonic.aero'});
        
       List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

        list<Id> liChildDocumentIds = new List<Id>(); 
        /*for(ContentDocumentLink cdl :  [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: cases[0].id]){
            liChildDocumentIds.add(cdl.ContentDocumentId);
        }*/
        liChildDocumentIds.add(docId);
        //List<ContentDocumentLink> cdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId =: docId];
        List<ContentVersion> files = [SELECT Id, Title, ContentSize, Description, FileExtension, FileType, IsLatest, VersionData FROM ContentVersion WHERE ContentDocumentId IN: liChildDocumentIds AND IsLatest = true];
        List<String> ids = new List<String>();

        for(ContentVersion file : files){
            ids.add(file.Id);
        }
        message.setEntityAttachments(ids);

        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
          } catch (Exception e) {
                System.System.debug('Email send exceptioon '+ e);
            throw e;
          }

     
    }
}