/**
 * @description       : Utility class to clone quote and quote lines
 * @author name       : Arun
 * @group             :
 * @last modified on  : 02-24-2021
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   07-14-2020   Arun              Initial Version
 * 2.0   11-01-2020   Arun              Clone QuoteLineGroups
**/
public class L2I_QuoteCloneUtility {

    public static List<SBQQ__Quote__c> cloneSBQQQuotes(Set<String> quoteIds) {
        String query = generateQuery('SBQQ__Quote__c', null);
        query += ' Where Id in :quoteIds';
system.debug ('Inside CK class 1 =');
        //SBQQ.TriggerControl.disable();
        Map<Id, SBQQ__Quote__c> sourceQuotes = new Map<Id, SBQQ__Quote__c>((List<SBQQ__Quote__c>)Database.query(query));
        List<SBQQ__Quote__c> clonedQuotes = cloneQuotes(sourceQuotes.values());
        system.debug ('Inside CK class 2 =' + clonedQuotes);
        insert clonedQuotes;

        //SBQQ.TriggerControl.disable();

        // 11-01-20 - Arun - Clone QuoteLineGroups
        Map<String, SBQQ__QuoteLineGroup__c> clonedLineGroups = cloneQuoteLineGroups(sourceQuotes, new Map<Id, SBQQ__Quote__c>(clonedQuotes));
        System.debug('For Insert: W-003591 '+ clonedLineGroups );
        insert clonedLineGroups.values();

        cloneQuoteLines(sourceQuotes, new Map<Id, SBQQ__Quote__c>(clonedQuotes), clonedLineGroups);
        //SBQQ.TriggerControl.enable();
        system.debug ('Inside CK class 2 =' + clonedQuotes);
        return clonedQuotes;
    }

    public static String generateQuery(String objApiName, Set<String> extraFields) {
        Map<String, Schema.SObjectField> quoteFieldsMap = Schema.getGlobalDescribe().get(objApiName).getDescribe().fields.getMap();
        String query = extraFields != null && !extraFields.isEmpty() ? 'Select '+String.join(new List<String>(extraFields), ',')+',': 'Select ';
        for(String str: quoteFieldsMap.keyset()) {
            query += str+',';
        }
        query = query.substring(0, query.length()-1);
        query += ' From '+objApiName;
        return query;
    }

    public static List<SBQQ__Quote__c> cloneQuotes(List<SBQQ__Quote__c> quotes) {
        List<SBQQ__Quote__c> clonedQuotes = new List<SBQQ__Quote__c>();

        for(SBQQ__Quote__c quote: quotes) {
            SBQQ__Quote__c clonedQuote = quote.clone(false, true, false, false);
            clonedQuote.SBQQ__Source__c = quote.Id;
            clonedQuote.SBQQ__Status__c = 'Draft';
            clonedQuote.SBQQ__Primary__c = false;
            clonedQuote.ApprovalStatus__c = 'Pending';
            clonedQuote.L2I_Version__c = quote.L2I_Version__c + 1;
            clonedQuote.SBQQ__Key__c = null; // Added by Arun - 02.07.21
            clonedQuote.L2I_External_Migration_Id__c = null; // Added by Arun - 02.07.21
            clonedQuotes.add(clonedQuote);
        }
        return clonedQuotes;
    }

    public static Map<String, SBQQ__QuoteLineGroup__c> cloneQuoteLineGroups(Map<Id, SBQQ__Quote__c> oldQuotes, Map<Id, SBQQ__Quote__c> clonedQuotes) {
        Map<String, SBQQ__QuoteLineGroup__c> groups = new Map<String, SBQQ__QuoteLineGroup__c>();
        Set<Id> quoteIds = oldQuotes.keySet();

        String query = generateQuery('SBQQ__QuoteLineGroup__c', null);
        query += ' Where SBQQ__Quote__c in :quoteIds';

        Map<Id, List<SBQQ__QuoteLineGroup__c>> groupsByQuote = new Map<Id, List<SBQQ__QuoteLineGroup__c>>();

        List<SBQQ__QuoteLineGroup__c> sourceGroups = new List<SObject>(Database.query(query));

        if(sourceGroups.isEmpty()) { return groups; }

        for(SBQQ__QuoteLineGroup__c lineGroup: sourceGroups) {
            if(groupsByQuote.containsKey(lineGroup.SBQQ__Quote__c)) {
                groupsByQuote.get(lineGroup.SBQQ__Quote__c).add(lineGroup);
            } else {
                groupsByQuote.put(lineGroup.SBQQ__Quote__c, new List<SBQQ__QuoteLineGroup__c>{lineGroup});
            }
        }
        System.Debug('Map for Insert'+ groupsByQuote);
        for(SBQQ__Quote__c quote: clonedQuotes.values()) {
            for(SBQQ__QuoteLineGroup__c lineGroup: groupsByQuote.get(quote.SBQQ__Source__c)) {
                SBQQ__QuoteLineGroup__c clonedGroup = lineGroup.clone(false, true, false, false);
                clonedGroup.SBQQ__Quote__c = quote.Id;
                clonedGroup.L2I_External_Migration_Id__c = null; // Added by Arun - 02.07.21
                groups.put(quote.SBQQ__Source__c+'-'+lineGroup.Id, clonedGroup);
            }
        }
        return groups;
    }

    public static void cloneQuoteLines(Map<Id, SBQQ__Quote__c> oldQuotes, Map<Id, SBQQ__Quote__c> clonedQuotes, Map<String, SBQQ__QuoteLineGroup__c> clonedLineGroups) {
        Set<Id> sourceIds = oldQuotes.keySet();
        String query = generateQuery('SBQQ__QuoteLine__c', new Set<String>{'PT_Price_List_Entry__r.PT_UnitPrice__c','PT_Price_List_Entry__r.PT_Program_Price_List__c','PT_Price_List_Entry__r.PT_Program_Price_List__r.PT_Price_List_Name__c'});
        query += ' Where SBQQ__Quote__c in :sourceIds Order By SBQQ__Quote__c,SBQQ__RequiredBy__c';
        Map<Id, SBQQ__QuoteLine__c> quoteLines = new Map<Id, SBQQ__QuoteLine__c>((List<SBQQ__QuoteLine__c>)Database.query(query));
        Map<Id, Id> requiredBys = new Map<Id, Id>();
        Map<Id, List<SBQQ__QuoteLine__c>> sourceQuoteLines = new Map<Id, List<SBQQ__QuoteLine__c>>();
        for(SBQQ__QuoteLine__c quoteLine: quoteLines.values()) {
            if(quoteLine.SBQQ__RequiredBy__c != null) {
                requiredBys.put(quoteLine.Id, quoteLine.SBQQ__RequiredBy__c);
            }
            if(sourceQuoteLines.containsKey(quoteLine.SBQQ__Quote__c)) {
                sourceQuoteLines.get(quoteLine.SBQQ__Quote__c).add(quoteLine);
            } else {
                sourceQuoteLines.put(quoteLine.SBQQ__Quote__c, new List<SBQQ__QuoteLine__c>{quoteLine});
            }
        }

        Map<String, SBQQ__QuoteLine__c> parentQuoteLines = new Map<String, SBQQ__QuoteLine__c>();
        Map<String, SBQQ__QuoteLine__c> childQuoteLines = new Map<String, SBQQ__QuoteLine__c>();
        Map<String, Integer> reqToRandom = new Map<String, Integer>();

        Map<String, Schema.SObjectField> lineFieldsMap = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();
        for(SBQQ__Quote__c quote: clonedQuotes.values()) {
            List<SBQQ__QuoteLine__c> lines = sourceQuoteLines.get(quote.SBQQ__Source__c);
            for(SBQQ__QuoteLine__c line: lines) {

                SBQQ__QuoteLine__c clonedLine = new SBQQ__QuoteLine__c();
                for(String str: lineFieldsMap.keyset()) {
                    if(str != 'SBQQ__RequiredBy__c' && lineFieldsMap.get(str).getDescribe().isUpdateable()) {
                        clonedLine.put(str, line.get(str));
                    }
                }
                clonedLine.SBQQ__Quote__c = quote.Id;
                if(line.SBQQ__RequiredBy__c == null) {
                    Integer randomNumber = Integer.valueof((Math.random() * 100000000));
                    clonedLine.L2I_ExternalId__c = line.SBQQ__Quote__c+'-'+line.Id+'-'+randomNumber;
                    reqToRandom.put(line.SBQQ__Quote__c+'-'+line.Id, randomNumber);
                } else {
                    clonedLine.L2I_ExternalId__c = line.SBQQ__Quote__c+'-'+line.Id+'-'+getSystemTime();
                }

                clonedLine.SBQQ__Source__c = line.Id;
                // 11/1/20 - Arun - Associate QuoteLineGroups
                if(clonedLineGroups.containsKey(quote.SBQQ__Source__c+'-'+clonedLine.SBQQ__Group__c)) {
                    clonedLine.SBQQ__Group__c = clonedLineGroups.get(quote.SBQQ__Source__c+'-'+clonedLine.SBQQ__Group__c).Id;
                }

                clonedLine.L2I_blng_MatchingId__c = null; // Added by Arun - 02.07.21
                clonedLine.SBQQ__OriginalQuoteLineId__c = null; // Added by Arun - 02.07.21
                // Added by Arun - 02.07.21
                // when QL is related to a Price List Entry [PT_Price_List_Entry__c]
                /*if(line.PT_Price_List_Entry__c != null) {
                    clonedLine.SBQQ__Discount__c = null;
                    clonedLine.SBQQ__AdditionalDiscountAmount__c = null;
                    clonedLine.SBQQ__OptionDiscount__c = null;
                    clonedLine.SBQQ__OptionDiscountAmount__c = null;
                    clonedLine.SBQQ__PartnerDiscount__c = null;
                    clonedLine.SBQQ__SpecialPrice__c = line.PT_Price_List_Entry__r.PT_UnitPrice__c;
                    clonedLine.SBQQ__SpecialPriceDescription__c = (line.PT_Price_List_Entry__r.PT_Program_Price_List__c != null) ? 'Program Price List Pricing '+line.PT_Price_List_Entry__r.PT_Program_Price_List__r.PT_Price_List_Name__c : null;
                    clonedLine.SBQQ__SpecialPriceType__c = 'Custom';
                }*/

                if(line.SBQQ__RequiredBy__c != null) {
                    String reqExternalId = line.SBQQ__Quote__c+'-'+line.SBQQ__RequiredBy__c+'-'+reqToRandom.get(line.SBQQ__Quote__c+'-'+line.SBQQ__RequiredBy__c);
                    if(parentQuoteLines.containsKey(reqExternalId)) {
                        SBQQ__QuoteLine__c lineExternal = new SBQQ__QuoteLine__c(L2I_ExternalId__c = parentQuoteLines.get(reqExternalId).L2I_ExternalId__c);
                        clonedLine.SBQQ__RequiredBy__r = lineExternal;
                    }
                }
                // system.debug(clonedLine);
                if(line.SBQQ__RequiredBy__c == null) {
                    parentQuoteLines.put(clonedLine.L2I_ExternalId__c, clonedLine);
                } else {
                    childQuoteLines.put(clonedLine.L2I_ExternalId__c, clonedLine);
                }
            }
        }
        insert parentQuoteLines.values();
        insert childQuoteLines.values();
    }

    @testVisible
    private static String getSystemTime() {
        return System.now().format('yyyyMMddHHmmss');
    }

    @AuraEnabled
    public static CloneQuoteDetails cloneQuoteAndLines(Id quoteId, Integer batchSize) {
        String query = generateQuery('SBQQ__Quote__c', null);
        query += ' Where Id = :quoteId';

        //SBQQ.TriggerControl.disable();
        Map<Id, SBQQ__Quote__c> sourceQuotes = new Map<Id, SBQQ__Quote__c>((List<SBQQ__Quote__c>)Database.query(query));
        List<SBQQ__Quote__c> clonedQuotes = cloneQuotes(sourceQuotes.values());
        insert clonedQuotes;

        SBQQ.TriggerControl.disable();

        // 11-01-20 - Arun - Clone QuoteLineGroups
        Map<String, SBQQ__QuoteLineGroup__c> clonedLineGroups = cloneQuoteLineGroups(sourceQuotes, new Map<Id, SBQQ__Quote__c>(clonedQuotes));
        insert clonedLineGroups.values();

        SBQQ.TriggerControl.enable();

        Id jobId = Database.executeBatch(new L2I_CloneQuoteLinesBatch(sourceQuotes.values()[0], clonedQuotes[0], clonedLineGroups), batchSize);

        return new CloneQuoteDetails(clonedQuotes[0], clonedLineGroups, jobId);
    }

    public class CloneQuoteDetails {
        @AuraEnabled
        public SBQQ__Quote__c clonedQuote;
        @AuraEnabled
        public Map<String, SBQQ__QuoteLineGroup__c> clonedGroups;
        @AuraEnabled
        public String jobId;
        public CloneQuoteDetails(SBQQ__Quote__c clonedQuote, Map<String, SBQQ__QuoteLineGroup__c> clonedGroups, String jobId) {
            this.clonedQuote = clonedQuote;
            this.clonedGroups = clonedGroups;
            this.jobId = jobId;
        }
    }

    @AuraEnabled(cacheable = true)
    public static SBQQ__Quote__c getQuoteDetails(Id quoteId) {
        return [Select Id, Name, SBQQ__LineItemCount__c, Owner.Name, LastModifiedBy.Name From SBQQ__Quote__c Where Id =: quoteId];
    }

    public static List<SBQQ__QuoteLine__c> cloneQuoteLinesWithoutRequiredby(Map<Id, List<SBQQ__QuoteLine__c>> sourceQuoteLines, Map<Id, SBQQ__Quote__c> oldQuotes, Map<Id, SBQQ__Quote__c> clonedQuotes, Map<String, SBQQ__QuoteLineGroup__c> clonedLineGroups) {
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();

        Map<String, Schema.SObjectField> lineFieldsMap = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();
        for(SBQQ__Quote__c quote: clonedQuotes.values()) {
            List<SBQQ__QuoteLine__c> lines = sourceQuoteLines.get(quote.SBQQ__Source__c);
            for(SBQQ__QuoteLine__c line: lines) {

                SBQQ__QuoteLine__c clonedLine = new SBQQ__QuoteLine__c();
                for(String str: lineFieldsMap.keyset()) {
                    if(str != 'SBQQ__RequiredBy__c' && lineFieldsMap.get(str).getDescribe().isUpdateable()) {
                        clonedLine.put(str, line.get(str));
                    }
                }
                clonedLine.SBQQ__Quote__c = quote.Id;

                clonedLine.SBQQ__Source__c = line.Id;
                // 11/1/20 - Arun - Associate QuoteLineGroups
                if(clonedLineGroups.containsKey(quote.SBQQ__Source__c+'-'+clonedLine.SBQQ__Group__c)) {
                    clonedLine.SBQQ__Group__c = clonedLineGroups.get(quote.SBQQ__Source__c+'-'+clonedLine.SBQQ__Group__c).Id;
                }

                clonedLine.L2I_blng_MatchingId__c = null; // Added by Arun - 02.07.21
                clonedLine.SBQQ__OriginalQuoteLineId__c = null; // Added by Arun - 02.07.21
                // Added by Arun - 02.07.21
                // when QL is related to a Price List Entry [PT_Price_List_Entry__c]
                /*if(line.PT_Price_List_Entry__c != null) {
                    clonedLine.SBQQ__Discount__c = null;
                    clonedLine.SBQQ__AdditionalDiscountAmount__c = null;
                    clonedLine.SBQQ__OptionDiscount__c = null;
                    clonedLine.SBQQ__OptionDiscountAmount__c = null;
                    clonedLine.SBQQ__PartnerDiscount__c = null;
                    clonedLine.SBQQ__SpecialPrice__c = line.PT_Price_List_Entry__r.PT_UnitPrice__c;
                    clonedLine.SBQQ__SpecialPriceDescription__c = (line.PT_Price_List_Entry__r.PT_Program_Price_List__c != null) ? 'Program Price List Pricing '+line.PT_Price_List_Entry__r.PT_Program_Price_List__r.PT_Price_List_Name__c : null;
                    clonedLine.SBQQ__SpecialPriceType__c = 'Custom';
                }*/
                quoteLines.add(clonedLine);
            }
        }
        return quoteLines;
    }

    public static void populateRequiredBy(Id sourceQuoteId, Id cloneQuoteId) {
        Map<Id, SBQQ__QuoteLine__c> sourceLines = new Map<Id, SBQQ__QuoteLine__c>([Select Id, SBQQ__RequiredBy__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c =: sourceQuoteId]);
        Map<Id, Id> cloneSourceToIdMap = new Map<Id, Id>();
        for(SBQQ__QuoteLine__c line :[Select Id, SBQQ__Source__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c =: cloneQuoteId]) {
            cloneSourceToIdMap.put(line.SBQQ__Source__c, line.Id);

        }
        List<SBQQ__QuoteLine__c> updateRequiredBy = new List<SBQQ__QuoteLine__c>();
        for(Id sourceId: cloneSourceToIdMap.keySet()) {
            Id clonedLineId = cloneSourceToIdMap.get(sourceId);
            if(sourceLines.containsKey(sourceId) && sourceLines.get(sourceId).SBQQ__RequiredBy__c != null && cloneSourceToIdMap.containsKey(sourceLines.get(sourceId).SBQQ__RequiredBy__c)) {
                updateRequiredBy.add(new SBQQ__QuoteLine__c(Id = clonedLineId, SBQQ__RequiredBy__c = cloneSourceToIdMap.get(sourceLines.get(sourceId).SBQQ__RequiredBy__c)));
            }
        }
        update updateRequiredBy;
    }

    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobId){
        return [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobId];
    }

    @AuraEnabled
    public static Boolean validateCanRevise(Id quoteId){
        Boolean canRevise = false;
        SBQQ__Quote__c qt = new SBQQ__Quote__c();
        qt = [SELECT SBQQ__Opportunity2__r.StageName, SBQQ__Opportunity2__r.L2I_Product_Category__c
                FROM SBQQ__Quote__c
                WHERE Id = :quoteId];
        if (qt.SBQQ__Opportunity2__r.StageName == 'Handoff' ||
              (qt.SBQQ__Opportunity2__r.StageName == 'Delivery' &&
              qt.SBQQ__Opportunity2__r.L2I_Product_Category__c != 'DSS')){
            canRevise = true;
        }
        return canRevise;
    }
}