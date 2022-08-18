/**
 *      @author       Raj Rajen
 *      @date         11/20/2019
 *      @description  Controller class to support DSL inline editing and saving functionality
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     11/20/2019         Initial scaffold
 *
 *
 */
public class L2I_DeliveryScheduleLineController {

    public class FieldMappingEntry {
        public String fieldName {get; set;}
        public String fieldApiName {get; set;}
        public String fieldType {get; set;}
        public Boolean isOptional {get; set;}

        public FieldMappingEntry(String varName, String apiName, String type) {
            this.fieldName = varName;
            this.fieldApiName = apiName;
            this.fieldType = type;
            this.isOptional = false;
        }

        public FieldMappingEntry(String varName, String apiName, String type, Boolean optional) {
            this.fieldName = varName;
            this.fieldApiName = apiName;
            this.fieldType = type;
            this.isOptional = optional;
        }

    }

    private static Map<String, FieldMappingEntry> fieldMapping = new Map<String, FieldMappingEntry>();

    static {
        fieldMapping.put('dslId',                new FieldMappingEntry('dslId', 'Id', 'String'));
        fieldMapping.put('aircraftName',         new FieldMappingEntry('aircraftName', 'Aircraft__c', 'String'));
        fieldMapping.put('aircraftConfirmation', new FieldMappingEntry('aircraftConfirmation', 'L2I_Aircraft_Confirmation__c', 'String'));
        fieldMapping.put('lineNumber',           new FieldMappingEntry('lineNumber', 'Line_Number__c', 'String'));
        fieldMapping.put('deliveryDate',         new FieldMappingEntry('deliveryDate', 'Delivery_Date__c', 'Date'));
        fieldMapping.put('seatEndDate',          new FieldMappingEntry('seatEndDate', 'Seat_End_Date__c', 'Date'));
        fieldMapping.put('headEndDate',          new FieldMappingEntry('headEndDate', 'Head_End_Date__c', 'Date'));
        fieldMapping.put('outOfWarrantyDate1',   new FieldMappingEntry('outOfWarrantyDate1', 'Out_of_Warranty_Date_1__c', 'Date', true));
        fieldMapping.put('outOfWarrantyDate2',   new FieldMappingEntry('outOfWarrantyDate2', 'Out_of_Warranty_Date_2__c', 'Date', true));
    }

    /*
    private static final Map<String, String> fieldMapping = new Map<String, String>{
                                                                  'dslId'                => 'Id',
                                                                  'aircraftName'         => 'Aircraft__c',
                                                                  'aircraftConfirmation' => 'L2I_Aircraft_Confirmation__c',
                                                                  'lineNumber'           => 'Line_Number__c',
                                                                  'deliveryDate'         => 'Delivery_Date__c',
                                                                  'seatEndDate'          => 'Seat_End_Date__c',
                                                                  'headEndDate'          => 'Head_End_Date__c',
                                                                  'outOfWarrantyDate1'   => 'Out_of_Warranty_Date_1__c',
                                                                  'outOfWarrantyDate2'   => 'Out_of_Warranty_Date_2__c'};
    */

    @AuraEnabled
    public static void updateDSLs(String dsls) {

        System.debug('======= In coming DSLs json :' + dsls);
        Map<String, Object> outerMap = (Map<String, Object>) JSON.deserializeUntyped(dsls);
        List<Object> dslList = (List<Object>) outerMap.get('data');

        List<L2I_DSL__c> dslsToUpdate = new List<L2I_DSL__c>();

        try {
            for (Object dslRow : dslList) {
                Map<String, Object> dsMap = (Map<String, Object>) dslRow;
                System.debug('****** dsMap: ' + dsMap);

                if (dsMap.containsKey('dslId')) {
                    SObject aDsl = new L2I_DSL__c();

                    for (String key : dsMap.keySet()) {
                        if (fieldMapping.containsKey(key)) {
                            String fieldName = fieldMapping.get(key).fieldApiName;
                            String fieldValue = (String) dsMap.get(key);
                            if (fieldName.containsIgnoreCase('_Date_')) {
                                if (fieldValue == null || String.isEmpty(fieldValue)) {
                                    throw new AuraHandledException('Date values cannot be empty. Please enter a valid date and resubmit');
                                }
                                Date dateValue = Date.valueOf(fieldValue);
                                aDsl.put(fieldName, dateValue);
                            } else {
                                aDsl.put(fieldName, fieldValue);
                            }

                        }
                    }

                    dslsToUpdate.add((L2I_DSL__c)aDsl);
                }
            }
        } catch (TypeException te) {
            System.debug('====== Type conversion exception occurred: ' + te);
            throw new AuraHandledException('Encountered invalid data : "' + te.getMessage() + '" Please correct the invalid data and resubmit');
        }


        if (!dslsToUpdate.isEmpty()) {
            try {
                update dslsToUpdate;
            } catch(DmlException dmle) {
                System.debug('====== DmlException encountered while attempting to save records: ' + dmle);
                throw new AuraHandledException('There was an error while trying to save the modified record(s): ' + dmle.getMessage());
            }
        }

    }

    public static String getType(Object o) {
        if (o == null) return 'null';  // we can't say much about null with our current techniques
        if (o instanceof SObject)      return ((SObject)o).getSObjectType().getDescribe().getName()+'';
        if (o instanceof Boolean)      return 'Boolean';
        if (o instanceof Id)           return 'Id';
        if (o instanceof String)       return 'String';
        if (o instanceof Blob)         return 'Blob';
        if (o instanceof Date)         return 'Date';
        if (o instanceof Datetime)     return 'Datetime';
        if (o instanceof Time)         return 'Time';
        if (o instanceof String)       return 'String';
        if (o instanceof Integer)      return 'Integer';
        if (o instanceof Long)         return 'Long';
        if (o instanceof Decimal)      return 'Decimal';  // we can't distinguish between decimal and double
        if (o instanceof Double)       return 'Double';   // we can't distinguish between decimal and double
        if (o instanceof List<Object>) return 'List';
        return 'Object';               // actually we can't detect maps and sets and maps
    }

    @AuraEnabled
    public static void updateDSL(String dslJSON) {

        System.debug('====== DSL json :' + dslJSON);
        Map<String, Object> dslMap = (Map<String, Object>) JSON.deserializeUntyped(dslJSON);

        for (String key : dslMap.keySet()) {
            String varName  = key;
            Object varValue = dslMap.get(key);
            String varType  = getType(varValue);
            System.debug('====== Key :' + varName + ' Value :' + varValue + ' Type :' + varType);
        }

        Boolean aircraftReset = false;
        if (dslMap.containsKey('aircraftConfirmation')) {
            if (!dslMap.containsKey('aircraftName')) {
                Boolean aircraftConfirmation = (Boolean) dslMap.get('aircraftConfirmation');
                if (aircraftConfirmation) {
                    throw new AuraHandledException('Aircraft confirmation cannot be specified without an associated Aircraft');
                }
            } else {
                Object varValue = dslMap.get('aircraftName');
                String varType  = getType(varValue);
                if (varType.equalsIgnoreCase('String')) {
                    String aircraftName = (String) dslMap.get('aircraftName');
                    if (aircraftName.length() == 0) {
                        aircraftReset = true;
                    }
                }
            }
        }


        // TODO: Refactor the following code after changing the fieldMapping structure from a Map to a Map of a Map
        //       or perhaps make the logic cleaner by using simpler methods to handle each field that comes in via the dslMap
        //       The following code started out generic and has ended up being too specialized. (12/11 - RR)
        if (dslMap.containsKey('dslId')) {
            Id dslId = (Id) dslMap.get('dslId');

            SObject aDsl = [select Id,
                                   Aircraft__c,
                                   L2I_Aircraft_Confirmation__c,
                                   Line_Number__c,
                                   Delivery_Date__c,
                                   Head_End_Date__c,
                                   Seat_End_Date__c,
                                   Out_of_Warranty_Date_1__c,
                                   Out_of_Warranty_Date_2__c
                              from L2I_DSL__c
                             where Id = :dslId limit 1];

            for (String key : dslMap.keySet()) {

                if (!fieldMapping.containsKey(key)) {
                    continue; // we dont care about a few fields like createdBy, createdDate, linkName, lineNumber, dslName
                              // as those are not editable
                }
                String fieldName = fieldMapping.get(key).fieldName;
                String fieldApiName = fieldMapping.get(key).fieldApiName;
                String fieldType = fieldMapping.get(key).fieldType;
                Boolean isOptional = fieldMapping.get(key).isOptional;

                if (key.equalsIgnoreCase('aircraftName')) {
                    Object varValue = dslMap.get(key);
                    String varType  = getType(varValue);
                    if (varType.equalsIgnoreCase('String')) {
                        String airCraftName = (String) varValue;
                        if (airCraftName.length() > 0) {
                            continue; // aircraft has not been changed
                        } else {
                            aDsl.put('Aircraft__c', ''); // aircraft has been removed
                            aDsl.put('L2I_Aircraft_Confirmation__c', false);
                        }
                    } else if (varType.equalsIgnoreCase('Object')) {  // a new aircraft has been set
                        Map<String, Object> selectedAircraftMap = (Map<String, Object>) varValue;
                        String aircraftId = (String) selectedAircraftMap.get('Id');
                        aDsl.put('Aircraft__c', aircraftId);
                    }
                } else if (fieldMapping.containsKey(key)) {
                    Object varValue = dslMap.get(key);
                    String varType  = getType(varValue);

                    if (fieldType.equalsIgnoreCase('Date')) {  // date fields
                        String fieldValue = (String) dslMap.get(key);
                        if ((fieldValue == null || String.isEmpty(fieldValue)) && !isOptional) {
                            throw new AuraHandledException('Date values cannot be empty. Please enter a valid ' + fieldName + ' and resubmit');
                        }
                        if (fieldValue == null || String.isEmpty(fieldValue)) {
                            aDsl.put(fieldApiName, null);
                        } else {
                            Date dateValue = Date.valueOf(fieldValue);
                            aDsl.put(fieldApiName, dateValue);
                        }
                    } else {
                        if (varType.equals('Boolean')) {  // L2I_Aircraft_Confirmation__c field
                            if (aircraftReset) {
                                aDsl.put(fieldApiName, false); // if the aircraft is being reset, we need the confirmation to be set to false;
                            } else {
                                Boolean boolValue = Boolean.valueOf(varValue);
                                aDsl.put(fieldApiName, boolValue);
                            }
                        } else { // all other fields
                            String stringValue = String.valueOf(varValue);
                            aDsl.put(fieldApiName, stringValue);
                        }

                    }
                }
            }

            try {
                update((L2I_DSL__c)aDsl);
            } catch (DmlException dmle) {
                throw new AuraHandledException('Exception occurred while updating DSL record : ' + dmle.getMessage());
            }

        }
    }

}