/**
 *      @author       Raj Rajen
 *      @date         01/03/2020
 *      @description  Helper class that wraps L2I_JSON_Settings__mdt
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     01/03/2020         Initial creation
 *
 */
public class L2I_JSON_Settings {
    static Map<String, String> jsonSettings;

    static {
        List<L2I_JSON_Settings__mdt> jsList = [select Id, DeveloperName, JSON_Representation__c from L2I_JSON_Settings__mdt];

        if (!jsList.isEmpty()) {
            jsonSettings = new Map<String, String>();
            for (L2I_JSON_Settings__mdt jsm : jsList) {
                String settingName = jsm.DeveloperName;
                String settingJSON = jsm.JSON_Representation__c;

                jsonSettings.put(settingName.toLowerCase(), settingJSON);
            }
        }
    }

    public static Map<String,String> getSettings(String settingName) {
        // Map<String, String> dbtNoteSettings = L2I_JSON_Settings.getSettings('Debit_Note_Settings');

        Map<String,String> settings = null;

        String key = settingName.toLowerCase();
        if (jsonSettings.containsKey(key)) {
            settings = new Map<String, String>();
            String settingJSON = jsonSettings.get(key);

            Map<String, Object> untypedSettings = (Map<String, Object>) JSON.deserializeUntyped(settingJSON);
            for (String skey : untypedSettings.keySet()) {
                String svalue = (String) untypedSettings.get(skey);
                settings.put(skey, svalue);
            }
        }

        return settings;
    }

    public static String getSpecificSetting(String settingsName, String settingKey) {
        // String amount = L2I_JSON_Settings.getSpecificSetting('Debit_Note_Settings','PM_Time_Amount');

        String settingValue = null;

        Map<String, String> settings = getSettings(settingsName);
        if (settings != null && settings.containsKey(settingKey)) {
            settingValue = settings.get(settingKey);
        }

        return settingValue;
    }

    public static Set<String> getSpecificSettingCollection(String settingsName, String settingKey) {
        // Set<String> recipients = L2I_JSON_Settings.getSpecificSettingCollection('System_Alert_Settings','Recipients');

        Set<String> setting = null;

        Map<String, String> settings = getSettings(settingsName);
        String settingValue = null;
        if (settings != null && settings.containsKey(settingKey)) {
            settingValue = settings.get(settingKey);
        }

        if (settingValue != null && settingValue.length() > 0) {
            Set<String> rawSet = new Set<String>(settingValue.split(','));
            if (rawSet.size() > 0) {
                setting = new Set<String>();
            }
            for (String s : rawSet) {
                setting.add(s.trim());
            }
        }

        return setting;
    }

}