public  class ife_SearchDeliveryDetailsController {
    public ife_SearchDeliveryDetailsController() {

    }
    @AuraEnabled(cacheable=true)
    public static List<Account>  getAccounts(){
        User userObj =[SELECT Id ,Name,Contact.AccountId,Contact.Account.L2I_Customer_ID__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(userObj.Contact.AccountId != null){
            System.debug('userObj.Contact.AccountId----'+userObj.Contact.AccountId);
           return getRelatedAccounts(userObj.Contact.AccountId);
        }  
        else{
           return getRelatedAccounts(null);
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> getRelatedAccounts(String accountId){
        Set<String> accountIds = new Set<String>();
        if(String.isNotBlank(accountId)){
            accountIds.add(accountId);
            for(L2I_Related_Account__c  relatedAccount :[SELECT Id, Related_To__c ,Relationship_Type__c
                                        FROM L2I_Related_Account__c 
                                        WHERE Account__c =: accountId])
            {
                accountIds.add(relatedAccount.Related_To__c);
            }
        }
        System.debug('accountIds ----'+accountIds);
        if(!accountIds.isEmpty()){
            List<Account> accounts = [SELECT Id, Name,L2I_Customer_ID__c FROM Account WHERE Id=:accountIds AND L2I_Customer_ID__c != null];
            System.debug('accounts 1----'+accounts);
            accounts.sort();
            return accounts;
        }
        else{
            List<Account> accounts = [SELECT Id, Name,L2I_Customer_ID__c FROM Account WHERE L2I_Customer_ID__c != null];
            System.debug('accounts 2----'+accounts);
            accounts.sort();
            return accounts;

        }
    }
    @AuraEnabled 
    public static  List<myIfeDeliveries__x> getMYIFDeliveryDetails(String deliveryNumber ,String referencePO ,String item ,String shipDate  , String Invoice ,String serial, String selectedAccount){
        System.debug('deliveryNumber--- '+deliveryNumber);
        System.debug('referencePO--- '+referencePO);
        System.debug('item--- '+item);
        System.debug('shipDate--- '+shipDate);
        System.debug('Invoice--- '+Invoice);
        System.debug('serial--- '+serial);
        System.debug('selectedAccount--- '+selectedAccount);
        String whereClause ='';
        if(String.isNotBlank(selectedAccount)){
            if(whereClause != ''){
                whereClause+= ' AND CUSTOMER_ID__c =: selectedAccount';
            }
            else{
                whereClause = ' CUSTOMER_ID__c =: selectedAccount';
            }
        }
        if(String.isNotBlank(deliveryNumber)){
            if(whereClause != ''){
                whereClause+= ' AND DELIVERY_ID__c =: deliveryNumber';
            }
            else{
                whereClause = ' DELIVERY_ID__c =: deliveryNumber';
            }
        }

        if(String.isNotBlank(referencePO)){
            if(whereClause != ''){
                whereClause+= ' AND REF_PO__c =: referencePO';
            }
            else{
                whereClause = ' REF_PO__c =: referencePO';
            }
        }

        if(String.isNotBlank(item)){
            if(whereClause !=''){
                whereClause+= ' AND ITEM_NUMBER__c =: item';
            }
            else{
                whereClause =' ITEM_NUMBER__c =: item';
            }
        }

        if(String.isNotBlank(shipDate)){
            if(whereClause != ''){
                whereClause+= ' AND ACTUAL_SHIP_DATE__c =: shipDate';
            }
            else{
                whereClause = ' ACTUAL_SHIP_DATE__c =: shipDate';
            }
        }

        if(String.isNotBlank(Invoice)){
            if(whereClause !=''){
                whereClause+= ' AND INVOICE_NUMBER__c=: Invoice';
            }
            else{
                whereClause= ' INVOICE_NUMBER__c=: Invoice';
            }
        }

        if(String.isNotBlank(serial)){
            if(whereClause != null ){
                whereClause+= ' AND SERIAL_NUMBER__c=: serial';
            }
            else{
                whereClause= ' SERIAL_NUMBER__c=: serial';
            }
        }
        
        System.debug('whereClause--- '+whereClause);
        String stringQuery ='SELECT Id,CUSTOMER_ID__c, LINE_ID__c, ORDER_HEADER_ID__c, DELIVERY_ID__c,ITEM_NUMBER__c, ORDER_NUMBER__c ,REF_PO__c, SCHEDULE_SHIP_DATE__c,ACTUAL_SHIP_DATE__c,FREIGHT_CARRIER__c,WEIGHT__c,SHIPPED_QUANTITY_UOM__c,STATUS__c,WAYBILL__c,SHIP_TO_LOCATION__c,TRIP_NAME__c,OTM_SHIPMENT_ID__c,INVOICE_NUMBER__c,SERIAL_NUMBER__c FROM myIfeDeliveries__x  WHERE '+   whereClause+ ' LIMIT 2000';
        System.debug('stringQuery--- '+stringQuery);
        List<myIfeDeliveries__x> MYIFEDeliveries = Database.query(stringQuery);
        System.debug('MYIFEDeliveries--- '+MYIFEDeliveries);
       // List<myIfeDeliveries__x> dd=[SELECT Id, DELIVERY_ID__c ,REF_PO__c, ITEM_NUMBER__c, ACTUAL_SHIP_DATE__c, INVOICE_NUMBER__c, SERIAL_NUMBER__c FROM myIfeDeliveries__x  WHERE   CUSTOMER_ID__c = '2318' LIMIT 5];
       // System.debug('dd ==== '+dd);
        return MYIFEDeliveries;

    }
    @AuraEnabled 
    public static  DataWrapper getMYIFdelivery(String lineId ,String headerId){
    System.debug('lineId ----   '+lineId);
    System.debug('headerId ----   '+headerId);
	DataWrapper dataWrapperObj = new DataWrapper();
      /*List<myifedeliverie__c> myifedeliveries =[SELECT Id, Name, STATUS__c, SHIP_TO_LOCATION__c, WAYBILL__c, ORDER_NUMBER__c, ITEM_NUMBER__c, SHIP_FROM__c, ACTUAL_SHIP_DATE__c, SHIPPED_QUANTITY__c, SHIPPED_QUANTITY_UOM__c, LINE_ID__c, ITEM_DESCRIPTION__c, FREIGHT_CARRIER__c, DELIVERY_ID__c, WEIGHT__c 
       FROM myifedeliverie__c WHERE ORDER_NUMBER__c =: lineId];*/
         List<myIfeDeliveries__x> myIfeDeliveries=[SELECT ITEM_NUMBER__c ,ITEM_DESCRIPTION__c,ORDER_NUMBER__c,
                                                    SHIP_FROM__c,SHIP_TO_LOCATION__c,SHIPPED_QUANTITY__c,SHIPPED_QUANTITY_UOM__c, LINE_ID__c, ORDER_HEADER_ID__c,
                                                    CUSTOMER_ID__c,DELIVERY_ID__c,DELIVERY_NAME__c,WAYBILL__c,STATUS__c,WEIGHT__c,FREIGHT_CARRIER__c
                                                    FROM myIfeDeliveries__x WHERE   LINE_ID__c =: lineId AND ORDER_HEADER_ID__c =: headerId];
         System.debug('myIfeDeliveries==== '+myIfeDeliveries);
         /*if(myifedeliveries.size() == 0){
            throw new AuraHandledException('No Record Found..'); 
         }*/
         String carrierTrackingURL = '';

       if(!myIfeDeliveries.isEmpty()){
            for(MyIFECarrierRedirect__mdt  carrierRedirecMdt : [SELECT Id, RedirectURL__c ,MasterLabel FROM MyIFECarrierRedirect__mdt ]){
                if(myIfeDeliveries[0].FREIGHT_CARRIER__c == carrierRedirecMdt.MasterLabel){
                    //carrierTrackingURL = carrierRedirecMdt.RedirectURL__c+myIfeDeliveries[0].WAYBILL__c;
                }
            }
        }
        Map<String,String> carrierWithRedirectURLMap = new Map<String,String>();
        for(MyIFECarrierRedirect__mdt  carrierRedirecMdt : [SELECT Id, RedirectURL__c ,MasterLabel FROM MyIFECarrierRedirect__mdt ]){
            carrierWithRedirectURLMap.put(carrierRedirecMdt.MasterLabel,carrierRedirecMdt.RedirectURL__c);
        }
         dataWrapperObj.myIFEDeliveries = myIfeDeliveries;
         dataWrapperObj.carrierWithRedirectURLMap = JSON.serialize(carrierWithRedirectURLMap);
        return dataWrapperObj;//myIfeDeliveries;//JSON.serialize(myifedeliveries) ;
    }
    public class DataWrapper{
        @AuraEnabled
        public List<myIfeDeliveries__x>  myIFEDeliveries {get;set;}
        @AuraEnabled
        public  String carrierWithRedirectURLMap {get;set;} 
        public DataWrapper(){
            myIFEDeliveries = new List<myIfeDeliveries__x>();
            carrierWithRedirectURLMap = null;
        }
    }
	@AuraEnabled 
	// Delivery Detail Line by Delivery ID Number April 2021
    public static  DataWrapper getMYIFdeliveryDetailLine(String lineId ,String headerId, String deliveryId){
		System.debug('line id ----   '+lineId);
		System.debug('header id ----   '+headerId);
		System.debug('delivery id ----   '+deliveryId);
		DataWrapper dataWrapperObj = new DataWrapper();
		List<myIfeDeliveries__x> myIfeDeliveryDetailLine=[SELECT ITEM_NUMBER__c,ITEM_DESCRIPTION__c,DELIVERY_ID__c, LINE_NUMBER__c, ORDER_NUMBER__c,
												  REQUESTED_QUANTITY__c, REQUESTED_QUANTITY_UOM__c, SHIPPED_QUANTITY__c, SHIPPED_QUANTITY_UOM__c, 
												  SHIP_FROM__c,SHIP_TO_LOCATION__c, STATUS__c, LOT_NUMBER__c, SCHEDULE_SHIP_DATE__c, LINE_ID__c, ORDER_HEADER_ID__c 
												  FROM myIfeDeliveries__x WHERE LINE_ID__c =: lineId AND ORDER_HEADER_ID__c =: headerId AND DELIVERY_ID__c =: deliveryId];
		System.debug('myIfeDelivery Detail Line ==== ' + myIfeDeliveryDetailLine);
		dataWrapperObj.myIFEDeliveries = myIfeDeliveryDetailLine;
		
		return dataWrapperObj;
	}
}