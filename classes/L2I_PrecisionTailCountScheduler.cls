global with sharing class L2I_PrecisionTailCountScheduler Implements Schedulable {
    public L2I_PrecisionTailCountScheduler() {

    }

    global void execute(SchedulableContext sc)    {
        Map<String, Object> params = new Map<String, Object>();
        Flow.Interview.L2I_Precision_Tail_Count_Update myFlow
                = new Flow.Interview.L2I_Precision_Tail_Count_Update(params);
        myFlow.start();
    }

}

/*
 * Anonymous Code block to execute this class
 L2I_PrecisionTailCountScheduler doit = new L2I_PrecisionTailCountScheduler();
 doit.execute(null);

 * Code block to schedule this class
 *  Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
 L2I_PrecisionTailCountScheduler setit = new L2I_PrecisionTailCountScheduler();
 String sch = '0 30 3 9 * ?';
 String jobID = system.schedule('L2I_PrecisionTailCountScheduler', sch, setit);
 System.debug(' .  ******* . L2I_PrecisionTailCountScheduler . jobID ' + jobID);

 System.debug(' .  ******* .  ' + System.now().format());
 System.abortJob('08e1800000Ou9aYAAR');  // JobId 
 */