global class L2I_AircraftServiceUsageBatch_MOD implements Database.Batchable<AggregateResult> {

    
    public final String ORDER_ID;
    public final Date BATCH_RUN_DATE;
    
    global L2I_AircraftServiceUsageBatch_MOD(Id orderId, Date runDate){
        BATCH_RUN_DATE = runDate;
        ORDER_ID = orderId;
    }
    
    global Iterable<AggregateResult> start(Database.BatchableContext bc) {
        System.debug('*** BATCH_RUN_DATE ' + BATCH_RUN_DATE);
        return new L2I_ASAggregateResultIterable(BATCH_RUN_DATE);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        if (BATCH_RUN_DATE <= Date.today() && ORDER_ID != NULL) {
            if (scope.size() > 0) {
                L2I_CreateUsageRecords_MOD.createUsageRecords((AggregateResult[]) scope, BATCH_RUN_DATE,ORDER_ID);
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}