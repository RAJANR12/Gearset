public class Ife_AccountDropDownController{
	public Ife_AccountDropDownController(){
	}

	@AuraEnabled(cacheable = true)
	public static List<Account> getAccounts(List<String> accountRelationshipType){

		System.debug('accountRelationshipType----contains' + accountRelationshipType);
		User userObj = [SELECT Id, Name, Contact.AccountId, Contact.Account.L2I_Customer_ID__c
		                FROM User
		                WHERE Id = :UserInfo.getUserId()];
		if (userObj.Contact.AccountId != null){
			System.debug('userObj.Contact.AccountId----' + userObj.Contact.AccountId);
			return getRelatedAccounts(userObj.Contact.AccountId, accountRelationshipType);
		} else{
			return getRelatedAccounts(null, null);
		}
	}

	@AuraEnabled(cacheable = true)
	public static List<Account> getRelatedAccounts(String accountId, List<String> accountRelationshipType){
		Set<String> accountIds = new Set<String>();
		if (String.isNotBlank(accountId)){
			accountIds.add(accountId);
			for (L2I_Related_Account__c relatedAccount : [SELECT Id, Related_To__c, Relationship_Type__c
			                                              FROM L2I_Related_Account__c
			                                              WHERE Account__c = :accountId]){
				if (!accountRelationshipType.isEmpty()){
					if (accountRelationshipType.contains(relatedAccount.Relationship_Type__c)){
						accountIds.add(relatedAccount.Related_To__c);
					}
                }
                else{
                    accountIds.add(relatedAccount.Related_To__c);
                }
			}
		}
		System.debug('accountIds ----' + accountIds);
		if (!accountIds.isEmpty()){
			List<Account> accounts = [SELECT Id, Name, L2I_Customer_ID__c
			                          FROM Account
			                          WHERE Id = :accountIds AND L2I_Customer_ID__c != null];
			System.debug('accounts 1----' + accounts);

			return accounts;
		} else{
			List<Account> accounts = [SELECT Id, Name, L2I_Customer_ID__c
			                          FROM Account
			                          WHERE L2I_Customer_ID__c != null];
			System.debug('accounts 2----' + accounts);

			return accounts;

		}
	}
}