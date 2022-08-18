/**
 *      @author       Raj Rajen
 *      @date         07/28/2019
 *      @description  L2I Order Trigger Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/28/2019         Initial scaffold
 *      Andy Fang                     08/12/2019         DSS platform event
 *      Andy Fang                     02/06/2020         Adding US1144 - Update program number for amend/renew orders
 */
public without sharing class L2I_Order_TriggerHandler extends L2I_TriggerHandler {

    private Map<Id, Order> newOrderMap;
    private List<Order> newOrderList;

    private Map<Id, Order> oldOrderMap;
    private List<Order> oldOrderList;

    public L2I_Order_TriggerHandler() {
        this.newOrderMap = (Map<Id, Order>) Trigger.newMap;
        this.newOrderList = (List<Order>) Trigger.new;

        this.oldOrderMap = (Map<Id, Order>) Trigger.oldMap;
        this.oldOrderList = (List<Order>) Trigger.old;
    }

    public override void beforeUpdate() {
        // valid trigger context vars:
        //     newOrderList  (modifiable)
        //     newOrderMap
        //     oldOrderList
        //     oldOrderMap
        System.debug('====== executing L2I_Order_TriggerHander::beforeUpdate()');
        // Replaced setProgramNumberOnOrder by setOrderFieldsBeforeUpdateOrInsert method on 7/3/2020 by Sanjay Singhal
        L2I_Order_TriggerFunctions.setOrderFieldsBeforeUpdate(newOrderList);
        //L2I_Order_TriggerFunctions.setOriginalSalesOpportunity(newOrderList);
    }

    public override void afterInsert() {
        // valid trigger context vars:
        //     newOrderList  (not modifiable)
        //     newOrderMap
        System.debug('====== executing L2I_Order_TriggerHander::afterInsert()');
        //L2I_Order_TriggerFunctions.setDeliverySchedule(newOrderList);
        L2I_Order_TriggerFunctions.checkObsoleteQuotesOppsOnCreate(newOrderList);
        L2I_Order_TriggerFunctions.publishOrders(newOrderList, null, Trigger.isInsert, Trigger.isUpdate); // Added by Arun
    }

    public override void beforeInsert() {
        // valid trigger context vars:
        //     newOrderList  (modifiable)
        System.debug('====== executing L2I_Order_TriggerHander::beforeInsert()');
        //L2I_Order_TriggerFunctions.setProgramNumberOnOrder(newOrderList); only call if n
        L2I_Order_TriggerFunctions.setOrderFieldsBeforeInsert(newOrderList);
    }

    public override void afterUpdate() {
        // valid trigger context vars:
        //     newOrderList  (not modifiable)
        //     newOrderMap
        //     oldOrderList
        //     oldOrderMap
        System.debug('======= executing Order_TriggerHander::afterUpdate()');
        L2I_Order_TriggerFunctions.refireDSSPlatformEvent(newOrderList, newOrderMap, oldOrderMap);
        L2I_Order_TriggerFunctions.checkObsoleteQuotesOppsOnActivate(newOrderList, newOrderMap, oldOrderMap);
//        L2I_Order_TriggerFunctions.cancelReplaceContracts(newOrderList, newOrderMap, oldOrderMap);
        L2I_Order_TriggerFunctions.publishOrders(newOrderList, oldOrderMap, Trigger.isInsert, Trigger.isUpdate); // Added by Arun
        L2I_Order_TriggerFunctions.closeOrders(newOrderList, oldOrderMap);  // W-002521, T-00535
    }

    public override void beforeDelete() {
        // valid trigger context vars:
        //     oldOrderList
        //     oldOrderMap
        System.debug('======= executing Order_TriggerHander::beforeDelete()');
    }

    public override void afterDelete() {
        // valid trigger context vars:
        //     oldOrderList
        //     oldOrderMap
        System.debug('======= executing Order_TriggerHander::afterDelete()');
    }

    public override void afterUndelete() {
        // valid trigger context vars:
        //     newOrderList  (not modifiable)
        //     newOrderMap
        System.debug('====== executing L2I_Order_TriggerHander::afterUndelete()');
    }

}