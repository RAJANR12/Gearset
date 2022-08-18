/**
 *      @author       Nitin Gupta
 *      @date         01/18/2021
 *      @description  Program Price List Utility methods
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Nitin Gupta                  01/18/2021         Initial scaffold
 */

public class PT_ProgramPriceList_Utils {
    public static void createUpdatePriceListEntries(Id quoteId, Id priceListId) {
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__NetPrice__c, SBQQ__Product__c, SBQQ__Product__r.ProductCode
                                                FROM SBQQ__QuoteLine__c
                                                WHERE SBQQ__Quote__c = :quoteId];

        List<PT_PriceList_Entry__c> priceListEntries = [SELECT Id, PT_Product__c, PT_UnitPrice__c
                                                        FROM PT_PriceList_Entry__c
                                                        WHERE PT_Program_Price_List__c = :priceListId];

        Map<Id, SBQQ__QuoteLine__c> productPriceMap = new Map<Id, SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            productPriceMap.put(ql.SBQQ__Product__c, ql);
        }

        Map<Id, PT_PriceList_Entry__c> productPLEMap = new Map<Id, PT_PriceList_Entry__c>();
        for (PT_PriceList_Entry__c ple : priceListEntries) {
            productPLEMap.put(ple.PT_Product__c, ple);
        }

        List<PT_PriceList_Entry__c> insertPLE = new List<PT_PriceList_Entry__c>();
        List<PT_PriceList_Entry__c> updatePLE = new List<PT_PriceList_Entry__c>();
        List<PT_PriceList_Entry__c> allPLE = new List<PT_PriceList_Entry__c>();
        for (Id prod : productPriceMap.keySet()) {
            if (!productPLEMap.isEmpty() && productPLEMap.containsKey(prod)){
                if(productPLEMap.get(prod).PT_UnitPrice__c != productPriceMap.get(prod).SBQQ__NetPrice__c) {
                    updatePLE.add(new PT_PriceList_Entry__c(Id = productPLEMap.get(prod).Id,
                                                            PT_isActive__c = TRUE,
                                                            PT_Status__c = 'Reconcile'
                    ));
                }
            } else {
                insertPLE.add(new PT_PriceList_Entry__c(
                        PT_Program_Price_List__c = priceListId,
                        PT_CanEscalate__c = TRUE,
                        PT_isActive__c = TRUE,
                        PT_StartDate__c = Date.today(),
                        PT_Status__c = 'Approved',
                        PT_Product__c = prod,
                        PT_UnitPrice__c = productPriceMap.get(prod).SBQQ__NetPrice__c,
                        Name = productPriceMap.get(prod).SBQQ__Product__r.ProductCode
                ));
            }
        }
        if (insertPLE.size() > 0) {
            insert insertPLE;
            allPLE.addall(insertPLE);
        }
        if (updatePLE.size() > 0) {
            update updatePLE;
            allPLE.addall(updatePLE);
        }
        if (insertPLE.size() > 0) {
            PT_PriceList__c updatePriceList = new PT_PriceList__c(Id = priceListId, PT_Status__c = 'Integration Pending');
            update updatePriceList;
        }
        updateQuoteLineWithPLE(quoteLines, allPLE);
    }

    public static void updateQuoteLineWithPLE(List<SBQQ__QuoteLine__c> quoteLines, List<PT_PriceList_Entry__c> allPLE) {
        Map<Id, Id> productPLEMap = new Map<Id, Id>();
        List<SBQQ__QuoteLine__c> UpdateQuoteLines = new List<SBQQ__QuoteLine__c>();
        for (PT_PriceList_Entry__c ple : allPLE) {
            productPLEMap.put(ple.PT_Product__c, ple.Id);
        }

        for (SBQQ__QuoteLine__c ql : quoteLines) {
            if (productPLEMap != null && productPLEMap.containsKey(ql.SBQQ__Product__c)) {
                UpdateQuoteLines.add(new SBQQ__QuoteLine__c(Id = ql.Id, PT_Price_List_Entry__c = productPLEMap.get(ql.SBQQ__Product__c)));
            }
        }

        if (UpdateQuoteLines.size() > 0) {
            update UpdateQuoteLines;
        }

    }
}