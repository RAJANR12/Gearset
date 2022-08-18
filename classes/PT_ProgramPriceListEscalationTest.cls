/**
* @File Name          : PT_ProgramPriceListEscalationTest.cls
* @Description        : Test Class for PT_ProgramPriceListEscalation
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@isTest
public class PT_ProgramPriceListEscalationTest {
    private static L2I_DataFactory factory;
    @isTest
    static void escalateProgramPriceListFromFlowTest() {
        factory = new L2I_DataFactory();
        List<PT_PriceList_Entry__c> insertPLE = new List<PT_PriceList_Entry__c>();
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
		
        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOpp;

        Product2 product = factory.createProduct('99999801', 'MediaServices', null, null, null);
        product.productCode = 'MCS BUNDLE';
        insert product;

        Product2 product1 = factory.createProduct('99999802', 'MediaServices', null, null, null);
        product1.productCode = 'MCS BUNDLE';
        insert product1;

        PT_PriceList__c priceList = new PT_PriceList__c(PT_Program__c = null,
                                                        PT_Description__c = 'TBD',
                                                        PT_IsActive__c = TRUE,
                                                        PT_Price_List_Sequence__c = '01',
                                                        PT_Price_List_Name__c = 'TestPL',
                                                        PT_Opportunity__c = salesOpp.Id);
        insert priceList;
        insertPLE.add(new PT_PriceList_Entry__c(
                        PT_Program_Price_List__c = priceList.Id,
                        PT_CanEscalate__c = TRUE,
                        PT_isActive__c = TRUE,
                        PT_StartDate__c = Date.today(),
                        PT_Status__c = 'Approved',
                        PT_Product__c = product.Id,
                        PT_UnitPrice__c = 20.0,
                        Name = 'Test123'
        ));
        insertPLE.add(new PT_PriceList_Entry__c(
                        PT_Program_Price_List__c = priceList.Id,
                        PT_CanEscalate__c = TRUE,
                        PT_isActive__c = TRUE,
                        PT_StartDate__c = Date.today(),
                        PT_Status__c = 'Approved',
                        PT_Product__c = product1.Id,
                        PT_UnitPrice__c = 30.0,
                        Name = 'Test1234'
        ));

        if (insertPLE.size() > 0) {
            insert insertPLE;
        }

        List<PT_ProgramPriceListEscalationController.FlowInput> requests = new List<PT_ProgramPriceListEscalationController.FlowInput>();
        PT_ProgramPriceListEscalationController.FlowInput req = new PT_ProgramPriceListEscalationController.FlowInput();
        req.progPriceListId = priceList.Id;
        req.escalationPercentage = 1.20;
        req.description = 'Test';
        requests.add(req);

        PT_ProgramPriceListEscalationController.escalateProgramPriceListFromFlow(requests);
    }
}