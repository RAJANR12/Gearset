public class PT_Quote_TriggerFunctions {
    public static void createUpdateDSLs(List<SBQQ__Quote__c> newQuoteList, Map<Id, SBQQ__Quote__c> oldQuoteMap) {
        List<SyncQuoteLinePriceListEntry__e> addEvents = new List<SyncQuoteLinePriceListEntry__e>();
        Set<Id> quoteIds = new Set<Id>();
        for (SBQQ__Quote__c quote : newQuoteList) {
            if (quote.SBQQ__Primary__c && oldQuoteMap.get(quote.Id).ApprovalStatus__c != 'Approved' && quote.ApprovalStatus__c == 'Approved') {
                quoteIds.add(quote.Id);
            }
        }
        if (quoteIds.size() > 0) {
            for (SBQQ__Quote__c quote : [
                    SELECT Id, SBQQ__Opportunity2__r.StageName, SBQQ__Opportunity2__r.PT_Price_List__c, SBQQ__Opportunity2__r.PT_Is_CPL__c, ApprovalStatus__c, SBQQ__Primary__c
                    FROM SBQQ__Quote__c
                    WHERE Id IN :quoteIds]) {
                if (quote.SBQQ__Opportunity2__r.StageName == 'Delivery' && quote.SBQQ__Primary__c &&
                    oldQuoteMap.get(quote.Id).ApprovalStatus__c != 'Approved' && quote.ApprovalStatus__c == 'Approved' ) {
                    //Sync Price from Quote Lines to Opportunity Assets
                    PT_PartList_Utils.syncPriceFromQuoteLinesToAssets(quote.Id);
                    //If CPL, Sync Price from Quote Lines to DSL Assets
                    if (quote.SBQQ__Opportunity2__r.PT_Is_CPL__c) {
                        PT_PartList_Utils.syncPriceFromQuoteLinesToDSLAssets(quote.Id);
                    }
                }
                if (quote.SBQQ__Opportunity2__r.PT_Price_List__c != null && quote.SBQQ__Primary__c &&
                    oldQuoteMap.get(quote.Id).ApprovalStatus__c != 'Approved' && quote.ApprovalStatus__c == 'Approved') {
                    SyncQuoteLinePriceListEntry__e event = new SyncQuoteLinePriceListEntry__e();
                    event.QuoteId__c = quote.Id;
                    addEvents.add(event);
                }
                if (addEvents.size() > 0) {
                    List<Database.SaveResult> results = EventBus.publish(addEvents);
                }
            }
        }
    }
    //Convert the verison# on quote to Revision Characters
    /*
    public static void updateQuoteRevison(List<SBQQ__Quote__c> newQuoteList) {
        for (SBQQ__Quote__c quote : newQuoteList) {
            if (quote.L2I_Version__c > 0) {
                quote.PT_Part_List_Rev__c = PT_Program_Utils.revisionCharacter(quote.L2I_Version__c.intValue());
            }
        }
    }
    */
    
    /**
    * @Method Name        : updatePTSStation
    * @Description        : update P&L Approval's PTS Station when Quote PTS Station is updated
    * @Author             : Jan Denrick Geronga / Managed Services Simplus
    * @Modification Log   :
    * Ver       	Date       	  Author              Modification
    * W-003016    	Jul-12-2021   MS Simplus Jan      Initial Version
    **/
    public static void updatePTSStation(List<SBQQ__Quote__c> newQuoteList, Map<Id, SBQQ__Quote__c> oldQuoteMap){
        Set<Id> setOppty = new Set<Id>();
        Set<Id> setPLA = new Set<Id>();
        String pTSStation;
        List<L2I_P_L_Approval__c> listPLA = new List<L2I_P_L_Approval__c>();
        
        for(SBQQ__Quote__c quote : newQuoteList){
            if(quote.SBQQ__Primary__c == true && quote.L2I_OpportunityProductCategory__c == 'PTS' && quote.L2I_Station__c != oldQuoteMap.get(quote.Id).L2I_Station__c){
                setOppty.add(quote.SBQQ__Opportunity2__c);
                pTSStation = quote.L2I_Station__c;
            }
        }
        if(setOppty.size() > 0){
            for(L2I_P_L_Sales_Opportunity__c pLSSales : [SELECT L2I_P_L_Approval__c FROM L2I_P_L_Sales_Opportunity__c WHERE L2I_Sales_Opportunity__c IN: setOppty]){
                setPLA.add(pLSSales.L2I_P_L_Approval__c);
            }
        }
        
        if (!setPLA.isEmpty()) {
            for(L2I_P_L_Approval__c pLA : [SELECT PL_PTS_Station__c FROM L2I_P_L_Approval__c WHERE ID IN: setPLA]){
                pLA.PL_PTS_Station__c = pTSStation;
                listPLA.add(pLA);
            }
        }
        
        if(listPLA.size() > 0){
            update listPLA;
        }
    }
    
    /**
    * @Method Name        : updateQLisNewTrue
    * @Description        : update QL isNew to False after Quote is Finalized
    * @Author             : Jan Denrick Geronga / Managed Services Simplus
    * @Modification Log   :
    * Ver       	Date       	  Author              Modification
    * W-002816    	Jul-23-2021   MS Simplus Jan      Initial Version
    **/
    public static void updateQLisNewTrue(List<SBQQ__Quote__c> newQuoteList, Map<Id, SBQQ__Quote__c> oldQuoteMap){
        Set<Id> sQIds = new Set<Id>();
        Set<Id> sOppId = new Set<Id>();
        List<SBQQ__QuoteLine__c> lQL = new List<SBQQ__QuoteLine__c>();
        
        for(SBQQ__Quote__c quote : newQuoteList){
            if (quote.SBQQ__Primary__c && oldQuoteMap.get(quote.Id).ApprovalStatus__c != 'Approved' && quote.ApprovalStatus__c == 'Approved') {
                sQIds.add(quote.Id);
                sOppId.add(quote.SBQQ__Opportunity2__c);
            }
        }
        if(sQIds.size() > 0){
            for(SBQQ__QuoteLine__c qL : [SELECT isNew__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: sQIds]){
                if(qL.isNew__c){
                    qL.isNew__c = false;
                    lQL.add(qL);
                }
            }
        }
        
        if(lQL.size() > 0){
            update lQL;
        }
    }
}