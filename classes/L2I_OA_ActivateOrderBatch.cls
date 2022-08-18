/**
 *      @author       Sarah Kennedy
 *      @date         06/25/2020
 *      @description  L2I_OA_ActivateOrderBatch - Activates Orders
 *      This class can be run as a Batch or a Schedulable that calls the Batch.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/25/2020         Initial scaffold
 *
 */
global class L2I_OA_ActivateOrderBatch implements Database.Batchable<sObject>, Database.Stateful {
    private L2I_LoggingStringBuffer logBuffer;
    private L2I_Order_Activation_Execution_Log__c oaeLog;
    private String logGuid = '';
    private Set<Id> orderErrorIds = new Set<Id>();
    private String orderErrorMsg = '';
    private String logStatus = 'Completed';
    
    public L2I_OA_ActivateOrderBatch() {
        // for independent batch run
    }
    
    public L2I_OA_ActivateOrderBatch(String guid) {
        logGuid = guid;
        logBuffer = new L2I_LoggingStringBuffer();
        logBuffer.append('Executing AutoExtend Step 4');
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('*** Starting L2I_OA_ActivateOrderBatch');
        
        String query = ' SELECT Id, Name, OrderNumber, Type, OpportunityId, EffectiveDate, L2I_Product_Category_2__c, ' +
              'L2I_1st_Aircraft_Entered_In_Service__c,L2I_DSS_PO_Case_Closed__c,L2I_SCM_Release_Date_Captured__c, ' +
              ' Opportunity.SBQQ__RenewedContract__r.EndDate, Opportunity.L2I_AutoExtend__c ' +
              ' FROM Order ' +
              ' WHERE L2I_AutoActivate__c = true ' +
              ' AND Status = \'Draft\' ' +
              ' AND (L2I_Order_Process__c = \'Contract Management\' ' +
              ' OR L2I_Order_Process__c = \'Advertising Brand\' ) ' +
              ' AND L2I_OrderActivationAlert__c = NULL ';
        System.debug('*** query ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        System.debug('*** Executing L2I_OA_ActivateOrderBatch');
        List<Order> orders = (List<Order>) scope;
        Set <Id> orderIds = new Set<Id>();
        Set<String> ordersIdNumber = new Set<String>();
        Map<Id, Order> contractTBTDOrdMap = new Map<Id, Order>();
        System.debug('*** Executing L2I_OA_ActivateOrderBatch :: scope size :: ' + orders.size());
        for (Order ord : orders) {
            //Commented because its being taken care by Process Builder
            /*if ((ord.L2I_Product_Category_2__c == 'WiFi' || ord.L2I_Product_Category_2__c == 'TV/Media' || ord.L2I_Product_Category_2__c == 'Cell Modem' ) &&
                (ord.Opportunity.L2I_AutoExtend__c ||
                  (!ord.Opportunity.L2I_AutoExtend__c &&
                        ord.EffectiveDate <= Date.today().addDays(7)))) {
                            System.debug('*** Executing L2I_OA_ActivateOrderBatch :: For "WiFi","Cell Modem" & "TV/Media" ');
                ord.Status = 'Activated';
                orderIds.add(ord.Id);
                ordersIdNumber.add(ord.OrderNumber + ' (' + ord.Id + ') ');
                if (ord.Type == 'Renewal' &&
                      ord.EffectiveDate <= ord.Opportunity.SBQQ__RenewedContract__r.EndDate) {
                    contractTBTDOrdMap.put(ord.Opportunity.SBQQ__RenewedContract__c, ord);
                }
            }else*/
             if(ord.L2I_1st_Aircraft_Entered_In_Service__c && ord.L2I_DSS_PO_Case_Closed__c && ord.L2I_SCM_Release_Date_Captured__c
             &&  (ord.Opportunity.L2I_AutoExtend__c ||(!ord.Opportunity.L2I_AutoExtend__c && ord.EffectiveDate <= Date.today().addDays(7)))
             ){
                System.debug('*** Executing L2I_OA_ActivateOrderBatch :: For PO Case Closed, Relase Date Captured & 1st A/C entered in Service');
                ord.Status = 'Activated';
                orderIds.add(ord.Id);
                ordersIdNumber.add(ord.OrderNumber + ' (' + ord.Id + ') ');
                if (ord.Type == 'Renewal' &&
                      ord.EffectiveDate <= ord.Opportunity.SBQQ__RenewedContract__r.EndDate) {
                    contractTBTDOrdMap.put(ord.Opportunity.SBQQ__RenewedContract__c, ord);
                }
            }             
            else {
                System.debug('*** orders not activated ' + ord.OrderNumber);
            }
        }
        System.debug('*** contractTBTDOrdMap :: ' + contractTBTDOrdMap);
        String idStr = '';
        for (String s : ordersIdNumber) {
            idStr += (idStr == '' ? '' : ',') + s;
        }
        if (logGuid != '') {
            if (idStr != '') {
                logBuffer.append('Orders identified: ' + idStr);
            }
        }
        Savepoint sp = Database.setSavepoint();
        try {
            if (orders != NULL && orders.size() > 0) {
                update orders;
            }
            System.debug('*** orders ' + orders);
            // update the Renewed Contract's To Be Terminated Date
            if (!contractTBTDOrdMap.isEmpty()) {
                // find the contracts' subscriptions
                List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
                subList = [
                      SELECT Id, L2I_ToBeTerminatedDate__c, SBQQ__Contract__c,
                            SBQQ__OrderProduct__r.OrderId,
                            SBQQ__Product__r.L2I_Sub_Category_2__c
                      FROM SBQQ__Subscription__c
                      WHERE SBQQ__Contract__c IN :contractTBTDOrdMap.keySet()
                      AND SBQQ__SubscriptionType__c = 'Renewable'
                ];
                for (SBQQ__Subscription__c sub : subList) {
                    System.debug('*** sub ' + sub);
                    System.debug('*** sub.SBQQ__Product__r.L2I_Sub_Category_2__c ' + sub.SBQQ__Product__r.L2I_Sub_Category_2__c);
                    System.debug('*** sub.SBQQ__OrderProduct__r.OrderId ' + sub.SBQQ__OrderProduct__r.OrderId);
                    if (sub.SBQQ__Product__r.L2I_Sub_Category_2__c == contractTBTDOrdMap.get(sub.SBQQ__Contract__c).L2I_Product_Category_2__c) {
                        sub.L2I_ToBeTerminatedDate__c = contractTBTDOrdMap.get(sub.SBQQ__Contract__c).EffectiveDate.addDays(-1);
                    }
                }
                if (subList != NULL && subList.size() > 0) {
                    update subList;
                }
                System.debug('*** subList ' + subList);
            }
        } catch (Exception e) {
            Database.rollback(sp);
            orderErrorIds.addAll(orderIds);
            orderErrorMsg = e.getMessage() + ' ' + e.getStackTraceString();
            if (!orderErrorIds.isEmpty()) {
                setException(orderErrorMsg, orderErrorIds);
            }
            orderErrorIds.clear();
            orderErrorMsg = '';
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('*** Finishing L2I_OA_ActivateOrderBatch');
        
        if (logGuid != '') {
            String logTrace = logBuffer.toStr();
            if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
                logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
            }
            oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(logGuid);
            oaeLog.Step4_Status__c = logStatus;
            oaeLog.Step4_Log_Message__c = logTrace;
            L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
            //
            // call the next steps
            //
            Datetime now = System.now();
            Integer minsOffset = 1; // Schedule it a minute after the final batch has been completed.
            String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
            String jobId;
    
            // Create Contracts
    
            L2I_OA_CreateContractSched step5 = new L2I_OA_CreateContractSched(logGuid);
            if (!Test.isRunningTest()) {
                jobId = System.schedule('AutoExtend Step5 ' + logGuid, cronTab, step5);
            }
            System.debug('AutoExtend Step 5 ' + logGuid + ' has been scheduled as :' + jobId);
        }
    }
    
    @TestVisible
    private void setException(String msgs, Set<Id> orderIds) {
        
        Id systemAlertId = L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
              'Exception occurred while Activating orders:' + msgs,
              'Order', 'see Order Contract Management Log', UserInfo.getUserId(), false);
        
        if (!orderIds.isEmpty()) {
            List<Order> oList = [SELECT Id, L2I_OrderActivationAlert__c FROM Order WHERE Id IN :orderIds];
            for (Order o : oList) {
                o.L2I_OrderActivationAlert__c = systemAlertId;
            }
            if (oList != NULL && oList.size() > 0) {
                update oList;
            }
        }
        
        if (logGuid != '') {
            logStatus = 'Encountered Exception';
            logBuffer.append('Exception occurred while setting creating AutoExtend Activate Orders :' + msgs + ' for Orders ' + orderIds);
        }
    }
}