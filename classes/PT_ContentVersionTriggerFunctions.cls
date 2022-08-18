/**
 *      @author       Sarah Kennedy
 *      @date         09/27/2020
 *      @description  Trigger Functions for ContentVersionTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy               09/27/2020          Initial scaffold
 */
public with sharing class PT_ContentVersionTriggerFunctions {
    
    public static void contentVersionToQuote(List<ContentVersion> newContentVersionList,
          Map<Id, ContentVersion> oldContentVersionMap) {
        Set<String> cvIds = new Set<String>();
        Set<String> cvReadyIds = new Set<String>();
        Map<String, ContentVersion> quoteCVMap = new Map<String, ContentVersion>();
        Map<String, ContentVersion> quoteCVReadyMap = new Map<String, ContentVersion>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quoteReadyList = new List<SBQQ__Quote__c>();
        List<PT_CPL_Document_Upload__e> cplList = new List<PT_CPL_Document_Upload__e>();
        
        for (ContentVersion cv : newContentVersionList) {
            System.debug('*** cv ' + cv);
            ContentVersion oldCV = oldContentVersionMap.get(cv.Id);
            System.debug('*** oldCV ' + oldCV);
            
            if (cv.PT_IntegrationType__c == 'CPL' &&
                  (cv.PT_CPL_External_ControlId__c != oldCV.PT_CPL_External_ControlId__c ||
                        cv.PT_IntegrationMessage__c != oldCV.PT_IntegrationMessage__c ||
                        cv.PT_IntegrationStatus__c != oldCV.PT_IntegrationStatus__c)) {
                cvIds.add(cv.Id);
                System.debug('*** cv.PT_IntegrationStatus__c ' + cv.PT_IntegrationStatus__c);
                if (cv.PT_IntegrationStatus__c != oldCV.PT_IntegrationStatus__c &&
                      cv.PT_IntegrationStatus__c == 'Ready To Integrate') {
                    cvReadyIds.add(cv.Id);
                    System.debug('*** cvReadyIds ' + cvReadyIds);
                }
            }
            if (!cvIds.isEmpty()) {
                // requery as TagCsv was not coming in with a value from Mulesoft
                for (ContentVersion cv2 : [
                      SELECT Id, TagCsv, PT_CPL_External_ControlId__c, PT_IntegrationMessage__c, PT_IntegrationStatus__c,
                            FirstPublishLocationId, ContentDocumentId
                      FROM ContentVersion
                      WHERE Id IN :cvIds
                ]) {
                    System.debug('*** cv2.TagCsv ' + cv2.TagCsv);
                    if (!String.isBlank(cv2.TagCsv)) {
                        String [] splitCsv = cv2.TagCsv.split(',');
                        String quoteId = '';
                        for (String s : splitCsv) {
                            if (s.startsWith('SBQQ__Quote__c')) {
                                String [] splitQuote = s.split(':');
                                if (!splitQuote.isEmpty() &&
                                      splitQuote.size() == 2) {
                                    quoteId = splitQuote[1];
                                }
                            }
                        }
                        if (quoteId != '') {
                            quoteCVMap.put(quoteId, cv2);
    
                            System.debug('*** cv2.Id ' + cv2.Id);
                            if (cvReadyIds.contains(cv2.Id)) {
                                quoteCVReadyMap.put(quoteId, cv2);
                            }
                        }
                    }
                }
            }
        }
        System.debug('*** quoteCVMap.size() ' + quoteCVMap.size());
        
        if (!quoteCVMap.isEmpty()) {
            quoteList = [
                  SELECT Id, PT_CPL_External_ControlId__c, PT_CPL_IntegrationMessage__c, PT_CPL_IntegrationStatus__c,
                        SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c
                  FROM SBQQ__Quote__c
                  WHERE Id IN :quoteCVMap.keySet()
            ];
            
            for (SBQQ__Quote__c q : quoteList) {
                q.PT_CPL_External_ControlId__c = quoteCVMap.get(q.Id).PT_CPL_External_ControlId__c;
                q.PT_CPL_IntegrationMessage__c = quoteCVMap.get(q.Id).PT_IntegrationMessage__c;
                q.PT_CPL_IntegrationStatus__c = quoteCVMap.get(q.Id).PT_IntegrationStatus__c;
            }
            System.debug('*** quoteList ' + quoteList);
            if (quoteList.size() > 0) {
                update quoteList;
            }
        }
        
        if (!quoteCVReadyMap.isEmpty()) {
            quoteReadyList = [
                  SELECT Id, SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c
                  FROM SBQQ__Quote__c
                  WHERE Id IN :quoteCVReadyMap.keySet()
            ];
            for (SBQQ__Quote__c q : quoteReadyList) {
                PT_CPL_Document_Upload__e cpl = new PT_CPL_Document_Upload__e();
                cpl.ContentDocumentId__c = quoteCVReadyMap.get(q.Id).ContentDocumentId;
                cpl.ContentVersionId__c = quoteCVReadyMap.get(q.Id).Id;
                cpl.OpportunityId__c = quoteCVReadyMap.get(q.Id).FirstPublishLocationId;
                cpl.QuoteId__c = q.Id;
                cpl.DSHId__c = q.SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c;
                System.debug('*** cpl ' + cpl);
                cplList.add(cpl);
            }
        }
        
        if (cplList != NULL &&
              cplList.size() > 0) {
            List<Database.SaveResult> results = EventBus.publish(cplList);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('====== Successfully published PT_CPL_Document_Upload__e event for Ready To Integrate');
                } else {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('====== Platform Event Publish Error for PT_CPL_Document_Upload__e Ready To Integrate returned: ' +
                              err.getStatusCode() +
                              ' - ' +
                              err.getMessage());
                    }
                }
            }
        }
    }
}