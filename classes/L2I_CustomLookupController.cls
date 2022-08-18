/**
 *      @author       Sarah Kennedy
 *      @date         11/20/2019
 *      @description  Controller class to support LWC custom lookup
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 01/03/2020         Initial creation
 *
 */
public with sharing class L2I_CustomLookupController {
    
    @AuraEnabled
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value, String objectIds) {
        System.debug('*** in getResults ');
        System.debug('ObjectName ' + ObjectName);
        System.debug('fieldName ' + fieldName);
        System.debug('value ' + value);
        value = value.trim();
        String orderBy = fieldName;
        String searchQuery = '';
        if (ObjectName == 'L2I_DSL__c'){
            orderBy = 'CreatedDate DESC ';
        }
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        System.debug('fieldName: ' + fieldName + 'ObjectName: ' + ObjectName + ' Value: ' + value + ' objectIds ' + objectIds);
        if (String.isNotEmpty(value)) {
            if (ObjectName == 'PT_Note__c') {
                searchQuery = 'SELECT Id,' + fieldName + ' FROM ' + ObjectName + ' WHERE PT_Opportunity__c = ' + '\'' + objectIds + '\'' + ' AND ' + fieldName + ' LIKE \'%' + value + '%\' ORDER BY ' + orderBy;
            } else if (ObjectName == 'L2I_Aircraft__c') {
                searchQuery = 'SELECT Id, Name, L2I_Serial_Number__c FROM L2I_Aircraft__c ' + ' ' +
                      'WHERE Name LIKE \'%' + value + '%\' OR  PT_PMO_Serial__c  LIKE \'' + value + '\' OR  L2I_Block_Number__c LIKE \'%' + value + '%\' ORDER BY ' + orderBy + ' LIMIT 15';
            } else {
                searchQuery = 'SELECT Id,' + fieldName + ' FROM ' + ObjectName + ' WHERE ' + fieldName + ' LIKE \'%' + value + '%\' ORDER BY ' + orderBy + ' LIMIT 10';
            }
            System.debug('*** searchQuery ' + searchQuery);
            for (sObject so : Database.Query(searchQuery)) {
                String fieldvalue = (String) so.get(fieldName);
                System.debug('*** fieldvalue ' + fieldvalue);
                sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
            }
        }
        
        return sObjectResultList;
    }
    
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }
}