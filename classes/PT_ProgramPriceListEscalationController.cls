/**
 *      @author       Nitin Gupta
 *      @date         01/08/2021
 *      @description  PT_ProgramPriceListEscalationController
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Nitin Gupta                01/07/2021        Initial creation
 */
global class PT_ProgramPriceListEscalationController {
    @InvocableMethod
    public static void escalateProgramPriceListFromFlow(List<FlowInput> inputs) {
        String progPriceListId;
        Decimal escalationPercentage;
        String description;
        try {
            for (FlowInput inId : inputs) {
                progPriceListId = inId.progPriceListId;
                escalationPercentage = inId.escalationPercentage/100;
                description = inId.description;
                PT_ProgramPriceListEscalationHandler.escalateProgramPriceList(progPriceListId, escalationPercentage, description);
            }
        } catch (DMLException e) {
            System.debug('DML Exception error: ' + e);
            throw new AuraHandledException('There was an error in escalating program price list: ' + e.getMessage());
        }
    }

    public class FlowInput {
        @InvocableVariable
        public String progPriceListId;
        @InvocableVariable
        public Decimal escalationPercentage;
        @InvocableVariable
        public String description;
    }
}