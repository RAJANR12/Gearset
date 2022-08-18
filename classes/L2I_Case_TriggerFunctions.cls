/**
 *      @author       Andy Fang
 *      @date         03/17/2020
 *      @description  L2I Case Trigger Functions
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                    03/17/2020         Initial scaffold
 *      Andy Fang                    04/01/2020         US1690 Added processAircraftActions
 *      Sarah Kennedy                04/10/2020         US1762 added checkServiceActivation method for Order Activation by Case
 *      Sarah Kennedy                06/17/2020         US2104, US1996 - removing processing of Order Cases as L2I_CaseMgmtFromCROrderController was
 *                                                         changed to a batch. This code was moved into L2I_CaseMgmtFromCROrderBatch
 *                                                         Issue was the execute step of L2I_CaseMgmtFromCROrderBatch inserted cases
 *                                                         which triggered this afterInsert which executes another batch. A batch cannot be
 *                                                         executed from another batch's execute step.
 *                                                         DSL confirmations will now also follow the same login as new Cases
 *      Sarah Kennedy                 02/03/2021        replace filter for L2I_Product_Category_2__c with L2I_Service_Activation_Type__c
 */
public without sharing class L2I_Case_TriggerFunctions {
    
    public static Set<Id> affectedOrderIds = new Set<Id>();
    
    public static void processCaseManagment( List<Case> newCaseList ){
//        Set<Id> caseIds = new Set<Id>();
//        Set<Id> caseIdSetOrder = new Set<Id>();
        Set<Id> caseIDSetDSL = new Set<Id>();

        //The current batch size is for both batch class.
        Integer BatchSize = Integer.valueOf (
                L2I_JSON_Settings.getSpecificSetting('Aircraft_Services_Management_Settings',
                        'BatchSize') );

        //Since both Create Order and DSL confirmation process will generate a case, we introduce a
        //Routing Path to indicate where this record came from and direct into the proper transactions.
        // Note: as L2I_CaseMgmtFromCROrderController was changed to a batch, we cannot use a trigger to execute another batch,
        // so the logic for an case from an Order is in the Finish of L2I_CaseMgmtFromCROrderBatch
        Id rtId = L2I_UtilityHelper.getRecordTypeId( 'L2I_Aircraft_Order', 'Case');
        for ( Case asCase : newCaseList ){
            if ( asCase.L2I_Routing_Path__c == 'DSL' && asCase.recordtypeId == rtId )
                caseIDSetDSL.add( asCase.Id );
//            if ( asCase.recordtypeId == rtId ) {
//                caseIds.add(asCase.Id);
//            }
        }
        System.debug('*** caseIDSetDSL ' + caseIDSetDSL);
//        if (caseIds.size() > 0) {
//            Datetime now = System.now();
//            Integer minsOffset = 1;
//            String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
//            String guid = L2I_UtilityHelper.generateGuid();
//            L2I_CM_AircraftService_Sched sched = new L2I_CM_AircraftService_Sched(guid, caseIds);
//            String jobId = System.schedule('AircraftServiceCaseMgmt ' + guid, cronTab, sched);
//            System.debug('AircraftServiceCaseMgmt' + guid + ' has been scheduled as :' + jobId);
//            // publish Aircraft Cases Process Mgmt
//            L2I_Aircraft_Cases_Process__e acp = new L2I_Aircraft_Cases_Process__e();
//            acp.caseIds__c = JSON.serialize(caseIds);
//            Database.SaveResult sr = EventBus.publish(acp);
//
//            if (sr.isSuccess()) {
//                System.debug('====== Successfully published L2I_Aircraft_Cases_Process__e event');
//            } else {
//                for (Database.Error err : sr.getErrors()) {
//                    System.debug('====== Platform Event L2I_Aircraft_Cases_Process__e publish Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
//                }
//            }
//        }

        if ( caseIDSetDSL.size() > 0 ){
            L2I_CM_AircraftService_Batch dsl = new L2I_CM_AircraftService_Batch ( caseIDSetDSL );
            Database.executeBatch(dsl, BatchSize );
        }
    }

    //US1690 - Manage Activation/Deactivation from Case
    public static void processAircraftActions( List<Case> newCaseList, Map<Id, Case> oldCaseMap ){
        system.debug( 'Staring of processAircraftActions function on Case Trigger ' );
        Set<Id> activeASAIds = new Set<Id>();
        Set<Id> deactiveASAIds = new Set<Id>();
        Set<Id> cancelASAIds = new Set<Id>();

        Set<Id> caseIdSets = new Set<Id>();
        Map<Id, Datetime> caseActiveDateMap = new Map<Id, Datetime>();
        Map<Id, Datetime> caseDeactiveDateMap = new Map<Id, Datetime>();
        Map<Id, Datetime> caseCancelDateMap = new Map<Id, Datetime>();
        Id rtId = L2I_UtilityHelper.getRecordTypeId( 'L2I_Aircraft_Order', 'Case');

        for ( Case c : newCaseList ){
            System.debug('*** c ' + c);
            if ( c.recordtypeId == rtId ) {
                if (c.L2I_Activation_Date__c != null && c.L2I_Activation_Date__c != oldCaseMap.get(c.Id).L2I_Activation_Date__c) {
                    activeASAIds.add(c.Id);
                    caseActiveDateMap.put(c.Id, c.L2I_Activation_Date__c);
                    caseIdSets.add(c.Id);
                }
                System.debug('*** checking Deactivate ');
                if (c.L2I_Deactivation_Date__c != null && c.L2I_Deactivation_Date__c != oldCaseMap.get(c.Id).L2I_Deactivation_Date__c) {
                    System.debug('*** got Deactivate ');
                    deactiveASAIds.add(c.Id);
                    caseDeactiveDateMap.put(c.Id, c.L2I_Deactivation_Date__c);
                    caseIdSets.add(c.Id);
                }

                if (c.L2I_Cancel_Date__c != null && c.L2I_Cancel_Date__c != oldCaseMap.get(c.Id).L2I_Cancel_Date__c) {
                    cancelASAIds.add(c.Id);
                    caseCancelDateMap.put(c.Id, c.L2I_Cancel_Date__c);
                    caseIdSets.add(c.Id);
                }
            }
        }
        System.debug('*** caseIdSets ' + caseIdSets);
        if ( caseIdSets.size() > 0 ) {
            List<L2I_ASA__c> asaList = [
                    select Id, Status__c, Action__c, Aircraft_Order__c, Aircraft_Service__c
                    from L2I_ASA__c
                    where Aircraft_Order__c IN :caseIdSets AND Status__c != 'Completed'
            ];

            List<L2I_ASA__c> asaToBeUpdated = new List<L2I_ASA__c>();
            Set<Id> asIdSets = new Set<Id>();
            Map<Id, Datetime> asActiveDateMap = new Map<Id, Datetime>();
            Map<Id, Datetime> asDeactiveDateMap = new Map<Id, Datetime>();
            Map<Id, Datetime> asCancelDateMap = new Map<Id, Datetime>();
    
            System.debug('*** asaList ' + asaList);
            for (L2I_ASA__c asa : asaList) {
                asIdSets.add(asa.Aircraft_Service__c);
                if (activeASAIds.contains(asa.Aircraft_Order__c) && asa.Action__c == 'Activate') {
                    asa.Status__c = 'Completed';
                    asActiveDateMap.put(asa.Aircraft_Service__c, caseActiveDateMap.get(asa.Aircraft_Order__c));
                }

                if (deactiveASAIds.contains(asa.Aircraft_Order__c) && asa.Action__c == 'Deactivate') {
                    asa.Status__c = 'Completed';
                    asDeactiveDateMap.put(asa.Aircraft_Service__c, caseDeactiveDateMap.get(asa.Aircraft_Order__c));
                }
                //caseCancelDateMap.get(asa.Aircraft_Order__c)
                if (cancelASAIds.contains(asa.Aircraft_Order__c) && asa.Action__c == 'Cancel') {
                    asa.Status__c = 'Completed';
                    asCancelDateMap.put(asa.Aircraft_Service__c, caseCancelDateMap.get(asa.Aircraft_Order__c));
                }

                asaToBeUpdated.add(asa);
            }
            System.debug('*** asaToBeUpdated ' + asaToBeUpdated);

            if (asaToBeUpdated.size() > 0) {
                update asaToBeUpdated;
            }

            List<L2I_Aircraft_Service__c> asList = [
                    select Id, L2I_Activation_Date__c, L2I_Deactivation_Date__c, Cancel_Date__c,
                            Status__c
                    from L2I_Aircraft_Service__c
                    where Id IN:asIdSets
            ];

            List<L2I_Aircraft_Service__c> updatedASList = new List<L2I_Aircraft_Service__c>();

            for (L2I_Aircraft_Service__c asRecord : asList) {

                if (asRecord.L2I_Activation_Date__c == null && asActiveDateMap.get(asRecord.Id) != null ) {
                    asRecord.L2I_Activation_Date__c = asActiveDateMap.get(asRecord.Id);
                }

                if (asRecord.L2I_Deactivation_Date__c == null && asDeactiveDateMap.get(asRecord.Id) != null ) {
                    asRecord.L2I_Deactivation_Date__c = asDeactiveDateMap.get(asRecord.Id);
                }

                if (asRecord.Cancel_Date__c == null && asCancelDateMap.get(asRecord.Id) != null ) {
                    //Defect
                    if ( asRecord.Status__c == 'Pending Activation' ) {
                        asRecord.Cancel_Date__c = asCancelDateMap.get(asRecord.Id);
                        asRecord.Status__c = 'Canceled';
                    }
                }
                System.debug('*** asRecord ' + asRecord);

                updatedASList.add (asRecord);
            }
    
            System.debug('*** updatedASList ' + updatedASList);
            if (updatedASList.size() > 0) {
                update updatedASList;
            }
        }


    }

    //Allow to reprocess the case only if record fail creating.  Admin only function
    public static void allowToReprocess( List<Case> newCaseList, Map<Id, Case> oldCaseMap ) {

        Set<Id> caseIdSets = new Set<Id>();
        Id rtId = L2I_UtilityHelper.getRecordTypeId( 'L2I_Aircraft_Order', 'Case');

        for ( Case c : newCaseList ){

            if ( c.L2I_Allow_To_Reprocess__c == false && c.L2I_Allow_To_Reprocess__c != oldCaseMap.get(c.Id).L2I_Allow_To_Reprocess__c
                    && c.recordtypeID == rtId ){
                caseIdSets.add( c.Id );
            }
        }

//        List<Case> caseList = [ select Id, recordtypeId from Case where Id IN: caseIdSets ];
        //Passing the case to processing again
//        processCaseManagment( caseList );
        Integer BatchSize = Integer.valueOf (
              L2I_JSON_Settings.getSpecificSetting('Aircraft_Services_Management_Settings',
                    'BatchSize') );
        if ( caseIdSets.size() > 0 ){
            L2I_CM_AircraftService_Batch dsl = new L2I_CM_AircraftService_Batch ( caseIdSets );
            Database.executeBatch(dsl, BatchSize );
        }
    }
    
    public static void checkServiceActivation(List<Case> newCaseList, Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap) {
        System.debug('====== Checking to see if Case records have been activated so we can process them');
        
        Id aircraftOrder = L2I_UtilityHelper.getRecordTypeId('L2I_Aircraft_Order', 'Case');
        Map<String, Set<Id>> ordCaseMap = new Map<String, Set<Id>>();
        Set<String> orderIds = new Set<String>();
        Set<Id> allOrderIds = new Set<Id>();
        Map<Id, Date> caseActDate = new Map<Id, Date>();
        Map<Id, Date> orderMinActivationDateMap = new Map<Id, Date>();
        
//        Set<String> allowedProducts;
        Set<String> oppoProductCategories;
//        allowedProducts = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
//              'Allowed Products');
        oppoProductCategories = L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
              'Product Category');
        
        for (Case cse : newCaseList) {
            Case newRec = newCaseMap.get(cse.Id);
            Case oldRec = oldCaseMap.get(cse.Id);
            
//            if (newRec.RecordTypeId == aircraftOrder &&
//                  (newRec.L2I_Order__c != null ||
//                        !String.isBlank(newRec.L2I_Related_Order__c)) &&
//                  newRec.L2I_Activation_Date__c != null &&
//                  newRec.L2I_Activation_Date__c != oldRec.L2I_Activation_Date__c &&
//                  oldRec.L2I_Activation_Date__c == null) {
//                orderIds = new Set<String>();
//                if (newRec.L2I_Order__c != null) {
//                    orderIds.add(newRec.L2I_Order__c);
//                }
//                if (!String.isBlank(newRec.L2I_Related_Order__c)) {
//                    Set<String> ordIds = (Set<String>) JSON.deserializeStrict(newRec.L2I_Related_Order__c, Set<String>.class);
//                    orderIds.addAll(ordIds);
//                }
            if (newRec.RecordTypeId == aircraftOrder &&
                  (newRec.L2I_Order__c != null) &&
                  newRec.L2I_Activation_Date__c != null &&
                  newRec.L2I_Activation_Date__c != oldRec.L2I_Activation_Date__c &&
                  oldRec.L2I_Activation_Date__c == null) {
                orderIds = new Set<String>();
                if (newRec.L2I_Order__c != null) {
                    orderIds.add(newRec.L2I_Order__c);
                }
                for (String s : orderIds) {
                    if (!String.isBlank(s)) {
                        if (ordCaseMap.containsKey(s)){
                            Set<Id> caseIds = ordCaseMap.get(s);
                            caseIds.add(cse.Id);
                            ordCaseMap.put(s, caseIds);
                        } else{
                            ordCaseMap.put(s, new Set<Id>{cse.Id});
                        }
                        allOrderIds.add(s);
                    }
                }
                Date actDate = Date.newInstance(cse.L2I_Activation_Date__c.year(), cse.L2I_Activation_Date__c.month(), cse.L2I_Activation_Date__c.day());
                caseActDate.put(cse.Id, actDate);
                System.debug('*** ordCaseMap ' + ordCaseMap);
                System.debug('*** caseActDate ' + caseActDate);
            }
        }
        
        if (allOrderIds.size() > 0) {
            for (Order ord : [
                  SELECT Id,
                        L2I_Original_Sales_Opportunity__c,
                        OpportunityId,
                        Opportunity.L2I_Product_Category__c,
                        Opportunity.RecordType.DeveloperName
                  FROM Order
                  WHERE Id IN :allOrderIds
                  AND Status != 'Activated'
                  AND L2I_Order_Process__c = 'Contract Management'
                  AND L2I_Service_Activation_Types__c != NULL
                  AND L2I_Service_Activation_Types__c != ''
                  AND Opportunity.L2I_Product_Category__c IN :oppoProductCategories
                  AND Opportunity.RecordType.DeveloperName IN ('Sales')
            ]) {
                if (ord.OpportunityId == ord.L2I_Original_Sales_Opportunity__c) {
                    Set<Id> caseIds = ordCaseMap.get(ord.Id);
                    Date aDate;
                    // find the earliest Case Activation Date for this Order
                    for (Id caseId : caseIds) {
                        if (aDate == null || caseActDate.get(caseId) < aDate) {
                            aDate = caseActDate.get(caseId);
                        }
                    }
                    orderMinActivationDateMap.put(ord.Id, aDate);
                    affectedOrderIds.add(ord.Id);
                    System.debug('*** orderMinActivationDateMap ' + orderMinActivationDateMap);
                    System.debug('*** affectedOrderIds ' + affectedOrderIds);
                }
            }
        }
    
        if (!affectedOrderIds.isEmpty()) {
            System.debug('====== Detected ' + affectedOrderIds.size() + ' Orders to Activate');
            
            // Fire once L2I_Aircraft_Service_Activated__e for all of the activated cases
            Boolean firePEonAircraftServiceActivation = L2I_GeneralSettings.shouldFirePEonAircraftServiceActivation();
            if (firePEonAircraftServiceActivation) {
                String jsonOrderMap = JSON.serialize(orderMinActivationDateMap);
                L2I_UtilityHelper.publishAircraftServiceActivatedEvent(jsonOrderMap);
            } else {
                System.debug('====== L2I_General_Settings__mdt CMT firePEonAircraftServiceActivation is set to false.');
                System.debug('====== Skipping the publishing of the Platform Event for this set of Activations');
            }
        } else {
            System.debug('====== Detected ' + affectedOrderIds.size() + ' Orders to Activate');
        }
    }
}