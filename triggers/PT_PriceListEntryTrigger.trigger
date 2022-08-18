/**
 *      @author       Dan Morris
 *      @date         02/16/2021
 *      @description  Trigger on the PT_PriceList_Entry__c object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Dan Morris                02/16/2021          Initial scaffold
 */




trigger PT_PriceListEntryTrigger on PT_PriceList_Entry__c (before insert, before update) {
    // Check if the trigger has to be run by checking if the User(Profile) has the Disable_InstallLoc__c
    // flag turned on in the L2I_Trigger_Settings__c custom setting.
    
        if (L2I_Trigger_Settings__c.getInstance(UserInfo.getUserId()).Disable_PriceListEntry__c) {
            System.debug('***** Bypassed execution of PT_PriceList_Entry__c trigger functions for user ' + UserInfo.getUserName());
            return;
        }
        
        // now handle it
        new PT_PriceListEntryTriggerHandler().run();
    }