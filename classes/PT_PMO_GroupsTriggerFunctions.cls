/**
 *      @author       Sarah Kennedy
 *      @date         09/27/2020
 *      @description  Trigger Functions for PT_PMO_GroupsTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy               09/27/2020          Initial scaffold
 */
public with sharing class PT_PMO_GroupsTriggerFunctions {
    
    public static void addPPMRDToPPMRDQueues(List<PT_PMO_Groups__c> newPMO_GroupsList) {
        Set<Id> pmoGrpOwners = new Set<Id>();
        Set<Id> pmoSubGrpOwners = new Set<Id>();
        
        for (PT_PMO_Groups__c newPMOGrp : newPMO_GroupsList) {
            System.debug('*** newPMOGrp ' + newPMOGrp);
            if (newPMOGrp.Group_Type__c != null) {
                if (newPMOGrp.Group_Type__c == 'Group') {
                    pmoGrpOwners.add(newPMOGrp.OwnerId);
                }
                if (newPMOGrp.Group_Type__c == 'Sub Group') {
                    pmoSubGrpOwners.add(newPMOGrp.OwnerId);
                }
            }
        }
        System.debug('*** pmoGrpOwners ' + pmoGrpOwners);
        System.debug('*** pmoSubGrpOwners ' + pmoSubGrpOwners);
        
        Group grpPPM = [
              SELECT Id
              FROM Group
              WHERE Group.Name = 'Program PPM Group'
              AND Group.Type = 'Regular'
              LIMIT 1
        ];
        System.debug('*** grpPPM ' + grpPPM);
        Group grpRD = [
              SELECT Id
              FROM Group
              WHERE Group.Name = 'Program RD Group'
              AND Group.Type = 'Regular'
              LIMIT 1
        ];
        System.debug('*** grpRD ' + grpRD);
        if (grpPPM != null &&
              !pmoSubGrpOwners.isEmpty()) {
            // calling future method to avoid MIXED_DML_OPERATION (PT_PMO_Groups__c was inserted then inserting into GroupMember setup object)
            addMembersToQueue (pmoSubGrpOwners, grpPPM.Id, 'Sub Group');
        }
        if (grpRD != null &&
              !pmoGrpOwners.isEmpty()) {
            // calling future method to avoid MIXED_DML_OPERATION (PT_PMO_Groups__c was inserted then inserting into GroupMember setup object)
            addMembersToQueue (pmoGrpOwners, grpRD.Id, 'Group');
        }
    }
    
    @future
    private static void addMembersToQueue(Set<Id> pmoGrpOwners, Id grpId, String grpType) {
        System.debug('*** addtoqueue pmoGrpOwners ' + pmoGrpOwners);
        System.debug('*** grpId ' + grpId);
        System.debug('*** grpType ' + grpType);
        List<GroupMember> newGmList = new List<GroupMember>();
        for (User u : [
              SELECT Id, Name
              FROM User
              WHERE Id IN :pmoGrpOwners
              AND Id NOT IN (
                    SELECT UserOrGroupId
                    FROM GroupMember
                    WHERE Group.Id = :grpId
              )
        ]) {
            newGmList.add(new GroupMember(GroupId = grpId, UserOrGroupId = u.Id));
        }
        if (newGmList != null && newGmList.size() > 0) {
            insert newGmList;
        }
        System.debug('*** newGMList ' + newGmList);
    }
    
    public static void deletePPMRDFromPPMRDQueue(List<PT_PMO_Groups__c> oldPMO_GroupList) {
        Set<Id> pmoGrpOwnersToRemove = new Set<Id>();
        Set<Id> pmoSubGrpOwnersToRemove = new Set<Id>();
        Set<Id> pmoGrpDeleted = new Set<Id>();
        Set<Id> pmoSubGrpDeleted = new Set<Id>();
        
        for (PT_PMO_Groups__c oldPMOGrp : oldPMO_GroupList) {
            if (oldPMOGrp.Group_Type__c != null) {
                if (oldPMOGrp.Group_Type__c == 'Group') {
                    pmoGrpOwnersToRemove.add(oldPMOGrp.OwnerId);
                    pmoGrpDeleted.add(oldPMOGrp.Id);
                }
                if (oldPMOGrp.Group_Type__c == 'Sub Group') {
                    pmoSubGrpOwnersToRemove.add(oldPMOGrp.OwnerId);
                    pmoSubGrpDeleted.add(oldPMOGrp.Id);
                }
            }
        }
        
        Group grpPPM = [
              SELECT Id
              FROM Group
              WHERE Group.Name = 'Program PPM Group'
              AND Group.Type = 'Regular'
              LIMIT 1
        ];
        Group grpRD = [
              SELECT Id
              FROM Group
              WHERE Group.Name = 'Program RD Group'
              AND Group.Type = 'Regular'
              LIMIT 1
        ];
        
        if (grpPPM != null &&
              !pmoSubGrpOwnersToRemove.isEmpty()) {
            // calling future method to avoid MIXED_DML_OPERATION (PT_PMO_Groups__c was deleted then deleting into GroupMember setup object)
            deleteMembersFromQueue (pmoSubGrpOwnersToRemove, pmoSubGrpDeleted, grpPPM.Id, 'Sub Group');
        }
        if (grpRD != null &&
              !pmoGrpOwnersToRemove.isEmpty()) {
            // calling future method to avoid MIXED_DML_OPERATION (PT_PMO_Groups__c was deleted then deleting into GroupMember setup object)
            deleteMembersFromQueue (pmoGrpOwnersToRemove, pmoGrpDeleted, grpRD.Id, 'Group');
        }
    }
    
    @future
    private static void deleteMembersFromQueue(Set<Id> pmoOwnersToRemove, Set<Id> pgmGrpsDeleted, Id grpId, String grpType) {
        System.debug('*** deletegromqueue pmoOwnersToRemove ' + pmoOwnersToRemove);
        System.debug('*** pgmGrpsDeleted ' + pgmGrpsDeleted);
        System.debug('*** grpId ' + grpId);
        System.debug('*** grpType ' + grpType);
        List<GroupMember> deleteGmList = new List<GroupMember>();
        
        // if other PMO Groups have the Owner, don't delete from the queue
        for (PT_PMO_Groups__c pg : [
              SELECT Id, Name, OwnerId, Owner.Name
              FROM PT_PMO_Groups__c
              WHERE Id NOT IN :pgmGrpsDeleted
              AND Group_Type__c = :grpType
        ]) {
            if (pmoOwnersToRemove.contains(pg.OwnerID)) {
                System.debug('*** Cannot remove from queue - PMO ' + grpType + ' Owner ' + pg.Owner.Name + ' ' + pg.OwnerId + ' exists in another PMO ' + grpType + ' ' + pg.Name + ' ' + pg.Id);
                pmoOwnersToRemove.remove(pg.OwnerId);
            }
        }
        
        if (!pmoOwnersToRemove.isEmpty()) {
            for (GroupMember gm : [
                  SELECT Id
                  FROM GroupMember
                  WHERE Group.Id = :grpId
                  AND UserOrGroupId IN :pmoOwnersToRemove
            ]) {
                deleteGmList.add(gm);
            }
            if (deleteGmList != null && deleteGmList.size() > 0) {
                delete deleteGmList;
            }
        }
        System.debug('*** deleteGmList ' + grpType + ' ' + deleteGmList);
    }
    
    public static void changePPMRDFromPPMRDQueue(List<PT_PMO_Groups__c> newPMO_GroupList, Map<Id, PT_PMO_Groups__c> oldPMO_GroupMap) {
        System.debug('*** changePPMRDFromPPMRDQueue ' + newPMO_GroupList);
        System.debug('*** oldPMO_GroupMap ' + oldPMO_GroupMap);
        List<PT_PMO_Groups__c> deletePPMRDList = new List<PT_PMO_Groups__c>();
        List<PT_PMO_Groups__c> addPPMRDList = new List<PT_PMO_Groups__c>();
        
        for (PT_PMO_Groups__c newPMO_Grp : newPMO_GroupList) {
            PT_PMO_Groups__c oldPMO_Grp = oldPMO_GroupMap.get(newPMO_Grp.Id);
            
            if (newPMO_Grp.OwnerId != oldPMO_Grp.OwnerId) {
                deletePPMRDList.add(oldPMO_Grp);
                addPPMRDList.add(newPMO_Grp);
            }
        }
        if (deletePPMRDList.size() > 0) {
            deletePPMRDFromPPMRDQueue(deletePPMRDList);
        }
        if (addPPMRDList.size() > 0) {
            addPPMRDToPPMRDQueues(addPPMRDList);
        }
    }
    
    public static void changePMOOwnerChanged(List<PT_PMO_Groups__c> newPMO_GroupList, Map<Id, PT_PMO_Groups__c> oldPMO_GroupMap) {
        System.debug('*** changePMOOwnerChanged ' + newPMO_GroupList);
        Map<Id, PT_PMO_Groups__c> oldNewGroupMap = new Map<Id, PT_PMO_Groups__c>();
        Map<Id, PT_PMO_Groups__c> oldNewSubGroupMap = new Map<Id, PT_PMO_Groups__c>();
        List<PT_Program__c> pgmUpdateList = new List<PT_Program__c>();
        
        for (PT_PMO_Groups__c newPMO_Grp : newPMO_GroupList) {
            PT_PMO_Groups__c oldPMO_Grp = oldPMO_GroupMap.get(newPMO_Grp.Id);
            
            if (newPMO_Grp.OwnerId != oldPMO_Grp.OwnerId) {
                if (newPMO_Grp.Group_Type__c == 'Group') {
                    oldNewGroupMap.put(oldPMO_Grp.Id, newPMO_Grp);
                }
                if (newPMO_Grp.Group_Type__c == 'Sub Group') {
                    oldNewSubGroupMap.put(oldPMO_Grp.Id, newPMO_Grp);
                }
            }
        }
        if (!oldNewGroupMap.isEmpty()) {
            for (PT_Program__c pgm : [SELECT Id, PT_PMO_Group__c, PMO_Regional_Director__c FROM PT_Program__c WHERE PT_PMO_Group__c IN :oldNewGroupMap.keySet()]) {
                pgm.PMO_Regional_Director__c = oldNewGroupMap.get(pgm.PT_PMO_Group__c).OwnerId;
                pgmUpdateList.add(pgm);
                System.debug('*** pgm for Group ' + pgm);
            }
        }
        if (!oldNewSubGroupMap.isEmpty()) {
            for (PT_Program__c pgm : [SELECT Id, PT_PMO_SubGroup__c, Principal_Program_Manager__c FROM PT_Program__c WHERE PT_PMO_SubGroup__c IN :oldNewSubGroupMap.keySet()]) {
                pgm.Principal_Program_Manager__c = oldNewSubGroupMap.get(pgm.PT_PMO_SubGroup__c).OwnerId;
                pgmUpdateList.add(pgm);
                System.debug('*** pgm for SubGroup ' + pgm);
            }
        }
        
        if (pgmUpdateList != null &&
              pgmUpdateList.size() > 0) {
            update pgmUpdateList;
        }
    }
}