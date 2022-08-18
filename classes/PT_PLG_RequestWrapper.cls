public class PT_PLG_RequestWrapper {
    public class Request {
        public String accountOperator {get; set;}
        public String aircraftType {get; set;}
        public String fitType {get; set;}
        public date firstDeliveryDate {get; set;}
    }

    public static String getPLGRequestBody(Id quoteId) {
        SBQQ__Quote__c qt = [SELECT Id, SBQQ__Opportunity2__r.L2I_AC_Operator__r.L2I_Operator_Number__c,
                    SBQQ__Opportunity2__r.L2I_Aircraft_Type__r.Name, SBQQ__Opportunity2__r.L2I_Fit_Type__c,
                    SBQQ__Opportunity2__r.L2I_First_Delivery_Date__c FROM SBQQ__Quote__c
                    WHERE Id = :quoteId];
        Request req = new Request();
        req.accountOperator = qt.SBQQ__Opportunity2__r.L2I_AC_Operator__r.L2I_Operator_Number__c;
        req.aircraftType = qt.SBQQ__Opportunity2__r.L2I_Aircraft_Type__r.Name;
        req.fitType = qt.SBQQ__Opportunity2__r.L2I_Fit_Type__c;
        req.firstDeliveryDate = qt.SBQQ__Opportunity2__r.L2I_First_Delivery_Date__c != null ? qt.SBQQ__Opportunity2__r.L2I_First_Delivery_Date__c : Date.today();
        String jsonRequest = 'accountOperator=' + req.accountOperator;
        jsonRequest += '&aircraftType=' + req.aircraftType;
        jsonRequest += '&fitType=' + req.fitType;
        jsonRequest += '&firstDeliveryDate=' + req.firstDeliveryDate;
        return jsonRequest;
    }
}