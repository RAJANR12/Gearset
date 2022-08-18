/**
 *      @author       Nitin Gupta
 *      @date         12/08/2020
 *      @description  Trigger Handler for SynchronizePartsListEventTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------ 
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Nitin Gupta               12/08/2020          Initial scaffold
 */


public class PT_SyncPartsListEvent_TriggerHandler extends L2I_TriggerHandler {

    private List<Synchronize_Parts_List__e> newPartsListEventList;

    public PT_SyncPartsListEvent_TriggerHandler() {
        this.newPartsListEventList = (List<Synchronize_Parts_List__e>) Trigger.new;
    }

    public override void afterInsert() {
        PT_SyncPartsListEvent_TriggerFuntions.processPartsListEvent(newPartsListEventList);
    }

}