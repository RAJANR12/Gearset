/**
 *      @author       Sarah Kennedy
 *      @date         01/04/2020
 *      @description  Test class for L2I_CustomLookupController
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 01/04/2020         Initial setup of tests
 *
 */
@IsTest
private class L2I_CustomLookupController_Test {
    @IsTest
    static void testResults() {
        List<Account> acctList = new List<Account>();
        Account testAccount = new Account(
              Name = 'BRITISH AIRWAYS CORP',
              AccountNumber = '1058',
              L2I_Account_Status__c = 'Active'
        );
        acctList.add(testAccount);
    
        Account testAccount2 = new Account(
              Name = 'GENSYS, INC',
              AccountNumber = '1058',
              L2I_Account_Status__c = 'Active'
        );
        acctList.add(testAccount2);
    
        Account testAccount3 = new Account(
              Name = 'BRITANY FIREPLACES, INC',
              AccountNumber = '1058',
              L2I_Account_Status__c = 'Active'
        );
        acctList.add(testAccount3);
        insert acctList;
        
        
       List<L2I_CustomLookupController.SObjectResult> resultList =
             L2I_CustomLookupController.getResults('Account', 'Name', 'bri', null);
    
        System.assertEquals(resultList.size(), 2, '2 records were found');
    }
}