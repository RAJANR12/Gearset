global class PT_PLG_Invoke_Revise {
    
    
     @InvocableMethod(label='Process Parts List Revise'
        description='Quote Revise / Merge Parts List')
    public static List<Results> ProcessPartsList (List<Requests> requests)
    {
        string quoteobj = (requests == null) || (requests[0].quoteobj == null) ? null : requests[0].quoteobj;
        String attachobj = (requests == null) || (requests[0].attachobj == null) ?  null : requests[0].attachobj;
        system.debug('Requests '+Requests);
        //L2I_PrecisionTailCountUtils(quoteobj,batchName);
        //quotemerge(quoteobj,attachobj);
        //OR
        //quoterevise(quoteobj,attachobj);
        
        List<SBQQ__Quote__c> clonedQuotes = L2I_QuoteCloneUtility.cloneSBQQQuotes(new Set<String>{quoteobj});
        
        

        Results thisResult = new Results();
        //thisResult.totaledProductUsageSummaries = L2I_OrderData.usageSummaries;
        //thisResult.trueUpUsages = L2I_OrderData.trueUpUsages;
        //thisResult.affectedOrders = getAffectedOrders(batchName);
        //thisResult.errorMessages = L2I_PrecisionTailCountUtils.getErrorMessages();
        thisResult.quotes = clonedQuotes;
        List<Results> linkageVar = new List<Results> {thisResult};
        system.debug('linkageVar '+linkageVar);    
        return linkageVar;
    }
    
    


    global class Requests {
        @InvocableVariable
        global String quoteobj;

        @InvocableVariable
        global String attachobj;
    }
    
    global class Results {
        @InvocableVariable
    	global List<Attachment> attachments;

        @InvocableVariable
        global List<SBQQ__Quote__c> quotes;

        @InvocableVariable
        global List<String> errorMessages;
    }    

}