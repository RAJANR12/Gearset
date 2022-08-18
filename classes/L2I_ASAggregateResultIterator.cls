/**
 *      @author       Sarah Kennedy
 *      @date         03/16/2020
 *      @description  Iterator class called from L2I_ASAggregateResultIterable class for use in allowing
 *                    aggregate SOQL in L2I_AircraftServiceUsageBatch
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 01/03/2020         Initial creation based on https://help.salesforce.com/articleView?id=000333422&type=1&mode=1
 *      Sanjay Singhal                07/23/2020         US2009 - added a filter to not count suspended ASA records L2I_Suspended__c = false
 */
global class L2I_ASAggregateResultIterator Implements Iterator<AggregateResult> {
    AggregateResult [] results { get; set; }
    Integer index { get; set; }
    global L2I_ASAggregateResultIterator(Date BATCH_RUN_DATE) {
        index = 0;
        results = Database.query( 'SELECT Count(Id) recCount, ' +
                    '     Matching_Id__c billMatch ' +
                    'FROM L2I_Aircraft_Service__c ' +
                    '  WHERE Product2__r.L2I_Service_Activation_Type__c like \'Monthly%\' ' +
                    '    AND Product2__r.SBQQ__ChargeType__c = \'Usage\' ' +
                    '    AND L2I_Activation_Date__c != null ' +
                    '    AND L2I_Activation_Date__c <= :BATCH_RUN_DATE ' +
                    '    AND (L2I_Deactivation_Date__c = null OR L2I_Deactivation_Date__c > :BATCH_RUN_DATE) ' +
                    '    AND Status__c <> \'Canceled\' ' +
                    '    AND Matching_Id__c != null ' +
                    '    AND L2I_Suspended__c = false ' +
                    'GROUP BY Matching_Id__c ');
    }
    
    global boolean hasNext() {
        return results != null && !results.isEmpty() && index < results.size();
    }
    global AggregateResult next() {
        // index gets incremented after return
        return results[index++];
    }
}