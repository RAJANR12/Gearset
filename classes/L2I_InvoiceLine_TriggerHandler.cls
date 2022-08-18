/**
 *      @author       Sarah Kennedy
 *      @date         02/09/2021
 *      @description  Trigger on the Invoice Line object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                  02/09/2021           Initial scaffold
 */
public without sharing class L2I_InvoiceLine_TriggerHandler extends L2I_TriggerHandler {
    
    private Map<Id, blng__InvoiceLine__c> newInvoiceLineMap;
    private List<blng__InvoiceLine__c> newInvoiceLineList;
    
    private Map<Id, blng__InvoiceLine__c> oldInvoiceLineMap;
    private List<blng__InvoiceLine__c> oldInvoiceLineList;
    
    public L2I_InvoiceLine_TriggerHandler() {
        this.newInvoiceLineMap = (Map<Id, blng__InvoiceLine__c>) Trigger.newMap;
        this.newInvoiceLineList = (List<blng__InvoiceLine__c>) Trigger.new;
        
        this.oldInvoiceLineMap = (Map<Id, blng__InvoiceLine__c>) Trigger.oldMap;
        this.oldInvoiceLineList = (List<blng__InvoiceLine__c>) Trigger.old;
    }
    
    public override void afterInsert() {
        // valid trigger context vars:
        //     newInvoiceLineList  (not modifiable)
        //     newInvoiceLineMap
        System.debug('====== executing L2I_InvoiceLine_TriggerHander::afterInsert()');
        L2I_InvoiceLine_TriggerFunctions.updateInvoiceFromCase(newInvoiceLineList);
    }
}