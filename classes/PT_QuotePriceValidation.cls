public class PT_QuotePriceValidation {
    @InvocableMethod
    public static List<String> quotePriceValidationFlow(List<Requests> requests) {
        List<String> results = new List<String>();
        if (requests[0].quoteId != null) {
            String errorMsg = PT_QuotePriceValidation.quotePriceValidation(requests[0].quoteId);
            if(errorMsg != '') {
                results.add(errorMsg);
            } else {
                results.add('There is no price mismatch found for this quote.');
            }
        }
        return results;
    }

    public static String quotePriceValidation (Id quoteId) {
        List<String> errorMessages = new List<String>();
        String errorMsg = '';
        List<AggregateResult> queryList = [
                SELECT
                SBQQ__Quote__r.SBQQ__Opportunity2__c oppId
                ,SBQQ__Quote__r.SBQQ__Opportunity2__r.L2I_Product_Category__c prodCat //added by Jan for W-004455
                ,SBQQ__Group__r.SBQQ__SolutionGroup__r.Type__c oppType
                ,SBQQ__Product__r.ProductCode productCode
                ,MIN(SBQQ__NetPrice__c) minPrice
                ,MAX(SBQQ__NetPrice__c) maxPrice
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c = :quoteId
            AND SBQQ__NetPrice__c <> null
            AND SBQQ__Quote__r.SBQQ__Primary__c = True
            AND SBQQ__Product__r.ProductCode != 'IFE MISCELLANEOUS'
            GROUP BY SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Group__r.SBQQ__SolutionGroup__r.Type__c, SBQQ__Product__r.ProductCode, 
                     SBQQ__Quote__r.SBQQ__Opportunity2__r.L2I_Product_Category__c //added by Jan for W-004455
            HAVING COUNT(SBQQ__Product__c) > 1
        ];
        for (AggregateResult ar: queryList) {
            if(ar.get('prodCat') != 'PTS'){ //added by Jan for W-004455
                if (ar.get('minPrice') == ar.get('maxPrice')) continue;
                errorMsg += 'Mismatched pricing in ' + ar.get('oppType') + ' for Part ' + ar.get('productCode') + '\n';
            }
        }
        return errorMsg;
    }

    public class Requests {
        @InvocableVariable
        public Id quoteId;
    }

}