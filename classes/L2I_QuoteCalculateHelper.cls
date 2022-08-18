public class L2I_QuoteCalculateHelper {
    
    @InvocableMethod(Label = 'Calculate Quote')
    public static void calculateQuote(List<Id> quoteId) {
        // Calculate quote totals
        /*String quoteJSON = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quoteId[0]);
        L2I_QuoteModel quoteModel = (L2I_QuoteModel) JSON.deserialize(quoteJSON, L2I_QuoteModel.class);
		
        L2I_QuoteCalculator quoteCalc = new L2I_QuoteCalculator();
        quoteCalc.calculate(quoteModel, 'L2I_CalculatorCallback');*/
        
        DateTime systemTime = System.now().addSeconds(15);
        String cron = systemTime.second() + ' ' + systemTime.minute() + ' ' + systemTime.hour() + ' ' + systemTime.day() + ' ' + systemTime.month() + ' ? ' + systemTime.year();
        System.schedule('QuoteCalculateJob - '+quoteId[0], cron, new L2I_QuoteCalculationSchedule(quoteId[0]));
    }

}