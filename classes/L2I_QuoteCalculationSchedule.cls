public class L2I_QuoteCalculationSchedule implements Schedulable {
    
    private Id quoteId;
    
    public L2I_QuoteCalculationSchedule(Id quoteId) {
        this.quoteId = quoteId;
    }
    
    public void execute(SchedulableContext sc) {
		String quoteJSON = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quoteId);
        L2I_QuoteModel quoteModel = (L2I_QuoteModel) JSON.deserialize(quoteJSON, L2I_QuoteModel.class);
		
        L2I_QuoteCalculator quoteCalc = new L2I_QuoteCalculator();
        quoteCalc.calculate(quoteModel, 'L2I_CalculatorCallback');
        
        String jobName = 'QuoteCalculateJob - '+quoteId;
        CronTrigger cronJob = [Select Id From CronTrigger Where CronJobDetail.Name = :jobName LIMIT 1];
        if(cronJob != null) {System.abortJob(cronJob.Id);}
    }

}