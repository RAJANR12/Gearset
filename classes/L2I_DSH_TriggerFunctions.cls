/**
 *      @author       Raj Rajen
 *      @date         08/26/2019
 *      @description  L2I DSH Trigger Functions
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/26/2019         Initial scaffold
 *      Sarah Kennedy                 03/02/2020         Added validateDelete method
 *      Sarah Kennedy                 03/04/2020         Removed updateDSLserviceMonths class (US1376)
 *      Sarah Kennedy                 06/16/2020         Release 4 Sprint 1 - moved preventEditOnOppClosed,  functionality to Delivery Sched UI as Current Opp is needed
 *
 */
public without sharing class L2I_DSH_TriggerFunctions {
    
    public static void validateDelete(Map<Id, L2I_DSH__c> oldDSHMap) {
        System.debug('====== DSH TriggerFunction validateDelete ');
        // Delivery Schedule should not be removable for a non-ordered opportunity in Stage = Pending Close / Closed Won / Closed Lost
        Set<String> errorIds = new Set<String>();
        Set<String> errorIdsAmendRenew = new Set<String>();
        for (Opportunity oppty : [
              SELECT Id,
                    RecordType.DeveloperName,
                    StageName,
                    L2I_Delivery_Schedule__c, (
                    SELECT ID, SBQQ__Ordered__c, SBQQ__Primary__c
                    FROM SBQQ__Quotes2__r
                    WHERE SBQQ__Primary__c = true
                    AND SBQQ__Ordered__c = true
              )
              FROM Opportunity
              WHERE L2I_Delivery_Schedule__c IN :oldDSHMap.keySet()
              AND RecordType.DeveloperName IN ('Sales', 'Amendment', 'Renewal')
        ]) {
            System.debug('*** oppty ' + oppty);
            if (oppty.StageName == 'Pending Close' ||
                  oppty.StageName == 'Closed Won' ||
                  oppty.StageName == 'Closed Lost' ||
                  oppty.SBQQ__Quotes2__r.size() != 0) {
                System.debug('*** error' + oppty.SBQQ__Quotes2__r.size());
                errorIds.add(oppty.L2I_Delivery_Schedule__c);
            } else {
                if (oppty.RecordType.DeveloperName == 'Amendment') {
                    errorIdsAmendRenew.add(oppty.L2I_Delivery_Schedule__c);
                }
            }
        }
        for (L2I_DSH__c dsh : oldDSHMap.values()) {
            if (errorIds.contains(dsh.Id)) {
                System.debug('*** added error');
                dsh.addError('This Delivery Schedule for an Opportunity that is Closed, Pending Close, Ordered or a Canceled Opportunity may not be deleted');
            } else {
                if (errorIdsAmendRenew.contains(dsh.Id)) {
                    System.debug('*** added error');
                    dsh.addError('This Delivery Schedule for a Canceled Opportunity may not be deleted');
                }
            }
        }
    }
}