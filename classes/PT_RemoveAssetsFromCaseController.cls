public class PT_RemoveAssetsFromCaseController {
    public PT_RemoveAssetsFromCaseController() {

    }

    public void removeAssetsFromCase() {
        String assetStr = Apexpages.currentPage().getParameters().get('id');

        List<String> assetIds = assetStr.split(',');
        List<Asset> assetsToUpdate = new List<Asset>();
        for (String astId : assetIds) {
            assetsToUpdate.add(new Asset (Id = astId, PT_Case__c = null));
        }

        update assetsToUpdate;
    }
}