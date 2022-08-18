/**
 *      @author       Sarah Kennedy
 *      @date         02/27/2020
 *      @description  L2I DSL Trigger Functions
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 02/27/2020         Initial scaffold
 *      Sarah Kennedy                 04/30/2020         US1823 TA3095 - Added check for 'Closed' for Amendment StageName change
 *      Sarah Kennedy                 06/07/2020         US2002, US2010 - allow Add, Delete for Renewals
 *      Sarah Kennedy                 07/21/2020         US2125 - Modifications to DSL Confirmation Process for Cases
 *
 */
public without sharing class L2I_DSLTriggerFunctions {

    public static void ifecDSLsAdded(List<L2I_DSL__c> newDSLList) {
        System.debug('*** Running DSL Trigger Function ifecAdded');
        // find the DSS/PTS DSHs for the IFEC DSH where a DSL is being added
        Set<String> dshIFECIds = new Set<String>();
        Set<String> dshtoChatIds = new Set<String>();
        for (L2I_DSL__c dsl : newDSLList) {
            if (dsl.Product_Category__c == 'IFEC') {
                dshIFECIds.add(dsl.Delivery_Schedule_Header__c);
            }
        }
        System.debug('*** dshIFECIds ' + dshIFECIds);
        for (L2I_DSL__c serviceDSL : [
              SELECT Id, Delivery_Schedule_Header__c
              FROM L2I_DSL__c
              WHERE Product_Category__c IN ('DSS', 'PTS')
              AND IFEC_DSL__r.Delivery_Schedule_Header__C IN :dshIFECIds
        ]) {
            dshtoChatIds.add(serviceDSL.Delivery_Schedule_Header__c);
        }
        System.debug('*** dshtoChatIds ' + dshtoChatIds);
        if (dshtoChatIds.size() > 0) {
            postChat(dshtoChatIds);
        }
    }


    public static void ifecDSLsDeleted(List<L2I_DSL__c> oldDSLList) {
        System.debug('*** Running DSL Trigger Function ifecDeleted');
        // find a matching DSS/PTS DSL linked to the IFEC DSL being deleted
        Set<String> ifecDSLIds = new Set<String>();
        Set<String> dshtoChatIds = new Set<String>();
        for (L2I_DSL__c dsl : oldDSLList) {
            if (dsl.Product_Category__c == 'IFEC') {
                ifecDSLIds.add(dsl.Id);
            }
        }
        System.debug('*** ifecDSLIds ' + ifecDSLIds);
        if (ifecDSLIds.size() > 0) {
            for (L2I_DSL__c serviceDSL : [
                  SELECT Id, Delivery_Schedule_Header__c
                  FROM L2I_DSL__c
                  WHERE Product_Category__c IN ('DSS', 'PTS')
                  AND IFEC_DSL__c IN :ifecDSLIds
            ]) {
                dshtoChatIds.add(serviceDSL.Delivery_Schedule_Header__c);
            }
        }
        System.debug('*** dshtoChatIds ' + dshtoChatIds);
        if (dshtoChatIds.size() > 0) {
            postChat(dshtoChatIds);
        }
    }
    @TestVisible
    private static void postChat(Set<String> dshIds) {
        List<L2I_ConnectAPIService.ConnectAPIWrap> caWrapList = new List<L2I_ConnectAPIService.ConnectAPIWrap>();
        L2I_ConnectAPIService.ConnectAPIWrap caWrap;
        System.debug('*** opp dshIds ' + dshIds);
        for (Opportunity oppty : [
              SELECT Id, OwnerId, StageName, L2I_Delivery_Schedule__c
              FROM Opportunity
              WHERE L2I_Delivery_Schedule__c IN :dshIds
              AND StageName <> 'Closed Won'
              AND StageName <> 'Closed'
        ]) {
            caWrap = new L2I_ConnectAPIService.ConnectAPIWrap();
            caWrap.objectId = oppty.Id;
            caWrap.ownerId = oppty.OwnerId;
            caWrap.message = ' ' + Label.Opportunity_Chat_DSLs_Change;
            caWrapList.add(caWrap);
            System.debug('*** caWrap ' + caWrap);
        }
        if (caWrapList != null && caWrapList.size() > 0) {
            System.debug('*** caWrapList ' + caWrapList.size());
            if (!Test.isRunningTest()) {
                Integer batchCount = L2I_ConnectAPIService.createChat(caWrapList);
            }
        }
    }

    public static void disallowDSLConfirmationForAmendment(List<L2I_DSL__c> newDSLList, Map<Id, L2I_DSL__c> newDSLMap, Map<Id, L2I_DSL__c> oldDSLMap) {
        System.debug('*** Running DSL Trigger Function disallowDSLConfirmationForAmendment');
//        Set<Id> dslIds = new Set<Id>();
        Set<Id> dshIds = new Set<Id>();
        Map<Id, List<Order>> origSalesOppOrderMap = new Map<Id, List<Order>>();
        // get confirmed DSLs
        for (L2I_DSL__c dsl : newDSLList) {
            L2I_DSL__c oldDSL = oldDSLMap.get(dsl.Id);
            L2I_DSL__c newDSL = newDSLMap.get(dsl.Id);

            if (newDSL.L2I_Aircraft_Confirmation__c == true &&
                  newDSL.L2I_Aircraft_Confirmation__c != oldDSL.L2I_Aircraft_Confirmation__c) {
                dshIds.add(dsl.Delivery_Schedule_Header__c);
            }
        }
        System.debug('*** dshIds ' + dshIds);
        // find any amendment orders
        List<Order> orderList = new List<Order>();
        orderList = [
              SELECT Id,
                    L2I_Original_Sales_Opportunity__c, Type,
                    L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c,
                    OpportunityId,
                    Opportunity.CreatedDate,
                    Opportunity.L2I_Delivery_Schedule__c,
                    L2I_Product_Category_2__c,
                    AccountId, (select Id from OrderItems where EndDate >= Today)
              FROM Order
              WHERE L2I_Terminated__c = false
              AND Opportunity.L2I_Delivery_Schedule__c IN:dshIds
              AND Type IN ('Amendment')
        ];
        if (orderList.size() > 0) {

            for (Order o : orderList) {
                System.debug('*** o ' + o);
                for (L2I_DSL__c dsl : newDSLList) {
                    System.debug('*** dsl ' + dsl);
                    if (dsl.Delivery_Schedule_Header__c == o.Opportunity.L2I_Delivery_Schedule__c){
                        System.debug('*** setting dslerror ' + o.Opportunity.L2I_Delivery_Schedule__c);
                        dsl.addError('The Service for Opportunity ' +
                              o.L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c +
                              ' has been canceled hence cannot confirm DSL.');
                    }
                }
            }
        }

    }

    public static void createCasesFromDSLs(List<L2I_DSL__c> newDSLList, Map<Id, L2I_DSL__c> newDSLMap, Map<Id, L2I_DSL__c> oldDSLMap) {
        System.debug('*** Running DSL Trigger Function createCases');
        L2I_DSLService.createCasesFromDSLs(newDSLList, newDSLMap, oldDSLMap);
    }

    public static void updateDSLName(List<L2I_DSL__c> newDSLList) {
        Id hardwareTypeId = Schema.SObjectType.L2I_DSL__c.getRecordTypeInfosByDeveloperName().get('Hardware').getRecordTypeId();
        Id inactiveTypeId = Schema.SObjectType.L2I_DSL__c.getRecordTypeInfosByDeveloperName().get('Inactive').getRecordTypeId();

        for (L2I_DSL__c dsl : newDSLList) {
            // Always update the name with the Line Number
            if (dsl.Line_Number__c != null) {
                dsl.Name = dsl.Line_Number__c;
            }
            if (dsl.PT_isActive__c == 'Inactive') {
                dsl.RecordTypeId = inactiveTypeId;
            } else {
                dsl.RecordTypeId = hardwareTypeId;
            }
            // 3/12/2021 Sarah W-003305
//            if (dsl.PT_Is_InService__c) {
//                dsl.RecordTypeId = inactiveTypeId;
//            } else {
//                dsl.RecordTypeId = hardwareTypeId;
//            }

        }
    }

    public static void updateDeliveryDateforrollup(List<L2I_DSL__c> newDSLList, Map<Id, L2I_DSL__c> oldDSLMap, Boolean before) {
        Set <ID> ifecDSLIds = new Set <ID>();
        Map <Id, L2I_DSL__c> iFecDSLmap = new Map<ID, L2I_DSL__c>();
        if (before) {
            //executing before update or before insert
            if (olddslmap == null){
                // method is executing before insert prepare the map of IFEC DSL dates needed to be queried.
                for (L2I_DSL__c rDsl : newDSLList) {
                    if (rDsl.Product_Category__c != 'IFEC' && rDsl.IFEC_DSL__c != null){
                        ifecDSLIds.add(rDsl.IFEC_DSL__c);
                    }
                }

                if (ifecDSLIds.size()>0){
                    for (L2I_DSL__c ifecDsl : [
                            SELECT Id, Delivery_Date__c FROM L2I_DSL__c Where id in :ifecDSLIds ]) {
                        iFecDSLmap.put(ifecDsl.Id, ifecDsl);
                    }
                }
            }
            // update all DSL records as needed
            for (L2I_DSL__c dsl : newDSLList) {
                if (olddslmap != null){
                    // method is executing in brefore update trigger.
                    if (dsl.IFEC_DSL__c == null  && dsl.Delivery_Date__c != olddslmap.get(dsl.id).Delivery_Date__c && dsl.Delivery_Date__c != null){
                        // updating for stand alone dsl record
                        dsl.Del_Date_for_Rollup__c = dsl.Delivery_Date__c;
                    } else if (dsl.IFEC_DSL__c != null && dsl.Del_Date_for_Rollup__c != dsl.IFEC_Delivery_Date__c) {
                        // updating for related DSL records
                        dsl.Del_Date_for_Rollup__c = dsl.IFEC_Delivery_Date__c;
                    }
                } else {
                    // method is executing in before insert trigger. so can only update for stand alone dsls
                    if (dsl.IFEC_DSL__c == null && dsl.Delivery_Date__c != null){
                        // updating for stand alone dsl record
                        dsl.Del_Date_for_Rollup__c = dsl.Delivery_Date__c;
                    } else if (dsl.IFEC_DSL__c != null && dsl.Del_Date_for_Rollup__c == null && iFecDSLmap.size() > 0) {
                        dsl.Del_Date_for_Rollup__c = iFecDSLmap.get(dsl.IFEC_DSL__c).Delivery_Date__c;
                    }
                }
            }

        } else {
            // executing after update
            List<ID> affectedrelatedDSLIDs = new List<Id>();
            List<L2I_DSL__c> affectedDSLs = new List<L2I_DSL__c>();
            for (L2I_DSL__c dsl : newDSLList) {
                // method is executing in after insert or after update trigger.
    
                if (dsl.IFEC_DSL__c == null && dsl.Product_Category__c == 'IFEC' && (dsl.Delivery_Date__c != oldDSLMap.get(dsl.Id).Delivery_Date__c) ) {
                   
                    // IFEC DSL is updated, update related dsls as necessary
                    //delivery date has changed may impact related dsls
                    affectedrelatedDSLIDs.add(dsl.Id);
                }
            }

            if (affectedrelatedDSLIDs.size() > 0 ){
                // find any related dsls to ifec dsl
                List<L2I_DSL__c> reldslList = new List<L2I_DSL__c>();
                reldslList = [
                        SELECT Id, Del_Date_for_Rollup__c, IFEC_Delivery_Date__c
                        FROM L2I_DSL__c
                        WHERE Product_Category__c != 'IFEC'
                        AND IFEC_DSL__c IN:affectedrelatedDSLIDs
                ];

                if (reldslList.size() > 0) {
                    for (L2I_DSL__c relDsl : reldslList) {
                        if (relDsl.Del_Date_for_Rollup__c != relDsl.IFEC_Delivery_Date__c) {
                            relDsl.Del_Date_for_Rollup__c = relDsl.IFEC_Delivery_Date__c;
                            affectedDSLs.add(relDsl);
                        }
                    }
                }
            }
            if (affectedDSLs.size()>0){
                update affectedDSLs;
            }
        }
    }


    //Once program is created, only those aircraft can be add to DSL which belong to the Associated Retrofit Program
//    public static void restrictAircraftRetrofitProgram(List<L2I_DSL__c> newDSLList, Map<Id, L2I_DSL__c> oldDSLMap) {
//        Set<Id> programs = new Set<Id>();
//        Set<Id> retrofitPrograms = new Set<Id>();
//        Map<Id, Set<Id>> programAircraftsMap = new Map<Id, Set<Id>>();
//
//        // get only those DSL for which aircraft is being updated and program is not null
//        for (L2I_DSL__c dsl : newDSLList) {
//            if (dsl.PT_Program__c != null) {
//                if (oldDSLMap.get(dsl.Id).Aircraft__c != dsl.Aircraft__c) {
//                    programs.add(dsl.PT_Program__c);
//                }
//            }
//        }
//
//        // get programs with the program type. Add retrofit types of program to set
//        if (programs.size() > 0) {
//            for (PT_Program__c prog : [SELECT Id, PT_Program_Type__c FROM PT_Program__c WHERE Id IN :programs]) {
//                if (prog.PT_Program_Type__c == 'Retrofit') {
//                    retrofitPrograms.add(prog.Id);
//                }
//            }
//        }
//
//        if (retrofitPrograms.size() > 0) {
//            // get all aircrafts belonging to the retrofit program
//            List<L2I_DSL__c> dslRecordsWithProgram = [SELECT Id, Aircraft__c, PT_Program__c FROM L2I_DSL__c WHERE PT_Program__c IN :retrofitPrograms];
//            for (L2I_DSL__c dsl : dslRecordsWithProgram) {
//                if (programAircraftsMap.containsKey(dsl.PT_Program__c)) {
//                    programAircraftsMap.get(dsl.PT_Program__c).add(dsl.Aircraft__c);
//                } else {
//                    programAircraftsMap.put(dsl.PT_Program__c, new Set<Id> {dsl.Aircraft__c});
//                }
//            }
//
//            // if the aircraft does not belong to the program, throw validation error.
//            for (L2I_DSL__c dsl : newDSLList) {
//                if (dsl.PT_Program__c != null && programAircraftsMap.containsKey(dsl.PT_Program__c)) {
//                    if (dsl.Aircraft__c != null && oldDSLMap.get(dsl.Id).Aircraft__c != dsl.Aircraft__c) {
//                        if (!programAircraftsMap.get(dsl.PT_Program__c).contains(dsl.Aircraft__c)) {
//                            //dsl.addError('The selected aircraft does not belong to this program');
//                        }
//                    }
//                }
//            }
//        }
//    }

    public static void setTailUniquenessOnDSL(List<L2I_DSL__c> newDSLList, Map<Id, L2I_DSL__c> oldDSLMap) {
        for (L2I_DSL__c dsl : newDSLList) {
            if (dsl.PT_Program__c != null && dsl.Aircraft__c != null) {
                dsl.PT_Tail_Uniqueness__c = dsl.PT_Program__c + '-' + dsl.Aircraft__c;
            } else if (dsl.PT_Program__c == null && dsl.Aircraft__c != null) {
                dsl.PT_Tail_Uniqueness__c = dsl.Delivery_Schedule_Header__c + '-' + dsl.Aircraft__c;
            } else if (dsl.Aircraft__c == null) {
                dsl.PT_Tail_Uniqueness__c  = null;
            }
        }
    }

    /*
    * @author           Lipton Abillar
    * @date             08/03/2021
    * @workitem         W-003512
    * @description      Recalculate Primary Quotes if Delivery Date is changed
    * @trigger          L2I_DSLTriggerHandler.afterUpdate()
    *
    * Developer:        Lipton Abillar      08/03/2021      Create
    */
    public static void recalculatePrimaryQuotes(List<L2I_DSL__c> newDSLList, Map<Id, L2I_DSL__c> oldDSLMap) {
        Set<Id> dshIds = new Set<Id>();
        Set<Id> dslIds = new Set<Id>();

        // Only select DSH that Delivery_Date__c has changed
        for (L2I_DSL__c dsl : newDSLList) {
            if (dsl.Forecasted_Delivery_Date__c != oldDSLMap.get(dsl.Id).Forecasted_Delivery_Date__c) {
                dshIds.add(dsl.Delivery_Schedule_Header__c);
                dslIds.add(dsl.Id);
            }
        }

        // Add in the list the related DSL's DSH
        List<L2I_DSL__c> relatedDSL = [SELECT Id, Delivery_Schedule_Header__c FROM L2I_DSL__c WHERE IFEC_DSL__c IN :dslIds];
        if (!relatedDSL.isEmpty()) {
            for (L2I_DSL__c dsl : relatedDSL) {
                dshIds.add(dsl.Delivery_Schedule_Header__c);
            }
        }

        

        if (!dshIds.isEmpty()) {
            recalculatePrimaryQuotes2(dshIds);
        }
    }

    @future
    public static void recalculatePrimaryQuotes2(Set<Id> dshIds) {
        Map<Id, L2I_DSH__c> dshMap = new Map<Id, L2I_DSH__c>(
            [SELECT Id, (SELECT Id, Forecasted_Delivery_Date__c FROM Delivery_Schedules__r ORDER BY Forecasted_Delivery_Date__c ASC LIMIT 1)
            FROM L2I_DSH__c WHERE Id IN :dshIds]);

        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();

        for (Opportunity opp : [SELECT Id, L2I_Delivery_Schedule__c, L2I_First_Delivery_Date__c,
                                    (SELECT Id,
                                            SBQQ__StartDate__c,
                                            SBQQ__EndDate__c,
                                            SBQQ__Opportunity2__c,
                                            SBQQ__Opportunity2__r.RecordType.DeveloperName,
                                            SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c,
                                            SBQQ__Opportunity2__r.SBQQ__RenewedContract__c,
                                            SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate,
                                            SBQQ__SubscriptionTerm__c,
                                            L2I_Bookings_Adj_Amount__c,
                                            L2I_Booking_Adj_AC_Service_Months__c,
                                            L2I_Bookings_Adj_Subscription_Term__c,
                                            L2I_Total_Aircraft_Service_Months__c,
                                            L2I_Aircraft_Quantity__c,
                                            SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Order__r.SBQQ__Quote__r.L2I_Aircraft_Quantity__c
                                    FROM SBQQ__Quotes2__r
                                    WHERE SBQQ__Primary__c = true AND ApprovalStatus__c != 'Approved')
                                FROM Opportunity 
                                WHERE L2I_Delivery_Schedule__c IN :dshIds
                                AND L2I_Product_Category__c IN ('DSS','PTS')
                                AND RecordType.DeveloperName IN ('Sales', 'Renewal', 'Amendment')
                                AND StageName != 'Closed Won']
        ) {
            for (SBQQ__Quote__c qt : opp.SBQQ__Quotes2__r) {
                Date startDate = opp.L2I_First_Delivery_Date__c;
                if (!dshMap.get(opp.L2I_Delivery_Schedule__c).Delivery_Schedules__r.isEmpty()) {
                    startDate = dshMap.get(opp.L2I_Delivery_Schedule__c).Delivery_Schedules__r[0].Forecasted_Delivery_Date__c;
                }
                qt.SBQQ__StartDate__c = startDate;
                L2I_QuoteService.calculateTotalAircraftServiceMonths(qt);
                quotesToUpdate.add(qt);
            }
        }

        if (!quotesToUpdate.isEmpty()) {
            update quotesToUpdate;
        }
    }
    
    public static void populateACService(List<L2I_DSL__c> newDSLList, Map<Id, L2I_DSL__c> oldDSLMap) {
        System.Debug('populateACService Entry');
        Map<Id, L2I_DSL__c> mapIFECDate = new Map<Id, L2I_DSL__c>();
        Set<Id> listIFECOpp = new Set<ID>(); 
        for(L2I_DSL__c dslItem : newDSLList){
        
            if((oldDSLMap.get(dslItem.Id).L2I_AC_Entered_Into_Service__c == FALSE && dslItem.L2I_AC_Entered_Into_Service__c == TRUE)
               || (oldDSLMap.get(dslItem.Id).PT_InService_Date__c == null && dslItem.PT_InService_Date__c != null)
               || (oldDSLMap.get(dslItem.Id).Hardware_Program_Number__c == null && dslItem.Hardware_Program_Number__c != null)){
                System.Debug(dslItem);
                listIFECOpp.add(dslItem.Original_Opportunity__c);
                mapIFECDate.put(dslItem.Original_Opportunity__c,dslItem);
    
            }
        }
    
        Set<Id> setDSSOpps = new Set<Id>();
        Map<Id, Id> mapIFECDSSIds = new Map<Id, Id>();
        Map<Id, String> mapIFECProgram = new Map<Id, String>();
        List<Order> updateOrderList = new List<Order> ();
        List<L2I_DSL__c> dslRec = new List<L2I_DSL__c>();        
        List<L2I_DSL__c> updateDslRec = new List<L2I_DSL__c>();   
        if(!listIFECOpp.isEmpty()){
            Map<Id, L2I_DSL__c> mapDSL = new Map<Id, L2I_DSL__c> ([SELECT ID, Original_Opportunity__c, (SELECT ID, Original_Opportunity__c, Original_Opportunity__r.Name,Hardware_Program_Number__c FROM Delivery_Schedule_Lines__r), Original_Opportunity__r.L2I_Opportunity_Number__c, Original_Opportunity__r.L2I_Program_Num__r.Name, Hardware_Program_Number__c FROM L2I_DSL__c WHERE Original_Opportunity__c IN: listIFECOpp AND Original_Opportunity__r.L2I_Product_Category__c = 'IFEC' ]);
            
            if(!mapDSL.isEmpty()){
                for(L2I_DSL__c dslLineItem :  mapDSL.values()){
                    
                    System.debug('DSS Opp Iterate' + dslLineItem );
                    if(dslLineItem.Delivery_Schedule_Lines__r != null){
                        dslRec = dslLineItem.Delivery_Schedule_Lines__r;
                        for(L2I_DSL__c dslRecDSS : dslRec ){
                            if(dslRecDSS.Id != null){
                                setDSSOpps.add(dslRecDSS.Original_Opportunity__c);
                                mapIFECDSSIds.put(dslRecDSS.Original_Opportunity__c, dslLineItem.Original_Opportunity__c);
                                if(dslLineItem.Original_Opportunity__r.L2I_Program_Num__c != null) {
                                    mapIFECProgram.put(dslRecDSS.Original_Opportunity__c, dslLineItem.Original_Opportunity__r.L2I_Program_Num__r.Name);
                                }
                                dslRecDSS.L2I_AC_Entered_Into_Service__c = mapIFECDate.get(dslLineItem.Original_Opportunity__c).L2I_AC_Entered_Into_Service__c;
                                dslRecDSS.PT_InService_Date__c = mapIFECDate.get(dslLineItem.Original_Opportunity__c).PT_InService_Date__c  ;
                                System.Debug('Individual Line IFEC' + dslLineItem);
                                System.Debug('Individual Lines DSS' + dslRecDSS);
                                if(dslLineItem.Hardware_Program_Number__c != null) {
                                    dslRecDSS.Hardware_Program_Number__c = mapIFECDate.get(dslLineItem.Original_Opportunity__c).Hardware_Program_Number__c ;
                                }
                                updateDslRec.add(dslRecDSS);
                            }
                        }
                    }
                }
            }
            
            if(!updateDslRec.isEmpty()){
                update updateDslRec;
            }
    
            if(!setDSSOpps.isEmpty()){
                
                 Map<Id, Order> mapOrder = new Map<Id, Order> ([ SELECT ID, L2I_1st_Aircraft_Entered_In_Service__c, L2I_1st_AC_Entered_In_Service_Date__c,OpportunityId FROM Order WHERE OpportunityId IN: setDSSOpps]);
                for(Order orderItem : mapOrder.values()){
                    if(orderItem.L2I_1st_Aircraft_Entered_In_Service__c == FALSE && orderItem.L2I_1st_AC_Entered_In_Service_Date__c == NULL ){
                        orderItem.L2I_1st_Aircraft_Entered_In_Service__c = mapIFECDate.get(mapIFECDSSIds.get(orderItem.OpportunityId)).L2I_AC_Entered_Into_Service__c;
                        orderItem.L2I_1st_AC_Entered_In_Service_Date__c = mapIFECDate.get(mapIFECDSSIds.get(orderItem.OpportunityId)).PT_InService_Date__c;
                        orderItem.HW_Program_Number__c = mapIFECProgram.get(orderItem.OpportunityId);
                        updateOrderList.add(orderItem);
                    }
                  
                }
            }
            if(!updateOrderList.isEmpty()){
                update updateOrderList;
            }
        }
        
        System.Debug(updateOrderList + 'List Debug');
    
    }
    /*
    *W-003555
    */
       
    /*public static void checkProgramFirstDeliveryDate(List<L2I_DSL__c> newDSLList){
        Map<Id, Date> programRecDlvryDate = new Map<Id, Date>();
        List<PT_Program__c> prgmList = new List<PT_Program__c>();
        
        for(L2I_DSL__c l2iRec: newDSLList){
            if(l2iRec.Delivery_Date__c != NULL){
                if(programRecDlvryDate.containsKey(l2iRec.PT_Program__c)){
                    if(programRecDlvryDate.get(l2iRec.PT_Program__c) > l2iRec.Delivery_Date__c){
                        programRecDlvryDate.put(l2iRec.PT_Program__c, l2iRec.Delivery_Date__c);
                    }
                }
                else {
                    programRecDlvryDate.put(l2iRec.PT_Program__c, l2iRec.Delivery_Date__c);
                }
            }
        }
        
        if(!programRecDlvryDate.keySet().isEmpty()){
            for(PT_Program__c progRec: [SELECT Id, PT_First_Aircraft_Delivery__c FROM PT_Program__c WHERE Id IN: programRecDlvryDate.keySet()]){
                if(progRec.PT_First_Aircraft_Delivery__c == NULL){
                    progRec.PT_First_Aircraft_Delivery__c = programRecDlvryDate.get(progRec.Id);
                    prgmList.add(progRec);
                }
                else if (progRec.PT_First_Aircraft_Delivery__c > programRecDlvryDate.get(progRec.Id)){
                    progRec.PT_First_Aircraft_Delivery__c = programRecDlvryDate.get(progRec.Id);
                    prgmList.add(progRec);
                }
            }
        }
        
        if(!prgmList.isEmpty()){
            update prgmList;
        }
    }*/
    /*
    *W-003555
    */
    public static void checkProgramFirstDeliveryDate(Map<Id, L2I_DSL__c> newDSMap, Map<Id, L2I_DSL__c> oldDSLMap){
        
        Set<Id> progId = new Set<Id>();
        Map<Id, PT_Program__c> prgmMap = new Map<Id, PT_Program__c>();
        
        //on delete, get the program id if a shipset is deleted
        if(newDSMap == NULL){
            for(L2I_DSL__c shipset: oldDSLMap.values()){
                progId.add(shipset.PT_Program__c);
            }
        }
        //on update, check if the delivery date has changed, if yes, get the Program Id for checking
        else{
            for(L2I_DSL__c shipset: newDSMap.values()){
                if(shipset.Delivery_Date__c != oldDSLMap.get(shipset.Id).Delivery_Date__c){
                    progId.add(shipset.PT_Program__c);
                }
                else if(shipset.PT_isActive__c != oldDSLMap.get(shipset.Id).PT_isActive__c){
                    progId.add(shipset.PT_Program__c);
                }
            }
        }
        
        //query the related shipset record for all program bound for checking, compare the delivery date and first delivery date
        for(PT_Program__c progRec: [SELECT Id, PT_First_Aircraft_Delivery__c, (SELECT Id, Delivery_Date__c FROM Delivery_Schedule_Lines__r WHERE PT_isActive__c = 'Active' ORDER BY Delivery_Date__c ASC LIMIT 1) FROM PT_Program__c WHERE Id IN: progId]){
            if(!progRec.Delivery_Schedule_Lines__r.isEmpty()){
                progRec.PT_First_Aircraft_Delivery__c = progRec.Delivery_Schedule_Lines__r[0].Delivery_Date__c;
                prgmMap.put(progRec.Id, progRec);                
            }            
        }
        
        //update the program records
        if(!prgmMap.values().isEmpty()){
            update prgmMap.values();
        }
    }

    /*
    * @author           Lipton Abillar
    * @date             10/28/21
    * @workitem         W-004055
    * @description      Roll up all Hardware_Program_Number__c to Opportunity's L2I_Related_Oracle_HW_Program_numbers__c 
    * @trigger          L2I_DSLTriggerHandler.afterUpdate() && afterInsert()
    *
    * Developer:        Lipton Abillar      10/28/21      Create
    */
    public static void rollupHardwareProgramNumbers(List<L2I_DSL__c> newDSLList, Map<Id, L2I_DSL__c> oldDSLMap) {
        Set<Id> dshIds = new Set<Id>();
        Map<Id, Set<String>> oppsHWProgramMap = new Map<Id, Set<String>>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (L2I_DSL__c dsl : newDSLList) {
            if ((oldDSLMap == null && dsl.Hardware_Program_Number__c != null) ||
                (oldDSLMap != null && dsl.Hardware_Program_Number__c != oldDSLMap.get(dsl.Id).Hardware_Program_Number__c)) {
                dshIds.add(dsl.Delivery_Schedule_Header__c);
            }
        }

        if (!dshIds.isEmpty()) {
            for (L2I_DSH__c dsh : [SELECT Id, (SELECT Id, Original_Opportunity__c, Hardware_Program_Number__c FROM Delivery_Schedules__r WHERE Hardware_Program_Number__c != null ORDER BY Delivery_Date__c ASC) FROM L2I_DSH__c WHERE Id IN :dshIds]) {
                for (L2I_DSL__c dsl : dsh.Delivery_Schedules__r) {
                    if (dsl.Original_Opportunity__c != null) {
                        if (!oppsHWProgramMap.containsKey(dsl.Original_Opportunity__c)) {
                            oppsHWProgramMap.put(dsl.Original_Opportunity__c, new Set<String>());
                        }
                        oppsHWProgramMap.get(dsl.Original_Opportunity__c).add(dsl.Hardware_Program_Number__c);
                    }
                }
            }
        }

        if (!oppsHWProgramMap.isEmpty()) {
            for (Id id : oppsHWProgramMap.keySet()) {
                String progNumbers = String.join(new List<String>(oppsHWProgramMap.get(id)), ', ');
                oppsToUpdate.add(new Opportunity(Id = id, L2I_Related_Oracle_HW_Program_numbers__c = progNumbers));
            }
          
          update oppsToUpdate;
        }
    }
}