@isTest
private class ife_GCS_DocumentsControllerTest {
	@isTest
    public static void getGCS_DocumentTest(){
        Test.setMock(HttpCalloutMock.class, new ife_GCS_DocumentsControllerMockCallOut());
        
        String Status = ife_GCS_DocumentsController.getGCS_Document('air');
        System.assertEquals('{"status":"success"}', Status);
    }
}