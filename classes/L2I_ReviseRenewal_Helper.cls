public class L2I_ReviseRenewal_Helper {
    
    @InvocableMethod(Label = 'Calculate Aircraft Months and Quote')
    public static List<Id> contractAmendment(List<Id> contractId) {
        Contract contract = [Select Id, SBQQ__RenewalOpportunity__c From Contract Where Id =: contractId[0]];
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c Where SBQQ__Opportunity2__c =: contract.SBQQ__RenewalOpportunity__c];
        
        // Calculate Total Aircraft Service Months on Quote
        L2I_QuoteService.calculateTotalAircraftServiceMonths(quote.Id);
        
        // Calculate quote totals
        String quoteJSON = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quote.Id);
        L2I_QuoteModel quoteModel = (L2I_QuoteModel) JSON.deserialize(quoteJSON, L2I_QuoteModel.class);
		
        L2I_QuoteCalculator quoteCalc = new L2I_QuoteCalculator();
        quoteCalc.calculate(quoteModel, 'L2I_CalculatorCallback');
        
        return new List<Id>{contract.SBQQ__RenewalOpportunity__c};
    }

}