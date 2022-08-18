/**
* @File Name          : L2I_ConnectAPIService_Test.cls
* @Description        : Test Class for L2I_ConnectAPIService
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest(SeeAllData=true)
private class L2I_ConnectAPIService_Test {
    // ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true).
    @IsTest
    static void testFeed() {
    
        L2I_DataFactory factory = new L2I_DataFactory();
        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC System Administrator');
        User salesUser = factory.createTestUser(null, salesProfile.Id, 'Sales', 'User');
        insert salesUser;
        
        test.startTest();  
        System.runAs(salesUser) {
            Account testAccount = new Account(Name = 'BRITISH AIRWAYS CORP',
                                              L2I_Account_Status__c = 'Active');
            insert testAccount;
            
            // Added for W-001727
            Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
            insert prodSysType;
            
            Id RecordTypeIdOpportunityDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
            Opportunity testParentOpp = new Opportunity(Name = 'TestParentOpp',
                                                        StageName = 'Quotation',
                                                        CloseDate = Date.today(),
                                                        AccountId = testAccount.Id,
                                                        RecordTypeId = RecordTypeIdOpportunityDeal);
            insert testParentOpp;
            
            Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
            Opportunity testOpp = new Opportunity(Name = 'TestParentOpp',
                                                  StageName = 'Quotation',
                                                  CloseDate = Date.today(),
                                                  L2I_Parent_Opportunity__c = testParentOpp.Id,
                                                  L2I_Product_Category__c = 'IFEC',
                                                  RecordTypeId = RecordTypeIdOpportunitySales,
                                                  L2I_Primary_System_Type__c = prodSysType.Id);
            insert testOpp;
            
            List<L2I_ConnectAPIService.ConnectAPIWrap> caWrapList = new List<L2I_ConnectAPIService.ConnectAPIWrap>();
            L2I_ConnectAPIService.ConnectAPIWrap caWrap;
            caWrap = new L2I_ConnectAPIService.ConnectAPIWrap();
            caWrap.objectId = testOpp.Id;
            caWrap.ownerId = testOpp.OwnerId;
            caWrap.message = ' test message ';
            caWrapList.add(caWrap);
            
            Integer batchCount = L2I_ConnectAPIService.createChat(caWrapList);
            System.debug('*** batchCount ' + batchCount);
            System.assertEquals(1, batchCount);
        }       
    }
}