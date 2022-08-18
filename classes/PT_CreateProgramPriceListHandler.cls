/**
 *      @author       Nitin Gupta
 *      @date         01/07/2021
 *      @description  Create Program Part List Controller Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Nitin Gupta                01/07/2021            Initial creation
 */


public class PT_CreateProgramPriceListHandler {
    public static void createInitialProgramPriceList(Id programId) {
        PT_Program__c prog = [SELECT Id, Name, Sales_Opportunity__c, Sales_Opportunity__r.SBQQ__PrimaryQuote__c FROM PT_Program__c WHERE Id = :programId];
        PT_PriceList__c priceList = new PT_PriceList__c(PT_Program__c = prog.Id,
                                                        PT_Description__c = 'TBD',
                                                        PT_IsActive__c = TRUE,
                                                        PT_Price_List_Sequence__c = '01',
                                                        PT_Price_List_Name__c = 'CPL-PL-' + prog.Name + '-01');
        insert priceList;

        prog.PT_Primary_Price_List__c = priceList.Id;
        update prog;

        if (prog.Sales_Opportunity__c != null && prog.Sales_Opportunity__r.SBQQ__PrimaryQuote__c != null) {
            PT_ProgramPriceList_Utils.createUpdatePriceListEntries(prog.Sales_Opportunity__r.SBQQ__PrimaryQuote__c, priceList.Id);
        }
        if (prog.Sales_Opportunity__c != null) {
            Opportunity oppty = new Opportunity (Id = prog.Sales_Opportunity__c, PT_Price_List__c = priceList.Id);
            update oppty;
        }
    }
}