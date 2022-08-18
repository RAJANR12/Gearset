public class PT_DeleteAssetsFromCaseController {

    public PT_DeleteAssetsFromCaseController() {}
    
    public void deleteAssetsFromCase() {
        String caseId = Apexpages.currentPage().getParameters().get('caseId');
        String assetStr = Apexpages.currentPage().getParameters().get('id');
        System.debug('caseId: '+Apexpages.currentPage().getParameters());
        /*Case caseRec = [Select Id, Status From Case Where Id =: caseId];

        if(caseRec.Status == 'Ordered') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot delete Assets on an Ordered Case'));
            return;
        }*/

        Set<String> assetIds = new Set<String>(assetStr.split(','));
        List<Asset> assetsToDelete = new List<Asset>();
        for (String astId : assetIds) {
            assetsToDelete.add(new Asset (Id = astId));
        }

        try {
            delete assetsToDelete;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Selected parts have been successfully removed from the case.'));
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
        } catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); }
    }

}