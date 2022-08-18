public class PT_PendingMRODChangesController {
    
    public ID ptProgramID { get; set; }
    public List<PT_MROD_Revision__c> mrodRevList {get; set;}
    public String mrodQuestions {get; set;}
    public String mrodSubmittedDate {get; set;}
	public String xlsHeader
    {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    
    public PT_PendingMRODChangesController(ApexPages.StandardController controller) {
        ptProgramID = ApexPages.currentPage().getParameters().get('Id');
        
        mrodRevList = [SELECT Id, Region__c, Sub_Group__c, Operator__c, Program_Manager__c, Program_Administrator__c, Program__r.Name,
                                                 Shipset_PPL__c, PPL_Type__c, Install_Location__r.Name, Part_Number__c, Description__c, Purchase_Qty__c, Orderable_Item__c, 
                                                 Current_MROD__c, Requested_MROD__c, Expedite__c, D1_Date__c, Name, Program__r.MROD_Latest_Approval_Questions__c,
                       							 Lead_Time__c, Lead_Time_Days__c, Default_Shipping_Org__c, MROD_FORECAST_DATE__c, Createddate, Extended_Price__c
                                                 FROM PT_MROD_Revision__c WHERE Program__c =: ptProgramID];// AND Status__c = 'Pending'];
        
        if(!mrodRevList.isEmpty()){
            mrodQuestions = mrodRevList[0].Program__r.MROD_Latest_Approval_Questions__c;
            DateTime dt = mrodRevList[0].Createddate;
            mrodSubmittedDate = dt.format('MMMMM dd, yyyy hh:mm:ss a');
        } else { mrodQuestions = ''; mrodSubmittedDate = '';}
        
        
    }    
    
}