/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-10-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-10-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
 * Adding the trigger for Azure Guest User for Community Users after convertion to Contact.
**/
trigger CommunitiesUserTrigger on User (before insert) {
if (trigger.isAfter && trigger.isInsert){
    CommunitiesUserTriggerHandler.updateAzureUserInfo(trigger.new);
    }
}