/**
 * Utility class for Table Properties metadata type
 *
 * Created: 01.22.2020 : Kevin Antonioli
 */
public without sharing class L2I_TablePropertyUtils {
    public static final String STAR_DELIM = '*';
    private static final String PRICE_STR = 'Price';
    private static final String CHECKBOX_FIELD_TYPE = 'checkbox';
    private static final String CURRENCY_FIELD_TYPE = 'CURRENCY';
    private static final String TRUE_STR = 'true';
    private static final String TABLE_BODY = 'Body';
    private static final String TABLE_HEADER = 'Header';
    private static final String TABLE_COLUMN_NAME_KEY = STAR_DELIM + 'Column_Name';
    private static final String TABLE_STYLES_KEY = STAR_DELIM + 'Styles';
    private static final String TABLE_CLASS_KEY = STAR_DELIM + 'Class';
    private static final String TABLE_LINKIFIED_KEY = STAR_DELIM + 'Linkified';
    private static final String TABLE_RELATED_LOOKUP_KEY = STAR_DELIM + 'Related_Lookup';
    private static final String TABLE_TEXT_ALIGNMENT_KEY = STAR_DELIM + 'Alignment';
    private static final String TABLE_FIELD_PATH_KEY = STAR_DELIM + 'Field_Path';
    private static final String TABLE_FIELD_DEFAULT_VALUE_KEY = STAR_DELIM + 'Default_Value';
    private static final String TABLE_OVERRIDE_FLS_KEY = STAR_DELIM + 'Override_FLS';
    private static final String TABLE_READ_ONLY_KEY = STAR_DELIM + 'Read_Only';
    private static final String TABLE_DISABLED_KEY = STAR_DELIM + 'Disabled';
    private static final String MIN_LENGTH_KEY = STAR_DELIM + 'Min_Length';
    private static final String MIN_NUMBER_KEY = STAR_DELIM + 'Min_Number';
    private static final String REQUIRED_KEY = STAR_DELIM + 'Required';
    private static final String TABLE_STEP_KEY = STAR_DELIM + 'Step';
    private static final String DEFAULT_TABLE_HEAD_STYLES = 'text-align:center;';
    //private static final String DEFAULT_TABLE_BODY_STYLES = 'text-align:right;';    
    
    private static final String PRODUCT2ID_FIELD = 'Product2Id';
    private static final String ORDERITEM_PRODUCT2ID_FIELD_REF = 'PricebookEntry.Product2Id';
    private static final String ORDERITEM_PRODUCTNAME_FIELD_REF = 'PricebookEntry.Product2.Name';
    
    private static final String DEFAULT_STEP = '0.01';
    private static final String BLANK_STRING = '';
    private static final String USD_CURRENCY_SYMBOL = '$';
    private static final String PRICE_ADJUSTMENT_TABLE_TYPE = 'Price Adjustment';
    private static final String ONE_SPACE_OF_INDENTATION = '\u00A0';
    private static final String SLDS_CENTER_CLASS = 'slds-text-align_center';
    
    private static final Map<String, String> fieldTypeToInputType = new Map<String, String>{
        'STRING' => 'text', 'BOOLEAN' => 'checkbox', 'DATE' => 'date', 'DECIMAL' => 'number', 'DOUBLE' => 'number', 'CURRENCY' => 'number', 
        'PERCENT' => 'number'
    };

    private static final Map<String, String> fieldTypeToFormatterType = new Map<String, String>{
        'DECIMAL' => 'decimal', 'DOUBLE' => 'decimal', 'CURRENCY' => 'currency', 'PERCENT' => 'percent'
    };

    /*
     * @description -> inner class to store data cell properties
     */
    public class DataCellPropertyPack {
        @AuraEnabled public Integer index { get; set; }
        @AuraEnabled public String formatter { get; set; }
        @AuraEnabled public String step { get; set; } // for decimal precision on number/decimal/currency attributes
        @AuraEnabled public Decimal min { get; set; } // minimum allowed value for number attributes
        @AuraEnabled public Integer minLength { get; set; } // minimum characters allowed
        @AuraEnabled public Boolean required { get; set; } // minimum characters allowed
        //@AuraEnabled public String msgWhenRangeUnderflow { get; set; }
        @AuraEnabled public String field { get; set; }
        @AuraEnabled public String fieldLabel { get; set; }
        @AuraEnabled public String columnName { get; set; }
        @AuraEnabled public String fieldType { get; set; }
        @AuraEnabled public String gridCellValue { get; set; }
        @AuraEnabled public String cssClass { get; set; }
        @AuraEnabled public String styles { get; set; }
        @AuraEnabled public Boolean linkifyIt { get; set; }
        @AuraEnabled public String relatedLookupId { get; set; }
        @AuraEnabled public String outputLink { get; set; }
        @AuraEnabled public String indentation { get; set; }
        @AuraEnabled public String textAlignment { get; set; }

        @AuraEnabled public Boolean isEditable { get; set; }
        @AuraEnabled public Boolean isDisabled { get; set; }
        @AuraEnabled public Boolean isReadOnly { get; set; }
        @AuraEnabled public Boolean isValid { get; set; }
        @AuraEnabled public String inputType { get; set; }
        @AuraEnabled public Boolean isChecked { get; set; }
    }

    /**
     * @description -> build a map of table properties for table header rows and table body rows.
     * @param String tablePropertyName 
     * @param String rowType
     * @return Map<String, String> masterPropertiesMap
     */ 
    public static Map<String, String> getMasterPropertiesMap(String tablePropertyName, String rowType) {
        System.debug('L2I_TablePropertyUtils.getMasterPropertiesMap: ' + tablePropertyName);
        List<L2I_Table_Properties__mdt> tableProperties = [
            SELECT Id, L2I_Field_API_Name__c, L2I_Style__c, L2I_CSS_Class__c, L2I_Linkified__c, L2I_Related_Lookup_Field__c, L2I_Column_Name__c, L2I_Min_Number__c,
            L2I_Field_Path__c, L2I_Override_FLS__c, L2I_Read_Only__c, L2I_Text_Alignment__c, L2I_Step__c, L2I_Disabled__c, L2I_Min_Length__c, L2I_Default_Value__c,
            L2I_Required__c
            FROM L2I_Table_Properties__mdt 
            WHERE L2I_Table_Name__c != null AND L2I_Table_Name__c = :tablePropertyName AND L2I_Row_Type__c = :rowType
        ];

        if(Test.isRunningTest()) {
            tableProperties.add(new L2I_Table_Properties__mdt(
                L2I_Field_API_Name__c = 'Product2Id',
                L2I_Related_Lookup_Field__c = 'PricebookEntry.Product2Id',
                L2I_Linkified__c = true,
                L2I_Read_Only__c = true,
                L2I_Override_FLS__c = true
            ));
        }

        Map<String, String> masterPropertiesMap = new Map<String, String>();
        for(L2I_Table_Properties__mdt tp : tableProperties) {
            masterPropertiesMap.put(tp.L2I_Field_API_Name__c, tp.L2I_Field_API_Name__c);
            masterPropertiesMap.put(tp.L2I_Field_API_Name__c + TABLE_FIELD_DEFAULT_VALUE_KEY, String.valueOf(tp.L2I_Default_Value__c));

            if(tp.L2I_Step__c != null) {
                masterPropertiesMap.put(tp.L2I_Field_API_Name__c + TABLE_STEP_KEY, String.valueOf(tp.L2I_Step__c));
            }
            if(tp.L2I_Disabled__c) {
                masterPropertiesMap.put(tp.L2I_Field_API_Name__c + TABLE_DISABLED_KEY, String.valueOf(tp.L2I_Disabled__c));
            }
            if(tp.L2I_Min_Length__c != null) {
                masterPropertiesMap.put(tp.L2I_Field_API_Name__c + MIN_LENGTH_KEY, String.valueOf(tp.L2I_Min_Length__c));
            }
            if(tp.L2I_Min_Number__c != null) {
                masterPropertiesMap.put(tp.L2I_Field_API_Name__c + MIN_NUMBER_KEY, String.valueOf(tp.L2I_Min_Number__c));
            }
            if(tp.L2I_Required__c != null) {
                masterPropertiesMap.put(tp.L2I_Field_API_Name__c + REQUIRED_KEY, String.valueOf(tp.L2I_Required__c));
            }
            
            masterPropertiesMap.put(tp.L2I_Field_API_Name__c + TABLE_COLUMN_NAME_KEY, tp.L2I_Column_Name__c);
            if(tp.L2I_Style__c != null) {
                masterPropertiesMap.put(tp.L2I_Field_API_Name__c + TABLE_STYLES_KEY, tp.L2I_Style__c);
            } else if(rowType == TABLE_HEADER) {
                masterPropertiesMap.put(tp.L2I_Field_API_Name__c + TABLE_STYLES_KEY, DEFAULT_TABLE_HEAD_STYLES);
            } //else if(rowType == TABLE_BODY) {
                //masterPropertiesMap.put(tp.L2I_Field_API_Name__c + TABLE_STYLES_KEY, DEFAULT_TABLE_BODY_STYLES);
            //}

            masterPropertiesMap.put(tp.L2I_Field_API_Name__c + TABLE_CLASS_KEY, tp.L2I_CSS_Class__c);
            if(tp.L2I_Linkified__c) {
                masterPropertiesMap.put(tp.L2I_Field_API_Name__c + TABLE_LINKIFIED_KEY, String.valueOf(tp.L2I_Linkified__c));
            }
            masterPropertiesMap.put(tp.L2I_Field_API_Name__c + TABLE_RELATED_LOOKUP_KEY, tp.L2I_Related_Lookup_Field__c);
            masterPropertiesMap.put(tp.L2I_Field_API_Name__c + TABLE_FIELD_PATH_KEY, tp.L2I_Field_Path__c);
            if(tp.L2I_Override_FLS__c) {
                masterPropertiesMap.put(tp.L2I_Field_API_Name__c + TABLE_OVERRIDE_FLS_KEY, String.valueOf(tp.L2I_Override_FLS__c));
            }
            if(tp.L2I_Read_Only__c) {
                masterPropertiesMap.put(tp.L2I_Field_API_Name__c + TABLE_READ_ONLY_KEY, String.valueOf(tp.L2I_Read_Only__c));
            }
            
            if(tp.L2I_Text_Alignment__c != null) {
                masterPropertiesMap.put(tp.L2I_Field_API_Name__c + TABLE_TEXT_ALIGNMENT_KEY, tp.L2I_Text_Alignment__c);
            }
        }
        return masterPropertiesMap;
    }

     /**
     * @description -> method to build the data cell properties for the cells that make up the column headers
     * @param String tableType -> the type of table in which to build a header cell property pack for. Ex: 'Price Adjustment'
     * @param FieldSetMemberWrapper fieldSetMemberWrapper -> wrapper class that contains fieldPath, fieldLabel, and fieldType..
     * @return DataCellPropertyPack dcpp -> a custom object of data cell properties (grid value, styles, etc.)
     */ 
    public static DataCellPropertyPack buildHeaderDataCellPropertyPack(
        Map<String, String> masterPropertiesMap, FieldSetMemberWrapper fieldSetMemberWrapper, Integer index
    ) {
        System.debug(LoggingLevel.FINE, 'L2I_TablePropertyUtils.buildHeaderDataCellPropertyPack fieldSetMemberWrapper: ' + fieldSetMemberWrapper);
        DataCellPropertyPack dcpp = new DataCellPropertyPack();
        dcpp.index = index;
        dcpp.field = fieldSetMemberWrapper.fieldPath;
        dcpp.fieldLabel = fieldSetMemberWrapper.fieldLabel;
        dcpp.columnName = masterPropertiesMap.get(dcpp.field + TABLE_COLUMN_NAME_KEY) == null 
            ? dcpp.fieldLabel : masterPropertiesMap.get(dcpp.field + TABLE_COLUMN_NAME_KEY);
        dcpp.fieldType = fieldSetMemberWrapper.fieldType;
        dcpp.cssClass = masterPropertiesMap.containsKey(dcpp.field + TABLE_CLASS_KEY) 
            ? masterPropertiesMap.get(dcpp.field + TABLE_CLASS_KEY) : SLDS_CENTER_CLASS;
        dcpp.styles = masterPropertiesMap.get(dcpp.field + TABLE_STYLES_KEY);

        return dcpp;
    }

    /**
     * @description -> method to build the data cell properties for the cells within a particular row.
     * @param String masterPropertiesMap -> the table properties map
     * @param FieldSetMemberWrapper fieldSetMemberWrapper -> wrapper class that contains fieldPath, fieldLabel, and fieldType..
     * @param SObject line -> an SObject record representing a line (ex: SBQQ__QuoteLine__c, OrderItem, etc)
     * @param SObject Tier -> the tier of a record (ex: for CPQ, there can be multiple tiers in regards to quote lines, contract lines, and order lines)
     * @param Map<String, Schema.SObjectField> rowObjFieldsMap -> a Schema.SObjectField map for the row records. This map is used to determine things like editability
     * @return DataCellPropertyPack dcpp -> a custom object of data cell properties (grid value, styles, etc.)
     */ 
    public static DataCellPropertyPack buildBodyDataCellPropertyPack(
        Map<String, String> masterPropertiesMap, FieldSetMemberWrapper fieldSetMemberWrapper, SObject line, Integer tier, 
        Map<String, Schema.SObjectField> rowObjFieldsMap, Integer dcppIndex, Integer rowIndex
    ) {
        String objType = String.valueOf(line.getSobjectType());
        DataCellPropertyPack dcpp = new DataCellPropertyPack();
        dcpp.index = dcppIndex;
        dcpp.field = fieldSetMemberWrapper.fieldPath;
        dcpp.fieldLabel = fieldSetMemberWrapper.fieldLabel;
        dcpp.fieldType = fieldSetMemberWrapper.fieldType;
        dcpp.inputType = fieldTypeToInputType.get(dcpp.fieldType) == null ? L2I_Constants.INPUT_TYPE_TEXT : fieldTypeToInputType.get(dcpp.fieldType);
        dcpp.formatter = fieldTypeToFormatterType.get(dcpp.fieldType) == null ? null : fieldTypeToFormatterType.get(dcpp.fieldType);
        dcpp.step = masterPropertiesMap.get(dcpp.field + TABLE_STEP_KEY) == null ? DEFAULT_STEP : masterPropertiesMap.get(dcpp.field + TABLE_STEP_KEY);
        dcpp.isValid = true;

        Schema.DescribeFieldResult dfr = rowObjFieldsMap.get(dcpp.field).getDescribe();
        dcpp.isReadOnly = masterPropertiesMap.containsKey(dcpp.field + TABLE_READ_ONLY_KEY) 
            ? true : false;

        dcpp.isReadOnly = (dfr.isAutoNumber() || dfr.isCalculated()) ? true : dcpp.isReadOnly; // autonumber and formulas are always read only
        dcpp.isEditable = (!dfr.isAutoNumber() && !dfr.isCalculated()) ? true : false; // baseline editability (exclude formulas and auto numbers)
        if(dcpp.isEditable) {
            dcpp.isEditable = !dfr.isUpdateable() ? false : dcpp.IsEditable; // editability based on FLS
            dcpp.isEditable = masterPropertiesMap.containsKey(dcpp.field + TABLE_OVERRIDE_FLS_KEY) 
                ? true : dcpp.isEditable; // override FLS and make editable, if Override FLS is checked on the table property record
        }
        // if dcpp is not editable by now, make sure read only is true:
        dcpp.isReadOnly = !dcpp.isEditable ? true : dcpp.isReadOnly;
        dcpp.isDisabled = masterPropertiesMap.get(dcpp.field + TABLE_DISABLED_KEY) != null 
            ? Boolean.valueOf(masterPropertiesMap.get(dcpp.field + TABLE_DISABLED_KEY)) : !dcpp.isEditable;

        dcpp.indentation = BLANK_STRING; // indent the lines based on their tier number (just like the QLE does it)
        if(dcpp.field == PRODUCT2ID_FIELD) {
            for(Integer i = 1; i < tier; i++) {
                dcpp.indentation += ONE_SPACE_OF_INDENTATION + ONE_SPACE_OF_INDENTATION + ONE_SPACE_OF_INDENTATION; // non breaking spaces;
            }
        }

        String fieldPath = masterPropertiesMap.get(dcpp.field + TABLE_FIELD_PATH_KEY) == null 
            ? dcpp.Field : masterPropertiesMap.get(dcpp.field + TABLE_FIELD_PATH_KEY);

        if(objType == L2I_Constants.ORDERITEM_OBJ_NAME && fieldPath == PRODUCT2ID_FIELD) {
            fieldPath = ORDERITEM_PRODUCTNAME_FIELD_REF;
        }

        dcpp.gridCellValue = String.valueOf(L2I_ApexUtils.parseFieldPathForSObject(line, fieldPath));
        if(dcpp.gridCellValue == null) {
            dcpp.gridCellValue = masterPropertiesMap.get(dcpp.field + TABLE_FIELD_DEFAULT_VALUE_KEY);
        }
        if(dcpp.inputType == CHECKBOX_FIELD_TYPE) {
            dcpp.isChecked = dcpp.gridCellValue == TRUE_STR ? true : false;
        }

        // Panasonic specific: enforce a minimum value within the Average GB Per Tail Upper Bound column:
        if(dcpp.field == L2I_Constants.CM_UPPER_BOUND_FIELD) {
            dcpp.min = (rowIndex + 1) * 2;
        }

        dcpp.min = masterPropertiesMap.get(dcpp.field + MIN_NUMBER_KEY) != null 
            ? Decimal.valueOf(masterPropertiesMap.get(dcpp.field + MIN_NUMBER_KEY)) : dcpp.min;
        dcpp.minLength = masterPropertiesMap.get(dcpp.field + MIN_LENGTH_KEY) != null 
            ? Integer.valueOf(masterPropertiesMap.get(dcpp.field + MIN_LENGTH_KEY)) : dcpp.minLength;
        dcpp.required = masterPropertiesMap.get(dcpp.field + REQUIRED_KEY) != null 
            ? Boolean.valueOf(masterPropertiesMap.get(dcpp.field + REQUIRED_KEY)) : dcpp.required;
        
        dcpp.linkifyIt = masterPropertiesMap.containsKey(dcpp.field + TABLE_LINKIFIED_KEY) ? true : false;
        String lookupFieldRef = masterPropertiesMap.get(dcpp.field + TABLE_RELATED_LOOKUP_KEY);
        dcpp.relatedLookupId = lookupFieldRef == null ? null : String.valueOf(L2I_ApexUtils.parseFieldPathForSObject(line, lookupFieldRef));
        dcpp.outputLink = dcpp.relatedLookupId == null ? null : '/' + dcpp.relatedLookupId;
        dcpp.cssClass = masterPropertiesMap.get(dcpp.field + TABLE_CLASS_KEY);
        dcpp.styles = masterPropertiesMap.get(dcpp.field + TABLE_STYLES_KEY);
        dcpp.textAlignment = masterPropertiesMap.get(dcpp.field + TABLE_TEXT_ALIGNMENT_KEY);

        return dcpp;
    }

    /**
     * @description -> generic field set member wrapper
     * @param -> Schema.FieldSetMember fieldSetMemberObj->
     * @param -> Schema.DescribeFieldResult describeFieldResult ->
     */
    public class FieldSetMemberWrapper {
        @AuraEnabled public String fieldPath;
        @AuraEnabled public String fieldLabel;
        @AuraEnabled public String fieldType;

        public FieldSetMemberWrapper(Schema.FieldSetMember fieldSetMemberObj) {
            this.fieldPath = String.valueOf(fieldSetMemberObj.getFieldPath());
            this.fieldLabel = String.valueOf(fieldSetMemberObj.getLabel());
            this.fieldType = String.valueOf(fieldSetMemberObj.getType());
        }

        public FieldSetMemberWrapper(Schema.DescribeFieldResult describeFieldResult) {
            this.fieldPath = String.valueOf(describeFieldResult.getSobjectField());
            this.fieldLabel = String.valueOf(describeFieldResult.getLabel());
            this.fieldType = this.fieldLabel.contains(PRICE_STR) ? CURRENCY_FIELD_TYPE : String.valueOf(describeFieldResult.getType());
        }
    }
}