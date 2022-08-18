@isTest
private class ife_DocumentTabsControllerTest {
    
    @isTest
    public static void getGCS_AirframeTest(){
        Test.setMock(HttpCalloutMock.class, new ife_DocumentTabsControllerMockCallOut());
        
        String returnValue = ife_DocumentTabsController.getGCS_Airframe();
        System.assertNotEquals(null, returnValue);
    }
}