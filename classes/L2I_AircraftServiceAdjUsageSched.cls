global class L2I_AircraftServiceAdjUsageSched implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        Integer batchSize = Integer.valueOf([SELECT Adjustment_Usage_Batch_Size__c 
                                             FROM L2I_General_Settings__mdt 
                                             LIMIT 1].Adjustment_Usage_Batch_Size__c);
        System.debug('batchSize: ' + batchSize);
        
        L2I_AircraftServiceAdjUsageBatch b = new L2I_AircraftServiceAdjUsageBatch();
        
        database.executebatch(b, batchSize);
        
    }

}