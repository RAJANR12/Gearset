public  class ife_VerticalNavController {
    @AuraEnabled 
    public static Contact getSalesAccess(){
       
        User userObj =[SELECT Id ,Contact.IFE_Sales_Access__c, Contact.IFE_Document_Access__c, 
                            Contact.IFE_Maintenance_Access__c,
                            Contact.IFE_Repair_Access__c , Contact.IFE_B2B_Access__c     
                            FROM User WHERE Id=:UserInfo.getUserId()];
        System.debug('userObj>>>'+userObj);
        System.debug('contact>>>'+userObj.ContactId);
        if(userObj.ContactId != null){
            return userObj.Contact;
            
        }
        else{
            return null;
        }
    }
}