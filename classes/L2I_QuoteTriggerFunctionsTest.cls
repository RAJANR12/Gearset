/**
 *      @author       Arun vadduri
 *      @date         07/12/2019
 *      @description  Test Class for L2I_QuoteTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Arun Vadduri                  07/12/2019            Test Class for L2I_QuoteTrigger
 *      Arun Vadduri                  08/19/2019            Refactored L2I_QuoteTriggerTest to cover L2I_Quote_TriggerFunctions
 *      Sarah Kennedy                 03/31/2020            US1618 added test for close Lost Renewal
 */
@isTest
private class L2I_QuoteTriggerFunctionsTest {
    
    @isTest
    private static void testQuoteClone() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
        
        SBQQ__Quote__c quote2 = quote.clone(false, true, false, false);
        
        Test.startTest();
        try {
            insert quote2;
        } Catch (Exception e) {
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testDisableTrigger() {
        insert new L2I_Trigger_Settings__c(SetupOwnerId = UserInfo.getUserId(), Disable_Quote__c = true);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        
        Test.startTest();
        insert quote;
        Test.stopTest();
    }
    
    @IsTest
    static void testRenewalQuote() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account Name' LIMIT 1];
    
        Account competitorCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Competitor' LIMIT 1];
        
        Opportunity oppDeal = [
              SELECT Id, Name, L2I_Delivery_Schedule__c, StageName, L2I_Win_Loss_Date__c
              FROM Opportunity
              WHERE Recordtype.DeveloperName = 'Deal'
              LIMIT 1
        ];
        
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        
        String renewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Opportunity renewalOpp = new Opportunity(
              L2I_Parent_Opportunity__c = oppDeal.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = renewId,
              StageName = 'Quotation',
              L2I_Closed_Lost_Reasoning__c = 'test',
              L2I_Win_Loss_Date__c = Date.today(),
              L2I_Fit_Type__c = 'Renewal',
              Name = 'Renew Opp',
              CloseDate = Date.today(),
              L2I_Delivery_Schedule__c = dsh.Id
        );
        insert renewalOpp;
    
        L2I_Competitors__c comp = new L2I_Competitors__c();
        comp.Opportunity__c = renewalOpp.Id;
        comp.CompetitorAccount__c = competitorCustomer.Id;
        comp.Type__c = 'DSS';
        comp.Primary__c = true;
        insert comp;
        
        renewalOpp.StageName = 'Closed Lost';
        update renewalOpp;
        
        
        SBQQ__Quote__c quote = factory.createQuote('draft', acct.Id, renewalOpp.Id, true);
        insert quote;
    }
}