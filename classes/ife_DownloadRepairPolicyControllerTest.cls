@isTest
private class ife_DownloadRepairPolicyControllerTest {

    @isTest
    public static void getDocumentsTest(){
        ife_DownloadRepairPolicyController downloadRepairPolicy = new ife_DownloadRepairPolicyController();
        List<IFE_Document__c>  documents = ife_DownloadRepairPolicyController.getDocuments();
        System.assertNotEquals(null, documents);
    }
}