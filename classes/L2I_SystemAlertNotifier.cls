/**
 *      @author       Raj Rajen
 *      @date         08/07/2019
 *      @description  Alert Notifier helper class

        Modification Log:
        ------------------------------------------------------------------------------------
        Developer                       Date                Description
        ------------------------------------------------------------------------------------
        Raj Rajen                     08/07/2019         Initial setup of class

 */
global class L2I_SystemAlertNotifier {
    
    //private static final String ALERT_RECIPIENT = 'rrajen@salesforce.com';
    //private static final String ALERT_SENDER = 'cep-alert-notifier@panasonic.aero';
    
    public static void createSystemAlert(String type, String message) {
        
        if (type == null || String.isEmpty(type)) {
            type = 'Unknown';
        }
        
        String currentTS = getTimeStamp();
        String uniqueId = type + ':' + currentTS;
        
        L2I_System_Alert__c alert = new L2I_System_Alert__c();
        alert.Alert_Type__c = type;
        alert.Timestamp__c = currentTS;
        alert.Alert_Code__c = uniqueId;
        alert.Notification_Sent__c = false;
        alert.Message__c = message;
        
        System.debug('====== Attempting to upsert System_Alert__c with uniqueId :' + uniqueId);
        Database.upsert(alert, L2I_System_Alert__c.Fields.Alert_Code__c);
    }
    
    public static Id createSystemAlert(String type, String message, String objectName, String objectIds, String userId, Boolean sendEmail) {
        
        if (type == null || String.isEmpty(type)) {
            type = 'Unknown';
        }
        
        String currentTS = getTimeStamp();
//        String uniqueId = type + ':' + currentTS;
        String uniqueId = type + ':' + L2I_UtilityHelper.generateGuid();
        
        Id alertId;
        List<L2I_System_Alert__c> alertList = new List<L2I_System_Alert__c>();
        alertList = [
              select Id,
                    Alert_Type__c,
                    Timestamp__c,
                    Alert_Code__c,
                    Notification_Sent__c,
                    Message__c,
                    Object_Name__c,
                    Object_Ids__c,
                    Running_User__c,
                    Send_Email__c
              FROM L2I_System_Alert__c
              WHERE Alert_Code__c = :uniqueId
        ];
        if (alertList != NULL && alertList.size() > 0) {
            alertList[0].Alert_Type__c = type;
            alertList[0].Timestamp__c = currentTS;
            alertList[0].Notification_Sent__c = false;
            alertList[0].Message__c = message.length() > 131000 ? message.substring(0, 131000) : message;
            alertList[0].Object_Name__c = objectName;
            alertList[0].Object_Ids__c = (objectIds != NULL && objectIds.length() > 255) ? objectIds.abbreviate(255) : objectIds;
            alertList[0].Running_User__c = userId;
            alertList[0].Send_Email__c = sendEmail;
            update alertList;
            alertId = alertList[0].Id;
        } else {
            L2I_System_Alert__c alert = new L2I_System_Alert__c();
            alert.Alert_Type__c = type;
            alert.Timestamp__c = currentTS;
            alert.Alert_Code__c = uniqueId;
            alert.Notification_Sent__c = false;
            alert.Message__c = message.length() > 131000 ? message.substring(0, 131000) : message;
            alert.Object_Name__c = objectName;
            alert.Object_Ids__c = (objectIds != NULL && objectIds.length() > 255) ? objectIds.abbreviate(255) : objectIds;
            alert.Running_User__c = userId;
            alert.Send_Email__c = sendEmail;
            
            System.debug('====== Attempting to upsert System_Alert__c with uniqueId :' + uniqueId);
            insert alert;
            alertId = alert.Id;
        }
        System.debug('====== Attempting to upsert System_Alert__c with uniqueId :' + uniqueId);
        return alertId;
    }
    
    //@future(callout=true)
    public static void sendEmailNotifications(Set<Id> alertIds) {
        
        //Set<String> ALERT_RECIPIENTS = L2I_GeneralSettings.getSystemAlertRecipients();
        //String ALERT_SENDER = L2I_GeneralSettings.getSystemAlertSender();
        // modifications to use JSON Settings instead of GeneralSettings
        Set<String> ALERT_RECIPIENTS = L2I_JSON_Settings.getSpecificSettingCollection('System_Alert_Settings', 'Recipients');
        String ALERT_SENDER = L2I_JSON_Settings.getSpecificSetting('System_Alert_Settings', 'Sender');
        
        List<L2I_System_Alert__c> alerts = [
              select Id,
                    Alert_Type__c,
                    Timestamp__c,
                    Alert_Code__c,
                    Notification_Sent__c,
                    Message__c,
                    Object_Name__c,
                    Object_Ids__c,
                    Running_User__c,
                    Send_Email__c
              
              from L2I_System_Alert__c
              where Id in :alertIds
        ];
        
        System.debug('===== Number of alerts to send emails for :' + alerts.size());
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>{
        };
        
        for (L2I_System_Alert__c alert : alerts) {
            if (alert.Send_Email__c) {
//build the message
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setSaveAsActivity(false);
                message.setSubject('System Alert (Org Id:' + UserInfo.getOrganizationId() + ') -- ' + alert.Alert_Type__c);
//message.setPlainTextBody(body);
                message.setHtmlBody('Link: ' + Url.getSalesforceBaseUrl().toExternalForm() + '/' + alert.Id + ':<br/> ' + alert.Message__c);
                message.setToAddresses(new List<String>(ALERT_RECIPIENTS));
                message.setReplyTo(ALERT_SENDER);
                
                messages.add(message);
            }
        }
        
        if (!messages.isEmpty()) {
            System.debug('====== Sending all System Alert email messages. Size :' + messages.size());
            List<Messaging.SendEmailResult> res = Messaging.sendEmail(messages);
        } else {
            System.debug('====== No System Alert email messages to send');
        }
    
    }

//@future(callout=true)
//public static void sendSlackNotifications(Set<Id> alertIds) {
//
//}
    
    public static String getTimeStamp() {
        String ts = '';
        Datetime now = System.now();
        
        Integer min = now.minute();
        String quarterDescriptor = '';
        if (min < 15) {
            quarterDescriptor = '00';
        } else if (min < 30) {
            quarterDescriptor = '15';
        } else if (min < 45) {
            quarterDescriptor = '30';
        } else {
            quarterDescriptor = '45';
        }
        
        ts = now.format('yyyyMMddHH') + quarterDescriptor;
        
        return ts;
    }

}