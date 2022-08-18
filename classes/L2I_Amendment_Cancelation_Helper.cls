public class L2I_Amendment_Cancelation_Helper {
    
    /*@InvocableMethod(Label = 'Create Amendment and CancelLines')
    public static List<Id> contractAmendment(List<Id> contractId) {
        L2I_ContractAmender amender = new L2I_ContractAmender();
        L2I_QuoteModel quote = amender.load(contractId[0]);
        calculateTotalAircrafts(quote.record.Id);
        cancelAllLines(quote.record.Id);
        
        // submit quote calculation
        L2I_QuoteCalculator quoteCalc = new L2I_QuoteCalculator();
        quoteCalc.calculate(quote, 'L2I_CalculatorCallback');
        
        finalizeQuote(quote.record);
        
        return new List<Id>{quote.record.SBQQ__Opportunity2__c};
    }*/
    
    @InvocableMethod(Label = 'Create Amendment and CancelLines')
    public static List<SBQQ__Quote__c> contractAmendment(List<Id> contractId) {
        L2I_ContractAmender amender = new L2I_ContractAmender();
        L2I_QuoteModel quote = amender.load(contractId[0]);
        calculateTotalAircrafts(quote.record.Id);
        cancelAllLines(quote.record.Id);
        return new List<SBQQ__Quote__c>{quote.record};
        //return new List<Id>{quote.record.SBQQ__Opportunity2__c};
    }
    
    private static void calculateTotalAircrafts(Id quoteId) {
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quoteId);
    }
    
    @testVisible
    private static void cancelAllLines(Id quoteId) {
        //List<L2I_AmendmentRefundController.QuoteLineWrapper> lines = L2I_AmendmentRefundController.getQuoteLines(quoteId);
        List<SBQQ__QuoteLine__c> cancelLines = getCancelLines(quoteId);
        for(SBQQ__QuoteLine__c ql: cancelLines) {
            ql.SBQQ__Quantity__c = 0;
            ql.SBQQ__BundledQuantity__c = 0;
        }
        update cancelLines;
    }
    
    private static List<SBQQ__QuoteLine__c> getCancelLines(Id quoteId) {
        List<SBQQ__QuoteLine__c> cancelLines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qLines = new List<SBQQ__QuoteLine__c>([Select Id, Name, SBQQ__Product__c, SBQQ__ProductCode__c, SBQQ__Quantity__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.Name, SBQQ__Quote__r.SBQQ__Type__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c =: quoteId ]);
        
        Set<Id> prodIds = new Set<Id>();
        for(SBQQ__QuoteLine__c ql: qLines) {
            prodIds.add(ql.SBQQ__Product__c);
        }
        Map<Id, Product2> prodMap = new Map<Id, Product2>([Select Id, Name, (Select Id From SBQQ__Options__r) From Product2 Where Id in :prodIds]);
        
        for(SBQQ__QuoteLine__c ql: qLines) {
            Boolean bundle = (prodMap.get(ql.SBQQ__Product__c) != null && prodMap.get(ql.SBQQ__Product__c).SBQQ__Options__r != null && prodMap.get(ql.SBQQ__Product__c).SBQQ__Options__r.size() > 0) ? True : False;
            if(ql.SBQQ__RequiredBy__c != null || !bundle) {
              cancelLines.add(ql);
            }
        }
        return cancelLines;
    }
    
    /*public static void finalizeQuote(SBQQ__Quote__c quote) {
        quote.SBQQ__Status__c = 'Approved';
        update quote;
    }*/

}