/**
 *      @author       Nitin Gupta
 *      @date         12/08/2020
 *      @description  Trigger Handler for Synchronize_Parts_List__e Object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Nitin Gupta               12/08/2020         Initial scaffold
 */
trigger PT_SynchronizePartsListEventTrigger on Synchronize_Parts_List__e (after insert) {
    new PT_SyncPartsListEvent_TriggerHandler().run();
}