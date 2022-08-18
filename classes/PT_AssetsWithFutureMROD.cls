public class PT_AssetsWithFutureMROD {

    @InvocableMethod
    public static List<boolean> assetsWithFutureMROD (List<Requests> requests) {
        Boolean futureMRODAsset = false;
        List<Asset> assets = [SELECT Id FROM Asset
                                WHERE PT_Install_Location__r.ShipSet__c =: requests[0].dslId AND PT_MROD__c != null AND PT_MROD__c > Today LIMIT 1];
        if(assets.size() > 0) {
            futureMRODAsset = true;
        }
        return new List<Boolean>{futureMRODAsset};
    }

    public class Requests {
        @InvocableVariable
        public Id dslId;
    }
}