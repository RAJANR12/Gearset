@isTest
private class ife_RepairDetailsControllerTest {
   @isTest
    public static void getRepairDetailsTest(){
         Test.setMock(HttpCalloutMock.class, new IfeMockServiceCallout());
        
        ife_RepairDetailsController repairDetail = new ife_RepairDetailsController();
        ife_RepairDetailsController.getRepairDetails('1234');
    }
}