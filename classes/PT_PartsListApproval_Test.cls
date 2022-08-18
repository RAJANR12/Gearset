/**
* @File Name          : PT_PartsListApproval_Test.cls
* @Description        : Test Class for PT_PartsListApproval
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class PT_PartsListApproval_Test {
    @IsTest
    static void testBehavior() {
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
        salesOppty.PT_Program_Mgr__c = UserInfo.getUserId();
        salesOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOppty;
        
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
    
//            EmailTemplate validEmailTemplate = new EmailTemplate();
//            validEmailTemplate.IsActive = true;
//            validEmailTemplate.Name = 'name';
//            validEmailTemplate.DeveloperName = 'Part_List_Submit_for_Approval';
//            validEmailTemplate.TemplateType = 'text';
//            validEmailTemplate.FolderId = UserInfo.getUserId();
//            insert validEmailTemplate;
    
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
    }
}