/**
 *      @author       Raj Rajen
 *      @date         01/03/2020
 *      @description  Test class for JSON Settings CustomMetadataType
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     01/03/2020         Initial setup of tests
 *
 */
@IsTest(SeeAllData=false)
public class L2I_JSON_Settings_Test {

    @IsTest
    static void test_get_json_settings() {
        Map<String, String> campaignTypeSettings = L2I_JSON_Settings.getSettings('OrderItem_Campaign_Type_Settings');
        System.assert(campaignTypeSettings != null, 'Campaign Type Settings cannot be null');

        Map<String, String> revenueTypeSettings = L2I_JSON_Settings.getSettings('OrderItem_Revenue_Type_Settings');
        System.assert(revenueTypeSettings != null, 'Revenue Type Settings cannot be null');

        Map<String, String> goalTypeSettings = L2I_JSON_Settings.getSettings('OrderItem_Goal_Type_Settings');
        System.assert(goalTypeSettings != null, 'Goal Type Settings cannot be null');
    }

    @IsTest
    static void test_get_specific_settings() {
        Map<String, String> campaignTypeSettings = L2I_JSON_Settings.getSettings('OrderItem_Campaign_Type_Settings');
        System.assert(campaignTypeSettings != null, 'Campaign Type Settings cannot be null');
        for (String key : campaignTypeSettings.keySet()) {
            String value = L2I_JSON_Settings.getSpecificSetting('OrderItem_Campaign_Type_Settings', key);
            System.assert(value != null, 'Specific value for key "' + key + '" cannot be null');
        }

        Map<String, String> revenueTypeSettings = L2I_JSON_Settings.getSettings('OrderItem_Revenue_Type_Settings');
        System.assert(revenueTypeSettings != null, 'Revenue Type Settings cannot be null');
        for (String key : revenueTypeSettings.keySet()) {
            String value = L2I_JSON_Settings.getSpecificSetting('OrderItem_Revenue_Type_Settings', key);
            System.assert(value != null, 'Specific value for key "' + key + '" cannot be null');
        }

        Map<String, String> goalTypeSettings = L2I_JSON_Settings.getSettings('OrderItem_Goal_Type_Settings');
        System.assert(goalTypeSettings != null, 'Goal Type Settings cannot be null');
        for (String key : goalTypeSettings.keySet()) {
            String value = L2I_JSON_Settings.getSpecificSetting('OrderItem_Goal_Type_Settings', key);
            System.assert(value != null, 'Specific value for key "' + key + '" cannot be null');
        }

        Set<String> recipients = L2I_JSON_Settings.getSpecificSettingCollection('System_Alert_Settings', 'Recipients');
        System.assert(recipients != null, 'System Alert Recipients cannot be null');
    }

    @IsTest
    static void validate_system_alert_settings() {
        Set<String> recipients = L2I_JSON_Settings.getSpecificSettingCollection('System_Alert_Settings', 'Recipients');
        System.assert(recipients != null, 'System Alert Recipients cannot be null');
        for (String s : recipients) {
            System.debug('====== Recipient :' + s);
            System.assert(L2I_UtilityHelper.validateEmail(s) == true, 'System Alert Recipient must have a valid email address');
        }

        String sender = L2I_JSON_Settings.getSpecificSetting('System_Alert_Settings', 'Sender');
        System.assert(L2I_UtilityHelper.validateEmail(sender) == true, 'System Alert Sender must have a valid email address');
    }
	
    @isTest
    static void validate_Debit_Note_Settings() {
        Map<String, String> debitNoteSettings = L2I_JSON_Settings.getSettings('Debit_Note_Settings');
        System.assert(debitNoteSettings != null, 'Debit Note Settings cannot be null');
        for (String key : debitNoteSettings.keySet()) {
            String value = L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings', key);
            System.assert(value != null, 'Specific value for key "' + key + '" cannot be null');
        }
        
        String pm_amount = L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings', 'PM_Time_Amount');
        Decimal pm_amount_deci;
        try {
            pm_amount_deci = Decimal.valueOf(pm_amount);
        } catch (Exception e) {
            System.assert(pm_amount_deci != null, 'Please provide decimal value for PM_Time_Amount in Debit_Note_Settings');
        }
        
        String oper_amount = L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings', 'Operations_Time_Amount');
        Decimal oper_amount_deci;
        try {
            oper_amount_deci = Decimal.valueOf(oper_amount);
        } catch (Exception e) {
            System.assert(pm_amount_deci != null, 'Please provide decimal value for Operations_Time_Amount in Debit_Note_Settings');
        }
        
        String equip_amount = L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings', 'Equipment_Time_Amount');
        Decimal equip_amount_deci;
        try {
            equip_amount_deci = Decimal.valueOf(equip_amount);
        } catch (Exception e) {
            System.assert(pm_amount_deci != null, 'Please provide decimal value for Equipment_Time_Amount in Debit_Note_Settings');
        }
        
        String rack_fee = L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings', 'Rack_Setup_Fee');
        Decimal rack_fee_deci;
        try {
            rack_fee_deci = Decimal.valueOf(rack_fee);
        } catch (Exception e) {
            System.assert(pm_amount_deci != null, 'Please provide decimal value for Rack_Setup_Fee in Debit_Note_Settings');
        }
    }
    
    @isTest
    static void validate_Order_Creation_Settings() {
        Map<String, String> orderCreationSettings = L2I_JSON_Settings.getSettings('Order_Creation_Settings');
        System.assert(orderCreationSettings != null, 'Order Creation Settings cannot be null');
        for (String key : orderCreationSettings.keySet()) {
            String value = L2I_JSON_Settings.getSpecificSetting('Order_Creation_Settings', key);
            System.assert(value != null, 'Specific value for key "' + key + '" cannot be null');
        }
    }
	
}