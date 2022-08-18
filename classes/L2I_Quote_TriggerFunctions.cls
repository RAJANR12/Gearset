/**
*      @author       Raj Rajen
*      @date         08/01/2019
*      @description  L2I Quote Trigger Functions
*
*      Modification Log:
*      ------------------------------------------------------------------------------------
*      Developer                       Date                Description
*      ------------------------------------------------------------------------------------
*      Raj Rajen                     08/01/2019         Initial scaffold
*      Sarah Kennedy                 03/31/2020         US1618 added resetRenewalClosedLostOpp method
*
*/

public without sharing class L2I_Quote_TriggerFunctions {
    
    public static void cloneQuote(List<SBQQ__Quote__c> newQuoteList) {
        for (SBQQ__Quote__c quote : newQuoteList) {
            if (quote.isClone() && quote.getCloneSourceId() != null) {
                quote.SBQQ__Source__c = quote.getCloneSourceId();
            }
        }
    }
    
    //    public static void cloneQuote(List<SBQQ__Quote__c> newQuoteList) {
    //        Map<Id, Decimal> sourceMap = new Map<Id, Decimal>();
    //        Set<Id> sourceIds = new Set<Id>();
    //        Set<Id> quoteIds = new Set<Id>();
    //        for (SBQQ__Quote__c quote : newQuoteList) {
    //            if (quote.isClone() && quote.getCloneSourceId() != null) {
    //                sourceIds.add(quote.getCloneSourceId());
    //                quoteIds.add(quote.Id);
    //            }
    //        }
    //        for (SBQQ__Quote__c sq : [SELECT Id, L2I_Version__c FROM SBQQ__Quote__c WHERE Id = :sourceIds]) {
    //            sourceMap.put(sq.Id, sq.L2I_Version__c);
    //        }
    //
    //        for (SBQQ__Quote__c quote2 : newQuoteList) {
    //            if (quoteIds.contains(quote2.Id)) {
    //                quote2.SBQQ__Source__c = quote2.getCloneSourceId();
    //                quote2.SBQQ__Primary__c = true;
    //                quote2.L2I_Version__c = sourceMap.get(quote2.SBQQ__Source__c) != null ? sourceMap.get(quote2.SBQQ__Source__c) + 1 : 0;
    //                System.debug('*** quote2 ' + quote2);
    //            }
    //        }
    //    }
    
    //    public static void quoteClonedSource(List<SBQQ__Quote__c> newQuoteList) {
    //        List<SBQQ__Quote__c> sourceQuotesList = new List<SBQQ__Quote__c>();
    //        Set<Id> sourceIds = new Set<Id>();
    //        for (SBQQ__Quote__c quote : newQuoteList) {
    //            if (quote.isClone() && quote.getCloneSourceId() != null) {
    //                sourceIds.add(quote.getCloneSourceId());
    //            }
    //        }
    //        for (SBQQ__Quote__c sq : [SELECT Id, L2I_Revised__c, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE Id = :sourceIds]) {
    //            sq.L2I_Revised__c = true;
    //            if (sq.SBQQ__Primary__c){
    //                sq.SBQQ__Primary__c = false;
    //            }
    //            sourceQuotesList.add(sq);
    //            System.debug('*** sourcequote ' + sq);
    //        }
    //        if (!sourceQuotesList.isEmpty() &&
    //              sourceQuotesList.size() > 0){
    //            update sourceQuotesList;
    //        }
    //    }
    
    public static void calculateAircraftValue(List<SBQQ__Quote__c> newQuoteList, Map<Id, SBQQ__Quote__c> oldQuoteMap, Boolean isInsert, Boolean isUpdate) {
        for (SBQQ__Quote__c quote : newQuoteList) {
            // Upon insert
            if (isInsert) {
                
                // upon update
            } else if (isUpdate && quote.SBQQ__StartDate__c != oldQuoteMap.get(quote.Id).SBQQ__StartDate__c) {
                
            }
        }
    }
    
    public static void resetRenewalClosedLostOpp(Map<Id, SBQQ__Quote__c> newQuoteMap) {
        // Only 1 Renewal Opp may be on a Contract
        // Subsequent Contract Renewals have the new Quote added to the 1 Renewal Opp
        // If that Renewal Opp was 'Closed Lost', reset back to an active Opp
        
        List<Opportunity> oppsToUpdateList = new List<Opportunity>();
        Opportunity oppToUpdate;
        System.debug('*** quotes to process ' + newQuoteMap.keySet());
        for (SBQQ__Quote__c sbQuote : [
            SELECT Id,
            SBQQ__Opportunity2__c,
            SBQQ__Opportunity2__r.StageName,
            SBQQ__Opportunity2__r.L2I_Closed_Lost_Reasoning__c,
            SBQQ__Opportunity2__r.L2I_Win_Loss_Date__c,
            SBQQ__Opportunity2__r.RecordType.DeveloperName
            FROM SBQQ__Quote__c
            WHERE Id IN :newQuoteMap.keySet()
            AND SBQQ__Opportunity2__r.StageName = 'Closed Lost'
            AND SBQQ__Opportunity2__r.RecordType.DeveloperName = 'Renewal'
        ]) {
            System.debug('*** Closed Lost Renewal Opp ' + sbQuote);
            oppToUpdate = new Opportunity();
            oppToUpdate.Id = sbQuote.SBQQ__Opportunity2__c;
            oppToUpdate.StageName = 'Quotation';
            oppToUpdate.L2I_Closed_Lost_Reasoning__c = '';
            oppToUpdate.L2I_Win_Loss_Date__c = null;
            oppsToUpdateList.add(oppToUpdate);
        }
        System.debug('*** oppsToUpdateList.size ' + oppsToUpdateList.size());
        update oppsToUpdateList;
    }
    
    /**
    * 
    * 
    */
    public static void updateRecordTypeForRejectedQuotes(List<SBQQ__Quote__c> newQuoteList){
        
        String draftRecTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Quote Draft').getRecordTypeId();
        for(SBQQ__Quote__c quoteRec: newQuoteList){
            if(quoteRec.ApprovalStatus__c == 'Rejected' && quoteRec.RecordTypeId  != draftRecTypeID){
                quoteRec.RecordTypeId = draftRecTypeID;
            }
        }
    }
    
    /**
    * 
    * 
    */
    public static void checkPrimaryQuoteBeforeDelete(Map<Id, SBQQ__Quote__c> oldQuoteMap){
        
        for(SBQQ__Quote__c quote: oldQuoteMap.values()){
            if(quote.SBQQ__Primary__c){
                quote.AddError('Primary quote can not be deleted');
            }
        }
        
    }
    
    /**
    * @Method Name        : updateBPillars
    * @Description        : Update Deal and Sales Oppty Record for multiple Business Pillar
    * @Author             : Leah Racquel Ajo / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-004424      May-16-2022   MS Simplus Leah     Initial Version
    **/
    public static void updateBPillars(List<SBQQ__Quote__c> newQuoteList,Map<Id, SBQQ__Quote__c> oldQuoteMap){
        Set<Id> quoteSalesOpptyId = new Set<Id>();
        Set<Id> dealOpptyId = new Set<Id>();
        Set<Id> childSalesOpptyId = new Set<Id>();
        Set<String> salesBPillars = new Set<String>();
        String newDealDesc = null;
        String oldDealDesc = null;
        String airlineCode = null;
        List<String> dealDesc = new List<String>();
        List<String> bPillars = new List<String>();
        List<Opportunity> dealOppty = new List<Opportunity>();
        
        for (SBQQ__Quote__c curQuote : newQuoteList) {            
            if(curQuote.PL_Business_Pillars__c != null && curQuote.PL_Business_Pillars__c != ''){
                if (curQuote.PL_Business_Pillars__c != oldQuoteMap.get(curQuote.Id).PL_Business_Pillars__c) {
                    System.debug('curQuote' + curQuote.Id);
                    quoteSalesOpptyId.add(curQuote.SBQQ__Opportunity2__c);
                    if(curQuote.PL_Business_Pillars__c.contains('-')) {
                        bPillars = curQuote.PL_Business_Pillars__c.split('-');
                    } else {
                        salesBPillars.add(curQuote.PL_Business_Pillars__c);
                    }
                }
            }
        }
        
        if (!bPillars.isEmpty()) {
            for (String bp : bPillars) {
                salesBPillars.add(bp);
            }
        }
        
        List<Opportunity> quouteParentSaleOppty = [SELECT Id, L2I_Parent_Opportunity__c, PL_Business_Pillars__c, L2I_Deal_Opportunity_Description__c FROM Opportunity WHERE Id IN :quoteSalesOpptyId];
        for (Opportunity oppty : quouteParentSaleOppty) {
            dealOpptyId.add(oppty.L2I_Parent_Opportunity__c);
            oldDealDesc = oppty.L2I_Deal_Opportunity_Description__c;
            if (oldDealDesc != null) {
                if (oldDealDesc.contains(' / ')) {
                    dealDesc = oldDealDesc.split(' / ');
                    airlineCode = dealDesc[0];
                    if(dealDesc[1].contains('-')) {
                        bPillars = dealDesc[1].split('-');
                    } else {
                        salesBPillars.add(dealDesc[1]);
                    }
                } else {
                    airlineCode = oldDealDesc;
                }
            } 
        }
        
        for (String bp : bPillars) {
            salesBPillars.add(bp);
        }
        System.debug('airlineCode' + airlineCode);
        System.debug('salesBPillars' + salesBPillars);
        
        if (!dealOpptyId.isEmpty()) {
            dealOppty = [SELECT Id, L2I_Deal_Opportunity_Description__c FROM Opportunity WHERE Id IN :dealOpptyId];
        }
        
        List<Opportunity> childSalesOppty = [SELECT Id, L2I_Parent_Opportunity__c, L2I_Deal_Opportunity_Description__c, PL_Business_Pillars__c 
                                             FROM Opportunity WHERE IsClosed = FALSE AND L2I_Parent_Opportunity__c IN :dealOpptyId];
        if (!childSalesOppty.isEmpty()) {            
            for (Opportunity oppty : childSalesOppty) {
                oppty.L2I_Deal_Opportunity_Description__c = airlineCode + ' / ' + String.join(new List<String>(salesBPillars), '-');
            }
            
            update childSalesOppty;
        }
        
        if (!dealOppty.isEmpty()) {            
            for (Opportunity oppty : dealOppty) {        
                oppty.L2I_Deal_Opportunity_Description__c = airlineCode + ' / ' + String.join(new List<String>(salesBPillars), '-');
            }
            update dealOppty;
        }
    }
}