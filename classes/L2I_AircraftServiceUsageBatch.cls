/**
 *      @author       Sarah Kennedy
 *      @date         03/16/2020
 *      @description  Batch processing for Daily Usage creation.
 *                    L2I_ASAggregateResultIterator class and L2I_ASAggregateResultIterable class are used
 *                    in allowing aggregate SOQL in this batch
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 01/03/2020         Initial creation based on https://help.salesforce.com/articleView?id=000333422&type=1&mode=1
 */
global class L2I_AircraftServiceUsageBatch implements Database.Batchable<AggregateResult> {
    
    L2I_Usage_Batch_Setting__c usageBatchSetting = [
          SELECT Batch_Run_Date__c
          FROM L2I_Usage_Batch_Setting__c
    ];
    
    Date BATCH_RUN_DATE = usageBatchSetting.Batch_Run_Date__c;
    
    
    global Iterable<AggregateResult> start(Database.BatchableContext bc) {
        System.debug('*** BATCH_RUN_DATE ' + BATCH_RUN_DATE);
        return new L2I_ASAggregateResultIterable(BATCH_RUN_DATE);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
//        for (sObject s : scope) {
//            System.debug('----------' + s);
//        }
        if (BATCH_RUN_DATE <= Date.today()) {
            if (scope.size() > 0) {
                L2I_CreateUsageRecords.createUsageRecords((AggregateResult[]) scope, BATCH_RUN_DATE);
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        
        if (BATCH_RUN_DATE <= Date.today()) {
            
            usageBatchSetting.Batch_Run_Date__c = usageBatchSetting.Batch_Run_Date__c + 1;
            update usageBatchSetting;
            
            if (usageBatchSetting.Batch_Run_Date__c < Date.Today()) {
                
                Integer batchSize = Integer.valueOf([
                      SELECT Usage_Batch_Size__c
                      FROM L2I_General_Settings__mdt
                      LIMIT 1
                ].Usage_Batch_Size__c);
                
                System.debug('run again if needed: ' + usageBatchSetting.Batch_Run_Date__c);
                L2I_AircraftServiceUsageBatch b = new L2I_AircraftServiceUsageBatch();
                Database.executeBatch(b, batchSize);
            }
        }
    }
}