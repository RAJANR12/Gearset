/**
 *      @author       Raj Rajen
 *      @date         07/12/2019
 *      @description  L2I Quote Trigger Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/01/2019         Refactored Arun V's trigger
 *      Sarah Kennedy                 03/31/2020         US1618 added resetRenewalClosedLostOpp method
 *
 */
public without sharing class L2I_Quote_TriggerHandler extends L2I_TriggerHandler {

    private Map<Id, SBQQ__Quote__c> newQuoteMap;
    private List<SBQQ__Quote__c> newQuoteList;

    private Map<Id, SBQQ__Quote__c> oldQuoteMap;
    private List<SBQQ__Quote__c> oldQuoteList;

    public L2I_Quote_TriggerHandler() {
        this.newQuoteMap = (Map<Id, SBQQ__Quote__c>) Trigger.newMap;
        this.newQuoteList = (List<SBQQ__Quote__c>) Trigger.new;

        this.oldQuoteMap = (Map<Id, SBQQ__Quote__c>) Trigger.oldMap;
        this.oldQuoteList = (List<SBQQ__Quote__c>) Trigger.old;
    }

	//Added by Jan Geronga on 7/29/21 for W-003548: Start
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
    //Added by Jan Geronga on 7/29/21 for W-003548: End

    public override void beforeInsert() {
        // valid trigger context vars:
        //     newQuoteList  (modifiable)
        System.debug('======= executing L2I_Quote_TriggerHandler::beforeInsert()');
        L2I_Quote_TriggerFunctions.cloneQuote(newQuoteList);
        //PT_Quote_TriggerFunctions.updateQuoteRevison(newQuoteList);
    }

    public override void beforeUpdate() {
        // valid trigger context vars:
        //     newQuoteList  (modifiable)
        System.debug('======= executing L2I_Quote_TriggerHandler::beforeUpdate()');
        L2I_Quote_TriggerFunctions.updateRecordTypeForRejectedQuotes(newQuoteList);
        //PT_Quote_TriggerFunctions.updateQuoteRevison(newQuoteList);
        // PT_Quote_TriggerFunctions.updatePreviousApprovalStatus(newQuoteList, oldQuoteMap); // Added by Lipton for W-004254 W-004253
    }

    public override void afterInsert() {
        // valid trigger context vars:
        //     newQuoteList  (not modifiable)
        //     newQuoteMap
        System.debug('======= executing L2I_Quote_TriggerHandler::afterInsert()');
//        L2I_Quote_TriggerFunctions.quoteClonedSource(newQuoteList);
        L2I_Quote_TriggerFunctions.resetRenewalClosedLostOpp (newQuoteMap);
    }

    public override void afterUpdate() {
        // valid trigger context vars:
        //     newQuoteList  (not modifiable)
        //     newQuoteMap
        System.debug('======= executing L2I_Quote_TriggerHandler::afterUpdate()');
        PT_Quote_TriggerFunctions.createUpdateDSLs(newQuoteList, oldQuoteMap);
        PT_Quote_TriggerFunctions.updatePTSStation(newQuoteList, oldQuoteMap);//Added by Jan Geronga for W-003016
        L2I_Quote_TriggerFunctions.updateBPillars(newQuoteList, oldQuoteMap); // Added by Leah Ajo for W-004424
        if (checkRecursive()){ //Added by Jan Geronga on 7/29/21 for W-003548
            PT_Quote_TriggerFunctions.updateQLisNewTrue(newQuoteList, oldQuoteMap);//Added by Jan Geronga for W-002816
        }
    }
    
    public override void beforeDelete(){	
        //L2I_Quote_TriggerFunctions.checkPrimaryQuoteBeforeDelete(oldQuoteMap);	
    }
}