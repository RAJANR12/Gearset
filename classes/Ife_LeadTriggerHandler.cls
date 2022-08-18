public class Ife_LeadTriggerHandler{
	public static void afterInsert(List<Lead> newLeads){
		Set<String> leadIds = new Set<String>();
		for (Lead leadObj : newLeads){
			if (leadObj.Email != null){
				leadIds.add(leadObj.Id);
			}

		}
		List<Lead> leads = new List<Lead>();
		for (Lead leadObj : [SELECT Id, IFE_Encrypted_Id__c
		                     FROM Lead
		                     WHERE Id IN :leadIds]){

			/*Blob key = Crypto.generateAesKey(256);

			 Blob source = Blob.valueOf(leadObj.Id);
			 Blob encrypted = Crypto.encryptWithManagedIV('AES256', key, source);
			 String encrypted64 = EncodingUtil.base64Encode(encrypted);
			 System.debug('encrypted64=====' + encrypted64);*/


			/*Blob exampleIv = Blob.valueOf('caseId');
			 Blob key = Crypto.generateAesKey(128);
			 Blob data = Blob.valueOf('Data to be encrypted');
			 Blob encrypted = Crypto.encrypt('AES128', key, exampleIv, data);

			 Blob decrypted = Crypto.decrypt('AES128', key, exampleIv, encrypted);
			 String decryptedString = decrypted.toString();
			 System.assertEquals('Data to be encrypted', decryptedString);*/

//MS - Debugging
			/*Blob exampleIv = Blob.valueOf('Example of IV123');
			Blob key = Blob.valueOf('Example of IV123');
			Blob data = Blob.valueOf(leadObj.Id);
			Blob encrypted = Crypto.encrypt('AES128', key, exampleIv, data);
			String encryptedStr = EncodingUtil.base64Encode(encrypted);*/
            
                                 Blob key = Blob.valueOf('aAk!h@37WQ9bsAfk');
string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(leadObj.Id)));
string encryptedStr = encodingUtil.URLEncode(encodedCipherText,'UTF-8');

                                 //String encryptedStr = EncodingUtil.urlEncode((String)encrypted.toString(),'UTF-8');
            //encryptedStr = EncodingUtil.urlEncode(encryptedStr,'UTF-8');

			leadObj.IFE_Encrypted_Id__c = encryptedStr;
			leads.add(leadObj);

			/*String strKey = 'caseId';
			 Blob key = EncodingUtil.base64Encode;
			 Blob data = Blob.valueOf(leadObj.Id);
			 Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);
			 String encryptedStr = EncodingUtil.base64Encode(encrypted);
			 leadObj.IFE_Encrypted_Id__c = encryptedStr;
			 leads.add(leadObj);*/

		}
		if (!leads.isEmpty()){
			System.debug('leads=====' + leads);
			update leads;
		}
	}
}