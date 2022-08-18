/**
 *      @author       Andy Fang
 *      @date         03/17/2020
 *      @description  L2I_CM_FromDSL_Batch
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                    03/17/2020         Initial scaffold
 */
    // This batch gets call from L2I_CaseMgmtFromDSLController
    // It creates Aircraft Service Action
    // Then it creates Aircraft Service record
    // Then it update Aircraft Service Action record with the associated Aircraft service
global class L2I_CM_FromDSL_Batch{
//    global class L2I_CM_FromDSL_Batch implements Database.Batchable<sObject>, Database.Stateful {

//        private Set<Id> caseIdSets;
//        private Boolean hasError;
//
//        public L2I_CM_FromDSL_Batch( Set<Id> caseIdSetsParam ){
//            caseIdSets = caseIdSetsParam;
//        }
//
//        global Database.QueryLocator start(Database.BatchableContext bc) {
//            return Database.getQueryLocator(
//                    'SELECT Id, L2I_Aircraft__c, L2I_Opportunity__r.L2I_Delivery_Schedule__c, ' +
//                            ' L2I_Product_Category_2__c FROM Case WHERE Id in: caseIdSets'
//            );
//
//        }
//
//        global void execute(Database.BatchableContext bc, List<Case> scope) {
//
//            hasError = false;
//            Savepoint sp = Database.setSavepoint();
//
//            try {
//
//                L2I_CaseMgmtDSLDAO dslDAO = new L2I_CaseMgmtDSLDAO();
//                Map<String, Set<Id>> ACDSLOrderIDMap = new Map<String, Set<Id>>();
//                Set<Id> OrderIdSet = New Set<Id>();
//                Set<Id> aircraftIds = new Set<Id>();
//                Set<String> matchingIdSet = new Set<String>();
//                List<L2I_ASA__c> newASARecords = new List<L2I_ASA__c>();
//
//                for ( Case c : scope ){
//                    aircraftIds.add( c.L2I_Aircraft__c );
//                    String key = c.L2I_Aircraft__c + '' + c.L2I_Opportunity__r.L2I_Delivery_Schedule__c;
////                    Set<Id> temp = (Set<Id>)Json.deserialize( c.L2I_Related_Order__c, Set<Id>.class );
////                    ACDSLOrderIDMap.put( key, temp );
////                    OrderIdSet.addAll( temp );
//                }
//
//                List<OrderItem> orderItemList = dslDAO.getOrderItemByOrderId( OrderIdSet );
//
//                Map<Id, Set<Id>> orderIdOrderItemsMap = new Map<Id, Set<Id>>();
//
//                //This variable is to use for calculation for Order to order item mapping
//                Map<String, Set<Id>> categoryOrderItemsMap = new Map<String, Set<Id>>();
//                Set<String> categorySet = new Set<String>();
//                Map<Id, Id> ExistingProd2IdOrderItemIdMap = new Map<Id, Id>();
//                Map<Id, Orderitem> oiProductMap = new Map<Id, Orderitem>();
//
//                for( OrderItem oi : orderItemList ){
//                    if ( categorySet.contains( oi.L2I_Sub_Category_2__c ) ){
//                        Set<Id> caseSet = categoryOrderItemsMap.get( oi.L2I_Sub_Category_2__c );
//                        if ( oi.Quantity >= 1 ) {
//                            caseSet.add(oi.Id);
//                            ExistingProd2IdOrderItemIdMap.put( oi.Product2Id, oi.Id );
//                        }
//                        if ( oi.Quantity <= -1 ) {
//                            caseSet.remove( ExistingProd2IdOrderItemIdMap.get(oi.Product2Id) );
//                        }
//                        categoryOrderItemsMap.put( oi.L2I_Sub_Category_2__c, caseSet );
//                    } else {
//                        categorySet.add( oi.L2I_Sub_Category_2__c );
//                        Set<Id> caseSet = new Set<Id>();
//                        caseSet.add( oi.Id );
//                        categoryOrderItemsMap.put( oi.L2I_Sub_Category_2__c, caseSet );
//                    }
//                    oiProductMap.put(oi.Id, oi);
//                    matchingIdSet.add(oi.L2I_blng_MatchingId__c);
//                }
//
//                //Existing AS record
//                List<L2I_Aircraft_Service__c> existingASRecords = [
//                        SELECT Id, Matching_Id__c, Aircraft__c
//                        FROM L2I_Aircraft_Service__c
//                        WHERE Aircraft__c IN:aircraftIds AND Matching_Id__c IN:matchingIdSet
//                ];
//
//                Map<String, Id> existingASMap = new Map<String, Id>();
//
//                for (L2I_Aircraft_Service__c asTemp : existingASRecords) {
//                    existingASMap.put(asTemp.Aircraft__c + '' + asTemp.Matching_Id__c, asTemp.Id);
//                }
//
//                //Create AS record
//                List<L2I_Aircraft_Service__c> newASRecords = new List<L2I_Aircraft_Service__c>();
//                Set<Id> existingIdSet = new Set<Id>();
//
//                for (Case c : scope) {
//
//                    Set<Id> temp = categoryOrderItemsMap.get( c.L2I_Product_Category_2__c );
//
//                    for (String oiId : temp) {
//                        String key = c.L2I_Aircraft__c + '' + oiProductMap.get(oiId).L2I_blng_MatchingId__c;
//                        if (existingASMap.get(key) == null) {
//                            L2I_Aircraft_Service__c newAS = new L2I_Aircraft_Service__c();
//                            newAS.Aircraft__c = c.L2I_Aircraft__c;
//                            newAS.Matching_Id__c = oiProductMap.get(oiId).L2I_blng_MatchingId__c;
//                            newAS.Product2__c = oiProductMap.get(oiId).Product2Id;
//                            newAS.Status__c = 'Pending Activation';
//                            newASRecords.add(newAS);
//                        } else {
//                            existingIdSet.add(existingASMap.get(key));
//                        }
//                    }
//                }
//
//                Database.SaveResult[] srList = Database.insert(newASRecords, false);
//                Set<Id> UpdatedId = new Set<Id>();
//
//                for (Database.SaveResult sr : srList) {
//                    if (sr.isSuccess()) {
//                        UpdatedId.add(sr.getId());
//                    }
//                }
//
//                //Update ASA with AS ID
//                UpdatedId.addAll(existingIdSet);
//
//                // Being of Req 06
//                Set<String> as_Filter =
//                        L2I_JSON_Settings.getSpecificSettingCollection('Aircraft_Services_Management_Settings',
//                                'AS Filter');
//
//                List<L2I_Aircraft_Service__c> oldASRecords = [
//                        SELECT Id, Matching_Id__c, Status__c, Aircraft__c
//                        FROM L2I_Aircraft_Service__c
//                        WHERE id IN:UpdatedId AND Status__c NOT IN: as_Filter
//                ];
//                // End of Req 06
//
//                Map<String, L2I_Aircraft_Service__c> MatchingIdASMap = new Map<String, L2I_Aircraft_Service__c>();
//
//                for ( L2I_Aircraft_Service__c asRecord : oldASRecords ){
//                    MatchingIdASMap.put( asRecord.Aircraft__c+''+asRecord.Matching_Id__c, asRecord );
//                }
//
//                for (Case c : scope) {
//
//                    Set<Id> temp = categoryOrderItemsMap.get( c.L2I_Product_Category_2__c );
//
//                    for (Id oi : temp) {
//                        if ( MatchingIdASMap.get( c.L2I_Aircraft__c +''+ oiProductMap.get(oi).L2I_blng_MatchingId__c ) != null ) {
//
//                            L2I_ASA__c newASA = new L2I_ASA__c();
//                            newASA.Order_Product__c = oi;
//                            newASA.Aircraft_Order__c = c.Id;
//                            newASA.Aircraft_Service__c = MatchingIdASMap.get(c.L2I_Aircraft__c +''+ oiProductMap.get(oi).L2I_blng_MatchingId__c).Id;
//                            newASA.Action__c = 'Activate';
//
//                            newASARecords.add(newASA);
//                        }
//                    }
//                }
//
//                Database.SaveResult[] asaList = Database.insert(newASARecords, false);
//
//                for (Case c : scope) {
//                    c.L2I_Allow_To_Reprocess__c = false;
//                }
//                update scope;
//
//            } catch ( Exception ex ){
//                Database.rollback( sp );
//                hasError = true;
//                for (Case c : scope) {
//                    c.L2I_Allow_To_Reprocess__c = true;
//                }
//                update scope;
//                system.debug( ex.getLineNumber() + ' ' + ex.getMessage() );
//            }
//        }
//
//        global void finish(Database.BatchableContext bc) {
//            if ( !hasError ){
//                if ( caseIdSets.size() > 0 ){
//                    L2I_UtilityHelper.createPlatformEvent( caseIdSets );
//                }
//            }
//        }

    }