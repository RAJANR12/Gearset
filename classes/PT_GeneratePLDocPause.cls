/**
 * Created by kennesk on 2/23/2021.
 */


global without sharing class PT_GeneratePLDocPause {
    @InvocableMethod(label='Generate PL Doc Pause')
    global static void executePauseBeforeOrder(List<Id> oppIdParam) {
        
        Map<String, Object> params = new Map<String, Object>();
        Id oppId = oppIdParam[0];
        params.put('oppId', oppId);
        Flow.Interview.PT_Generate_PL_Document_Subflow myFlow
              = new Flow.Interview.PT_Generate_PL_Document_Subflow(params);
        myFlow.start();
    
    }
}