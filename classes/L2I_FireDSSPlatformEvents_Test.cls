/**
 *      @author       Raj Rajen
 *      @date         08/18/2019
 *      @description  Test class for Firing DSS Platform Events Queueable class
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     09/05/2019         Initial setup of tests
 *      MS Simplus Khrisna            03/31/2022         W-001727 Primary System Type Validation Rule
 */
@IsTest(SeeAllData=false)
public class L2I_FireDSSPlatformEvents_Test {

    @IsTest
    static void test_fire_dss_events() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');

        //Create Opportunity
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');

        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
                dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;

        SBQQ__Quote__c quote = factory.createQuote('draft', namedCustomer.Id, salesOppty.Id, true);
        insert quote;

        System.assert(quote.Id != null, 'Quote id cannot be null');

        Order theTestOrder = new Order(AccountId = namedCustomer.Id,
                                       PoNumber= 'Test',
                                       EffectiveDate = Date.today(),
                                       Status='Draft',
                                       Pricebook2Id=Test.getStandardPricebookId(),
                                       blng__BillingDayOfMonth__c = '30',
                                       OpportunityId = salesOppty.Id,
                                       SBQQ__Quote__c = quote.Id);
        insert theTestOrder;

        Set<Id> orderIds = new Set<Id>();
        orderIds.add(theTestOrder.Id);

        Test.startTest();
            L2I_FireDSSPlatformEvents dssEventsQueueable = new L2I_FireDSSPlatformEvents(orderIds);
            Id jobId = System.enqueueJob(dssEventsQueueable);
            System.debug('====== Enqueued Job Id :' + jobId);
        Test.stopTest();

    }

}