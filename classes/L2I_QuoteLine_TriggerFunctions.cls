/**
 *  @author       Raj Rajen
 *  @date         03/02/2020
 *  @description  L2I QuoteLine Trigger Functions
 *
 *  Modification Log:
 *  ------------------------------------------------------------------------------------
 *  Developer                       Date                Description
 *  ------------------------------------------------------------------------------------
 *  Raj Rajen                     03/02/2020         Initial scaffold
 *  Sarah Kennedy                 05/06/2020         DE454 L2I_QuoteLineService.cls to replace same Matching Id functionality in QuoteLine Trigger Functions
 *
 */
public without sharing class L2I_QuoteLine_TriggerFunctions {

//    public static void setMatchingId(List<SBQQ__QuoteLine__c> newQuoteLineList) {
//
//        Set<Id> affectedQuoteLineItems = new Set<Id>();
//        Set<Id> referencedParentQuotes = new Set<Id>();
//        for (SBQQ__QuoteLine__c qli : newQuoteLineList) {
//            affectedQuoteLineItems.add(qli.Id);
//            referencedParentQuotes.add(qli.SBQQ__Quote__c);
//        }
//
//        System.debug('====== Number of quote line items : ' + affectedQuoteLineItems.size());
//        System.debug('====== Number of unique parent quotes : ' + referencedParentQuotes.size());
//
//        // cloned quotes (SBQQ__Quote__r.SBQQ__Source__c != null) will already have
//        // the matching Ids cloned. So we can exclude them for Amendment quotes.
//        // TODO: Renewal Quotes might have to be handled slightly differently
//        //       need to preserve the matching Id of only the renewed items
//
//        List<SBQQ__QuoteLine__c> quoteLines = [select Id,
//                                                      L2I_blng_MatchingId__c,
//                                                      SBQQ__Quote__c,
//                                                      SBQQ__Quote__r.SBQQ__Source__c,
//                                                      SBQQ__Quote__r.SBQQ__OriginalQuote__c,
//                                                      SBQQ__Quantity__c
//                                                 from SBQQ__QuoteLine__c
//                                                where Id in :affectedQuoteLineItems];
//
//        if (quoteLines.isEmpty()) {
//            return;
//        }
//
//
//        for (SBQQ__QuoteLine__c item : quoteLines) {
//            if (item.SBQQ__Quote__r.SBQQ__Source__c == null) {
//                item.L2I_blng_MatchingId__c = item.Id;
//            }
//        }
//
//        update quoteLines;
//        System.debug('====== Updated ' + quoteLines.size() + ' QuoteLine records with Matching Id');
//
//    }
//
//    public static void UpdateMatchingId(List<SBQQ__QuoteLine__c> newQuoteLineList,
//                                        Map<Id, SBQQ__QuoteLine__c> newQuoteLineMap,
//                                        Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap) {
//
//        System.debug('====== Executing L2I_QuoteLine_TriggerFunctions::UpdateMatchingId');
//
//        /**
//        if (L2I_RecursionGuard.hasRunOnce) {
//            return;
//        }
//
//        L2I_RecursionGuard.hasRunOnce = true;
//        **/
//
//        Set<Id> affectedQLIs = new Set<Id>();
//        for (SBQQ__QuoteLine__c oitem : newQuoteLineList) {
//            SBQQ__QuoteLine__c newRec = newQuoteLineMap.get(oitem.Id);
//            SBQQ__QuoteLine__c oldRec = oldQuoteLineMap.get(oitem.Id);
//
//            if ((newRec.SBQQ__RenewedSubscription__c != null && newRec.SBQQ__RenewedSubscription__c != oldRec.SBQQ__RenewedSubscription__c) ||
//                (newRec.SBQQ__UpgradedSubscription__c != null && newRec.SBQQ__UpgradedSubscription__c != oldRec.SBQQ__UpgradedSubscription__c)){
//
//                affectedQLIs.add(oitem.Id);
//            }
//        }
//
//        System.debug('====== Number of quote line items to consider for processing : ' + affectedQLIs.size());
//        if (affectedQLIs.isEmpty()) {
//            return;
//        }
//
//        List<SBQQ__QuoteLine__c> quoteLines = [select Id,
//                                                      L2I_blng_MatchingId__c,
//                                                      SBQQ__Quote__c,
//                                                      SBQQ__RenewedSubscription__c,
//                                                      SBQQ__RenewedSubscription__r.L2I_blng_MatchingId__c,
//                                                      SBQQ__UpgradedSubscription__c,
//                                                      SBQQ__UpgradedSubscription__r.L2I_blng_MatchingId__c
//                                                 from SBQQ__QuoteLine__c
//                                                where Id in :affectedQLIs
//                                                  and (SBQQ__RenewedSubscription__c != null
//                                                   or SBQQ__UpgradedSubscription__c != null)];
//
//
//        System.debug('====== Number of quote line items that require matching Id setup : ' + quoteLines.size());
//
//        if (quoteLines.isEmpty()) {
//            return;
//        }
//
//        for (SBQQ__QuoteLine__c item : quoteLines) {
//            if (item.SBQQ__RenewedSubscription__c != null) {
//                item.L2I_blng_MatchingId__c = item.SBQQ__RenewedSubscription__r.L2I_blng_MatchingId__c;
//                System.debug('====== Setting QuoteLine MatchingId to RenewedSubscription Matching Id :' + item.SBQQ__RenewedSubscription__r.L2I_blng_MatchingId__c) ;
//            } else if (item.SBQQ__UpgradedSubscription__c != null) {
//                item.L2I_blng_MatchingId__c = item.SBQQ__UpgradedSubscription__r.L2I_blng_MatchingId__c;
//                System.debug('====== Setting QuoteLine MatchingId to UpgradedSubscription Matching Id :' + item.SBQQ__UpgradedSubscription__r.L2I_blng_MatchingId__c) ;
//            }
//        }
//
//        update quoteLines;
//
//        System.debug('====== Updated ' + quoteLines.size() + ' QuoteLine records with Matching Id');
//        System.debug('====== Finished Executing L2I_QuoteLine_TriggerFunctions::UpdateMatchingId');
//    }

}