public with sharing class QuoteExtController {
    private Id quoteId;
    private SBQQ__Quote__c quote;
    public QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
        quote = [Select Id,L2I_Verified_ConnectivityPriceCost__c,L2I_Verified_LiveTelevisionPriceCost__c,L2I_Verified_MediaServicesPriceCost__c,L2I_Reviewed_PO_Required__c, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.RecordTypeId From SBQQ__Quote__c Where id =: quoteId];
    }
    public PageReference onSubmit() {
        Boolean validationFailed = false;
        Set<String> validationProds = new Set<String>();
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>([Select Id From SBQQ__QuoteLine__c Where SBQQ__Quote__c =:quoteId]);
        
        if(quoteLines.size() == 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You cannot finalize a quote without products'));
        }
        
        for(SBQQ__QuoteLine__c ql: [Select Id, SBQQ__RequiredBy__r.SBQQ__ProductCode__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c =:quoteId and SBQQ__ProductCode__c like '%YYYY']) {
            validationProds.add(ql.SBQQ__RequiredBy__r.SBQQ__ProductCode__c);
        }
        String errMsg;
        for(String pCode: validationProds) {
            if(pCode == 'MediaSvcs-Bundle' && !quote.L2I_Verified_MediaServicesPriceCost__c) {
                errMsg = (errMsg == null) ? 'Media Services, ': errMsg+'Media Services, ';
            } else if(pCode == 'ConnectivitySvcsWiFi-Bundle' && !quote.L2I_Verified_ConnectivityPriceCost__c) {
                errMsg = (errMsg == null) ? 'Connectivity, ': errMsg+'Connectivity, ';
            } else if(pCode == 'LiveTV-Bundle' && !quote.L2I_Verified_LiveTelevisionPriceCost__c) {
                errMsg = (errMsg == null) ? 'Live Television, ': errMsg+'Live Television, ';
            }
        }
        if(errMsg != null) {
            errMsg = errMsg.subString(0, errMsg.trim().length()-1);
            errMsg = 'Have you verified all '+errMsg+' YYYY part numbers are accurately populated with cost and price? If so, please check the Verified '+errMsg+' Price/Cost checkbox';
            System.debug(errMsg);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errMsg));
            validationFailed = true;
        }
        
        Set<Id> oppRecTypes = new Set<Id>();
        for(String recType: L2I_JSON_Settings.getSpecificSettingCollection('Order_Creation_Settings','Opp_Type_Exclude_PO_Req')) {
            oppRecTypes.add(Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get(recType).getRecordTypeId());
        }
        System.debug(oppRecTypes);
        if(!quote.L2I_Reviewed_PO_Required__c && (quote.SBQQ__Opportunity2__c == null || (quote.SBQQ__Opportunity2__c != null && !oppRecTypes.contains(quote.SBQQ__Opportunity2__r.RecordTypeId)))) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please check that you have reviewed the PO Required checkbox on your quote before submitting for approval'));
            validationFailed = true;
        }
        List<SBQQ__QuoteLine__c> qls = new List<SBQQ__QuoteLine__c>([Select Id, SBQQ__ProductCode__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c =:quoteId AND SBQQ__ProductCode__c in ('TBD-Recurring','TBD-OneTime') AND (SBQQ__NetTotal__c = 0 OR SBQQ__NetTotal__c = null)]);
        String partNumbers;
        
        if(qls.size() > 0) {
            for(SBQQ__QuoteLine__c ql: qls) {
                partNumbers = (partNumbers != null) ? partNumbers+','+ql.SBQQ__ProductCode__c : ql.SBQQ__ProductCode__c;
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a price for Placeholder Part:'+partNumbers+' in order to submit your quote'));
            validationFailed = true;
        }
        if(validationFailed)
            return null;
        if (quoteId != null) {
            SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
        }
        return new PageReference('/' + quoteId);
    }
    public PageReference onRecall() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
        }
        return new PageReference('/' + quoteId);
    }
}