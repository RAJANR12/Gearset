public with sharing class PT_ClearPendingMRODDates {
    @InvocableMethod(Label = 'Clear Pending MROD Dates')
    public static void clearPendingMRODDates(List<Id> programIds) {
        System.debug('*** Starting PT_ProgramService.clearPendingMRODDates ' + programIds);
        String programId;
        Set<Id> installLocIds = new Set<Id>();
        List<Asset> assetUpdateList = new List<Asset>();
        List<PT_Install_Location__c> iLocUpdateList = new List<PT_Install_Location__c>();
        try {
            programId = programIds[0];
            
            for (Asset ast : [
                  SELECT Id, PT_Pending__c, PT_Install_Location__c, PT_Install_Location__r.Pending_MROD__c
                  FROM Asset
                  WHERE PT_Program__c = :programId
            ]) {
                System.debug('*** ast ' + ast);
                if (ast.PT_Install_Location__r.Pending_MROD__c != null) {
                    installLocIds.add(ast.PT_Install_Location__c);
                }
                if (ast.PT_Pending__c != null) {
                    ast.PT_Pending__c = null;
                    assetUpdateList.add(ast);
                }
            }
            for (PT_Install_Location__c iLoc : [
                  SELECT Id,Pending_MROD__c, Allow_Past_Due_Pending_MROD_Date__c
                  FROM PT_Install_Location__c
                  WHERE Id IN :installLocIds
            ]) {
                System.debug('*** iLoc ' + iLoc);
                iLoc.Pending_MROD__c = null;
                iLoc.Allow_Past_Due_Pending_MROD_Date__c = true;    // to allow past due/null dates to process
                iLocUpdateList.add(iLoc);
            }
            if (iLocUpdateList != null &&
                  iLocUpdateList.size() > 0) {
                update iLocUpdateList;
            }
            System.debug('*** iLocUpdateList.size() ' + iLocUpdateList.size());
    
            if (assetUpdateList != null &&
                  assetUpdateList.size() > 0) {
                update assetUpdateList;
            }
            System.debug('*** assetUpdateList.size() ' + assetUpdateList.size());
            
            // clear the allowed past due flag
            for (PT_Install_Location__c iLoc : iLocUpdateList){
                iLoc.Allow_Past_Due_Pending_MROD_Date__c = false;
            }
            if (iLocUpdateList != null &&
                  iLocUpdateList.size() > 0) {
                update iLocUpdateList;
            }
            System.debug('*** clear allowed past due flag iLocUpdateList.size() ' + iLocUpdateList.size());
            
            System.debug('*** Ending PT_ProgramService.clearPendingMRODDates ');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}