@isTest
private class ife_SendEmailControllerTest {
    
    @isTest
    public static void updatLeadTest(){
        Lead ld = new Lead();
        ld.firstname = 'firstname';
        ld.lastName = 'lastName';
        ld.Company = 'company';
        ld.Email = 'test@gmail.com';
        ld.LeadSource = 'Communities';
        ld.Policy_Agreement__c = true;
        ld.recordtypeid = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('External Customer').getRecordTypeId();
        insert ld;
        
        /*Blob exampleIv = Blob.valueOf('Example of IV123');
        Blob key = Blob.valueOf('Example of IV123');
        Blob data = Blob.valueOf(ld.Id);
        Blob encrypted = Crypto.encrypt('AES128', key, exampleIv, data);
        String encryptedStr = EncodingUtil.base64Encode(encrypted);*/

        Blob key = Blob.valueOf('aAk!h@37WQ9bsAfk');
        string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(ld.Id)));
        string encryptedStr = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
        //leadObj.IFE_Encrypted_Id__c = encryptedStr;
        
       String sentEmailMessage = ife_SendEmailController.updatLead(encryptedStr);
        
       System.assertEquals('Your email has been confirmed.', sentEmailMessage);
    }
}