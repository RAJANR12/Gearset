public class PT_PLG_CallOut {
    @AuraEnabled
    public static String getAirCraftConfig(Id recordId) {
        String jsonBody = PT_PLG_RequestWrapper.getPLGRequestBody(recordId);
        return PT_JSON_Settings.PLGCalloutSetting('url') + '?quoteId=' + recordId + '&' + jsonBody;
    }
}