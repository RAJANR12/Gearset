public class L2I_AutomateExistingDealOppBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext bc) {     
        Id RecordTypeIdOpportunityDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal').getRecordTypeId();  
        
        String queryString = 'SELECT Id, L2I_Deal_Opportunity_Description__c, L2I_AC_Operator__c, RecordTypeId, AccountId, CreatedDate FROM Opportunity WHERE RecordTypeId = :RecordTypeIdOpportunityDeal';
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> lDealOpportunity){
        Id RecordTypeIdOpportunitySales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();   
        Map<Id,Account> accountMap = new Map<Id,Account> ();
        Map<Id, Opportunity> dealOpptyMap = new Map<Id, Opportunity> ();
        Map<Id, String> dealDescMap = new Map<Id, String> ();
        Map<Id, String> dealAirlineMap = new Map<Id, String> ();
        Map<Id, Opportunity> salesOpptyMap = new Map<Id, Opportunity> ();
        Set<Id> accountIds = new Set<Id>();
        String newDealDesc = '';
        String newAirlineCode = '';
        String pillars = '';
        String airlineCode = '';
        Set<String> pillarSet = new Set<String>();
        Map<Id,Set<String>> salesBPillarsMap = new Map<Id,Set<String>> ();
        List<Opportunity> cancelledSalesOppty = new List<Opportunity> ();
        
        if (lDealOpportunity.size() > 0) {
            for (Opportunity opp : lDealOpportunity) {
                dealOpptyMap.put(opp.Id, opp);                                                                                                        
            }
            
            if (dealOpptyMap.size() > 0) {
                List<Opportunity> childSalesOppty = [SELECT Id, L2I_Parent_Opportunity__c, L2I_AC_Operator__c, RecordTypeId, SBQQ__PrimaryQuote__c,
                                                     L2I_Deal_Opportunity_Description__c, StageName, PL_Business_Pillars__c 
                                             		 FROM Opportunity WHERE RecordTypeId = :RecordTypeIdOpportunitySales AND L2I_Parent_Opportunity__c IN :dealOpptyMap.keySet()];
                if (!childSalesOppty.isEmpty()) {
                    for (Opportunity oppty : childSalesOppty) { 
                        System.debug(oppty.Id);
                        System.debug('*** oppty.PL_Business_Pillars__c for oppty.ID  ***' + oppty.Id + ': ' + oppty.PL_Business_Pillars__c);
                        System.debug('--- parentOppty for oppty.ID  ***' + oppty.L2I_Parent_Opportunity__c + ': ' + oppty.Id); 
                        accountIds.add(oppty.L2I_AC_Operator__c);
                        if (oppty.PL_Business_Pillars__c != null) {
                            if(salesBPillarsMap.containskey(oppty.L2I_Parent_Opportunity__c)){
                                salesBPillarsMap.get(oppty.L2I_Parent_Opportunity__c).add(oppty.PL_Business_Pillars__c);
                            }
                            else{
                                salesBPillarsMap.put(oppty.L2I_Parent_Opportunity__c, new Set<String>{oppty.PL_Business_Pillars__c});
                            }
                            dealDescMap.put(oppty.L2I_Parent_Opportunity__c, String.join(new List<String>(salesBPillarsMap.get(oppty.L2I_Parent_Opportunity__c)), '-'));
                        }                        
                        System.debug('--- salesBPillarsMap.containsKey()  ***' + salesBPillarsMap.containsKey(oppty.L2I_Parent_Opportunity__c));
                        System.debug('--- salesBPillarsMap for oppty.ID  ***' + oppty.Id + ': ' + salesBPillarsMap.get(oppty.L2I_Parent_Opportunity__c));
                        System.debug('--- oppty ID + salesBPillarsMap  ***' + oppty.Id + ': ' + salesBPillarsMap);                                       
                    }
                    
                    for (Opportunity oppty : childSalesOppty) { 
                        System.debug(oppty.Id);
                        if(salesBPillarsMap.containskey(oppty.L2I_Parent_Opportunity__c)) {
                            String salesBPillarsString = String.join(new List<String>(salesBPillarsMap.get(oppty.L2I_Parent_Opportunity__c)), '-');
                            salesBPillarsMap.remove(oppty.L2I_Parent_Opportunity__c);
                            salesBPillarsMap.put(oppty.L2I_Parent_Opportunity__c,new Set<String> (salesBPillarsString.split('-')));
                        }
                        System.debug('--- salesBPillarsMap  ***' + salesBPillarsMap);
                    } 
                    
                    if (!accountIds.isEmpty()) {
                        accountMap = new Map<Id,Account> ([SELECT Id, L2I_Operator_Number__c FROM Account WHERE ID IN :accountIds]);
                    }
                    
                    for (Opportunity oppty : childSalesOppty) {
                        System.debug(oppty.Id);
                        if(accountMap.containskey(oppty.L2I_AC_Operator__c)) {
                            airlineCode = accountMap.get(oppty.L2I_AC_Operator__c).L2I_Operator_Number__c;
                            if (airlineCode == null) {
                                airlineCode = 'Unavailable';
                            }
                        } else {
                            airlineCode = 'Unavailable';
                        }                        
                        System.debug('*** oppty ID + airlineCode  ***' + oppty.Id + ': ' + airlineCode);
                        if(dealAirlineMap.containskey(oppty.L2I_Parent_Opportunity__c)){
                            dealAirlineMap.remove(oppty.L2I_Parent_Opportunity__c);
                        }
                        dealAirlineMap.put(oppty.L2I_Parent_Opportunity__c, airlineCode);
                        if(dealDescMap.containskey(oppty.L2I_Parent_Opportunity__c)){
                            pillars = ' / ' + dealDescMap.get(oppty.L2I_Parent_Opportunity__c);
                        }
                        else{
                            pillars = '';
                        }
                        System.debug('*** oppty ID + pillars  ***' + oppty.Id + ': ' + pillars);
                        newDealDesc = airlineCode + pillars;
                        oppty.L2I_Deal_Opportunity_Description__c = newDealDesc;
                        salesOpptyMap.put(oppty.Id, oppty); 
                        System.debug('--- oppty ID + Deal Desc  ***' + oppty.Id + ': ' + dealDescMap.get(oppty.L2I_Parent_Opportunity__c));                   
                    }
                    
                    try {
                        Database.SaveResult [] updateResult = Database.update(childSalesOppty, false);
                        Opportunity oppToUpdate;
                        
                        for (Integer idx = 0; idx < updateResult.size(); idx++) {
                            if (!updateResult[idx].isSuccess()) {
                                oppToUpdate = salesOpptyMap.get(updateResult[idx].getId());
                                oppToUpdate.SBQQ__PrimaryQuote__c = null;
                                cancelledSalesOppty.add(oppToUpdate);
                                salesOpptyMap.remove(updateResult[idx].getId());
                                salesOpptyMap.put(updateResult[idx].getId(),oppToUpdate);
                            }
                        }
                        
                        if (!cancelledSalesOppty.isEmpty()) {
                            for (Opportunity oppty : cancelledSalesOppty) {
                                System.debug(oppty.Id);
                                if(accountMap.containskey(oppty.L2I_AC_Operator__c)) {
                                    airlineCode = accountMap.get(oppty.L2I_AC_Operator__c).L2I_Operator_Number__c;
                                    if (airlineCode == null) {
                                        airlineCode = 'Unavailable';
                                    }
                                } else {
                                    airlineCode = 'Unavailable';
                                }
                                oppty.L2I_Deal_Opportunity_Description__c = airlineCode;                  
                            }
                            update cancelledSalesOppty;
                        }
                    } catch (Exception ex) {} 
                }
                
                System.debug('*** dealDescMap  ***' + dealDescMap);
                
                List<Opportunity> dealOpptyToUpdate = dealOpptyMap.values();   
                
                if (!dealOpptyToUpdate.isEmpty()) {
                    String dealDesc;
                    for (Opportunity oppty : dealOpptyToUpdate) {
                        System.debug('*** for loop sud  ***' + oppty);          
                        System.debug('*** oppty ID + newAirlineCode  ***' + oppty.Id + ': ' + dealAirlineMap.get(oppty.Id) + dealDescMap.get(oppty.Id));
                        if(dealDescMap.containskey(oppty.Id)){
                            dealDesc = dealAirlineMap.get(oppty.Id) + ' / ' + dealDescMap.get(oppty.Id);
                        }
                        else{
                            dealDesc = dealAirlineMap.get(oppty.Id);
                        }
                        oppty.L2I_Deal_Opportunity_Description__c = dealDesc;
                        System.debug('*** oppty ID + Deal Desc  ***' + oppty.Id + ': ' + oppty.L2I_Deal_Opportunity_Description__c);
                    }                     
                    update dealOpptyToUpdate;
                }          
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {      
    }
}