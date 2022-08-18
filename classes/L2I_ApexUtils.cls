/**
 * Utility class for common operations
 *
 * Any classes that use Schema.SObjectField, this property is object by calling "Schema.Account.Description"
 * This allows type safety to ensure that code will not break if fields are changed
 * this will not work with person accounts
 *
 */
public class L2I_ApexUtils {

    public class NoParentRecordIncludedException extends Exception {}
    
    private static final String ID_STR = 'Id'; 
    private static Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();
    public static String instanceURL = System.URL.getSalesforceBaseURL().toExternalForm();
    public static String subDomainWithProtocol = (System.URL.getSalesforceBaseURL().toExternalForm()).split('\\.')[0];
    public static final Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
    public static Map<String, Map<String, Schema.SObjectField>> mapObjNameToFieldMap = new Map<String, Map<String, Schema.SObjectField>>();

    public static Boolean runningInASandbox {
        get {
            if (runningInASandbox == null) {
                runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return runningInASandbox;
        }
        set;
    }


    


    /**
     * Get environment short name from url.
     * @param none
     * @return String of the environment name
     * Example:
     *   URL structure: https://xyzcompany.my.salesforce.com
     *   This method will return 'xyzcompany'
     */
    public static String getEnvironmentName() {//used
        return getEnvironmentName(null);
    }
    /* Optionally pass in a string to detect in the subDomainWithProtocol name and truncate after that.
     * Example:
     *   URL structure: https://xyzcompany--dev.cs77.my.salesforce.com
     *   Passing in '--' as the parameter will cause the method to return 'dev'
     */ 
    public static String getEnvironmentName(String urlPortionToSnipAfter) {
        // subDomainWithProtocol is set at the class level to allow mocking in unit test by setting specific URL
        if(urlPortionToSnipAfter == null || !subDomainWithProtocol.contains(urlPortionToSnipAfter)) {
            urlPortionToSnipAfter = 'https://'; 
        }
        Integer intIndex = subDomainWithProtocol.indexOf(urlPortionToSnipAfter) + urlPortionToSnipAfter.length();
        String envName = subDomainWithProtocol.substring(intIndex, subDomainWithProtocol.length());
      
        return envName;
    }


    /** 
     * @description -> method to parse field references, even if in dot notation (ex: Contact.Account.Name)
     *  Example: if I have a queried Task record where I queried Contact.Account.Name from the Task,
     *  if I pass in the Task record and 'Contract.Account.Name' as a string, this method will return the value stored in the 'Name'.
     * @param SObject record -> the record in which to parse the field reference from
     * @param String fieldReference -> the field reference in which to parse. Ex: 'Contact.Account.Name' will get the Name field value parsed
     * @return Object fieldVal -> the String, Integer, Boolean, etc parsed value. Ex: 'Contact.Account.Name' will return the value in the Account's Name field which is a String primitive Object.
     */
    public static Object parseFieldPathForSObject(SObject record, String fieldReference) {//used
        SObject tempObj = record; // if field has a "." this holds the nested objects until fields is reached
        Object fieldVal;
        // If provided field is using dot notation, get nested object and field
        if(!fieldReference.contains('.')) {
            return record.get(fieldReference);
        } else {
            List<String> fields = fieldReference.split('\\.');
            for(String splitField : fields) {
                try {
                    tempObj = (SObject)tempObj.getSobject(splitField);
                } catch (Exception ex) {
                    try{
                        fieldVal = tempObj == null ? null : tempObj.get(splitField);
                    } catch (Exception exx) {
                        return null;
                    }
                }
            }
        }
        return fieldVal;
    }

    /**
     * @description -> Method to get properties of a field set.
     * @usage example:
     *  List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet('SBQQ__LineEditor','SBQQ__Quote__c');
     *  for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
     *      system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
     *      system.debug('Label ====>' + fieldSetMemberObj.getLabel());
     *      system.debug('Required ====>' + fieldSetMemberObj.getRequired());
     *      system.debug('DbRequired ====>' + fieldSetMemberObj.getDbRequired());
     *      system.debug('Type ====>' + fieldSetMemberObj.getType());   //type - STRING,PICKLIST
     *  }
     *
     * @param String fieldSetName -> name of field set you wish to get the properties (ex: fields) for
     * @return List<Schema.FieldSetMember -> field set properties to return.
     *///used
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)  {
        Schema.SObjectType SObjectTypeObj = globalDescribe.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }

    /**
     * @description -> Method to get list of field API names to query, given a Schema.FieldSetMember list:
     * @param List<Schema.FieldSetMember> fieldSetMemberList -> a Schema.FieldSetMember list in which to parse the field API names from
     * @return List<String> fieldSetFieldAPINames -> a list of field API names parsed from the field set parameter
     */ 
    public static List<String> getFieldSetFieldAPINames(List<Schema.FieldSetMember> fieldSetMemberList) {
        Set<String> fieldSetFieldAPINamesSet = new Set<String>();
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {   
            fieldSetFieldAPINamesSet.add(fieldSetMemberObj.getFieldPath());
        }
        List<String> fieldSetFieldAPINames = new List<String>(fieldSetFieldAPINamesSet);
        return fieldSetFieldAPINames;
    }

 

    /**
     * @description -> create an 18 character fake id 
     * @param String IdPrefix -> 3 character id prefix (ex: a0h)
     * @return Id fakeId
     */
    public static Id create18CharFakeId(String IdPrefix) {//used
        String fakeIdTemplate = IdPrefix + '000000001111111';
        Integer random7DigitInt = Math.round((Math.random() * (9000000) + 1000000));
        Id fakeId = fakeIdTemplate.replace('1111111', String.valueOf(random7DigitInt));
        return fakeId;
    }

    
}