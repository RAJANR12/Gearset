/**
 *      @author       Raj Rajen
 *      @date         03/24/2020
 *      @description  L2I PLSalesOpportunity Trigger Functions
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     03/24/2020         Initial scaffold
 *      Jan Geronga                   07/12/2021         W-003016 added updatePTSStation
 *      Francis macam                 11/08/2021         W-003708 added updatePLApprovalSalesOppDesc and reconstructPLApprovalSalesOppDesc
 *      Khrisna Elumba                06/10/2022         W-004450 added updatePLAutomatedSalesOppDesc in After Insert, Update, Delete, Undelete
 */

public without sharing class L2I_PLSalesOpportunity_TriggerFunctions {

    public static void updatePLApprovalFinancials(List<L2I_P_L_Sales_Opportunity__c> newPLSalesOpptyList) {
        recalculatePLApprovalFinancials(newPLSalesOpptyList);
    }

    public static void updatePLApprovalFinancials(List<L2I_P_L_Sales_Opportunity__c> newPLSalesOpptyList,
                                                  Map<Id, L2I_P_L_Sales_Opportunity__c> newPLSalesOpptyMap,
                                                  Map<Id, L2I_P_L_Sales_Opportunity__c> oldPLSalesOpptyMap) {

        List<L2I_P_L_Sales_Opportunity__c> affectedPLSalesOpptys = new List<L2I_P_L_Sales_Opportunity__c>();
        for (L2I_P_L_Sales_Opportunity__c plso : newPLSalesOpptyList) {
             L2I_P_L_Sales_Opportunity__c oldPLSalesOppty = oldPLSalesOpptyMap.get(plso.Id);
             L2I_P_L_Sales_Opportunity__c newPLSalesOppty = newPLSalesOpptyMap.get(plso.Id);

            if (newPLSalesOppty.L2I_Product_Category__c != null && newPLSalesOppty.L2I_Product_Category__c != oldPLSalesOppty.L2I_Product_Category__c) {
                System.debug('====== Amount has changed on the Opportunity from ' + oldPLSalesOppty.L2I_Product_Category__c + ' to ' + newPLSalesOppty.L2I_Product_Category__c);
                affectedPLSalesOpptys.add(plso);
            }
        }

        if (affectedPLSalesOpptys.isEmpty()) {
            return;
        }
        recalculatePLApprovalFinancials(newPLSalesOpptyList);
    }

    public static void recalculatePLApprovalFinancials(List<L2I_P_L_Sales_Opportunity__c> incomingList) {

        Set<Id> parentPLApprovalIds = new Set<Id>();

        for (L2I_P_L_Sales_Opportunity__c plso : incomingList) {
            if (plso.L2I_P_L_Approval__c != null) {
                parentPLApprovalIds.add(plso.L2I_P_L_Approval__c);
            }
        }

        if (parentPLApprovalIds.isEmpty()) {
            System.debug('====== No parent P&L Approvals found to update');
            return;
        }

        System.debug('====== Number of affected parent P&LApprovals :' + parentPLApprovalIds.size());

        // Parent PLApproval's L2I_Financials_Included__c has to be recalculated based on all the child
        // P&LSalesOpportunities

        // First get all the affected parent P&LApprovals
        Map<Id, L2I_P_L_Approval__c> parentApprovalLookup = new Map<Id, L2I_P_L_Approval__c>([select Id,
                                                                                                     Name,
                                                                                                     L2I_Financials_Included__c
                                                                                                from L2I_P_L_Approval__c
                                                                                               where Id in :parentPLApprovalIds]);

        System.debug('====== Number of parentApprovalLookup entries :' + parentApprovalLookup.size());
        Set<Id> parentApprovalIds = parentApprovalLookup.keySet();


        // Next get all the children of the affected parent approvals. This may seem redundant here as the
        // incomingList should already have the child records. But since we have to do this for deleted
        // child records, it is best to get the list of children again
        Map<Id, L2I_P_L_Sales_Opportunity__c> childPLSalesOpptyLookup =  new Map<Id, L2I_P_L_Sales_Opportunity__c>([select Id,
                                                                                                                           Name,
                                                                                                                           L2I_Product_Category__c,
                                                                                                                           L2I_P_L_Approval__c
                                                                                                                      from L2I_P_L_Sales_Opportunity__c
                                                                                                                     where L2I_P_L_Approval__c in :parentApprovalIds]);

        System.debug('====== Number of childPLSalesOpptyLookup entries :' + childPLSalesOpptyLookup.size());


        // Now recalculate the 'Financials Included' for each parent PLApproval based on the children's Product Category
        for (L2I_P_L_Approval__c parentPLApproval : parentApprovalLookup.values()) {
            List<L2I_P_L_Sales_Opportunity__c> childPLSalesOpptys = new List<L2I_P_L_Sales_Opportunity__c>();

            for (L2I_P_L_Sales_Opportunity__c childPLSalesOppty : childPLSalesOpptyLookup.values()) {
                if (childPLSalesOppty.L2I_P_L_Approval__c == parentPLApproval.Id) {
                    childPLSalesOpptys.add(childPLSalesOppty);
                }
            }

            Set<String> financialsIncluded = new Set<String>();
            for (L2I_P_L_Sales_Opportunity__c child : childPLSalesOpptys) {
                if (child.L2I_Product_Category__c != null) {
                    financialsIncluded.add(child.L2I_Product_Category__c);
                }
            }

            // this should set or reset the Financials included appropriately based on the number of child records
            String joinedString = String.join(new List<String>(financialsIncluded), ';');
            System.debug('====== Setting Parent PLApproval ' + parentPLApproval.Name + ' Financials Included as :' + joinedString);
            parentPLApproval.L2I_Financials_Included__c = joinedString;

        }

        // Lastly update the parent records
        List<L2I_P_L_Approval__c> parentPLApprovals = parentApprovalLookup.values();
        update parentPLApprovals;

    }
    
    /**
    * @Method Name        : updatePTSStation
    * @Description        : update P&L Approval's PTS Station when new PL Sales Oppty is added
    * @Author             : Jan Denrick Geronga / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-003016      Jul-12-2021   MS Simplus Jan      Initial Version
    **/
    public static void updatePTSStation(List<L2I_P_L_Sales_Opportunity__c> newPLSalesOpptyList){
        Map<Id, L2I_P_L_Sales_Opportunity__c> mapPLS = new Map<Id, L2I_P_L_Sales_Opportunity__c>();
        Set<Id> setPLA = new Set<Id>();
        String pTSStation;
        List<L2I_P_L_Approval__c> listPLA = new List<L2I_P_L_Approval__c>();
        
        for(L2I_P_L_Sales_Opportunity__c pLSSales : newPLSalesOpptyList){
            if(pLSSales.L2I_Product_Category__c == 'PTS'){
                mapPLS.put(pLSSales.L2I_Sales_Opportunity__c, pLSSales);
                setPLA.add(pLSSales.L2I_P_L_Approval__c);
            }
        }
        
        if(!mapPLS.isEmpty()){
            for(SBQQ__Quote__c quote: [SELECT Id, L2I_Station__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN: mapPLS.keySet() AND SBQQ__Primary__c =: true LIMIT 1]){
                pTSStation = quote.L2I_Station__c;
            }
            
            for(L2I_P_L_Approval__c pLA: [SELECT PL_PTS_Station__c FROM L2I_P_L_Approval__c WHERE ID IN: setPLA]){
                pLA.PL_PTS_Station__c = pTSStation;
                listPLA.add(pLA);
            }
        }
        
        if(listPLA.size() > 0){
            update listPLA;
        }
    }
    
    /**
    * @Method Name        : updatePLApprovalSalesOppDesc
    * @Description        : update P&L Approval's Sales Opportunity Description when Sales Opportunity Description is updated
    * @Author             : Francis Jan Macam / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-003708      Nov-08-2021   MS Simplus Francis  Initial Version
    **/
    public static void updatePLApprovalSalesOppDesc(List<L2I_P_L_Sales_Opportunity__c> newPLSalesOpptyList) {
        List<L2I_P_L_Sales_Opportunity__c> targetPLSalesOppList = new List<L2I_P_L_Sales_Opportunity__c>();
        
        for (L2I_P_L_Sales_Opportunity__c curPLSalesOpp : newPLSalesOpptyList) {
            if (curPLSalesOpp.L2I_Sales_Opportunity__c != null && curPLSalesOpp.L2I_P_L_Approval__c != null) {                
                targetPLSalesOppList.add(curPLSalesOpp);
            }
        }

        if (!targetPLSalesOppList.isEmpty()) {
            reconstructPLApprovalSalesOppDesc(targetPLSalesOppList);
        }
    }
    
    /**
    * @Method Name        : updatePLApprovalSalesOppDesc
    * @Description        : update P&L Approval's Sales Opportunity Description when Sales Opportunity Description is updated
    * @Author             : Francis Jan Macam / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-003708      Nov-08-2021   MS Simplus Francis  Initial Version
    **/
    public static void updatePLApprovalSalesOppDesc(List<L2I_P_L_Sales_Opportunity__c> newPLSalesOpptyList,
                                                           Map<Id, L2I_P_L_Sales_Opportunity__c> newPLSalesOpptyMap,
                                                           Map<Id, L2I_P_L_Sales_Opportunity__c> oldPLSalesOpptyMap) {
        List<L2I_P_L_Sales_Opportunity__c> targetPLSalesOppList = new List<L2I_P_L_Sales_Opportunity__c>();
        
        for (L2I_P_L_Sales_Opportunity__c curPLSalesOpp : newPLSalesOpptyList) {
             L2I_P_L_Sales_Opportunity__c oldPLSalesOpp = oldPLSalesOpptyMap.get(curPLSalesOpp.Id);
             L2I_P_L_Sales_Opportunity__c newPLSalesOpp = newPLSalesOpptyMap.get(curPLSalesOpp.Id);
            
            if (newPLSalesOpp.L2I_Sales_Opportunity__c != oldPLSalesOpp.L2I_Sales_Opportunity__c ||
                newPLSalesOpp.L2I_P_L_Approval__c != oldPLSalesOpp.L2I_P_L_Approval__c) {                
                targetPLSalesOppList.add(curPLSalesOpp);
            }
        }

        if (!targetPLSalesOppList.isEmpty()) {
            reconstructPLApprovalSalesOppDesc(targetPLSalesOppList);
        }
    }
    
/**
    * @Method Name        : updateQuoteLookup
    * @Description        : 
    * @Author             : Alvin Claridad / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-004396      Apr-20-2022   MS Simplus Francis  Initial Version
    **/
    public static void updateQuoteLookup(List<L2I_P_L_Sales_Opportunity__c> newPLSalesOpptyList) {
        List<Id> salesOppList = new List<Id>();                                                              
        for (L2I_P_L_Sales_Opportunity__c curPLSalesOpp : newPLSalesOpptyList) {
             salesOppList.add(curPLSalesOpp.L2I_Sales_Opportunity__c);
        }
        if(!salesOppList.isEmpty()){
            Map<Id,Opportunity > mapOppQuote = new Map<Id,Opportunity>([SELECT Id, SBQQ__PrimaryQuote__c FROM Opportunity WHERE ID IN: salesOppList]);
            if(!mapOppQuote.isEmpty()){
                for(L2I_P_L_Sales_Opportunity__c curPLSalesOpp : newPLSalesOpptyList){
                    curPLSalesOpp.PL_Quote_Lookup__c = mapOppQuote.get(curPLSalesOpp.L2I_Sales_Opportunity__c).SBQQ__PrimaryQuote__c;
                }
            }
        }
    }
    
    /**
    * @Method Name        : reconstructPLApprovalSalesOppDesc
    * @Description        : update P&L Approval's Sales Opportunity Description when Sales Opportunity Description is updated
    * @Author             : Francis Jan Macam / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-003708      Nov-08-2021   MS Simplus Francis  Initial Version
    **/
    public static void reconstructPLApprovalSalesOppDesc(List<L2I_P_L_Sales_Opportunity__c> pLsalesList) {
        Set<Id> targetPLApprovalIds = new Set<Id>();
        
        for (L2I_P_L_Sales_Opportunity__c pLSalesOpp : pLsalesList) {
            if (pLSalesOpp.L2I_P_L_Approval__c != null) {
                targetPLApprovalIds.add(pLSalesOpp.L2I_P_L_Approval__c);
            }
        }

        if (!targetPLApprovalIds.isEmpty()) {            
            Map<Id, L2I_P_L_Approval__c> pLApprovalMap = new Map<Id, L2I_P_L_Approval__c>([SELECT Id, L2I_Sales_Opportunity_Description__c 
                                                                                           FROM L2I_P_L_Approval__c 
                                                                                           WHERE Id in :targetPLApprovalIds]);

            Map<Id, L2I_P_L_Sales_Opportunity__c> pLSalesOppMap =  new Map<Id, L2I_P_L_Sales_Opportunity__c>([SELECT Id, L2I_Sales_Opportunity__r.Name, L2I_P_L_Approval__c
                                                                                                              FROM L2I_P_L_Sales_Opportunity__c
                                                                                                              WHERE L2I_P_L_Approval__c in :pLApprovalMap.keySet()]);

            for (L2I_P_L_Approval__c pLApproval : pLApprovalMap.values()) {
                pLApproval.L2I_Sales_Opportunity_Description__c = '';

                for (L2I_P_L_Sales_Opportunity__c pLSalesOpp : pLSalesOppMap.values()) {
                    if (pLSalesOpp.L2I_P_L_Approval__c == pLApproval.Id) {
                        if(!String.isEmpty(pLApproval.L2I_Sales_Opportunity_Description__c)){
                            pLApproval.L2I_Sales_Opportunity_Description__c += '; ';    
                        }
                        pLApproval.L2I_Sales_Opportunity_Description__c += pLSalesOpp.L2I_Sales_Opportunity__r.Name;
                    }
                }
            }

            List<L2I_P_L_Approval__c> pLlApprovalList = pLApprovalMap.values();
            update pLlApprovalList;
        }        
    }

    /**
    * @Method Name        : updatePLAutomatedSalesOppDesc
    * @Description        : update P&L Approval's Automated Sales Opportunity Description
    * @Author             : Khrisna Elumba / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date          Author              Modification
    * W-004450      Jun-10-2022   MS Simplus Khrisna  Initial Version
    **/
    public static void updatePLAutomatedSalesOppDesc(List<L2I_P_L_Sales_Opportunity__c> pLsalesList) {
        Id recordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        Set<Id> targetPLApprovalIds = new Set<Id>();
        
        for (L2I_P_L_Sales_Opportunity__c pLSalesOpp : pLsalesList) {
            if (pLSalesOpp.L2I_P_L_Approval__c != null) {
                targetPLApprovalIds.add(pLSalesOpp.L2I_P_L_Approval__c);
            }
        }

        if (!targetPLApprovalIds.isEmpty()) {
            Map<Id, L2I_P_L_Approval__c> pLApprovalMap = new Map<Id, L2I_P_L_Approval__c>([SELECT Id, Automated_Sales_Opportunity_Description__c,
                                                                                           L2I_Approval_Deal_Opportunity__c,
                                                                                           L2I_Approval_Deal_Opportunity__r.RecordtypeId
                                                                                           FROM L2I_P_L_Approval__c 
                                                                                           WHERE Id in :targetPLApprovalIds]);

            Map<Id, L2I_P_L_Sales_Opportunity__c> pLSalesOppMap =  new Map<Id, L2I_P_L_Sales_Opportunity__c>([SELECT Id, L2I_P_L_Approval__c,
                                                                                                              Automated_Sales_Opportunity_Description__c 
                                                                                                              FROM L2I_P_L_Sales_Opportunity__c
                                                                                                              WHERE L2I_P_L_Approval__c in :pLApprovalMap.keySet()]);

            for (L2I_P_L_Approval__c pLApproval : pLApprovalMap.values()) {
                pLApproval.Automated_Sales_Opportunity_Description__c = '';
                
                if(pLApproval.L2I_Approval_Deal_Opportunity__c != null && pLApproval.L2I_Approval_Deal_Opportunity__r.RecordtypeId == recordTypeId) {
                    for (L2I_P_L_Sales_Opportunity__c pLSalesOpp : pLSalesOppMap.values()) {
                        if (pLSalesOpp.L2I_P_L_Approval__c == pLApproval.Id) {
                            if(!String.isEmpty(pLApproval.Automated_Sales_Opportunity_Description__c)){
                                pLApproval.Automated_Sales_Opportunity_Description__c += '; ';
                            }
                            String automatedSOppDescription = pLSalesOpp.Automated_Sales_Opportunity_Description__c;
                            pLApproval.Automated_Sales_Opportunity_Description__c += automatedSOppDescription.stripHtmlTags();
                        }
                    }
                }
            }

            List<L2I_P_L_Approval__c> pLlApprovalList = pLApprovalMap.values();
            update pLlApprovalList;
        }
    }
}