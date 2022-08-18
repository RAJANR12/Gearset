/**
 *      @author       Raj Rajen
 *      @date         07/10/2019
 *      @description  L2I Utility Helper Class
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/10/2019         Initial scaffold
 *      Arun                          07/30/2019         Added getPlaceHolderProductCodes method
 *      Arun                          08/04/2019         Added getAccountRecordTypeNames method
 *      Andy Fang                     08/13/2019         Added createPlatformEvent
 *      Arun                          09/19/2019         Added getOpportunityTypeForPORequired method
 *      Andy Fang                     02/21/2020         Update createPlatformEvent for Service Now
 *      Sarah Kennedy                 03/26/2020         Added log GUID to batch names in publishOrderActivationCompletedEvent
 *      Andy Fang                     04/10/2020         Added sendEmail function to send email
 *      Sarah Kennedy                 04/10/2020         US1762 added checkServiceActivation method for Order Activation by Case
 */
public class L2I_UtilityHelper {

    public static Id getRecordTypeId(String developerName, String sobjectName) {
        List<RecordType> recordTypes = [select Id
                                          from RecordType
                                         where DeveloperName = :developerName
                                           and SobjectType = :sobjectName];
        if (recordTypes.isEmpty()) {
            return null;
        }

        return recordTypes[0].Id;
    }

    public static Map<Id,RecordType> getRecordTypesLookup(String sobjectName) {
        Map<Id,RecordType> lookupMap = new Map<Id, RecordType>([select Id,
                                                                       Name,
                                                                       DeveloperName
                                                                  from RecordType
                                                                 where SobjectType = :sobjectName]);
        return lookupMap;
    }


    public static Id getEmailTemplateId(String templateDeveloperName) {
        List<EmailTemplate> templates = [select Id,
                                                Name,
                                                DeveloperName,
                                                TemplateStyle,
                                                TemplateType,
                                                Subject
                                           from EmailTemplate
                                          where DeveloperName = :templateDeveloperName];
        if (templates.isEmpty()) {
            return null;
        }

        return templates[0].Id;
    }

    public static Set<String> getAllowedOrderProducts() {
        Set<String> allowedProducts = L2I_GeneralSettings.getAllowedProducts();

        return allowedProducts;
    }

    public static Set<String> getDisallowedOrderProducts() {
        Set<String> disallowedProducts = L2I_GeneralSettings.getDisallowedProducts();

        return disallowedProducts;
    }
    /*
    public static Set<String> getPlaceHolderProductCodes() {
        Set<String> placeholderParts = L2I_GeneralSettings.getPlaceholderProductCodes();
        return placeholderParts;
    }

    public static Set<String> getAccountRecordTypeNames() {
        Set<String> accRecTypes = L2I_GeneralSettings.getAccountRecordTypeNames();
        return accRecTypes;
    }*/

    // Builds a CRON Expression out of a Datetime with offsets
    public static String getCRONexpression(Datetime dt, Integer secsOffset, Integer minsOffset, Integer hoursOffset) {
        Datetime scheduledTime = dt.addHours(hoursOffset);
        scheduledTime = scheduledTime.addMinutes(minsOffset);
        scheduledTime = scheduledTime.addSeconds(secsOffset);

        String secondsPart = String.valueOf(scheduledTime.second());
        String minutesPart = String.valueOf(scheduledTime.minute());
        String hoursPart = String.valueOf(scheduledTime.hour());
        return ('' + secondsPart + ' ' + minutesPart + ' ' + hoursPart + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year());
    }

    public static void publishOrderActivationCompletedEvent(String logId) {
        
        // Finally, publish a Platform Event to take care of removing the jobs
        // so that they can rescheduled with the same names with the additional
        // benefit of not having a proliferation of Completed Scheduled Jobs
        List<L2I_Order_Activation_Completed__e> allCompleteList = new List<L2I_Order_Activation_Completed__e>();
    
        L2I_Order_Activation_Completed__e allComplete = new L2I_Order_Activation_Completed__e();
        allComplete.logId__c = logId;
        allCompleteList.add(allComplete);
        List<Database.SaveResult> results = EventBus.publish(allCompleteList);
    
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('====== Successfully published L2I_Order_Activation_Complete__e event');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('====== Platform Event Publish Error returned: ' +
                          err.getStatusCode() +
                          ' - ' +
                          err.getMessage());
                }
            }
        }
    }

    public static void publishAircraftServiceActivatedEvent(String jsonOrderMap) {

        L2I_Aircraft_Service_Activated__e aircraftServiceActivation = new L2I_Aircraft_Service_Activated__e();
        aircraftServiceActivation.orderMap__c = jsonOrderMap;

        Database.SaveResult sr = EventBus.publish(aircraftServiceActivation);

        if (sr.isSuccess()) {
            System.debug('====== Successfully published L2I_Aircraft_Service_Activated__e event');
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('====== Platform Event Publish Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
            }
        }
    }

    // Platform Event method to create Event ONLY after Aircraft Order and Aircraft Service is completed
    // US - Using aircraft Id & Opportunity Name as an identifier for service now implementation
    //public static void createPlatformEvent( Set<Id> AOSetID ){
    public static void createPlatformEvent( Set<Id> caseIdSet ){

        List<Case> caseList = [ SELECT Id, L2I_Aircraft__c, L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c,
                                L2I_Product_Category_2__c
                                FROM Case WHERE Id IN: caseIdSet];
        List<L2I_Service_Activation__e> saEventList = new List<L2I_Service_Activation__e>();

        Map<String, Set<Id>> acOppOMap = new Map<String, Set<Id>>();

        for ( case c : caseList ){
            // Note: US2122 prevents WiFi from this integration on a Revise Case
            if ( c.L2I_Product_Category_2__c  == 'TV/Media' || c.L2I_Product_Category_2__c  == 'WiFi' ) {
                String key = c.L2I_Aircraft__c + '' + c.L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c;

                if (acOppOMap.get(key) != NULL) {
                    Set<Id> temp = acOppOMap.get(key);
                    temp.add(c.Id);
                    acOppOMap.put(key, temp);
                } else {
                    Set<Id> caseIds = new Set<Id>();
                    caseIds.add(c.Id);
                    acOppOMap.put(key, caseIds);
                }
            }
        }
        // Note: US2122 prevents WiFi from this integration on a Revise Case
        for ( case c : caseList ){
            if ( c.L2I_Product_Category_2__c  == 'TV/Media' || c.L2I_Product_Category_2__c  == 'WiFi' ) {
                String key = c.L2I_Aircraft__c + '' + c.L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c;
                L2I_Service_Activation__e sa = new L2I_Service_Activation__e();
                sa.AircraftId__c = c.L2I_Aircraft__c;
                sa.Opportunity_Number__c = c.L2I_Original_Sales_Opportunity__r.L2I_Opportunity_Number__c;
                sa.CaseIds__c = JSON.serialize(acOppOMap.get(key));
                saEventList.add(sa);
            }
        }
        system.debug( ' saEventList ' + saEventList );
        if ( saEventList.size() > 0 )
            EventBus.publish( saEventList );

        /*
        List<L2I_Aircraft_Order__c> aoList = [ SELECT Id, Name, Aircraft__c, Order__c,
                                                Order__r.Opportunity.L2I_Opportunity_Number__c,
                                                Product_Category2__c
                                                FROM L2I_Aircraft_Order__c WHERE ID in : AOSetID ];

        //List<L2I_Create_Connectivity__e> asEventList = new List<L2I_Create_Connectivity__e>();
        List<L2I_Service_Activation__e> saEventList = new List<L2I_Service_Activation__e>();
        Set<Id> aircraftIdSet = new Set<Id>();
        Map<Id, String> acTooppoMap = new Map<Id, String>();
        //If we need to associate aircraft Id to multiple oppoName
        // Map<Id, List<String>> acTooppoMap = new Map<Id, List<String>>();

        for ( L2I_Aircraft_Order__c ao : aoList ){
            if ( ao.Product_Category2__c != null ){
                system.debug( ao.Product_Category2__c  );
                if ( ao.Product_Category2__c  == 'TV/Media' ||
                        ao.Product_Category2__c  == 'WiFi'
                        ){
                    // Adding aircrcraft into set
                    if( ao.Aircraft__c != null && !aircraftIdSet.contains( ao.Aircraft__c )){
                        aircraftIdSet.add( ao.Aircraft__c );
                    }

                    // Create aircraft to opportunity map
                    if ( ao.Aircraft__c != null && ao.Order__r.Opportunity.L2I_Opportunity_Number__c != null ){
                        // We are assuming only one aircraft contains one opportunity
                        // otherwise, we need to use the other map for multiple oppos
                        if ( acTooppoMap.get( ao.Aircraft__c) == null ){
                             acTooppoMap.put( ao.Aircraft__c, ao.Order__r.Opportunity.L2I_Opportunity_Number__c );
                         }
                    }
                }
            }
        }

        for ( Id acId : aircraftIdSet ){

            if ( acTooppoMap.get( acId ) != null ){
                L2I_Service_Activation__e sa = new L2I_Service_Activation__e();
                sa.AircraftId__c = acId;
                sa.Opportunity_Number__c = acTooppoMap.get( acId );
                saEventList.add( sa );
            }
        }

        system.debug( ' saEventList ' + saEventList );
        if ( saEventList.size() > 0 )
            EventBus.publish( saEventList );
        */
        /* Old Code
        for ( L2I_Aircraft_Order__c ao : aoList ){
            if ( ao.Product_Category2__c != null ){
                system.debug( ao.Product_Category2__c  );
                if ( ao.Product_Category2__c  == 'TV/Media' ||
                        ao.Product_Category2__c  == 'WiFi'
                        ){
                    L2I_Create_Connectivity__e wifie = new L2I_Create_Connectivity__e();
                    wifie.AircraftId__c = ao.Aircraft__c;
                    //We are using Name instead of ID to potentially resolve the sandbox refresh issue
                    wifie.OrderId__c = ao.Name;
                    wifie.ProductCategory__c = ao.Product_Category2__c;

                    asEventList.add( wifie );
                }
            }

        }
        system.debug( ' asEventList ' + asEventList );
        if ( asEventList.size() > 0 )
            EventBus.publish( asEventList );
        */
    }

    public static String generateGuid() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
    /*
    public static Set<String> getOpportunityTypeForPORequired() {
        Set<String> oppRecTypes = L2I_GeneralSettings.getOpportunityTypeForPORequired();
        return oppRecTypes;
    }*/

    public static Boolean validateEmail(String email) {
        Boolean res = true;

        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher emailMatcher = emailPattern.matcher(email);

        if (!emailMatcher.matches()) {
            res = false;
        }

        return res;
    }
    
    public static void sendEmail( String email_subject, String email_body, Id userId ){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject( email_subject );
        mail.setTargetObjectId( userId );
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(email_body );

        Messaging.sendEmail(new Messaging.Email[] { mail });

    }    

}