public class PT_AssignAssetsToCaseController {
    public PT_AssignAssetsToCaseController() {

    }

    public void assignAssetsToCase() {
        String caseId = Apexpages.currentPage().getParameters().get('caseId');
        String assetStr = Apexpages.currentPage().getParameters().get('id');

        List<String> assetIds = assetStr.split(',');
        List<Asset> assetsToUpdate = new List<Asset>();
        for (String astId : assetIds) {
            assetsToUpdate.add(new Asset (Id = astId, PT_Case__c = caseId));
        }

        update assetsToUpdate;
    }
}