/**
 *      @author       Raj Rajen
 *      @date         08/03/2019
 *      @description  Test class for L2I Static Constants.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/03/2019         Initial setup of tests
 *
 */
@isTest(SeeAllData=false)
public class L2I_StaticConstants_Test {

    static testMethod void test_record_type_values() {
        RecordType[] acctRecordTypes = L2I_StaticConstants.getRecordTypeIDsByObject('Account');
        System.assert(acctRecordTypes.size() > 0, 'Account Record Types size is not as expected');
    }

    static testMethod void test_profile_permission_set_assignment() {
        L2I_DataFactory factory = new L2I_DataFactory();

        Profile salesProfile = L2I_StaticConstants.getProfileByName('PAC Sales');
        User stewardUser = factory.createTestUser(null, salesProfile.Id, 'Aircraft', 'Steward');
        insert stewardUser;

        System.assert(stewardUser.Id != null, 'User Id cannot be null');

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Aircraft_Data_Steward'];
        insert new PermissionSetAssignment(AssigneeId = stewardUser.Id, PermissionSetId = ps.Id);

        Boolean isAssigned = L2I_StaticConstants.isUserAssignedToPermissionSet('Aircraft_Data_Steward', stewardUser.Id);
        System.assert(isAssigned, 'Permission Set Assignment must exist');
    }


    static testmethod void test_static_resource_csv_loads() {

        List<SObject> blng_GLRules = Test.loadData(blng__GLRule__c.sObjectType,
                                                   L2I_StaticConstants.unitTestStaticResource.get('GLRule_file'));
        System.assert(blng_GLRules.size() > 0, 'There must be atleast one GLRule loaded');
        System.debug('Loaded blng__GLRules');


        List<SObject> blng_LegalEntities = Test.loadData(blng__LegalEntity__c.sObjectType,
                                                         L2I_StaticConstants.unitTestStaticResource.get('LegalEntity_file'));
        System.assert(blng_LegalEntities.size() > 0, 'There must be atleast one LegalEntity loaded');
        System.debug('Loaded blng__LegalEntities');


        List<SObject> blng_financeBooks = Test.loadData(blng__FinanceBook__c.sObjectType,
                                                        L2I_StaticConstants.unitTestStaticResource.get('FinanceBook_file'));
        System.assert(blng_financeBooks.size() > 0, 'There must be atleast one FinanceBook loaded');
        System.debug('Loaded blng__FinanceBooks');


        List<SObject> blng_billingRules = Test.loadData(blng__BillingRule__c.sObjectType,
                                                        L2I_StaticConstants.unitTestStaticResource.get('BillingRule_file'));
        System.assert(blng_billingRules.size() > 0, 'There must be atleast one BillingRule loaded');
        System.debug('Loaded blng__BillingRule');


        List<SObject> blng_taxRules = Test.loadData(blng__TaxRule__c.sObjectType,
                                                    L2I_StaticConstants.unitTestStaticResource.get('TaxRule_file'));
        System.assert(blng_taxRules.size() > 0, 'There must be atleast one TaxRule loaded');
        System.debug('Loaded blng__TaxRule');


        List<SObject> blng_revrecRules = Test.loadData(blng__RevenueRecognitionRule__c.sObjectType,
                                                       L2I_StaticConstants.unitTestStaticResource.get('RevenueRecognitionRule_file'));
        System.assert(blng_revrecRules.size() > 0, 'There must be atleast one RevenueRecognitionRule loaded');
        System.debug('Loaded blng__RevRecRules');


        List<SObject> blng_GLAccounts = Test.loadData(blng__GLAccount__c.sObjectType,
                                                      L2I_StaticConstants.unitTestStaticResource.get('GLAccount_file'));
        System.assert(blng_GLAccounts.size() > 0, 'There must be atleast one GLAccount loaded');
        System.debug('Loaded blng__GLAccounts');


        List<SObject> blng_GLTreatments = Test.loadData(blng__GLTreatment__c.sObjectType,
                                                        L2I_StaticConstants.unitTestStaticResource.get('GLTreatment_file'));
        System.assert(blng_GLTreatments.size() > 0, 'There must be atleast one GLTreatment loaded');
        System.debug('Loaded blng__GLTreatments');


        /**
        List<SObject> blng_financePeriods = Test.loadData(blng__FinancePeriod__c.sObjectType,
                                                          L2I_StaticConstants.unitTestStaticResource.get('FinancePeriod_file'));
        System.assert(blng_financePeriods.size() > 0, 'There must be atleast one FinancePeriod loaded');
        System.debug('Loaded blng__financePeriods');
        **/


        List<SObject> blng_billingTreatments = Test.loadData(blng__BillingTreatment__c.sObjectType,
                                                             L2I_StaticConstants.unitTestStaticResource.get('BillingTreatment_file'));
        System.assert(blng_billingTreatments.size() > 0, 'There must be atleast one BillingTreatment loaded');
        System.debug('Loaded blng__billingTreatment');


        List<SObject> products = Test.loadData(Product2.sObjectType,
                                               L2I_StaticConstants.unitTestStaticResource.get('Product2_file'));
        System.assert(products.size() > 0, 'There must be atleast one or more Products loaded');
        System.debug('Loaded Products');

        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        for (SObject prod : products) {
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                                    Product2Id = prod.Id,
                                                    UnitPrice = 1000,
                                                    IsActive = true);
            pbEntries.add(pbe);
        }
        insert pbEntries;

    }
}