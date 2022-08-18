/**
 *      @author       Nitin Gupta
 *      @date         01/07/2021
 *      @description  PT_CreateProgramPriceListController
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Nitin Gupta                01/07/2021        Initial creation
 */
global class PT_CreateProgramPriceListController {
    @InvocableMethod
    public static void createProgramPriceListFromFlow(List<FlowInput> inputs) {
        String programId;
        try {
            for (FlowInput inId : inputs) {
                programId = inId.programId;
                PT_CreateProgramPriceListHandler.createInitialProgramPriceList(programId);
            }
        } catch (DMLException e) {
            System.debug('DML Exception error: ' + e);
            throw new AuraHandledException('There was an error in creating program price list: ' + e.getMessage());
        }
    }

    public class FlowInput {
        @InvocableVariable
        public String programId;
    }
}