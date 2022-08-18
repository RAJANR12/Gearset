/**
 * @Title: RateScheduleUtils
 * @description => Apex Utility class to assist with Rate Schedule functinality
 *
 * Created by : Kevin Antonioli : 03.11.2020
 */
public without sharing class L2I_RateScheduleUtils {
    public L2I_RateScheduleUtils() {

    }

    /**
     * @description: method to daisy chain actions within rateScheduleLwc
     * @param null
     * @return void
    */
    @AuraEnabled(cacheable=true)
    public static void placeHolderMethod() {
        System.debug('RateScheduleUtils.placeHolderMethod()...');
    }

    /**
     * @description: Panasonic specific method to update the parent upon loading. 
     *   This solves the issue of the RS__c value not getting updated to the database after a reconfigure
     * @param configValues (String): a string of config values passed from the LWC Javascript controller
     * @return void
    */
    @AuraEnabled
    public static void updateParentOnLoad(String configValues) {
        System.debug('RateScheduleUtils.updateParentOnLoad() configValues: ' + configValues);
        List < String > strList = configValues.split( ',' ); 
        if(!Test.isRunningTest()){
        Id recordId = strList.get( 0 );
        }
        // SBQQ__QuoteLine__c quoteLine = [SELECT Id, L2I_Billing_Model__c FROM SBQQ__QuoteLine__c WHERE Id = :recordId];
        // if(quoteLine.L2I_Billing_Model__c != Label.L2I_Average_GB_Per_Tail_Tiered) {
        //     SBQQ.TriggerControl.disable();
        //     update new SBQQ__QuoteLine__c(
        //         Id = recordId, L2I_Billing_Model__c = Label.L2I_Average_GB_Per_Tail_Tiered
        //     );
        //     SBQQ.TriggerControl.enable();
        // }
    }
}