global with sharing class L2I_ConnectivityProductRollUpScheduler Implements Schedulable {
    public L2I_ConnectivityProductRollUpScheduler() {

    }

    global void execute(SchedulableContext sc)    {
        Map<String, Object> params = new Map<String, Object>();
        Flow.Interview.L2I_Connectivity_Product_Roll_Up myFlow
                = new Flow.Interview.L2I_Connectivity_Product_Roll_Up(params);
        myFlow.start();
    }
}


/*
 * Anonymous Code block to execute this class
 L2I_ConnectivityProductRollUpScheduler doit = new L2I_ConnectivityProductRollUpScheduler();
 doit.execute(null);

 * Code block to schedule this class
 *  Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
 L2I_ConnectivityProductRollUpScheduler setit = new L2I_ConnectivityProductRollUpScheduler();
 String sch = '0 7 0,12 * * ?';
 String jobID = system.schedule('L2I_ConnectivityProductRollUpScheduler', sch, setit);
 System.debug(' .  ******* . L2I_ConnectivityProductRollUpScheduler . jobID ' + jobID);

 System.debug(' .  ******* .  ' + System.now().format());
 System.abortJob('08e8A00000FjaPF');  // Use JobId 
 */