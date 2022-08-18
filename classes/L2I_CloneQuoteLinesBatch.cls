public class L2I_CloneQuoteLinesBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    SBQQ__Quote__c sourceQuote;
    SBQQ__Quote__c clonedQuote;
    Map<String, SBQQ__QuoteLineGroup__c> clonedGroups;
    
    public L2I_CloneQuoteLinesBatch(SBQQ__Quote__c sourceQuote, SBQQ__Quote__c clonedQuote, Map<String, SBQQ__QuoteLineGroup__c> clonedGroups) {
        this.sourceQuote = sourceQuote;
        this.clonedQuote = clonedQuote;
        this.clonedGroups = clonedGroups;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Id quoteId = sourceQuote.Id;
        String query = L2I_QuoteCloneUtility.generateQuery('SBQQ__QuoteLine__c', new Set<String>{'PT_Price_List_Entry__r.PT_UnitPrice__c','PT_Price_List_Entry__r.PT_Program_Price_List__c','PT_Price_List_Entry__r.PT_Program_Price_List__r.PT_Price_List_Name__c'});
        query += ' Where SBQQ__Quote__c = :quoteId Order By SBQQ__Quote__c,SBQQ__RequiredBy__c';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SBQQ__QuoteLine__c> scope) {
        List<SBQQ__QuoteLine__c> quoteLines = L2I_QuoteCloneUtility.cloneQuoteLinesWithoutRequiredby(new Map<Id, List<SBQQ__QuoteLine__c>>{sourceQuote.Id=>scope}, new Map<Id, SBQQ__Quote__c>{sourceQuote.Id=>sourceQuote}, new Map<Id, SBQQ__Quote__c>{clonedQuote.Id=>clonedQuote}, clonedGroups);
        SBQQ.TriggerControl.disable();
        insert quoteLines;
        SBQQ.TriggerControl.enable();
    }
    
    public void finish(Database.BatchableContext bc) {
        L2I_QuoteCloneUtility.populateRequiredBy(sourceQuote.Id, clonedQuote.Id);
    }
}