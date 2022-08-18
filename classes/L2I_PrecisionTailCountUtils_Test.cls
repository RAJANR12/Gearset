@isTest
private class L2I_PrecisionTailCountUtils_Test {

    @isTest
    static void test_initializers() {
        Date targetDate = Date.today() -9;
        L2I_PrecisionTailCountUtils myObj1 = new L2I_PrecisionTailCountUtils();
        System.assert(myObj1 != null);
        L2I_PrecisionTailCountUtils myObj2 = new L2I_PrecisionTailCountUtils(targetDate);
        System.assert(myObj2 != null);
        L2I_PrecisionTailCountUtils myObj3 = new L2I_PrecisionTailCountUtils(targetDate,true);
        System.assert(myObj3 != null);
        L2I_PrecisionTailCountUtils myObj4 = new L2I_PrecisionTailCountUtils(targetDate,'fred');
        System.assert(myObj4 != null);
    }

    @isTest static void myTest() {
        L2I_PrecisionTailCountUtils ptc = new L2I_PrecisionTailCountUtils();
        ptc.productUsageList();
        //ptc.processJSONmodels();
        ptc.processUsages();
        ptc.processBillingModels();
        ptc.execute();
    }
}