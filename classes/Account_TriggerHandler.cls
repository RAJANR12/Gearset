/**
 * @Description        : Handler for Account_Trigger
 * @Author             : Jan Denrick Geronga / Managed Services Simplus
 * @Modification Log   :
 * Ver          Date          Author              Modification
 * W-003956     Oct-18-2021   MS Simplus Jan      Initial Version
 **/

public without sharing class Account_TriggerHandler extends L2I_TriggerHandler {
    private List<Account> newAccountList;
    private Map<Id, Account> oldAccountMap;

    public Account_TriggerHandler() {
        this.newAccountList = (List<Account>) Trigger.new;
        this.oldAccountMap = (Map<Id, Account>) Trigger.oldMap;
    }
    
    public override void afterUpdate() {
        Account_TriggerFunctions.updateQuoteShipToBillTo(newAccountList,oldAccountMap);
    }
}