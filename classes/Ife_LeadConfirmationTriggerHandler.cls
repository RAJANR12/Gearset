public  class Ife_LeadConfirmationTriggerHandler {
    public static void afterInsert(List<Ife_LeadConfirmation__c> leadConfirmations){
        List<Lead> leadList = new List<Lead>();
        for(Ife_LeadConfirmation__c lcObj : leadConfirmations){
            if(lcObj.Lead_Id__c != null){
                Lead leadObj = new Lead();
                leadObj.Id= lcObj.Lead_Id__c;
                leadObj.IFE_Email_Verified__c = true;
                leadList.add(leadObj);
            }

        }
        update leadList;

    }
}