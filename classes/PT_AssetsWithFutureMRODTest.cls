/**
* @File Name          : PT_AssetsWithFutureMRODTest.cls
* @Description        : Test Class for PT_AssetsWithFutureMROD
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class PT_AssetsWithFutureMRODTest {
    @IsTest
    static void assetsWithFutureMRODTest() {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);

        Id customerRecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID;
        Account acctCustomer = new Account(
              Name = 'Acct1',
              RecordTypeId = customerRecordTypeId);
        insert acctCustomer;

        Opportunity dealOppty = new Opportunity(
              Name = 'Deal Opp',
              CloseDate = Date.today(),
              StageName = 'Open'
        );
        insert dealOppty;

        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOppty = new Opportunity(
              Name = 'Sales Opp',
              AccountId = acctCustomer.Id,
              RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
              L2I_Product_Category__c = 'IFEC',
              CloseDate = Date.today(),
              StageName = 'Handoff',
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_AircraftQuantity__c = 1,
              L2I_Program_Num__c = prog1.Id,
              L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;

        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        update dsh;
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;

        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              PT_isActive__c = 'Active',
              PT_Program__c = prog1.Id
        );
        insert dsl;

        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active',
              Part_List_Opportunity__c = salesOppty.Id
        );
        insert instLoc2;

        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;

        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc2.Id,
              PT_Pending__c = Date.today(),
              PT_Program__c = prog1.Id,
              Product2Id = prod.Id,
              AccountId = acctCustomer.Id,
              PT_Configured_Quantity__c = 10,
              PT_Pending_Configured_Quantity__c = 15,
              Quantity = 10,
              PT_Pending_Quantity__c = 11,
              PT_Status__c = 'New',
              PT_MROD__c = Date.Today() + 5
        );
        insert ast;
        List<PT_AssetsWithFutureMROD.Requests> requests = new List<PT_AssetsWithFutureMROD.Requests>();
        PT_AssetsWithFutureMROD.Requests request = new PT_AssetsWithFutureMROD.Requests();
        request.dslId = dsl.Id;
        requests.add(request);

        PT_AssetsWithFutureMROD.assetsWithFutureMROD(requests);
    }
}