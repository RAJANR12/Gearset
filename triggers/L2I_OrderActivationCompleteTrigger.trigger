/**
 *      @author       Raj Rajen
 *      @date         08/09/2019
 *      @description  L2I Order Activation Completed Platform Event Handler.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     08/09/2019         Initial scaffold
 *      Sarah Kennedy                 03/26/2020         LogId added to SOQL filter
 *      Sarah Kennedy                 06/2602020         US2046 - AutoExtend - just look for the GUID in the jobname
 *
 */
trigger L2I_OrderActivationCompleteTrigger on L2I_Order_Activation_Completed__e (after insert) {
    
    System.debug('====== Reacting to Order Activation Completed Platform Event');
    
    for (L2I_Order_Activation_Completed__e oac : Trigger.new) {
        System.debug('*** OAC logId ' + oac.logId__c);
        if (!String.isEmpty(oac.logId__c)) {
            String isLike = '%' + oac.logId__c;
            System.debug('*** OAC isLike ' + isLike);
            List<CronTrigger> cronJobs = new List<CronTrigger>([
                  SELECT Id,
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
                  FROM CronTrigger
                  WHERE CronJobDetail.Name LIKE :isLike
                  AND NextFireTime = NULL
                  AND State = 'DELETED'
            ]);
            for (CronTrigger job : cronJobs) {
                System.debug('*** Unscheduling job ' + job);
                System.debug('====== Unscheduling JobId: ' + job.Id);
                System.abortJob(job.Id);
            }
        }
    }
}