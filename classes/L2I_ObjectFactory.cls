/**
 *      @author       Raj Rajen
 *      @date         01/31/2020
 *      @description  A builder class to generate a coherent set of data records for unit tests
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     01/31/2020         Initial setup
 *      Sarah Kennedy                 06/17/2020         Retrieving RecordTypeId using DeveloperName (API name) instead of just the Name (label)
 *
 */
public class L2I_ObjectFactory {
    public class UndefinedSObjectTypeException extends Exception {}
    public class DuplicateIdentifierException extends Exception {}

    private Map<String,SObject> registry;

    public L2I_ObjectFactory() {
        this.registry = new Map<String,SObject>();
    }

    // typeName must be a valid API name (i.e. custom objects should be suffixed with "__c"):
    private SObject newSObject(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if (targetType == null) {
            // calling code should usually handle this exception:
            throw new UndefinedSObjectTypeException('The requested SObject type [' + typeName +
                    '] cannot be constructed; it is not configured on this org.');
        }
        // SObjects offer the only way in Apex to instantiate an object with a type determined at
        // runtime -- you can optionally pass an Id argument to instantiate an SObject for an
        // existing record:
        return targetType.newSObject();
    }

    private SObject build(String typeName, SObject baseObject, Map<String, Object> attributes) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        Map<String, Schema.SObjectField> fieldTypesMap = targetType.getDescribe().fields.getMap();

        for (String key : attributes.keySet()) {
            Schema.SObjectField field = fieldTypesMap.get(key);
            Schema.DisplayType fldType = field.getDescribe().getType();

            Object value = attributes.get(key);
            String fieldType = fldType.name().toLowerCase();
            switch on fieldType {
                when 'date' {
                    baseObject.put(key, Date.valueOf((String)value));
                }
                when 'datetime' {
                    baseObject.put(key, Datetime.valueOf((String)value));
                }
                when 'boolean' {
                    baseObject.put(key, Boolean.valueOf((String)value));
                }
                when 'double' {
                    baseObject.put(key, Double.valueOf((String)value));
                }
                when 'integer' {
                    baseObject.put(key, Integer.valueOf((String)value));
                }
                when 'currency' {
                    baseObject.put(key, Double.valueOf((String)value));
                }
                when 'percent' {
                    baseObject.put(key, Double.valueOf((String)value));
                }
                when 'reference' {
                    /* validate Ids as either 15 or 18 character strings? */
                    baseObject.put(key, (String)value);
                }
                when else {
                    /* url, string, textarea, picklist, etc */
                    baseObject.put(key, (String)value);
                }
            }
        }

        return baseObject;
    }

    private Id resolveRecordType(String expression) {
        Id recTypeId = null;
        String recType = expression.substringBetween('{', '}');
        List<String> tokens = recType.split('\\.');

        if (tokens.size() == 2) {
            String objName = tokens[0];
            String recTypeName = tokens[1];
            System.debug('*** objName ' + objName);
            System.debug('*** recTypeName ' + recTypeName);
            recTypeId = Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByDeveloperName().get(recTypeName).getRecordTypeId();
            System.debug('*** recTypeId ' + recTypeId);
        }
        return recTypeId;
    }

    private Id resolveParentId(String expression) {
        Id parentId = null;
        String recType = expression.substringBetween('{', '}');
        List<String> tokens = recType.split('\\.');

        if (tokens.size() == 2) {
            String identifier = tokens[0];
            String fldName = tokens[1];

            if (this.registry.containsKey(identifier)) {
                System.debug('======= attempting to get \'' + identifier + '\' from registry');
                SObject parent = this.registry.get(identifier);
                System.debug(parent);
                // TODO: Is there a potential issue here with type casting to String?
                parentId = (String) parent.get(fldName);
            }
        }
        return parentId;
    }

    private String evaluateDateExpression(String expression) {
        // $eval{DATE(today,addDays,20)}
        String evaluatedDate = null;
        Date adt = null;

        String dateExpr = expression.substringBetween('{DATE(', ')}');
        List<String> tokens = dateExpr.split('\\,');
        System.debug('======= expression :' + expression);
        System.debug('======= tokens :' + tokens);
        System.debug('======= tokens size :' + tokens.size());

        if (tokens.size() == 1 && tokens[0].equalsIgnoreCase('today')) {
            adt = Date.today();
        } else if (tokens.size() == 3 && tokens[0].equalsIgnoreCase('today')) {
            adt = Date.today();
            String dateMethod = tokens[1].toLowerCase();
            Integer offset = Integer.valueOf(tokens[2]);
            System.debug('======= dateMethod :' + dateMethod + ' offset :' + offset);
            switch on dateMethod {
                when 'adddays' {
                    adt = adt.addDays(offset);
                }
                when 'addmonths' {
                    adt = adt.addMonths(offset);
                }
                when 'addyears' {
                    adt = adt.addYears(offset);
                }
            }
        }
        evaluatedDate = '' + adt.year() + '-' + adt.month() + '-' + adt.day();

        return evaluatedDate;
    }

    private String evaluateAclExpression(String expression) {
        // $eval{ACL(profile,System Administrator)}
        String evaluatedAcl = null;
        Date adt = null;

        String aclExpr = expression.substringBetween('{ACL(', ')}');
        List<String> tokens = aclExpr.split('\\,');
        System.debug('======= expression :' + expression);
        System.debug('======= tokens :' + tokens);
        System.debug('======= tokens size :' + tokens.size());

        if (tokens.size() == 2 && tokens[0].equalsIgnoreCase('profile')) {
            String profileName = tokens[1];
            Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
            if (p != null) {
                evaluatedAcl = p.Id;
            }
        }

        return evaluatedAcl;
    }

    private String evaluateExternalIdExpression(String expression) {
        // $eval{EXTERNALID(Product2,L2I_Inventory_Item_Id__c,52267)}
        String evaluatedExternalId = null;

        String extIdExpr = expression.substringBetween('{EXTERNALID(', ')}');
        List<String> tokens = extIdExpr.split('\\,');
        System.debug('======= expression :' + expression);
        System.debug('======= tokens :' + tokens);
        System.debug('======= tokens size :' + tokens.size());

        if (tokens.size() == 3) {
            String objectApiName = tokens[0];
            String fieldApiName = tokens[1];
            String fieldValue = tokens[2];

            List<SObject> results = Database.query('SELECT Id FROM ' + objectApiName + ' WHERE ' + fieldApiName + ' = \'' + fieldValue + '\' LIMIT 1');
            if (results != null && results.size() == 1) {
                evaluatedExternalId = results[0].Id;
            }
        }
        return evaluatedExternalId;
    }


    private void addToRegistry(String identifier, SObject sobj, Map<String, Object> fieldsMap) {

        // resolve anything that needs to be resolved before we attempt inserting the record
    
        System.debug('*** identifier ' + identifier);
        for (String fld : fieldsMap.keySet()) {
            String fieldValueSpec = (String) fieldsMap.get(fld);

            if (fieldValueSpec.startsWithIgnoreCase('$recordType{')) {
                Id recordTypeId = resolveRecordType(fieldValueSpec);
                System.debug('======= Record Type Id :' + recordTypeId);
                sobj.put(fld, recordTypeId);
            }

            if (fieldValueSpec.startsWithIgnoreCase('$resolve{')) {
                Id recordTypeId = resolveParentId(fieldValueSpec);
                System.debug('======= Parent Id :' + recordTypeId);
                System.debug('*** fieldValueSpec ' + fieldValueSpec);
                sobj.put(fld, recordTypeId);
            }
        }

        if (this.registry.containsKey(identifier)) {
            // throw an exception as this potentially represents a duplicate identifier?
            throw new DuplicateIdentifierException('Identifier \'' + identifier + '\' has already been defined in the registry');
        } else {
            insert sobj;
            System.debug('*** sobj inserted ' + sobj);
            this.registry.put(identifier, sobj);
        }
    }

    public Map<String, SObject> getRegistry() {
        return this.registry;
    }

    public SObject getRegistryItem(String key) {
        if (this.registry.containsKey(key)) {
            return this.registry.get(key);
        } else {
            return null;
        }
    }

    private void evaluateExpressions(Map<String, Object> fieldsMap) {
        for (String fld : fieldsMap.keySet()) {
            String fieldValueSpec = (String) fieldsMap.get(fld);

            if (fieldValueSpec.startsWithIgnoreCase('$eval{DATE(')) {
                String dts = evaluateDateExpression(fieldValueSpec);
                fieldsMap.put(fld, dts);
            }

            if (fieldValueSpec.startsWithIgnoreCase('$eval{ACL(')) {
                String dts = evaluateAclExpression(fieldValueSpec);
                fieldsMap.put(fld, dts);
            }

            if (fieldValueSpec.startsWithIgnoreCase('$eval{EXTERNALID(')) {
                String dts = evaluateExternalIdExpression(fieldValueSpec);
                fieldsMap.put(fld, dts);
            }

        }
    }

    public void loadResource(String resourceName) {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = :resourceName LIMIT 1];
        String body = sr.Body.toString();

        loadString(body);
    }

    public void loadString(String body) {

        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(body);

        List<Object> resources = (List<Object>) root.get('resources');
        if (Test.isRunningTest() && resources != null) {
            for (Object ritem : resources) {
                Map<String,Object> resource = (Map<String, Object>) ritem;

                String resourceFileAlias = (String) resource.get('resource');
                String sobjectType       = (String) resource.get('sobject');
                System.debug('======= Attempting to load static resource csv file :' + resourceFileAlias + ' for ' + sobjectType);

                Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sobjectType);
                Test.loadData(targetType, L2I_StaticConstants.unitTestStaticResource.get(resourceFileAlias));
            }
        }

        List<Object> entries = (List<Object>) root.get('records');
        System.debug('======= Number of records :' + entries.size());

        for (Object aItem : entries) {
            Map<String, Object> entry = (Map<String, Object>) aItem;

            String identifier             = (String) entry.get('identifier');
            String sobjectType            = (String) entry.get('sobject');
            Map<String, Object> fieldsMap = (Map<String, Object>) entry.get('fields');

            SObject sObj = newSObject(sobjectType);

            System.debug('======== SObject :' + sobjectType + ' identifier :' + identifier + ' fields :'+ fieldsMap.size());

            evaluateExpressions(fieldsMap);

            sObj = build(sobjectType, sObj, fieldsMap);

            addToRegistry(identifier, sObj, fieldsMap);
        }
    }
}