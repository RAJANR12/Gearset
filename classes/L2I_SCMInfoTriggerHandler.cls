public without sharing class L2I_SCMInfoTriggerHandler extends L2I_TriggerHandler {
    
    public static void scmBeforeInsert (List<L2I_SCM_Confirmations__c> newSCMList) {
        
        Map<String, L2I_SCM_Confirmations__c> newSCMMap =  new Map<String, L2I_SCM_Confirmations__c>();
        List<String> newSalesNumList = new List<String>();
        Map<Id,L2I_SCM_Confirmations__c> insertSCMList = new Map<Id,L2I_SCM_Confirmations__c>();
        Map<String,Set<String>> mapRelatedDSS = new Map<String,Set<String>>();
        Map<String, String> mapSCMFeature = new Map<String, String>();
        
        for (L2I_SCM_Confirmations__c scm : newSCMList ) {
            if ( scm.L2I_Related__c == FALSE) {
                newSalesNumList.add(scm.L2I_Salesforce_Opportunity_Identifier__c);
                newSCMMap.put(scm.L2I_Salesforce_Opportunity_Identifier__c, scm);
                if (scm.L2I_Feature_Part_Numbers__c != null) {
                    mapSCMFeature.put(scm.L2I_Salesforce_Opportunity_Identifier__c,scm.L2I_Feature_Part_Numbers__c);
                }
                scm.L2I_Related__c = TRUE;
            }
        }
        
        if (!newSalesNumList.isEmpty()) {
            Map<Id, L2I_DSL__c> mapDSL = new Map<Id, L2I_DSL__c> ([SELECT ID, 
                                                                       (SELECT ID, 
                                                                            Original_Opportunity__c, 
                                                                            Original_Opportunity__r.Name 
                                                                        FROM Delivery_Schedule_Lines__r),
                                                                       Original_Opportunity__r.L2I_Opportunity_Number__c 
                                                                   FROM L2I_DSL__c 
                                                                   WHERE Original_Opportunity__c IN 
                                                                       (SELECT ID 
                                                                        FROM Opportunity 
                                                                        WHERE L2I_Opportunity_Number__c  IN : newSalesNumList)
                                                                  ]);
            System.debug('mapDSL is ' +mapDSL);
            System.debug('mapDSL.values is ' +mapDSL.values());
            if (!mapDSL.isEmpty()) {
                for (L2I_DSL__c dslLineItem :  mapDSL.values()) {
                    L2I_SCM_Confirmations__c cloneRec = newSCMMap.get(dslLineItem.Original_Opportunity__r.L2I_Opportunity_Number__c).clone(false, true, false, false);
                    System.debug('dslLineItem.Delivery_Schedule_Lines__r is ' +dslLineItem.Delivery_Schedule_Lines__r);
                    L2I_DSL__c dslRec = dslLineItem.Delivery_Schedule_Lines__r;
                    System.debug('dslRec is ' +dslRec);
                    cloneRec.Opportunity__c = dslRec.Original_Opportunity__c;
                    System.debug('mapRelatedDSS is ' +mapRelatedDSS);
                    System.debug('dslLineItem.Original_Opportunity__r.L2I_Opportunity_Number__c is ' +dslLineItem.Original_Opportunity__r.L2I_Opportunity_Number__c);
                    if (mapRelatedDSS.containsKey(dslLineItem.Original_Opportunity__r.L2I_Opportunity_Number__c)) {
                        System.debug('In the if loop ' );
                        Set<String> existingList = mapRelatedDSS.get(dslLineItem.Original_Opportunity__r.L2I_Opportunity_Number__c);
                        existingList.add(dslRec.Original_Opportunity__r.Name);
                        mapRelatedDSS.put(dslLineItem.Original_Opportunity__r.L2I_Opportunity_Number__c,existingList);
                    } else {
                        if (dslRec.Original_Opportunity__r.Name != null) {
                            Set<String> newList = new Set<String>{dslRec.Original_Opportunity__r.Name};
                            mapRelatedDSS.put(dslLineItem.Original_Opportunity__r.L2I_Opportunity_Number__c,newList); 
                        }
                    }
                    System.debug('cloneRec is ' +cloneRec);
                    insertSCMList.put(dslRec.Original_Opportunity__c,cloneRec);
                }
            }
            
            if (!mapRelatedDSS.isEmpty()) {
                for (String salesKey:mapRelatedDSS.keySet()) {
                    for (String setVal: mapRelatedDSS.get(salesKey)) {
                        if (setVal != null && setVal != 'null' ) {
                            String newString = newSCMMap.get(salesKey).L2I_Related_DSS__c;
                            if (newString != null) {
                                newString += setVal + ',';
                            } else {
                                newString = setVal;
                            }
                            newSCMMap.get(salesKey).L2I_Related_DSS__c = newString;
                        }
                    }
                }
            }
            if(!insertSCMList.isEmpty()){
                insert insertSCMList.values();
            }
        }
        
        if (!mapSCMFeature.isEmpty()) {
            List<String> queryString = new List<String>();
            List<String> returnString = new List<String>();
            Set<Id> setOrderId = new Set<Id>();
            Map<Id, OrderItem> mapCaseId = new Map<Id, OrderItem>();
            Map<String, DateTime> mapFeatureDate = new Map<String, DateTime>();
            Map<String, String> mapFeatureProgram = new Map<String, String>();
            List<Order> updateOrder = new List<Order>();
            List<Case> updateCase = new List<Case>();
            Set<String> setStringVal = new  Set<String>();
            
            for(String scmString : mapSCMFeature.keySet()){
                returnString = mapSCMFeature.get(scmString).split(',');
                queryString.addAll(returnString);
                if(!returnString.isEmpty()){
                    for(String featureItem : returnString){  
                        mapFeatureDate.put(featureItem, System.Now());
                        mapFeatureProgram.put(featureItem, newSCMMap.get(scmString).L2I_Program_Number__c);
                    }
                }
            }
            
            if(!queryString.isEmpty()){
                Map<Id, OrderItem> mapOrderItem = new Map<Id, OrderItem> ([ SELECT ID,L2I_Feature_ID__c, OrderId, Order.Status, Order.PT_Case__c, Order.PT_Case__r.IFE_Program_Number__c FROM OrderItem WHERE L2I_Feature_ID__c IN: queryString AND Order.Status = 'Draft']);
                for(OrderItem orderLine: mapOrderItem.values()){
                    if(orderLine.OrderId != null && orderLine.Order.PT_Case__c != null){
                        mapCaseId.put(orderLine.Order.PT_Case__c,orderLine);
                        setOrderId.add(orderLine.OrderId);
                        //mapCaseId.put(orderLine.Order.PT_Case__c,mapFeatureDate.get(orderLine.L2I_Feature_ID__c));
                    }
                }
            }
            
            if(!mapCaseId.isEmpty()){
                for(Id caseId: mapCaseId.keySet()){
                    Case modifyCase = new Case();
                    modifyCase.Id = caseId;
                    modifyCase.L2I_SCMDB_Release_Date__c = mapFeatureDate.get(mapCaseId.get(caseId).L2I_Feature_ID__c);
                            String newString = mapCaseId.get(caseId).Order.PT_Case__r.IFE_Program_Number__c;
                            if(newString != null){
                                setStringVal.addAll(newString.split(','));
                                setStringVal.add(mapFeatureProgram.get(mapCaseId.get(caseId).L2I_Feature_ID__c));
                                //newString += mapFeatureProgram.get(mapCaseId.get(caseId).L2I_Feature_ID__c) + ',';
                            } else{
                                setStringVal.add(mapFeatureProgram.get(mapCaseId.get(caseId).L2I_Feature_ID__c));
                                //newString = mapFeatureProgram.get(mapCaseId.get(caseId).L2I_Feature_ID__c) + ',';
                            }
                    modifyCase.IFE_Program_Number__c = String.join(new List<String>(setStringVal), ',');
                    updateCase.add(modifyCase);
                    
                    if(mapCaseId.get(caseId).OrderId != null){
                        Order modifyOrder = new Order();
                        modifyOrder.Id = mapCaseId.get(caseId).OrderId;
                        modifyOrder.L2I_SCM_Release_Date_Captured__c = TRUE;
                        updateOrder.add(modifyOrder);
                    }
                }
            }
            
            
            
            if(!updateCase.isEmpty()){
                update updateCase;
            }
            if(!updateOrder.isEmpty()){
                update updateOrder;
            }
        }
    }
}