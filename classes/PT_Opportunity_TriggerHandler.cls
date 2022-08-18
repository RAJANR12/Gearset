/**
 *      @author       Sarah Kennedy
 *      @date         04/28/2020
 *      @description  PT Opportunity Trigger Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 04/27/2020         Added method call createProgramUpdateDSLs from Program Table POC
 *      Michael Straw                  06/29/2021       Added call to preventNonQueueMemberFromApproving
 *
 */
public class PT_Opportunity_TriggerHandler extends L2I_TriggerHandler {

    private Map<Id, Opportunity> newOpportunityMap;
    private List<Opportunity> newOpportunityList;

    private Map<Id, Opportunity> oldOpportunityMap;
    private List<Opportunity> oldOpportunityList;

    public PT_Opportunity_TriggerHandler() {
        this.newOpportunityMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.newOpportunityList = (List<Opportunity>) Trigger.new;

        this.oldOpportunityMap = (Map<Id, Opportunity>) Trigger.oldMap;
        this.oldOpportunityList = (List<Opportunity>) Trigger.old;
    }
    
    //Added by Jan Geronga on 7/29/21 for W-003928: Start
    @TestVisible private static Boolean recursive = true;
    public static Boolean checkRecursive(){
        if (recursive){
            recursive = false;
            return true;
        }
        else{
            return false;
        }
    }
    //Added by Jan Geronga on 7/29/21 for W-003928: End

    public override void beforeUpdate() {
        // valid trigger context vars:
        //     newOpportunityList  (modifiable)
        //     newOpportunityMap
        //     oldOpportunityList
        //     oldOpportunityMap
        //        System.debug('====== executing L2I_Opportunity_TriggerHander::beforeUpdate()');
        if (checkRecursive()){//Added by Jan Geronga on 7/29/21 for W-003928: Start
            PT_Opportunity_TriggerFunctions.setPartListRevision(newOpportunityList, oldOpportunityMap);
            PT_Opportunity_TriggerFunctions.updateCPLName(newOpportunityList);
            PT_Opportunity_TriggerFunctions.updatePPLNameAndProgram(newOpportunityList);
            PT_Opportunity_TriggerFunctions.callUdpateProgramAircrafts(newOpportunityList, oldOpportunityMap);
            PT_Opportunity_TriggerFunctions.syncQuoteLinesWithProgPriceList(newOpportunityList, oldOpportunityMap);
            PT_Opportunity_TriggerFunctions.preventSubmitterFromApproving(newOpportunityList, oldOpportunityMap);
            PT_Opportunity_TriggerFunctions.preventNonQueueMemberFromApproving(newOpportunityList, oldOpportunityMap);
            PT_Opportunity_TriggerFunctions.updateApprovedDataOnPLOpp(newOpportunityMap, oldOpportunityMap);
            PT_Opportunity_TriggerFunctions.validateStageChange(newOpportunityList, oldOpportunityMap);
            System.debug('***PT_Opportunity_TriggerHandler :: executing resetRejectedRecalled');
            PT_Opportunity_TriggerFunctions.resetRejectedRecalled(newOpportunityList, oldOpportunityMap);
        }//Added by Jan Geronga on 7/29/21 for W-003928: End
    }

    // public override void afterInsert() {
// valid trigger context vars:
//     newOpportunityList  (not modifiable)
//     newOpportunityMap
//        System.debug('====== executing L2I_Opportunity_TriggerHander::afterInsert()');
//    }

    public override void beforeInsert() {
// valid trigger context vars:
//     newOpportunityList  (modifiable)
//        System.debug('====== executing L2I_Opportunity_TriggerHander::beforeInsert()');
        PT_Opportunity_TriggerFunctions.setPartListRevisionInsert(newOpportunityList);
        PT_Opportunity_TriggerFunctions.updateCPLName(newOpportunityList);
        PT_Opportunity_TriggerFunctions.updatePPLNameAndProgram(newOpportunityList);
        PT_Opportunity_TriggerFunctions.clearFieldsWhenCloning(newOpportunityList); // Added by Lipton for W-004007
    }

    public override void afterUpdate() {
// valid trigger context vars:
//     newOpportunityList  (not modifiable)
//     newOpportunityMap
//     oldOpportunityList
//     oldOpportunityMap
        System.debug('====== executing PT_Opportunity_TriggerHander::afterUpdate()');
        PT_Opportunity_TriggerFunctions.createProgramUpdateDSLs(newOpportunityList, oldOpportunityMap);
        System.debug('*** executing resequenceDSLs');
        PT_Opportunity_TriggerFunctions.resequenceDSLs(newOpportunityList, oldOpportunityMap);
        System.debug('*** executing updateProgramRecordType');
        PT_Opportunity_TriggerFunctions.updateProgramRecordType(newOpportunityList);
        System.debug('*** executing createEventForILsAssetsToOppty');
        PT_Opportunity_TriggerFunctions.createEventForILsAssetsToOppty(newOpportunityList, oldOpportunityMap);
        System.debug('*** executing updateAssetsOnPartListApproved');
        PT_Opportunity_TriggerFunctions.partListApproved(newOpportunityList, oldOpportunityMap);
        System.debug('*** executing partListRejectedRecalled');
        PT_Opportunity_TriggerFunctions.partListRejectedRecalled(newOpportunityList, oldOpportunityMap);
        System.debug('*** executing ');
        // PT_Opportunity_TriggerFunctions.splitCPLOpptyToPPLOpptys(newOpportunityList, oldOpportunityMap); // Commented by Lipton for W-004272
        PT_Opportunity_TriggerFunctions.updateProgramLatestPPLRollup(newOpportunityList); // Added by Lipton for W-003404
        PT_Opportunity_TriggerFunctions.alignPrimaryQuotesCPL(newOpportunityList, newOpportunityMap, oldOpportunityMap); // Added by Lipton for W-003446
    }

    /**
    public override void beforeDelete() {
        // valid trigger context vars:
        //     oldOpportunityList
        //     oldOpportunityMap
        System.debug('======= executing Opportunity_TriggerHander::beforeDelete()');
        L2I_Opportunity_TriggerFunctions.rollupParentOpportunityAmount(oldOpportunityList);
    }
    **/

//    public override void afterDelete() {
// valid trigger context vars:
//     oldOpportunityList
//     oldOpportunityMap
//        System.debug('======= executing Opportunity_TriggerHander::afterDelete()');
 //   }

//    public override void afterUndelete() {
// valid trigger context vars:
//     newOpportunityList  (not modifiable)
//     newOpportunityMap
//        System.debug('====== executing L2I_Opportunity_TriggerHander::afterUndelete()');
//    }

}