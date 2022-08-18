public with sharing class PT_ClearShipsetMRODDates {
    @InvocableMethod(Label = 'Clear Shipset MROD Dates')
    public static void clearShipsetMRODDates(List<Id> dslIds) {
        System.debug('*** Starting PT_ClearShipsetMRODDates.clearShipsetMRODDates' + dslIds);
        String dslId;
        Set<Id> installLocIds = new Set<Id>();
        List<Asset> assetUpdateList = new List<Asset>();
        List<PT_Install_Location__c> iLocUpdateList = new List<PT_Install_Location__c>();
        try {
            dslId = dslIds[0];
            // clear MROD Dates for the specified Shipset where the Asset has not been assigned to a Case
            // later it was decided not to restrict the clearing of MRODs for any reason
            for (Asset ast : [
                  SELECT Id, PT_Pending__c, PT_MROD__c, PT_Install_Location__c, PT_Install_Location__r.MROD__c,
                        PT_Case__c
                  FROM Asset
                  WHERE PT_Install_Location__r.ShipSet__c = :dslId
            ]) {
                if (ast.PT_Install_Location__r.MROD__c != null) {
                    installLocIds.add(ast.PT_Install_Location__c);
                }
                if (ast.PT_MROD__c != null) {
                    ast.PT_MROD__c = null;
                    assetUpdateList.add(ast);
                }
            }
    
            for (PT_Install_Location__c iLoc : [
                  SELECT Id, MROD__c, Allow_Past_Due_Pending_MROD_Date__c
                  FROM PT_Install_Location__c
                  WHERE Id IN :installLocIds
            ]) {
                System.debug('*** iLoc ' + iLoc);
                iLoc.MROD__c = null;
                iLoc.Allow_Past_Due_Pending_MROD_Date__c = false;    // to allow past due/null dates to process
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
            
            System.debug('*** Ending PT_ClearShipsetMRODDates.clearShipsetMRODDates ');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}