public without sharing class PT_MRODDatesController {
    @AuraEnabled
    public static DateWrapper updateMRODDates(String idString, String obj, Date mrodPendDate) {
        System.debug('*** updateMRODDates idString ' + idString);
        System.debug('*** updateMRODDates obj ' + obj);
        System.debug('*** updateMRODDates mrodPendDate ' + mrodPendDate);
        List<PT_Install_Location__c> installLocList = new List<PT_Install_Location__c>();
        List<Asset> assetList = new List<Asset>();
        DateWrapper dw = new DateWrapper();
        dw.errMsg = '';
        List<String> idList = idString.split(',');
        try {
            if (obj == 'IL') {
                installLocList = [SELECT Id, MROD__c, Pending_MROD__c,
                      (SELECT Id, PT_MROD__c, PT_Pending__c FROM Assets__r)
                      FROM PT_Install_Location__c WHERE Id IN :idList];
                for (PT_Install_Location__c iloc : installLocList) {
                    iloc.Pending_MROD__c = mrodPendDate;
                    for (Asset ast : iloc.Assets__r){
                        if (ast.PT_MROD__c == null ||
                              ast.PT_MROD__c == iloc.MROD__c){
                            ast.PT_Pending__c = mrodPendDate;
                            assetList.add(ast);
                        }
                    }
                }
                System.debug('*** installLocList ' + installLocList);
                System.debug('*** assetList.size() ' + assetList.size());
                System.debug('*** assetList ' + assetList);
                if (installLocList.size() > 0){
                    update installLocList;
                }
                if (assetList.size() > 0){
                    update assetList;
                }
            
            }
//            else if (obj == 'Asset') {
//                assetList = [SELECT Id, PT_MROD__c, PT_Pending__c FROM Asset WHERE Id IN :idList];
//                for (Asset partAsset : assetList) {
//                    partAsset.PT_Pending__c = mrodPendDate;
//                }
//                System.debug('*** assetList ' + assetList);
//                update assetList;
//            }
        } catch (AuraHandledException ex) {
            dw.errMsg = ex.getMessage();
        }
        return dw;
    }
    
    public class DateWrapper {
        @AuraEnabled public String errMsg { get; set; }
        
        public DateWrapper() {
        }
    }
}