/**
 *      @author       Sarah Kennedy
 *      @date         02/04/2020
 *      @description  Process DSL Opportunity QuoteLines for Install Location QLs and Part Number QLs,
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 01/16/2020         Initial creation
 *      Sreekanth Basireddy           02/04/2020         Updates for Program Table
 */
global with sharing class PT_AssignPTCPLController {
// process the QuoteLines for the DSL root asset
    @InvocableMethod
    public static void processDSLQuoteLinesFlow(List<FlowInput> inputs) {
        String primaryQuoteId;
        try {
            for (FlowInput inId : inputs) {
                primaryQuoteId = inId.primaryQuoteId;
                PT_AssignPTCPLBatch batch = new PT_AssignPTCPLBatch(primaryQuoteId);
                Id batchId = Database.executeBatch(batch, 25);
            }
        } catch (DMLException e) {
            System.debug('DML Exception error: ' + e);
            throw new AuraHandledException('There was an error in Assigning CPL: ' + e.getMessage());
        }
    }

    public class FlowInput {
        @InvocableVariable
        public String primaryQuoteId;
    }
}