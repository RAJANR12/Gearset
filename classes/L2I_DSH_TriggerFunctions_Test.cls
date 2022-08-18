/**
* @File Name          : L2I_DSH_TriggerFunctions_Test.cls
* @Description        : Test Class for L2I_DSH_TriggerFunctions
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class L2I_DSH_TriggerFunctions_Test {
    @IsTest
    static void testDelete() {
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
    
        Account acct = [SELECT Id FROM Account LIMIT 1];
    
        Opportunity oppDeal = [SELECT Id, Name, L2I_Delivery_Schedule__c, StageName, L2I_Win_Loss_Date__c
        FROM Opportunity WHERE Recordtype.DeveloperName = 'Deal' LIMIT 1];
    
        Opportunity oppIFEC = [SELECT Id, Name, L2I_Delivery_Schedule__c, StageName, L2I_Win_Loss_Date__c
        FROM Opportunity WHERE Recordtype.DeveloperName = 'Sales' LIMIT 1];
    
        L2I_DSH__c dsh = [SELECT Id, Name FROM L2I_DSH__c LIMIT 1];
        dsh.Product_Category__c = 'IFEC';
        update dsh;
        Test.startTest();
        Boolean gotError = false;
        try {
            delete dsh;
        } catch (Exception e){
            gotError = true;
        }
        Test.stopTest();
    
        System.assertEquals(false, gotError);
    }
    
    @IsTest
    static void testNoDelete() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
        Test.startTest();
        Opportunity opp = [SELECT Id, AccountId, StageName, L2I_Primary_System_Type__c FROM Opportunity WHERE RecordType.DeveloperName = 'Sales' LIMIT 1];
        // START: Added by Khrisna for W-004060
        SBQQ__Quote__c quote = [SELECT Id, SubmittedDate__c, L2I_Final_Proposal_Submission_Date__c FROM SBQQ__QUOTE__c
        WHERE SBQQ__Opportunity2__c =:opp.Id LIMIT 1];
        quote.SubmittedDate__c = Date.today();
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today();
        update quote;
        // END: W-004060
        opp.StageName = 'Closed Won';
        update opp;
        
        
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Boolean gotError = false;
        
        try {
            delete dsh;
        } catch (Exception e){
            gotError = true;
        }
        System.assertEquals(true, gotError);
        Test.stopTest();
        
        
    }
    
    @IsTest
    static void testNoDelete2() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE RecordType.DeveloperName = 'Sales' LIMIT 1];
        opp.StageName = 'Closed Lost';
        update opp;
        
        Test.startTest();
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        Boolean gotError = false;
        try {
            delete dsh;
        } catch (Exception e){
            gotError = true;
        }
        System.assertEquals(true, gotError);
        Test.stopTest();
        
        
    }

}