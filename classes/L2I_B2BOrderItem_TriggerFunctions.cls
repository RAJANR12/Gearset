public without sharing class L2I_B2BOrderItem_TriggerFunctions {
    public static void setCCCFieldsBeforeInsert(List<ccrz__E_OrderItem__c> newB2BOrderItemList){
        //B2B_Account_CCC_Code__c = 'TEST-BI';
        System.debug('====== executing L2I_B2BOrderItem_TriggerFunctions :: setCCCFieldsBeforeInsert');
        for (ccrz__E_OrderItem__c b2bOrderItem : newB2BOrderItemList)
        b2bOrderItem.B2B_Account_CCC_Code__c= 'TEST-BI';
    }
    
    
   /* public static void setCCCFieldsAfterInsert(List<ccrz__E_OrderItem__c> newB2BOrderItemList){
        //B2B_Account_CCC_Code__c = 'TEST-BI';
        System.debug('====== executing L2I_B2BOrderItem_TriggerFunctions :: setCCCFieldsAfterInsert');
    }*/
}