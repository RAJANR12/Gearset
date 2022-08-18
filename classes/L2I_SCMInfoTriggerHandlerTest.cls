/**
* @File Name          : L2I_SCMInfoTriggerHandlerTest.cls
* @Description        : Test Class for L2I_SCMInfoTriggerHandler
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
**/
@isTest
public class L2I_SCMInfoTriggerHandlerTest {
    
    @isTest
    static void testSCMBeforeInsert() {
                
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated'); 
        
        test.startTest();
        L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c LIMIT 1];
        dsh.Product_Category__c = 'IFEC';
        update dsh;
        
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        Opportunity dealOpp = [SELECT Id FROM Opportunity WHERE RecordType.Developername = 'DEAL' LIMIT 1];
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
            Name = 'TestSalesOpp',
            StageName = 'Quotation',
            CloseDate = Date.today(),
            L2I_Parent_Opportunity__c = dealOpp.Id,
            L2I_Product_Category__c = 'DSS',
            L2I_Delivery_Schedule__c = dsh.Id,
            RecordTypeId = salesId);
        insert salesOppty;
        
        Opportunity salesOppty1 = new Opportunity(
            Name = 'TestSalesOpp2',
            StageName = 'Quotation',
            CloseDate = Date.today(),
            L2I_Parent_Opportunity__c = dealOpp.Id,
            L2I_Product_Category__c = 'DSS',
            L2I_Delivery_Schedule__c = dsh.Id,
            RecordTypeId = salesId);
        insert salesOppty1;
        
        Opportunity oppoRecord = [Select Id, L2I_Opportunity_Number__c From Opportunity Where Id =: salesOppty.Id];
        
        String opportunityNumber = oppoRecord.L2I_Opportunity_Number__c;
        String opportunityId = oppoRecord.Id;
        
        L2I_Aircraft_Type__c atype = new L2I_Aircraft_Type__c(
              Name = 'F-18TestThis',
              L2I_PAC_Type_Designator__c = 'ABCD',
              L2I_Model__c = 'GT',
              Manufacturer__c = namedCustomer.Id,
              L2I_Aircraft_Type__c = 'MyTest',
              L2I_Is_Active__c = true,
              L2I_Manufacturer_Party_ID__c = 123456,
              L2I_Make__c = 'ABC',
              L2I_Series__c = 'DEF'
        );
        insert atype;
    
        L2I_Aircraft__c ac = new L2I_Aircraft__c(
              L2I_Aircraft_Status__c = 'In Service',
              Name = 'Test A/C 1',
              L2I_GPIN__c = 'A319-1100',
              L2I_Operator__c = namedCustomer.Id,
              L2I_Serial_Number__c = 'abc12289',
              L2I_Aircraft_Delivery_Date__c = DATE.today().addDays(30),
              Aircraft_Type__c = atype.Id,
              L2I_Approved__c = true,
              L2I_Registration_Number__c = 'SK-Test-CEE'
        );
        insert ac;
        
        PT_Program__c prog = new PT_Program__c();
        prog.Name = 'Test1234';
        prog.Program_Number__c = 'Test1234';
        prog.Aircraft_Identifier_Field__c = 'Tail Number';
        insert prog;
        
        L2I_DSL__c dsl = [SELECT Id, 
                              Original_Opportunity__c, 
                              Original_Opportunity__r.L2I_Opportunity_Number__c,
                              Delivery_Schedule_Header__c, 
                              Delivery_Date__c 
                          FROM L2I_DSL__c 
                          LIMIT 1];
        dsl.Aircraft__c = ac.Id;
        dsl.Original_Opportunity__c = salesOppty.Id;
        dsl.PT_Program__c = prog.Id;
        update dsl;
        System.debug('-- dsl: ' + dsl);
        L2I_DSH__c dsh2 = new L2I_DSH__c(
              Product_Category__c = 'DSS',
              Account__c = namedCustomer.Id
        );
        insert dsh2;
        
        L2I_DSL__c dsl1 = new L2I_DSL__c();
        dsl1.Original_Opportunity__c = salesOppty1.Id;
        dsl1.Delivery_Schedule_Header__c = dsh2.Id;
        dsl1.Delivery_Date__c = Date.today();
        dsl1.Line_Number__c = '001';
        dsl1.IFEC_DSL__c = dsl.Id;
        dsl1.Aircraft__c = ac.Id;
        dsl1.PT_Program__c = prog.Id;
        insert dsl1;
        System.debug('-- dsl1: ' + dsl1);
        //Product2 prod = new Product2(L2I_Inventory_Item_Id__c=externalId,
                                     //Name='Test Product',
                                     //L2I_Category__c=category,
                                     //L2I_Sub_Category_1__c=subCategory1,
                                     //L2I_Sub_Category_2__c=subCategory2
                                     //);
        Product2 prodRecord = [Select Id, Name, L2I_Sub_Category_2__c, L2I_Service_Activation_Type__c from Product2 limit 1];
        System.debug ('prodRecord is ' +prodRecord);
        
        PricebookEntry pbeRecord = [Select Id,
                                      Product2Id,
                                      Pricebook2Id,
                                      UnitPrice,
                                      IsActive
                                  From PricebookEntry
                                  Where Product2Id =: prodRecord.Id];
        
        //Case caseRecord = [Select Id, IFE_Program_Number__c From Case limit 1];
        
        Id aircraftOrder = L2I_UtilityHelper.getRecordTypeId('L2I_Aircraft_Order', 'Case');
        Case cse = new Case(
              //L2I_Order__c = theTestOrder.Id,
              RecordTypeId = aircraftOrder,
              L2I_Case_Process__c = 'Revise'
        );
        insert cse;
        
        Order ord1 = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c, 
                      L2I_1st_Aircraft_Entered_In_Service__c, L2I_1st_AC_Entered_In_Service_Date__c
                      FROM Order LIMIT 1];
        ord1.OpportunityId = salesOppty.Id;
        ord1.PT_Case__c = cse.Id;
        //ord1.L2I_1st_Aircraft_Entered_In_Service__c = false;
        //ord1.L2I_1st_AC_Entered_In_Service_Date__c = null;
        ord1.Status = 'Draft';
        update ord1;
        System.debug('Order is '+ord1);
        
        OrderItem theTestOrderItem = new OrderItem(OrderId = ord1.id,
                                                       Quantity = 1,
                                                       Product2Id = prodRecord.Id,
                                                       PricebookEntryId = pbeRecord.Id,
                                                       UnitPrice = pbeRecord.UnitPrice,
                                                       L2I_Sub_Category_2__c = prodRecord.L2I_Sub_Category_2__c,
                                                       L2I_PO_Required__c = true,
                                                       L2I_Frequency__c = 'Monthly (12)',
                                                       SBQQ__ChargeType__c = 'Recurring',
                                                       SBQQ__BillingFrequency__c = 'Monthly',
                                                       SBQQ__BillingType__c = 'Advance',
                                                       //blng__BillingRule__c = billingrule.Id,
                                                       SBQQ__DefaultSubscriptionTerm__c = 24,
                                                       EndDate = Date.today().addMonths(24),
                                                       L2I_Feature_ID__c = 'RD-AP4000000',
                                                       SBQQ__Activated__c = false); 
        insert theTestOrderItem;
        System.debug('theTestOrderItem is '+theTestOrderItem);
     
        L2I_SCM_Confirmations__c scmObj = new L2I_SCM_Confirmations__c();
        scmObj.Opportunity__c = opportunityId;
        scmObj.L2I_Salesforce_Opportunity_Identifier__c = opportunityNumber;
        scmObj.L2I_Feature_Part_Numbers__c = 'RD-AP4000000,RD-AP0050000,RD-AP5000002';
        insert scmObj;
        System.debug('scmObj is ' +scmObj);
        test.stopTest();
    }

}