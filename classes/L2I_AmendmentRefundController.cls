public class L2I_AmendmentRefundController {
        
    @AuraEnabled
    public static List<QuoteLineWrapper> getQuoteLines(Id quoteId) {
        List<SBQQ__QuoteLine__c> qLines = new List<SBQQ__QuoteLine__c>([Select Id, Name, SBQQ__Product__c, SBQQ__ProductCode__c, SBQQ__Quantity__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.Name, SBQQ__Quote__r.SBQQ__Type__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c =: quoteId ]);
        if(!qLines.isEmpty() && qLines[0].SBQQ__Quote__r.SBQQ__Type__c != 'Amendment') {
            AuraHandledException e = new AuraHandledException('You can only cancel the lines for an Amendment quote');
            e.setMessage('You can only cancel the lines for an Amendment quote');
            throw e;
        }
        Set<Id> prodIds = new Set<Id>();
        for(SBQQ__QuoteLine__c ql: qLines) {
            prodIds.add(ql.SBQQ__Product__c);
        }
        Map<Id, Product2> prodMap = new Map<Id, Product2>([Select Id, Name, (Select Id From SBQQ__Options__r) From Product2 Where Id in :prodIds]);
        List<QuoteLineWrapper> qls = new List<QuoteLineWrapper>();
        for(SBQQ__QuoteLine__c ql: qLines) {
            qls.add(new QuoteLineWrapper(ql, ((prodMap.get(ql.SBQQ__Product__c) != null && prodMap.get(ql.SBQQ__Product__c).SBQQ__Options__r != null && prodMap.get(ql.SBQQ__Product__c).SBQQ__Options__r.size() > 0) ? True : False)));
        }
        return qls;
    }
    
    @AuraEnabled
    public static void submitForRefund(List<SBQQ__QuoteLine__c> quoteLines) {
        system.debug(quoteLines);
        List<SBQQ__QuoteLine__c> qLines = [Select Id, Name, SBQQ__PriorQuantity__c, SBQQ__UpgradedQuantity__c, SBQQ__Quantity__c, SBQQ__OptionType__c From SBQQ__QuoteLine__c Where Id in: quoteLines and SBQQ__SubscriptionType__c != 'One-time'] ;
        //List<SBQQ__QuoteLine__c> qLines = [Select Id, Name, SBQQ__PriorQuantity__c, SBQQ__UpgradedQuantity__c, SBQQ__Quantity__c, SBQQ__OptionType__c From SBQQ__QuoteLine__c Where Id in: quoteLines and SBQQ__RequiredBy__c = null];
        system.debug(qLines);
        for(SBQQ__QuoteLine__c ql: qLines) {
            //ql.SBQQ__UpgradedQuantity__c = ql.SBQQ__PriorQuantity__c * -1;
            ql.SBQQ__Quantity__c = 0;
            ql.SBQQ__BundledQuantity__c = 0;
            //ql.SBQQ__OptionType__c = 'Related Product';
        }
        try {
            update qLines;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class QuoteLineWrapper {
        @AuraEnabled
        public SBQQ__QuoteLine__c ql {get; set;}
        @AuraEnabled
        public Boolean bundle {get; set;}
        
        public QuoteLineWrapper(SBQQ__QuoteLine__c ql, Boolean bundle) {
            this.ql = ql;
            this.bundle = bundle;
        }
    }

}