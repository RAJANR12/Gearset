@isTest
public class PT_InvocableEmailAttachmentTest {

    @isTest
    static void sendEmailSendTo() {

        Account acc = new Account();
        acc.Name = 'Test for Email Attachment';
        insert acc;

        Opportunity o = new opportunity();
        o.Name = 'Test for Email Attachment';
        o.StageName = 'Negotiation';
        o.AccountId = acc.Id;
        o.Amount = 2000;
        o.CloseDate = system.Date.today();
        insert o;

        attachment att = new attachment();
        att.Name = 'CPL-Test attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        att.Body = bodyBlob;
        att.ParentId = o.Id;
        insert att;

        string myEmail = 'anytestEmailID@gmail.com';
        string emailBody = 'this is the email body';
        string emailSubject = 'this is subject';
        List<PT_InvocableEmailAttachment.flowInput> inputList = new List<PT_InvocableEmailAttachment.flowInput>();

        PT_InvocableEmailAttachment.flowInput input = new PT_InvocableEmailAttachment.flowInput();
        input.eMail = myEmail;
        input.ccMail = myEmail;
        input.currentRecordId = o.Id;
        input.eSubject = emailSubject;
        input.ebody = emailBody;
        inputList.add(input);

        PT_InvocableEmailAttachment.currentRecordID(inputList);

        integer invocation = limits.getEmailInvocations();

        system.assertEquals(1, invocation);
    }
}