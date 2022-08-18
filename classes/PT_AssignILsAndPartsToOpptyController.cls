/**
 *      @author       Nitin Gupta
 *      @date         10/08/2020
 *      @description  Process Opportunity QuoteLines for Install Location QLs and Part Number QLs,
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Nitin Gupta                 10/08/2020             Initial creation
 */
global class PT_AssignILsAndPartsToOpptyController {
    // process the QuoteLines for the PPL
        @InvocableMethod
        public static void processAssignPartsToOppty(List<FlowInput> inputs) {
            String primaryQuoteId;
            try {
                for (FlowInput inId : inputs) {
                    primaryQuoteId = inId.primaryQuoteId;
                    PT_AssignILsAndPartsToOpptyBatch batch = new PT_AssignILsAndPartsToOpptyBatch(primaryQuoteId);
                    Id batchId = Database.executeBatch(batch, 1);
                }
            } catch (DMLException e) {
                System.debug('DML Exception error: ' + e);
                throw new AuraHandledException('There was an error in Assigning Oppty: ' + e.getMessage());
            }
        }

        public class FlowInput {
            @InvocableVariable
            public String primaryQuoteId;
        }
    }