public class PT_CloneQuoteWithRelatedController {
    
    Id quoteId;
    
    public PT_CloneQuoteWithRelatedController(ApexPages.StandardController stdController) {
        this.quoteId = stdController.getId();
    }
    
    public PageReference cloneQuote() {
        System.debug(this.quoteId);
        List<SBQQ__Quote__c> cloneQuote;
        try {
            cloneQuote = L2I_QuoteCloneUtility.cloneSBQQQuotes(new Set<String>{this.quoteId});
            return new PageReference('/'+cloneQuote[0].Id);
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }

}