@isTest
private class ife_EditablePendingQuotesControllerTest {
    
    @isTest
    public static void getFeesFromApiCallTest(){
        Test.setMock(HttpCalloutMock.class, new ife_EditablePendingQuotesCntrlMock());
        
        String returnValue =  ife_EditablePendingQuotesController.getFeesFromApiCall('123');
        System.assertNotEquals(null, returnValue);
    }
}