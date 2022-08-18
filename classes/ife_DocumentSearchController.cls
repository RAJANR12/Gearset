public class ife_DocumentSearchController{
	public ife_DocumentSearchController(){
	}

	@AuraEnabled
	public static List<String> getDocumentTypeValue(){
		String objectName = 'IFE_Document__c';
		String fieldName = 'Tech_Pub_Document_Type__c';
		List<String> pickValues = new List<String>();
		Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
		Schema.DescribeSObjectResult r = s.getDescribe();
		Map<String, Schema.SObjectField> fields = r.fields.getMap();
		Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry pickListVal : ple){
			System.debug(pickListVal.getLabel()+' ' + pickListVal.getValue());
			pickValues.add(pickListVal.getValue());
		}
		return pickValues;
	}
    @AuraEnabled
	public static List<IFE_Document__c> getDocumentSearchResult(String partNumber, String partDescription, String documentNumber, String techPubDocumentType, String dateTo, String dateFrom){
        //Set<String> documentIdsLoginUser = getLoginUserDocuments();
        Set<String> documentPartNumbers = new Set<String>();
        Set<String> documentIds = new Set<String>();
        Set<String> resultDocuments = new Set<String>();
        
        User userObj = [SELECT Id, Name, Contact.AccountId, Contact.Account.L2I_Customer_ID__c
		                FROM User
						WHERE Id = :UserInfo.getUserId()];
		
		Set<String> documentIdsLoginUser = getLoginUserDocuments(userObj);
        
        String customerId='';
		if (userObj.Contact.AccountId != null){
			System.debug('userObj.Contact.AccountId--- ' + userObj.Contact.AccountId);

			customerId = userObj.Contact.Account.L2I_Customer_ID__c;

		}
       
        List<String> overrideParts = new List<String>();
         for (IFE_Part_Overide__c part :[SELECT Account__c, Override__c, IFE_Part__r.name, Name, Id
		                                 FROM IFE_Part_Overide__c
		                                 WHERE Override__c = 'Add' AND Account__c = :userObj.Contact.AccountId ]){
			overrideParts.add(part.IFE_Part__r.name);
		}
        List<String> partNumsToQuery = new List<String>();
         //partNumPresentInOverride
        If(String.isNotBlank(partNumber) && overrideParts.contains(partNumber)){
             for(IFE_Part_Document__c partDocument : [SELECT Id, IFE_Document__c, IFE_Part__c, Name, IFE_Part__r.Name
		                                          FROM IFE_Part_Document__c
		                                          WHERE IFE_Part__r.Name = :partNumber ]){
					documentPartNumbers.add(partDocument.IFE_Part__r.Name);
            		resultDocuments.add(partDocument.IFE_Document__c);    
                    documentIds.add(partDocument.IFE_Document__c);
		 	}
        }
        //partNumPresentButNotInOverride            
        for (IFE_Part_Document__c partDocument : [SELECT Id, IFE_Document__c, IFE_Part__c, Name
		                                          FROM IFE_Part_Document__c
		                                          WHERE IFE_Part__r.Name = :partNumber AND IFE_Document__c = :documentIdsLoginUser]){
			resultDocuments.add(partDocument.IFE_Document__c);
            documentIds.add(partDocument.IFE_Document__c);
		 }
        //getAllPartDocumentsRelatedToOverride
        for (IFE_Part_Document__c partDocument : [SELECT Id, IFE_Document__c, IFE_Part__c, Name
		                                          FROM IFE_Part_Document__c
		                                          WHERE IFE_Part__r.Name = :overrideParts]){
			//resultDocuments.add(partDocument.IFE_Document__c);
            documentIds.add(partDocument.IFE_Document__c);
		 }
        //alldocumemtIdsfromOverride
        //searchBasedOnOtherCriteria
        documentIdsLoginUser.addAll(documentIds);
        List<IFE_Document__c> matchingDocuments = getMatchingDocuments(partNumber, partDescription, documentNumber, techPubDocumentType, dateTo, dateFrom, documentIdsLoginUser, resultDocuments);    
                                                               
        return matchingDocuments;                                                
    }
    
	public static List<IFE_Document__c> getMatchingDocuments(String partNumber, String partDescription, String documentNumber, String techPubDocumentType, String dateTo, String dateFrom,  Set<String> documentIdsLoginUser, Set<String> resultDocuments){
		//Set<String> documentIdsLoginUser = getLoginUserDocuments();
		
		System.debug('techPubDocumentType--- ' + techPubDocumentType);
		String DOCUMENT_TYPE = 'Technical Publication';
		String whereClause = 'Document_Type__c =: DOCUMENT_TYPE';	
	    Boolean additionalFilter = false;

			if (String.isNotBlank(partDescription)){
				whereClause += '  AND Description__c =: partDescription';
                 additionalFilter = true;
			}
			if (String.isNotBlank(documentNumber)){
				whereClause += '  AND Document_Number__c =: documentNumber';
                additionalFilter = true;
			}
			if (String.isNotBlank(techPubDocumentType)){
				whereClause += ' AND Tech_Pub_Document_Type__c =: techPubDocumentType';
                 additionalFilter = true;
			}
			if (String.isNotBlank(dateTo) && String.isNotBlank(dateFrom)){
				Date fromDate = date.valueOf(dateFrom);
				Date toDate = date.valueOf(dateTo);
				whereClause += '  AND Document_Modified_Date__c >=:fromDate  AND Document_Modified_Date__c <=: toDate ';
                additionalFilter = true;
			}
            if (documentIdsLoginUser != null && documentIdsLoginUser.size() > 0 && additionalFilter){
				whereClause += ' AND Id =: documentIdsLoginUser';
			}
        	else{
            	whereClause += ' AND Id =: resultDocuments';
        	}
			System.debug('whereClause--- ' + whereClause);
			String stringQuery = 'SELECT Id,File_Name__c,Folder_Version__c,Folder_Number__c, Part_Number__c,Revision__c,CreatedDate, Part_Description__c, Document_Type__c, Document_Number__c, Description__c FROM IFE_Document__c  WHERE ' + whereClause + ' ORDER BY CreatedDate  DESC';
			System.debug('stringQuery--- ' + stringQuery);
			List<IFE_Document__c> documents = Database.query(stringQuery);
			System.debug('documents--- ' + documents);
			return documents;
	}

	public static Set<String> getLoginUserDocuments(User userObj){
		Set<String> documentIds = new Set<String>();
	
		if (userObj.Contact.AccountId != null){
			System.debug('userObj.Contact.AccountId--- ' + userObj.Contact.AccountId);

			documentIds = getDocuments(new Set<String>{userObj.Contact.AccountId});

		}
		System.debug('documentIds--- ' + documentIds);
		return documentIds;
	}

	public static Set<String> getDocuments(Set<String> accountIds){
		Set<String> documentIds = new Set<String>();
		for (IFE_Document_Account__c docAccount : [SELECT Id, Account__c, IFE_Document__c
		                                           FROM IFE_Document_Account__c
		                                           WHERE Account__c = :accountIds]){
			System.debug('**docAccount-----' + docAccount);
			documentIds.add(docAccount.IFE_Document__c);
		}
		for (IFE_Document__c techPubDocs : [SELECT Id
												   FROM IFE_Document__c
												   WHERE All_Customers__c = true]){
			
			documentIds.add(techPubDocs.Id);
		}
		System.debug('**documentIds-----' + documentIds);
		return documentIds;
	}

	
}