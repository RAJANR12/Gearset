/**
 *      @author       Dan Morris
 *      @date         07/17/2020
 *      @description  Program Table Structured Settings
 * Class that manages the general settings for Program Table functionality
 * This class defines Apex objects that are rendered from a
 * Custom Metadata record:
 *      L2I_JSON_Settings__mdt.JSON_Representation__c
 *      DeveloperName = 'Program_Table_Settings'
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Dan Morris                   07/17/2020         Initial scaffold
 *
 */
 public with sharing class PT_JSON_Settings {
     @TestVisible public static ConfigurationData myConfig {
        public get {
            if (myConfig == null) initialize();
            return myConfig;
        }
       private set;
    }

    @TestVisible private static void initialize() {
        String sampleJson = '{"SystemTypeTranslations":{"S3000i":"8","eXW":"W","eXK":"J","eXLite":"L","eFX":"C","MPES w OVH VID":"3","eX2":"A","eXO":"Y","NEXT":"Z","eXconnect":"E","eXphone":"E","eXtv":"E","CMS":"F","eX3":"G","eX2 FOR B787":"B","S3000":"5","PRAM ONLY":"6","MISCELLANEOUS":"9","MPES":"3","AVOD 1.5":"4","DIGITAL MPES":"3","GCS":"E","eX1":"H","AVOD 1.0":"4"}}';
        List<L2I_JSON_Settings__mdt> records = [
            SELECT JSON_Representation__c FROM L2I_JSON_Settings__mdt
            WHERE DeveloperName = 'Program_Table_Settings' LIMIT 1
        ];
        myConfig = (PT_JSON_Settings.ConfigurationData) JSON.deserialize(
            (records == null || records.size() < 1) ? sampleJson : records[0].JSON_Representation__c
            , ConfigurationData.class
        );
    }
    public PT_JSON_Settings() {
        initialize();
    }

     @TestVisible public class ConfigurationData {
       public Map<String,String> SystemTypeTranslations;
        public Map<String,String> PLGCalloutSettings;
    }

    public static String SystemTypeTranslation(String systemType) {
        return myConfig.SystemTypeTranslations.containsKey(systemType) ? myConfig.SystemTypeTranslations.get(systemType) : null;
    }
    public static Map<String,String> SystemTypeTranslations() {return myConfig.SystemTypeTranslations;}
    public static List<String> SystemTypes() {return new List<String>(SystemTypeTranslations().keySet());}

    public static String PLGCalloutSetting(String setting) {
        return myConfig.PLGCalloutSettings.containsKey(setting) ? myConfig.PLGCalloutSettings.get(setting) : null;
    }
    public static Map<String,String> PLGCalloutSettings() {
        return myConfig.PLGCalloutSettings;
    }
    public static List<String> settings() {
        return new List<String>(PLGCalloutSettings().keySet());
    }
}