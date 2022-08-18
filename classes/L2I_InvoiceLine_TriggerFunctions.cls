/**
 *      @author       Sarah Kennedy
 *      @date         02/09/2021
 *      @description  Trigger on the Invoice Line object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                  02/09/2021           Initial scaffold
 */
public without sharing class L2I_InvoiceLine_TriggerFunctions {
    public static void updateInvoiceFromCase(List<blng__InvoiceLine__c> newInvoiceLineList) {
        Set<Id> invoiceIds = new Set<Id>();
        Set<Id> invoiceIdsInList = new Set<Id>();
        List<blng__Invoice__c> invoiceToUpdateList = new List<blng__Invoice__c>();
        
        for (blng__InvoiceLine__c iLine : newInvoiceLineList) {
            invoiceIds.add(iLine.blng__Invoice__c);
        }
        
        for (blng__InvoiceLine__c iLinePlus : [
              SELECT Id, Name, blng__Invoice__c,
                    blng__OrderProduct__c,
                    blng__OrderProduct__r.OrderId,
                    blng__OrderProduct__r.Order.PT_Case__r.PT_PO_Number__c,
                    blng__OrderProduct__r.Order.PT_Case__r.PT_PO_Received_Date__c,
                    blng__OrderProduct__r.Order.PT_Case__r.PT_Freight_Terms__c,
                    blng__OrderProduct__r.Order.PT_Case__r.PT_Ship_to_Customer__c,
                    blng__OrderProduct__r.Order.PT_Case__r.PT_Ship_to_Location__c,
                    blng__OrderProduct__r.Order.PT_Case__r.PT_Shipping_Method__c,
                    blng__OrderProduct__r.Order.PT_Case__r.PT_Packing_Instructions__c,
                    blng__OrderProduct__r.Order.PT_Case__r.PT_Ship_to_Contact__c,
                    blng__OrderProduct__r.Order.PT_Case__r.PT_Shipping_Instructions__c,
                    blng__OrderProduct__r.Order.PT_Case__r.PT_Purpose__c,
                    blng__OrderProduct__r.Order.PT_Case__r.PT_CR_Number__c,
                    blng__OrderProduct__r.Order.PT_Case__r.PT_Comments__c,
                    blng__OrderProduct__r.Order.PT_Case__r.L2I_End_User_Location__c,
                    blng__OrderProduct__r.Order.PT_Case__r.L2I_Product_Category_2__c,
                    blng__OrderProduct__r.Order.L2I_Product_Category_2__c
              FROM blng__InvoiceLine__c
              WHERE blng__Invoice__c IN :invoiceIds
        ]) {
            // an Invoice can have multiple lines. Each line would retrieve the same Cases data to update the Invoice
            // So don't add multiple invoices to the list to be updated
            if (!invoiceIdsInList.contains(iLinePlus.blng__Invoice__c)) {
                invoiceIdsInList.add(iLinePlus.blng__Invoice__c);
                blng__Invoice__c inv = new blng__Invoice__c();
                inv.Id = iLinePlus.blng__Invoice__c;
                inv.PT_PO_Number__c = iLinePlus.blng__OrderProduct__r.Order.PT_Case__r.PT_PO_Number__c;
                inv.PT_PO_Received_Date__c = iLinePlus.blng__OrderProduct__r.Order.PT_Case__r.PT_PO_Received_Date__c;
                inv.PT_Freight_Terms__c = iLinePlus.blng__OrderProduct__r.Order.PT_Case__r.PT_Freight_Terms__c;
                inv.PT_Ship_to_Customer__c = iLinePlus.blng__OrderProduct__r.Order.PT_Case__r.PT_Ship_to_Customer__c;
                inv.PT_Ship_to_Location__c = iLinePlus.blng__OrderProduct__r.Order.PT_Case__r.PT_Ship_to_Location__c;
                inv.PT_Shipping_Method__c = iLinePlus.blng__OrderProduct__r.Order.PT_Case__r.PT_Shipping_Method__c;
                inv.PT_Packing_Instructions__c = iLinePlus.blng__OrderProduct__r.Order.PT_Case__r.PT_Packing_Instructions__c;
                inv.PT_Ship_to_Contact__c = iLinePlus.blng__OrderProduct__r.Order.PT_Case__r.PT_Ship_to_Contact__c;
                inv.PT_Shipping_Instructions__c = iLinePlus.blng__OrderProduct__r.Order.PT_Case__r.PT_Shipping_Instructions__c;
                inv.PT_Purpose__c = iLinePlus.blng__OrderProduct__r.Order.PT_Case__r.PT_Purpose__c;
                inv.PT_CR_Number__c = iLinePlus.blng__OrderProduct__r.Order.PT_Case__r.PT_CR_Number__c;
                inv.PT_Comments__c = iLinePlus.blng__OrderProduct__r.Order.PT_Case__r.PT_Comments__c;
                inv.L2I_End_User_Location__c = iLinePlus.blng__OrderProduct__r.Order.PT_Case__r.L2I_End_User_Location__c;
//                inv.L2I_Product_Category_2__c = iLinePlus.blng__OrderProduct__r.Order.PT_Case__r.L2I_Product_Category_2__c;
                inv.L2I_Product_Category_2__c = iLinePlus.blng__OrderProduct__r.Order.L2I_Product_Category_2__c;
                inv.blng__Order__c = iLinePlus.blng__OrderProduct__r.OrderId;
                inv.PT_Updates_from_Case_Complete__c = true;
//                inv.L2I_IntegrationStatus__c = 'Ready to Integrate';
                invoiceToUpdateList.add(inv);
            }
        }
        if (!invoiceToUpdateList.isEmpty() &&
              invoiceToUpdateList.size() > 0) {
            update invoiceToUpdateList;
        }
    }
}