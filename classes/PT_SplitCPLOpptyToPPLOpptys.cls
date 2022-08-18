public class PT_SplitCPLOpptyToPPLOpptys {
    public static Id pplTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PPL').getRecordTypeId();
    public static SBQQ__Quote__c quote;

    @InvocableMethod
    public static void invokeCPLOpptySplit (List<Requests> requests) {
        if (requests[0].opportunityId != null) {
            Opportunity oppty = [SELECT Id, AccountId, CloseDate, L2I_Program_Num__c, Name, L2I_Parent_Opportunity__c, SBQQ__PrimaryQuote__c, Pricebook2Id
                                FROM Opportunity WHERE Id = : requests[0].opportunityId];
            processCPLOpptySplit(oppty);
        }
    }

    public static void processCPLOpptySplit(Opportunity oppty) {
        List<Opportunity> clonedPPLOpptys = new List<Opportunity>();
        List<SBQQ__Quote__c> clonedQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLineGroup__c> clonedQuoteLineGroups = new List<SBQQ__QuoteLineGroup__c>();
        List<SBQQ__QuoteLineGroup__c> deleteQuoteLineGroups = new List<SBQQ__QuoteLineGroup__c>();
        List<SBQQ__QuoteLine__c> deleteQuoteLines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        PT_PLG_Invoke_Revise.Requests req = new PT_PLG_Invoke_Revise.Requests();
        Map<Id, String> OpptyIdPPLOpptyTypeMap = new Map<Id, String>();
        Map<String, String> groupNameTypeMap = new Map<String, String>();
        Map<String, Id> pplTypeQuoteIdMap = new Map<String, Id>();
        Decimal amountFCOppty = 0;
        Opportunity opptyFC;
        Id quoteId;

        List<SBQQ__Quote__c> quotes = L2I_QuoteCloneUtility.cloneSBQQQuotes(new Set<String>{oppty.SBQQ__PrimaryQuote__c});
        quoteId = quotes[0].Id;

        String quoteQuery = generateQuery('SBQQ__Quote__c', '');
        quoteQuery += ' Where Id = :quoteId';

        SBQQ__Quote__c quote = Database.query(quoteQuery);
        Set<String> pplOpptyType = new Set<String>{'EQ', 'CR', 'ZZ', 'FC', 'AC', 'SV', 'OT', 'SW', 'OEM', 'DSS'};
        Set<String> groupType = new Set<String>();
        List<SBQQ__QuoteLineGroup__c> quoteLineGroups = [SELECT Id, Name, SBQQ__SolutionGroup__r.Type__c FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :quoteId];
        for (SBQQ__QuoteLineGroup__c qlg : quoteLineGroups) {
            groupType.add(qlg.SBQQ__SolutionGroup__r.Type__c);
            groupNameTypeMap.put(qlg.Name, qlg.SBQQ__SolutionGroup__r.Type__c);
            if (pplOpptyType.contains(qlg.SBQQ__SolutionGroup__r.Type__c)) {
                deleteQuoteLineGroups.add(qlg);
            }
        }

        for (String pplType : groupType) {
            if (pplOpptyType.contains(pplType)) {
                clonedPPLOpptys.add(createPPLOppty(oppty, pplType));
            }
        }
        if (clonedPPLOpptys.size() > 0) {
            insert clonedPPLOpptys;
        }
        for (Opportunity pplOppty : clonedPPLOpptys) {
            /*if (pplOppty.PT_PPL_Type__c != 'FC') {
                clonedQuotes.add(createQuote(pplOppty, quote));
            } else if (pplOppty.PT_PPL_Type__c == 'FC') {
                 opptyFC = pplOppty;
            }*/
            if (pplOppty.PT_PPL_Type__c == 'FC') {
                opptyFC = pplOppty;
            }
            clonedQuotes.add(createQuote(pplOppty, quote));
            OpptyIdPPLOpptyTypeMap.put(pplOppty.Id, pplOppty.PT_PPL_Type__c);
        }
        if (clonedQuotes.size() > 0) {
            insert clonedQuotes;
        }
        for (SBQQ__Quote__c qt : clonedQuotes) {
            if (OpptyIdPPLOpptyTypeMap != null && OpptyIdPPLOpptyTypeMap.containsKey(qt.SBQQ__Opportunity2__c)) {
                pplTypeQuoteIdMap.put(OpptyIdPPLOpptyTypeMap.get(qt.SBQQ__Opportunity2__c), qt.Id);
            }
        }

        String qlgQuery = generateQuery('SBQQ__QuoteLineGroup__c', '');
        qlgQuery += ' Where SBQQ__Quote__c = :quoteId';
        for(SBQQ__QuoteLineGroup__c lineGroup: Database.query(qlgQuery)) {
            SBQQ__QuoteLineGroup__c clonedGroup = lineGroup.clone(false, true, false, false);
            if (groupNameTypeMap.containsKey(lineGroup.Name)) {
                if (pplTypeQuoteIdMap.containsKey(groupNameTypeMap.get(lineGroup.Name))) {
                    clonedGroup.SBQQ__Quote__c = pplTypeQuoteIdMap.get(groupNameTypeMap.get(lineGroup.Name));
                    clonedQuoteLineGroups.add(clonedGroup);
                }
            }
        }
        if (clonedQuoteLineGroups.size() > 0) {
            insert clonedQuoteLineGroups;
        }
        Map<String, Id> qlgNameIdMap = new Map<String, Id>();
        for (SBQQ__QuoteLineGroup__c qlg : clonedQuoteLineGroups) {
            qlgNameIdMap.put(qlg.Name, qlg.Id);
        }
        String qlQuery = generateQuery('SBQQ__QuoteLine__c', 'SBQQ__Group__r.Name, SBQQ__Group__r.SBQQ__SolutionGroup__r.Type__c, ');
        qlQuery += ' Where SBQQ__Quote__c = :quoteId';

        for(SBQQ__QuoteLine__c quoteLine: Database.query(qlQuery)) {
            if (quoteLine.SBQQ__Group__r.SBQQ__SolutionGroup__r.Type__c == 'FC') {
                amountFCOppty = amountFCOppty + quoteLine.SBQQ__NetPrice__c;
                //deleteQuoteLines.add(quoteLine);
            } //else {
                if (pplTypeQuoteIdMap.containsKey(groupNameTypeMap.get(quoteLine.SBQQ__Group__r.Name))) {
                    SBQQ__QuoteLine__c clonedLine = quoteLine.clone(false, true, false, false);
                    clonedLine.SBQQ__Quote__c = pplTypeQuoteIdMap.get(groupNameTypeMap.get(quoteLine.SBQQ__Group__r.Name));
                    clonedLine.SBQQ__Group__c = qlgNameIdMap.get(quoteLine.SBQQ__Group__r.Name);
                    clonedLine.L2I_ExternalId__c = '';
                    quoteLines.add(clonedLine);
                    deleteQuoteLines.add(quoteLine);
                }
            //}
        }
        if(opptyFC != null) {
            opptyFC.PT_FC_Budget__c = amountFCOppty;
            update opptyFC;
        }

        if (quoteLines.size() > 0) {
            insert quoteLines;
        }
        if (deleteQuoteLines.size() > 0) {
           delete deleteQuoteLines;
        }
        if (deleteQuoteLineGroups.size() > 0) {
            delete deleteQuoteLineGroups;
        }
        if(clonedPPLOpptys.size() > 0) {
            createPLRecordsForPPLOppty(oppty.Id, clonedPPLOpptys);
        }
        //Recalculate quote for CPL
        if (quotes.size() > 0) {
            try {
                invokeFlowForQuoteCalculate(quotes);
            } catch (Exception e) {

            }
        }
        //Recalculate quote for PPL
        if (clonedQuotes.size() > 0) {
            try {
                invokeFlowForQuoteCalculate(clonedQuotes);
            } catch (Exception e) {

            }
        }
    }

    public static Opportunity createPPLOppty(Opportunity oppty, String pplType) {
        Opportunity newPPLOppty = new Opportunity();
        newPPLOppty.AccountId = oppty.AccountId;
        newPPLOppty.CloseDate = oppty.CloseDate;
        newPPLOppty.L2I_Program_Num__c = oppty.L2I_Program_Num__c;
        newPPLOppty.PT_CPL_Opportunity__c = oppty.Id;
        newPPLOppty.PT_PPL_Type__c = pplType;
        newPPLOppty.Name = pplType + ' - ' + oppty.Name;
        newPPLOppty.StageName = 'Handoff';
        newPPLOppty.L2I_Parent_Opportunity__c = oppty.L2I_Parent_Opportunity__c;
        newPPLOppty.recordTypeId = pplTypeId;
        newPPLOppty.Pricebook2Id = oppty.Pricebook2Id;

        return newPPLOppty;
    }

    public static void createPLRecordsForPPLOppty(Id salesOppty, List<Opportunity> pplOpptys) {
        List<L2I_P_L_Sales_Opportunity__c> plRecordsForPPLOpptyList = new List<L2I_P_L_Sales_Opportunity__c>();
        for (L2I_P_L_Sales_Opportunity__c pl : [SELECT Id, L2I_P_L_Approval__c
                                                FROM L2I_P_L_Sales_Opportunity__c
                                                WHERE L2I_Sales_Opportunity__c = :salesOppty]) {
            for (Opportunity opp : pplOpptys) {
                L2I_P_L_Sales_Opportunity__c newPL = new L2I_P_L_Sales_Opportunity__c();
                newPL.L2I_P_L_Approval__c = pl.L2I_P_L_Approval__c;
                newPL.L2I_Sales_Opportunity__c = opp.Id;
                plRecordsForPPLOpptyList.add(newPL);
            }
        }
        if (plRecordsForPPLOpptyList.size() > 0) {
            insert plRecordsForPPLOpptyList;
        }
    }

    public static SBQQ__Quote__c createQuote(Opportunity pplOppty, SBQQ__Quote__c quote) {
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
        newQuote.ApprovalStatus__c = 'Pending';
        newQuote.SBQQ__Account__c = pplOppty.AccountId;
        newQuote.SBQQ__Opportunity2__c = pplOppty.Id;
        newQuote.SBQQ__OrderByQuoteLineGroup__c = true;
        newQuote.SBQQ__LineItemsGrouped__c = true;
        //newQuote.L2I_System_Type1__c = 'All';
        //newQuote.L2I_Connectivity_System_Type1__c = 'All';
        newQuote.SBQQ__Primary__c = true;
        newQuote.SBQQ__PriceBook__c = quote.SBQQ__PriceBook__c;
        newQuote.SBQQ__PricebookId__c = quote.SBQQ__PriceBook__c;
        //newQuote.SBQQ__BillingName__c = quote.SBQQ__BillingName__c;
        //newQuote.SBQQ__ContractingMethod__c = 'By Subscription End Date';
        //newQuote.SBQQ__ExpirationDate__c = Date.Today() + 30;
        //newQuote.SBQQ__PaymentTerms__c = 'Net 30';
        //newQuote.SBQQ__ShippingName__c = quote.SBQQ__ShippingName__c;
        newQuote.SBQQ__Type__c = 'Quote';
        newQuote.SBQQ__Status__c = 'Draft';
        newQuote.Is_IFC__c = false;
        newQuote.L2I_Final_Proposal_Submission_Date__c = quote.L2I_Final_Proposal_Submission_Date__c;
        newQuote.L2I_Proposal_Due_Date__c = quote.L2I_Proposal_Due_Date__c;
        newQuote.SubmittedDate__c = quote.SubmittedDate__c;
        return newQuote;
    }

    public static String generateQuery(String objApiName, String parentFields) {
        Map<String, Schema.SObjectField> quoteFieldsMap = Schema.getGlobalDescribe().get(objApiName).getDescribe().fields.getMap();
        String query = 'Select ' + parentFields ;
        for(String str: quoteFieldsMap.keyset()) {
            query += str+',';
        }

        query = query.substring(0, query.length()-1);
        query += ' From '+objApiName;
        return query;
    }

    // Invoke flow for Calculating the Quote using CPQ API
    public static void invokeFlowForQuoteCalculate(List<SBQQ__Quote__c> clonedQuotes) {
        for (SBQQ__Quote__c qt : clonedQuotes) {
            Map<String, Object> params = new Map<String, Object>();
            params.put('quoteId', qt.Id);
            Flow.Interview.Calculate_Quote myFlow = new Flow.Interview.Calculate_Quote(params);
            myFlow.start();
        }
    }

    public class Requests {
        @InvocableVariable
        public Id opportunityId;
    }
}