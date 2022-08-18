/**
 *      @author       Sarah Kennedy
 *      @date         02/18/2020
 *      @description  Controller class to support management of IFEC Schedules related to Service Schedules
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 01/18/2020         Initial creation
 *
 */
public with sharing class L2I_ManageRelatedSchedController {

    @AuraEnabled
    public static List<IFECWrap> getIFECSchedules(String oppId, String sortFilter, String sortedBy, String sortDirection) {
        System.debug('*** oppId ' + oppId);
        List<IFECWrap> ifecWList = new List<IFECWrap>();
        IFECWrap ifecW;
        Map<String, List<L2I_DSL__c>> dshDSLIFECMap = new Map<String, List<L2I_DSL__c>>();
        // get Service Schdule Account
        Opportunity oppAcct = [
              SELECT
                    Id,
                    Name,
                    AccountId
              FROM Opportunity
              WHERE Id = :oppId
        ];
        System.debug('*** oppAcct ' + oppAcct);
        // find all IFEC Schedules under the same Account
        for (Opportunity oppty : [
              SELECT
                    Id,
                    Name,
                    Account.Name,
                    RecordType.DeveloperName,
                    L2I_Delivery_Schedule__c,
                    L2I_Delivery_Schedule__r.Name,
                    L2I_Delivery_Schedule__r.Line_Count__c,
                    L2I_Aircraft_Type__r.Name,
                    L2I_AircraftQuantity__c,
                    L2I_Parent_Opportunity__r.Name
              FROM Opportunity
              WHERE AccountId = :oppAcct.AccountId
              AND L2I_Product_Category__c = 'IFEC'
              AND L2I_Delivery_Schedule__c <> null
              ORDER BY Name
        ]) {
            ifecW = new IFECWrap();
            ifecW.keyId = oppty.L2I_Delivery_Schedule__c;
            ifecW.oppDesc = oppty.Name;
//            ifecW.oppDescLink = '/' + oppty.Id;
            ifecW.oppDescLink = oppty.Id;
            ifecW.oppAircraftQty = oppty.L2I_AircraftQuantity__c;
            ifecW.ifecName = oppty.L2I_Delivery_Schedule__r.Name;
            ifecW.ifecLineCount = oppty.L2I_Delivery_Schedule__r.Line_Count__c;
            ifecW.oppAircraftType = oppty.L2I_Aircraft_Type__r.Name;
            ifecW.accountName = oppty.Account.Name;
            ifecW.parentOppName = oppty.L2I_Parent_Opportunity__r.Name;
//            ifecW.parentOppNameLink = '/' + oppty.L2I_Parent_Opportunity__c;
            ifecW.parentOppNameLink = oppty.L2I_Parent_Opportunity__c;
            System.debug('*** ifecW ' + ifecW);
            ifecWList.add(ifecW);
        }
        return ifecWList;
    }

    @AuraEnabled
    public static Integer addScheduleLines(String oppId, String dshIFECId) {
        Set<Id> ifecIds = new Set<Id>();
        List<L2I_DSL__c> dslAddList = new List<L2I_DSL__c>();
        L2I_DSL__c dslAdd;
        Integer highLineNumber = 0;
        Id dshId;
        // get the DSH from the Opportunity
        Opportunity oppty = [
              SELECT
                    Id,
                    Name,
                    L2I_Delivery_Schedule__c
              FROM Opportunity
              WHERE Id = :oppId
        ];
        dshId = oppty.L2I_Delivery_Schedule__c;
        System.debug('*** dshId ' + dshId);
        System.debug('*** dshIFECId ' + dshIFECId);
        // get the DSLs for the Service Schedule
        for (L2I_DSL__c dsl : [
              SELECT
                    Id,
                    Name,
                    Line_Number__c,
                    IFEC_DSL__c
              FROM L2I_DSL__c
              WHERE Delivery_Schedule_Header__c = :dshId
        ]) {
            System.debug('*** dsl ' + dsl);
            if (dsl.IFEC_DSL__c != null) {
                ifecIds.add(dsl.IFEC_DSL__c);
            }
            if (dsl.Line_Number__c.isNumeric()) {
                if (Integer.valueOf(dsl.Line_Number__c) > highLineNumber) {
                    highLineNumber = Integer.valueOf(dsl.Line_Number__c);
                }
            }
        }

        System.debug('*** ifecIds existing in dsh ' + ifecIds);
        // find the IFEC DSLs that are not already on the Service Delivery Schedule
        for (L2I_DSL__c dslIFEC : [
              SELECT
                    Id,
                    Name,
                    Delivery_Schedule_Header__c
              FROM L2I_DSL__c
              WHERE Delivery_Schedule_Header__c = :dshIFECId
              AND Id NOT IN :ifecIds
        ]) {
            System.debug('*** dslIFEC ' + dslIFEC);
            String currentLineNumber = String.valueOf(highLineNumber);
            dslAdd = new L2I_DSL__c();
            dslAdd.Delivery_Schedule_Header__c = dshId;
            dslAdd.IFEC_DSL__c = dslIFEC.Id;
            dslAdd.Status__c = '';
            dslAdd.Original_Opportunity__c = oppId;
            dslAdd.Line_Number__c = highLineNumber + 1 < 10 ? '0' + String.valueOf(highLineNumber + 1) : String.valueOf(highLineNumber + 1);
            dslAdd.PT_Line_Number__c = PT_Program_Utils.characterSequencer(currentLineNumber);
            highLineNumber++;
            dslAddList.add(dslAdd);
        }
        insert dslAddList;
        Set<String> excludeStatuses =
              L2I_JSON_Settings.getSpecificSettingCollection('Delivery_Schedule_Settings',
                    'Exclude_Statuses');
        return [
              SELECT COUNT()
              FROM L2I_DSL__c
              WHERE Delivery_Schedule_Header__c = :dshId
              AND Status__c NOT IN :excludeStatuses
              AND ((Original_Opportunity__r.StageName IN ('Pending Close', 'Closed Won', 'Closed')
              AND Original_Opportunity__r.SBQQ__PrimaryQuote__c <> null
              AND Original_Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c = true)
              OR (Original_Opportunity__r.StageName NOT IN ('Pending Close', 'Closed Won', 'Cancelled', 'No Bid', 'Closed Lost', 'Closed')))
        ];
    }

    public class IFECWrap {
        @AuraEnabled public String keyId { get; set; }
        @AuraEnabled public String oppDesc { get; set; }
        @AuraEnabled public Decimal oppAircraftQty { get; set; }
        @AuraEnabled public String ifecName { get; set; }
        @AuraEnabled public String oppDescLink { get; set; }
        @AuraEnabled public Decimal ifecLineCount { get; set; }
        @AuraEnabled public String oppAircraftType { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public String parentOppName { get; set; }
        @AuraEnabled public String parentOppNameLink { get; set; }
        @AuraEnabled public String linkOpp { get; set; }
        @AuraEnabled public String linkParent { get; set; }

        public IFECWrap() {
            this.linkOpp = 'link';
            this.linkParent = 'link';
        }
    }
}