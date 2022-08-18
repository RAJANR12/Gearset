/**
 *      @author       Dan Morris
 *      @date         02/16/2021
 *      @description  Trigger Handler for PT_PriceList_Entry__c
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Dan Morris               02/16/2021          Initial scaffold
 */

public with sharing class PT_PriceListEntryTriggerHandler extends L2I_TriggerHandler {

    private Map<Id, PT_PriceList_Entry__c> newPriceListEntryMap;
    private List<PT_PriceList_Entry__c> newPriceListEntryList;

    private Map<Id, PT_PriceList_Entry__c> oldPriceListEntryMap;
    private List<PT_PriceList_Entry__c> oldPriceListEntryList;

    public PT_PriceListEntryTriggerHandler() {
        this.newPriceListEntryMap = (Map<Id, PT_PriceList_Entry__c>) Trigger.newMap;
        this.newPriceListEntryList = (List<PT_PriceList_Entry__c>) Trigger.new;

        this.oldPriceListEntryMap = (Map<Id, PT_PriceList_Entry__c>) Trigger.oldMap;
        this.oldPriceListEntryList = (List<PT_PriceList_Entry__c>) Trigger.old;
    }

    // valid trigger context vars:
    //     newPriceListEntryList  (not modifiable)
    //     newPriceListEntryMap
    //     oldPriceListEntryList
    //     oldPriceListEntryMap

    public override void beforeInsert() {
        System.debug('======= executing PT_PriceListEntryTriggerHandler::beforeInsert()');
        PT_PriceListEntryTriggerFunctions.priceRelatedQuoteLines(oldPriceListEntryMap, newPriceListEntryMap);
    }
        

    public override void beforeUpdate() {
        System.debug('======= executing PT_PriceListEntryTriggerHandler::beforeUpdate()');
        PT_PriceListEntryTriggerFunctions.priceRelatedQuoteLines(oldPriceListEntryMap, newPriceListEntryMap);
    }
            

}