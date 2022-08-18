public with sharing class L2I_OrderUsageData {

    public Id      orderId {public get; private set;}
    public Id      orderItemId {public get; private set;}
    public Id      usageSummaryId {public get; private set;}
    public Date    summaryStartDate {public get; private set;}
    public Date    summaryEndDate {public get; private set;} 
    public String  matchingId {public get; private set;}
    public Boolean hasRateSchedule {public get; private set;}
    public String  modelType {public get; private set;}
    public String  productCode {public get; private set;}
    public Decimal includedUsagePerTail {public get; private set;}
    public Double  unitPrice {public get; private set;}
    public Double  subTotal {public get; private set;}
    public Double  quantity {public get; private set;}
    public Double  actualQuantity {public get; private set;}
    public Double  flightCount {public get; private set;}
    public Double  bandwidthMultiplier {public get; private set;}
    public Double  minGBPerTail {public get; private set;}
    public String  mapKey {public get; private set;}

    private L2I_OrderUsageData(AggregateResult ar) {
        orderId		        	= (Id) ar.get('blng__Order__c');
        orderItemId	        	= (Id) ar.get('blng__OrderProduct__c');
        usageSummaryId      	= (Id) ar.get('blng__UsageSummary__c');
        summaryStartDate    	= (Date) ar.get('blng__SummaryStartDate__c');
        summaryEndDate      	= (Date) ar.get('blng__SummaryEndDate__c');
        matchingId	        	= (String) ar.get('blng__MatchingId__c');
        hasRateSchedule     	= (Boolean) ar.get('L2I_Has_Rate_Schedule__c');
        modelType               = (String) ar.get('L2I_Model_Type__c') == null ? '' : (String) ar.get('L2I_Model_Type__c');
        productCode	    	    = (String) ar.get('productCode');
        includedUsagePerTail	= (Double) (ar.get('includedUsage'));
        unitPrice		    	= (Double) ar.get('unitPrice');
        subTotal		    	= (Double) ar.get('subTotal');
        quantity			    = (Double) ar.get('totalQuantity');
        // 'actualQuantity' should never be null for plane count products.
        //TODO FIXME Remove the entire order and log an error
        actualQuantity       	= (Double) ar.get('totalActualQuantity') == null ? quantity : (Double) ar.get('totalActualQuantity');
        flightCount             = (Double) ar.get('totalActiveFlightCount') == null ? 0 : (Double) ar.get('totalActiveFlightCount');
        bandwidthMultiplier 	= Double.valueOf(ar.get('L2I_Megabyte_Definition__c'));
        minGBPerTail         	= Double.valueOf(ar.get('L2I_Minimum_GB_Per_Tail__c'));
        mapKey                  = mapKey();
    }

    public static L2I_OrderUsageData parse(AggregateResult ar) {
        System.debug('L2I_OrderUsageData:parse: Record: '+ar);

        if (ar.get('blng__MatchingId__c') == null
            || ar.get('blng__UsageSummary__c') == null
            || ar.get('productCode') == null
            || ar.get('subTotal') == null
            || ar.get('unitPrice') == null
        )  {
            System.debug(logginglevel.ERROR,'L2I_OrderUsageData.parse: Null data '+ar);
            return null;
        }

        return new L2I_OrderUsageData(ar);
    }

    public String mapKey() {
        if (this.orderId == null || this.summaryEndDate == null) {
            System.debug('L2I_OrderData.UsageData.mapKey: BAD DATA');
            return null;
        }
        return (String) this.orderId + this.summaryEndDate.format();
    }
}