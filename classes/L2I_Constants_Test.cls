@isTest
private class L2I_Constants_Test {
    @isTest static void myTest() {
        L2I_Constants c = new L2I_Constants();
        c.L2I_Constants();
        //ptc.L2I_PrecisionTailCountUtils(system.today(),true);
        //c.productUsageList();
        //L2I_Constants.BLANK_STRING='';
        //System.assertEquals(L2I_Constants.BLANK_STRING, '');
        Test.startTest();
        System.assertEquals('',L2I_Constants.BLANK_STRING);
        System.assertEquals('Approved',L2I_Constants.APPROVED_STRING);
        System.assertEquals('Order',L2I_Constants.ORDER_OBJ_NAME);
        System.assertEquals('Completed',L2I_Constants.RECORDJOB_STATUS_COMPLETED);
        System.assertEquals('Select One',L2I_Constants.SELECT_ONE);
        System.assertEquals('None',L2I_Constants.NONE);
        Test.stopTest();
    }
}