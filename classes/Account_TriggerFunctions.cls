/**
 * @Description        : Helper for Account_TriggerHandler
 * @Author             : Jan Denrick Geronga / Managed Services Simplus
 * @Modification Log   :
 * Ver          Date          Author              Modification
 * W-003956     Oct-18-2021   MS Simplus Jan      Initial Version
 **/

public class Account_TriggerFunctions {

    public static void updateQuoteShipToBillTo(List<Account> newList, Map<Id, Account> oldMap) {
        Map<Id, Account> mAcc = new Map<Id, Account>();
        List<SBQQ__Quote__c> lQuote = new List<SBQQ__Quote__c>();
        for(Account acc : newList) {
            if((acc.ShippingAddress != oldMap.get(acc.Id).ShippingAddress) || (acc.BillingAddress != oldMap.get(acc.Id).BillingAddress)
               || (acc.Name != oldMap.get(acc.Id).Name) || (acc.ShippingCity != oldMap.get(acc.Id).ShippingCity) || (acc.ShippingCountry != oldMap.get(acc.Id).ShippingCountry)
               || (acc.ShippingPostalCode != oldMap.get(acc.Id).ShippingPostalCode) || (acc.ShippingState != oldMap.get(acc.Id).ShippingState)
               || (acc.ShippingStreet != oldMap.get(acc.Id).ShippingStreet) || (acc.BillingCity != oldMap.get(acc.Id).BillingCity)
               || (acc.BillingCountry != oldMap.get(acc.Id).BillingCountry) || (acc.BillingPostalCode != oldMap.get(acc.Id).BillingPostalCode)
               || (acc.BillingState != oldMap.get(acc.Id).BillingState) || (acc.BillingStreet != oldMap.get(acc.Id).BillingStreet)){
                mAcc.put(acc.Id, acc);
            }
        }
        
        if(!mAcc.isEmpty()){
            for(SBQQ__Quote__c quote: [SELECT Id, SBQQ__Opportunity2__c, SBQQ__Account__c, SBQQ__ShippingName__c, SBQQ__ShippingCity__c, SBQQ__ShippingCountry__c, SBQQ__ShippingPostalCode__c,
                                       SBQQ__ShippingState__c, SBQQ__ShippingStreet__c, SBQQ__BillingName__c, SBQQ__BillingCity__c, SBQQ__BillingCountry__c, SBQQ__BillingPostalCode__c,
                                       SBQQ__BillingState__c, SBQQ__BillingStreet__c
                                       FROM SBQQ__Quote__c WHERE SBQQ__Account__c IN: mAcc.keySet()]){
                                           quote.SBQQ__ShippingName__c = mAcc.get(quote.SBQQ__Account__c).Name; 
                                           quote.SBQQ__ShippingCity__c = mAcc.get(quote.SBQQ__Account__c).ShippingCity; 
                                           quote.SBQQ__ShippingCountry__c = mAcc.get(quote.SBQQ__Account__c).ShippingCountry;
                                           quote.SBQQ__ShippingPostalCode__c = mAcc.get(quote.SBQQ__Account__c).ShippingPostalCode;
                                           quote.SBQQ__ShippingState__c = mAcc.get(quote.SBQQ__Account__c).ShippingState;
                                           quote.SBQQ__ShippingStreet__c = mAcc.get(quote.SBQQ__Account__c).ShippingStreet; 
                                           quote.SBQQ__BillingName__c = mAcc.get(quote.SBQQ__Account__c).Name; 
                                           quote.SBQQ__BillingCity__c = mAcc.get(quote.SBQQ__Account__c).BillingCity;
                                           quote.SBQQ__BillingCountry__c = mAcc.get(quote.SBQQ__Account__c).BillingCountry;
                                           quote.SBQQ__BillingPostalCode__c = mAcc.get(quote.SBQQ__Account__c).BillingPostalCode;
                                           quote.SBQQ__BillingState__c = mAcc.get(quote.SBQQ__Account__c).BillingState;
                                           quote.SBQQ__BillingStreet__c = mAcc.get(quote.SBQQ__Account__c).BillingStreet;
                                           lQuote.add(quote);
                                       }
        }
        if(lQuote.size() > 0){
            update lQuote;
        }
    }
}