/**
 * @Title: LWC_ListController
 * @description => Apex Controller for the LWC Advanced Related List
 *
 * Created by : Kevin Antonioli : 03.11.2020
 * Sarah Kennedy 8/9/2020 Checking for additionalFieldsToQuery != null in getFieldsToQuery
 */
public without sharing class L2I_LwcListController {
    private static final Map<String, Schema.SObjectField> fieldMap = L2I_ApexUtils.globalDescribe.get(L2I_Constants.CUSTOM_MODEL_OBJ_NAME).getDescribe().Fields.getMap();

    private static final String CPQ_LINE_SOURCE_NAME = 'CPQ Line';
    private static final String CPQ_QUOTE_API_NAME = 'SBQQ__Quote__c';
    private static final String CPQ_QUOTELINE_API_NAME = 'SBQQ__QuoteLine__c';
    private static final String CPQ_ORDERITEM_API_NAME = 'OrderItem';
    private static final String CPQ_ASSET_API_NAME = 'Asset';
    private static final String CPQ_SUBSCRIPTION_API_NAME = 'SBQQ__Subscription__c';
    private static final String ID_STR = 'Id';

    // Supports up to a 5 tier bundle structure. You want it to support more? Just add TIER_6_Line_PATH, TIER_7, etc.
    private static final String TIER_5_LINE_PATH = 'SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c';
    private static final String TIER_4_LINE_PATH = 'SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c';
    private static final String TIER_3_LINE_PATH = 'SBQQ__RequiredBy__r.SBQQ__RequiredBy__c';
    private static final String TIER_2_LINE_PATH = 'SBQQ__RequiredBy__c';
    private static final String CPQ_ROOTID_FIELD = 'SBQQ__RootId__c';

    /**
     * @Description -> method to get the environment name of the org. 
     *   Example: januarytwenty-dev-ed
     * @param null
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static String getEnvironmentName() {
        return L2I_ApexUtils.getEnvironmentName().replace('--c', '');
    }

    /**
     * @Description -> method to get column header properties for the list of child records.
     * @param String childObjName -> the API name of the child object (Ex: SBQQ__QuoteLine__c, Asset, SBQQ__Subscription__c, OrderItem, etc)
     * @param String childObjFieldSetName => the API name of the child object field set
     * @return List<L2I_TablePropertyUtils.DataCellPropertyPack> -> a list of properties (stored in object variables) for the column headers
     */
    @AuraEnabled(cacheable=true)
    public static List<L2I_TablePropertyUtils.DataCellPropertyPack> getColumnHeaderProperties(String configValues) {
        System.debug('LWC_ListController.getColumnHeaderProperties() configValues: ' + configValues);
        List<L2I_TablePropertyUtils.DataCellPropertyPack> dataCellPropertyPacks = new List<L2I_TablePropertyUtils.DataCellPropertyPack>();
        try{
            List < String > strList = configValues.split( ',' );  
            String childObjName = strList.get( 4 );
            String childObjFieldSetName = strList.get ( 5 );
            String tablePropertiesName = strList.get( 8 );
            String customModel = strList.get( 11 );

            List<L2I_TablePropertyUtils.FieldSetMemberWrapper> fieldSetMemberWrappers = new List<L2I_TablePropertyUtils.FieldSetMemberWrapper>();
            Map<String, String> masterPropertiesMap = L2I_TablePropertyUtils.getMasterPropertiesMap(tablePropertiesName, L2I_Constants.TABLE_HEADER);

            if(customModel != null && customModel != L2I_Constants.UNDEFINED_STR) {
                L2I_Custom_Model__mdt customModelMdt = [SELECT Id, L2I_Column_API_Names__c FROM L2I_Custom_Model__mdt WHERE DeveloperName = :customModel];
                List<String> columnAPINames = customModelMdt.L2I_Column_API_Names__c.split(',');
                for(String columnAPIName : columnAPINames) {
                    Schema.SObjectField sObjField = fieldMap.get(columnAPIName.toLowerCase());
                    Schema.DescribeFieldResult dfr = sObjField.getDescribe();
                    fieldSetMemberWrappers.add(new L2I_TablePropertyUtils.FieldSetMemberWrapper(dfr));
                }
            } else {
                List<Schema.FieldSetMember> fieldSetMemberList = L2I_ApexUtils.readFieldSet(childObjFieldSetName, childObjName);
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                    fieldSetMemberWrappers.add(new L2I_TablePropertyUtils.FieldSetMemberWrapper(fieldSetMemberObj));
                }
            }

            for(L2I_TablePropertyUtils.FieldSetMemberWrapper fieldSetMemberWrapper : fieldSetMemberWrappers) {
                Integer index = fieldSetMemberWrappers.indexOf(fieldSetMemberWrapper);
                L2I_TablePropertyUtils.DataCellPropertyPack dcpp = L2I_TablePropertyUtils.buildHeaderDataCellPropertyPack(
                    masterPropertiesMap, fieldSetMemberWrapper, index
                );

                dataCellPropertyPacks.add(dcpp);
            }
        } catch(Exception e) {
            String exceptionMessage = 'LWC_ListController.getColumnHeaderProperties() exception: ' + e.getMessage() + ' Stack trace: ' + e.getStackTraceString();
            System.debug(exceptionMessage);
            throw new AuraHandledException(exceptionMessage);
        }

        return dataCellPropertyPacks;
    }

    /**
     * @Description -> method to get the main record (ex: Quote, Order, Contract etc)
     * @param String configValues -> a list of config params passed from the Lightning Web Component
     * @return SObject -> the main record queried
     */
    @AuraEnabled(cacheable=true)
    public static TopRecordWrapper getTopRecordWrapper(String configValues) {
        System.debug('LWC_ListController.getTopRecordWrapper() configValues: ' + configValues);
        TopRecordWrapper trw = new TopRecordWrapper();

        String strSOQL;
        try {
            List < String > strList = configValues.split( ',' );  
            Id recordId = strList.get( 0 );
            String parentObjName = strList.get( 2 );
            String parentObjFieldSetName = strList.get( 3 );
            String additionalFieldsToQuery = strList.get( 13 );
            if(additionalFieldsToQuery == null || additionalFieldsToQuery == 'undefined') {
                additionalFieldsToQuery = '';
            } else {
                additionalFieldsToQuery = ',' + additionalFieldsToQuery;
            }

            // if the user elected to display the component on an alternate object layout:
            recordId = potentiallyReassignRecordId(recordId, strList);
            
            List<L2I_TablePropertyUtils.FieldSetMemberWrapper> fieldSetMemberWrappers = new List<L2I_TablePropertyUtils.FieldSetMemberWrapper>();
            List<Schema.FieldSetMember> fieldSetMemberList = (parentObjFieldSetName != null && parentObjFieldSetName != L2I_Constants.UNDEFINED_STR) 
                ? L2I_ApexUtils.readFieldSet(parentObjFieldSetName, parentObjName) : null;

            if(fieldSetMemberList != null) {
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                    fieldSetMemberWrappers.add(new L2I_TablePropertyUtils.FieldSetMemberWrapper(fieldSetMemberObj));
                }
                List<String> fieldsToQuery = getFieldsToQuery(fieldSetMemberWrappers, null, null);
                strSOQL = 'SELECT ' + String.join(fieldsToQuery, ','); 
                strSOQL += ' FROM ' + parentObjName + ' WHERE Id = :recordId';
            } else {
                strSOQL = 'SELECT Id ' + additionalFieldsToQuery + ' FROM ' + parentObjName + ' WHERE Id = :recordId';
            }
            trw.topRecord = Database.query(strSOQL);
            return trw;
        } catch(Exception e) {
            String exceptionMessage = 'LWC_ListController.getTopRecordWrapper() exception: ' + e.getMessage() + ' Stack trace: ' + e.getStackTraceString();
            System.debug(exceptionMessage);
            throw new AuraHandledException(exceptionMessage);
        }
    }

    /**
     * @description -> inner class to store data structure for root level (ultimate bundle level) order items
     */
    public class TopRecordWrapper {
        @AuraEnabled public SObject topRecord;
        @AuraEnabled public String quoteModel;
        //@AuraEnabled public CPQ_ApiDataModels.QuoteModel quoteModel;
    }

    /**
     * @Description -> TODO: fill out javadoc
     * @param 
     * @return
     */
    public static Id potentiallyReassignRecordId(Id recordId, List<String> strList) {
        if(strList.get( 9 ) != L2I_Constants.UNDEFINED_STR && strList.get( 10 ) != L2I_Constants.UNDEFINED_STR ) {
            String altRecordIdSourceField = strList.get( 9 );
            String altParentObjName = strList.get( 10 ); // TODO
            SObject parentObjRecord = Database.query(
                'SELECT ' + altRecordIdSourceField + ' FROM ' + altParentObjName + ' WHERE Id = :recordId' 
            );
            recordId = (Id) parentObjRecord.get(altRecordIdSourceField);
        }
        return recordId;
    }

    /**
     * @Description -> method to get the child records for the main (parent) record
     * @param String configValues -> a list of config params passed from the Lightning Web Component
     * @return List<Row> rowList -> the child records row data structure
     */
    @AuraEnabled(cacheable=true)
    public static List<Row> getRows(String configValues) {
        System.debug('LWC_ListController.getRows() configValues: ' + configValues);
        List<Row> rowList = new List<Row>();
        try {
            List < String > strList = configValues.split( ',' );  
            String recordId = strList.get( 0 );
            String childRecordSource = strList.get ( 1 );
            String parentObjName = strList.get( 2 );
            String parentObjFieldSetName = strList.get( 3 );
            String childObjName = strList.get( 4 );
            String childObjFieldSetName = strList.get ( 5 );
            String parentRelationshipName = strList.get ( 6 );
            String childRecordsOrderBy = strList.get( 7 );
            String tablePropertiesName = strList.get( 8 );
            String customModel = strList.get( 11 );
            String productId = strList.get( 12 );

            // if the user elected to display the component on an alternate object layout:
            recordId = potentiallyReassignRecordId(recordId, strList);
            Set<String> additionalFieldsToQuerySet = new Set<String>();

            Map<String, String> masterPropertiesMap = L2I_TablePropertyUtils.getMasterPropertiesMap(tablePropertiesName, L2I_Constants.TABLE_BODY);
            for(String key : (masterPropertiesMap.keyset())) {
                if(!key.contains(L2I_TablePropertyUtils.STAR_DELIM)) {
                    additionalFieldsToQuerySet.add(key);
                }
            }

            String objNameToParse = (customModel == null || customModel == L2I_Constants.UNDEFINED_STR) ? childObjName : L2I_Constants.CUSTOM_MODEL_OBJ_NAME;
            SObjectType rowObjType = L2I_ApexUtils.globalDescribe.get(objNameToParse);
            Map<String, Schema.SObjectField> rowObjFieldsMap = rowObjType.getDescribe().fields.getMap();

            List<SObject> recordsList;
            List<L2I_TablePropertyUtils.FieldSetMemberWrapper> fieldSetMemberWrappers = new List<L2I_TablePropertyUtils.FieldSetMemberWrapper>();
            if(customModel == null || customModel == L2I_Constants.UNDEFINED_STR) {
                List<Schema.FieldSetMember> fieldSetMemberList = L2I_ApexUtils.readFieldSet(childObjFieldSetName, childObjName);
                masterPropertiesMap = L2I_TablePropertyUtils.getMasterPropertiesMap(tablePropertiesName, L2I_Constants.TABLE_HEADER);

                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                    fieldSetMemberWrappers.add(new L2I_TablePropertyUtils.FieldSetMemberWrapper(fieldSetMemberObj));
                }

                // derive from field set:
                List<String> fieldsToQuery = getFieldsToQuery(fieldSetMemberWrappers, additionalFieldsToQuerySet, childObjName);
                String strSOQL = buildChildSOQLString(childObjName, parentRelationshipName, fieldsToquery, recordId, childRecordsOrderBy);            
                recordsList = Database.query(strSOQL);
            } else {
                // derive from custom metadata model:
                L2I_Custom_Model__mdt customModelMdt = [SELECT Id, L2I_Column_API_Names__c, L2I_JSON_Field_API_Name__c FROM L2I_Custom_Model__mdt WHERE DeveloperName = :customModel];
                List<String> columnAPINames = customModelMdt.L2I_Column_API_Names__c.split(',');
                for(String columnAPIName : columnAPINames) {
                    Schema.SObjectField sObjField = fieldMap.get(columnAPIName.toLowerCase());
                    Schema.DescribeFieldResult dfr = sObjField.getDescribe();
                    fieldSetMemberWrappers.add(new L2I_TablePropertyUtils.FieldSetMemberWrapper(dfr));
                }

                List<SObject> parentObj = Database.query('SELECT ' + customModelMdt.L2I_JSON_Field_API_Name__c + ' FROM ' + parentObjName + ' WHERE Id = :recordId LIMIT 1');
                if(!parentObj.isEmpty()) { 
                    SObjectType mdtType = L2I_ApexUtils.globalDescribe.get(L2I_Constants.CUSTOM_MODEL_OBJ_NAME);
                    Schema.DescribeSObjectResult mdtDesc = mdtType.getDescribe();
                    String keyPrefix = mdtDesc.getKeyPrefix();

                    String childJSON = (String) parentObj[0].get(customModelMdt.L2I_JSON_Field_API_Name__c);
                    if(childJSON == null) {
                        recordsList = new List<SObject>();
                        SObject placeHolderObj = mdtType.newSObject();
                        placeHolderObj.Id = L2I_ApexUtils.create18CharFakeId(keyPrefix);
                        placeHolderObj.put(L2I_Constants.CUSTOM_MODEL_PARENT_FIELD, recordId);
                        placeHolderObj.put(L2I_Constants.CM_LOWER_BOUND_FIELD, 1); // Panasonic Specificz
                        placeHolderObj.put(L2I_Constants.CM_PRODUCT_ID_FIELD, productId); 
                        recordsList.add(placeHolderObj);
                    } else {
                        recordsList = (List<SObject>) JSON.deserialize(childJSON, List<SObject>.class); 
                    }
                } 
            }
            
            Integer rowIndex = 0;
            for(SObject record : recordsList) {
                Row row = new Row(
                    masterPropertiesMap, record, fieldSetMemberWrappers, childRecordSource, childObjName, rowObjFieldsMap, rowIndex, recordsList.size()
                );
                row.idxAfterFiltering = rowIndex;
                rowList.add(row);
                rowIndex += 1;
            }
        } catch(Exception e) {
            String exceptionMessage = 'LWC_ListController.getRecordList() exception: ' + e.getMessage() + ' Stack trace: ' + e.getStackTraceString();
            System.debug(exceptionMessage);
            throw new AuraHandledException(exceptionMessage);
        }

        return rowList;
    }

    /**
     * @Description -> method to build a string list of fields read in from the field set
     * @param List<Schema.FieldSetMember> fieldSetMemberList -> the read field set
     * @return List<String> fieldsToQuery -> a string list of fields read in from the field set
     */
    private static List<String> getFieldsToQuery(
        List<L2I_TablePropertyUtils.FieldSetMemberWrapper> fieldSetMemberWrappers, Set<String> additionalFieldsToQuery, String childObjName
    ) {
        System.debug('LWC_ListController.getFieldsToQuery() fieldSetMemberWrappers: ' + fieldSetMemberWrappers);
        System.debug('LWC_ListController.getFieldsToQuery() additionalFieldsToQuery: ' + additionalFieldsToQuery);
        Set<String> fieldsToQuerySet = new Set<String>();
        // get fields from the field set:
        for(L2I_TablePropertyUtils.FieldSetMemberWrapper fieldSetMemberWrapper : fieldSetMemberWrappers) {
            String fieldAPIPath = fieldSetMemberWrapper.fieldPath;
            // Product and Product Name are gathered for order item via traversing through the PricebookEntry relationship,
            //  so accomodate for that here:
            if(fieldAPIPath == L2I_Constants.PRODUCT2ID_FIELD) {
                fieldAPIPath = L2I_Constants.ORDERITEM_PRODUCTNAME_FIELD_REF;
            }
            fieldsToQuerySet.add(fieldAPIPath);
        }
        
        if (additionalFieldsToQuery != null) {
            additionalFieldsToQuery.add(ID_STR);
            if (childObjName == CPQ_QUOTELINE_API_NAME || childObjName == CPQ_ORDERITEM_API_NAME) {
                additionalFieldsToQuery.add(TIER_5_LINE_PATH);
                additionalFieldsToQuery.add(TIER_4_LINE_PATH);
                additionalFieldsToQuery.add(TIER_3_LINE_PATH);
                additionalFieldsToQuery.add(TIER_2_LINE_PATH);
            }
    
            fieldsToQuerySet.addAll(additionalFieldsToQuery);
        }
        return new List<String>(fieldsToQuerySet);
    }

    /**
     * @Description -> 
     * @param String childObjName -> the API name of the child object (Ex: SBQQ__QuoteLine__c)
     * @param String parentRelaionshipName -> the API name of the parent relationship for the child object (ex: SBQQ__Quote__c)
     * @param String fieldsToQuery -> the fields to query from the child object
     * @param String recordId -> the record Id of the parent
     * @param String childRecordsOrderBy -> how to order the child objects (ex: SBQQ__Number__c)
     * @return String strSOQL -> the SOQL query string for the child object
     */
    private static String buildChildSOQLString(
        String childObjName, String parentRelationshipName, List<String> fieldsToQuery, String recordId, String childRecordsOrderBy
    ) {
        String strSOQL = 'SELECT ' + String.join(fieldsToQuery, ',');
        strSOQL += ' FROM ' + childObjName + ' WHERE ' + parentRelationshipName + ' = :recordId'; 

        if ( childRecordsOrderBy != null && childRecordsOrderBy != '' && childRecordsOrderBy != L2I_Constants.UNDEFINED_STR) {
            strSOQL += ' ORDER BY ' + childRecordsOrderBy;
        }

        strSOQL += ' LIMIT 50000';

        return strSOQL;
    }          

    /**
     * @description -> inner class to store data structure for root level (ultimate bundle level) order items
     */
    public class Row{
        //@AuraEnabled public Row originalRow;
        @AuraEnabled public Integer index;
        @AuraEnabled public Boolean isNewRow = false;
        @AuraEnabled public Boolean flagForDelete = false;
        @AuraEnabled public Integer idxAfterFiltering;
        @AuraEnabled public Boolean isHiddenByFilter = false;
        @AuraEnabled public SObject originalRecord;
        @AuraEnabled public SObject record;
        @AuraEnabled public Integer tier;
        @AuraEnabled public Boolean isUltimateParent;
        @AuraEnabled public Boolean isVisible;
        @AuraEnabled public Boolean isEditable;
        @AuraEnabled public String sourceOfChange;
        @AuraEnabled public String rootId;
        @AuraEnabled public String indentation;
        @AuraEnabled public Boolean expandCollapseCheckboxChecked = false;
        @AuraEnabled public Boolean isDirty = false;
        @AuraEnabled public List<L2I_TablePropertyUtils.DataCellPropertyPack> dataCellPropertyPacks;
        @AuraEnabled public Integer fieldSetSize;
        @AuraEnabled public Map<String, String> fieldToCssClassMap = new Map<String, String>();

        public Row(
            Map<String, String> masterPropertiesMap, SObject record, List<L2I_TablePropertyUtils.FieldSetMemberWrapper> fieldSetMemberWrappers, 
            String childRecordSource, String childObjName, Map<String, Schema.SObjectField> rowObjFieldsMap, Integer rowIndex, Integer recordsSize
        ) {
            this.index = rowIndex;
            this.originalRecord = record;
            this.record = record;
            Id childRecordId = (Id) record.get(ID_STR);
            
            // if child record source is an Asset, Subscription, Quote Line, or Order Product
            if(childRecordSource == CPQ_LINE_SOURCE_NAME) {
                // Asset and Subscription lines:
                if(childObjName == CPQ_ASSET_API_NAME || childObjName == CPQ_SUBSCRIPTION_API_NAME) {
                    this.rootId = record.get(CPQ_ROOTID_FIELD) == null ? null : (Id) record.get(CPQ_ROOTID_FIELD);
                }
                
                // Quote Lines and Order Products (they don't have an SBQQ__RootId__c field):
                if(this.rootId == null) {
                    // supports up to a 5 tier bundle structure:
                    if(L2I_ApexUtils.parseFieldPathForSObject(record, TIER_5_LINE_PATH) != null) {
                        // tier 5 lines
                        this.rootId = (Id) L2I_ApexUtils.parseFieldPathForSObject(record, TIER_5_LINE_PATH);
                        this.tier = 5;
                    } else if(L2I_ApexUtils.parseFieldPathForSObject(record, TIER_4_LINE_PATH) != null) {
                        // tier 4 lines
                        this.rootId = (Id) L2I_ApexUtils.parseFieldPathForSObject(record, TIER_4_LINE_PATH);
                        this.tier = 4;
                    } else if(L2I_ApexUtils.parseFieldPathForSObject(record, TIER_3_LINE_PATH) != null) {
                        // tier 3 lines:
                        this.rootId = (Id) L2I_ApexUtils.parseFieldPathForSObject(record, TIER_3_LINE_PATH);
                        this.tier = 3;
                    } else if(L2I_ApexUtils.parseFieldPathForSObject(record, TIER_2_LINE_PATH) != null) {
                        // tier 2 lines:
                        this.rootId = (Id) L2I_ApexUtils.parseFieldPathForSObject(record, TIER_2_LINE_PATH);
                        this.tier = 2;
                    } else {
                        this.rootId = childRecordId;
                        this.tier = 1;
                    }
                }
            } else {
                this.rootId = childRecordId;
                this.tier = 1;
            }
            
            this.isVisible = tier == 1 ? true : false;
            this.isUltimateParent = tier == 1 ? true : false;
            this.dataCellPropertyPacks = new List<L2I_TablePropertyUtils.DataCellPropertyPack>();
            Integer finalIndex = recordsSize - 1;
            for(L2I_TablePropertyUtils.FieldSetMemberWrapper fieldSetMemberWrapper : fieldSetMemberWrappers) {
                Integer dcppIndex = fieldSetMemberWrappers.indexOf(fieldSetMemberWrapper);
                L2I_TablePropertyUtils.DataCellPropertyPack dcpp = L2I_TablePropertyUtils.buildBodyDataCellPropertyPack(
                    masterPropertiesMap, fieldSetMemberWrapper, this.record, this.tier, rowObjFieldsMap, dcppIndex, rowIndex
                );
                this.fieldToCssClassMap.put(dcpp.field, dcpp.cssClass);
                
                // Panasonic specific: for the first row, set upper bound cell to disabled and input type of text:
                if(this.index == finalIndex && dcpp.field == L2I_Constants.CM_UPPER_BOUND_FIELD) {
                    dcpp.isDisabled = true;
                    dcpp.inputType = L2I_Constants.INPUT_TYPE_TEXT;
                    if(dcpp.gridCellValue != null && dcpp.gridCellValue != 'undefined') {
                        dcpp.gridCellValue = Integer.valueOf(dcpp.gridCellValue) + ' and beyond';
                    }
                }
                
                this.dataCellPropertyPacks.add(dcpp);
            }
            this.fieldSetSize = this.dataCellPropertyPacks.size();            
        }
    }

    /**
     * @Description -> method to save records that were modified in the customList table
     * @param List<SObject> records -> a list of records to save, passed in from the JS controller
     * @param List<SObject> newRecords
     * @param List<SObject> recordsToDeleteParam
     * @return void
     */
    @AuraEnabled
    public static void saveRecords(
        List<SObject> recordsToUpdate, List<SObject> newRecords, Id parentId, Boolean jsonImplementation, String customModel
    ) {
        // TODO: find a way to ensure unique values in the Javascript controller:

        System.debug('LWC_ListController.saveRecord() recordsToUpdate: ' + recordsToUpdate);
        System.debug('LWC_ListController.saveRecord() newRecordsToCreate: ' + newRecords);
        System.debug('LWC_ListController.saveRecord() parentId: ' + parentId);
        System.debug('LWC_ListController.saveRecord() jsonImplementation: ' + jsonImplementation);
        System.debug('LWC_ListController.saveRecord() customModel: ' + customModel);
        //System.debug('LWC_ListController.saveRecord() recordsToDeleteParam: ' + recordsToDeleteParam);

        Map<Id, SObject> pseudoRecords = new Map<Id, SObject>();

        try {
            if(!jsonImplementation) {
                update recordsToUpdate;
            } else {
                Boolean updateFieldJSON = false; 
                if(recordsToUpdate != null && !recordsToUpdate.isEmpty()) {
                    for(SObject record : recordsToUpdate) {
                        Id recordId = (Id) record.get(ID_STR);
                        record.put(L2I_Constants.CUSTOM_MODEL_PARENT_FIELD, parentId);
                        pseudoRecords.put(recordId, record);
                    }
                    updateFieldJSON = true; 
                }
                if(newRecords != null && !newRecords.isEmpty()) {
                    Schema.DescribeSObjectResult customModelMdtDescribe = L2I_Custom_Model__mdt.sObjectType.getDescribe();
                    String keyPrefix = customModelMdtDescribe.getKeyPrefix();
                    for(SObject newRecord : newRecords) {
                        Id fakeId = L2I_ApexUtils.create18CharFakeId(keyPrefix);
                        newRecord.put(ID_STR, fakeId);
                        newRecord.put(L2I_Constants.CUSTOM_MODEL_PARENT_FIELD, parentId);
                        pseudoRecords.put(fakeId, newRecord);
                    }
                    updateFieldJSON = true;
                }
                if(updateFieldJSON) { 
                    SBQQ.TriggerControl.disable();
                    L2I_Custom_Model__mdt customModelMdt = [
                        SELECT Id, L2I_Column_API_Names__c, L2I_JSON_Field_API_Name__c, L2I_JSON_Flag_Field_API_Name__c 
                        FROM L2I_Custom_Model__mdt WHERE DeveloperName = :customModel
                    ];
                    SObject obj = parentId.getSObjectType().newSObject(parentId);
                    if(customModelMdt.L2I_JSON_Field_API_Name__c != null) {
                        obj.put(customModelMdt.L2I_JSON_Field_API_Name__c, JSON.serialize(pseudoRecords.values()));
                        obj.put(customModelMdt.L2I_JSON_Flag_Field_API_Name__c, true);
                    }
                    update obj;
                }
            }

        } catch(Exception e) {
            String exceptionMessage = 'LWC_ListController.saveRecords() exception: ' + e.getMessage() + ' Stack trace: ' + e.getStackTraceString();
            System.debug(exceptionMessage);
            throw new AuraHandledException(exceptionMessage);
        }
    }

    /***********************************************************************/
    /*  NOTE: CODE BELOW THIS LINE ONLY PERTAINS TO CPQ QUOTES/QUOTE LINES
    /***********************************************************************/

    /**
     * @Description -> method to calculate a CPQ quote in MEMORY as a QuoteModel without committing to the database
     * (decomment to enable Calculate on Advanced Related List)
     * @param Id quoteId -> the id of the quote to calculate in memory
     * @return SBQQ__Quote__c calculatedQuoteWithoutCommit -> an SBQQ__Quote__c in memory
     */
    // @AuraEnabled(cacheable=true)
    // public static CalculatedQuoteWrapper getCalculatedQuoteWrapper(Id quoteId, String quoteModelString) {
    //     System.debug('quoteModelString: ' + quoteModelString);

    //     //System.debug('LWC_ListController.getCalculatedQuoteWrapper() quoteModel: ' + quoteModel);
    //    //System.debug('LWC_ListController.getCalculatedQuoteWrapper() quoteModel.lineItems: ' + quoteModel.lineItems);

    //     CalculatedQuoteWrapper calculatedQuoteWrapper;
    //     try {
    //         CPQ_ApiDataModels.QuoteModel calculatedQuoteModel = CPQ_ApiWrapper.calculateQuote2ButDoNotCommit(quoteId, quoteModelString);
    //         calculatedQuoteWrapper = new CalculatedQuoteWrapper(calculatedQuoteModel);
    //     } catch(Exception e) {
    //         System.debug(e.getMessage() + ', line number: ' + e.getLineNumber());
    //         throw new AuraHandledException(e.getMessage() + ', line number: ' + e.getLineNumber());
    //     }
    //     return calculatedQuoteWrapper; 
    // }

    // /**
    //  * @Description -> class to store a quote that has been calculated in memory, along with its quote lines that have been calculated in memory
    //  * (decomment to enable Calculate on Advanced Related List):
    //  */
    // public class CalculatedQuoteWrapper {
    //     @AuraEnabled public SObject calculatedQuote;
    //     //@AuraEnabled public Map<Id, SBQQ__QuoteLine__c> calculatedQuoteLines;
    //     @AuraEnabled public List<SBQQ__QuoteLine__c> calculatedQuoteLines;

    //     public CalculatedQuoteWrapper(CPQ_ApiDataModels.QuoteModel calculatedQuoteModel) {
    //         this.calculatedQuote = calculatedQuoteModel.record;
    //         //this.calculatedQuoteLines = new Map<Id, SBQQ__QuoteLine__c>();
    //         this.calculatedQuoteLines = new List<SBQQ__QuoteLine__c>();
    //         for(CPQ_APIDataModels.QuoteLineModel qlm : calculatedQuoteModel.lineItems) {
    //             SBQQ__QuoteLine__c ql = qlm.record;
    //             ///this.calculatedQuoteLines.put(ql.Id, ql);
    //             this.calculatedQuoteLines.add(ql);
    //         }
    //     }
    // }
}