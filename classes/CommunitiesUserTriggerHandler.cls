/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-12-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-11-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class CommunitiesUserTriggerHandler {
    public static void updateAzureUserInfo(List<User> newUsers){
		Set<String> userIds = new Set<String>();
		for (User userObj : newUsers){
			if (userObj.Email != null){
				userIds.add(userObj.Id);
			}

		}
		List<User> users = new List<User>();
		for (User userObj : [SELECT id, name, L2i_preferred_name__c, email, L2I_FederationId__c, FederationIdentifier
		                     FROM User
		                     WHERE Id IN :userIds]){

			if (userObj.email != null)
			{
				// Verify the user whether the user exists in Azure or not.
				// If exits ... No Invitation to create and Send an email to user to start using Community otherwise call Azure API
                string userEmailAddress = CommunitiesAzureUserController.getUserInfo(userObj.email);
            	if (userEmailAddress == '')
            	{
               		string rtnAzureUserEmail = CommunitiesAzureUserController.createAzureInvitation(userObj.L2i_preferred_name__c, userEmailAddress);
				}
				// set the email address from either User Object or from Azure Email return above* to fedration ids in User
				userObj.L2I_FederationId__c = userObj.Email;
				userObj.FederationIdentifier = userObj.Email;
				users.add(userObj);
			}	
		}

		if (!users.isEmpty())
        {
			System.debug('users=====' + users);
			update users;
		}
	}
}