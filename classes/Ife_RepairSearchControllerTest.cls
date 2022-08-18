@isTest
private class Ife_RepairSearchControllerTest {
     @isTest
    public static void getRepairSearchResultsTest(){
         Test.setMock(HttpCalloutMock.class, new IfeMockServiceCallout());
        
       //  Account acc = ife_TestDataUtil.createAccount(true);
        Ife_RepairSearchController repairSearchCntrl = new  Ife_RepairSearchController();
         Ife_RepairSearchController.getRepairSearchResults('acc',null, null, null, null, null, null, null ,null, null);
    }
}