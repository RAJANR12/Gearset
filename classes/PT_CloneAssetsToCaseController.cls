public class PT_CloneAssetsToCaseController {
    public PT_CloneAssetsToCaseController() {

    }

    public void cloneAssetsToCase() {
        String caseId = Apexpages.currentPage().getParameters().get('caseId');
        String assetStr = Apexpages.currentPage().getParameters().get('id');

        Case caseRec = [Select Id, OwnerId, PT_Ship_to_Customer__c, PT_Order_Type_Context__c From Case Where Id =: caseId];
        List<String> assetIds = assetStr.split(',');
        List<Asset> newAssets = new List<Asset>();
        String assetQuery = generateQuery('Asset');
        assetQuery += ' Where Id IN :assetIds';
        //List<Asset> assets = Database.query(assetQuery);
        //System.debug(assets);
        
        for(Asset asset: Database.query(assetQuery)) {
            Asset clonedAsset = asset.clone(false, true, false, false);
            clonedAsset.PT_Case__c = caseId;
            clonedAsset.ParentId = asset.Id;
            clonedAsset.OwnerId = caseRec.OwnerId;
            clonedAsset.PT_Case_Ship_to_Customer__c = caseRec.PT_Ship_to_Customer__c;
            clonedAsset.PT_Order_Type_Context__c = caseRec.PT_Order_Type_Context__c;
            if(clonedAsset.PT_Order_Type_Context__c == 'Eval/Loan Order') {
                clonedAsset.PT_Line_Type__c = 'Eval/Loan Line';
            } else if(clonedAsset.PT_Order_Type_Context__c == 'Invoice Only Order') {
                clonedAsset.PT_Line_Type__c = 'Invoice Only Line';
            } else if(clonedAsset.PT_Order_Type_Context__c == 'NRE Service') {
                clonedAsset.PT_Line_Type__c = 'Invoice Only Line';
            } else if(clonedAsset.PT_Order_Type_Context__c == 'Irvine Direct - S/W') {
                clonedAsset.PT_Line_Type__c = 'Standard Sales Order Line';
            } else if(clonedAsset.PT_Order_Type_Context__c == 'MILESTONE') {
                clonedAsset.PT_Line_Type__c = 'Standard Sales Order Line';
            } else if(clonedAsset.PT_Order_Type_Context__c == 'Standard Stock Order') {
                    clonedAsset.PT_Line_Type__c = 'Standard Sales Order Line';
            } else {
                clonedAsset.PT_Line_Type__c = '';
            }
            newAssets.add(clonedAsset);
        }
        
        /*for (String astId : assetIds) {
            assetsToUpdate.add(new Asset (Id = astId, PT_Case__c = caseId));
        }

        update assetsToUpdate;*/
        insert newAssets;
    }
    
    private String generateQuery(String objApiName) {
        Map<String, Schema.SObjectField> quoteFieldsMap = Schema.getGlobalDescribe().get(objApiName).getDescribe().fields.getMap();
        String query = 'Select ';
        for(String str: quoteFieldsMap.keyset()) {
            query += str+',';
        }
        query = query.substring(0, query.length()-1);
        query += ' From '+objApiName;
        return query;
    }
}