/**
 *      @author       Raj Rajen
 *      @date         09/18/2019
 *      @description  L2I Quote Validation Action  Invocable Apex Class
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     09/18/2019         Initial scaffold
 *      Arun V                        11/08/2019         Refactored to add Validation on "Exclude from Orders"checkbox.
 *      Sarah Kennedy                 04/30/2020         US1823 TA3095 - Added check for 'Closed' for Amendment StageName change
 *
 */
global class L2I_QuoteValidationAction {
    
    private static Set<String> ALLOWED_CATEGORIES = L2I_UtilityHelper.getAllowedOrderProducts();
    private static Set<String> DISALLOWED_CATEGORIES = L2I_UtilityHelper.getDisallowedOrderProducts();
    private static Set<String> PLACEHOLDER_PARTS = L2I_JSON_Settings.getSpecificSettingCollection('Order_Creation_Settings', 'Place_Holder_Parts');
    private static Set<String> DISALLOWED_ACC_RECORDTYPES = L2I_JSON_Settings.getSpecificSettingCollection('Order_Creation_Settings', 'Excluded_Account_RecTypes');
    
    /**
    @InvocableMethod(label='Validate Quote')
    public static void validateSingleQuote(List<Id> quoteIds) {

    }
    **/
    
    @InvocableMethod(label='Validate Quote')
    public static List<L2I_QuoteValidationResult> validateQuote(List<L2I_QuoteValidationRequest> requests) {
        List<L2I_QuoteValidationResult> results = new List<L2I_QuoteValidationResult>();
        
        // This validation process is used interactively and is meant to validate only one quote
        // therefore we take only the first item from the incoming requests list
        L2I_QuoteValidationRequest request = requests[0];
        Id recId = request.quoteId;
        
        System.debug('======= Record Id associated with QuoteValidationAction Invocable Apex :' + recId);
        Set<String> errorMessages = new Set<String>();
        Set<Id> accRecTypes = new Set<Id>();
        
        for (String recType : DISALLOWED_ACC_RECORDTYPES) {
            accRecTypes.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(recType).getRecordTypeId());
        }
    
        Boolean byPassValidation = false;
        byPassValidation = L2I_GenericSettings__c.getInstance(UserInfo.getUserId()).Bypass_Create_Order_Quote_Validations__c;
        System.debug('*** byPass Quote Validate for User ' + byPassValidation + ' ' + UserInfo.getUserName());
        
        Id quoteId = recId;
        Id amendId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        
        SBQQ__Quote__c quote = null;
        try {
            quote = [
                  select Id,
                        Name,
                        SBQQ__Ordered__c,
                        SBQQ__Account__c,
                        SBQQ__Account__r.RecordTypeId,
                        SBQQ__Opportunity2__r.StageName,
                        SBQQ__Opportunity2__r.PT_Price_List__c,
                        SBQQ__Opportunity2__r.PT_Price_List__r.L2I_Header_ExternalId__c,
                        SBQQ__Opportunity2__r.PT_Price_List__r.L2I_IntegrationStatus__c,
                        SBQQ__Opportunity2__r.RecordTypeId,
                        SBQQ__Opportunity2__r.RecordType.DeveloperName,
                        SBQQ__Primary__c,
                        L2I_Forecasting_Quote__c,
                        SBQQ__Type__c,
                        L2I_Obsolete__c,
                        SBQQ__MasterContract__c,
                        SBQQ__Opportunity2__r.SBQQ__RenewedContract__c
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
    
            // W-003039
            if (quote.SBQQ__Opportunity2__r.RecordTypeId != amendId) {      // skip validation for Cancellation Opps (Amendments)
                Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                if ((byPassValidation &&
                      isSandbox) ||
                      Test.isRunningTest()) {
                    if (!quote.SBQQ__Opportunity2__r.StageName.equalsIgnoreCase('delivery')) {
                        String error = 'Opportunity stage must be Delivery and (BYPASSING) Customer Price List must be complete before an Order can be created';
                        errorMessages.add(error);
                    }
                } else {
                    if (!quote.SBQQ__Opportunity2__r.StageName.equalsIgnoreCase('delivery') ||
                          String.isBlank(quote.SBQQ__Opportunity2__r.PT_Price_List__c) ||
                          String.isBlank(quote.SBQQ__Opportunity2__r.PT_Price_List__r.L2I_Header_ExternalId__c) ||
                          quote.SBQQ__Opportunity2__r.PT_Price_List__r.L2I_IntegrationStatus__c != 'Success') {
                        String error = 'Opportunity stage must be Delivery and Customer Price List must be complete before an Order can be created';
                        errorMessages.add(error);
                    }
                }
                System.debug('*** quote.SBQQ__Opportunity2__r.StageName ' + quote.SBQQ__Opportunity2__r.StageName);
                System.debug('*** quote.SBQQ__Opportunity2__r.RecordType.DeveloperName ' + quote.SBQQ__Opportunity2__r.RecordType.DeveloperName);
                System.debug('*** quote.SBQQ__Opportunity2__r.PT_Price_List__r.L2I_Header_ExternalId__c  ' + quote.SBQQ__Opportunity2__r.PT_Price_List__r.L2I_Header_ExternalId__c);
                System.debug('*** quote.SBQQ__Opportunity2__r.PT_Price_List__r.L2I_IntegrationStatus__c ' + quote.SBQQ__Opportunity2__r.PT_Price_List__r.L2I_IntegrationStatus__c);
            }
            // to check if it's a forecasting quote and throw an error message
            /* Commented by Arun
            if (quote.L2I_Forecasting_Quote__c) {
                String error = 'You cannot create an order from a Forecasting Quote.';
                errorMessages.add(error);
            }*/
            
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
                            L2I_ProductCode_Display__c,
                            SBQQ__Product__r.L2I_Exclude_From_Orders__c
                      from SBQQ__QuoteLine__c
                      where SBQQ__Quote__c = :quoteId
                ];
                
                
                for (SBQQ__QuoteLine__c line : quoteLines) {
                    String lineProduct = line.SBQQ__ProductName__c;
                    String lineCategory = line.SBQQ__Product__r.L2I_Sub_Category_2__c;
                    String lineProductCodeDisplay = line.L2I_ProductCode_Display__c;
                    System.debug('====== Quoteline is "' + lineProduct + '" category2 : ' + lineCategory);
                    // Added null condition check by Arun. It was throwing null pointer exception for PlaceHolder Parts
                    /* Commented by Arun (Can be cleaned up further in next release)
                    if (lineCategory != null && DISALLOWED_CATEGORIES.contains(lineCategory.toLowerCase())) {
                        String error = 'Cannot create an order for "' + lineCategory + '" products';
                        errorMessages.add(error);
                    }*/
                    
                    if (line.SBQQ__Product__r.L2I_Exclude_From_Orders__c) {
                        String error = 'Cannot create an order for "' + line.SBQQ__ProductName__c + '" product';
                        errorMessages.add(error);
                    }
                    
                    if (lineProductCodeDisplay != null && PLACEHOLDER_PARTS.contains(lineProductCodeDisplay.toLowerCase())) {
                        String error = 'Please fill the Part# for ' + lineProductCodeDisplay + ' product';
                        errorMessages.add(error);
                    }
                }
                System.debug('*** errorMessages ' + errorMessages);
            }
            
            if (quote.SBQQ__Type__c == 'Amendment') {
                if (quote.L2I_Obsolete__c) {
                    errorMessages.add('This Quote has been invalidated by another Amendment order, please restart new Amendment Opportunity.');
                }
                
                List<Order> orders = new List<Order>([Select Id From Order Where SBQQ__Quote__r.SBQQ__MasterContract__c = :quote.SBQQ__MasterContract__c And Status != 'Activated' And SBQQ__Quote__r.L2I_Obsolete__c = false And SBQQ__Quote__r.SBQQ__Type__c = :quote.SBQQ__Type__c]);
                if (orders.size() > 0) {
                    errorMessages.add('There is a Pending Order, a new order cannot be created until pending order has been Activated. Once this pending order is activated Current Quote will be marked as Obsolete and New Amendment Quote will need to be created.');
                }
            }
            
            if (quote.SBQQ__Type__c == 'Renewal') {
                if (quote.L2I_Obsolete__c) {
                    errorMessages.add('This Quote has been invalidated by another Renewal order, please restart new Renewal Opportunity.');
                }
                
                List<Order> orders = new List<Order>([Select Id From Order Where Opportunity.SBQQ__RenewedContract__c = :quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c And Status != 'Activated' And SBQQ__Quote__r.L2I_Obsolete__c = false And SBQQ__Quote__r.SBQQ__Type__c = :quote.SBQQ__Type__c]);
                if (orders.size() > 0) {
                    errorMessages.add('There is a Pending Order, a new order cannot be created until pending order has been Activated. Once this pending order is activated Current Quote will be marked as Obsolete and New Renewal Quote will need to be created.');
                }
            }
        } catch (Exception e) {
            System.debug('*** exception ' + e.getMessage());
            throw new L2I_QuoteValidationActionException(e.getMessage());
        }
        
        L2I_QuoteValidationResult result = new L2I_QuoteValidationResult();
        
        if (!errorMessages.isEmpty()) {
            // We have some validation errors!!!
            String allErrors = 'Validation failed with following ' + errorMessages.size() + ' error(s):\n';
            Integer count = 1;
            for (String emsg : errorMessages) {
                allErrors = allErrors + '[' + count + '] ' + emsg + '\n';
                count++;
            }
            System.debug('Validation Errors :\n' + allErrors);
            result.isValid = false;
            result.message = allErrors;
        } else {
            // All validations have passed!
            result.isValid = true;
            result.message = 'Quote is valid';
        }
        
        // return the result
        results.add(result);
        return results;
    }
    
    global class L2I_QuoteValidationRequest {
        @InvocableVariable(required=true)
        global Id quoteId;
    
    }
    
    global class L2I_QuoteValidationResult {
        @InvocableVariable
        global Boolean isValid;
        
        @InvocableVariable
        global String message;
    }
    
    class L2I_QuoteValidationActionException extends Exception {
    }
}