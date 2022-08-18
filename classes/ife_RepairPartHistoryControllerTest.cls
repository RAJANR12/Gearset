@isTest
private class ife_RepairPartHistoryControllerTest {
    @isTest
    public static void getRepairPartHistoryTest(){
          Test.setMock(HttpCalloutMock.class, new IfeMockServiceCallout());
        
        ife_RepairPartHistoryController repairPartHistory = new ife_RepairPartHistoryController();
        ife_RepairPartHistoryController.getRepairPartHistory(null,null);
    }
}