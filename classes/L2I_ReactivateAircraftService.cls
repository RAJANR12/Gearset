// Removed the following field Subscription__c online 12,21,50,58,70

public class L2I_ReactivateAircraftService {
    
    //Send back a string with a message instead of a boolean
    @AuraEnabled
    public static String getAircraftServiceRecords(Id recordId) {
        
        String result = '';
        L2I_Aircraft_Service__c asRecord = new L2I_Aircraft_Service__c();
        
        asRecord = [SELECT Id, Status__c, L2I_Deactivation_Date__c, Aircraft__c, Order_Product__c,
                    L2I_Activation_Date__c, Matching_Id__c
                    FROM L2I_Aircraft_Service__c 
                    WHERE Id = :recordId];
        
        // Separate function and run this method again before the insert.
        if(asRecord.Status__c == 'Deactivated' && asRecord.L2I_Deactivation_Date__c != null) {

            List<L2I_Aircraft_Service__c> asRecords = new List<L2I_Aircraft_Service__c>();
            asRecords = [SELECT Id, Status__c, L2I_Deactivation_Date__c, Aircraft__c, Order_Product__c,
                         L2I_Activation_Date__c, Matching_Id__c
                         FROM L2I_Aircraft_Service__c 
                         WHERE Aircraft__c = :asRecord.Aircraft__c 
                         AND Matching_Id__c = :asRecord.Matching_Id__c
                         AND (Status__c = 'Pending Activation' OR Status__c = 'Activated')];
            
            if(asRecords.size() == 0) {
                result = 'Success';
            } else {
                System.debug('asRecords: ' + asRecords[0].Id);
                result = 'There is an existing record with the same Billing Matching Id with a Status of Pending Activation or Activated.';
            }
            
        } else {
            result = 'This record\'s Status is not Deactivated or the Deactivation Date is missing.';
        }
        
        System.debug('result: ' + result);
        return result;
        
    }
    
    @AuraEnabled
    public static String activateServiceRecord(Id recordId, Date activationDate) {
        
        String result = '';
        L2I_Aircraft_Service__c asRecord = new L2I_Aircraft_Service__c();
        
        asRecord = [SELECT Id, Status__c, L2I_Deactivation_Date__c, Aircraft__c, Order_Product__c,
                    L2I_Activation_Date__c, Matching_Id__c, Product2__c
                    FROM L2I_Aircraft_Service__c 
                    WHERE Id = :recordId];
        
        if(asRecord.Status__c == 'Deactivated' && asRecord.L2I_Deactivation_Date__c != null) {
            
            List<L2I_Aircraft_Service__c> asRecords = new List<L2I_Aircraft_Service__c>();
            asRecords = [SELECT Id, Status__c, L2I_Deactivation_Date__c, Aircraft__c, Order_Product__c,
                         L2I_Activation_Date__c, Matching_Id__c
                         FROM L2I_Aircraft_Service__c 
                         WHERE Aircraft__c = :asRecord.Aircraft__c 
                         AND Matching_Id__c = :asRecord.Matching_Id__c
                         AND (Status__c = 'Pending Activation' OR Status__c = 'Activated')];
            
            if(asRecords.size() == 0) {
                
                L2I_Aircraft_Service__c newAsRecord = new L2I_Aircraft_Service__c(
                    Aircraft__c = asRecord.Aircraft__c,
                    Matching_Id__c = asRecord.Matching_Id__c,
                    //Aircraft_Order__c = asRecord.Aircraft_Order__c,
                    Order_Product__c = asRecord.Order_Product__c,
                    //Subscription__c = asRecord.Subscription__c,
                    L2I_Activation_Date__c = activationDate,
                    Product2__c = asRecord.Product2__c
                );
                
                try {
                    
                    insert newAsRecord;
                    result = newAsRecord.Id;
                    
                } catch(DmlException e) {
                    
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        System.debug('error: ' + e.getDmlMessage(i));
                        result = e.getDmlMessage(i);
                    }
                    
                }
                
            } else {
                System.debug('asRecords: ' + asRecords[0].Id);
                result = 'There is an existing record with the same Billing Matching Id with a Status of Pending Activation or Activated.';
            }
            
        }
        
        System.debug('result: ' + result);
        return result;
        
    }
    
    
}