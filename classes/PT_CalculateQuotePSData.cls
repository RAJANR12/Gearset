public class PT_CalculateQuotePSData {
    @InvocableMethod
    public static void invokeCalculateQuotePSData (List<Requests> requests) {
        if (requests[0].quoteId != null) {
            List<SBQQ__Quote__c> quoteList = [SELECT Id
                    FROM SBQQ__Quote__c
                    WHERE Id = :requests[0].quoteId AND SBQQ__Opportunity2__r.RecordType.DeveloperName IN ('Sales', 'Renewal', 'Amendment')];

            if (quoteList.size() == 1) {
                L2I_QuoteService.calculateTotalAircraftServiceMonths(requests[0].quoteId);
            }
            database.executeBatch(new PL_CalculatePSDataBatch(requests[0].quoteId));
        }
    }

    public class Requests {
        @InvocableVariable
        public Id quoteId;
    }
}