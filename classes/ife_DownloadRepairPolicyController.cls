public class ife_DownloadRepairPolicyController {
    public ife_DownloadRepairPolicyController() {

    }
    @AuraEnabled
	public static  List<IFE_Document__c> getDocuments(){
        List<IFE_Document__c>  documents =[SELECT Id, Name,Document_Type__c,File_Name__c,Folder_Version__c,Folder_Number__c FROM IFE_Document__c WHERE Document_Type__c = 'Repair'];
        return documents;
    }
    @AuraEnabled
	public static String urlDownloadDocument(String folderNumber, String folderVersion, String fileName){
		ife_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
		                                          FROM ife_Integration__mdt
		                                          WHERE MasterLabel = 'AgileDocument'
		                                          LIMIT 1];
		String url = integrationMdtObj.URL__c + 'agileDocument/' + folderNumber + ':' + folderVersion + ':' + fileName;
		return url;
	}
}