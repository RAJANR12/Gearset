/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-12-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-06-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class CommunitiesAzureUserController{
    @AuraEnabled
	public static String getUserInfo(String emailAddress) {
        // Gather mule endpoint infomration by email address
        ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel 
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'AzureUser'
		                                          LIMIT 1];
		String returnuserEmailAddress = null;
        try{
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(integrationMdtObj.URL__c + 'getUserByEmailAddress/' + emailAddress);
			request.setMethod('GET');
			// Below Client ID and Secret are being disabled this time. Will add it later May 20121
			//request.setHeader('client_id', integrationMdtObj.Client_Id__c);
			//request.setHeader('client_secret', integrationMdtObj.Client_Secret__c);
			request.setHeader('Accept', '*/*');
			request.setHeader('Connection', 'keep-alive');
			request.setHeader('Content-Type', 'application/json');
			request.setTimeout(120000);
			HttpResponse response = http.send(request);
			System.debug('getBody ==== ' + response.getBody());
			String userdata = (String) response.getBody();
			// replace Azure data Context node
			userdata = userdata.replace('@odata.context','respHeader');
			userdata = userdata.replace('"value"','"respValue"');
			System.debug('getBodyString ==== ' + userdata);
			if (response != null && response.getStatusCode() == 200){
				azureUserObj azureuserObj = (azureUserObj) JSON.deserialize(userdata, azureUserObj.class);
				returnuserEmailAddress = azureuserObj.respValue[0].mail; // Get the user email address
			} else{
				System.debug('response.getStatus()---------' + response.getStatus());
				Ife_ErrorLog.createErrorLog('CommunitiesAzureUserController', response.getStatus());
			}

		} catch (Exception e){
			System.debug('e---------' + e.getMessage());
			Ife_ErrorLog.createErrorLog('CommunitiesAzureUserController', e.getMessage());
		}
		return returnuserEmailAddress;
    }

    @AuraEnabled
	public static String createAzureInvitation(String userDisplayName, String userEmailAddress)
	{
		ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel 
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'AzureUser'
		                                          LIMIT 1];
		SfUserInfo sfUserInfo = new SfuserInfo();
		sfUserInfo.invitedUserDisplayName = userDisplayName;
		sfUserInfo.invitedUserEmailAddress = userEmailAddress;
		sfUserInfo.inviteRedirectUrl = getCommunityInvitationURL();
		sfUserInfo.SendInvitationMessage = 'true';
		HttpResponse response = new HttpResponse();
		String returnuserEmailAddress = null;
		try {

			Http http = new Http();
			HttpRequest request = new HttpRequest();
			//request.setHeader('client_id', integrationMdtObj.Client_Id__c);
			//request.setHeader('client_secret', integrationMdtObj.Client_Secret__c);
			request.setHeader('Content-Type', 'application/json');
			request.setEndpoint(integrationMdtObj.URL__c + 'createInvitation');
			request.setMethod('POST');
			String reqBody = JSON.serialize(sfUserInfo);
			request.setBody(reqBody);
			response = http.send(request);
			azureUserInfo azureusr = new azureUserInfo();
			if (response != null && response.getStatusCode() == 200) {
				azureusr = (azureUserInfo) JSON.deserialize(response.getBody(), azureUserInfo.class);
				system.debug(azureusr.invitedUserEmailAddress);
				returnuserEmailAddress = azureusr.invitedUserEmailAddress;
			}
			else {
				System.debug('response.getstatus() -------' + response.getStatus());
			}
		} 
		catch (Exception e) {
			System.debug('e---------' + e.getMessage());
		}
		return returnuserEmailAddress;
	}

	// get the Community Invitation URL
	private static String getCommunityInvitationURL()
	{
		String invitationUrl = null;
		Domain communityDomain =[SELECT Domain, DomainType FROM Domain WHERE DomainType ='DNS' LIMIT 1];
		Network communityNetwork =[SELECT Name, UrlPathPrefix FROM Network WHERE Name ='Customer Portal' LIMIT 1];
		return 'https://' + communityDomain.Domain + '/' + communityNetwork.UrlPathPrefix + '/';
	}

	// Sending Azure User Invitation to Azure as guest user
	public class SFUserInfo {
		public String invitedUserDisplayName;
		public String invitedUserEmailAddress;
		public String inviteRedirectUrl;
		public String SendInvitationMessage;
	}

	// Azure User Information AFTER creating the invitation to Azure and returned data fields
	public class azureUserInfo {
		public string invitation_id {get; set;}
		public string inviteRedeemUrl {get; set;}
		public string invitedUserDisplayName {get; set;}
		public string invitedUserType {get; set;}
		public string invitedUserEmailAddress {get; set;}
		public string sendInvitationMessage {get; set;}
		public string inviteRedirectUrl {get; set;}
		public string status {get; set;}
		public InvitedUser invitedUser {get; set;}
	}
	public class InvitedUser{
        public String id {get;set;}
    }

	// Azure User Information
	public class azureUserObj{
		public string respHeader {get;set;}
		public List<respValue> respvalue {get;set;}
	}

	public class respValue{
		public List<string> businessPhones {get; set;}
		public string displayName {get; set;}
		public string givenName {get; set;}
		public string jobTitle {get; set;}
		public string mail {get; set;}
		public string mobilePhone {get; set;}
		public string officeLocation {get; set;}
		public string preferredLanguage {get; set;}
		public string surname {get; set;}
		public string userPrincipalName {get; set;}
		public string id {get; set;}
	}

}