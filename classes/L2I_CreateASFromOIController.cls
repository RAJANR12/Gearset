/**
 *      @author       Andy Fang
 *      @date         07/12/2019
 *      @description  Auto Create Aircraft Service From Order Product
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                     07/12/2019         Initial scaffold
 *      Andy Fang                     04/01/2020         Commenting Out
 */

global class L2I_CreateASFromOIController {

    /*
   @InvocableMethod
   public static void autoCreateAircraftServicesFromOI( List<Id> orderItemIds ) {

       try {
           //Getting a list of order Item being created
           List<OrderItem> oiList = [SELECT Id, L2I_Delivery_Schedule__c, OrderId, SBQQ__Subscription__c FROM orderItem WHERE Id in:orderItemIds];

           Set<Id> HeaderIdSet = new Set<Id>();
           Set<Id> orderIdSet = new Set<Id>();

           Map<String, String> DSOrderMap = new Map<String, String>();
           Map<String, String> ACDSMap = new Map<String, String>();

           //Map<String, String> AircraftOrderMap = new Map<String,String>();
           Map<String, String> ExistingAircraftOrderMap = new Map<String, String>();
           List<L2I_Aircraft_Order__c> newAOList = new List<L2I_Aircraft_Order__c>();

           // To create set of Header ID, Order ID and create Mapping for DS to Order (?)
           for (OrderItem oi : oiList) {
               if (oi.L2I_Delivery_Schedule__c != NULL)
                   HeaderIdSet.add(oi.L2I_Delivery_Schedule__c);
               if (oi.OrderId != NULL)
                   orderIdSet.add(oi.OrderId);
               if (oi.L2I_Delivery_Schedule__c != NULL && oi.OrderId != NULL)
                   DSOrderMap.put(oi.L2I_Delivery_Schedule__c, oi.OrderId);
           }
           System.debug(' 1. HeaderIdSet ' + HeaderIdSet);
           System.debug(' 2. orderIdSet ' + orderIdSet);
           System.debug(' 3. DSOrderMap ' + DSOrderMap);

           // To create Aircraft set related, might need to add more filter
           List<L2I_DSL__c> dslList = [SELECT Id, Aircraft__c, Delivery_Schedule_Header__c FROM L2I_DSL__c where Delivery_Schedule_Header__c in:HeaderIdSet AND L2I_Aircraft_Confirmation__c = true];

           // To create Aircraft Id set and mapping (?)
           Set<Id> AircraftIdSet = new Set<Id>();

           for (L2I_DSL__c dsl : dslList) {
               if (dsl.Aircraft__c != NULL && dsl.Delivery_Schedule_Header__c != NULL) {
                   AircraftIdSet.add(dsl.Aircraft__c);
                   ACDSMap.put(dsl.Aircraft__c, dsl.Delivery_Schedule_Header__c);
               }
           }

           System.debug(' 4. orderIdSet ' + orderIdSet);

           // To process record if order and aircraft record exists
           if (orderIdSet.size() > 0 && AircraftIdSet.size() > 0) {

               //Query for all the existing aircraft order and create existing mapping
               List<L2I_Aircraft_Order__c> aoList = [SELECT Id, Aircraft__c, Order__c FROM L2I_Aircraft_Order__c WHERE Aircraft__c in :AircraftIdSet AND Order__c in :orderIdSet];
               System.debug(' 5. aoList ' + aoList);

               for (L2I_Aircraft_Order__c ao : aoList) {
                   if (ao.Aircraft__c != NULL && ao.Order__c != NULL && ao.Id != NULL)
                       ExistingAircraftOrderMap.put(ao.Aircraft__c + '' + ao.Order__c, ao.Id);
               }
               System.debug(' 6. ExistingAircraftOrderMap ' + ExistingAircraftOrderMap);

               // Begins to Search for the correct AO ID
               // Search for existing AO record, if AO doesn't exists, creating the record
               // And update the mapping with the AO ID
               for (Id aID : AircraftIdSet) {
                   for (Id oID : orderIdSet) {

                       String uID = aID + '' + oID;

                       if (ExistingAircraftOrderMap.get(uID) == NULL) {
                           //Create new AO record
                           L2I_Aircraft_Order__c nao = new L2I_Aircraft_Order__c();
                           nao.Aircraft__c = aID;
                           nao.Order__c = oID;

                           newAOList.add(nao);
                       }

                   }
               }

               System.debug(' 7. newAOList ' + newAOList);

               Database.SaveResult[] srList = Database.insert(newAOList, false);
               Set<Id> newlyAOSetID = new Set<Id>();

               for (Database.SaveResult sr : srList) {
                   newlyAOSetID.add (sr.getId());
               }

               List<L2I_Aircraft_Order__c> newlyaoList = [SELECT Id, Aircraft__c, Order__c FROM L2I_Aircraft_Order__c WHERE ID in :newlyAOSetID];
               System.debug(' 8. newlyaoList ' + newlyaoList);

               // Adding into the existing Mapping
               for (L2I_Aircraft_Order__c ao : newlyaoList) {
                   //not record should be existed here, therefore adding into list
                   if (ao.Aircraft__c != NULL && ao.Order__c != NULL && ao.Id != NULL)
                       ExistingAircraftOrderMap.put(ao.Aircraft__c + '' + ao.Order__c, ao.Id);
               }

               //Creating Aircraft Service record
               List<L2I_Aircraft_Service__c> asList = new List<L2I_Aircraft_Service__c>();

               for (OrderItem oi : oiList) {
                   for (Id aID : AircraftIdSet) {
                       // To insert into the AS only if the aircraft is same as the delievery schedule
                       if (ACDSMap.get(aID) != NULL && oi.L2I_Delivery_Schedule__c == ACDSMap.get(aID)) {
                           L2I_Aircraft_Service__c asItem = new L2I_Aircraft_Service__c();
                           asItem.Status__c = 'Pending Activation';
                           asItem.Aircraft__c = aID;
                           asItem.Order_Product__c = oi.Id;
                           String UID = aID + '' + oi.OrderId;
                           if (ExistingAircraftOrderMap.get(UID) != NULL)
                               asItem.Aircraft_Order__c = ExistingAircraftOrderMap.get(UID);
                           //asItem.Subscription__c = oi.SBQQ__Subscription__c;
                           asList.add(asItem);
                       }
                   }
               }

               System.debug(' 9. asList ' + asList);

                if ( asList.size() > 0 )
                    insert asList;

               if ( newlyAOSetID.size() > 0 )
                   L2I_UtilityHelper.createPlatformEvent( newlyAOSetID );
           }
       } catch ( Exception ex ){
           System.debug('L2I_CreateASFromOIController has an issue : ' + ex.getMessage());
       }
   }
    */

}