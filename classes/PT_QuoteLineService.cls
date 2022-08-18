/**
 *  @author       Sarah Kennedy
 *  @date         11/01/2020
 *  @description  PT_QuoteLineService class
 *
 *  Modification Log:
 *  ------------------------------------------------------------------------------------
 *  Developer                       Date                Description
 *  ------------------------------------------------------------------------------------
 *  Sarah Kennedy                  11/01/2020         Initial scaffold
 *
 */

public with sharing class PT_QuoteLineService {
//    @AuraEnabled(cacheable=true)
//    public static List<SBQQ__QuoteLineGroup__c> getQuoteLineGroups(String quoteId) {
//        System.debug('*** quoteId ' + quoteId);
//        System.debug('*** soql ' + [SELECT Id, Name FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :quoteId]);
//        return [SELECT Id, Name FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :quoteId ORDER BY Name];
//    }
//
//    @AuraEnabled
//    public static List<partsWrapper> findPartsForQuoteLine(String quoteId, List<String> qlgIdList) {
//        List<partsWrapper> pwList = new List<partsWrapper>();
//        Set<String> existingQuoteLineParts = new Set<String>();
//        Map<Id, String> qlgMap = new Map<Id, String>();
//
//        for (SBQQ__QuoteLineGroup__c qlg : [
//              SELECT Id, Name
//              FROM SBQQ__QuoteLineGroup__c
//              WHERE Id IN :qlgIdList
//        ]) {
//            qlgMap.put(qlg.Id, qlg.Name);
//        }
//
//        for (SBQQ__QuoteLine__c qLine : [
//              SELECT Id, Name, SBQQ__Product__c, SBQQ__Group__c
//              FROM SBQQ__QuoteLine__c
//              WHERE SBQQ__Quote__c = :quoteId
//              AND SBQQ__Group__c IN :qlgIdList
//        ]) {
//            existingQuoteLineParts.add(qLine.SBQQ__Product__c);
//        }
//
//        String pbId;
//        pbId = [SELECT SBQQ__PriceBook__c FROM SBQQ__Quote__c WHERE Id = :quoteId].SBQQ__PriceBook__c;
//
//        List<PricebookEntry> pbeList = new List<PricebookEntry>();
//        Map<Id, PricebookEntry> prodListPriceMap = new Map<Id, PricebookEntry>();
//        for (PricebookEntry pbe : [
//              SELECT Product2Id, UnitPrice, CurrencyIsoCode
//              FROM PricebookEntry
//              WHERE Pricebook2Id = :pbId
//              AND Product2Id <> NULL
//        ]) {
//            prodListPriceMap.put(pbe.Product2Id, pbe);
//        }
//
//        for (Product2 prod : [
//              SELECT Id, Name, Description, ProductCode, Family, L2I_Product_Family__c, L2I_Price_List_ID__c
//              FROM Product2
//              WHERE L2I_Category__c = 'IFEC'
//              AND Id NOT IN :existingQuoteLineParts
//              LIMIT 50
//        ]) {
//            if (prodListPriceMap.get(prod.Id) != null) {
//                partsWrapper pw = new partsWrapper();
//                pw.Id = prod.Id;
//                pw.partCode = prod.ProductCode;
//                pw.partName = prod.Name;
//                pw.partDescription = prod.Description;
//                pw.partFamily = prod.L2I_Product_Family__c;
//                pw.partListPrice = prodListPriceMap.get(prod.Id).UnitPrice;
//                pw.currencyCode = prodListPriceMap.get(prod.Id).CurrencyIsoCode;
//                pw.qlgIdList = qlgIdList;
//                pw.quoteId = quoteId;
//                pwList.add(pw);
//            }
//        }
//        return pwList;
//    }
//
//    @AuraEnabled
//    public static String savePartsForQuoteLine(List<partsWrapper> selectedParts) {
//        String msg = '';
//        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
//        try {
//            for (partsWrapper pw : selectedParts) {
//                for (String qlg : pw.qlgIdList) {
//                    SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c();
//                    qLine.SBQQ__Quote__c = pw.quoteId;
//                    qLine.SBQQ__Product__c = pw.Id;
//                    qLine.SBQQ__Group__c = qlg;
//                    quoteLineList.add(qLine);
//                }
//            }
//            if (quoteLineList != NULL &&
//                  quoteLineList.size() > 0) {
//                insert quoteLineList;
//            }
//            msg = 'Successfully inserted ' + quoteLineList.size() + ' Quote Lines';
//        } catch (Exception e){
//            msg = 'Error inserting Quote Lines: ' + e.getMessage();
//        }
//        return msg;
//    }
//
//    public class partsWrapper {
//        @AuraEnabled public String Id { get; set; }
//        @AuraEnabled public String partCode { get; set; }
//        @AuraEnabled public String partName { get; set; }
//        @AuraEnabled public String partDescription { get; set; }
//        @AuraEnabled public String partFamily { get; set; }
//        @AuraEnabled public Decimal partListPrice { get; set; }
//        @AuraEnabled public String currencyCode { get; set; }
//        @AuraEnabled public List<String> qlgIdList { get; set; }
//        @AuraEnabled public String quoteId { get; set; }
//
//        public partsWrapper() {
//        }
//    }

}