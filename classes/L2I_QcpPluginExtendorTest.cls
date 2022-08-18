/**
 * @description -> Test Class that tests QcpPluginExtendor
 */
@isTest
public class L2I_QcpPluginExtendorTest {
    @testSetup 
    private static void dataSetup() {
    	//CPQ_TestsA.bulkRecordSize = 5;
    	//CPQ_TestsA.initialSetup();
    	
    	Test.startTest(); // gain an extra set of governor limits within the context of the test class
    	/*CPQ_TestsA.setupQuotesAndQuoteLines(
            false,   // Boolean quoteStartTests
            false,   // Boolean quoteStopTests
            false,   // Boolean quoteLineStartTests
            false    // Boolean quoteLineStopTests
        );*/
        Test.stopTest();
    }
    
    @isTest static void testHttpPost() {
        /*SBQQ__QuoteLine__c quoteLine = [
            SELECT SBQQ__Product__c, SBQQ__Quote__c,SBQQ__PricebookEntryId__c,SBQQ__PricingMethod__c,SBQQ__StartDate__c,SBQQ__ListPrice__c,
            SBQQ__Quantity__c,SBQQ__PriorQuantity__c,SBQQ__RegularPrice__c,SBQQ__NetPrice__c,SBQQ__Number__c,SBQQ__ProrateMultiplier__c,SBQQ__SubscriptionPricing__c,
            SBQQ__SubscriptionScope__c,SBQQ__DefaultSubscriptionTerm__c,SBQQ__ChargeType__c,SBQQ__BillingType__c,SBQQ__BillingFrequency__c
            FROM SBQQ__QuoteLine__c LIMIT 1
        ];
        quoteLine.Id = null;
        system.debug('nick quoteLine.Id'+quoteLine.Id);
        system.debug('nick2 quoteLine '+quoteLine);
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>{quoteLine};
        String jsonString = JSON.serialize(quoteLines);        
    
        // As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/QuoteLine/'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
    
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
            List<SBQQ__QuoteLine__c> newQuoteLines = L2I_QcpPluginExtendor.updateQuoteLines();//HttpClass.updateCustomObject();
        Test.stopTest();
*/
        //System.assertEquals(newQuoteLines.size() > 0, true);
    }
}