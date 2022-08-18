global class ife_DocumentSendEmailBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
	public Map<String, List<IFE_Document__c>> mapOfAccountIdAndDocumentalist;
	public List<sObject> start(Database.BatchableContext c){

		mapOfAccountIdAndDocumentalist = getDocument();
		system.debug('mapOfAccountIdAndDocumentalist>>>' + mapOfAccountIdAndDocumentalist);

		List<User> userList = [SELECT Id, Name, Email, ContactId, Contact.AccountId
		                       FROM User
		                       WHERE IFE_Email_Opt_In__c = true];
		System.debug('userList----' + userList);
		return userList;
	}

	global void execute(SchedulableContext ctx){
		Database.executebatch(new ife_DocumentSendEmailBatch());

		Datetime sysTime = System.now();
		sysTime = sysTime.addDays(7);
		String chron_exp = '' + sysTime.second()+' ' + sysTime.minute()+' ' + sysTime.hour()+' ' + sysTime.day()+' ' + sysTime.month()+' ? ' + sysTime.year();
		system.debug('ife_DocumentSendEmailBatch --> ' + chron_exp);
		System.schedule('ife_DocumentSendEmailBatchJob' + System.now(), chron_exp, new ife_DocumentSendEmailBatch());
		Id cronTrigId = ctx.getTriggerId();
		System.abortJob(cronTrigId);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		System.debug('scope=== ' + mapOfAccountIdAndDocumentalist);
		List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();


		for (User userObj : (List<User>)scope){
			
			if (mapOfAccountIdAndDocumentalist.containsKey(userObj.Contact.AccountId)){
				Integer item = 1;
				String htmlBody = '<h1:>Technical Library Document Notification</h1><br/><br/';
				htmlBody += userObj.Name + ', <br/>';
				htmlBody += 'This is a Technical Document Library email from Panasonic Avionics Corporation.<br/>';
				htmlBody += 'The following are document numbers of newly released or revised Technical Publication uploaded to the MyIFE Technical Library on the dates shown.<br/><br/>';

				htmlBody += '<table border="1" style="border-collapse: collapse"><caption></caption><tr><th>Item#</th><th>Document#</th><th>Rev#</th><th>Doc Type</th><th>Date</th></tr>';

				for (IFE_Document__c doc : mapOfAccountIdAndDocumentalist.get(userObj.Contact.AccountId)){
					htmlBody += '<tr><td>' + item++ + '</td><td>' + doc.Document_Number__c + '</td><td>' + doc.Revision__c + '</td><td>' + doc.Document_Type__c + '</td><td>' + doc.Document_Modified_Date__c + '</td></tr>';

				}
				Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();

				objEmail.setToAddresses(new List<String>{userObj.Email});
				htmlBody += '</table>';
				htmlBody += '<br/><br/>If you do not want to receive these email notifcations, please log in to MyIFE at https://myife.panasonic.aero. Access the "My Profile" option, uncheck the box for "Email Opt In" and submit the change.<br/>';
				htmlBody += 'If you have questions about the contents of this notification use the "Technical Publication Support" option on the Support Page.';
				objEmail.setHtmlBody(htmlBody);
				objEmail.setSubject('Technical Library Document Notification');
				lstEmails.add(objEmail);

			}
            if(String.isBlank(userObj.ContactId)){
                getEmailForInternalUser(userObj, mapOfAccountIdAndDocumentalist, lstEmails);
            }
		}
		System.debug('lstEmails====' + lstEmails);
		Messaging.sendEmail(lstEmails);
	}

	global void finish(Database.BatchableContext BC){
	}

	public Map<String, List<IFE_Document__c>> getDocument(){
		Date currDate = Date.today();
		Date dayBefore = currDate.addDays(-7);
		Set<String> documentIds = new Set<String>();
		Map<String, List<IFE_Document__c>> accountaIdWithDocumentObj = new Map<String, List<IFE_Document__c>>();
		/*for (IFE_Document_Account__c docAccount : [SELECT Id, Account__c, IFE_Document__c, IFE_Document__r.Document_Modified_Date__c, IFE_Document__r.Revision__c, IFE_Document__r.Document_Type__c, IFE_Document__r.Document_Number__c
		 FROM IFE_Document_Account__c
		 WHERE IFE_Document__r.Document_Type__c = 'Technical Publication' AND IFE_Document__r.Document_Modified_Date__c <= :currDate AND IFE_Document__r.Document_Modified_Date__c > :dayBefore]){
		 System.debug('docAccount>><<<' + docAccount);

		 if (accountaIdWithDocumentObj.containsKey(docAccount.Account__c)){
		 accountaIdWithDocumentObj.get(docAccount.Account__c).add(docAccount.IFE_Document__r);
		 } else{
		 accountaIdWithDocumentObj.put(docAccount.Account__c, new List<IFE_Document__c>{docAccount.IFE_Document__r});
		 }
		 }*/

		Map<String, IFE_Document__c> idWirhDocument = new Map<String, IFE_Document__c>([SELECT Id, Document_Type__c, Email_Alert__c, Document_Modified_Date__c, Revision__c, Document_Number__c
		                                                                                FROM IFE_Document__c
		                                                                                WHERE Document_Type__c = 'Technical Publication' AND Email_Alert__c = true AND Document_Modified_Date__c <= :currDate AND Document_Modified_Date__c > :dayBefore]);
		
		for (IFE_Document_Account__c docAccount : [SELECT Id, Account__c, IFE_Document__c
		                                           FROM IFE_Document_Account__c
		                                           WHERE IFE_Document__c IN :idWirhDocument.keySet() AND Account__c != null]){
			if (docAccount.Account__c != null && idWirhDocument.containsKey(docAccount.IFE_Document__c)){
				if (accountaIdWithDocumentObj.containsKey(docAccount.Account__c)){
					accountaIdWithDocumentObj.get(docAccount.Account__c).add(idWirhDocument.get(docAccount.IFE_Document__c));
				} else{
					accountaIdWithDocumentObj.put(docAccount.Account__c, new List<IFE_Document__c>{idWirhDocument.get(docAccount.IFE_Document__c)});
				}
			}
		}
		
		Map<String, IFE_Document__c> partIdWithPartDocument = new Map<String, IFE_Document__c>();
		for (IFE_Part_Document__c partDoc : [SELECT Id, IFE_Document__c, IFE_Part__c
		                                     FROM IFE_Part_Document__c
		                                     WHERE IFE_Document__c IN :idWirhDocument.keySet()]){
			partIdWithPartDocument.put(partDoc.IFE_Part__c, idWirhDocument.get(partDoc.IFE_Document__c));
			
		}
		for (IFE_Part_Overide__c partOveridr : [SELECT Id, Account__c, IFE_Part__c, Override__c
		                                        FROM IFE_Part_Overide__c
		                                        WHERE IFE_Part__c IN :partIdWithPartDocument.keySet() AND Override__c = 'Add' AND Account__c != null]){
			
			if (partIdWithPartDocument.containsKey(partOveridr.IFE_Part__c)){
				if (accountaIdWithDocumentObj.containsKey(partOveridr.Account__c)){
					accountaIdWithDocumentObj.get(partOveridr.Account__c).add(partIdWithPartDocument.get(partOveridr.IFE_Part__c));
				} else{
					accountaIdWithDocumentObj.put(partOveridr.Account__c, new List<IFE_Document__c>{partIdWithPartDocument.get(partOveridr.IFE_Part__c)});
				}
			}
		}
		System.debug('accountaIdWithDocumentObj   ====' + accountaIdWithDocumentObj);
		return accountaIdWithDocumentObj;
	}
    
    public void getEmailForInternalUser(User userObj, Map<String, List<IFE_Document__c>>mapOfAccountIdAndDocumentalist, List<Messaging.SingleEmailMessage> lstEmails){
   
			
			if (mapOfAccountIdAndDocumentalist.values().size()>0){
				Integer item = 1;
				String htmlBody = '<h1:>Technical Library Document Notification</h1><br/><br/';
				htmlBody += userObj.Name + ', <br/>';
				htmlBody += 'This is a Technical Document Library email from Panasonic Avionics Corporation.<br/>';
				htmlBody += 'The following are document numbers of newly released or revised Technical Publication uploaded to the MyIFE Technical Library on the dates shown.<br/><br/>';

				htmlBody += '<table border="1" style="border-collapse: collapse"><caption></caption><tr><th>Item#</th><th>Document#</th><th>Rev#</th><th>Doc Type</th><th>Date</th></tr>';
                
                Set<IFE_Document__c> alldocs = new Set<IFE_Document__c>();
                for (Id key : mapOfAccountIdAndDocumentalist.keySet()) {   
                	alldocs.addAll(mapOfAccountIdAndDocumentalist.get(key));
				}

            
				for (IFE_Document__c doc : alldocs){
					htmlBody += '<tr><td>' + item++ + '</td><td>' + doc.Document_Number__c + '</td><td>' + doc.Revision__c + '</td><td>' + doc.Document_Type__c + '</td><td>' + doc.Document_Modified_Date__c + '</td></tr>';
				}
				Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();

				objEmail.setToAddresses(new List<String>{userObj.Email});
				htmlBody += '</table>';
				htmlBody += '<br/><br/>If you do not want to receive these email notifcations, please log in to MyIFE at https://myife.panasonic.aero. Access the "My Profile" option, uncheck the box for "Email Opt In" and submit the change.<br/>';
				htmlBody += 'If you have questions about the contents of this notification use the "Technical Publication Support" option on the Support Page.';
				objEmail.setHtmlBody(htmlBody);
				objEmail.setSubject('Technical Library Document Notification');
				lstEmails.add(objEmail);

			}
    }
    
}