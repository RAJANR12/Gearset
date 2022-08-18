public class L2I_SingleSObjectLookupController {
    @AuraEnabled
    public static List <SObject> fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = '%' + searchKeyWord + '%';

        List<SObject> returnList = new List<SObject>();

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        String sQuery =  'select id, Name, OwnerId from ' + ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 8';
        List<SObject> lstOfRecords = Database.query(sQuery);

        for (SObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}