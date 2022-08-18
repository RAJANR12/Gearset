/**
* @File Name          : PT_ClearShipsetMRODDates_Test.cls
* @Description        : Test Class for PT_ClearShipsetMRODDates
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@IsTest
private class PT_ClearShipsetMRODDates_Test {
    @IsTest
    static void testClearingDates() {
        L2I_DataFactory factory = new L2I_DataFactory();
        
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
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;

        Opportunity salesOppty = new Opportunity(
              Name = 'Sales Opp',
              AccountId = acctCustomer.Id,
              RecordTypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
              L2I_Product_Category__c = 'IFEC',
              CloseDate = Date.today(),
              StageName = 'Quotation',
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Primary_System_Type__c = prodSysType.Id
        );
        insert salesOppty;
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        
        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id
        );
        insert dsl;
        
        PT_Program__c pgm = new PT_Program__c(
              Name = 'Prog1',
              Program_Number__c = 'Prog1'
        );
        insert pgm;
        System.debug('*** insert pgm');
        
        PT_Install_Location__c instLoc = new PT_Install_Location__c(
              Name = 'CW',
              ShipSet__c = dsl.Id,
              Pending_MROD__c = Date.today(),
              Status__c = 'Active'
        );
        insert instLoc;
        
        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;
        
        Product2 prod = factory.createProduct('99999802', 'MediaServices', '', '', null);
        prod.productCode = 'MCS BUNDLE';
        insert prod;
        
        Asset ast = new Asset(
              Name = 'Asset Name',
              PT_Install_Location__c = instLoc.Id,
              PT_MROD__c = Date.today(),
              PT_Pending__c = Date.today(),
              PT_Program__c = pgm.Id,
              Product2Id = prod.Id,
              AccountId = acctCustomer.Id,
              PT_Configured_Quantity__c = 10,
              Quantity = 10
        );
        insert ast;
        System.debug('*** inserted ast ' + ast);
        PT_ClearShipsetMRODDates.clearShipsetMRODDates(new List<Id>{dsl.Id});
        Test.startTest();
        update pgm;
        Test.stopTest();
        
        System.assertEquals(null, [SELECT PT_MROD__c FROM Asset LIMIT 1].PT_MROD__c, 'Asset Shipset MROD Date is cleared');
    }
}