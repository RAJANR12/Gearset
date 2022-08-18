/**
 *      @author       Dan Morris
 *      @date         12/16/2021
 *      @description  Trigger Functions for PT_InstallLocationTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Dan Morris               12/16/2021          Initial scaffold
 */

public without sharing class PT_PriceListEntryTriggerFunctions {

    public static void priceRelatedQuoteLines(Map<Id, PT_PriceList_Entry__c> oldPriceListEntryMap, Map<Id, PT_PriceList_Entry__c> newPriceListEntryMap) {
        if (newPriceListEntryMap == null || newPriceListEntryMap.size() < 1) return;
        Set<Id> pleIds = newPriceListEntryMap.keySet();
        Set<String> errorQuotes = new Set<String>();
        Id anIdForError = null;
        for (PT_PriceList_Entry__c ple: newPriceListEntryMap.values()) {
            if (ple.PT_Pending_Price__c == null || ple.PT_Pending_Price__c == oldPriceListEntryMap.get(ple.Id).PT_Pending_Price__c) pleIds.remove(ple.Id);
        }
        if (pleIds.size()< 1) return;
        List<SBQQ__QuoteLine__c> quoteLines = [
            SELECT Id, SBQQ__SpecialPrice__c, SBQQ__Discount__c, PT_Price_List_Entry__c
                , SBQQ__Quote__r.ApprovalStatus__c, SBQQ__Quote__r.Name
            FROM SBQQ__QuoteLine__c
            WHERE isDeleted = false
            AND SBQQ__Quote__r.SBQQ__Primary__c = true
            AND SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName = 'Delivery'
            AND PT_Price_List_Entry__c IN :pleIds
        ];
        for (SBQQ__QuoteLine__c ql: quoteLines) {
            if (ql.SBQQ__Quote__r.ApprovalStatus__c == 'Approved') {
                errorQuotes.add(ql.SBQQ__Quote__r.Name);
                anIdForError = ql.PT_Price_List_Entry__c; // Doesn't really matter we won't do any updates
            }
            if (errorQuotes.size() > 0) continue;
            if (newPriceListEntryMap.containsKey(ql.PT_Price_List_Entry__c)) {
                //ql.SBQQ__Discount__c = newPriceListEntryMap.get(ql.PT_Price_List_Entry__c).PT_Pending_Price__c / ql.SBQQ__SpecialPrice__c;
            }
        }
        if (errorQuotes.size() > 0) {
            newPriceListEntryMap.get(anIdForError).addError('Price cannot be updated until Quote (' + String.join(new List<String>(errorQuotes),',') + ') is revised');
            System.debug('======= PT_PriceListEntryTriggerFunctions::priceRelatedQuoteLines() errors in quotes ' + errorQuotes);
        }
        else    {
            //update quoteLines;
            System.debug('======= PT_PriceListEntryTriggerFunctions::priceRelatedQuoteLines() updated ' + quoteLines.size() + ' records');
        }
    }
}