/**
 *      @author       Raj Rajen
 *      @date         07/12/2019
 *      @description  L2I Opportunity Trigger Functions
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/12/2019         Initial scaffold
 *      Sarah Kennedy                 12/12/2019         Added validatePLApproval method
 *      Sarah Kennedy                 01/28/2020         Added updateAmendmentRenewalFields method
 *      Sarah Kennedy                 03/11/2020         Modified Renewal Opportunity Name on insert to be of format 'Renewal for  contract# 0000000'
 *      Sarah Kennedy                 03/26/2020         US1708 - copy Program Nbr to Amendments/Renewals
 *      Sarah Kennedy                 03/27/2020         validatePLApproval method needs to consider user 'Automated Process' like a Sys Admin
 *      Sarah Kennedy                 04/10/2020         US1756 P&L Approvals for Amendments
 *      Sarah Kennedy                 04/29/2020         US1749 TA3091 - Populate Amendment and Renewal with PO Issuer and Aircraft Owner
 *      Sarah Kennedy                 04/30/2020         US1823 TA3095 - Added check for 'Closed' for Amendment StageName change
 *      Sarah Kennedy                 05/01/2020         US1824 - Validate P&L Approvals - Renewal requires, Amendment requires if all quote linnes have not been canceled
 *      Sarah Kennedy                 05/02/2020         US1837 - Added to populate new Renewal and Amendments Original Opportunity
 *      Sarah Kennedy                 06/17/2020         Changed to use getRecordTypeInfosByDeveloperName() (API Name) instead of getRecordTypeInfosByName() (label)
 *      Sarah Kennedy                 06/30/2020         US2063 Autoextend - set oppty fields
 *      Queenie Ong                   08/20/2021         W-3873, Added Price List auto populated based from Original Opportunity if the Product Type is DSS in updateAmendmentRenewalFields method
 *      Khrisna Elumba                06/10/2022         W-004450 added updatePLAutomatedSalesOppDesc to update Automated Sales Opp Description on P&L
 */

public without sharing class L2I_Opportunity_TriggerFunctions {

    /**
    public static void processOpportunityUpdate(List<Opportunity> newOpportunityList,
                                                Map<Id,Opportunity> newOpportunityMap,
                                                Map<Id,Opportunity> oldOpportunityMap) {
        System.debug('====== Number of Opportunities to be updated :' + newOpportunityList.size());

        for (Opportunity oppty : newOpportunityList) {
            Opportunity oldOpportunity = oldOpportunityMap.get(oppty.Id);
            Opportunity newOpportunity = newOpportunityMap.get(oppty.Id);

            if (newOpportunity.Amount != null && newOpportunity.Amount != oldOpportunity.Amount) {
                System.debug('====== Amount has changed on the Opportunity from ' + oldOpportunity.Amount + ' to ' + newOpportunity.Amount);

            }
        }

        // since this is a before Update function there is *NO NEED* to call 'update' explicitly
        // the platform will do that for us.
    }
    **/


    public static void rollupParentOpportunityAmount(List<Opportunity> newOpportunityList) {
        System.debug('====== Number of opportunities :' + newOpportunityList.size());
        //updateParentOpportunityAmount(newOpportunityList);
        recalculateParentOpportunityAmount(newOpportunityList);
    }

    public static void rollupParentOpportunityAmount(List<Opportunity> newOpportunityList,
                                                         Map<Id, Opportunity> newOpportunityMap,
                                                         Map<Id, Opportunity> oldOpportunityMap) {

        List<Opportunity> affectedOpptys = new List<Opportunity>();
        for (Opportunity oppty : newOpportunityList) {
            Opportunity oldOppty = oldOpportunityMap.get(oppty.Id);
            Opportunity newOppty = newOpportunityMap.get(oppty.Id);

            if (newOppty.Amount != null && (newOppty.Amount != oldOppty.Amount || newOppty.Probability != oldOppty.Probability)) {
                System.debug('====== Amount has changed on the Opportunity from ' + oldOppty.Amount + ' to ' + newOppty.Amount);
                affectedOpptys.add(oppty);
            }
        }

        if (affectedOpptys.isEmpty()) {
            return;
        }
        recalculateParentOpportunityAmount(newOpportunityList);
    }


    public static void recalculateParentOpportunityAmount(List<Opportunity> incomingOpportunityList) {

        System.debug('====== executing recalculateParentOpportunityAmount');
        System.debug('====== incoming opptyList :' + incomingOpportunityList);


        /**
        * The following mechanism of obtaining a list works only in insert and update context
        * but not in the delete context. Perhaps because of the keySet()
        *
        System.debug('====== executing updateParentOpportunityAmount');
        System.debug('====== incoming opptyList :' + incomingOpportunityList);
        List<Opportunity> opptys = [select Id,
                                           Name,
                                           Amount,
                                           L2I_Parent_Opportunity__c,
                                           RecordTypeId, RecordType.DeveloperName
                                      from Opportunity
                                     where Id in :new Map<Id,Opportunity>(incomingOpportunityList).keySet()];
        System.debug('====== queried opptyList :' + opptys);
        **/

        Set<Id> parentOpptyIds = new Set<Id>();
        for (Opportunity oppty : incomingOpportunityList) {
            if (oppty.L2I_Parent_Opportunity__c != null) {
                parentOpptyIds.add(oppty.L2I_Parent_Opportunity__c);
            }
        }

        if (parentOpptyIds.isEmpty()) {
            System.debug('====== No parent opptys found to update');
            return;
        }

        System.debug('====== Number of affected parent Opportunities :' + parentOpptyIds.size());

        // Parent Opportunity's Amount has to be recalculated based on all the child opportunities
        // it can't be simply added to existing Amount as that will result in incorrect values

        // First get all the affected parent opportunities
        Map<Id, Opportunity> parentOpptyLookup = new Map<Id, Opportunity>([select Id,
                                                                                  Name,
                                                                                  Amount,
                                                                                  Probability,
                                                                                  RecordType.DeveloperName
                                                                             from Opportunity
                                                                            where Id in :parentOpptyIds]);

        System.debug('====== Number of parentOpptyLookup entries :' + parentOpptyLookup.size());


        // Next get all the children of the affected parent opportunities
        Map<Id, Opportunity> childOpptyLookup =  new Map<Id, Opportunity>([select Id,
                                                                                  Name,
                                                                                  Amount,
                                                                                  Probability,
                                                                                  L2I_Parent_Opportunity__c,
                                                                                  RecordType.DeveloperName
                                                                             from Opportunity
                                                                            where L2I_Parent_Opportunity__c in :parentOpptyIds]);

        System.debug('====== Number of childOpptyLookup entries :' + childOpptyLookup.size());


        // Now recalculate the Amount for each parent opportunity based on the children's amounts
        for (Opportunity parentOppty : parentOpptyLookup.values()) {
            List<Opportunity> childOpportunities = new List<Opportunity>();

            for (Opportunity childOppty : childOpptyLookup.values()) {
                if (childOppty.L2I_Parent_Opportunity__c == parentOppty.Id) {
                    childOpportunities.add(childOppty);
                }
            }

            Double childAmountSum = 0.0;
            for (Opportunity child : childOpportunities) {
                if (child.Amount != null && child.Probability!=null && child.Probability>0) {
                    childAmountSum = childAmountSum + child.Amount;
                }
            }

            parentOppty.Amount = childAmountSum;
        }

        // Lastly update the parent records
        List<Opportunity> parentOpptys = parentOpptyLookup.values();
        update parentOpptys;

    }

    public static void validatePLApproval(List<Opportunity> newOpportunityList,
          Map<Id, Opportunity> newOpportunityMap,
          Map<Id, Opportunity> oldOpportunityMap) {

        Set<Id> oppIds = new Set<Id>();
        Id userProfileId = UserInfo.getProfileId();
        String userProfileName = '';
        Id userId = UserInfo.getUserId();
        String userName = UserInfo.getUserName();
        System.debug('*** userName ' + userName);
        if (!userName.startsWith('autoproc')) {      // Automated Process user has no profile - it's an internal fake user
            userProfileName = [SELECT Id, Name FROM Profile WHERE Id = :userProfileId].Name;
            System.debug('====== Running user profile name :' + userProfileName);
        }

        // no error for System Administrators
        if (userProfileName != 'System Administrator' && userProfileName != '' && !userName.startsWith('autoproc')) {
            Id SalesRecordTypeId = L2I_UtilityHelper.getRecordTypeId('Sales', 'Opportunity');
            Id AmendmentRecordTypeId = L2I_UtilityHelper.getRecordTypeId('Amendment', 'Opportunity');
            Id RenewalRecordTypeId = L2I_UtilityHelper.getRecordTypeId('Renewal', 'Opportunity');
            Id PPLRecordTypeId = L2I_UtilityHelper.getRecordTypeId('PPL', 'Opportunity');
            // save Amendment Opportunities
            Set<Id> amendmentOpps = new Set<Id>();
            for (Opportunity opp : newOpportunityList){
                System.debug('*** opp ' + opp);
                System.debug('*** opp.RecordTypeId ' + opp.RecordTypeId);
                System.debug('*** AmendmentRecordTypeId ' + AmendmentRecordTypeId);
                if (opp.RecordTypeId == AmendmentRecordTypeId){
                    amendmentOpps.add(opp.Id);
                }
            }
            // identify the Amendment Opportunities with non-canceled quotelines
            Set<Id> oppsWithLines = new Set<Id>();
            for (SBQQ__Quote__c quote : [
                  SELECT Id, SBQQ__Type__c,SBQQ__Opportunity2__c, (
                        SELECT Id, Name, SBQQ__Product__c, SBQQ__ProductCode__c, SBQQ__Quantity__c, SBQQ__Bundle__c
                        FROM SBQQ__LineItems__r
                        WHERE SBQQ__Quantity__c > 0
                        AND SBQQ__Bundle__c = FALSE
                  )
                  FROM SBQQ__Quote__c
                  WHERE SBQQ__Type__c = 'Amendment'
                  AND SBQQ__Primary__c = TRUE
                  AND SBQQ__Opportunity2__c IN :amendmentOpps
            ]) {
                for (SBQQ__QuoteLine__c qLine : quote.SBQQ__LineItems__r) {
                    oppsWithLines.add(quote.SBQQ__Opportunity2__c);
                }
            }
            System.debug('*** oppsWithLines ' + oppsWithLines);

            for (Opportunity oppty : newOpportunityList) {
                Opportunity oldOppty = oldOpportunityMap.get(oppty.Id);
                Opportunity newOppty = newOpportunityMap.get(oppty.Id);
                // applying validation to PPL opportunity as well.
                if (((newOppty.RecordTypeId == SalesRecordTypeId) || (newOppty.RecordTypeId == PPLRecordTypeId) ||
                      (newOppty.RecordTypeId == RenewalRecordTypeId && !newOppty.l2i_AutoExtend__c) ||
                      (newOppty.RecordTypeId == AmendmentRecordTypeId &&
                          newOppty.Amount != null &&
                          newOppty.Amount != 0 &&
                          oppsWithLines.contains(newOppty.Id))) &&
                      newOppty.StageName != null &&
                      !newOppty.L2I_Legacy_Opportunity__c &&
                      (newOppty.StageName == 'Pending Close' || newOppty.StageName == 'Closed' || newOppty.StageName == 'Closed Won') &&
                      newOppty.StageName != oldOppty.StageName) {
                    System.debug('====== StageName has changed on the Opportunity from ' + oldOppty.StageName + ' to ' + newOppty.StageName);
                    oppIds.add(oppty.Id);
                }
            }
        }

        if (oppIds.isEmpty()) {
            return;
        }
        // make sure each Sales Opp has at least one P&L Approval
        // W-004410: Ajo, Leah: add Change_Request__c
        for (Opportunity oppty : [
              SELECT Id, Name, Change_Request__c, (
                    SELECT
                          L2I_P_L_Approval__r.ApprovalStatus__c,
                          L2I_P_L_Approval__r.Name
                    FROM
                          Opportunities_Related_To_P_L__r
                    WHERE L2I_P_L_Approval__r.ApprovalStatus__c = 'Approved'
                      AND (L2I_P_L_Approval__r.L2I_Revision_Status__c = 'Award'
                        OR L2I_P_L_Approval__r.L2I_Revision_Status__c = 'Contract Signed')
              )
              FROM
                    Opportunity
              WHERE Id IN :oppIds
        ]) {
            Boolean foundApproval = false;
            for (L2I_P_L_Sales_Opportunity__c plSalesOpp : oppty.Opportunities_Related_To_P_L__r) {
                foundApproval = true;
                break;
            }
            // W-004410: Ajo, Leah: add CR Opp validation
            if (!oppty.Change_Request__c && !foundApproval){
                newOpportunityMap.get(oppty.Id).addError(Label.P_L_Approval_Required);
            }
        }
    }

    public static void updateAmendmentRenewalFields(List<Opportunity> newOpportunityList) {
        Id amendmentId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        Id renewalId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Set<Id> amendmentRenewalIds = new Set<Id>();
        Map<Id, Contract> amendmentRenewalMap = new Map<Id, Contract>();

        // find any amendment or renewal opportunities
        for (Opportunity oppty : newOpportunityList) {
            System.debug('*** oppty Id ' + oppty.Id);
            System.debug('*** oppty.SBQQ__AmendedContract__c ' + oppty.SBQQ__AmendedContract__c);
            System.debug('*** oppty.SBQQ__RenewedContract__c ' + oppty.SBQQ__RenewedContract__c);
            if (oppty.SBQQ__AmendedContract__c != null) {
                amendmentRenewalIds.add(oppty.SBQQ__AmendedContract__c);
            }
            if (oppty.SBQQ__RenewedContract__c != null) {
                amendmentRenewalIds.add(oppty.SBQQ__RenewedContract__c);
            }
        }

        if (!amendmentRenewalIds.isEmpty()){
            // get the contract data and save to a map
            for (Contract cntrt : [
                  SELECT Id,
                        ContractNumber, //SBQQ__RenewalPricebookId__c,
                        SBQQ__Opportunity__r.L2I_AC_Operator__c,
                        SBQQ__Opportunity__r.L2I_AircraftQuantity__c,
                        SBQQ__Opportunity__r.L2I_Aircraft_Type__c,
                        SBQQ__Opportunity__r.L2I_Delivery_Schedule__c,
                        SBQQ__Opportunity__r.L2I_Parent_Opportunity__c,
                        SBQQ__Opportunity__r.L2I_Product_Category__c,
                        //SBQQ__Opportunity__r.Pricebook2Id,
                        SBQQ__Opportunity__r.AccountId,
                        SBQQ__Opportunity__r.L2I_Fit_Type__c,
                        SBQQ__Opportunity__r.StageName,
                        SBQQ__Opportunity__r.L2I_Warranty__c,
                        SBQQ__Opportunity__r.L2I_Route_Supported__c,
                        SBQQ__Opportunity__r.L2I_Are_any_of_these_AC_to_be_leased__c,
                        SBQQ__Opportunity__r.L2I_Aircraft_Quantity_Option__c,
                        SBQQ__Opportunity__r.L2I_Are_These_Follow_On_Aircraft__c,
                        SBQQ__Opportunity__r.L2I_Are_These_Partial_Shipsets__c,
                        SBQQ__Opportunity__r.L2I_Business_Initiative__c,
                        SBQQ__Order__r.L2I_Program_Number__c,
                        SBQQ__Opportunity__r.L2I_PO_Issuer__c,
                        SBQQ__Opportunity__r.L2I_Aircraft_Owner__c,
                        SBQQ__Order__r.L2I_Original_Sales_Opportunity__c,
                        SBQQ__Opportunity__r.PT_Price_List__c, //W-3873
                        L2I_Last_Auto_Extend_Processed__c
                  FROM Contract
                  WHERE Id IN :amendmentRenewalIds
            ]) {
                amendmentRenewalMap.put(cntrt.Id, cntrt);
            }

            if (!amendmentRenewalMap.isEmpty()) {
                // assign Contract values to Opportunity
                Contract cont;
                Id recordTypeId;
                Boolean isRenewal;
                for (Opportunity oppty2 : newOpportunityList) {
                    isRenewal = false;
                    cont = null;
                    if (oppty2.SBQQ__AmendedContract__c != null) {
                        cont = amendmentRenewalMap.get(oppty2.SBQQ__AmendedContract__c);
                        recordTypeId = amendmentId;
                    }
                    if (oppty2.SBQQ__RenewedContract__c != null) {
                        cont = amendmentRenewalMap.get(oppty2.SBQQ__RenewedContract__c);
                        isRenewal = true;
                        recordTypeId = renewalId;
                    }
                    if (cont != null) {
                        System.debug('*** cont.ContractNumber ' + cont.ContractNumber);
                        System.debug('*** isRenewal ' + isRenewal);
                        System.debug('*** cont.SBQQ__Opportunity__r.L2I_Product_Category__c ' + cont.SBQQ__Opportunity__r.L2I_Product_Category__c);
                        if (isRenewal){
                            oppty2.Name = 'Revise for contract #' + cont.ContractNumber;
                            // autoextend change
                            System.debug('*** autoextend ' + cont.L2I_Last_Auto_Extend_Processed__c );
                            if (cont.L2I_Last_Auto_Extend_Processed__c != NULL){
                                oppty2.CloseDate = Date.today();
                                oppty2.L2I_AutoExtend__c = true;
                            }
                            //W-3873
                            /*
                            if ('DSS' == cont.SBQQ__Opportunity__r.L2I_Product_Category__c){
                                oppty2.PT_Price_List__c = cont.SBQQ__Opportunity__r.PT_Price_List__c;
                            }*/
                            
                        }else {
                            oppty2.Name = 'Cancellation for contract #' + cont.ContractNumber;
                        }
                        oppty2.L2I_AC_Operator__c = cont.SBQQ__Opportunity__r.L2I_AC_Operator__c;
                        oppty2.L2I_AircraftQuantity__c = cont.SBQQ__Opportunity__r.L2I_AircraftQuantity__c;
                        oppty2.L2I_Aircraft_Type__c = cont.SBQQ__Opportunity__r.L2I_Aircraft_Type__c;
                        oppty2.L2I_Delivery_Schedule__c = cont.SBQQ__Opportunity__r.L2I_Delivery_Schedule__c;
                        oppty2.Original_DSH__c = cont.SBQQ__Opportunity__r.L2I_Delivery_Schedule__c;
                        oppty2.L2I_Parent_Opportunity__c = cont.SBQQ__Opportunity__r.L2I_Parent_Opportunity__c;
                        oppty2.L2I_Product_Category__c = cont.SBQQ__Opportunity__r.L2I_Product_Category__c;

                        // update the opportunity price book from Contract renewal price book.
                        /**System.debug('====== Contract Renewal Pricebook ====' + cont.SBQQ__RenewalPricebookId__c);
                        if (Cont.SBQQ__RenewalPricebookId__c != null && isRenewal) {
                            System.debug('===== inside Setting renewal price book id====');
                                oppty2.Pricebook2Id = cont.SBQQ__RenewalPricebookId__c;
                        } else {
                            System.debug('===== outside Setting renewal price book id====');
                            oppty2.Pricebook2Id = cont.SBQQ__Opportunity__r.Pricebook2Id;
                        } **/
                        oppty2.L2I_Deal_Account__c = null;
                        oppty2.AccountId = cont.SBQQ__Opportunity__r.AccountId;
                        oppty2.L2I_Fit_Type__c =
                              (cont.SBQQ__Opportunity__r.L2I_Product_Category__c == 'DSS' && isRenewal)
                                    ? 'Renewal'
                                    : cont.SBQQ__Opportunity__r.L2I_Fit_Type__c;
                        oppty2.StageName = 'Quotation';
                        oppty2.L2I_Warranty__c = cont.SBQQ__Opportunity__r.L2I_Warranty__c;
                        oppty2.L2I_Route_Supported__c = cont.SBQQ__Opportunity__r.L2I_Route_Supported__c;
                        oppty2.L2I_Are_any_of_these_AC_to_be_leased__c = cont.SBQQ__Opportunity__r.L2I_Are_any_of_these_AC_to_be_leased__c;
                        oppty2.L2I_Aircraft_Quantity_Option__c = cont.SBQQ__Opportunity__r.L2I_Aircraft_Quantity_Option__c;
                        oppty2.L2I_Are_These_Follow_On_Aircraft__c = cont.SBQQ__Opportunity__r.L2I_Are_These_Follow_On_Aircraft__c;
                        oppty2.L2I_Are_These_Partial_Shipsets__c = cont.SBQQ__Opportunity__r.L2I_Are_These_Partial_Shipsets__c;
                        oppty2.L2I_Business_Initiative__c = cont.SBQQ__Opportunity__r.L2I_Business_Initiative__c;
                        oppty2.RecordTypeId = recordTypeId;
                        oppty2.L2I_Program_Number__c = cont.SBQQ__Order__r.L2I_Program_Number__c;
                        oppty2.L2I_PO_Issuer__c = cont.SBQQ__Opportunity__r.L2I_PO_Issuer__c;
                        oppty2.L2I_Aircraft_Owner__c = cont.SBQQ__Opportunity__r.L2I_Aircraft_Owner__c;
                        oppty2.L2I_Original_Opportunity__c = cont.SBQQ__Order__r.L2I_Original_Sales_Opportunity__c;
                    }
                }
            }
        }
    }

    public static void updateAmendmentRenewalRelatedLists(List<Opportunity> newOpportunityList) {
        System.debug('*** in updateAmendmentRenewalRelatedLists');
        System.debug('*** newOpportunityList ' + newOpportunityList);
        Map<Id, Id> contractNewOpp = new Map<Id, Id>();
        Map<Id, Id> salesOppNewOpp = new Map<Id, Id>();
        List<L2I_Competitors__c> competitors = new List<L2I_Competitors__c>();
        List<OpportunityTeamMember> teamMembers = new List<OpportunityTeamMember>();

        // find any amendment or renewal opportunities
        for (Opportunity oppty : newOpportunityList) {
            System.debug('*** oppty Id ' + oppty.Id);
            System.debug('*** oppty.SBQQ__AmendedContract__c ' + oppty.SBQQ__AmendedContract__c);
            System.debug('*** oppty.SBQQ__RenewedContract__c ' + oppty.SBQQ__RenewedContract__c);
            if (oppty.SBQQ__AmendedContract__c != null) {
                contractNewOpp.put(oppty.SBQQ__AmendedContract__c, oppty.Id);
            }
            if (oppty.SBQQ__RenewedContract__c != null) {
                contractNewOpp.put(oppty.SBQQ__RenewedContract__c, oppty.Id);
            }
            System.debug('*** contractNewOpp ' + contractNewOpp);
        }

        if (!contractNewOpp.isEmpty()) {
            // get the contract opportunity and save to a map
            for (Contract cntrt : [
                  SELECT Id,
                        SBQQ__Opportunity__c
                  FROM Contract
                  WHERE Id IN :contractNewOpp.keySet()
            ]) {
                salesOppNewOpp.put(cntrt.SBQQ__Opportunity__c, contractNewOpp.get(cntrt.Id));
            }
            System.debug('*** salesOppNewOpp ' + salesOppNewOpp);

            if (!salesOppNewOpp.isEmpty()) {
                String salesOppIn = '';
                for (Id soId : salesOppNewOpp.keySet()) {
                    if (salesOppIn != '') {
                        salesOppIn += ',';
                    }
                    salesOppIn += '\'' + soId + '\'';
                }

                // Competitors
                String competitorQuery = String.format(
                      'SELECT {0} FROM L2I_Competitors__c WHERE Opportunity__c IN ({1})',
                      new String[]{
                            String.join(
                                  new List<String>(
                                        L2I_Competitors__c.SObjectType.getDescribe().fields.getMap().keySet()
                                  ),
                                  ','
                            ),
                            salesOppIn
                      }
                );
                System.debug('*** competitorQuery ' + competitorQuery);

                // copy the competitors to the amendment/renewal opportunity
                for (L2I_Competitors__c competitor : (List<L2I_Competitors__c>) Database.query(competitorQuery)) {
                    competitors.add(competitor.clone(false, true, false, false));
                }
                if (!competitors.isEmpty()) {
                    System.debug('L2I_Competitors__c List successfully cloned!');
                }
                for (L2I_Competitors__c comp : competitors) {
                    comp.Opportunity__c = salesOppNewOpp.get(comp.Opportunity__c);
                }

                System.debug('*** competitors ' + competitors.size());
                insert competitors;

                // OpportunityTeamMember
                String teamQuery = String.format(
                      'SELECT {0} FROM OpportunityTeamMember WHERE OpportunityId IN ({1})',
                      new String[]{
                            String.join(
                                  new List<String>(
                                        OpportunityTeamMember.SObjectType.getDescribe().fields.getMap().keySet()
                                  ),
                                  ','
                            ),
                            salesOppIn
                      }
                );
                System.debug('*** teamQuery ' + teamQuery);

                // copy the Opp Team Members to the amendment/renewal opportunity
                for (OpportunityTeamMember team : (List<OpportunityTeamMember>) Database.query(teamQuery)) {
                    teamMembers.add(team.clone(false, true, false, false));
                }
                if (!teamMembers.isEmpty()) {
                    System.debug('OpportunityTeamMember List successfully cloned!');
                }
                for (OpportunityTeamMember team : teamMembers) {
                    team.OpportunityId = salesOppNewOpp.get(team.OpportunityId);
                }

                System.debug('*** teamMembers ' + teamMembers.size());
                insert teamMembers;
            }
        }
    }
    /*
    public static void validatePriceOnQuote(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Map<Id, Opportunity> closingOpps = new Map<Id, Opportunity>();
        for(Opportunity opp: newList) {
            if(opp.StageName != oldMap.get(opp.Id).StageName && (opp.StageName == 'Pending Close' || opp.StageName == 'Closed Won')) {
                closingOpps.put(opp.Id, opp);
            }
        }

        if(closingOpps.isEmpty()) { return; }

        Map<Id, SBQQ__Quote__c> quotes = new Map<Id, SBQQ__Quote__c>([Select Id, Name, SBQQ__Opportunity2__c, (Select Id, SBQQ__NetPrice__c, SBQQ__Group__c, SBQQ__Product__c From SBQQ__LineItems__r) From SBQQ__Quote__c Where SBQQ__Opportunity2__c IN :closingOpps.keySet() And SBQQ__Primary__c = True]);

        // Map<OpportunityId, Map<ProductId, Map<GroupId, Price>>>
        Map<Id, Map<Id, Map<Id, Decimal>>> oppToProductGroupPrice = new Map<Id, Map<Id, Map<Id, Decimal>>>();
        for(SBQQ__Quote__c quote: quotes.values()) {
            Map<Id, Map<Id, Decimal>> linesData;
            if(oppToProductGroupPrice.containsKey(quote.SBQQ__Opportunity2__c)) {
                linesData = oppToProductGroupPrice.get(quote.SBQQ__Opportunity2__c);
            } else {
                linesData = new Map<Id, Map<Id, Decimal>>();
            }
            for(SBQQ__QuoteLine__c line: quote.SBQQ__LineItems__r) {
                System.debug('line: '+line);
                System.debug('linesData.get(line.SBQQ__Product__c): '+linesData.get(line.SBQQ__Product__c));
                if(linesData.containsKey(line.SBQQ__Product__c) && linesData.get(line.SBQQ__Product__c).values()[0] != line.SBQQ__NetPrice__c) {
                    linesData.get(line.SBQQ__Product__c).put(line.SBQQ__Group__c, line.SBQQ__NetPrice__c);
                }
                if(!linesData.containsKey(line.SBQQ__Product__c)) {
                    linesData.put(line.SBQQ__Product__c, new Map<Id, Decimal>{line.SBQQ__Group__c=>line.SBQQ__NetPrice__c});
                }
            }
            oppToProductGroupPrice.put(quote.SBQQ__Opportunity2__c, linesData);
        }

        for(Opportunity opp: closingOpps.values()) {
            if(oppToProductGroupPrice.containsKey(opp.Id)) {
                Map<Id, Map<Id, Decimal>> linesData = oppToProductGroupPrice.get(opp.Id);
                System.debug('linesData: '+linesData);
                for(Id prodId : linesData.keySet()) {
                    if(linesData.get(prodId).size() > 1) {
                        Decimal oldPrice;
                        for(Decimal price: linesData.get(prodId).values()) {
                            if(oldPrice == null) {oldPrice = price;}
                            else if(oldPrice != null && oldPrice != price) { opp.addError('Please validate product pricing uniqueness across all Quote Lines.'); }
                        }
                    }
                }
            }
        }
    }*/
    
    /**
    * @Method Name        : updateQuoteShipToBillTo
    * @Description        : Updates the Quotes Ship/Bill To address once Oppty Account changes.
    * @Author             : Jan Denrick Geronga / Managed Services Simplus
    * @Modification Log   :
    * Ver       	Date       	  Author              Modification
    * W-003956    	Oct-18-2021   MS Simplus Jan      Initial Version
    **/
    public static void updateQuoteShipToBillTo(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> sOppty = new Set<Id>();
        Map<Id, Opportunity> mOppty = new Map<Id, Opportunity>();
        List<SBQQ__Quote__c> lQuote = new List<SBQQ__Quote__c>();
        for(Opportunity opp : newList) {
            if(opp.AccountId != oldMap.get(opp.Id).AccountId){
                sOppty.add(opp.Id);
            }
        }
        
        for(Opportunity oppty : [SELECT Id, Account.Name, AccountId, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode,
                                 Account.BillingCountry, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, 
                                 Account.ShippingPostalCode, Account.ShippingCountry From Opportunity WHERE ID IN: sOppty]){
                                     mOppty.put(oppty.Id, oppty);
            
        }
        
        for(SBQQ__Quote__c quote: [SELECT Id, SBQQ__Opportunity2__c, SBQQ__ShippingName__c, SBQQ__ShippingCity__c, SBQQ__ShippingCountry__c, SBQQ__ShippingPostalCode__c,
                                   SBQQ__ShippingState__c, SBQQ__ShippingStreet__c, SBQQ__BillingName__c, SBQQ__BillingCity__c, SBQQ__BillingCountry__c, SBQQ__BillingPostalCode__c,
                                   SBQQ__BillingState__c, SBQQ__BillingStreet__c
                                   FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN: mOppty.keySet()]){
                                       quote.SBQQ__Account__c = mOppty.get(quote.SBQQ__Opportunity2__c).AccountId;
                                       quote.SBQQ__ShippingName__c = mOppty.get(quote.SBQQ__Opportunity2__c).Account.Name; 
                                       quote.SBQQ__ShippingCity__c = mOppty.get(quote.SBQQ__Opportunity2__c).Account.ShippingCity; 
                                       quote.SBQQ__ShippingCountry__c = mOppty.get(quote.SBQQ__Opportunity2__c).Account.ShippingCountry;
                                       quote.SBQQ__ShippingPostalCode__c = mOppty.get(quote.SBQQ__Opportunity2__c).Account.ShippingPostalCode;
                                       quote.SBQQ__ShippingState__c = mOppty.get(quote.SBQQ__Opportunity2__c).Account.ShippingState;
                                       quote.SBQQ__ShippingStreet__c = mOppty.get(quote.SBQQ__Opportunity2__c).Account.ShippingStreet; 
                                       quote.SBQQ__BillingName__c = mOppty.get(quote.SBQQ__Opportunity2__c).Account.Name; 
                                       quote.SBQQ__BillingCity__c = mOppty.get(quote.SBQQ__Opportunity2__c).Account.BillingCity;
                                       quote.SBQQ__BillingCountry__c = mOppty.get(quote.SBQQ__Opportunity2__c).Account.BillingCountry;
                                       quote.SBQQ__BillingPostalCode__c = mOppty.get(quote.SBQQ__Opportunity2__c).Account.BillingPostalCode;
                                       quote.SBQQ__BillingState__c = mOppty.get(quote.SBQQ__Opportunity2__c).Account.BillingState;
                                       quote.SBQQ__BillingStreet__c = mOppty.get(quote.SBQQ__Opportunity2__c).Account.BillingStreet;
                                       lQuote.add(quote);
                                   }
        
        if(lQuote.size() > 0){
            update lQuote;
        }
    }
    
    /**
    * @Method Name        : updatePLApprovalSalesOppDesc
    * @Description        : update P&L Approval's Sales Opportunity Description when Sales Opportunity Description is updated
    * @Author             : Francis Jan Macam / Managed Services Simplus
    * @Modification Log   :
    * Ver       	Date       	  Author              Modification
    * W-003708    	Nov-08-2021   MS Simplus Francis  Initial Version
    **/
    public static void updatePLApprovalSalesOppDesc(List<Opportunity> newOpportunityList,
                                                    Map<Id, Opportunity> newOpportunityMap,
                                                    Map<Id, Opportunity> oldOpportunityMap) {
        List<Opportunity> targetOpportunityList = new List<Opportunity>();
        Id recordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        
        for (Opportunity curSalesOpp : newOpportunityList) {
            Opportunity oldSalesOpp = oldOpportunityMap.get(curSalesOpp.Id);
            Opportunity newSalesOpp = newOpportunityMap.get(curSalesOpp.Id);
            
            if (newSalesOpp.Name != oldSalesOpp.Name && newSalesOpp.RecordTypeId == recordTypeId) {                
                targetOpportunityList.add(curSalesOpp);
            }
        }

        if (!targetOpportunityList.isEmpty()) {
            updatePLApprovalSalesOppDesc(targetOpportunityList);
        }
    }
    
    /**
    * @Method Name        : updatePLApprovalSalesOppDesc
    * @Description        : update P&L Approval's Sales Opportunity Description when Sales Opportunity Description is updated
    * @Author             : Francis Jan Macam / Managed Services Simplus
    * @Modification Log   :
    * Ver       	Date       	  Author              Modification
    * W-003708    	Nov-08-2021   MS Simplus Francis  Initial Version
    **/
    public static void updatePLApprovalSalesOppDesc(List<Opportunity> pLsalesList) {
        Set<Id> targetPLApprovalIds = new Set<Id>();
        Map<Id, L2I_P_L_Sales_Opportunity__c> pLSalesOppSubMap =  new Map<Id, L2I_P_L_Sales_Opportunity__c>([SELECT Id, L2I_Sales_Opportunity__c, L2I_P_L_Approval__c 
                                                                                                               FROM L2I_P_L_Sales_Opportunity__c
                                                                                                               WHERE L2I_Sales_Opportunity__c in :pLsalesList]);
        
        for (L2I_P_L_Sales_Opportunity__c pLSalesOpp : pLSalesOppSubMap.values()) {
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
    * @Method Name        : populateOperatorAirlineCode
    * @Description        : update airline code from sales oppty to deal oppty
    * @Author             : Leah Racquel Ajo / Managed Services Simplus
    * @Modification Log   :
    * Ver       	Date       	  Author              Modification
    * W-004424    	May-16-2022   MS Simplus Leah	  Initial Version
    **/
    public static void populateOperatorAirlineCode(List<Opportunity> newOpportunityList) {
        Id recordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Set<Id> operatorIds = new Set<Id> ();
        Set<Id> dealOpptyIds = new Set<Id> ();
        Map<Id,Account> accountMap;
        List<Opportunity> dealOpptyList = new List<Opportunity>();
        Map<Id,Opportunity> salesOpptyMap = new Map<Id,Opportunity>();
        
        for (Opportunity oppty : newOpportunityList) {
            if (oppty.RecordTypeId == recordTypeId) {
                dealOpptyIds.add(oppty.L2I_Parent_Opportunity__c);
                salesOpptyMap.put(oppty.L2I_Parent_Opportunity__c, oppty);
                if (oppty.L2I_AC_Operator__c != null) {
                    operatorIds.add(oppty.L2I_AC_Operator__c);
                }
            }
        }
        
        if (!operatorIds.isEmpty()) {
            accountMap = new Map<Id,Account> ([SELECT Id, L2I_Operator_Number__c FROM Account WHERE ID IN :operatorIds]);
        }
        
        if (!dealOpptyIds.isEmpty()) {
            dealOpptyList = [SELECT Id, L2I_Deal_Opportunity_Description__c, RecordTypeId, AccountId, CreatedDate FROM Opportunity WHERE ID IN :dealOpptyIds];
        }
                
        if (dealOpptyList.size() > 0) {
            String dealDesc;
            String bPillars;
            String newDealDesc;
            String newAirlineCode = '';
            Opportunity dealDescSalesOppty;
            for(Opportunity oppty : dealOpptyList) {
                dealDesc = oppty.L2I_Deal_Opportunity_Description__c;
                if (salesOpptyMap.get(oppty.Id).L2I_AC_Operator__c == null) {
                    newAirlineCode = 'Unavailable';
                } else {
                    if (newAirlineCode != 'Unavailable') {
                        newAirlineCode = salesOpptyMap.get(oppty.Id).L2I_AC_Operator__c;
                        if (accountMap.get(newAirlineCode).L2I_Operator_Number__c == null) {
                            newAirlineCode = 'Unavailable';
                        } else {
                            newAirlineCode = accountMap.get(newAirlineCode).L2I_Operator_Number__c;
                            if (newAirlineCode == null) {
                                newAirlineCode = 'Unavailable';
                            }
                        }
                    }
                }
                newDealDesc = newAirlineCode;
                if (dealDesc != null) {
                    if (dealDesc.contains('/')) {
                        bPillars = dealDesc.split(' / ')[1];
                        newDealDesc = newAirlineCode + ' / ' + bPillars;
                    }
                }
                oppty.L2I_Deal_Opportunity_Description__c = newDealDesc;
                dealDescSalesOppty = salesOpptyMap.get(oppty.Id);
                dealDescSalesOppty.L2I_Deal_Opportunity_Description__c = newDealDesc;
            }
            update dealOpptyList;
        }
    }

    public static void populateOperatorAirlineCode(List<Opportunity> newOpportunityList,
        Map<Id, Opportunity> newOpportunityMap,
        Map<Id, Opportunity> oldOpportunityMap) {

        Id recordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Set<Id> operatorIds = new Set<Id> ();
        Set<Id> dealOpptyIds = new Set<Id> ();
        Map<Id,Account> accountMap;
        List<Opportunity> dealOpptyList = new List<Opportunity>();
        Map<Id,Opportunity> salesOpptyMap = new Map<Id,Opportunity>();
        
        for (Opportunity oppty : newOpportunityList) {
            if (oppty.RecordTypeId == recordTypeId) {                
                if (oppty.L2I_AC_Operator__c != oldOpportunityMap.get(oppty.Id).L2I_AC_Operator__c) {
                    operatorIds.add(oppty.L2I_AC_Operator__c);
                    dealOpptyIds.add(oppty.L2I_Parent_Opportunity__c);
                    salesOpptyMap.put(oppty.L2I_Parent_Opportunity__c, oppty);
                }
            }
        }
        
        if (!operatorIds.isEmpty()) {
            accountMap = new Map<Id,Account> ([SELECT Id, L2I_Operator_Number__c FROM Account WHERE ID IN :operatorIds]);
        }
        
        if (!dealOpptyIds.isEmpty()) {
            dealOpptyList = [SELECT Id, L2I_Deal_Opportunity_Description__c, RecordTypeId, AccountId, CreatedDate FROM Opportunity WHERE ID IN :dealOpptyIds];
        }
                
        if (dealOpptyList.size() > 0) {
            String dealDesc;
            String bPillars;
            String newDealDesc;
            String newAirlineCode = '';
            Opportunity dealDescSalesOppty;
            for(Opportunity oppty : dealOpptyList) {
                dealDesc = oppty.L2I_Deal_Opportunity_Description__c;
                if (salesOpptyMap.get(oppty.Id).L2I_AC_Operator__c == null) {
                    newAirlineCode = 'Unavailable';
                } else {
                    if (newAirlineCode != 'Unavailable') {
                        newAirlineCode = salesOpptyMap.get(oppty.Id).L2I_AC_Operator__c;
                        if (accountMap.get(newAirlineCode).L2I_Operator_Number__c == null) {
                            newAirlineCode = 'Unavailable';
                        } else {
                            newAirlineCode = accountMap.get(newAirlineCode).L2I_Operator_Number__c;
                            if (newAirlineCode == null) {
                                newAirlineCode = 'Unavailable';
                            }
                        }
                    }
                }
                newDealDesc = newAirlineCode;
                if (dealDesc != null) {
                    if (dealDesc.contains('/')) {
                        bPillars = dealDesc.split(' / ')[1];
                        newDealDesc = newAirlineCode + ' / ' + bPillars;
                    }
                }
                oppty.L2I_Deal_Opportunity_Description__c = newDealDesc;
                dealDescSalesOppty = salesOpptyMap.get(oppty.Id);
                dealDescSalesOppty.L2I_Deal_Opportunity_Description__c = newDealDesc;
            }
            update dealOpptyList;
        }
    }
    
    /**
    * @Method Name        : updatePLAutomatedSalesOppDesc
    * @Description        : update P&L Approval's Automated Sales Opportunity Description when Automated Sales Opportunity Description is updated
    * @Author             : Khrisna Elumba / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date            Author              Modification
    * W-004450      Jun-10-2022     MS Simplus Khrisna  Initial Version
    **/
    public static void updatePLAutomatedSalesOppDesc(List<Opportunity> newOpportunityList,
                                                     Map<Id, Opportunity> newOpportunityMap,
                                                     Map<Id, Opportunity> oldOpportunityMap) {
        List<Opportunity> targetOpportunityList = new List<Opportunity>();
        Id recordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Sales').getRecordTypeId();

        for (Opportunity curSalesOpp : newOpportunityList) {
            Opportunity oldSalesOpp = oldOpportunityMap.get(curSalesOpp.Id);
            Opportunity newSalesOpp = newOpportunityMap.get(curSalesOpp.Id);

            if (newSalesOpp.L2I_Sales_Opportunity_Description__c != oldSalesOpp.L2I_Sales_Opportunity_Description__c 
                && newSalesOpp.RecordTypeId == recordTypeId) {
                targetOpportunityList.add(curSalesOpp);
            }
        }

        if (!targetOpportunityList.isEmpty()) {
            updatePLAutomatedSalesOppDesc(targetOpportunityList);
        }
    }

    /**
    * @Method Name        : updatePLAutomatedSalesOppDesc
    * @Description        : update P&L Approval's Automated Sales Opportunity Description when Automated Sales Opportunity Description is updated
    * @Author             : Khrisna Elumba / Managed Services Simplus
    * @Modification Log   :
    * Ver           Date            Author              Modification
    * W-004450      Jun-10-2022     MS Simplus Khrisna  Initial Version
    **/
    public static void updatePLAutomatedSalesOppDesc(List<Opportunity> opportunityList) {
        Set<Id> targetPLApprovalIds = new Set<Id>();
        Id recordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        Map<Id, L2I_P_L_Sales_Opportunity__c> pLSalesOppSubMap =  new Map<Id, L2I_P_L_Sales_Opportunity__c>([SELECT Id, L2I_Sales_Opportunity__c, L2I_P_L_Approval__c 
                                                                                                               FROM L2I_P_L_Sales_Opportunity__c
                                                                                                               WHERE L2I_Sales_Opportunity__c in :opportunityList]);
        
        for (L2I_P_L_Sales_Opportunity__c pLSalesOpp : pLSalesOppSubMap.values()) {
            if (pLSalesOpp.L2I_P_L_Approval__c != null) {
                targetPLApprovalIds.add(pLSalesOpp.L2I_P_L_Approval__c);
            }
        }

        if (!targetPLApprovalIds.isEmpty()) {
            Map<Id, L2I_P_L_Approval__c> pLApprovalMap = new Map<Id, L2I_P_L_Approval__c>([SELECT Id, Automated_Sales_Opportunity_Description__c,
                                                                                           L2I_Approval_Deal_Opportunity__r.RecordtypeId,
                                                                                           L2I_Approval_Deal_Opportunity__c
                                                                                           FROM L2I_P_L_Approval__c
                                                                                           WHERE Id IN :targetPLApprovalIds]);
            Map<Id, L2I_P_L_Sales_Opportunity__c> pLSalesOppMap = new Map<Id, L2I_P_L_Sales_Opportunity__c>([SELECT Id, 
                                                                                                             L2I_Sales_Opportunity__r.L2I_Sales_Opportunity_Description__c, 
                                                                                                             L2I_P_L_Approval__c 
                                                                                                             FROM L2I_P_L_Sales_Opportunity__c
                                                                                                             WHERE L2I_P_L_Approval__c IN :pLApprovalMap.keySet()]);
            for (L2I_P_L_Approval__c pLApproval : pLApprovalMap.values()) {
                pLApproval.Automated_Sales_Opportunity_Description__c = '';
                if(pLApproval.L2I_Approval_Deal_Opportunity__c != null && pLApproval.L2I_Approval_Deal_Opportunity__r.RecordtypeId == recordTypeId){
                    for (L2I_P_L_Sales_Opportunity__c pLSalesOpp : pLSalesOppMap.values()) {
                        if (pLSalesOpp.L2I_P_L_Approval__c == pLApproval.Id) {
                            if(!String.isEmpty(pLApproval.Automated_Sales_Opportunity_Description__c)){
                                pLApproval.Automated_Sales_Opportunity_Description__c += '; ';
                            }
                            String automatedSOppDescription = pLSalesOpp.L2I_Sales_Opportunity__r.L2I_Sales_Opportunity_Description__c;
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