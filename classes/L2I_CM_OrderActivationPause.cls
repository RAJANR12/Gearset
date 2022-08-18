global without sharing class L2I_CM_OrderActivationPause {
    @InvocableMethod(label='Order Activation Pause')
    global static void executePauseBeforeOrder(List<Id> quoteIdParam) {
    
        Map<String, Object> params = new Map<String, Object>();
        Id quoteId = quoteIdParam[0];
        params.put('quoteId', quoteId);
        Flow.Interview.New_Create_Order_Pause myFlow
              = new Flow.Interview.New_Create_Order_Pause(params);
        myFlow.start();
    
    }
}