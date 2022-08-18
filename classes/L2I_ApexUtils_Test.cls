@isTest
private class L2I_ApexUtils_Test {
    @isTest static void myTest() {
        L2I_ApexUtils c = new L2I_ApexUtils();
        
        L2I_DataFactory factory = new L2I_DataFactory();
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        Test.startTest();
        
        L2I_ApexUtils.runningInASandbox = true;
        L2I_ApexUtils.create18CharFakeId('123');
        L2I_ApexUtils.getEnvironmentName('asd');
        L2I_ApexUtils.parseFieldPathForSObject(dealOppty,'id');
        L2I_ApexUtils.parseFieldPathForSObject(dealOppty,'id.');
        L2I_ApexUtils.readFieldSet('SBQQ__SearchFilters', 'Asset');
        List<Schema.FieldSetMember> fieldSetMemberList = L2I_ApexUtils.readFieldSet('SBQQ__SearchFilters', 'Asset');
		L2I_ApexUtils.getFieldSetFieldAPINames(fieldSetMemberList);
//.List<Schema.FieldSetMember> fieldSetMemberList = 
        Test.stopTest();
    }
}