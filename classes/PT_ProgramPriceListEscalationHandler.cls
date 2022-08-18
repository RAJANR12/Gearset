/**
 *      @author       Nitin Gupta
 *      @date         01/07/2021
 *      @description  PT_ProgramPriceListEscalationHandler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Nitin Gupta                01/08/2021            Initial creation
 */


public class PT_ProgramPriceListEscalationHandler {
    public static void escalateProgramPriceList(Id progPriceListId, Decimal escalationPercentage, String description) {
        PT_PriceList__c progPL = [SELECT Id, Name, PT_Description__c, PT_IsActive__c, PT_Price_List_Name__c, PT_Price_List_Sequence__c, PT_Program__c, PT_Program__r.Name
                                FROM PT_PriceList__c
                                WHERE Id = :progPriceListId];
        String maxPriceListSeq = [SELECT Id, PT_Price_List_Sequence__c FROM PT_PriceList__c  WHERE PT_Program__c = :progPL.PT_Program__c ORDER BY PT_Price_List_Sequence__c DESC LIMIT 1].PT_Price_List_Sequence__c;
        String nextPriceListSeq = String.valueOf(Decimal.valueOf(maxPriceListSeq) + 1);
        if (nextPriceListSeq.length() == 1) {
            nextPriceListSeq = '0' + nextPriceListSeq;
        }
        List<PT_PriceList_Entry__c> progPLEList = [SELECT Id, Name, PT_CanEscalate__c, PT_Description__c, PT_EndDate__c, PT_isActive__c, PT_Product__c,
                                                    PT_Program_Price_List__c, PT_StartDate__c, PT_Status__c, PT_UnitPrice__c
                                                    FROM PT_PriceList_Entry__c
                                                    WHERE PT_Program_Price_List__c = :progPriceListId];

        PT_PriceList__c priceList = new PT_PriceList__c(PT_Program__c = progPL.PT_Program__c,
                                                        PT_Description__c = ' \n Escalation of Price list ' + progPL.Name + ' using factor of ' + escalationPercentage + '\n' + description,
                                                        PT_IsActive__c = TRUE,
                                                        PT_Price_List_Sequence__c = nextPriceListSeq,
                                                        PT_Price_List_Name__c = 'CPL-PL-' + progPL.PT_Program__r.Name + '-' + nextPriceListSeq);
        insert priceList;

        List<PT_PriceList_Entry__c> insertPLE = new List<PT_PriceList_Entry__c>();
        for (PT_PriceList_Entry__c ple : progPLEList) {
            insertPLE.add(new PT_PriceList_Entry__c(
                    PT_Program_Price_List__c = priceList.Id,
                    PT_CanEscalate__c = ple.PT_CanEscalate__c,
                    PT_isActive__c = ple.PT_isActive__c,
                    PT_StartDate__c = Date.today(),
                    PT_Status__c = 'New',
                    PT_Product__c = ple.PT_Product__c,
                    PT_UnitPrice__c = ple.PT_CanEscalate__c ? ple.PT_UnitPrice__c * (1 + escalationPercentage) : ple.PT_UnitPrice__c,
                    Name = ple.Name
                ));
        }
        if (insertPLE.size() > 0) {
            insert insertPLE;
        }
    }

}