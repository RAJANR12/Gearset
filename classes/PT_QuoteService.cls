/**
 *  @author       Sarah Kennedy
 *  @date         12/08/2020
 *  @description  PT_QuoteService class
 *
 *  Modification Log:
 *  ------------------------------------------------------------------------------------
 *  Developer                       Date                Description
 *  ------------------------------------------------------------------------------------
 *  Sarah Kennedy                  12/08/2020         Initial scaffold
 *
 */

public with sharing class PT_QuoteService {
//    public static void genQuoteDoc(Id quoteId) {
//        System.debug('*** Starting PT_QuoteService.genQuoteDoc ' + quoteId);
//
//        SBQQ__Quote__c q = [
//              SELECT Id, SBQQ__Opportunity2__c
//              FROM SBQQ__Quote__c
//              WHERE Id = :quoteId
//        ];
//
//        if (q.SBQQ__Opportunity2__c == null) {
//            System.debug('*** q.SBQQ__Opportunity2__c is null ');
//            return;
//        }
//
//        Opportunity opp = [
//              SELECT Id, PT_Current_Parts_List__c, PT_Part_List_Name_Rev__c,
//                      L2I_Program_Num__r.Program_Number__c,
//                    StageName, PT_Is_PPL__c, PT_Is_CPL__c, L2I_Delivery_Schedule__c
//              FROM Opportunity
//              WHERE Id = :q.SBQQ__Opportunity2__c
//        ];
//
//        System.debug('*** opp ' + opp);
//
//        // generate CPL/PPL document
//        // create the CPL Integration document
//        // generate quote proposal
//        // to be used for creating CPL document to send to PAC Agile (W-001777)
//        System.debug('*** before gendoc');
//        String documentTemplateId = String.valueOf (
//              L2I_JSON_Settings.getSpecificSetting('CPL_Settings', 'CPLDocTemplateId'));
//
//        if (Test.isRunningTest()) {
//            SBQQ__QuoteTemplate__c qtemplate = new SBQQ__QuoteTemplate__c(Name = 'Test Template');
//            insert qtemplate;
//            documentTemplateId = qtemplate.Id;
//        }
//
//        System.debug('*** PT_Part_List_Name_Rev__c ' + opp.PT_Part_List_Name_Rev__c);
//        System.debug('*** documentTemplateId ' + documentTemplateId);
//        if (opp.StageName == 'Delivery' &&
//              quoteId != null &&
//              !String.isBlank(opp.PT_Part_List_Name_Rev__c) &&
//              !String.isBlank(documentTemplateId)) {
//            L2I_QuoteService.generateQuoteProposal(quoteId, opp.PT_Part_List_Name_Rev__c, documentTemplateId);
//            System.debug('*** L2I_QuoteApprovalController - generated QuoteProposal for quoteId: ' + quoteId +
//                  ' StageName: ' + opp.StageName +
//                  ' CPL Name: ' + opp.PT_Part_List_Name_Rev__c +
//                  ' CPL Document Template Id: ' + documentTemplateId);
//
//            // save the quoteId for updating the TagCsv field on the ContentVersion when the
//            // quote doc -> Attachment -> ContentVersion is created (via a setting in CPQ)
//            System.debug('*** updating opp.PT_Current_Parts_List__c ');
//            opp.PT_Current_Parts_List__c = quoteId;
//            update opp;
//            System.debug('*** updating opp.PT_Current_Parts_List__c opp ' + opp);
//            // serialize the PL Data and add as files to the Opportunity
//            System.debug('*** calling PT_OpportunityService.serializeOppShipset ');
//            PT_OpportunityService.serializeOppShipset(opp, quoteId);
//        } else {
//            System.debug('*** L2I_QuoteApprovalController - Was not generateQuoteProposal for quoteId: ' + quoteId +
//                  ' StageName: ' + opp.StageName +
//                  ' CPL Name: ' + opp.PT_Part_List_Name_Rev__c +
//                  ' CPL Document Template Id: ' + documentTemplateId);
//        }
//    }
}