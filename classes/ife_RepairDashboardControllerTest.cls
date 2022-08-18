@isTest
private class ife_RepairDashboardControllerTest {

 @isTest 
    static void getRepairDashboardTest() {
        Test.setMock(HttpCalloutMock.class, new ife_RepairDashboardControllerMockCallOut());
   
        String res = ife_RepairDashboardController.getRepairDashboard();
        
        System.assertEquals('{"example":"test"}', res);
        
    }
}