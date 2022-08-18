global class L2I_AircraftServiceAdjUsageBatch implements Database.Batchable<sObject> {
    
    L2I_Usage_Batch_Setting__c usageBatchSetting = [SELECT Batch_Run_Date__c 
                                                    FROM L2I_Usage_Batch_Setting__c];
    
    Date BATCH_RUN_DATE = usageBatchSetting.Batch_Run_Date__c;
    
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
            
            if(affectedAircraftServices.size() > 0) {
                System.debug('affectedAircraftServices: ' + affectedAircraftServices);
                L2I_CreateUsageRecords.reconcileUsageRecords(affectedAircraftServices, BATCH_RUN_DATE);
            }
            
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
		
		Integer batchSize = Integer.valueOf([SELECT Usage_Batch_Size__c 
                                             FROM L2I_General_Settings__mdt 
                                             LIMIT 1].Usage_Batch_Size__c);
        
        L2I_AircraftServiceUsageBatch b = new L2I_AircraftServiceUsageBatch();
        Database.executeBatch(b, batchSize);
        
    }

}