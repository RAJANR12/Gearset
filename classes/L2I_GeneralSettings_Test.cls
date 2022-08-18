/**
 *      @author       Raj Rajen
 *      @date         08/18/2019
 *      @description  Test class for General Settings CustomMetadataType
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/18/2019         Initial setup of tests
 *
 */
@IsTest(SeeAllData=false)
public class L2I_GeneralSettings_Test {

    @IsTest
    static void test_get_mdt() {
        L2I_General_Settings__mdt mdt = L2I_GeneralSettings.getGeneralSetting();
        System.assert(mdt != null, 'GeneralSettings CustomMetadataType cannot be null');
    }

    @IsTest
    static void test_get_settings() {
        Set<String> disallowedProducts = L2I_GeneralSettings.getDisallowedProducts();
        System.assert(disallowedProducts.size() > 0, 'Number of Disallowed Products should be greater than 0');

        Set<String> allowedProducts = L2I_GeneralSettings.getAllowedProducts();
        System.assert(allowedProducts.size() > 0, 'Number of Allowed Products should be greater than 0');

        Set<String> alertRecipients = L2I_GeneralSettings.getSystemAlertRecipients();
        System.assert(alertRecipients.size() > 0, 'Number of alert recipients must be greater than 0');

        String sender = L2I_GeneralSettings.getSystemAlertSender();
        System.assert(sender != null, 'System Alert Sender cannot be null');

        Integer jobOffset = L2I_GeneralSettings.getOrderActivationScheduleJobOffsetMinutes();
        System.assert(jobOffset != null, 'Schedule Job Offset in minutes cannot be null');
		
        /*Set<String> placeholderProductCodes = L2I_GeneralSettings.getPlaceholderProductCodes();
        System.assert(placeholderProductCodes.size() > 0, 'Number of Placeholder Product Codes should be greater than 0');

        Set<String> excludedAcctTypes = L2I_GeneralSettings.getAccountRecordTypeNames();
        System.assert(excludedAcctTypes.size() > 0, 'Number of excluded Account record types must be greater than zero');*/

        Set<String> aircraftServiceAllowedProducts = L2I_GeneralSettings.getAircraftServiceAllowedProducts();
        System.assert(aircraftServiceAllowedProducts.size() > 0, 'Number of aircraft services allowed products must be greater than zero');

        Boolean enableOALogging = L2I_GeneralSettings.getEnableOrderActivationLoggingFlag();
        System.assert(enableOALogging != null, 'Enable Order Activation Logging flag should either be true or false');

        Boolean firePEonAircraftServiceActivation = L2I_GeneralSettings.shouldFirePEonAircraftServiceActivation();
        System.assert(firePEonAircraftServiceActivation != null, 'Fire PE on Aircraft Service Activation flag should either be true or false');
        System.debug('Current value of firePEonAircraftServiceActivation :' + firePEonAircraftServiceActivation);
    }

}