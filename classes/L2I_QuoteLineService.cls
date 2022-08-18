/**
 *  @author       Sarah Kennedy
 *  @date         05/06/2020
 *  @description  L2I QuoteLine Service class
 *
 *  Modification Log:
 *  ------------------------------------------------------------------------------------
 *  Developer                       Date                Description
 *  ------------------------------------------------------------------------------------
 *  Sarah Kennedy                  05/06/2020         Initial scaffold
 *  Sarah Kennedy                  05/06/2020         DE454 to replace same functionality in QuoteLine Trigger Functions
 *                                                    where errors were occurring:
 *                                                    Fwd: Sandbox: Developer script exception from
 *                                                    Panasonic Avionics Corporation : L2I_QuoteLineTrigger :
 *                                                    L2I_QuoteLineTrigger: execution of AfterInsert caused by: System.DmlException:
 *                                                    Update failed. First exception on row 0 with id a0q4D000000FQsKQAW;
 *                                                    first error: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY,
 *                                                    SBQQ.QuoteLineBefore: execution of BeforeUpdate caused by:
 *                                                    System.ExternalObjectException: External Object Error (SBQQ) : [] ()
 *
 */

public with sharing class L2I_QuoteLineService {
    
    public static void setMatchingIds(Set<Id> quoteIds) {
        
        if (quoteIds.isEmpty()) {
            return;
        }
        
        System.debug('====== Executing L2I_QuoteLineService::setMatchingIds for # of quoteIds ' + quoteIds.size());
        
        List<SBQQ__QuoteLine__c> quoteLines = [
              select Id,
                    L2I_blng_MatchingId__c,
                    SBQQ__Quote__c,
                    SBQQ__RenewedSubscription__c,
                    SBQQ__RenewedSubscription__r.L2I_blng_MatchingId__c,
                    SBQQ__UpgradedSubscription__c,
                    SBQQ__UpgradedSubscription__r.L2I_blng_MatchingId__c
              from SBQQ__QuoteLine__c
              where SBQQ__Quote__c in :quoteIds
        ];
        
        System.debug('====== Number of quote line items that require matching Id setup : ' + quoteLines.size());
        
        if (quoteLines.isEmpty()) {
            return;
        }
    
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c item : quoteLines) {
            // check to see if the matching id should come from a renewed or upgraded subscription
            if (item.SBQQ__RenewedSubscription__c != null) {
                if (item.L2I_blng_MatchingId__c != item.SBQQ__RenewedSubscription__r.L2I_blng_MatchingId__c) {
                    System.debug('====== Setting QuoteLine ' + item.Id + ' MatchingId from ' + item.L2I_blng_MatchingId__c + ' to RenewedSubscription Matching Id :' + item.SBQQ__RenewedSubscription__r.L2I_blng_MatchingId__c) ;
                    item.L2I_blng_MatchingId__c = item.SBQQ__RenewedSubscription__r.L2I_blng_MatchingId__c;
                    quoteLinesToUpdate.add(item);
                }
            } else if (item.SBQQ__UpgradedSubscription__c != null) {
                if (item.L2I_blng_MatchingId__c != item.SBQQ__UpgradedSubscription__r.L2I_blng_MatchingId__c) {
                    System.debug('====== Setting QuoteLine ' + item.Id + ' MatchingId from ' + item.L2I_blng_MatchingId__c + ' to UpgradedSubscription Matching Id :' + item.SBQQ__UpgradedSubscription__r.L2I_blng_MatchingId__c) ;
                    item.L2I_blng_MatchingId__c = item.SBQQ__UpgradedSubscription__r.L2I_blng_MatchingId__c;
                    quoteLinesToUpdate.add(item);
                }
            } else if (item.L2I_blng_MatchingId__c == null ||
                       item.L2I_blng_MatchingId__c != item.Id){
                System.debug('====== Setting QuoteLine ' + item.Id + ' MatchingId from ' + item.L2I_blng_MatchingId__c + ' to Id :' + item.Id) ;
                item.L2I_blng_MatchingId__c = item.Id;
                quoteLinesToUpdate.add(item);
            }
        }
    
        System.debug('====== Number of QuoteLines to Update ' + quoteLinesToUpdate.size());
        if (!quoteLinesToUpdate.isEmpty()) {
            update quoteLinesToUpdate;
        }
        System.debug('====== Finished Executing L2I_QuoteLineService::setMatchingIds');
    }
}