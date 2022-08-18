/**
 *      @author       Raj Rajen
 *      @date         08/20/2019
 *      @description  L2I Aircraft Service Activated Platform Event Handler.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/20/2019         Initial scaffold
 *      Sarah Kennedy                 03/26/2020         Creating order activation log here to pass the guid to the order activation steps
 *      Sarah Kennedy                 04/10/2020         US1762 added orderMap__c field for Order Activation by Case
 *
 */
trigger L2I_AircraftServiceActivationTrigger on L2I_Aircraft_Service_Activated__e (after insert) {

    System.debug('====== Reacting to L2I_Aircraft_Service_Activated__e Platform Event');

    // We need to check if the scheduled job is not already running first or if it is already
    // scheduled. Only if those two conditions are met, should the "Order Activation Step 1'
    // job be scheduled. Otherwise we will run into exception situations
    for (L2I_Aircraft_Service_Activated__e asa : Trigger.new) {
        System.debug('*** asa ' + asa);
        System.debug('*** L2I_Aircraft_Service_Activated__e orderMap__c ' + asa.orderMap__c);
        // create the order activation log so we can pass the guid into the order activation steps
        L2I_Order_Activation_Execution_Log__c logEntry = L2I_OAExecutionLog_Helper.createLogEntry();
        String isLike = 'Order Activation Step 1 ' + logEntry.GUID__c;
        System.debug('*** isLike ' + isLike);
    
        List<CronTrigger> cronJobs = new List<CronTrigger>([
              select Id,
                    CreatedBy.Username,
                    CreatedDate,
                    CronExpression,
                    CronJobDetail.Name,
                    EndTime,
                    NextFireTime,
                    PreviousFireTime,
                    StartTime,
                    State,
                    TimesTriggered,
                    TimeZoneSidKey
              from CronTrigger
              where CronJobDetail.Name like :isLike
        ]);
        System.debug('*** L2I_AircraftServiceActivationTrigger cronJobs empty? ' + cronJobs.isEmpty());
        if (cronJobs.isEmpty()) {
            Datetime now = Datetime.now();
            System.debug('*** Start OrderActivation');
            L2I_OrderActivation_Orchestrator step1 = new L2I_OrderActivation_Orchestrator(logEntry.GUID__c, asa.orderMap__c);
            String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, 1, 0);
            System.debug('*** Schedule Step 1 ' + logEntry.GUID__c + ' job');
            String jobId = System.schedule('Order Activation Step 1 ' + logEntry.GUID__c, cronTab, step1);
        
            System.debug('====== Cron Setting :' + cronTab);
            System.debug('====== Order Activation Step 1 has been scheduled as jobId :' + jobId);
        }
    }

}