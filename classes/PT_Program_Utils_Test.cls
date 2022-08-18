/**
 *      @author       Dan Morris
 *      @date         07/20/2020
 *      @description  Test class for Program Table Utilities.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Dan Morris                   07/20/2020         Initial setup of tests
 *
 */

 @isTest(SeeAllData=false)
private  class PT_Program_Utils_Test {
    public PT_Program_Utils_Test() {

    }

    @isTest
    private static void randomPrograms() {
        Integer i = 0;
        List<String> systemTypes = PT_JSON_Settings.SystemTypes();
        Integer n = systemTypes.size();
        Integer skip = 3;
        for (L2I_Aircraft_Type__c a: [SELECT Id,L2I_Aircraft_Type__c FROM L2I_Aircraft_Type__c]) {
            // Randomly drop every <skip> record
            if (math.mod(math.roundToLong(math.random()*skip),skip) != 0) {
                String coreProgramName = PT_Program_Utils.getCoreProgramName(systemTypes[math.mod(i,n)],'DL',a.L2I_Aircraft_Type__c, '001');
                System.debug('Program Name: '+coreProgramName);
                i++;
            }
            if (i>30) break;
        }
    }

    private static PT_Program__c stubProgramRecord(String ProgramName) {
        return new PT_Program__c(
            Name = ProgramName
            , Program_Number__c = ProgramName
        );
    }

    @isTest
    private static void validateProgramNames() {
        // Clean one...
        String coreProgramName = PT_Program_Utils.getCoreProgramName('4','SN','A330-320', '001');
        System.debug('Program Name: '+coreProgramName);
        System.assert(coreProgramName == '4SN001');
        // Next Sequence
        PT_Program__c stubProgram = stubProgramRecord(coreProgramName);
        insert stubProgram;
        coreProgramName =  PT_Program_Utils.getCoreProgramName('4','SN','A330-320', '001');
        System.assert(coreProgramName == '4SN001');
        // Mixed ACType
        coreProgramName =  PT_Program_Utils.getCoreProgramName('4','SN','Mixed', '001');
        System.assert(coreProgramName == '4SNMIX');
        // Base Model ACType
        coreProgramName =  PT_Program_Utils.getCoreProgramName('4','SN','757', '001');
        System.assert(coreProgramName == '4SN001');
    }

    @isTest
    private static void validateRevisionSequencer() {
        // Test is based on the <charIndex> string, change the expected result if the string is changed
        System.assertEquals('B', PT_Program_Utils.revisionCharacter(2));
        System.assertEquals('Q', PT_Program_Utils.revisionCharacter(17));
        System.assertEquals('AA', PT_Program_Utils.revisionCharacter(27));
        System.assertEquals('02', PT_Program_Utils.characterSequencer('001'));   
        System.assertEquals('B1', PT_Program_Utils.characterSequencer('AA'));   
    }
    
    @isTest
    private static void testUdpateProgramAircrafts() {
        L2I_DataFactory factory;
        
        factory = new L2I_DataFactory();
        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');

        L2I_Aircraft_Type__c airType = new L2I_Aircraft_Type__c(Name = '737 MAX 10',
              L2I_Model__c = '737',
              L2I_Master_Series__c = 'G4',
              L2I_Series__c = 'Max 10',
              L2I_Aircraft_Type__c = 'A',
              L2I_PAC_Type_Designator__c = 'A',
              L2I_Program_Code__c = 'abc',
              L2I_Is_Active__c = true);
        insert airType;

        L2I_Aircraft__c ac = new L2I_Aircraft__c(
              L2I_Aircraft_Status__c = 'In Service',
              Name = 'Test A/C 1',
              L2I_GPIN__c = 'A319-1100',
              L2I_Operator__c = acc.Id,
              L2I_Serial_Number__c = 'abc12289',
              L2I_Aircraft_Delivery_Date__c = DATE.today().addDays(30),
              Aircraft_Type__c = airType.Id,
              L2I_Approved__c = true
        );
        insert ac;
        
        Product2 product = factory.createProduct('99999802', 'MediaServices', 'IFEC', 'IFE HW', null);
        product.productCode = 'MCS BUNDLE';
        product.L2I_System_Type_Translation__c = 'A';
        insert product;

        PT_Program__c prog = new PT_Program__c(Name = 'Test1234',Program_Number__c = 'Test1234');
        insert prog;
        
        Id salesTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Handoff', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Product_Category__c = 'IFEC';
        salesOpp.L2I_AC_Operator__c = acc.Id;
        salesOpp.L2I_Aircraft_Type__c = airType.Id;
        salesOpp.Account = acc;
        salesOpp.L2I_Primary_System_Type__c = product.Id;
        salesOpp.RecordTypeId = salesTypeId;
        salesOpp.L2I_Program_Num__c = prog.Id;
        insert salesOpp;
        
        L2I_DSH__c dsh = new L2I_DSH__c();
        insert dsh;
        
        insert new L2I_DSL__c(Original_Opportunity__c = salesOpp.Id, PT_Program__c = prog.Id, Aircraft__c = ac.Id, Delivery_Date__c = Date.today(), Delivery_Schedule_Header__c = dsh.Id);
        Test.startTest();
        PT_Program_Utils.udpateProgramAircrafts(salesOpp.Id, prog.Id);
        Test.stopTest();
        
        system.assertEquals(String.valueOf(ac.Id)+';', [SELECT PT_Program_Aircraft_IDs__c FROM PT_Program__c WHERE Id=: prog.Id].PT_Program_Aircraft_IDs__c);
    }

}