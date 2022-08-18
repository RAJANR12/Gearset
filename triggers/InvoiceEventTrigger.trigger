trigger InvoiceEventTrigger on L2I_InvoiceEvent__e (after Insert) {
    System.debug('InvoiceEventTrigger firing');
}