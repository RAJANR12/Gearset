/**
* @File Name          : PT_PartsListApprovalView_Test.cls
* @Description        : Test Class for PT_PartsListApprovalView
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class PT_PartsListApprovalView_Test {
    @IsTest
    static void testPLApproval() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
    
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
		
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'IFEC');
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        salesOppty.PT_Program_Mgr__c = UserInfo.getUserId();
        salesOppty.L2I_Fit_Type__c = 'Production';
        insert salesOppty;
    
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
        
            //Create Parent Group
            Group grp = new Group();
            grp.DeveloperName = 'Program_PM_PPM_QueueTEST';
            grp.Name = 'Program_PM_PPM_QueueTEST';
            grp.Type = 'Queue';
            insert grp;
        
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = UserInfo.getUserId();
            grpMem1.GroupId = grp.Id;
            insert grpMem1;
            List<PT_PartsListApproval.PLApprovalParams> pppList = new List<PT_PartsListApproval.PLApprovalParams>();
            PT_PartsListApproval.PLApprovalParams ppp = new PT_PartsListApproval.PLApprovalParams();
            ppp.oppId = salesOppty.Id;
            pppList.add(ppp);
        
            PT_PartsListApproval.processPartsListApproval(pppList);
        }
    
        ProcessInstance objProcessInstance = [SELECT Id,TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :salesOppty.Id];
        System.assertNotEquals(null,objProcessInstance);
    
        List<PT_PartsListApprovalView.PLApprovalWrapper> pawList = PT_PartsListApprovalView.getPendingPLApprovals();
        System.assertEquals(1, pawList.size());
    }
    
    @IsTest
    static void testMRODApproval() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'PAC Sales'].Id;
        User u1 = factory.createTestUser(null, profileId, 'User1', 'Test');
        insert u1;
        User u2 = factory.createTestUser(null, profileId, 'User2', 'Test');
        insert u2;
        User u3 = factory.createTestUser(null, profileId, 'User3', 'Test');
        insert u3;
        
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'IFEC');
        salesOppty.PT_Program_Mgr__c = UserInfo.getUserId();
        salesOppty.L2I_Fit_Type__c = 'Production';
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
    
        PT_PMO_Groups__c pg = new PT_PMO_Groups__c(
              Name = 'pgName',
              Group_Type__c = 'Group'
        );
        insert pg;
        pg.OwnerId = u1.Id;
        update pg;
    
        PT_PMO_Groups__c pg2 = new PT_PMO_Groups__c(
              Name = 'pgName2',
              Group_Type__c = 'Sub Group'
        );
        insert pg2;
        pg2.OwnerId = u2.Id;
        update pg2;
        
    
        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        prog1.PT_PMO_Group__c = pg.Id;
        prog1.PT_PMO_SubGroup__c = pg2.Id;
        prog1.Program_Manager__c = u1.Id;
        prog1.Principal_Program_Manager__c = u2.Id;
        prog1.PMO_Regional_Director__c = u3.Id;
        insert prog1;
        
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            
            //Create Parent Group
            Group grp = new Group();
            grp.DeveloperName = 'Program_PM_PPM_QueueTEST';
            grp.Name = 'Program_PM_PPM_QueueTEST';
            grp.Type = 'Queue';
            insert grp;
            
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = UserInfo.getUserId();
            grpMem1.GroupId = grp.Id;
            insert grpMem1;
    
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(prog1.Id);
            req1.setProcessDefinitionNameOrId('Program_MROD_Approval_v3');
            Approval.ProcessResult result = Approval.process(req1);
            
            System.assert(result.isSuccess());
        }
        
        ProcessInstance objProcessInstance = [SELECT Id,TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :prog1.Id];
        System.assertNotEquals(null,objProcessInstance);
        
        List<PT_PartsListApprovalView.PLApprovalWrapper> pawList = PT_PartsListApprovalView.getPendingPLApprovals();
        System.debug('*** pawList.size() ' + pawList.size());
    }
    
}