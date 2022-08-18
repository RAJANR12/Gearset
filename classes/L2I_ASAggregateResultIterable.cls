/**
 *      @author       Sarah Kennedy
 *      @date         03/16/2020
 *      @description  Iterable class calling L2I_ASAggregateResultIterator class for use in allowing
 *                    aggregate SOQL in L2I_AircraftServiceUsageBatch
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 01/03/2020         Initial creation based on https://help.salesforce.com/articleView?id=000333422&type=1&mode=1
 */
global class L2I_ASAggregateResultIterable implements Iterable<AggregateResult> {
    global Date BATCH_RUN_DATE;
    global L2I_ASAggregateResultIterable(Date batchDate){
        BATCH_RUN_DATE = batchDate;
    }
    global Iterator<AggregateResult> Iterator() {
        return new L2I_ASAggregateResultIterator(BATCH_RUN_DATE);
    }
}