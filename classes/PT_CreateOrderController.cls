/**
 *      @author       Nitin Gupta
 *      @date         10/29/2020
 *      @description  Create Orders Controller
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Nitin Gupta                10/29/2020        Initial creation
 */
global class PT_CreateOrderController {
    @InvocableMethod
    public static void createOrderFromFlow(List<FlowInput> inputs) {
        String caseId;

        try {
            for (FlowInput inId : inputs) {
                caseId = inId.caseId;
                // Call Create Order Class
                PT_CreateOrderControllerHandler.createOrderFromCase(caseId);
            }
        } catch (DMLException e) {
            System.debug('DML Exception error: ' + e);
            throw e; // Added by Arun - 02.22.21
            //throw new AuraHandledException('There was an error in Assigning CPL: ' + e.getMessage());
        }
    }

    public class FlowInput {
        @InvocableVariable
        public String caseId;
    }
}