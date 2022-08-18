@isTest
private class Ife_LeadTriggerHandlerTest {

    @isTest
    public static void afterInsertTest(){
        List<Lead> leadList = new List<Lead>();
        Lead ld = new Lead();
        ld.firstname = 'firstname';
        ld.lastName = 'lastName';
        ld.Company = 'company';
        ld.Email = 'test@gmail.com';
        ld.LeadSource = 'Communities';
        ld.Policy_Agreement__c = true;
        ld.recordtypeid = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('External Customer').getRecordTypeId();
        insert ld;
        leadList.add(ld);
        
        Ife_LeadTriggerHandler.afterInsert(leadList);
    }
}