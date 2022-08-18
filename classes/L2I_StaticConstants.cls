/**
 *      @author       Raj Rajen
 *      @date         07/10/2017
 *      @description  Helper class to act as a repository of global static constants
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/10/2017         Initial scaffold
 *
 */
public class L2I_StaticConstants {

    // LongTextArea size limit
    public static final Integer LONGTEXT_AREA_LIMIT = 32768 - 2; // less 2 characters for substring usage?

    // Record Types
    // Account Record Types
    public static final Id PROSPECT_ACCOUNT_RT_ID =
            Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
    public static final Id CUSTOMER_ACCOUNT_RT_ID =
            Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    public static final Id COMPETITOR_ACCOUNT_RT_ID =
            Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();

    // Opportunity Record Types
    public static final Id DEAL_OPPORTUNITY_RT_ID =
            Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
    public static final Id SALES_OPPORTUNITY_RT_ID =
            Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
    public static final Id ADVERTISING_OPPORTUNITY_RT_ID =
            Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Advertising').getRecordTypeId();
    public static final Id MARKET_OPPORTUNITY_RT_ID =
            Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Market').getRecordTypeId();
    public static final Id PPL_OPPORTUNITY_RT_ID =
            Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PPL').getRecordTypeId();

    // DSH and DSL Record Types
    public static final Id HARDWARE_DSH_RT_ID =
            Schema.SObjectType.L2I_DSH__c.getRecordTypeInfosByName().get('Hardware').getRecordTypeId();
    public static final Id HARDWARE_DSL_RT_ID =
            Schema.SObjectType.L2I_DSL__c.getRecordTypeInfosByName().get('Hardware').getRecordTypeId();

    // SBQQ__Quote Record Types
    public static final Id DRAFT_QUOTE_RT_ID =
            Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Quote Draft').getRecordTypeId();
    public static final Id APPROVED_QUOTE_RT_ID =
            Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Quote Approved').getRecordTypeId();
    public static final Id PENDING_QUOTE_RT_ID =
            Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Quote Pending').getRecordTypeId();

    // Profiles
    private static final Profile[] allProfiles = [select Id, Name from Profile];

    public static Profile getProfileByName(String profileName) {
        Profile prof = null;
        for (Profile p : L2I_StaticConstants.allProfiles) {
            if (profileName.equalsIgnoreCase(p.Name)) {
                prof = p;
                break;
            }
        }
        return prof;
    }

    // Permission Sets
    public static Boolean isUserAssignedToPermissionSet(String permsetName, Id userId) {
        Boolean isAssigned = false;

        PermissionSet pset = [select Id, Name from PermissionSet where Name =: permsetName];
        if (pset != null) {
            List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>([select Id,
                                                                                                  AssigneeId,
                                                                                                  PermissionSetId
                                                                                             from PermissionSetAssignment
                                                                                            where PermissionSetId =: pset.Id
                                                                                              and AssigneeId =: userId]);
            if (!assignments.isEmpty()) {
                isAssigned = true;
            }
        }
        return isAssigned;
    }


    // static variable to store all record type ids
    private static final RecordType[] allRecordTypeIds = [select Id, DeveloperName, SobjectType From RecordType];

    // function to return all record type ids for a object
    public static RecordType[] getRecordTypeIDsByObject(String SobjectType){
        RecordType[] rts = new RecordType[]{};
        for (RecordType rt:L2I_StaticConstants.allRecordTypeIds) {
            if (rt.SobjectType == SobjectType) rts.add(rt);
        }
        return rts;
    }

    // A map of all Static Resource csv files that are needed for Billing, Products and CPQ (not configuration) testing.
    // It would have been nice if these files could have been loaded into a zip file and be referenced from the zip file
    // but unfortunately Salesforce does not allow for that :(
    public static final Map<String, String> unitTestStaticResource = new Map<String,String>{'GLRule_file'                 => 'Unit_Test_blng_GLRule_csv',
                                                                                            'LegalEntity_file'            => 'Unit_Test_blng_LegalEntity_csv',
                                                                                            'FinanceBook_file'            => 'Unit_Test_blng_FinanceBook_csv',
                                                                                            'BillingRule_file'            => 'Unit_Test_blng_BillingRule_csv',
                                                                                            'TaxRule_file'                => 'Unit_Test_blng_TaxRule_csv',
                                                                                            'RevenueRecognitionRule_file' => 'Unit_Test_blng_RevenueRecognitionRule_csv',
                                                                                            'GLAccount_file'              => 'Unit_Test_blng_GLAccount_csv',
                                                                                            'GLTreatment_file'            => 'Unit_Test_blng_GLTreatment_csv',
                                                                                            'FinancePeriod_file'          => 'Unit_Test_blng_FinancePeriod_csv',
                                                                                            'BillingTreatment_file'       => 'Unit_Test_blng_BillingTreatment_csv',
                                                                                            'Product2_file'               => 'Unit_Test_Product2_csv',
                                                                                            'BillingConfig_file'          => 'Unit_Test_blng_BillingConfig_csv'};
}