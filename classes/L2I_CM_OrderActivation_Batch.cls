/**
 *      @author       Andy Fang
 *      @date         03/17/2020
 *      @description  L2I_Order_Activation_Batch
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                    03/18/2020         Initial scaffold
 */

global class L2I_CM_OrderActivation_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    private List<Id> quoteIds;
    //private Savepoint sp;
    //private List<Id> aircraftIds;
    public Exception[] errors = new Exception[0];
    public String updateErrors = '';
    
    public L2I_CM_OrderActivation_Batch(List<Id> quoteIdParam) {
        quoteIds = quoteIdParam;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
              'SELECT Id, SBQQ__Ordered__c FROM SBQQ__Quote__c WHERE Id IN: quoteIds AND SBQQ__Ordered__c != true'
        );
    
    }
    
    @InvocableMethod(label='Order Activation')
    global static void executeBatchMethod(List<Id> quoteIdParam) {
        
        Database.executeBatch(new L2I_CM_OrderActivation_Batch(quoteIdParam), 10);
    
    }
    
    global void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> scope) {
        //This should be only one quote per activation
        //sp = Database.setSavepoint();
        //The following code is to create an error during email notification
        //Map<String, Case> a = new Map<String, case>();
        //system.debug(' hello' + a.get('hi').Id);
        try {
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            Set<Id> orderedQuotes = new Set<Id>(); // Added By Arun - 01.19.21
            
            for (SBQQ__Quote__c quote : scope) {
                quote.SBQQ__Ordered__c = true;
                quoteList.add(quote);
            }
            Database.SaveResult[] asaList = Database.update(quoteList, false);
            for (Database.SaveResult sr : asaList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully ordered the Quote. Quote ID: ' + sr.getId());
                    orderedQuotes.add(sr.getId()); // Added By Arun - 01.19.21
                } else {
                    // Operation failed, so get all errors
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        updateErrors += updateErrors + 'The following error has occurred.' + err.getStatusCode() + ': ' + err.getMessage();
                    }
                }
            }
    
            // Added by Arun - 01.19.21 - to create a DSS PO Case once the order is created.
            if (!orderedQuotes.isEmpty()) {
                List<Order> orders = new List<Order>([Select Id, Name, PT_Case__c, AccountId, (Select Id, L2I_Case__c From OrderItems) From Order Where SBQQ__Quote__c IN :orderedQuotes AND Opportunity.L2I_Product_Category__c = 'DSS']);
                if (orders.isEmpty()) {
                    return;
                } // Return if orders are not found with the required criteria
                Id caseDSSRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('DSS PO Case 1').getRecordTypeId();
                Group customP0Queue = [SELECT Id, Name FROM Group Where Type = 'Queue' And DeveloperName = 'PTCustomer_PO_Case' LIMIT 1];
                // create cases
                Map<Id, Case> cases = new Map<Id, Case>();
                for (Order order : orders) {
                    cases.put(order.Id, new Case(RecordTypeId = caseDSSRecType, PO_Case_Type__c = 'DSS', AccountId = order.AccountId, Ownerid = customP0Queue.Id, L2I_Order__c = order.Id));
                }
                // insert cases
                asaList = Database.insert(cases.values(), false);
        
                Set<Id> caseIds = new Set<Id>();
                List<OrderItem> items = new List<OrderItem>();
                for (Database.SaveResult sr : asaList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted the Case. Case ID: ' + sr.getId());
                        caseIds.add(sr.getId());
                    } else {
                        System.debug(sr.getErrors());
                    }
                }
                if (!caseIds.isEmpty() && caseIds.size() > 0) {
                    for (Case cse : [SELECT Id, L2I_Order__c FROM Case WHERE Id IN :caseIds]) {
                        // update orders and orderItems
                        for (Order order : orders) {
                            if (cse.L2I_Order__c == order.Id) {
                                order.PT_Case__c = cse.Id;
                                for (OrderItem item : order.OrderItems) {
                                    item.L2I_Case__c = cse.Id;
                                    items.add(item);
                                }
                            }
                        }
                    }
                    // update orders and orderItems
                    Database.update(orders, false);
                    Database.update(items, false);
                }
            }
        } catch (Exception ex) {
            System.debug('*** execute ex.getMessage() ' + ex.getMessage());
            errors.add(ex);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('*** finish L2I_CM_OrderActivation_Batch');
        try {
            if (!errors.isEmpty() ||
                  !String.isBlank(updateErrors)) {
                if (!errors.isEmpty()) {
                    L2I_UtilityHelper.sendEmail('Errors occurred during Create Order process - Order Creation', 'The batch Apex job processed with the following error ' + errors[0].getMessage(), UserInfo.getUserId());
                } else {
                    L2I_UtilityHelper.sendEmail('Errors occurred during Create Order process - Order Creation', 'The batch Apex job processed with the following error ' + updateErrors, UserInfo.getUserId());
                }
            } else {
                // schedule batch to run
                // needs delay so created orders can complete
                Datetime now = System.now();
                Integer minsOffset = 1;
                String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
                String guid = L2I_UtilityHelper.generateGuid();
                L2I_CaseMgmtFromCROrderSched sched = new L2I_CaseMgmtFromCROrderSched(guid, quoteIds);
                String jobId = System.schedule('CaseMgmtFromCROrder ' + guid, cronTab, sched);
                System.debug('CaseMgmtFromCROrder' + guid + ' has been scheduled as :' + jobId);
            }
        } catch (Exception ex) {
            //Database.rollback(sp);
            system.debug('*** finish ex.getMessage() ' + ex.getMessage());
            L2I_UtilityHelper.sendEmail('Errors occurred during Create Order process - Case Creation', 'The batch Apex job processed with the following error ' + ex.getMessage(), UserInfo.getUserId());
        }
    }
}