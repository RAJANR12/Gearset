public class L2I_TotalAircraftServiceMonthsController {
    
    @AuraEnabled
    public static void calculateServiceMonths(Id quoteId) {
    SBQQ__Quote__c quote = [Select Id, SBQQ__Opportunity2__r.L2I_Product_Category__c From SBQQ__Quote__c Where Id =: quoteId];
        if(quote.SBQQ__Opportunity2__r.L2I_Product_Category__c != 'DSS') {
            return;
        }
        try {
            L2I_QuoteService.calculateTotalAircraftServiceMonths(quoteId);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Id contractAmendment(Id contractId) {
        try {
            String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, null);
            L2I_QuoteModel quoteModel = (L2I_QuoteModel) JSON.deserialize(quoteJSON, L2I_QuoteModel.class);
            
            if(quoteModel == null || quoteModel.record == null || quoteModel.record.Id == null) {
                throw new AuraHandledException('Failed to create a quote');
            }
            
            L2I_TotalAircraftServiceMonthsController.calculateServiceMonths(quoteModel.record.Id);
            
            return quoteModel.record.Id;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}