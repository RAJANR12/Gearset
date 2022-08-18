global with sharing class L2I_ProcessTailCountBasedOrders {
    public L2I_ProcessTailCountBasedOrders() {

    }

    public static List<Order> getAffectedOrders(String batchName, String batchNamePosted) {
        List<Order> orders = new List<Order>();
        Set<Id> oids = L2I_OrderData.getAffectedOrderIds();
        for (Order o: [SELECT Id, L2I_Blanket_PO_Available__c FROM Order WHERE Id in :oids]) {
            if (o.L2I_Blanket_PO_Available__c == null || o.L2I_Blanket_PO_Available__c == false)
                orders.add(new Order(Id = o.Id, blng__InvoiceBatch__c = batchName));
            else
                orders.add(new Order(Id = o.Id, blng__InvoiceBatch__c = batchNamePosted));
        }
        return orders;
    }
        
    @InvocableMethod(label='Process Tail Count Products'
        description='Custom Billing Models, leverages usage field L2I_Actual_Quantity__c')
    public static List<Results> ProcessTailCountBasedOrders (List<Requests> requests)
    {
        Date targetDate = (requests == null) || (requests[0].targetDate == null) ? null : requests[0].targetDate;
        String batchName = (requests == null) || (requests[0].invoiceBatch == null) ?  null : requests[0].invoiceBatch;
        String batchNamePosted = (requests == null) || (requests[0].invoiceBatchPosted == null) ?  null : requests[0].invoiceBatchPosted;
        L2I_PrecisionTailCountUtils myObj = new L2I_PrecisionTailCountUtils(targetDate,batchName);
        myObj.execute();

        Results thisResult = new Results();
        thisResult.totaledProductUsageSummaries = L2I_OrderData.usageSummaries;
        thisResult.trueUpUsages = L2I_OrderData.trueUpUsages;
        thisResult.affectedOrders = getAffectedOrders(batchName, batchNamePosted);
        thisResult.errorMessages = new List<String>();
 //       thisResult.errorMessages = L2I_PrecisionTailCountUtils.getErrorMessages();
        List<Results> linkageVar = new List<Results> {thisResult};
        return linkageVar;
    }


    global class Requests {
        @InvocableVariable
        global Date targetDate;

        @InvocableVariable
        global String invoiceBatch;

        @InvocableVariable
        global String invoiceBatchPosted;
    }
    
    global class Results {
        @InvocableVariable
    	global List<blng__UsageSummary__c> totaledProductUsageSummaries;

        @InvocableVariable
        global List<blng__Usage__c> trueUpUsages;

        @InvocableVariable
        global List<Order> affectedOrders;

        @InvocableVariable
        global List<String> errorMessages;
    }    
  
}