/**
 *      @author       Andy Fang
 *      @date         09/23/2019
 *      @description  Quote ID into Order Item
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                     09/23/2019         Initial scaffold
 *      Andy Fang                     04/09/2020         Commeting out
 *
 */
global class L2I_QuoteToOIController {

    /*
    @InvocableMethod
    public static List<L2I_QuoteAircraftServiceResult> autoCreateAircraftServicesFromQuote( List<Id> QuoteIds ) {
    
        List<L2I_QuoteAircraftServiceResult> results = new List<L2I_QuoteAircraftServiceResult>();
        Set<String> errorMessages = new Set<String>();

        try {

            //Query all order item that needs service activation
            List<OrderItem> oiList = [SELECT Id FROM orderItem WHERE OrderId IN (
                    SELECT Id FROM Order WHERE SBQQ__Quote__c IN: QuoteIds )
                    AND L2I_Service_Activation_Type__c != NULL];
            System.debug('====== oiList is "'  + oiList.size() );

            List<Id> oiIds = new List<Id>();

            for ( OrderItem oi : oiList ){
                oiIds.add( oi.Id );
            }

            if ( oiIds.size() == 0 ){
                String error = 'Your order doesn\'t need service activation.';
                errorMessages.add(error);
            } else {
                L2I_CreateASFromOIController.autoCreateAircraftServicesFromOI( oiIds );
            }


        } catch ( Exception ex ){
            throw new L2I_QuoteToOIControllerException(ex.getMessage());
        }

        L2I_QuoteAircraftServiceResult result = new L2I_QuoteAircraftServiceResult();

        if (!errorMessages.isEmpty()) {
            // We have some validation errors!!!
            String allErrors = 'Validation failed with following ' + errorMessages.size() + ' error(s):\n';
            Integer count = 1;
            for (String emsg : errorMessages) {
                allErrors = allErrors + '[' + count + '] ' + emsg + '\n';
                count++;
            }
            System.debug('Validation Errors :\n'+allErrors);
            result.isValid = false;
            result.message = allErrors;
        } else {
            // All validations have passed!
            result.isValid = true;
            result.message = 'AS is processing';
        }

        // return the result
        results.add(result);
        System.debug('====== results is "'  + results );

        return results;

    }


    global class L2I_QuoteAircraftServiceResult {
        @InvocableVariable
        global Boolean isValid;

        @InvocableVariable
        global String message;
    }

    class L2I_QuoteToOIControllerException extends Exception {}
    */
}