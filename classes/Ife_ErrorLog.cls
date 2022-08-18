public class Ife_ErrorLog{
	public static void createErrorLog(String className, String errorMessage){
        if(String.isNotBlank(className) && String.isNotBlank(errorMessage)){
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = errorMessage;
            log.Class_Name__c = className;
            insert log;

        }
	}
}