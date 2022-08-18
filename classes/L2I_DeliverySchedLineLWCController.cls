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
 *      Sarah Kennedy                 01/03/2020         Created for LWC
 *
 */
public class L2I_DeliverySchedLineLWCController {
    
    public class FieldMappingEntry {
        public String fieldName { get; set; }
        public String fieldApiName { get; set; }
        public String fieldType { get; set; }
        public Boolean isOptional { get; set; }
        public String fieldLabel { get; set; }
        
        public FieldMappingEntry(String varName, String apiName, String type, String label) {
            this.fieldName = varName;
            this.fieldApiName = apiName;
            this.fieldType = type;
            this.isOptional = false;
            this.fieldLabel = label;
        }
        
        public FieldMappingEntry(String varName, String apiName, String type, String label, Boolean optional) {
            this.fieldName = varName;
            this.fieldApiName = apiName;
            this.fieldType = type;
            this.isOptional = optional;
            this.fieldLabel = label;
        }
    }
    
    private static Map<String, FieldMappingEntry> fieldMapping = new Map<String, FieldMappingEntry>();
    
    static {
        fieldMapping.put('dslId', new FieldMappingEntry('dslId', 'Id', 'String', 'String'));
        fieldMapping.put('aircraftName', new FieldMappingEntry('aircraftName', 'Aircraft__c', 'String', 'Aircrafy Identifier'));
        fieldMapping.put('aircraftConfirmation', new FieldMappingEntry('aircraftConfirmation', 'L2I_Aircraft_Confirmation__c', 'Boolean', 'Confirmation'));
        fieldMapping.put('lineNumber', new FieldMappingEntry('lineNumber', 'Line_Number__c', 'String', 'Line No.'));
        fieldMapping.put('deliveryDate', new FieldMappingEntry('deliveryDate', 'Delivery_Date__c', 'Date', 'Delivery Date'));
        fieldMapping.put('seatEndDate', new FieldMappingEntry('seatEndDate', 'Seat_End_Date__c', 'Date', 'Seat End Date'));
        fieldMapping.put('headEndDate', new FieldMappingEntry('headEndDate', 'Head_End_Date__c', 'Date', 'Head End Date'));
        fieldMapping.put('outOfWarrantyDate1', new FieldMappingEntry('outOfWarrantyDate1', 'Out_of_Warranty_Date_1__c', 'Date', 'Out of Warranty Date1', true));
        fieldMapping.put('outOfWarrantyDate2', new FieldMappingEntry('outOfWarrantyDate2', 'Out_of_Warranty_Date_2__c', 'Date', 'Out of Warranty Date2', true));
    }
    
    public static String getType(Object o) {
        if (o == null) return 'null';  // we can't say much about null with our current techniques
        if (o instanceof SObject) return ((SObject) o).getSObjectType().getDescribe().getName() + '';
        if (o instanceof Boolean) return 'Boolean';
        if (o instanceof Id) return 'Id';
        if (o instanceof String) return 'String';
//        if (o instanceof Blob) return 'Blob';
//        if (o instanceof Date) return 'Date';
//        if (o instanceof Datetime) return 'Datetime';
//        if (o instanceof Time) return 'Time';
//        if (o instanceof String) return 'String';
//        if (o instanceof Integer) return 'Integer';
//        if (o instanceof Long) return 'Long';
//        if (o instanceof Decimal) return 'Decimal';  // we can't distinguish between decimal and double
//        if (o instanceof Double) return 'Double';   // we can't distinguish between decimal and double
//        if (o instanceof List<Object>) return 'List';
        return 'Object';               // actually we can't detect maps and sets and maps
    }
    
    @AuraEnabled
    public static ErrorWrapper updateDSLs(String dsls, String origdsls, String productcategory) {
        
        System.debug('======= In coming DSLs json :' + dsls);
        System.debug('======= In coming orig DSLs json :' + origdsls);
        
        Map<String, Object> outerMap = (Map<String, Object>) JSON.deserializeUntyped(dsls);
        List<Object> dslList = (List<Object>) outerMap.get('data');
        List<L2I_DSL__c> dslsToUpdate = new List<L2I_DSL__c>();
        
        Map<String, Object> outerOrigMap = (Map<String, Object>) JSON.deserializeUntyped(origdsls);
        List<Object> dslOrigList = (List<Object>) outerOrigMap.get('data');
        
        Map<String, String> validAircraft = new Map<String, String>();
        ErrorWrapper ew = new ErrorWrapper();
        List<ErrorRowWrapper> erwList = new List<ErrorRowWrapper>();
        ErrorTableWrapper etw = new ErrorTableWrapper();
        
        try {
            getValidAircraftFromDSLs(dslList, validAircraft);
            // validate the table by row
            validateByRow(dslList, dslOrigList, productcategory, validAircraft, erwList, etw);
            
            // if no errors - update the DSLs
            if (erwList.size() == 0) {
                // no errors
                for (Object dslRow : dslList) {
                    Map<String, Object> dsMap = (Map<String, Object>) dslRow;
                    
                    if (dsMap.containsKey('dslId')) {
                        SObject aDsl = new L2I_DSL__c();
                        for (String key : dsMap.keySet()) {
                            if (fieldMapping.containsKey(key)) {
                                String fieldName = fieldMapping.get(key).fieldApiName;
                                Object varType = getType(dsMap.get(key));
                                if (fieldName.containsIgnoreCase('_Date_')) {
                                    String fieldValue = (String) dsMap.get(key);
                                    System.debug('*** date fieldValue ' + fieldValue);
                                    System.debug('*** date fieldName ' + fieldName);
                                    Date dateValue;
                                    // out of warranty dates can be blank - this has been validated in validateByRow method
                                    if (String.isBlank(fieldValue)) {
                                        dateValue = null;
                                    } else {
                                        dateValue = Date.valueOf(fieldValue);
                                    }
                                    aDsl.put(fieldName, dateValue);
                                    System.debug('*** aDsl ' + aDsl);
                                } else if (varType == 'Boolean') {
                                    if (fieldName == 'L2I_Aircraft_Confirmation__c') {
                                        Boolean confirmationValue = Boolean.valueOf(dsMap.get(key));
                                        aDsl.put(fieldName, confirmationValue);
                                    }
                                } else {
                                    String fieldValue;
                                    if (fieldName == 'Aircraft__c') {
                                        String fieldNameValue = (String) dsMap.get('aircraftName');
                                        fieldValue = validAirCraft.get(fieldNameValue);
                                        aDsl.put(fieldName, fieldValue);
                                    } else {
                                        fieldValue = (String) dsMap.get(key);
                                        aDsl.put(fieldName, fieldValue);
                                    }
                                }
                            }
                        }
                        dslsToUpdate.add((L2I_DSL__c) aDsl);
                    }
                }
                if (!dslsToUpdate.isEmpty()) {
                    try {
                        System.debug('*** dslsToUpdate ' + dslsToUpdate);
                        update dslsToUpdate;
                    } catch (DmlException dmle) {
                        System.debug('====== DmlException encountered while attempting to save records: ' + dmle);
                        throw new AuraHandledException('There was an error while trying to save the modified record(s): ' + dmle.getMessage());
                    }
                }
            }
            ew.errorRowWrapperList = erwList;
            ew.tableWrap = etw;
            return ew;
        } catch (TypeException te) {
            System.debug('====== Type conversion exception occurred: ' + te);
            throw new AuraHandledException('Encountered invalid data : "' + te.getMessage() + '" Please correct the invalid data and resubmit');
        }
    }
    
    // capture all the aircraft from the DSLs
    private static void getValidAircraftFromDSLs(List<Object> dslList, Map<String, String> validAircraft) {
        // capture the valid aircraft for validation of the datatable
        Set<String> draftAircraft = new Set<String>();
        for (Object dslRow : dslList) {
            Map<String, Object> dsMap = (Map<String, Object>) dslRow;
            if (dsMap.containsKey('dslId')) {
                String ifecDSLId = (String) dsMap.get('ifecDSLId');
                String fieldValue;
                if (!String.isBlank((ifecDSLId))){
                    fieldValue = (String) dsMap.get('ifecDSLAircraftName');
                } else {
                    fieldValue = (String) dsMap.get('aircraftName');
                }
                if (fieldValue != '') {
                    draftAircraft.add(fieldValue);
                }
            }
        }
        for (L2I_Aircraft__c airCraft : [SELECT Id, Name FROM L2I_Aircraft__c WHERE Name IN :draftAircraft]) {
            validAircraft.put(airCraft.Name, airCraft.Id);
        }
        System.debug('*** validAircraft ' + validAircraft);
    }
    
    private static void validateByRow(List<Object> dslList, List<Object> dslOrigList, String productcategory, Map<String, String> validAircraft, List<ErrorRowWrapper> erwList, ErrorTableWrapper etw) {
        System.debug('*** dslList ' + dslList);
        Map<String, Object> origdslMap = new Map<String, Object>();
        for (Object dslRow : dslList) {
            Map<String, Object> dsMap = (Map<String, Object>) dslRow;
            if (dsMap.containsKey('dslId')) {
                Boolean confirmationValue = false;
                String airCraftValue = '';
                String confirmFieldName = '';
                String airCraftFieldName = '';
                Boolean confirmSent = false;
                Boolean airCraftSent = false;
                String dslId = (String) dsMap.get('dslId');
                // load the original values for the row - used for validation
                for (Object obj : dslOrigList) {
                    origdslMap = (Map<String, Object>) obj;
                    if (origdslMap.get('dslId') == dslId) {
                        break;
                    }
                }
                for (String key : dsMap.keySet()) {
                    if (fieldMapping.containsKey(key)) {
                        String fieldAPIName = fieldMapping.get(key).fieldApiName;
                        String fieldName = fieldMapping.get(key).fieldName;
                        String fieldLabel = fieldMapping.get(key).fieldLabel;
                        System.debug('*** fieldname ' + fieldName);
                        System.debug('*** fieldAPIName ' + fieldAPIName);
                        System.debug('*** fieldLabel ' + fieldLabel);
                        Object varType = getType(dsMap.get(key));
                        if (fieldAPIName.containsIgnoreCase('_Date_')) {
                            String fieldVal = (String) dsMap.get(key);
                            System.debug('*** date value ' + fieldVal);
                            System.debug('*** date fieldLabel ' + fieldLabel);
                            Date fieldValue;
                           if (String.isBlank(fieldVal) && !fieldLabel.contains('Out of Warranty')) {
                                setErrorMessage(dslId, fieldLabel + ' cannot be empty', fieldName, erwList, etw);
                            } else {
                                if (String.isBlank(fieldVal) && fieldLabel.contains('Out of Warranty')) {
                                    fieldValue = null;
                                } else {
                                    fieldValue = Date.valueOf(fieldVal);
                                }
                            }
                            System.debug('*** final date fieldvalue ' + fieldValue);
                        } else if (varType == 'Boolean') {
                            if (fieldAPIName == 'L2I_Aircraft_Confirmation__c') {
                                confirmationValue = Boolean.valueOf(dsMap.get(key));
                                confirmFieldName = fieldName;
                                confirmSent = true;
                            }
                        } else {
                            if (fieldAPIName == 'Aircraft__c') {
                                airCraftValue = (String) dsMap.get(fieldName);
                                airCraftFieldName = fieldName;
                                airCraftSent = true;
                            }
                        }
                    }
                }
                System.debug('*** airCraftValue ' + airCraftValue);
                System.debug('*** confirmationValue ' + confirmationValue);
                System.debug('*** airCraftSent ' + airCraftSent);
                System.debug('*** confirmSent ' + confirmSent);
                // validate aircraft values on the row
                if (airCraftSent && !String.isBlank(airCraftValue)) {
                    if (String.isBlank(validAirCraft.get(airCraftValue))) {
                        setErrorMessage(dslId, 'Invalid Aircraft ' + airCraftValue, airCraftFieldName, erwList, etw);
                    }
                }
                
                if (confirmSent && !airCraftSent) {
                    // need to get the original aircraft value
                    System.debug('*** origdslMap ' + origdslMap);
                    System.debug('*** origdslMap.get("ifecDSLId") ' + origdslMap.get('ifecDSLId'));
                    String ifecDSLId = (String) origdslMap.get('ifecDSLId');
                    if (!String.isBlank((ifecDSLId))){
                        airCraftValue = (String) origdslMap.get('ifecDSLAircraftName');
                    } else {
                        airCraftValue = (String) origdslMap.get('aircraftName');
                    }
                } else if (!confirmSent && airCraftSent) {
                    confirmationValue = Boolean.valueOf(origdslMap.get('aircraftConfirmation'));
                }
                System.debug('*** airCraftValue ' + airCraftValue);
                System.debug('*** confirmationValue ' + confirmationValue);
                if (confirmationValue &&
                      String.isBlank(airCraftValue)) {
                    setErrorMessage(dslId, 'Aircraft required with Confirmation', confirmFieldName, erwList, etw);
                }
            }
        }
        System.debug('*** erwList.size() ' + erwList.size());
        System.debug('*** erwList ' + erwList);
    }
    
    private static void setErrorMessage(String keyId, String msg, String fieldName, List<ErrorRowWrapper> erwList, ErrorTableWrapper etw) {
        Boolean foundMatch = false;
        for (ErrorRowWrapper erw : erwList) {
            if (erw.keyId == keyId) {
                foundMatch = true;
                erw.fieldnameList.add(fieldName);
                erw.messageList.add(msg);
                erw.title = 'Errors';
                break;
            }
        }
        if (!foundMatch) {
            ErrorRowWrapper erw = new ErrorRowWrapper();
            erw.keyId = keyId;
            erw.messageList = new List<String>{
                  msg
            };
            erw.fieldNameList = new List<String>{
                  fieldName
            };
            erw.title = 'Errors';
            erwList.add(erw);
        }
        etw.messageList.add(msg);
    }
    
    public class ErrorWrapper {
        @AuraEnabled public List<ErrorRowWrapper> errorRowWrapperList { get; set; }
        @AuraEnabled public ErrorTableWrapper tableWrap { get; set; }
        
        public ErrorWrapper() {
        }
    }
    
    public class ErrorRowWrapper {
        @AuraEnabled public String keyId { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public List<String> messageList { get; set; }
        @AuraEnabled public List<String> fieldNameList { get; set; }
        
        public ErrorRowWrapper() {
        }
    }
    
    public class ErrorTableWrapper {
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public List<String> messageList { get; set; }
        
        public ErrorTableWrapper() {
            title = 'Please review the errors.';
            messageList = new List<String>();
        }
    }
}