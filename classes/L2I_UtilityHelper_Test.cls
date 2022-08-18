/**
 *      @author       Raj Rajen
 *      @date         08/18/2019
 *      @description  Test class for System Alert Notifier
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/18/2019         Initial setup of tests
 *
 */
@IsTest(SeeAllData=false)
public class L2I_UtilityHelper_Test {

    @IsTest
    static void test_get_record_types_lookup() {
        Map<Id,RecordType> acctRtypes = L2I_UtilityHelper.getRecordTypesLookup('Account');
        System.assert(acctRtypes != null, 'Account Record Types cannot be null');
    }

    @IsTest
    static void test_get_record_type_id() {
        Id rtId = L2I_UtilityHelper.getRecordTypeId('Deal', 'Opportunity');
        System.assert(rtId != null, 'Deal Opportunity Record Type Id cannot be null');
    }

    @IsTest
    static void test_get_email_template_id() {
        Id tmplId = L2I_UtilityHelper.getEmailTemplateId('Approved_Template');
        System.assert(tmplId != null, 'Approved Template for Quote cannot be null');

        tmplId = L2I_UtilityHelper.getEmailTemplateId('Non_Existant_Template');
        System.assert(tmplId == null, 'There should not be a template called Non_Existant_Template');
    }

    @IsTest
    static void test_get_general_settings() {
        Set<String> disallowedProducts = L2I_UtilityHelper.getDisallowedOrderProducts();
        System.assert(disallowedProducts.size() > 0, 'Number of Disallowed Products should be greater than 0');

        Set<String> allowedProducts = L2I_UtilityHelper.getAllowedOrderProducts();
        System.assert(allowedProducts.size() > 0, 'Number of Allowed Products should be greater than 0');

        /*Set<String> placeholderProductCodes = L2I_UtilityHelper.getPlaceholderProductCodes();
        System.assert(placeholderProductCodes.size() > 0, 'Number of Placeholder Product Codes should be greater than 0');

        Set<String> excludedAcctTypes = L2I_UtilityHelper.getAccountRecordTypeNames();
        System.assert(excludedAcctTypes.size() > 0, 'Number of excluded Account record types must be greater than zero');*/
    }

    @IsTest
    static void test_generate_random_string() {
        String randomString = L2I_UtilityHelper.generateRandomString(32768);
        System.assert(randomString.length() == 32768, 'Generated string is not 32768 characters in length');
    }

    @IsTest
    static void test_validate_email_address() {
        String validEmailAddress = 'someone@some.where.com';
        String invalidEmailAddress = 'someone&some_where.com';

        System.assert(L2I_UtilityHelper.validateEmail(validEmailAddress) == true, 'Valid email address cannot be flagged as invalid');
        System.assert(L2I_UtilityHelper.validateEmail(invalidEmailAddress) == false, 'Invalid email address cannot be flagged as valid');
    }

    @IsTest
    static void test_send_email() {
        User u = [ SELECT Id FROM User WHERE isactive = TRUE AND profile.Name = 'System Administrator' LIMIT 1];
        String emailErrorSubject = 'This is an error subject';
        String emailErrorBody = 'The is an error body';
        L2I_UtilityHelper.sendEmail( emailErrorSubject, emailErrorBody, u.Id );
    }
    
    @IsTest
    static void test_service_activated(){
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupAccountThruOrder(null, null, false, 'Activated');
        
        Order ord = [SELECT Id  FROM Order LIMIT 1];
        Map<Id, Date> orderMap = new Map<Id, Date>();
        Date actDate = Date.today();
        orderMap.put(ord.Id, actDate);
        String jsonString = JSON.serialize(orderMap);
        L2I_UtilityHelper.publishAircraftServiceActivatedEvent(jsonString);
    }
}