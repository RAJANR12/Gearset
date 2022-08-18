@IsTest
private class PT_Attachment_TriggerFunctions_Test {
    @IsTest
    static void testAttachment() {
        L2I_DataFactory factory = new L2I_DataFactory();
        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        System.assert(namedCustomer.Id != null, 'Named Customer Account must have an Id');
        
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        System.assert(dealOppty.Id != null, 'Deal Opportunity must have an Id');
        
        Opportunity salesOppty = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, namedCustomer.Id,
              dealOppty.Id, 200000, 'DSS');
        insert salesOppty;
        
        Attachment attach = new Attachment();
        attach.Name = 'CPL Unit Test Attachment Anon';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = salesOppty.id;
        Test.startTest();
        insert attach;
        Test.stopTest();
        List<Attachment> attachments = [select id, name from Attachment where parent.id = :salesOppty.id];
        System.assertEquals(0, attachments.size(), 'Attachment is inserted above but then deleted at the end of Attachment trigger functions');
        
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :salesOppty.id]);
    }
}