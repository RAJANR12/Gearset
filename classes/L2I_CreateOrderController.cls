/**
 *      @author       Raj Rajen
 *      @date         07/27/2017
 *      @description  Apex Controller used by the L2I_CreateOrderAction QuickAction Lightning component
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/25/2017         Initial scaffold
 *      Arun                          07/29/2019         Validation for placeholder parts
 *      Arun                          08/04/2019         Added Prospect Account validation
 *      Arun                          09/03/2019         Added Forecasting Quote validation
 *      Sarah Kennedy                 04/30/2020         US1823 TA3095 - Added check for 'Closed' for Amendment StageName change
 *
 */
public class L2I_CreateOrderController {
    
    private static Set<String> ALLOWED_CATEGORIES = L2I_UtilityHelper.getAllowedOrderProducts();
    private static Set<String> DISALLOWED_CATEGORIES = L2I_UtilityHelper.getDisallowedOrderProducts();
    private static Set<String> PLACEHOLDER_PARTS = L2I_JSON_Settings.getSpecificSettingCollection('Order_Creation_Settings', 'Place_Holder_Parts');
    private static Set<String> DISALLOWED_ACC_RECORDTYPES = L2I_JSON_Settings.getSpecificSettingCollection('Order_Creation_Settings', 'Excluded_Account_RecTypes');
    
    @AuraEnabled
    public static boolean createOrder(Id recId) {
        System.debug('======= Record Id associated with QuickAction :' + recId);
        Set<String> errorMessages = new Set<String>();
        Set<Id> accRecTypes = new Set<Id>();
        
        for (String recType : DISALLOWED_ACC_RECORDTYPES) {
            accRecTypes.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(recType).getRecordTypeId());
        }
        
        Id quoteId = recId;
        SBQQ__Quote__c quote = null;
        try {
            quote = [
                  select Id,
                        Name,
                        SBQQ__Ordered__c,
                        SBQQ__Account__c,
                        SBQQ__Account__r.RecordTypeId,
                        SBQQ__Opportunity2__r.StageName,
                        SBQQ__Primary__c,
                        L2I_Forecasting_Quote__c
                  from SBQQ__Quote__c
                  where Id = :quoteId
                  Limit 1
            ];
            System.debug('====== Selected Quote :' + quote);
            
            // Check if the record type is eligible for order creation. If not throw an error
            if (quote.SBQQ__Account__c != null && accRecTypes.contains(quote.SBQQ__Account__r.RecordTypeId)) {
                String error = 'You cannot create an order for a prospect account.';
                errorMessages.add(error);
            }
            
            if (quote.SBQQ__Primary__c != true) {
                String error = 'Order can only be created from a Primary Quote';
                errorMessages.add(error);
            }
            
            if (!(quote.SBQQ__Opportunity2__r.StageName.equalsIgnoreCase('closed won') ||
                  quote.SBQQ__Opportunity2__r.StageName.equalsIgnoreCase('pending close') ||
                  quote.SBQQ__Opportunity2__r.StageName.equalsIgnoreCase('closed') )) {
                String error = 'Opportunity stage must be Pending Close, Closed or Closed Won to create an Order';
                errorMessages.add(error);
            }
            
            // to check if it's a forecasting quote and throw an error message
            if (quote.L2I_Forecasting_Quote__c) {
                String error = 'You cannot create an order from a Forecasting Quote.';
                errorMessages.add(error);
            }
            
            // first check if the Quote has already been ordered
            if (quote.SBQQ__Ordered__c) {
                String error = 'Cannot create an order again. This quote has already been ordered';
                errorMessages.add(error);
            } else {
                // Quote has not been ordered already, but need to verify that the quote lines
                // do not contain any Disallowed products
                List<SBQQ__QuoteLine__c> quoteLines = [
                      select Id,
                            Name,
                            SBQQ__Bundle__c,
                            SBQQ__ProductName__c,
                            SBQQ__Product__r.L2I_Category__c,
                            SBQQ__Product__r.L2I_Sub_Category_1__c,
                            SBQQ__Product__r.L2I_Sub_Category_2__c,
                            SBQQ__Quote__c,
                            L2I_ProductCode_Display__c
                      from SBQQ__QuoteLine__c
                      where SBQQ__Quote__c = :quoteId
                ];
                
                
                for (SBQQ__QuoteLine__c line : quoteLines) {
                    String lineProduct = line.SBQQ__ProductName__c;
                    String lineCategory = line.SBQQ__Product__r.L2I_Sub_Category_2__c;
                    String lineProductCodeDisplay = line.L2I_ProductCode_Display__c;
                    System.debug('====== Quoteline is "' + lineProduct + '" category2 : ' + lineCategory);
                    // Added null condition check by Arun. It was throwing null pointer exception for PlaceHolder Parts
                    if (lineCategory != null && DISALLOWED_CATEGORIES.contains(lineCategory.toLowerCase())) {
                        String error = 'Cannot create an order for "' + lineCategory + '" products';
                        errorMessages.add(error);
                    }
                    if (lineProductCodeDisplay != null && PLACEHOLDER_PARTS.contains(lineProductCodeDisplay.toLowerCase())) {
                        String error = 'Please fill the Part# for ' + lineProductCodeDisplay + ' product';
                        errorMessages.add(error);
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        if (!errorMessages.isEmpty()) {
            String allErrors = 'Validation failed with following ' + errorMessages.size() + ' error(s):\n';
            Integer count = 1;
            for (String emsg : errorMessages) {
                allErrors = allErrors + '[' + count + '] ' + emsg + '\n';
                count++;
            }
            System.debug('Validation Errors :\n' + allErrors);
            throw new AuraHandledException(allErrors);
        }
        
        // All validations have passed!
        // finally try to update the Quote as an Ordered quote
        try {
            quote.SBQQ__Ordered__c = true;
            update quote;
            System.debug('====== Quote has been marked as ordered');
            return true;
        } catch (Exception e) {
            System.debug('====== Exception occurred when updating Quote as ordered');
            System.debug('====== message :' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    
    
    }

    // Description: Updates Order and related Order Products Start date
    @InvocableMethod(label= 'Update Order Start Date')
    public static void updateStartDate(List<FlowInputs> request) {
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        List<Order> ordersToUpdate = new List<Order>();
        List<String> recordIds = request[0].recordIds.split(',');
        Date startDate = request[0].startDate;

        for (OrderItem oi : [SELECT Id, ServiceDate FROM OrderItem WHERE OrderId IN :recordIds]) {
            oi.ServiceDate = startDate;
            orderItemsToUpdate.add(oi);
        }

        for (String id : recordIds) {
            ordersToUpdate.add(new Order(Id = id, EffectiveDate = startDate));
        }

        update ordersToUpdate;
        update orderItemsToUpdate;
    }

     //input details that comes to apex from flow
     public class FlowInputs{
    
        @InvocableVariable
        public String recordIds;
        
        @InvocableVariable
        public Date startDate;
    }
}