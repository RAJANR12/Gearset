/**
 *  @author       Sarah Kennedy
 *  @date         12/08/2020
 *  @description  PT_QuoteDocGeneration class
 *
 *  Modification Log:
 *  ------------------------------------------------------------------------------------
 *  Developer                       Date                Description
 *  ------------------------------------------------------------------------------------
 *  Sarah Kennedy                  12/08/2020         Initial scaffold
 *
 */

public without sharing class PT_QuoteDocGeneration {
    
    @AuraEnabled
    public static void genDoc(Id oppId) {
        List<FlowInput> fiList = new List<FlowInput>();
        FlowInput fi = new FlowInput();
        fi.oppIdToProcess = oppId;
        fiList.add(fi);
        genQuoteDoc(fiList);
    }
    
    @InvocableMethod(Label = 'Generate Quote Proposal')
    public static void genQuoteDoc(List<FlowInput> inputs) {
        String oppId;
        System.debug('*** Starting PT_QuoteDocGeneration.genQuoteDoc ' + inputs);
    
        if (inputs == null) {
            System.debug('*** Flow inputs is null ');
            return;
        }
        for (FlowInput inId : inputs) {
            oppId = inId.oppIdToProcess;
        }
    
        if (oppId == null) {
            System.debug('*** oppId is null ');
            return;
        }
    
        System.debug('*** oppId ' + oppId);
 
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [
              SELECT Id, PT_Current_Parts_List__c, PT_Part_List_Name_Rev__c, L2I_Program_Num__r.Program_Number__c,
                    StageName, PT_Is_PPL__c, PT_Is_CPL__c, L2I_Delivery_Schedule__c,
                    Name, PT_Program_Mgr__r.Email, PT_Program_Mgr__r.Name,
                    PT_PL_Approval_Approver__r.Name, PT_PL_Approval_Approver_Comments__c,
                    PT_PL_Approval_Submitter__r.Name, PT_PL_Approval_Submitter_Comments__c,
                    PT_Part_List_Name__c, PT_Revised_Parts_List_Version_Trans__c,
                    PT_PL_Approval_Date__c, SBQQ__PrimaryQuote__c, PT_Part_List_Document_Generated__c
              FROM Opportunity
              WHERE Id = :oppId
        ];
        
        if (oppList.isEmpty() || oppList.size() == 0){
            System.debug('*** PL Opportunity is null ');
            return;
        }
        
        Opportunity opp = oppList[0];
        
        if (opp.SBQQ__PrimaryQuote__c == null) {
            System.debug('*** opp.SBQQ__PrimaryQuote__c is null ');
            return;
        }
        
         String quoteId = opp.SBQQ__PrimaryQuote__c;
        System.debug('*** quoteId ' + quoteId);
        
        opp.PT_Current_Parts_List__c = quoteId;
        update opp;
        
        // generate CPL/PPL document
        // create the CPL Integration document
        // to be used for creating CPL document to send to PAC Agile (W-001777)
        System.debug('*** before gendoc');
        System.debug('*** PT_Part_List_Name_Rev__c ' + opp.PT_Part_List_Name_Rev__c);
        if (opp.StageName == 'Delivery' &&
              quoteId != null &&
              !String.isBlank(opp.PT_Part_List_Name_Rev__c)) {
            String fileName = '';
            PageReference pdf;
            pdf = Page.PT_PartsListPDF;
            fileName = opp.PT_Part_List_Name_Rev__c + '.pdf';
            pdf.getParameters().put('id', opp.Id);

            // attach to Opportunity
            Blob body;
            if(Test.isRunningTest()) {
                body = blob.valueOf('Unit.Test');
            } else {
                body = pdf.getContentAsPDF();
            }
            
            Attachment attachmentPDF = new Attachment();
            attachmentPDF.ParentId = opp.Id;
            attachmentPDF.Name = fileName;
            attachmentPDF.Body = body; //This creates the PDF content
            insert attachmentPDF;
            System.debug('*** after gendoc atttachment created');
    
            // generate the XLS ===========================================
            try{
            System.debug('*** generating xls');
            String fileNameX = '';
            PageReference xls;
//            xls = Page.PT_PartsListXLS;
                xls = Page.PT_PartsListMSXLS;
            System.debug('*** xls ' + xls);
            fileNameX = opp.PT_Part_List_Name_Rev__c + ' XLS.xls';
            xls.getParameters().put('id', opp.Id);
    
            // attach to Opportunity
            if(Test.isRunningTest()) {
                body = blob.valueOf('Unit.Test');
            } else {
                body = xls.getContent();
            }
            System.debug('*** body ' + body);
            Attachment attachmentXLS = new Attachment();
            attachmentXLS.ParentId = opp.Id;
            attachmentXLS.Name = fileNameX;
            attachmentXLS.Body = body; //This creates the XLS content
            insert attachmentXLS;
            System.debug('*** attachmentXLS ' + attachmentXLS);
            } catch (Exception e){
                System.debug('*** Error generating Final XLS Part List document: ' + e.getMessage());
            }
            // ================================================================
    
            // call future method of generate the PDF and attach it to the PL Opportunity
//            PT_GenerateCPLDocCall.callGenerateCPLDoc(opp.Id, opp.PT_Part_List_Name_Rev__c, UserInfo.getSessionId());

            System.debug('*** PT_QuoteDocGeneration - generated QuoteProposal for quoteId: ' + quoteId +
                  ' StageName: ' + opp.StageName +
                  ' CPL Name: ' + opp.PT_Part_List_Name_Rev__c);
            
            // save the quoteId for updating the TagCsv field on the ContentVersion when the
            // quote doc -> Attachment -> ContentVersion is created (via a setting in CPQ)
            System.debug('*** updating opp.PT_Current_Parts_List__c ');
            opp.PT_Part_List_Document_Generated__c = true;
            opp.PT_PL_Document_Generation_Status__c = 'Completed'; // Added by Khrisna for W-003113
            update opp;
            System.debug('*** updating opp.PT_Current_Parts_List__c opp ' + opp);
            // serialize the PL Data and add as files to the Opportunity
            System.debug('*** calling PT_OpportunityService.serializeOppShipset ');
//            PT_OpportunityService.serializeOppShipset(opp, quoteId);
        } else {
            System.debug('*** PT_QuoteDocGeneration - Was not generateQuoteProposal for quoteId: ' + quoteId +
                  ' StageName: ' + opp.StageName +
                  ' CPL Name: ' + opp.PT_Part_List_Name_Rev__c);
        }
        System.debug('*** Exiting PT_QuoteDocGeneration.genQuoteDoc ' + quoteId);
    }
    
    public class FlowInput {
        @InvocableVariable
        public String oppIdToProcess;
    }
    
//    @AuraEnabled
//    public static Boolean getInProcessStatus(Id oppId) {
//        return [Select Id, Name, PT_PL_Batch_In_Process__c From Opportunity Where Id =: oppId].PT_PL_Batch_In_Process__c;
//    }
}