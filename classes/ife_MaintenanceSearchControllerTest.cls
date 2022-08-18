@isTest
private class ife_MaintenanceSearchControllerTest {
    
    @isTest 
    public static void ife_MaintenanceSearchControllerTest(){
        ife_MaintenanceSearchController controller = new ife_MaintenanceSearchController();
    }
    
    @isTest 
    public static void getSearchResultTest(){
        List<String> stringList = new List<String>();
        stringList.add('abc');
        stringList.add('vf');
        stringList.add('test');
       String jsonString = ife_MaintenanceSearchController.getSearchResult(stringList);
        System.assertNotEquals(NULL, jsonString);
    }
    
    @isTest 
    public static void ApiResponseDataTest(){
        ife_MaintenanceSearchController.ApiResponseData responseData = new ife_MaintenanceSearchController.ApiResponseData();
        ife_MaintenanceSearchController.getDataFromApi();
    }
}