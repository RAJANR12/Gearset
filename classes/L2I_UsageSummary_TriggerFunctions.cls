/**
 *
 *      @author       Andy Fang
 *      @date         09/24/2019
 *      @description  L2I Usage Summary Handler Functions
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                     09/24/2019         Initial scaffold
 */

public without sharing class L2I_UsageSummary_TriggerFunctions {


    // Copy value from blng__OrderProduct__r.L2I_blng_MatchingId__c into matching ID
    public static void copyMatchIDFromOrderItem(List<blng__UsageSummary__c> newSummaryList) {

        Set<Id> opIdSets = new Set<Id>();
        for ( blng__UsageSummary__c bus : newSummaryList ){
            System.debug('==>>>> copyMatchIDFromOrderItem: ' + bus);

            bus.blng__MatchingId__c = String.isBlank(bus.blng__MatchingId__c) ? bus.L2I_MatchingIDCopy__c : bus.blng__MatchingId__c;
        }

    }


}