/**
 *      @author       Raj Rajen
 *      @date         07/28/2019
 *      @description  L2I OrderItem Trigger Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/28/2019         Initial scaffold
 *      Andy Fang                     04/22/2019         DE417 enabling after update trigger
 *      Andy Fang                     05/08/2019         Remove DE417 trigger due to recursive calls
 */
public without sharing class L2I_OrderItem_TriggerHandler extends L2I_TriggerHandler {

    private Map<Id, OrderItem> newOrderItemMap;
    private List<OrderItem> newOrderItemList;

    private Map<Id, OrderItem> oldOrderItemMap;
    private List<OrderItem> oldOrderItemList;

    public L2I_OrderItem_TriggerHandler() {
        this.newOrderItemMap = (Map<Id, OrderItem>) Trigger.newMap;
        this.newOrderItemList = (List<OrderItem>) Trigger.new;

        this.oldOrderItemMap = (Map<Id, OrderItem>) Trigger.oldMap;
        this.oldOrderItemList = (List<OrderItem>) Trigger.old;
    }

//    public override void beforeUpdate() {
        // valid trigger context vars:
        //     newOrderItemList  (modifiable)
        //     newOrderItemMap
        //     oldOrderItemList
        //     oldOrderItemMap
//        System.debug('====== executing L2I_OrderItem_TriggerHander::beforeUpdate()');
//    }

    public override void afterInsert() {
        // valid trigger context vars:
        //     newOrderItemList  (not modifiable)
        //     newOrderItemMap
        System.debug('====== executing L2I_OrderItem_TriggerHander::afterInsert()');
        //[RR]L2I_OrderItem_TriggerFunctions.setDeliverySchedule(newOrderItemList);
        //[RR]L2I_OrderItem_TriggerFunctions.setParentOrderFields(newOrderItemList);
        L2I_OrderItem_TriggerFunctions.setFieldsOnCreation(newOrderItemList);
        L2I_OrderItem_TriggerFunctions.updateAllFieldsOnParent(newOrderItemList);
    }

    public override void beforeInsert() {
        // valid trigger context vars:
        //     newOrderItemList  (modifiable)
        System.debug('====== executing L2I_OrderItem_TriggerHander::beforeInsert()');
        L2I_OrderItem_TriggerFunctions.updateDeliverySchedulefromOrder(newOrderItemList);
        L2I_OrderItem_TriggerFunctions.populateLisPriceId(newOrderItemList); // Added by Arun
    }

    public override void afterUpdate() {
        // valid trigger context vars:
        //     newOrderItemList  (not modifiable)
        //     newOrderItemMap
        //     oldOrderItemList
        //     oldOrderItemMap
        System.debug('======= executing OrderItem_TriggerHander::afterUpdate()');
        //L2I_OrderItem_TriggerFunctions.setBillingTreatmentForTBOrderProduct(newOrderItemList);
        //L2I_OrderItem_TriggerFunctions.updateEndDateOnParentAfterUpdate(newOrderItemList, oldOrderItemMap );
    }

//    public override void beforeDelete() {
        // valid trigger context vars:
        //     oldOrderItemList
        //     oldOrderItemMap
//        System.debug('======= executing OrderItem_TriggerHander::beforeDelete()');
//    }

//    public override void afterDelete() {
        // valid trigger context vars:
        //     oldOrderItemList
        //     oldOrderItemMap
//        System.debug('======= executing OrderItem_TriggerHander::afterDelete()');
//    }

//    public override void afterUndelete() {
        // valid trigger context vars:
        //     newOrderItemList  (not modifiable)
        //     newOrderItemMap
//        System.debug('====== executing L2I_OrderItem_TriggerHander::afterUndelete()');
//    }

}