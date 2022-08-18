/**
 *      @author       Sarah Kennedy
 *      @date         07/16/2020
 *      @description  L2I_CaseMgmtFromCROrderSched - Process Orders that have been created from Create Order flow
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 07/16/2020         Initial scaffold
 *
 */
global class L2I_CaseMgmtFromCROrderSched implements Schedulable {
    private String logGuid;
    private List<Id> quoteIds;
    
    public L2I_CaseMgmtFromCROrderSched(String guid, List<Id> quoteIdList) {
        logGuid = guid;
        quoteIds = quoteIdList;
    }
    
    public void execute(SchedulableContext sc) {
        System.debug('*** Starting L2I_CaseMgmtFromCROrderSched - calling L2I_CaseMgmtFromCROrderBatch with quoteIds ' + quoteIds);
        Integer BatchSize = Integer.valueOf (
              L2I_JSON_Settings.getSpecificSetting('Aircraft_Services_Management_Settings',
                    'ProcessOrderBatchSize'));
        Database.executeBatch(new L2I_CaseMgmtFromCROrderBatch(quoteIds), batchSize);
        
        // cleanup the job
        System.debug('*** L2I_CaseMgmtFromCROrderSched calling Platform Event to clear jobs ' + logGuid);
        L2I_UtilityHelper.publishOrderActivationCompletedEvent(String.valueOf(logGuid));
        Datetime now = System.now();
        Integer minsOffset = 1; // Schedule it a minute after the final batch has been completed.
        String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
    }
}