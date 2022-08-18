public with sharing class PT_ValidateUserPMOUser {
    @InvocableMethod(Label = 'Validate PMO User')
    public static List<Boolean> validatePMOUser() {
        System.debug('*** Starting PT_ProgramService.validatePMOUser ');
        Set<Id> psetIds = new Set<Id>();
        for (PermissionSet pset : [
              SELECT Id
              FROM PermissionSet
              WHERE Name IN ('PAC_PMO_Standard', 'PAC_PMO_Admin')
        ]) {
            psetIds.add(pset.Id);
        }
        
        Integer pCount = [
              SELECT COUNT()
              FROM PermissionSetAssignment
              WHERE AssigneeId = :UserInfo.getUserId()
              AND PermissionSetId IN :psetIds
        ];
        System.debug('*** pCount ' + pCount);
        Boolean validUser = false;
        if (pCount > 0){
            validUser = true;
        }
        System.debug('*** Ending PT_ProgramService.validatePMOUser ' + validUser);
        return new List<Boolean>{validUser};
    }
}