public class L2I_DebitNote_Creation_Controller {
    
    @AuraEnabled
    public static OrderWrapper getOrders(Id accId) {
        Set<String> products = L2I_JSON_Settings.getSpecificSettingCollection('Debit_Note_Settings','Products');
        OrderWrapper ow = new OrderWrapper();
        ow.orders = new List<OrderItem>([Select Id, OrderItemNumber, Order.Status, Order.OrderNumber, Product2Id, Product2.Name, Quantity, TotalPrice From OrderItem Where SBQQ__QuoteLine__r.SBQQ__ProductCode__c in :products and Order.AccountId =: accId Order by Order.OrderNumber]);
    	ow.pmTimeAmount = Decimal.valueOf(L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings','PM_Time_Amount'));
        ow.operTimeAmount = Decimal.valueOf(L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings','Operations_Time_Amount'));
        ow.equipTimeAmount = Decimal.valueOf(L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings','Equipment_Time_Amount'));
        ow.rackSetupFees = Decimal.valueOf(L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings','Rack_Setup_Fee'));
        return ow;
    }
    
    @AuraEnabled
    public static void createDebitNotesAndLines(List<OrderItem> orderItems, Id accId, Decimal pmTime, Decimal operationsTime, Decimal equipmentTime, Boolean rackSetupFee, String description) {
        System.debug('items: '+orderItems);
        Map<String, String> rates = L2I_JSON_Settings.getSettings('Debit_Note_Settings');
        String debitNotes = 'PM Time: ' +((pmTime != null) ? String.valueOf(pmTime): ' ')+ ' hours at $'+rates.get('PM_Time_Amount')+'/hour ; Operations Time: ' +((operationsTime != null) ? String.valueOf(operationsTime): ' ')+ ' hours at $'+rates.get('Operations_Time_Amount')+'/hour ; Equipment Time: ' +((equipmentTime != null) ? String.valueOf(equipmentTime): ' ')+ ' hours at $'+rates.get('Equipment_Time_Amount')+'/hour ; Rack Setup Fee: ' + (rackSetupFee != null && rackSetupFee ? 'Included at $'+rates.get('Rack_Setup_Fee') : 'Excluded');
        Decimal totalHours = ((pmTime != null) ? pmTime: 0)+((operationsTime != null) ? operationsTime: 0)+((equipmentTime != null) ? equipmentTime: 0);
        
        blng__DebitNote__c note = new blng__DebitNote__c(blng__DebitNoteDate__c = System.today(), blng__Account__c = accId, blng__Status__c = 'Draft', blng__Notes__c = debitNotes, L2I_Total_Hours__c = totalHours, L2I_Project_Description__c = description);
        
        Decimal pmAmount = (pmTime != null && L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings','PM_Time_Amount') != null) ? pmTime*Decimal.valueOf(L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings','PM_Time_Amount')) : null;
        Decimal operationsAmount = (operationsTime != null && L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings','Operations_Time_Amount') != null) ? operationsTime*Decimal.valueOf(L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings','Operations_Time_Amount')) : null;
        Decimal equipmentAmount = (equipmentTime != null && L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings','Equipment_Time_Amount') != null) ? equipmentTime*Decimal.valueOf(L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings','Equipment_Time_Amount')) : null;
        Decimal rackSetupFeeAmount = (rackSetupFee != null && rackSetupFee && L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings','Rack_Setup_Fee') != null) ? Decimal.valueOf(L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings','Rack_Setup_Fee')) : null;
        
        try {
            insert note;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        if(note != null && note.Id == null) {
            throw new AuraHandledException('Failed to insert Debit Note');
        }
        List<blng__DebitNoteLine__c> debitLines = new List<blng__DebitNoteLine__c>();
        for(OrderItem item: orderItems) {
            Decimal subTotal = ((pmAmount != null) ? pmAmount: 0)+((operationsAmount != null) ? operationsAmount: 0)+((equipmentAmount != null) ? equipmentAmount: 0)+((rackSetupFeeAmount != null) ? rackSetupFeeAmount: 0);
            blng__DebitNoteLine__c line = new blng__DebitNoteLine__c(blng__DebitNote__c = note.Id, L2I_OrderProduct__c = item.Id, blng__Product__c = item.Product2Id, blng__Subtotal__c = subTotal);
            debitLines.add(line);
        }
        try {
            insert debitLines;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class OrderWrapper {
        @AuraEnabled public List<OrderItem> orders;
        @AuraEnabled public Decimal pmTimeAmount;
        @AuraEnabled public Decimal operTimeAmount;
        @AuraEnabled public Decimal equipTimeAmount;
        @AuraEnabled public Decimal rackSetupFees;
    }
}