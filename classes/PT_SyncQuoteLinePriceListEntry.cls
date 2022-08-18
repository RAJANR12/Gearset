global class PT_SyncQuoteLinePriceListEntry {
    @InvocableMethod
    public static void syncQuoteLinePriceListEntry(List<FlowInput> inputs) {
        Set<Id> pleIds = new Set<Id>();
        Id quoteId = inputs[0].quoteId;
        Boolean updatePL = false;
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, PT_Price_List_Entry__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.PT_Price_List__c
                                                FROM SBQQ__QuoteLine__c
                                                WHERE SBQQ__Quote__c =: quoteId];
        for (SBQQ__QuoteLine__c qle : quoteLines) {
            pleIds.add(qle.PT_Price_List_Entry__c);
        }

        List<PT_PriceList_Entry__c> priceListEntries = [SELECT Id, PT_Status__c, PT_UnitPrice__c,
                                                        (SELECT Id, SBQQ__NetPrice__c FROM Quote_Lines__r)
                                                        FROM PT_PriceList_Entry__c
                                                        WHERE Id IN :pleIds AND PT_Status__c != 'Integrated'];
        for (PT_PriceList_Entry__c ple : priceListEntries) {
            Decimal listPrice;
            for (SBQQ__QuoteLine__c qle : ple.Quote_Lines__r) {
                if (qle.SBQQ__NetPrice__c != ple.PT_UnitPrice__c) {
                    ple.PT_Status__c = 'Reconcile';
                    break;
                } else {
                    listPrice = qle.SBQQ__NetPrice__c;
                    ple.PT_Status__c = 'Approved';
                }
            }
            if (ple.PT_Status__c == 'Approved') {
                ple.PT_UnitPrice__c = listPrice;
                updatePL = true;
            }
        }

        update priceListEntries;
        if (updatePL) {
            PT_PriceList__c updatePriceList = new PT_PriceList__c(Id = quoteLines[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.PT_Price_List__c, PT_Status__c = 'Integration Pending');
            update updatePriceList;
        }

    }

    public class FlowInput {
        @InvocableVariable
        public String quoteId;
    }
}