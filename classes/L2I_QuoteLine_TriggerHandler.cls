/**
 *  @author       Raj Rajen
 *  @date         03/02/2020
 *  @description  L2I QuoteLine Trigger Handler
 *
 *  Modification Log:
 *  ------------------------------------------------------------------------------------
 *  Developer                       Date                Description
 *  ------------------------------------------------------------------------------------
 *  Raj Rajen                     03/02/2020         Initial setup
 *  Sarah Kennedy                 05/06/2020         DE454 L2I_QuoteLineService.cls to replace same Matching Id functionality in QuoteLine Trigger Functions
 *
 */
public without sharing class L2I_QuoteLine_TriggerHandler extends L2I_TriggerHandler {

    private Map<Id, SBQQ__QuoteLine__c> newQuoteLineMap;
    private List<SBQQ__QuoteLine__c> newQuoteLineList;

    private Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap;
    private List<SBQQ__QuoteLine__c> oldQuoteLineList;

    public L2I_QuoteLine_TriggerHandler() {
        this.newQuoteLineMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.newMap;
        this.newQuoteLineList = (List<SBQQ__QuoteLine__c>) Trigger.new;

        this.oldQuoteLineMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.oldMap;
        this.oldQuoteLineList = (List<SBQQ__QuoteLine__c>) Trigger.old;

        // Important!!! we are setting the MaxLoopCount to be 1 so that this trigger executes
        //              only once.
        //this.setMaxLoopCount(1);
    }

    public override void beforeUpdate() {
// valid trigger context vars:
//     newQuoteLineList  (modifiable)
//     newQuoteLineMap
//     oldQuoteLineList
//     oldQuoteLineMap
        System.debug('====== executing L2I_QuoteLine_TriggerHandler::beforeUpdate()');
//        PT_QuoteLine_TriggerFunctions.addSolGroupToQLGroup(newQuoteLineList, newQuoteLineMap, oldQuoteLineMap);
    }

    public override void beforeInsert() {
// valid trigger context vars:
//     newQuoteLineList  (modifiable)
        System.debug('====== executing L2I_QuoteLine_TriggerHandler::beforeInsert()');
//        PT_QuoteLine_TriggerFunctions.addSolGroupToQLGroup(newQuoteLineList, newQuoteLineMap, null);
        PT_QuoteLine_TriggerFunctions.validationDeliveryStageOppty(newQuoteLineList);
        PT_QuoteLine_TriggerFunctions.validatePartNumbers(newQuoteLineList);
    }

    public override void afterInsert() {
        // valid trigger context vars:
        //     newQuoteLineList  (not modifiable)
        //     newQuoteLineMap

        System.debug('====== executing L2I_QuoteLine_TriggerHandler::afterInsert()');
    }

    public override void afterUpdate() {
        // valid trigger context vars:
        //     newQuoteLineMap
        //     oldQuoteLineList

        System.debug('======= executing L2I_QuoteLine_TriggerHandler::afterUpdate()');
        PT_QuoteLine_TriggerFunctions.syncQLandPLE(newQuoteLineList, oldQuoteLineMap); // Added by Lipton Abillar for W-003670
    }

    public override void beforeDelete() {
        // valid trigger context vars:
        //     oldQuoteLineList
        //     oldQuoteLineMap
        System.debug('======= executing L2I_QuoteLine_TriggerHandler::beforeDelete()');
        PT_QuoteLine_TriggerFunctions.validationAssetStatusNotDeleted(oldQuoteLineList);
    }

    public override void afterDelete() {
        // valid trigger context vars:
        //     oldQuoteLineList
        //     oldQuoteLineMap
        System.debug('======= executing L2I_QuoteLine_TriggerHandler::afterDelete()');
    }

}