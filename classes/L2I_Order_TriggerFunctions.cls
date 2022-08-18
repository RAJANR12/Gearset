/**
 *      @author       Raj Rajen
 *      @date         07/28/2019
 *      @description  L2I Opportunity Trigger Functions
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/28/2019         Initial scaffold
 *      Andy Fang                     08/12/2019         Added DSS Platform Event
 *      Andy Fang                     10/31/2019         Added Advertising Platform Event
 *      Andy Fang                     02/06/2020         Adding US1144 - Update program number for amend/renew orders
 *      Andy Fang                     03/12/2020         US1595 - Populate original sales oppo on Order
 *      Sarah Kennedy                 03/24/2020         US1618 - Obsolete Opp/Quote checks
 *      Sarah Kennedy                 05/06/2020         Check for NULL OpportunityId in Obsolete checks
 *      Sarah Kennedy                 05/30/2020         US1919 - cancelReplaceContracts
 */
public without sharing class L2I_Order_TriggerFunctions {
    /** This Method is refactored method to simplify Code from many other methods
       *  to update fields on the order object fields before update/insert
       *  following methods has been included in this methods and commented out.
       *  setProgramNumberOnOrder - Update Program number fields from opportunity to order on 7/2/2020 - Sanjay S
       *  new functionality to set Order Process Fields on 7/2/2020 - Sanjay S
      */
    public static void setOrderFieldsBeforeInsert(List<Order> newOrderList) {

        Set<Id> reqUpdateIdSet = new Set<Id>();
        Map<Id, Opportunity> OptyMap = new Map<Id, Opportunity>();

        // Gather list of unique Opportunity Ids
        for (Order ord : newOrderList) {
            if (! reqUpdateIdSet.contains(ord.OpportunityId)){
                reqUpdateIdSet.add( ord.OpportunityId );
            }
        }

        // Retrive Opportunity Fields
        List<Opportunity> OptyList = [ SELECT Id, L2I_Program_Number__c, L2I_Product_Category__c,
                L2I_AutoExtend__c, L2I_Delivery_Schedule__c, L2I_Original_Opportunity__c
        FROM Opportunity
        WHERE id IN: reqUpdateIdSet ];

        // Populate Opportunity Map
        for ( Opportunity opt : OptyList ){
            OptyMap.put( opt.Id, opt);
        }

        System.debug('======= Order Trigger Before Insert Opportunity Query Count ======:' +OptyMap.size());

        // Process all orders in new trigger
        for (Order newOrd : newOrderList) {
            Opportunity Opty = OptyMap.get( newOrd.OpportunityId );
            if ( Opty != null ) {
                // initialize Order Process field
                if (newOrd.L2I_Order_Process__c == null){
                    if (Opty.L2I_Product_Category__c == 'DSS' || Opty.L2I_Product_Category__c == 'PTS' ) {
                        newOrd.L2I_Order_Process__c = 'Contract Management';
                    }
                }

                // Update any field here for Contract Management Order Process.
                if (newOrd.l2I_Order_Process__c == 'Contract Management'){
                    //Update Program number field
                    if (newOrd.L2I_Program_Number__c == null){
                        newOrd.L2I_Program_Number__c = opty.L2I_Program_Number__c;
                    }

                    //Update delivery schedule
                    if (newOrd.L2I_Delivery_Schedule__c == null) {
                        newOrd.L2I_Delivery_Schedule__c = opty.L2I_Delivery_Schedule__c;
                    }

                    //update billing Day of the month for Connectivity orders
                    Integer billingDayOfMonth = newOrd.EffectiveDate.day();
                    String orderProductCategory = newOrd.L2I_Product_Category_2__c;
                    if ('wifi'.equalsIgnoreCase(orderProductCategory)) {
                        newOrd.blng__BillingDayOfMonth__c = '1'; // US-2069
                    }else {
                        newOrd.blng__BillingDayOfMonth__c = String.valueOf(billingDayOfMonth);
                    }

                    //Update Order Auto Activate for AutoExtend Opportunity - US2069
                    if (!newOrd.L2I_AutoActivate__c && newOrd.Type == 'Renewal' && opty.L2I_AutoExtend__c){
                        newOrd.L2I_AutoActivate__c = true;
                    }

                    // Update order original sales opportunity field
                    if (newOrd.L2I_Original_Sales_Opportunity__c == null) {
                        if (Opty.L2I_Original_Opportunity__c != null) {
                            // update for renewal and amendment orders
                            newOrd.L2I_Original_Sales_Opportunity__c = Opty.L2I_Original_Opportunity__c;
                        } else {
                            // update for new sales orders
                            newOrd.L2I_Original_Sales_Opportunity__c = newOrd.OpportunityId;
                        }
                    }
                }
            }
        }
    }

    /** This Method is refactored method to simplify Code from many other methods
      *  to update fields on the order object fields before update
      *  following methods has been included in this methods and commented out.
      *  setProgramNumberOnOrder - Update Program number fields from opportunity to order on 7/2/2020 - Sanjay S
      *  new functionality to set Order Process Fields on 7/2/2020 - Sanjay S
     */
    public static void setOrderFieldsBeforeUpdate(List<Order> newOrderList) {

        for (Order newOrd : newOrderList) {
            System.debug('*** newOrd ' + newOrd);
            System.debug('*** newOrd.L2I_Order_Process__c ' + newOrd.L2I_Order_Process__c);
            System.debug('*** newOrd.L2I_Product_Category_2__c ' + newOrd.L2I_Product_Category_2__c);
            // initialize Order Process field for advertising brand, Contract Management is set during before insert.
            // Added null check by Arun
            if (newOrd.L2I_Order_Process__c == null && newOrd.L2I_Product_Category_2__c != null && newOrd.L2I_Product_Category_2__c.equalsIgnoreCase('advertisers/brands')) {
                newOrd.L2I_Order_Process__c = 'Advertising Brand';
            }
        }
    }


    /**
     * Method OrdersProcessvalues determines if new order list contians
     * any L2I_Order_Process__c with null  values
     * @param newOrderList
     * Created on 7/6/2020 by Sanjay S for US 2094
     */
    public static boolean hasOrderProcessValues(List<Order> newOrderList, String Str1, String Str2){
        for (Order newOrd : newOrderList) {
            if (newOrd.L2I_Order_Process__c == null || newOrd.L2I_Order_Process__c == Str1 || newOrd.L2I_Order_Process__c == Str2) {
                return true;
            }
        }
        return false;
    }

    /** no longer needed refactored into before insert trigger on 7/6 by sanjay
    public static void setDeliverySchedule(List<Order> newOrderList) {
        System.debug('====== Number of orders to set delivery schedule on :' + newOrderList.size());
        
        Set<Id> affectedIds = new Set<Id>();
        for (Order ord : newOrderList) {
            affectedIds.add(ord.Id);
        }
        
        List<Order> createdOrders = new List<Order>([select Id,
              OpportunityId,
              Opportunity.L2I_Delivery_Schedule__c,
              L2I_Delivery_Schedule__c
        from Order
        where Id in :affectedIds]);
        
        for (Order ord : createdOrders) {
            System.debug('====== Setting Order DSH ' + ord.L2I_Delivery_Schedule__c + ' to be Opportunity\'s DSH ' + ord.Opportunity.L2I_Delivery_Schedule__c);
            ord.L2I_Delivery_Schedule__c = ord.Opportunity.L2I_Delivery_Schedule__c;

        }
        
        System.debug('====== Number of orders to update delivery schedule on :' + createdOrders.size());
        if (!createdOrders.isEmpty()) {
            update createdOrders;
        }
    
    }
**/
    /**
        We need to update this to accomdate other platform event being refiring at the order Item level
        The current case only handle create media, we are adding create advertsing.
     **/
    public static void refireDSSPlatformEvent(List<Order> newOrderList,  Map<Id, Order> newOrderMap, Map<Id, Order> oldOrderMap){
        if (hasOrderProcessValues(newOrderList,'Contract Management', 'Advertising Brand')) {
            Set<Id> affectedRecords = new Set<Id>();
            Set<Id> affectedRecordAdvs = new Set<Id>();

            for (Order ord : newOrderList) {
                // only execute if Contract management or Advertising Brand Order Process
                if (ord.L2I_Order_Process__c == 'Contract Management' || ord.L2I_Order_Process__c == 'Advertising Brand') {
                    Order newRec = newOrderMap.get(ord.Id);
                    Order oldRec = oldOrderMap.get(ord.Id);

                    if (newRec.L2I_IntegrationStatus__c != null &&
                            newRec.L2I_IntegrationStatus__c.equalsIgnoreCase('Ready to Integrate') &&
                            newRec.L2I_IntegrationStatus__c != oldRec.L2I_IntegrationStatus__c) {

                        // Added category separation for MCS product
                        if (newRec.L2I_Product_Category_2__c != null) {
                            if (newRec.L2I_Product_Category_2__c.equalsIgnoreCase('mcs')) {
                                affectedRecords.add(ord.Id);
                            }
                            if (newRec.L2I_Product_Category_2__c.equalsIgnoreCase('advertisers/brands') ||
                                    newRec.L2I_Product_Category_2__c.equalsIgnoreCase('advertising')) {
                                affectedRecordAdvs.add(ord.Id);
                            }
                        }
                    }
                }
            }

            if (!affectedRecords.isEmpty()) {
                List<L2I_Order_Create_Media__e> ocmList = new List<L2I_Order_Create_Media__e>();
                for (Id oid : affectedRecords) {
                    System.debug('======= Setting up Order Create Media Platform Event for Order Id :' + oid);
                    L2I_Order_Create_Media__e ocm = new L2I_Order_Create_Media__e();
                    ocm.RecordID__c = oid;
                    ocmList.add(ocm);
                }

                System.debug('======= Refiring ' + ocmList.size() + ' DSS Order Create Platform Event(s)');
                if (ocmList.size() > 0) {
                    EventBus.publish(ocmList);
                }
            }

            if (!affectedRecordAdvs.isEmpty()) {
                List<L2I_Order_Create_Advertising__e> ocaList = new List<L2I_Order_Create_Advertising__e>();
                for (Id oid : affectedRecordAdvs) {
                    System.debug('======= Setting up Order Create Advertising Platform Event for Order Id :' + oid);
                    L2I_Order_Create_Advertising__e oca = new L2I_Order_Create_Advertising__e();
                    oca.RecordID__c = oid;
                    ocaList.add(oca);
                }

                System.debug('======= Refiring ' + ocaList.size() + ' Advertising Order Create Platform Event(s)');

                if (ocaList.size() > 0) {
                    List<Database.SaveResult> results = EventBus.publish(ocaList);
                    for (Database.SaveResult sr : results) {
                        if (sr.isSuccess()) {
                            System.debug('Successfully published event.');
                        } else {
                            for (Database.Error err : sr.getErrors()) {
                                System.debug('Error returned: ' +
                                        err.getStatusCode() +
                                        ' - ' +
                                        err.getMessage());
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
        This function is for US1144
        Program Number Copied from original Order associated on to the Amendment/Renewal Order

        To do : TBD
        order gets created -> copy pn from opp ( reg ) to order

        7/1/2020 Sanjay - added code to set Order Process field

     **/
    /** public static void setProgramNumberOnOrder(List<Order> newOrderList) {

        Set<Id> reqUpdateIdSet = new Set<Id>();
        Map<Id, String> OrderIdProgNumbMap = new Map<Id, String>();
        Map<Id, String> OrderIdProdCategoryMap = new Map<Id, String>();

        for (Order ord : newOrderList) {
            reqUpdateIdSet.add(ord.Id);
        }

        List<Order> oldOrderList = [
                SELECT Id, Opportunity.L2I_Program_Number__c, Opportunity.L2I_Product_Category__c
                FROM Order
                WHERE id IN:reqUpdateIdSet
        ];

        for (Order ord : oldOrderList) {
            OrderIdProgNumbMap.put(ord.Id, ord.Opportunity.L2I_Program_Number__c);
            OrderIdProdCategoryMap.put(ord.Id, ord.Opportunity.L2I_Product_Category__c);
        }

        for (Order ord : newOrderList) {
            if (OrderIdProgNumbMap.get(ord.Id) != null) {
                ord.L2I_Program_Number__c = OrderIdProgNumbMap.get (ord.Id);
            }
            if (ord.L2I_Order_Process__c == null && OrderIdProdCategoryMap.get(ord.Id) == 'DSS') {
                ord.L2I_Order_Process__c = 'Contract Management';
            }
        }
    } **/

/**  The requirement is updated to pull from Order opportunity program number
List<Order> oldOrderList = [ SELECT Id, SBQQ__Quote__r.SBQQ__Type__c, SBQQ__Quote__r.SBQQ__MasterContract__c,
        Opportunity.SBQQ__RenewedContract__c,
        Opportunity.SBQQ__RenewedContract__r.SBQQ__Order__r.L2I_Program_Number__c,
        SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.L2I_Program_Number__c
        FROM Order
        WHERE id IN: reqUpdateIdSet  ];

system.debug( '************************************* 1 ' );
system.debug(  oldOrderList );

for ( Order ord : oldOrderList ){

    if ( ord.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment' &&
            ord.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.L2I_Program_Number__c != null ){
        OrderIdProgNumbMap.put( ord.Id, ord.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.L2I_Program_Number__c );
    }
    if ( ord.SBQQ__Quote__r.SBQQ__Type__c == 'Renewal' &&
            ord.Opportunity.SBQQ__RenewedContract__r.SBQQ__Order__r.L2I_Program_Number__c != null ){
        OrderIdProgNumbMap.put( ord.Id, ord.Opportunity.SBQQ__RenewedContract__r.SBQQ__Order__r.L2I_Program_Number__c );
    }

}

for (Order ord : newOrderList) {
    if ( OrderIdProgNumbMap.get( ord.Id ) != null ) {
        ord.L2I_Program_Number__c = OrderIdProgNumbMap.get ( ord.Id );
    }
}
**/
    
    /**
        US1595
        Populate Original Sales Opportunity link on Order
     **/
/** refactored on 7/6 by sanjay in before insert method.
    public static void setOriginalSalesOpportunity(List<Order> newOrderList) {
        
        Set<Id> reqUpdateIdSet = new Set<Id>();
        Map<Id, String> OrderIdOriginalSalesIdMap = new Map<Id, String>();
        
        for (Order ord : newOrderList) {
            reqUpdateIdSet.add(ord.Id);
        }
        
        List<Order> oldOrderList = [
              SELECT Id, Opportunity.RecordType.developername, OpportunityId,
                    L2I_Original_Sales_Opportunity__c,
                    SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.L2I_Original_Sales_Opportunity__c,
                    Opportunity.SBQQ__RenewedContract__r.SBQQ__Opportunity__c
              FROM Order
              WHERE id IN:reqUpdateIdSet
        ];
        
        for (Order ord : oldOrderList) {
            
            if (ord.Opportunity.RecordType.developername == 'Sales' && ord.OpportunityId != null) {
                OrderIdOriginalSalesIdMap.put(ord.Id, ord.OpportunityId);
            }
            
            if (ord.Opportunity.RecordType.developername == 'Amendment' &&
                  ord.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.L2I_Original_Sales_Opportunity__c != null) {
                OrderIdOriginalSalesIdMap.put(ord.Id, ord.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.L2I_Original_Sales_Opportunity__c);
            }
            
            if (ord.Opportunity.RecordType.developername == 'Renewal' &&
                  ord.Opportunity.SBQQ__RenewedContract__r.SBQQ__Opportunity__c != null) {
                OrderIdOriginalSalesIdMap.put(ord.Id, ord.Opportunity.SBQQ__RenewedContract__r.SBQQ__Opportunity__c);
            }
        }
        
        for (Order ord : newOrderList) {
            if (OrderIdOriginalSalesIdMap.get(ord.Id) != null) {
                ord.L2I_Original_Sales_Opportunity__c = OrderIdOriginalSalesIdMap.get (ord.Id);
            }
        }
    
    }
**/
    public static void checkObsoleteQuotesOppsOnCreate(List<Order> newOrderList) {
        if (!hasOrderProcessValues(newOrderList, 'Contract Management', '')) {
            // no orders to process
            return;
        }
        System.debug('*** in checkObsoleteQuotesOppsOnCreate ' + newOrderList);
        Map<String, String> ordOppMap = new Map<String, String>();
        Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
        for (Order ord : newOrderList){
            System.debug('*** ord.OpportunityId ' + ord.OpportunityId);
            
            if (ord.OpportunityId != null) {
                System.debug('*** ord.Opportunity.SBQQ__AmendedContract__c ' + ord.Opportunity.SBQQ__AmendedContract__c);
                ordOppMap.put(ord.Id, ord.OpportunityId);
            }
        }
        // find all opportunities to get the amended/renewal contract value
        for (Opportunity opp : [SELECT Id,
              SBQQ__AmendedContract__c,
              SBQQ__RenewedContract__c,
              StageName,
              SBQQ__PrimaryQuote__c,
              RecordTypeId
        FROM Opportunity
        WHERE Id IN :ordOppMap.values()]){
            oppMap.put(opp.Id, opp);
        }
        
        Set<String> newOrdOppIds = new Set<String>();
        Set<String> amendRenewalIds = new Set<String>();
        
        for (Order ord : newOrderList) {
            newOrdOppIds.add(ord.OpportunityId);
            String oppId = ordOppMap.get(ord.Id);
            Opportunity opp = oppMap.get(oppId);
            if (opp != NULL) {
                if (opp.SBQQ__AmendedContract__c != NULL) {
                    amendRenewalIds.add(opp.SBQQ__AmendedContract__c);
                }
                if (opp.SBQQ__RenewedContract__c != NULL) {
                    amendRenewalIds.add(opp.SBQQ__RenewedContract__c);
                }
            }
        }
        if (amendRenewalIds.size() > 0) {
            checkObsoleteQuotesOpps(amendRenewalIds, newOrdOppIds);
        }
    }
    
    public static void checkObsoleteQuotesOppsOnActivate(List<Order> newOrderList,  Map<Id, Order> newOrderMap, Map<Id, Order> oldOrderMap) {
        if (!hasOrderProcessValues(newOrderList, 'Contract Management', '')) {
            // no orders to process
            return;
        }

        System.debug('*** in checkObsoleteQuotesOppsOnActivate ' + newOrderList);
        Map<String, String> ordOppMap = new Map<String, String>();
        Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
        
        for (Order ord : newOrderList){
            Order newRec = newOrderMap.get(ord.Id);
            Order oldRec = oldOrderMap.get(ord.Id);
            System.debug('*** oldRec ' + oldRec);
            
            if (newRec.Status != null &&
                  newRec.Status == 'Activated' &&
                  newRec.Status != oldRec.Status) {
                System.debug('*** ord.OpportunityId ' + ord.OpportunityId);
                if (ord.OpportunityId != null) {
                    System.debug('*** ord.Opportunity.SBQQ__AmendedContract__c ' + ord.Opportunity.SBQQ__AmendedContract__c);
                    ordOppMap.put(ord.Id, ord.OpportunityId);
                }
            }
        }
        // find all opportunities to get the amended/renewal contract value
        List<String> ordOppMapValues = ordOppMap.values();
        if (!ordOppMapValues.isEmpty()) {
            for (Opportunity opp : [SELECT Id,
              SBQQ__AmendedContract__c,
              SBQQ__RenewedContract__c,
              StageName,
              SBQQ__PrimaryQuote__c,
              RecordTypeId
            FROM Opportunity
            WHERE Id IN :ordOppMap.values()]){
                oppMap.put(opp.Id, opp);
            }
        }
        
        
        Set<String> newOrdOppIds = new Set<String>();
        Set<String> amendRenewalIds = new Set<String>();
        
        for (Order ord : newOrderList) {
            Order newRec = newOrderMap.get(ord.Id);
            Order oldRec = oldOrderMap.get(ord.Id);
            
            if (newRec.Status != null &&
                  newRec.Status == 'Activated' &&
                  newRec.Status != oldRec.Status) {
                newOrdOppIds.add(ord.OpportunityId);
                String oppId = ordOppMap.get(ord.Id);
                Opportunity opp = oppMap.get(oppId);
                if (opp != NULL) {
                    if (opp.SBQQ__AmendedContract__c != NULL) {
                        amendRenewalIds.add(opp.SBQQ__AmendedContract__c);
                    }
                    if (opp.SBQQ__RenewedContract__c != NULL) {
                        amendRenewalIds.add(opp.SBQQ__RenewedContract__c);
                    }
                }
            }
        }
        if (amendRenewalIds.size() > 0) {
            checkObsoleteQuotesOpps(amendRenewalIds, newOrdOppIds);
        }
    }
    
    private static void checkObsoleteQuotesOpps(Set<String> amendRenewalIds, Set<String> newOrdOppIds){
        System.debug('*** in checkObsoleteQuotesOpps ');
        System.debug('*** amendRenewalIds ' + amendRenewalIds);
        System.debug('*** newOrdOppIds ' + newOrdOppIds);
        Set<String> oppsToObsolete = new Set<String>();
        List<Opportunity> oppsToCloseList = new List<Opportunity>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        
        // find all the Amendment/Renewal opportunites that match the new order opportunity
        for (Opportunity oppty : [
              SELECT Id,
                    SBQQ__AmendedContract__c,
                    SBQQ__RenewedContract__c,
                    StageName
              FROM Opportunity
              WHERE (SBQQ__AmendedContract__c IN :amendRenewalIds
              OR SBQQ__RenewedContract__c IN :amendRenewalIds)
              AND RecordType.DeveloperName IN ('Amendment', 'Renewal')
              AND SBQQ__PrimaryQuote__r.SBQQ__Ordered__c <> TRUE
              AND Id NOT IN :newOrdOppIds
        ]) {
            System.debug('*** oppty to close ' + oppty);
            oppsToObsolete.add(oppty.Id);
            oppty.StageName = 'Closed Lost';
            oppty.L2I_Closed_Lost_Reasoning__c = 'Obsolete by System';
            oppty.L2I_Win_Loss_Date__c = Date.today();
            oppsToCloseList.add(oppty);
        }
        // find the quotes to obsolete
        if (oppsToObsolete.size() > 0) {
            for (SBQQ__Quote__c sbQuote : [
                  SELECT Id,
                        L2I_Obsolete__c,
                        SBQQ__Opportunity2__c
                  FROM SBQQ__Quote__c
                  WHERE SBQQ__Opportunity2__c IN :oppsToObsolete
            ]) {
                System.debug('*** quote to obsolete ' + sbQuote);
                if (sbQuote.L2I_Obsolete__c != true) {
                    sbQuote.L2I_Obsolete__c = true;
                    quoteList.add(sbQuote);
                }
            }
        }
        // do the updates
        System.debug('*** oppsToCloseList.size() ' + oppsToCloseList.size());
        update oppsToCloseList;
        System.debug('*** quoteList.size() ' + quoteList.size());
        update quoteList;
    }
    
//    public static void cancelReplaceContracts(List<Order> newOrderList,  Map<Id, Order> newOrderMap, Map<Id, Order> oldOrderMap) {
//        System.debug('*** in cancelReplaceContracts ' + newOrderList);
//        List<Id> activatedRenewalOrdIds = new List<Id>();
//        // when a renewal order is activated, terminate renewed contract subscriptions and orderitems
//        for (Order ord : newOrderList) {
//            Order newRec = newOrderMap.get(ord.Id);
//            Order oldRec = oldOrderMap.get(ord.Id);
//            if (newRec.Type == 'Renewal' &&
//                  newRec.Status != null &&
//                  newRec.Status == 'Activated' &&
//                  newRec.Status != oldRec.Status) {
//                activatedRenewalOrdIds.add(newRec.Id);
//            }
//        }
//        if (!activatedRenewalOrdIds.isEmpty() &&
//              activatedRenewalOrdIds.size() > 0){
//            L2I_CancelReplaceService.cancelPrior(activatedRenewalOrdIds);
//        }
//    }
    
    public static void closeOrders(List<Order> newOrderList, Map<Id, Order> oldOrderMap) {
        Map<Id, Integer> caseClosedOrdersMap = new Map<Id, Integer>();
        
        for (Order order : newOrderList) {
            Order oldRec = oldOrderMap.get(order.Id);
            if (oldRec.PT_Ext_Order_Header_Status__c != 'CANCELLED' &&
                  oldRec.PT_Ext_Order_Header_Status__c != 'CLOSED') {
                if (order.PT_Ext_Order_Header_Status__c == 'CANCELLED' ||
                      order.PT_Ext_Order_Header_Status__c == 'CLOSED') {
                    if (order.PT_Ext_Order_Header_Status__c != oldRec.PT_Ext_Order_Header_Status__c &&
                          order.PT_Case__c != null) {
                        // initialize case map
                        caseClosedOrdersMap.put(order.PT_Case__c, 0);
                    }
                }
            }
        }
        // find any open orders for the cases
        List<Case> caseToUpdateList = new List<Case>();
        for (Order ord : [
              SELECT Id, PT_Case__c
              FROM Order
              WHERE PT_Case__c IN :caseClosedOrdersMap.keySet()
              AND PT_Ext_Order_Header_Status__c NOT IN ('CLOSED', 'CANCELLED')
        ]) {
            Integer tmpCount = caseClosedOrdersMap.get(ord.PT_Case__c);
            tmpCount++;
            caseClosedOrdersMap.put(ord.PT_Case__c, tmpCount);
        }
        
        for (Id caseId : caseClosedOrdersMap.keySet()) {
            // check for no open orders
            if (caseClosedOrdersMap.get(caseId) == 0) {
                Case c = new Case(
                      Id = caseId,
                      Status = 'Order Closed'
                );
                caseToUpdateList.add(c);
            }
        }
        System.debug('*** caseToUpdateList.size() ' + caseToUpdateList.size());
        if (!caseToUpdateList.isEmpty() && caseToUpdateList.size() > 0) {
            update caseToUpdateList;
        }
    }
    
    
    public static void publishOrders(List<Order> newOrderList,  Map<Id, Order> oldOrderMap, Boolean isInsert, Boolean isUpdate) {
        Map<String, PT_Create_Order__e> createOrders = new Map<String, PT_Create_Order__e >();
        Set<String> orderHeaderStatus = new Set<String>{'CLOSED','BOOKED','PENDING APPROVAL','CANCELLED','ENTERED','APPROVED'};
        for(Order order : newOrderList) {
            if(order.PT_Integration_Status__c == 'Ready to Integrate' && !orderHeaderStatus.contains(order.PT_Ext_Order_Header_Status__c) && (isInsert || (isUpdate && order.PT_Integration_Status__c != oldOrderMap.get(order.Id).PT_Integration_Status__c))) {
                createOrders.put(order.Id, new PT_Create_Order__e(L2I_OrderId__c = order.Id, L2I_Order_Process__c = 'Program Table'));
            }
        }
        if(!createOrders.isEmpty()) { EventBus.publish(createOrders.values());}
    }
}