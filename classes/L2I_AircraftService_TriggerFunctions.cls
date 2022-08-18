/**
 *      @author       Raj Rajen
 *      @date         08/14/2019
 *      @description  L2I AircraftService Trigger Functions
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/14/2019         Initial scaffold
 *      Sarah Kennedy                 03/24/2020         Changes for Amendment/Renewal object/field changes
 *      Sarah Kennedy                 04/10/2020         US1762 removed checkServiceActivation method
 *      
 */
public without sharing class L2I_AircraftService_TriggerFunctions {

    public static void InitializeFlags(List<L2I_Aircraft_Service__c> newAircraftServiceList,
                                          Map<Id, L2I_Aircraft_Service__c> newAircraftServiceMap,
                                          Map<Id, L2I_Aircraft_Service__c> oldAircraftServiceMap) {
        System.debug('====== Checking to see if blng__Usage__c Adjustment records have to be created');
        // initialize fields used in Aircraft Service Adj Usage Batch
        for (L2I_Aircraft_Service__c newAS : newAircraftServiceList) {
            L2I_Aircraft_Service__c oldAS = oldAircraftServiceMap.get(newAS.Id);
            // if activation date is set initialize
            System.debug('@@@@ Inside For loop : ' + newAS.Service_Activation_Type__c);

            if (newAS.L2I_Activation_Date__c !=null && oldAS.L2I_Activation_Date__c == null) {
                System.debug('@@@@ Activation Date is set : ');
                if (newAS.Calculated_Activation_Date__c < (Date.today() - 1) && newAS.Service_Activation_Type__c == 'Monthly') {
                    newAS.L2I_Activation_Adjustment_Needed__c = true;
                } Else if (newAS.Service_Activation_Type__c == 'Yearly' && newAS.Yearly_Bill_Date__c == null) {
                    // for yearly usage type
                    System.debug('@@@@ Yearly Bill Date is set : ');
                    Integer OffsetYears = 1;
                    if (newAS.Initial_Offset_Years__c != null && newAS.Initial_Offset_Years__c != '0' && newAS.Initial_Offset_Years__c != ''){
                        OffsetYears = Integer.valueOf(newAS.Initial_Offset_Years__c);
                    }
                    newAS.Yearly_Bill_Date__c = newAS.Calculated_Activation_Date__c.addYears(OffsetYears);
                }
            } else if (newAS.L2I_Deactivation_Date__c !=null && oldAS.L2I_Deactivation_Date__c == null) {
                if (newAS.Calculated_Deactivation_Date__c < (Date.today() - 1) && newAS.Service_Activation_Type__c == 'Monthly') {
                    newAS.L2I_Deactivation_Adjustment_Needed__c = true;
                }
            }
        }

    }

}