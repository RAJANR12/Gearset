/**
* @File Name          : L2I_ConnectivityScheduler_Test.cls
* @Description        : Test Class for L2I_ConnectivityProductRollUpScheduler
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : Mar 31, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
*               Mar 31 2022    MS Simplus Khrisna   Updated to fix test class error
**/
@isTest
private class L2I_ConnectivityScheduler_Test {
    
    static testmethod void test() {
        
        L2I_ConnectivityProductRollUpScheduler abs = new L2I_ConnectivityProductRollUpScheduler();
        String yearNow = String.valueOf(DateTime.now().addYears(1).year());
        String cronTime = '0 0 0 15 3 ? ' + yearNow;
        String jobId = System.schedule('myJobTestJobName', cronTime, abs);

        abs.execute(null);
    }
}