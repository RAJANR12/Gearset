trigger L2I_SCMInfoTrigger on L2I_SCM_Confirmations__c (before insert, before update, before delete, after insert, after update, after delete) {
    // Check if the trigger has to be run by checking if the User(Profile) has the Disable_Case__c
    // flag turned on in the L2I_Trigger_Settings__c custom setting.

    /*if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_Case__c) {
        System.debug('***** Bypassed execution of Case trigger functions for user ' + UserInfo.getUserName());
        return;
    }*/
    
    if(Trigger.isInsert && Trigger.isBefore) {
        L2I_SCMInfoTriggerHandler.scmBeforeInsert (Trigger.new);
    }

}