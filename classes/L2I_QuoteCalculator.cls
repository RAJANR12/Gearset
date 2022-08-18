public with sharing class L2I_QuoteCalculator {     
    
    public void calculate(L2I_QuoteModel quote, String callbackClass) {
        QuoteCalculatorContext ctx = new QuoteCalculatorContext(quote, callbackClass);
        SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteCalculator', null, JSON.serialize(ctx));    
    }    
    
    private class QuoteCalculatorContext {        
        private L2I_QuoteModel quote; //The quote and callbackClass properties are called in the API code by the exact names seen here.
        private String callbackClass; //Altering these property names will cause calculator API calls to fail.
        
        private QuoteCalculatorContext(L2I_QuoteModel quote, String callbackClass) {
            this.quote = quote;            
            this.callbackClass = callbackClass;        
        }
    } 
}