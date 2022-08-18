public without sharing class ife_LeadEmailConfirmationController{
	@AuraEnabled
	public static String updatLead(String leadId){
		try{
			///MS
			Blob key = Blob.valueOf('aAk!h@37WQ9bsAfk');
			string encodedcontactid = leadId;
			Blob blobData = EncodingUtil.base64Decode(EncodingUtil.urlDecode(encodedcontactid,'UTF-8'));    
			Blob decryptedBlob = Crypto.decryptWithManagedIV('AES128', key, blobData);    
			string decodedId = decryptedBlob.toString();
			//MS
			/*Blob exampleIv = Blob.valueOf('Example of IV123');
			Blob key1 = Blob.valueOf('Example of IV123');
			//leadId = EncodingUtil.urlDecode(leadId, 'UTF-8');
			Blob data1 = EncodingUtil.base64Decode(leadId);

			Blob decrypted = Crypto.decrypt('AES128', key1, exampleIv, data1);
			String decryptedLeadId = decrypted.toString();*/
			Lead leadObj = [SELECT Id, IFE_Email_Verified__c
			                FROM Lead
			                WHERE Id = :decodedId];
			if (leadObj.IFE_Email_Verified__c){
				return Label.ife_LeadEmailAlreadyConfirmMessage;

			} else{
				Lead leObje = new Lead(Id = leadObj.Id, IFE_Email_Verified__c = true);
				update leObje;
				return Label.ife_LeadEmailSuccessMessage;
			}
		} catch (Exception e){
			return Label.ife_LeadEmailErrorMessage;
		}
	}
}