global class L2I_AutomateExistingDealOppSched implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        Integer batchSize = Integer.valueOf([SELECT Usage_Batch_Size__c 
                                             FROM L2I_General_Settings__mdt 
                                             LIMIT 1].Usage_Batch_Size__c);
        System.debug('batchSize: ' + batchSize);
        
        L2I_AutomateExistingDealOppBatch b = new L2I_AutomateExistingDealOppBatch();
        
        database.executebatch(b, 200);
    }
    
}