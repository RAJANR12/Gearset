global with sharing class L2I_TotalProductUsages {
    
    @InvocableMethod(label='Order Product Usage Totals'
        description='Calculates Quantity Sum of Usages for a given day span')

    public static List<Results> TotalProductUsages (List<Requests> requests)
       {
            //Calculate date to limit Query
            Integer daySpan = (requests == null) || (requests[0].queryDaySpan == null) ? 3 : requests[0].queryDaySpan;
            Date queryStartDate = System.today() - daySpan;
           
            List<AggregateResult> productUsageTotals = [
                            SELECT blng__Order__c, blng__OrderProduct__c
                                , sum(blng__Quantity__c) totalUsage
                            FROM blng__Usage__c
                            WHERE blng__Status__c = 'Processed'
                            AND blng__OrderProduct__r.L2I_Sub_Category_2__c = 'WiFi' 
                            AND IsDeleted = FALSE
                            GROUP BY blng__Order__c, blng__OrderProduct__c
                            HAVING max(CreatedDate)   >= :queryStartDate
                            OR max(LastModifiedDate)  >= :queryStartDate
                            ];
           List<OrderItem> orderProducts = [SELECT Id, L2I_Total_Usage__c, L2I_Product_Code__c FROM OrderItem LIMIT 0];
           Set<Id> myIds = new Set<Id>();

           if(productUsageTotals != null && productUsageTotals.size() > 0) {
               for(AggregateResult productTotal : productUsageTotals) {
                   OrderItem thisProduct = new OrderItem();
                   thisProduct.Id = (Id) productTotal.get('blng__OrderProduct__c');
                   thisProduct.L2I_Total_Usage__c = (Double) productTotal.get('totalUsage');
                   orderProducts.add(thisProduct);
				   myIds.add((Id) productTotal.get('blng__Order__c')); // Adds multiple OrderIds...
               }
           }
           
           // When we are happy and ready to make things happen...
           update orderProducts;
           
           List<OrderItem> retOrderProducts = [
               SELECT Id, OrderId
               	, L2I_Product_Code__c, L2I_Total_Usage__c, L2I_IncludedUsage__c
               	, L2I_Next_Threshold_Percentage__c, L2I_Threshold_Step__c
               	, blng__InvoiceRunProcessingStatus__c
               FROM OrderItem
               WHERE L2I_Sub_Category_2__c = 'WiFi'
               	  AND  (SBQQ__ChargeType__c = 'Usage' OR L2I_Product_Code__c = 'PA-CPSTPFL-YYYY')
               	  AND  OrderId IN :myIds
               ORDER BY OrderId
           ];

           List<Results> resultsList = new List<results>();
           Results thisResult = new Results();
           thisResult.totaledOrderProducts = retOrderProducts;
           resultsList.add(thisResult);

           return resultsList;
       }
    
    global class Requests {
        @InvocableVariable
    	global Integer queryDaySpan; 
    }
    
    global class Results {
        @InvocableVariable
    	global List<OrderItem> totaledOrderProducts;

    }    
    
}