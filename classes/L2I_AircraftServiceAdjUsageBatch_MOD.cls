global class L2I_AircraftServiceAdjUsageBatch_MOD implements Database.Batchable<sObject> {
    
    public final ID ORDER_ID;
    public final Date BATCH_RUN_DATE;
    
    global L2I_AircraftServiceAdjUsageBatch_MOD(Id orderId, String runDate){
        BATCH_RUN_DATE = String.isNotBlank(runDate) ? Date.valueOf(runDate) : NULL;
        ORDER_ID = orderId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator(
            'SELECT Id, ' +
            ' L2I_Activation_Date__c, ' +
            ' L2I_Activation_Adjustment_Needed__c, ' +
            ' L2I_Deactivation_Date__c, ' +
            ' L2I_Deactivation_Adjustment_Needed__c, '+
            ' L2I_When_Activated__c, ' +
            ' L2I_When_Deactivated__c, ' +
            ' Matching_Id__c, Service_Activation_Type__c, L2I_OneTime_Billed__c, ' +
            ' Yearly_Bill_Date__c ' +
            'FROM L2I_Aircraft_Service__c ' +
            'WHERE (((L2I_Activation_Date__c != null AND L2I_Activation_Adjustment_Needed__c = true) ' +
            '  OR (L2I_Deactivation_Date__c != null AND L2I_Deactivation_Adjustment_Needed__c = true)) ' +
            '  AND Service_Activation_Type__c = \'Monthly\') ' +
            '  OR L2I_is_OneTime_Ready__c = true ' +
            '  OR ( L2I_Is_Yearly_Ready__c = true and Yearly_Bill_Date__c <= :BATCH_RUN_DATE )'
        );        
    }
    
    global void execute(Database.BatchableContext bc, List<L2I_Aircraft_Service__c> scope) {
        
        List<L2I_Aircraft_Service__c> affectedAircraftServices = new List<L2I_Aircraft_Service__c>();
        
        if(scope.size() > 0) {            
            for(L2I_Aircraft_Service__c u : scope) {
                affectedAircraftServices.add(u);
            }
            
            if(affectedAircraftServices.size() > 0 && ORDER_ID != NULL && BATCH_RUN_DATE != NULL) {
                L2I_CreateUsageRecords_MOD.reconcileUsageRecords(affectedAircraftServices, BATCH_RUN_DATE, ORDER_ID);
            }            
        }        
    }
    
    global void finish(Database.BatchableContext bc) {        
        if(BATCH_RUN_DATE != NULL && ORDER_ID != NULL){
            L2I_AircraftServiceUsageBatch_MOD b = new L2I_AircraftServiceUsageBatch_MOD(ORDER_ID,BATCH_RUN_DATE);        
            database.executebatch(b, 25); 
        }    
    }
    
}