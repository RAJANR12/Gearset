public class PT_CalculateQuote {
    @InvocableMethod
    public static void invokeCalculateQuote (List<Requests> requests) {
        if (requests[0].quoteId != null) {
            CPQ_ApiDataModels.QuoteModel quoteModel = CPQ_ApiWrapper.getQuoteModel(requests[0].quoteId);
            CPQ_ApiWrapper.calculateQuote(quoteModel);
        }
    }

    public class Requests {
        @InvocableVariable
        public Id quoteId;
    }
}