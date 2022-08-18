global class L2I_AircraftServiceUsageSchedulable implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        Integer batchSize = Integer.valueOf([SELECT Usage_Batch_Size__c 
                                             FROM L2I_General_Settings__mdt 
                                             LIMIT 1].Usage_Batch_Size__c);
        System.debug('batchSize: ' + batchSize);
        
        L2I_AircraftServiceUsageBatch b = new L2I_AircraftServiceUsageBatch();
        
        database.executebatch(b, batchSize);
        
    }
    
}