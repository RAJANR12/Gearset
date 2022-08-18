global with sharing class L2I_ConnectivityProductRollUp {
    public L2I_ConnectivityProductRollUp() {

    }

    @InvocableMethod(label='Connectivity Product Usage Totals'
        description='Calculates Order Product Lifetime Usage updated within a given day span')
    public static List<Results> ConnectivityProductRollUp (List<Requests> requests) {
        //Calculate date to limit Query
        Integer recentUsageDays = (requests == null) || (requests[0].recentUsageDays == null) ? 3 : requests[0].recentUsageDays;
        Integer runningPeriodDays = (requests == null) || (requests[0].runningPeriodDays == null) ? 8 : requests[0].runningPeriodDays;
        
        L2I_ConnectivityProductUtils obj = new L2I_ConnectivityProductUtils(recentUsageDays,runningPeriodDays);
        Map<Id, OrderItem> tbOrderItemMap = obj.execute();
        List<blng__BillingTransaction__c> milestoneBillingTransactions = obj.tbBillingTransactions(tbOrderItemMap);

        List<Results> resultsList = new List<results>();
        Results thisResult = new Results();
        // thisResult.totaledOrderProducts = new List<OrderItem>();  // Null for now, remove later
        thisResult.tbOrderItems = tbOrderItemMap.values();
        thisResult.milestoneBillingTransactions = milestoneBillingTransactions;
        resultsList.add(thisResult);

        return resultsList;
    }
    
    global class Requests {
        @InvocableVariable global Integer recentUsageDays; 
        @InvocableVariable global Integer runningPeriodDays; 
    }
    
    global class Results {
        // @InvocableVariable global List<OrderItem> totaledOrderProducts;

        @InvocableVariable global List<OrderItem> tbOrderItems;
        @InvocableVariable global List<blng__BillingTransaction__c> milestoneBillingTransactions;
    }    

}