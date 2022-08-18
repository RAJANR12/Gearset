/**
 *      @author       Sarah Kennedy
 *      @date         04/28/2020
 *      @description  PT Opportunity Trigger Functions
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 04/27/2020         Added methods from Program Table POC: updateDSLs, createProgram, createProgramUpdateDSLs
 *      Sarah Kennedy                 05/15/2020         Added checks for empty values prior to SELECT to help prevent SOQL limit
 *      Dan Morris                    06/29/2020         Added primary quote as initial Parts List for DSLs
 *      Sarah Kennedy                 09/24/2020         W-001777 - Create a Quote document when IFEC Opp Stage is set to Closed Won
 *      Sarah Kennedy                 10/26/2020         Removing references to PT_Program_NonShipset_Code__mdt
 *      Michael Straw                 06/29/2021         W-003530 Added validation for queue membership on the approval process
 * 		QOng						  09/02/2021		 W-003749 Update Process for CR PPL Type
 */

public without sharing class PT_Opportunity_TriggerFunctions {
    public static Id productionTypeId = Schema.SObjectType.PT_Program__c.getRecordTypeInfosByDeveloperName().get('Production').getRecordTypeId();
    public static Id retrofitTypeId = Schema.SObjectType.PT_Program__c.getRecordTypeInfosByDeveloperName().get('Retrofit').getRecordTypeId();
    public static Id salesTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
    public static Id pplTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PPL').getRecordTypeId();
    public static void createProgramUpdateDSLs(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap) {

        System.debug('====== executing createProgramUpdateDSLs');
        Map<Id, Opportunity> oppsForCreateProgramMap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> oppsForDSLUpdatemMap = new Map<Id, Opportunity>();
        Map<Id, Id> dshProgramMap = new Map<Id, Id>();
        Map<Id, Id> dshCplMap = new Map<Id, Id>();
        List<L2I_DSL__c> dslList = new List<L2I_DSL__c>();
        List<PT_Program__c> programList = new List<PT_Program__c>();
        Set<String> oppPrimaryQuote = new Set<String>();

        // save off opportunities needing a Program reference
        // otherwise, update the Program DSLs
        for (Opportunity oppty : newOpportunityList) {
            if (oldOpportunityMap.get(oppty.Id).StageName == 'Handoff' && oppty.StageName == 'Delivery' &&
                  oppty.L2I_Product_Category__c == 'IFEC' && oppty.RecordTypeId == salesTypeId) {
                System.debug('*** opp Closed Won IFEC');
                if (oppty.L2I_Program_Num__c == null) {
                    System.debug('*** oppty.PT_Program__c null ');
                    oppsForCreateProgramMap.put(oppty.Id, oppty);
                    System.debug('*** oppsForCreateProgramMap ' + oppsForCreateProgramMap);
                }
                oppsForDSLUpdatemMap.put(oppty.Id, oppty);
                System.debug('*** oppsForDSLUpdatemMap ' + oppsForDSLUpdatemMap);
                // prepare to process approved parts
                if (oppty.SBQQ__PrimaryQuote__c != NULL){
                    oppPrimaryQuote.add(oppty.SBQQ__PrimaryQuote__c);
                }
            }
        }
		// create Programs
        if (!oppsForCreateProgramMap.isEmpty()) {
            for (Opportunity oppExtended : [
                  SELECT Id,
                        AccountId,
                        L2I_Aircraft_Owner__c,
                        L2I_AC_Operator__c,
                        L2I_Business_Initiative__c,
                        L2I_Fit_Type__c,
                        L2I_PO_Issuer__c,
                        Account.L2I_Operator_Number__c,
                        PT_Part_List_Name__c,
                        SBQQ__PrimaryQuote__c,
                        SBQQ__PrimaryQuote__r.L2I_System_Type1__c,
                        L2I_Primary_System_Type__r.L2I_System_Type_Translation__c,
                        L2I_Aircraft_Type__r.L2I_Aircraft_Type__c,
                        L2I_Aircraft_Type__r.L2I_Program_Code__c,
                        L2I_Delivery_Schedule__r.Aircraft_Type__r.L2I_PAC_Type_Designator__c,
                        Proposed_CSFE__c, Proposed_Order_Administrator__c, Proposed_PAC_Airbus_Manager__c,
                        Proposed_PMO_Group__c, Proposed_PMO_SubGroup__c, Proposed_Program_Administrator__c,
                        Proposed_Program_Manager__c,
                        PT_Sub_System_Type__c         
                  FROM Opportunity
                  WHERE Id IN :oppsForCreateProgramMap.keySet()
            ]) {
                programList.add(createProgram(oppExtended));
            }
            insertProgramList(programList);
            //insert programList;
            System.debug('*** programList.size() ' + programList.size());
            System.debug('*** programList ' + programList);
        }
        for (String primaryQuote : oppPrimaryQuote){
            // processing one at a time for CPL
			// L2I_QuoteService.processApprovedPartsList(primaryQuote);
        }

		// update Program DSLs
        if (!oppsForDSLUpdatemMap.isEmpty()) {
            for (Opportunity oppProgramForDSL : [
                  SELECT Id,
                        L2I_Program_Num__c,
                        L2I_Delivery_Schedule__c,
                        SBQQ__PrimaryQuote__c
                  FROM Opportunity
                  WHERE Id IN :oppsForDSLUpdatemMap.keySet()
            ]) {
                dshProgramMap.put(oppProgramForDSL.L2I_Delivery_Schedule__c, oppProgramForDSL.L2I_Program_Num__c);
                dshCplMap.put(oppProgramForDSL.L2I_Delivery_Schedule__c, oppProgramForDSL.SBQQ__PrimaryQuote__c);
            }
            System.debug('*** dshProgramMap ' + dshProgramMap);
            updateDSLs(dshProgramMap, dshCplMap, dslList);
            upsert dslList;
            System.debug('*** dslList.size() ' + dslList.size());
        }
    }

    private static PT_Program__c createProgram(Opportunity opp) {
        PT_Program__c prog = new PT_Program__c();
        prog.Account__c = opp.AccountId;
        prog.PT_Special_Project__c = opp.L2I_Business_Initiative__c;
        prog.Owner__c = opp.L2I_Aircraft_Owner__c;
        prog.Operator__c = opp.L2I_AC_Operator__c;
        prog.PO_Provider__c = opp.L2I_PO_Issuer__c;
        prog.Core_Program__c = PT_Program_Utils.getCoreProgramName(opp.L2I_Primary_System_Type__r.L2I_System_Type_Translation__c,
              opp.Account.L2I_Operator_Number__c, opp.L2I_Aircraft_Type__r.L2I_Aircraft_Type__c, opp.L2I_Aircraft_Type__r.L2I_Program_Code__c);
        prog.Sales_Opportunity__c = opp.Id;
        prog.CSFE__c= opp.Proposed_CSFE__c;
        prog.Order_Administrator__c = opp.Proposed_Order_Administrator__c;
        prog.PAC_Airbus_Manager__c = opp.Proposed_PAC_Airbus_Manager__c;
        prog.PT_PMO_Group__c = opp.Proposed_PMO_Group__c; 
        prog.PT_PMO_SubGroup__c = opp.Proposed_PMO_SubGroup__c;
        prog.Program_Administrator__c = opp.Proposed_Program_Administrator__c;
        prog.Program_Manager__c = opp.Proposed_Program_Manager__c ;
        prog.PT_Sub_System_Type__c = opp.PT_Sub_System_Type__c; // Added by Lipton for W-003362                    
        if (opp.L2I_Fit_Type__c == 'Production') {
            prog.RecordTypeId = productionTypeId;
        } else if (opp.L2I_Fit_Type__c == 'Retrofit') {
            prog.RecordTypeId = retrofitTypeId;
        }
        System.debug('*** opp.Id ' + opp.Id + ' prog.Sales_Opportunity__c ' + prog.Sales_Opportunity__c);
        return prog;
    }

    private static void insertProgramList(List<PT_Program__c> programList) {
        Map<String, String> programHighSequence = new Map<String, String>();
        Set<String> corePrograms = new Set<String>();
        String sequence;
        for (PT_Program__c prog : programList) {
            corePrograms.add(prog.Core_Program__c);
        }
        if (corePrograms.size() > 0) {
            List<AggregateResult> programSequences = [
                SELECT Core_Program__c, MAX(Program_Number__c) HIGHSEQ
                FROM PT_Program__c
                WHERE Core_Program__c IN :corePrograms
                GROUP BY Core_Program__c
            ];
            for (AggregateResult ar : programSequences) {
                programHighSequence.put((String) ar.get('Core_Program__c'), ((String) ar.get('HIGHSEQ')).mid(6, 2));
            }
        }
        for (PT_Program__c prog : programList) {
            if (programHighSequence != null) {
                sequence = programHighSequence.get(prog.Core_Program__c) == null ? '00' : programHighSequence.get(prog.Core_Program__c);
            } else {
                sequence = '00';
            }
            String nextSequence = PT_Program_Utils.characterSequencer(sequence);
            prog.Program_Number__c = prog.Core_Program__c + nextSequence;
            prog.Name = prog.Program_Number__c;
            Map<String, String> nextSequenceAlt = new Map<String, String>{
                  '0' => 'A',
                  '1' => 'B',
                  '2' => 'C',
                  '3' => 'D',
                  '4' => 'E',
                  '5' => 'F',
                  '6' => 'G',
                  '7' => 'H',
                  '8' => 'I',
                  '9' => 'J'
            };
            prog.PT_Program_Number_Alt__c = prog.Core_Program__c + nextSequence.replaceFirst(nextSequence.left(1), nextSequenceAlt.get(nextSequence.left(1)));
            programHighSequence.put(prog.Core_Program__c, nextSequence);
        }
        if (programList.size() > 0) {
            insert programList;
        }
    }
    private static List<L2I_DSL__c> updateDSLs(Map<Id, Id> dshProgramMap, Map<Id, Id> dshCplMap, List<L2I_DSL__c> dslList) {
        Map<Id, Id> dshOppMap = new Map<Id, Id>();
        for (Opportunity opp : [
              SELECT Id,
                    L2I_Delivery_Schedule__c
              FROM Opportunity
              WHERE L2I_Delivery_Schedule__c IN :dshProgramMap.keySet()
        ]) {
            dshOppMap.put(opp.L2I_Delivery_Schedule__c, opp.Id);
        }
        for (L2I_DSL__c dsl : [
              SELECT Id,
                    PT_Program__c,
                    PT_Assigned_Part_List__c,
                    Line_Number__c,
                    Delivery_Schedule_Header__c
              FROM L2I_DSL__c
              WHERE Delivery_Schedule_Header__c IN :dshProgramMap.keySet()
        ]) {
            dsl.PT_Program__c = dshProgramMap.get(dsl.Delivery_Schedule_Header__c);
            dsl.PT_Assigned_Part_List__c = dshCplMap.get(dsl.Delivery_Schedule_Header__c);
//            if (dsl.Line_Number__c == nonShipSetCode) {
//                dshWithShipSet.add(dsl.Delivery_Schedule_Header__c);
//            }
            dslList.add(dsl);
        }
        return dslList;
    }

    public static void updateProgramRecordType(List<Opportunity> newOpportunityList) {
        Set<Id> OppIds = new Set<Id>();
        List<PT_Program__c> updatePrograms = new List<PT_Program__c>();
        for (Opportunity oppty : newOpportunityList) {
            if (oppty.L2I_Program_Num__c != null) {
                OppIds.add(oppty.Id);
            }
        }
        if (OppIds.size() > 0) {
            List<Opportunity> oppsWithPrograms = [
              SELECT Id, L2I_Fit_Type__c, L2I_Program_Num__c, L2I_Program_Num__r.Aircraft_Identifier_Field__c,
                    L2I_Program_Num__r.PT_isActive__c, L2I_Program_Num__r.RecordType.Name,
                    L2I_Program_Num__r.Sales_Opportunity__c
              FROM Opportunity
              WHERE Id IN :OppIds
            ];
            for (Opportunity opp : oppsWithPrograms) {
                if (opp.L2I_Fit_Type__c == 'Production' && opp.L2I_Program_Num__r.PT_isActive__c != 'Inactive' && opp.Id == opp.L2I_Program_Num__r.Sales_Opportunity__c) {
                    PT_Program__c prog = new PT_Program__c();
                    prog.Id = opp.L2I_Program_Num__c;
                    prog.Aircraft_Identifier_Field__c = 'Serial Number';
                    prog.RecordTypeId = productionTypeId;
                    updatePrograms.add(prog);
                } else if (opp.L2I_Fit_Type__c == 'Retrofit' && opp.L2I_Program_Num__r.PT_isActive__c != 'Inactive' && opp.Id == opp.L2I_Program_Num__r.Sales_Opportunity__c && opp.L2I_Program_Num__r.RecordType.Name != 'Retrofit') {
                    PT_Program__c prog = new PT_Program__c();
                    prog.Id = opp.L2I_Program_Num__c;
                    prog.RecordTypeId = retrofitTypeId;
                    updatePrograms.add(prog);
                }
            }
            update updatePrograms;
        }
    }

    public static void updateCPLName(List<Opportunity> newOpportunityList) {
        Id salesTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
        Map<Id, Integer> opptProgramCountMap = new Map<Id, Integer>();
        Map<Id, String> programIdNameMap = new Map<Id, String>();
        Set<Id> programIds = new Set<Id>();
        Set<Id> opptIds = new Set<Id>();
        for (Opportunity oppty : newOpportunityList) {
            if ((oppty.Id == null || oppty.PT_Part_List_Name__c == null) && oppty.L2I_Product_Category__c == 'IFEC' && oppty.RecordTypeId == salesTypeId && oppty.L2I_Program_Num__c != null) {
                programIds.add(oppty.L2I_Program_Num__c);
                opptIds.add(oppty.Id);
            }
        }
        if (programIds.size() > 0) {
            List<PT_Program__c> programWithCPLOppts = [
                SELECT Id, Name, (
                        SELECT Id
                        FROM Opportunities__r
                        WHERE L2I_Product_Category__c = 'IFEC' AND RecordTypeId = :salesTypeId AND PT_Part_List_Name__c != null AND Id NOT IN :opptIds
                )
                FROM PT_Program__c
                WHERE Id IN :programIds
            ];
            for (PT_Program__c prog : programWithCPLOppts) {
                opptProgramCountMap.put(prog.Id, prog.Opportunities__r.size());
                programIdNameMap.put(prog.Id, prog.Name);
            }
        }

        for (Opportunity oppty : newOpportunityList) {
            if ((oppty.Id == null || oppty.PT_Part_List_Name__c == null) && oppty.L2I_Product_Category__c == 'IFEC' && oppty.RecordTypeId == salesTypeId && oppty.L2I_Program_Num__c != null) {
                Integer numOfOpps = opptProgramCountMap.get(oppty.L2I_Program_Num__c) + 1;
                oppty.PT_Part_List_Name__c = 'CPL-' + programIdNameMap.get(oppty.L2I_Program_Num__c) + '-' + numOfOpps;
                opptProgramCountMap.put(oppty.L2I_Program_Num__c, numOfOpps);
            }
        }
    }

    // Function to publish an event for Opportunity - Install Locations & Parts
    public static void createEventForILsAssetsToOppty(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap) {
        List<Assign_Parts_to_Shipset__e> addEvents = new List<Assign_Parts_to_Shipset__e>();
        for (Opportunity oppty : newOpportunityList) {
            if (oldOpportunityMap.get(oppty.Id).StageName == 'Handoff' && oppty.StageName == 'Delivery' &&
                ((oppty.L2I_Product_Category__c == 'IFEC' && oppty.RecordTypeId == salesTypeId) || oppty.RecordTypeId == pplTypeId)) {

                if (oppty.PT_Is_CPL__c) {
                    PT_AssignPTCPLBatch batch = new PT_AssignPTCPLBatch(oppty.SBQQ__PrimaryQuote__c);
                    //Id batchId = Database.executeBatch(batch, 25);
                }
                Assign_Parts_to_Shipset__e event = new Assign_Parts_to_Shipset__e();
                event.QuoteId__c = oppty.SBQQ__PrimaryQuote__c;
                event.DSL_Opportunity__c = 'Opportunity';
                addEvents.add(event);
            }
            if (addEvents.size() > 0) {
                List<Database.SaveResult> results = EventBus.publish(addEvents);
            }
        }
    }

    public static void callUdpateProgramAircrafts(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap) {
        for (Opportunity oppty : newOpportunityList) {
            if (oldOpportunityMap.get(oppty.Id).StageName == 'Handoff' && oppty.StageName == 'Delivery' &&
                oppty.L2I_Product_Category__c == 'IFEC' && oppty.RecordTypeId == salesTypeId && oppty.L2I_Program_Num__c != null) {
                PT_Program_Utils.udpateProgramAircrafts(oppty.Id, oppty.L2I_Program_Num__c);
            }
        }
    }

    // Function to sync Quote Line Products with Program Price List
    public static void syncQuoteLinesWithProgPriceList(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap) {
        List<PT_Program__c> progPriceList = new List<PT_Program__c>();
        List<PT_PriceList__c> insertProgPriceList = new List<PT_PriceList__c>();
        Map<Id, Id> pplOpptyPriceListMap = new Map<Id, Id>();
        Map<Id, Id> priceListOpptyIdMap = new Map<Id, Id>();
        Map<Id, Id> progPriceListMap = new Map<Id, Id>();
        Map<Id, String> programIdNameMap = new Map<Id, String>();
        Set<Id> programs = new Set<Id>();
        Set<Id> dssOpptyIdSet = new Set<Id>();

        for (Opportunity oppty : newOpportunityList) {
            if (oppty.L2I_Program_Num__c != null && oldOpportunityMap.get(oppty.Id).StageName == 'Handoff' && oppty.StageName == 'Delivery' &&
                ((oppty.L2I_Product_Category__c == 'IFEC' && oppty.RecordTypeId == salesTypeId) || oppty.RecordTypeId == pplTypeId)) {
                programs.add(oppty.L2I_Program_Num__c);
            }
        }
        if (programs.size() > 0) {
            progPriceList = [SELECT Id, Name, PT_Primary_Price_List__c
                            FROM PT_Program__c
                            WHERE Id IN :programs];
        }
        for (PT_Program__c prog : progPriceList) {
            if (prog.PT_Primary_Price_List__c != null) progPriceListMap.put(prog.Id, prog.PT_Primary_Price_List__c);
            programIdNameMap.put(prog.Id, prog.Name);
        }

        for (Opportunity oppty : newOpportunityList) {
            if (oldOpportunityMap.get(oppty.Id).StageName != 'Delivery' && oppty.StageName == 'Delivery'
                && oppty.L2I_Product_Category__c == 'DSS') {
                dssOpptyIdSet.add(oppty.Id);
            }
        }
        if (dssOpptyIdSet.size() > 0) {
            for (Opportunity dssOppty : [SELECT Id, L2I_Opportunity_ID__c, Account.L2I_Operator_Number__c, L2I_Program_Num__c, SBQQ__PrimaryQuote__c, PT_Price_List__c
                                            FROM Opportunity
                                            WHERE Id IN :dssOpptyIdSet]) {

                if (dssOppty.PT_Price_List__c != null) {
                    PT_ProgramPriceList_Utils.createUpdatePriceListEntries(dssOppty.SBQQ__PrimaryQuote__c, dssOppty.PT_Price_List__c);
                } else {
                    PT_PriceList__c priceList = new PT_PriceList__c(PT_Program__c = dssOppty.L2I_Program_Num__c,
                                                                        PT_Description__c = 'TBD',
                                                                        PT_IsActive__c = TRUE,
                                                                        PT_Price_List_Sequence__c = '01',
                                                                        PT_Price_List_Name__c = 'DSS-PL-' + dssOppty.L2I_Opportunity_ID__c + '-' + dssOppty.Account.L2I_Operator_Number__c + '-01',
                                                                        PT_Opportunity__c = dssOppty.Id);
                    insertProgPriceList.add(priceList);
                }
            }
        }
        for (Opportunity oppty : newOpportunityList) {
            if (oppty.L2I_Program_Num__c != null && oldOpportunityMap.get(oppty.Id).StageName == 'Handoff' && oppty.StageName == 'Delivery' &&
                ((oppty.L2I_Product_Category__c == 'IFEC' && oppty.RecordTypeId == salesTypeId) || oppty.RecordTypeId == pplTypeId)) {
                if (oppty.PT_Price_List__c != null) {
                    PT_ProgramPriceList_Utils.createUpdatePriceListEntries(oppty.SBQQ__PrimaryQuote__c, oppty.PT_Price_List__c);
                } else if (oppty.L2I_Product_Category__c == 'IFEC' && progPriceListMap.containsKey(oppty.L2I_Program_Num__c)) {
                    PT_ProgramPriceList_Utils.createUpdatePriceListEntries(oppty.SBQQ__PrimaryQuote__c, progPriceListMap.get(oppty.L2I_Program_Num__c));
                    oppty.PT_Price_List__c = progPriceListMap.get(oppty.L2I_Program_Num__c);
                } else if (oppty.RecordTypeId == pplTypeId && oppty.PT_Price_List__c == null) {
                    String progName = programIdNameMap.containsKey(oppty.L2I_Program_Num__c) ? programIdNameMap.get(oppty.L2I_Program_Num__c) : 'CPLProgNA';
                    PT_PriceList__c priceList = new PT_PriceList__c(PT_Program__c = oppty.L2I_Program_Num__c,
                                                                    PT_Description__c = 'TBD',
                                                                    PT_IsActive__c = TRUE,
                                                                    PT_Price_List_Sequence__c = '01',
                                                                    PT_Price_List_Name__c = 'PPL-PL-' + progName + '-01',
                                                                    PT_Opportunity__c = oppty.Id);
                    insertProgPriceList.add(priceList);
                }
            }
        }
        if (insertProgPriceList.size() > 0) {
            insert insertProgPriceList;
        }
        for (PT_PriceList__c pl : insertProgPriceList ) {
            priceListOpptyIdMap.put(pl.PT_Opportunity__c, pl.Id);
        }
        for (Opportunity oppty : newOpportunityList) {
            if (priceListOpptyIdMap != null && priceListOpptyIdMap.containsKey(oppty.Id)) {
                PT_ProgramPriceList_Utils.createUpdatePriceListEntries(oppty.SBQQ__PrimaryQuote__c, priceListOpptyIdMap.get(oppty.Id));
                oppty.PT_Price_List__c = priceListOpptyIdMap.get(oppty.Id);
            }
        }
    }

    public static void updatePPLNameAndProgram(List<Opportunity> newOpportunityList) {
        Id pplTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PPL').getRecordTypeId();
        Set<Id> opptyIdsCPL = new Set<Id>();
        Set<Id> opptyIds = new Set<Id>();
        Set<Id> progIds = new Set<Id>();
        Map<Id, Integer> opptProgramCountMap = new Map<Id, Integer>();
        Map<Id, Opportunity> opptyCPLMap = new Map<Id, Opportunity>();
        for (Opportunity oppty : newOpportunityList) {
            if (oppty.RecordTypeId == pplTypeId && oppty.PT_CPL_Opportunity__c != null &&
                  (oppty.PT_Part_List_Name__c == null || oppty.L2I_Program_Num__c == null || oppty.Id == null)) {
                opptyIdsCPL.add(oppty.PT_CPL_Opportunity__c);
                opptyIds.add(oppty.Id);
            }
        }
        if(opptyIdsCPL.size() > 0) {
            List<Opportunity> opptyRecordsCPL = [
                SELECT Id, L2I_Program_Num__c, L2I_Program_Num__r.Name
                FROM Opportunity
                WHERE Id IN :opptyIdsCPL
            ];

            for (Opportunity oppty : opptyRecordsCPL) {
                progIds.add(oppty.L2I_Program_Num__c);
                opptyCPLMap.put(oppty.Id, oppty);
            }
        }
        if (progIds.size() > 0) {
            List<PT_Program__c> progWithPPLs = [
                SELECT Id, (SELECT Id FROM Opportunities__r WHERE RecordTypeId = :pplTypeId AND PT_Part_List_Name__c != null AND Id NOT IN :opptyIds)
                FROM PT_Program__c
                WHERE Id IN :progIds
            ];

            for (PT_Program__c prog : progWithPPLs) {
                opptProgramCountMap.put(prog.Id, prog.Opportunities__r.size());
                System.debug('size' + prog.Opportunities__r.size());
            }
        }

        for (Opportunity oppty : newOpportunityList) {
            if (oppty.RecordTypeId == pplTypeId && oppty.PT_CPL_Opportunity__c != null &&
                  (oppty.PT_Part_List_Name__c == null || oppty.L2I_Program_Num__c == null || oppty.Id == null)) {
                if (opptyCPLMap.get(oppty.PT_CPL_Opportunity__c).L2I_Program_Num__c != null) {
                    Integer numOfOpps = opptProgramCountMap.get(opptyCPLMap.get(oppty.PT_CPL_Opportunity__c).L2I_Program_Num__c) + 1;
                    
                    //W-003749 Do not Set Part List Name if the PPL Type is CR. This field will be set by PT_PartList_Utils.updateOpportunityPostApproval for CR PPL Type upon moving the Opportunity to Delivery.
                   
                    if(oppty.PT_PPL_Type__c != 'CR'){
                        oppty.PT_Part_List_Name__c = 'PPL-' + opptyCPLMap.get(oppty.PT_CPL_Opportunity__c).L2I_Program_Num__r.Name + '-' + numOfOpps; 
                    }  
					
                    oppty.L2I_Program_Num__c = opptyCPLMap.get(oppty.PT_CPL_Opportunity__c).L2I_Program_Num__c;
                    opptProgramCountMap.put(opptyCPLMap.get(oppty.PT_CPL_Opportunity__c).L2I_Program_Num__c, numOfOpps);
                }
            }
        }
    }

    // Added by Lipton for W-003404
    // A utility method to get all the related PPL opportunities
    public static Map<Id,List<Opportunity>> getProgramRelatedPPL(List<Opportunity> newOpportunityList) {
        Map<Id, List<Opportunity>> result = new Map<Id, List<Opportunity>>();
        Set<Id> programIds = new Set<Id>();
        for(Opportunity opp : newOpportunityList) {
            programIds.add(opp.L2I_Program_Num__c);
        }

        for(PT_Program__c program : [SELECT Id, (SELECT Id, PT_Parts_List_Revision_Number__c, PT_PPL_Type__c, PT_Part_List_Name_Rev__c
                                            FROM Opportunities__r
                                            WHERE RecordTypeId = :pplTypeId AND PT_Part_List_Name__c != null
                                            ORDER BY PT_PPL_Type__c, PT_Parts_List_Revision_Number__c ASC)
                                    FROM PT_Program__c
                                    WHERE Id IN :programIds
        ]) {
            result.put(program.Id, program.Opportunities__r);
        }
        
        return result;
    }

    // Added by Lipton for W-003404
    // A utility method to get the latest Revision Number per PPL Type
    // Default: 0
    public static Integer getLatestRevisionNumber(List<Opportunity> pplOpps, String type) {
        Integer result = 0;

        if (!String.isBlank(type) && !pplOpps.isEmpty()) {
            for (Opportunity opp : pplOpps) {
                if (opp.PT_PPL_Type__c == type && opp.PT_Parts_List_Revision_Number__c != null && opp.PT_Parts_List_Revision_Number__c > result) {
                    result = (Integer)(opp.PT_Parts_List_Revision_Number__c);
                }
            }
        }

        return result;
    }

    public static void setPartListRevision(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap) {
        System.debug('*** Starting PT_Opportunity_TriggerFunctions.setPartListRevision');
        // When CPL/PPL Opportunity is updated from Handoff to Delivery, reset the PT_Parts_List_Revision_Number__c to 1.
        Map<Id,List<Opportunity>> programRelatedPPl = getProgramRelatedPPL(newOpportunityList); // Added by Lipton for W-003404
                
        for (Opportunity oppty : newOpportunityList) {
            system.debug(LoggingLevel.Info, '##3'+oldOpportunityMap.get(oppty.Id).StageName);
            system.debug(LoggingLevel.Info, '##4'+oppty.StageName);
            if (oldOpportunityMap.get(oppty.Id).StageName == 'Handoff' && oppty.StageName == 'Delivery' &&
                ((oppty.L2I_Product_Category__c == 'IFEC' && oppty.RecordTypeId == salesTypeId) || oppty.RecordTypeId == pplTypeId)) {
                // Modified IF statement by Lipton for W-003404
                // Removed oppty.SBQQ__PrimaryQuote__c == null 
                if (oppty.RecordTypeId == pplTypeId) {
                    Decimal revisionNumber = (Decimal)getLatestRevisionNumber(programRelatedPPl.get(oppty.L2I_Program_Num__c), oppty.PT_PPL_Type__c);
                    oppty.PT_Parts_List_Revision_Number__c = revisionNumber;
                    oppty.PT_Revised_Parts_List_Version_Trans__c = PT_Program_Utils.revisionCharacter(Integer.valueOf(oppty.PT_Parts_List_Revision_Number__c));
                    
                    //W-003749 Default CR Part List Revision Number to 1 upon Setting the CR PPL Type to Delivery.                    
                    if('CR' == oppty.PT_PPL_Type__c){                        
                        oppty.PT_CR_Parts_List_Revision_Number__c = 1;
                        oppty.PT_CR_Parts_List_Revision_Trans__c = PT_Program_Utils.revisionCharacter(Integer.valueOf(oppty.PT_CR_Parts_List_Revision_Number__c)); 
                    }                  
                } else {
                    oppty.PT_Parts_List_Revision_Number__c = 0;
                    oppty.PT_Revised_Parts_List_Version_Trans__c = null;
                }
                System.debug('*** Handoff -> Config oppty.PT_Parts_List_Revision_Number__c ' + oppty.PT_Parts_List_Revision_Number__c);
            }
        }
        System.debug('*** Ending PT_Opportunity_TriggerFunctions.setPartListRevision');

    }

    public static void setPartListRevisionInsert(List<Opportunity> newOpportunityList) {
        System.debug('*** Starting PT_Opportunity_TriggerFunctions.setPartListRevisionInsert');
        Map<Id,List<Opportunity>> programRelatedPPl = getProgramRelatedPPL(newOpportunityList); // Added by Lipton for W-003404
        // When a new Opp is saved in Split/Config and the Stage is Delivery
        for (Opportunity oppty : newOpportunityList) {
            if (oppty.StageName == 'Delivery' &&
                  oppty.L2I_Product_Category__c == 'IFEC' && (oppty.RecordTypeId == salesTypeId || oppty.RecordTypeId == pplTypeId)) {
//                oppty.PT_Parts_List_Revision_Number__c = oppty.PT_Parts_List_Revision_Number__c == null ? 1 : oppty.PT_Parts_List_Revision_Number__c++;
                // Added by Lipton for W-003404
                // Separate logic for PPL opportunities
                if (oppty.RecordTypeId == pplTypeId) {
                    Decimal revisionNumber = (Decimal)getLatestRevisionNumber(programRelatedPPl.get(oppty.L2I_Program_Num__c), oppty.PT_PPL_Type__c);
                    oppty.PT_Parts_List_Revision_Number__c = revisionNumber;
                    oppty.PT_Revised_Parts_List_Version_Trans__c = PT_Program_Utils.revisionCharacter(Integer.valueOf(oppty.PT_Parts_List_Revision_Number__c));
                } else {
                    oppty.PT_Parts_List_Revision_Number__c = oppty.PT_Parts_List_Revision_Number__c == null ? 0 : oppty.PT_Parts_List_Revision_Number__c;
                }
                System.debug('*** New Opp From Split/Config oppty.PT_Parts_List_Revision_Number__c ' + oppty.PT_Parts_List_Revision_Number__c);
            }
        }
        System.debug('*** Ending PT_Opportunity_TriggerFunctions.setPartListRevisionInsert');
    }

    public static void preventSubmitterFromApproving(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap) {
        Map<Id, Id> cplpplIdSubmitterMap = new Map<Id, Id>();
        Set<Id> oppsWithError = new Set<Id>();
        String userProfileName = '';
        Id userProfileId = UserInfo.getProfileId();

        Id userId = UserInfo.getUserId();
        String userName = UserInfo.getUserName();
        System.debug('*** userName ' + userName);
        if (!userName.startsWith('autoproc')) {      // Automated Process user has no profile - it's an internal fake user
            userProfileName = [SELECT Id, Name FROM Profile WHERE Id = :userProfileId].Name;
            System.debug('====== Running user profile name :' + userProfileName);
        }

        if (userName.startsWith('autoproc') ||
             userProfileName == 'System Administrator' ||
              userProfileName == 'PAC System Administrator'){
            return;
        }

        for (Opportunity oppty : newOpportunityList) {
            if ((oppty.PT_Is_PPL__c || oppty.PT_Is_CPL__c) &&
                  oppty.PT_PL_Approval_Status__c == 'Approved' &&
                  oldOpportunityMap.get(oppty.Id).PT_PL_Approval_Status__c == 'Pending') {
                cplpplIdSubmitterMap.put(oppty.Id, oppty.PT_PL_Approval_Submitter__c);
            }
        }
        System.debug('*** cplpplIdSubmitterMap ' + cplpplIdSubmitterMap);
        if (!cplpplIdSubmitterMap.isEmpty()) {
            for (ProcessInstance pi : [
                  SELECT TargetObjectId,LastActorId,LastActor.Name,
                        ProcessDefinitionId,
                        ProcessDefinition.DeveloperName, Status
                  FROM ProcessInstance
                  WHERE
                  TargetObjectId IN :cplpplIdSubmitterMap.keySet()
                  AND ProcessDefinition.DeveloperName = 'Part_List_Approval'
                  AND Status IN ('Approved')
                  ORDER BY CreatedDate DESC
                  LIMIT 1
            ]) {
                System.debug('*** pi.LastActorId ' + pi.LastActorId);
                System.debug('*** cplpplIdSubmitterMap.get(pi.TargetObjectId)' + cplpplIdSubmitterMap.get(pi.TargetObjectId));
                if (pi.LastActorId == cplpplIdSubmitterMap.get(pi.TargetObjectId)) {
                    System.debug('*** match ');
                    oppsWithError.add(pi.TargetObjectId);
                }
            }
        }

        if (!oppsWithError.isEmpty()) {
            for (Opportunity oppty : newOpportunityList) {
                if (oppsWithError.contains(oppty.Id)) {
                    System.debug('*** adding error');
                    oppty.addError('Submitter cannot also Approve');
                }
            }
        }
    }
    public static void  preventnonQueueMemberFromApproving(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap) {
       System.debug('*** Starting prevent nonQueueMemberFromApproving ***');
    
        Map<Id, Id> cplpplIdApproverMap = new Map<Id, Id>();
        Set<Id> oppsWithError = new Set<Id>();
        String userProfileName = '';
        Id userProfileId = UserInfo.getProfileId();
       
        //Get the queueid
        QueueSobject qo = [SELECT Queue.Id, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName = 'Program_PM_PPM_Queue' LIMIT 1];
        //Get the GroupMember Groups
        Set<id> groupIdSet = new Set<id>();
            for( groupMember gm : [Select id, UserorGroupId from GroupMember where GroupId = :qo.Queue.id]){
                GroupIdSet.Add(gm.UserorGroupId);
            }
        //Get the user ids
        Set<id> userIdSet = new Set<id>();
            for(GroupMember gm : [Select Id, UserOrGroupId from GroupMember where GroupId in : GroupIdSet]){
                userIdSet.Add(gm.UserOrGroupId);
            }

        Id userId = UserInfo.getUserId();
        String userName = UserInfo.getUserName();
    
        if (!userName.startsWith('autoproc')) {      // Automated Process user has no profile - it's an internal fake user
            userProfileName = [SELECT Id, Name FROM Profile WHERE Id = :userProfileId].Name;
        }

       if (userName.startsWith('autoproc') ||
            userProfileName == 'System Administrator'){
            return;
        }  

        /*for(user thisuser  :[ select firstname, lastname from user where id in :userIdSet order by lastname]){
            system.debug(thisuser.firstname +' ' + thisuser.lastname);
        } */


        for (Opportunity oppty : newOpportunityList) {
           // system.debug('*** is PPL ' + oppty.PT_Is_PPL__c + ' is CPL '+oppty.PT_Is_CPL__c);
           // system.debug('New Approval Status ' + oppty.PT_PL_Approval_Status__c + 'Old Approval Status '+  oldOpportunityMap.get(oppty.Id).PT_PL_Approval_Status__c  );
            if ((oppty.PT_Is_PPL__c || oppty.PT_Is_CPL__c) &&
                  oppty.PT_PL_Approval_Status__c == 'Approved' &&
                  oldOpportunityMap.get(oppty.Id).PT_PL_Approval_Status__c == 'Pending') {
                    if (!userIdSet.contains(userinfo.getUserId())) {
                        oppty.addError('This user cannot approve because they are not a member of the Program PM PPM Queue ');
                    }                 
                }
        }
       
    }

    public static void updateApprovedDataOnPLOpp(Map<Id, Opportunity> newOpportunityMap, Map<Id, Opportunity> oldOpportunityMap) {
        System.debug('*** Starting PT_Opportunity_TriggerFunctions.updateApprovedDataOnPLOpp - before update');
        Map<Id, Opportunity> approvedOppMap = new Map<Id, Opportunity>();

        for (Opportunity newOpp : newOpportunityMap.values()) {
            Opportunity oldOpp = oldOpportunityMap.get(newOpp.Id);
            if (newOpp.PT_PL_Approval_Status__c != oldOpp.PT_PL_Approval_Status__c &&
                  newOpp.PT_PL_Approval_Status__c == 'Approved') {
                System.debug('*** Approved Opportunity: ' + newOpp.Name);
                approvedOppMap.put(newOpp.Id, newOpp);
            }
        }

        if (!approvedOppMap.isEmpty()) {
            // Update Part List Rev #
            for (Opportunity oppAppHistory : [
                  SELECT Id, PT_Parts_List_Revision_Number__c, PT_Revised_Parts_List_Version_Trans__c, RecordType.Name, PT_PPL_Type__c//,PT_CR_Parts_List_Revision_Trans__c,PT_CR_Parts_List_Revision_Number__c
                  FROM Opportunity
                  WHERE Id IN :approvedOppMap.keySet()
            ]) {
                Opportunity oppNew = newOpportunityMap.get(oppAppHistory.Id);

                //W-003749 Set value for CR Part List Revision Number upon approving the Part list Update
                if(oppAppHistory.PT_PPL_Type__c == 'CR'){
                    oppNew.PT_CR_Parts_List_Revision_Number__c = oppNew.PT_CR_Parts_List_Revision_Number__c == null ? 1 :  oppNew.PT_CR_Parts_List_Revision_Number__c + 1;
                    oppNew.PT_CR_Parts_List_Revision_Trans__c = PT_Program_Utils.revisionCharacter(Integer.valueOf(oppNew.PT_CR_Parts_List_Revision_Number__c));
                } else{ 
                    oppNew.PT_Parts_List_Revision_Number__c = oppNew.PT_Parts_List_Revision_Number__c == null ? 1 :  (oppNew.PT_Parts_List_Revision_Number__c + 1);
                    oppNew.PT_Revised_Parts_List_Version_Trans__c = PT_Program_Utils.revisionCharacter(Integer.valueOf(oppNew.PT_Parts_List_Revision_Number__c));
                }
            }

            // Add Approver and comments to the Opportunity from the Approval History
            Set<Id> processInstanceIds = new Set<Id>();

            for (Opportunity oppAppHistory : [
                  SELECT Id, PT_Parts_List_Revision_Number__c, PT_Revised_Parts_List_Version_Trans__c,
                  (SELECT Id, LastActorId FROM ProcessInstances ORDER BY CreatedDate DESC)
                  FROM Opportunity
                  WHERE Id IN :approvedOppMap.keySet()
            ]) {
                processInstanceIds.clear();
                for (ProcessInstance pi : oppAppHistory.ProcessInstances) {
                    processInstanceIds.add(pi.Id);
                }
                for (ProcessInstance pi : [
                      SELECT TargetObjectId,LastActorId,LastActor.Name, (
                            SELECT Id, ActorId, Actor.Name, OriginalActor.Name,Comments, ProcessInstanceId, StepStatus
                            FROM StepsAndWorkitems
                            WHERE StepStatus = 'Approved'
                            ORDER BY Id DESC
                            LIMIT 1
                      )
                      FROM ProcessInstance
                      WHERE Id IN :processInstanceIds
                      ORDER BY CreatedDate DESC
                      LIMIT 1
                ]) {
                    if (pi.StepsAndWorkitems.size() > 0) {
                        for (ProcessInstanceHistory pih : pi.StepsAndWorkitems) {
                            Opportunity oppNew = newOpportunityMap.get(oppAppHistory.Id);
                            oppNew.PT_PL_Approval_Approver__c = pi.LastActorId;
                            oppNew.PT_PL_Approval_Approver_Comments__c = pih.Comments;
                            oppNew.PT_PL_Approval_Date__c = System.Now();
                        }
                    }
                }
            }
        }
        System.debug('*** Exiting PT_Opportunity_TriggerFunctions.updateApprovedDataOnPLOpp');
    }

    public static void partListApproved(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap) {
        System.debug('*** Starting PT_Opportunity_TriggerFunctions.partListApproved - after update');
        List<Asset> assetUpdateList = new List<Asset>();
        List<PT_Note__c> ptNotes = new List<PT_Note__c>();
        List<PT_Install_Location__c> installLocations = new List<PT_Install_Location__c>();
        Map<Id, Opportunity> approvedOppMap = new Map<Id, Opportunity>();
        Set<Id> approvedOppIds = new Set<Id>();

        for (Opportunity newOpp : newOpportunityList) {
            Opportunity oldOpp = oldOpportunityMap.get(newOpp.Id);
             System.debug('*** Approved Opportunity: ' + newOpp.PT_PL_Approval_Status__c);
            System.debug('*** Approved Opportunity: ' + oldOpp.PT_PL_Approval_Status__c);
            if (newOpp.PT_PL_Approval_Status__c != oldOpp.PT_PL_Approval_Status__c &&
                newOpp.PT_PL_Approval_Status__c == 'Approved') {
                   
                    approvedOppIds.add(newOpp.Id);
                }
        }

        if (!approvedOppIds.isEmpty()) {
            for (Opportunity opp : [
                  SELECT Id, PT_Part_List_Name__c, L2I_Program_Num__r.Program_Number__c,
                        SBQQ__PrimaryQuote__c, StageName, PT_Is_PPL__c, PT_Is_CPL__c,
                        (SELECT Id, PT_Approval_Status__c FROM Notes__r WHERE PT_Approval_Status__c = 'Pending'), // Added by Lipton for W-003567
                        (SELECT Id, PT_Approval_Status__c FROM Install_Locations__r WHERE PT_Approval_Status__c = 'Pending') // Added by Lipton for W-003567
                  FROM Opportunity
                  WHERE Id IN :approvedOppIds
            ]) {
                approvedOppMap.put(opp.Id, opp);

                // Added by Lipton for W-003567
                for (PT_Note__c notes : opp.Notes__r) {
                    notes.PT_Approval_Status__c = 'Approved';
                    ptNotes.add(notes);
                }

                for (PT_Install_Location__c il : opp.Install_Locations__r) {
                    il.PT_Approval_Status__c = 'Approved';
                    installLocations.add(il);
                }
            }
        }

        // Added by Lipton for W-003567
        if (!ptNotes.isEmpty()) {
            update ptNotes;
        }

        if (!installLocations.isEmpty()) {
            update installLocations;
        }

        if (!approvedOppMap.isEmpty()) {
            for (Opportunity newOpp : approvedOppMap.values()) {
                System.debug('***PT_Opportunity_TriggerFunctions :: newopp.Id ' + newOpp.Id);
                // update Revision Records
                System.debug('***PT_Opportunity_TriggerFunctions :: calling updatePartListPostApproval');
                PT_PartList_Utils.updatePartListPostApproval(newOpp.Id);

                // update Assets
                System.debug('***PT_Opportunity_TriggerFunctions :: calling updateAssetsOnPartListApproval');
                PT_PartList_Utils.updateAssetsOnPartListApproval(newOpp.Id);

                // call the Platform Events
                System.debug('***PT_Opportunity_TriggerFunctions :: calling createSyncPartsListToQuoteEvent');
                PT_PartList_Utils.createSyncPartsListToQuoteEvent(newOpp.Id);
                System.debug('***PT_Opportunity_TriggerFunctions :: calling createSyncPartsListToDSLEvent');
//                PT_PartList_Utils.createSyncPartsListToDSLEvent(newOpp.Id);
            }
        }

        System.debug('*** Exiting PT_Opportunity_TriggerFunctions.partListApproved');
    }

    public static void partListRejectedRecalled(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap) {
        System.debug('*** Starting PT_Opportunity_TriggerFunctions.partListRejectedRecalled');
        List<PT_Parts_List_Revision__c> plrList = new List<PT_Parts_List_Revision__c>();
        Set<Id> rejectRecallOppIds = new Set<Id>();

        for (Opportunity newOpp : newOpportunityList) {
            Opportunity oldOpp = oldOpportunityMap.get(newOpp.Id);
            if (newOpp.PT_PL_Approval_Status__c != oldOpp.PT_PL_Approval_Status__c &&
                  (newOpp.PT_PL_Approval_Status__c == 'Rejected' || newOpp.PT_PL_Approval_Status__c == 'Recalled')) {
                System.debug('*** Rejected/Recalled Opportunity: ' + newOpp.Name);
                rejectRecallOppIds.add(newOpp.Id);
            }
        }

        // delete unapproved revision records
        if (!rejectRecallOppIds.isEmpty()) {
            for (PT_Parts_List_Revision__c plr : [
                  SELECT Id
                  FROM PT_Parts_List_Revision__c
                  WHERE PT_Part_List_Opportunity__c IN :rejectRecallOppIds
                  AND PT_Parts_List_Revision_Number__c = NULL
            ]) {
                plrList.add(plr);
            }
        }

        if (plrList.size() > 0) {
            delete plrList;
        }
        System.debug('*** Exiting PT_Opportunity_TriggerFunctions.partListRejectedRecalled');
    }


    // This method needs to be bulkified. Will update soon - Nitin

    // This method will update all to make the DSLs on Porgram in a sequencial order.
    public static void resequenceDSLs(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap) {
        Integer currSequence;
        for (Opportunity oppty : newOpportunityList) {
            if (oldOpportunityMap.get(oppty.Id).StageName == 'Handoff' && oppty.StageName == 'Delivery' &&
                  oppty.L2I_Product_Category__c == 'IFEC' && oppty.RecordTypeId == salesTypeId) {
                if (oppty.L2I_Program_Num__c != null) {
                    // Get highest number of DSL from the program related to this oppty.
                    List<L2I_DSL__c> dslHighestNumber = [SELECT Id, Name, PT_Line_Number__c, Line_Number__c
                                                            FROM L2I_DSL__c
                                                            WHERE Original_Opportunity__r.StageName = 'Delivery'
                                                            AND Original_Opportunity__c !=: oppty.Id
                                                            AND PT_Program__c =: oppty.L2I_Program_Num__c
                                                            ORDER BY PT_Line_Number__c DESC LIMIT 1];

                    if (dslHighestNumber.size() == 1) {
                        currSequence = Integer.valueOf(dslHighestNumber[0].Line_Number__c);
                    } else {
                        currSequence = 0;
                    }
                    //Get all DSLs related to this Oppty. These DSLs will need to be updated to make them sequencial.
                    List<L2I_DSL__c> thisOptyDSLs = [SELECT Id, Name, PT_Line_Number__c, Line_Number__c
                                                            FROM L2I_DSL__c
                                                            WHERE Original_Opportunity__c =: oppty.Id AND PT_Program__c =: oppty.L2I_Program_Num__c];

                    // Loop thru each DSL related to this Oppty and assign the sequencial number.
                    for (L2I_DSL__c dsl : thisOptyDSLs) {
                        dsl.PT_Line_Number__c = PT_Program_Utils.characterSequencer(String.valueOf(currSequence));
                        String lineNumber;
                        if (currSequence + 1 < 10) {
                            lineNumber = '00' + String.valueOf(currSequence + 1);
                        } else if (currSequence + 1 > 9 && currSequence + 1  < 100) {
                            lineNumber = '0' + String.valueOf(currSequence + 1);
                        } else {
                            lineNumber = String.valueOf(currSequence + 1);
                        }
                        dsl.Line_Number__c = lineNumber;
                        dsl.Name = lineNumber;
                        currSequence++;
                    }
                    //Update DSLs
                    update thisOptyDSLs;
                }
            }
        }
    }

    // Commented by Lipton for W-004272
    /*public static void splitCPLOpptyToPPLOpptys(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap) {
        List<PT_SplitCPLOpptyToPPLOpptys__e> addEvents = new List<PT_SplitCPLOpptyToPPLOpptys__e>();
        for (Opportunity oppty : newOpportunityList) {
            if (oldOpportunityMap.get(oppty.Id).StageName == 'Closed Won' && oppty.StageName == 'Handoff' &&
                  oppty.L2I_Product_Category__c == 'IFEC' && oppty.RecordTypeId == salesTypeId) {
                PT_SplitCPLOpptyToPPLOpptys__e event = new PT_SplitCPLOpptyToPPLOpptys__e();
                event.OpportunityId__c = oppty.Id;
                addEvents.add(event);
            }
        }
        if (addEvents.size() > 0) {
            List<Database.SaveResult> results = EventBus.publish(addEvents);
        }
    }*/

    public static void validateStageChange(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap) {
        System.debug('*** Starting PT_Opportunity_TriggerFunctions.validateStageChange');

        for (Opportunity newOppty : newOpportunityList) {
            Opportunity oldOppty = oldOpportunityMap.get(newOppty.Id);
            if (oldOppty.StageName != newOppty.StageName) {
                if (oldOppty.StageName == 'Delivery') {
                    if (newOppty.L2I_Product_Category__c != 'PTS') {
                        newOppty.addError('Stage may not be changed from Delivery');
                    }
                } else if (oldOppty.StageName == 'Handoff') {
                    if (newOppty.StageName != 'Delivery') {
                        if (newOppty.L2I_Product_Category__c != 'DSS' &&
                              newOppty.L2I_Product_Category__c != 'PTS') {
                            newOppty.addError('Handoff Stage may only move to previous Stage for PTS and DSS Product Categories');
                        }
                    }
                } else if (newOppty.StageName == 'Delivery') {
                    if (oldOppty.StageName != 'Handoff') {
                        newOppty.addError('Only Handoff Stage can move to Delivery');
                    }
                } else if (newOppty.StageName == 'Handoff') {
                    if (oldOppty.StageName != 'Closed Won' &&
                          newOppty.L2I_Product_Category__c != 'PTS') {
                        newOppty.addError('Only Closed Won Stage can move to Handoff');
                    } else {
                        newOppty.PT_Part_List_Document_Generated__c = false;
                        newOppty.PT_PL_Batch_In_Process__c = true;
                    }
                } else if (newOppty.StageName == 'Closed Won') {
                    if (newOppty.L2I_Product_Category__c != 'PTS') {
                        if (oldOppty.Probability >= 100) {
                            newOppty.addError('Future Stages may not move to Closed Won');
                        }
                        if ((newOppty.L2I_Product_Category__c == 'IFEC' ||
                              newOppty.RecordTypeId == pplTypeId) &&
                              (oldOppty.StageName == 'Handoff' ||
                              oldOppty.StageName == 'Delivery')){
                            newOppty.addError('Stages Handoff and Delivery may not move to Closed Won for IFEC or PPL');
                        }
                        if (newOppty.L2I_Product_Category__c == 'DSS' &&
                              oldOppty.StageName == 'Delivery'){
                            newOppty.addError('Delivery Stage may not move to Closed Won for DSS');
                        }
                    }
                }
            }
        }
        System.debug('*** Ending PT_Opportunity_TriggerFunctions.validateStageChange');
    }

    public static void resetRejectedRecalled(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap) {
        System.debug('*** Starting PT_Opportunity_TriggerFunctions.resetRejectedRecalled');
        for (Opportunity newOpp : newOpportunityList) {
            Opportunity oldOpp = oldOpportunityMap.get(newOpp.Id);
            if (newOpp.PT_PL_Approval_Status__c != oldOpp.PT_PL_Approval_Status__c &&
                    (newOpp.PT_PL_Approval_Status__c == 'Rejected' || newOpp.PT_PL_Approval_Status__c == 'Recalled')) {
                System.debug('*** Reset Rejected/Recalled Opportunity: ' + newOpp.Name);
                newOpp.PT_Part_List_Document_Generated__c = true;
                newOpp.PT_PL_Batch_In_Process__c = false;
            }
        }
        System.debug('*** Exiting PT_Opportunity_TriggerFunctions.resetRejectedRecalled');
    }

    /*
    * @author           Lipton Abillar
    * @date             08/18/2021
    * @workitem         W-003404
    * @description      Roll-up summary for the latest PPL revision for each PPL Type
    * @trigger          PT_Opportunity_TriggerHandler.afterUpdate()
    *
    * Developer:        Lipton Abillar      08/18/2021      Create
    */
    public static void updateProgramLatestPPLRollup(List<Opportunity> newOpportunityList) {
        List<Opportunity> pplOpportunities = new List<Opportunity>();

        for (Opportunity opp : newOpportunityList) {
            if (opp.PT_Is_PPL__c && opp.StageName == 'Delivery') {
                pplOpportunities.add(opp);
            }
        }

        Map<Id, List<Opportunity>> programRelatedPPL = getProgramRelatedPPL(pplOpportunities);

        List<PT_Program__c> programsToUpdate = new List<PT_Program__c>();

        for (Id programId : programRelatedPPL.keySet()) {
            programsToUpdate.add(new PT_Program__c(Id = programId, Latest_PPL_Revision_Rollup__c = getLatestPPLRevisions(programRelatedPPL.get(programId))));
        }

        if (!programsToUpdate.isEmpty()) {
            update programsToUpdate;
        }
    }

    // Added by Lipton for W-003404
    // A utility method to get the latest Revisions of PPL per PPL Type
    public static String getLatestPPLRevisions(List<Opportunity> pplOpps) {
        Map<String, PPLRevisionWrapper> latestRevisions= new Map<String, PPLRevisionWrapper>();
        String result = '';

        if (!pplOpps.isEmpty()) {
            for (Opportunity opp : pplOpps) {
                if(opp.PT_Parts_List_Revision_Number__c != null) {
                    if (!latestRevisions.containsKey(opp.PT_PPL_Type__c)) {
                        latestRevisions.put(opp.PT_PPL_Type__c, new PPLRevisionWrapper(opp.PT_Parts_List_Revision_Number__c, opp.PT_Part_List_Name_Rev__c, opp.Id));
                    } else if (opp.PT_Parts_List_Revision_Number__c > latestRevisions.get(opp.PT_PPL_Type__c).revisionNumber) {
                        latestRevisions.get(opp.PT_PPL_Type__c).revisionNumber = opp.PT_Parts_List_Revision_Number__c;
                        latestRevisions.get(opp.PT_PPL_Type__c).revisionName = opp.PT_Part_List_Name_Rev__c;
                        latestRevisions.get(opp.PT_PPL_Type__c).oppId = opp.Id;
                    }
                }
            }
        }

        if (!latestRevisions.isEmpty()) {
            for (PPLRevisionWrapper rev : latestRevisions.values()) {
                result += rev.oppId + '; ';
            }
        }

        return result;
    }

    public class PPLRevisionWrapper {
        Decimal revisionNumber { get; set;}
        String revisionName { get; set; }
        Id oppId { get; set; }

        public PPLRevisionWrapper(Decimal revisionNumber, String revisionName, Id oppId) {
            this.revisionNumber = revisionNumber;
            this.revisionName = revisionName;
            this.oppId = oppId;
        }
    }

    /*
    * @author           Lipton Abillar
    * @date             10/08/2021
    * @workitem         W-004007
    * @description      Clear some fields when Opportunity is being cloned
    * @trigger          PT_Opportunity_TriggerHandler.beforeInsert()
    *
    * Developer:        Lipton Abillar      10/08/2021      Create
    */
    public static void clearFieldsWhenCloning(List<Opportunity> newOpportunityList) {
        for (Opportunity opp : newOpportunityList) {
            if (opp.isClone()) {
                opp.PT_Price_List__c = null;
                opp.PT_PL_Approval_Date__c = null;
                opp.PT_PL_Approval_Status__c = null;
                opp.PT_PL_Approval_Submitted_Date__c = null;
            }
        }
    }

    /*
    * @author           Lipton Abillar
    * @date             10/19/2021
    * @workitem         W-003446
    * @description      Align CPL Revision to Primary Quotes
    * @trigger          PT_Opportunity_TriggerHandler.afterUpdate()
    *
    * Developer:        Lipton Abillar      10/19/2021      Create
    */
    public static void alignPrimaryQuotesCPL(List<Opportunity> newOpportunityList, Map<Id,Opportunity> newOpportunityMap, Map<Id, Opportunity> oldOpportunityMap) {
        Set<Id> primaryQuotesId = new Set<Id>();
        
        for (Opportunity opp : newOpportunityList) {
            if (opp.PT_Parts_List_Revision_Number__c != oldOpportunityMap.get(opp.Id).PT_Parts_List_Revision_Number__c
                || opp.SBQQ__PrimaryQuote__c != oldOpportunityMap.get(opp.Id).SBQQ__PrimaryQuote__c) {
                primaryQuotesId.add(opp.SBQQ__PrimaryQuote__c);
            }
        }

        if (!primaryQuotesId.isEmpty()) {
            List<SBQQ__Quote__c> primaryQuotes = [SELECT Id, L2I_Current_CPL_Text__c, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id IN :primaryQuotesId AND ApprovalStatus__c != 'Approved'];
            if (!primaryQuotes.isEmpty()) {
                for (SBQQ__Quote__c quote : primaryQuotes) {
                    quote.L2I_Current_CPL_Text__c = newOpportunityMap.get(quote.SBQQ__Opportunity2__c).PT_Part_List_Name_Rev__c;
                }
                update primaryQuotes;
            }
        }
    }
}