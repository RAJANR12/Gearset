global with sharing class L2I_CalculatorCallback implements SBQQ.CalculateCallback {
    
    global void callback(String quoteJSON){
        SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver', quoteJSON);       
    }
    
}