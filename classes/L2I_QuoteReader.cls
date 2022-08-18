public with sharing class L2I_QuoteReader {
    
    public L2I_QuoteModel read(String quoteId) {
        String quoteJSON = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quoteId);
        return (L2I_QuoteModel) JSON.deserialize(quoteJSON, L2I_QuoteModel.class);
    }
}