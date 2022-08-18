/**
 *      @author       Raj Rajen
 *      @date         08/01/2019
 *      @description  L2I Quote Trigger Functions
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/01/2019         Initial scaffold
 *
 */
public without sharing class L2I_Aircraft_TriggerFunctions {

    public static void checkBeforeDelete(List<L2I_Aircraft__c> oldAircraftList, Map<Id, L2I_Aircraft__c> oldAircraftMap) {
        Id userProfileId = UserInfo.getProfileId();
        Id userId = UserInfo.getUserId();

        String userProfileName = [SELECT Id, Name from Profile Where Id =: userProfileId].Name;
        System.debug('====== Running user profile name :' + userProfileName);

        Boolean userIsAircraftDataSteward = L2I_StaticConstants.isUserAssignedToPermissionSet('Aircraft_Data_Steward', userId);
        // Only System Administrators are allowed to delete Aircrafts
        if (userProfileName == 'System Administrator' || userProfileName == 'PAC System Administrator' || userIsAircraftDataSteward) {
            // Even if the running user is in the allowed profiles. Aircrafts can only be deleted
            // if there no usages of the Aircraft
            Set<Id> affectedAircrafts = new Set<Id>();
            for (L2I_Aircraft__c ac : oldAircraftList) {
                affectedAircrafts.add(ac.Id);
            }

            
            Map<Id, L2I_Aircraft_Service__c> asLookup = new Map<Id, L2I_Aircraft_Service__c>([select Id,
                                                                                                     Name,
                                                                                                     Aircraft__c
                                                                                                from L2I_Aircraft_Service__c
                                                                                               where Aircraft__c in :affectedAircrafts]);

            Map<Id, Integer> inUseAircraftLookup = new Map<Id, Integer>();
            for (L2I_Aircraft_Service__c asvc : asLookup.values()) {
                Id aircraftId = asvc.Aircraft__c;
                if (inUseAircraftLookup.containsKey(aircraftId)) {
                    Integer count = inUseAircraftLookup.get(aircraftId);
                    count = count + 1;
                    inUseAircraftLookup.put(aircraftId, count);
                } else {
                    Integer count = 1;
                    inUseAircraftLookup.put(aircraftId, count);
                }
            }

            for (L2I_Aircraft__c ac : oldAircraftList) {
                if (inUseAircraftLookup.containsKey(ac.Id)) {
                    ac.addError('In-use Aircraft records cannot be deleted');
                }
            }



        } else {
            for (L2I_Aircraft__c ac : oldAircraftList) {
                ac.addError('Unauthorized Attempt to delete. Aircraft records can only be deleted by Administrators ');
            }
        }
    }

}