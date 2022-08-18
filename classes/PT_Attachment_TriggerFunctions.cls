/**
 *      @author       Sarah Kennedy
 *      @date         09/10/2020
 *      @description  Trigger Functions for PT_AttachmentTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy               09/10/2020          Initial scaffold
 */

public without sharing class PT_Attachment_TriggerFunctions {
    
    public static void createFileFromAttachment(List<Attachment> newAttachmentList) {
        // read Opportunity Attachments and create Files and ContentDocument objects
        List<ContentVersion> cVerList = new List<ContentVersion>();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<String, String> oppCVerMap = new Map<String, String>();
        Map<String, Opportunity> oppQuoteMap = new Map<String, Opportunity>();
        Map<String, String> oppCVerNameMap = new Map<String, String>();
        List<PT_CPL_Document_Upload__e> cplList = new List<PT_CPL_Document_Upload__e>();
        Set<String> cVerIds = new Set<String>();
        Set<String> oppIds = new Set<String>();
        Set<String> oppCPLs = new Set<String>();
        Set<String> attachIds = new Set<String>();
        
        for (Attachment attach : newAttachmentList) {
            if ((String.valueOf(attach.Name).startsWith('CPL') ||
                  String.valueOf(attach.Name).startsWith('PPL') ||
                 String.valueOf(attach.Name).startsWith('CR'))  && //W-003749 Added CR in the formatting
                  String.valueOf(attach.ParentId).startsWith('006')) {
                oppIds.add(attach.ParentId);
                attachIds.add(attach.Id);
                System.debug('*** attach ' + attach);
            }
        }
        
        // get opportunities for update
        // not using Primary Quote as the cloning process may remove the Primary check before we process this attachment
        oppList = [
              SELECT Id, PT_CPL_Document_Id__c, PT_CPL_Document_Name__c, PT_Current_Parts_List__c, PT_Is_CPL__c, PT_Is_PPL__c,
                    L2I_Delivery_Schedule__c
              FROM Opportunity
              WHERE Id IN :oppIds
        ];
        
        for (Opportunity opp : oppList) {
            oppQuoteMap.put(opp.Id, opp);
            if (opp.PT_Is_CPL__c){
                oppCPLs.add(opp.Id);
            }
        }
        System.debug('*** oppCPLs ' + oppCPLs);
        
        for (Attachment attach2 : newAttachmentList) {
            if ((String.valueOf(attach2.Name).startsWith('CPL') ||
                  String.valueOf(attach2.Name).startsWith('PPL') || 
                 String.valueOf(attach2.Name).startsWith('CR')) && //W-003749 Added CR in the formatting
                  String.valueOf(attach2.ParentId).startsWith('006')) {
                // create contentversion
                ContentVersion cVer = new ContentVersion();
                cVer.ContentLocation = 'S';             // document is in Salesforce
                cVer.PathOnClient = attach2.Name;        // filename with extension
                cVer.Title = attach2.Name;
                cVer.VersionData = attach2.Body;
                if (String.valueOf(attach2.Name).startsWith('CPL')){
                    cVer.PT_IntegrationType__c = 'CPL';
                } else {
                    cVer.PT_IntegrationType__c = 'PPL';
                }
                cVer.tagCsv = 'SBQQ__Quote__c:' + oppQuoteMap.get(attach2.ParentId).PT_Current_Parts_List__c;
                cVer.FirstPublishLocationId = attach2.ParentId;  // creates ContentDocumentLink also
                System.debug('*** cVer ' + cVer);
                cVerList.add(cVer);
            }
        }
        
        
        if (cVerList.size() > 0) {
            insert cVerList;
        }
        
        for (ContentVersion cVer : cVerList) {
            cVerIds.add(cVer.Id);
        }
        
        for (ContentVersion cVerDoc : [SELECT Id, ContentDocumentId, FirstPublishLocationId, Title FROM ContentVersion WHERE Id IN :cVerIds]) {
            // have to specifically select for ContentDocumentId - it doesn't populate in the inserted list
            System.debug('*** cVerDoc ' + cVerDoc.ContentDocumentId);
            String contentId = cVerDoc.ContentDocumentId + ':' + cVerDoc.Id;
            oppCVerMap.put(cVerDoc.FirstPublishLocationId, cVerDoc.ContentDocumentId);
            oppCVerNameMap.put(cVerDoc.FirstPublishLocationId, cVerDoc.Title);
            
            // platform event for CPLs
            if (oppCPLs.contains(cVerDoc.FirstPublishLocationId) &&
                  !cVerDoc.Title.contains('Pending') &&
                  !cVerDoc.Title.contains('XLS')) {
                PT_CPL_Document_Upload__e cpl = new PT_CPL_Document_Upload__e();
                String [] cIds = contentId.split(':');
                cpl.ContentDocumentId__c = cIds[0];
                cpl.ContentVersionId__c = cIds[1];
                cpl.OpportunityId__c = cVerDoc.FirstPublishLocationId;
                cpl.QuoteId__c = oppQuoteMap.get(cVerDoc.FirstPublishLocationId).PT_Current_Parts_List__c;
                cpl.DSHId__c = oppQuoteMap.get(cVerDoc.FirstPublishLocationId).L2I_Delivery_Schedule__c;
                System.debug('*** cpl ' + cpl);
                cplList.add(cpl);
            }
        }
        
        for (Opportunity opp : oppList) {
            opp.PT_CPL_Document_Id__c = oppCVerMap.get(opp.Id);
            opp.PT_CPL_Document_Name__c = oppCVerNameMap.get(opp.Id);
        }
        if (oppList.size() > 0) {
            update oppList;
        }
        
        // publish the platform event for CPLs
        System.debug('*** cplList ' + cplList);
        if (cplList != NULL &&
              cplList.size() > 0) {
            List<Database.SaveResult> results = EventBus.publish(cplList);
            // Inspect publishing result for each event
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('====== Successfully published PT_CPL_Document_Upload__e event');
                } else {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('====== Platform Event Publish Error for PT_CPL_Document_Upload__e returned: ' +
                              err.getStatusCode() +
                              ' - ' +
                              err.getMessage());
                    }
                }
            }
        }
        
        if (attachIds.size() > 0) {
            delete [SELECT Id FROM Attachment WHERE Id IN :attachIds];
        }
    }
}