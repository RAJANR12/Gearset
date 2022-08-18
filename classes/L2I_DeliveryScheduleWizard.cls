/**
 *      @author       Blake Poutra
 *      @date         07/08/2019
 *      @description  Delivery Schedule Wizard for DSH and DSL creation
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Blake Poutra                  07/08/2019         Initial Creation
 *      Raj Rajen                     11/20/2019         Refactored to keep things DRY
 *
 */
public class L2I_DeliveryScheduleWizard {

    private class deliveryScheduleLine {

        @AuraEnabled private String  dslId                {get; set;}
        @AuraEnabled private String  dslName              {get; set;}
        @AuraEnabled private String  linkName             {get; set;}
        @AuraEnabled private String  aircraftName         {get; set;}
        @AuraEnabled private Boolean aircraftConfirmation {get; set;}
        @AuraEnabled private String  lineNumber           {get; set;}
        @AuraEnabled private Date    deliveryDate         {get; set;}
        @AuraEnabled private Date    seatEndDate          {get; set;}
        @AuraEnabled private Date    headEndDate          {get; set;}
        @AuraEnabled private Date    outOfWarrantyDate1   {get; set;}
        @AuraEnabled private Date    outOfWarrantyDate2   {get; set;}
        @AuraEnabled private String  createdBy            {get; set;}
        @AuraEnabled private Date    createdDate          {get; set;}

        public deliveryScheduleLine(L2I_DSL__c ldsl) {
            this.dslId                = ldsl.Id;
            this.dslName              = ldsl.Name;
            this.linkName             = '/' + ldsl.Id;
            this.aircraftName         = ldsl.Aircraft__r.Name;
            this.aircraftConfirmation = ldsl.L2I_Aircraft_Confirmation__c;
            this.lineNumber           = ldsl.Line_Number__c;
            this.deliveryDate         = ldsl.Delivery_Date__c;
            this.seatEndDate          = ldsl.Seat_End_Date__c;
            this.headEndDate          = ldsl.Head_End_Date__c;
            this.outOfWarrantyDate1   = ldsl.Out_of_Warranty_Date_1__c;
            this.outOfWarrantyDate2   = ldsl.Out_of_Warranty_Date_2__c;
            this.createdBy            = ldsl.CreatedBy.Name;
            this.createdDate          = Date.valueOf(ldsl.CreatedDate);
        }
    }

    private class deliverySchedule {

        @AuraEnabled private String  objectName          {get; set;}
        @AuraEnabled private String  recordId            {get; set;}
        @AuraEnabled private String  dsId                {get; set;}
        @AuraEnabled private String  dsName              {get; set;}
        @AuraEnabled private String  aircraftName        {get; set;}
        @AuraEnabled private Integer subscriptionTerm    {get; set;}
        @AuraEnabled private String  accountName         {get; set;}
        @AuraEnabled private Integer aircraftQuantity    {get; set;}
        @AuraEnabled private Integer firstClass          {get; set;}
        @AuraEnabled private Integer businessClass       {get; set;}
        @AuraEnabled private Integer premiumEconomyClass {get; set;}
        @AuraEnabled private Integer economyClass        {get; set;}
        @AuraEnabled private String  createdBy           {get; set;}
        @AuraEnabled private Date    createdDate         {get; set;}

        @AuraEnabled private List<deliveryScheduleLine> deliveryScheduleLines {get; set;}

        public deliverySchedule(String recordId, String sObjectName) {
            this.objectName            = sObjectName;
            this.recordId              = recordId;
            this.dsId                  = '';
            this.aircraftQuantity      = 0;
            this.subscriptionTerm      = 0;
            this.firstClass            = 0;
            this.businessClass         = 0;
            this.premiumEconomyClass   = 0;
            this.economyClass          = 0;
            this.deliveryScheduleLines = new List<deliveryScheduleLine>();
        }

        public deliverySchedule(String recordId, String sObjectName, L2I_DSH__c lds) {
            this.recordId              = recordId;
            this.objectName            = sObjectName;
            this.dsId                  = lds.Id;
            this.aircraftQuantity      = Integer.valueOf(lds.Aircraft_Quantity__c);
            this.subscriptionTerm      = Integer.valueOf(lds.Subscription_Term__c);
            this.firstClass            = Integer.valueOf(lds.First_Class__c);
            this.businessClass         = Integer.valueOf(lds.Business_Class__c);
            this.premiumEconomyClass   = Integer.valueOf(lds.Premium_Economy_Class__c);
            this.economyClass          = Integer.valueOf(lds.Economy_Class__c);
            this.dsName                = lds.Name;
            this.aircraftName          = lds.Aircraft_Type__r.Name;
            this.accountName           = lds.Account__r.Name;
            this.createdBy             = lds.CreatedBy.Name;
            this.createdDate           = Date.valueOf(lds.CreatedDate);
            this.deliveryScheduleLines = new List<deliveryScheduleLine>();
        }

    }

    private class DSLGeneratorAttributes {
        private Integer aircraftQuantity         {get; set;}
        private Integer interval                 {get; set;}
        private Date    firstDeliveryDate        {get; set;}
        private Integer headEndDateOffset        {get; set;}
        private Integer seatEndDateOffset        {get; set;}
        private Integer outOfWarrantyDate1Offset {get; set;}
        private Integer outOfWarrantyDate2Offset {get; set;}
        private String  dshId                    {get; set;}
    }

    private static void generateDeliveryScheduleLines(DSLGeneratorAttributes attrs, Integer monthOffset, List<L2I_DSL__c> newDeliveryScheduleLines) {

        Integer aircraftQuantity         = attrs.aircraftQuantity;
        Integer interval                 = attrs.interval;
        Date deliveryDate                = attrs.firstDeliveryDate;
        Integer headEndDateOffset        = attrs.headEndDateOffset;
        Integer seatEndDateOffset        = attrs.seatEndDateOffset;
        Integer outOfWarrantyDate1Offset = attrs.outOfWarrantyDate1Offset;
        Integer outOfWarrantyDate2Offset = attrs.outOfWarrantyDate2Offset;
        String dshId                     = attrs.dshId;

        List<Integer> lstAirplanes = new List<Integer>();
        for (Integer i = 0; i < aircraftQuantity; i++) {
            lstAirplanes.add(i);
        }

        List<List<Integer>> lstShipsets = new List<List<Integer>>();
        Integer perPeriod = interval;

        for (Integer i = 0; i < (lstAirplanes.size() / perPeriod)+1 ; i++) {
            List<Integer> lstTemp = new List<Integer>();
            for (Integer j=(i*perPeriod); (j<(i*perPeriod)+perPeriod) && j<lstAirplanes.size(); j++) {
                lstTemp.add(lstAirplanes.get(j));
            }
            lstShipsets.add(lstTemp);
        }
        //System.debug(lstShipsets);

        Integer monthsToAdd = 0;
        for (List<Integer> ss : lstShipsets) {

            if (ss.size() > 0) {
                for (Integer i = 0; i < ss.size(); i++) {
                    System.debug('ss size: ' + ss.size() + ' - ' + monthsToAdd);

                    Date calcDeliveryDate = deliveryDate.addMonths(Integer.valueOf(monthsToAdd));
                    System.debug('calcDeliveryDate: ' + calcDeliveryDate);
                    String lineNumber = newDeliveryScheduleLines.size()+1 < 10 ? '0' + String.valueOf(newDeliveryScheduleLines.size()+1) : String.valueOf(newDeliveryScheduleLines.size()+1);

                    L2I_DSL__c ndsl = new L2I_DSL__c();

                    ndsl.Delivery_Schedule_Header__c  = dshId;
                    ndsl.Delivery_Date__c             = calcDeliveryDate;
                    ndsl.Head_End_Date__c             = calcDeliveryDate.addMonths(headEndDateOffset);
                    ndsl.Seat_End_Date__c             = calcDeliveryDate.addMonths(seatEndDateOffset);
                    ndsl.Out_of_Warranty_Date_1__c    = outOfWarrantyDate1Offset == null? null : calcDeliveryDate.addMonths(outOfWarrantyDate1Offset);
                    ndsl.Out_of_Warranty_Date_2__c    = outOfWarrantyDate2Offset == null? null : calcDeliveryDate.addMonths(outOfWarrantyDate2Offset);
                    ndsl.Line_Number__c               = lineNumber;
                    ndsl.L2I_Aircraft_Confirmation__c = false;

                    //System.debug('newDeliveryScheduleLine: ' + ndsl);
                    newDeliveryScheduleLines.add(ndsl);
                }

                monthsToAdd += monthOffset;
            }

        }
    }

    private static void getDeliveryScheduleOfCurrentOpportunity(String recordId, Schema.SObjectType sObjectName, List<deliverySchedule> deliverySchedules) {

        Opportunity currentOpp = [select Id,
                                         RecordType.Name,
                                         L2I_Delivery_Schedule__c,
                                         L2I_Parent_Opportunity__c
                                    from Opportunity
                                   where Id = :recordId];

        String currentDeliveryScheduleId = recordId;

        if (currentOpp.RecordType.Name != 'Deal') {
            currentDeliveryScheduleId = currentOpp.L2I_Delivery_Schedule__c;
        }

        List<L2I_DSH__c> deliveryScheduleList = new List<L2I_DSH__c>();
        deliveryScheduleList = [select Id,
                                       Name,
                                       Aircraft_Type__r.Name,
                                       Account__r.Name,
                                       CreatedDate,
                                       CreatedBy.Name,
                                       Aircraft_Quantity__c,
                                       First_Class__c,
                                       Business_Class__c,
                                       Premium_Economy_Class__c,
                                       Economy_Class__c,
                                       Subscription_Term__c
                                  from L2I_DSH__c
                                 where Id = :currentDeliveryScheduleId];

        Set<Id> deliveryScheduleIds = new Set<Id>();

        if (deliveryScheduleList.size() > 0) {
            for (L2I_DSH__c lds : deliveryScheduleList) {
                deliverySchedule ds = new deliverySchedule(recordId, String.valueOf(sObjectName), lds);

                deliverySchedules.add(ds);
                deliveryScheduleIds.add(lds.Id);
            }
        } else {
            deliverySchedule ds = new deliverySchedule(recordId, String.valueOf(sObjectName));

            deliverySchedules.add(ds);
        }

        List<L2I_DSL__c> deliveryScheduleLineList = new List<L2I_DSL__c>();
        Map<Id, List<deliveryScheduleLine>> deliveryScheduleMap = new Map<Id, List<deliveryScheduleLine>>();

        if (deliveryScheduleIds.size() > 0) {

            deliveryScheduleLineList = [select Id,
                                               Name,
                                               Aircraft__r.Name,
                                               L2I_Aircraft_Confirmation__c,
                                               Delivery_Date__c,
                                               CreatedDate,
                                               CreatedBy.Name,
                                               Delivery_Schedule_Header__c,
                                               Line_Number__c,
                                               Seat_End_Date__c,
                                               Head_End_Date__c,
                                               Out_of_Warranty_Date_1__c,
                                               Out_of_Warranty_Date_2__c
                                          from L2I_DSL__c
                                         where Delivery_Schedule_Header__c in :deliveryScheduleIds
                                         order by Delivery_Date__c asc];

            System.debug('deliveryScheduleLineList: ' + deliveryScheduleLineList);

            if (deliveryScheduleLineList.size() > 0) {

                for(L2I_DSL__c ldsl : deliveryScheduleLineList) {
                    if (deliveryScheduleMap.containsKey(ldsl.Delivery_Schedule_Header__c)) {

                        List<deliveryScheduleLine> dsls = deliveryScheduleMap.get(ldsl.Delivery_Schedule_Header__c);
                        deliveryScheduleLine dsl = new deliveryScheduleLine(ldsl);

                        dsls.add(dsl);
                        deliveryScheduleMap.put(ldsl.Delivery_Schedule_Header__c, dsls);

                    } else {

                        List<deliveryScheduleLine> dsls = new List<deliveryScheduleLine>();
                        deliveryScheduleLine dsl = new deliveryScheduleLine(ldsl);

                        dsls.add(dsl);
                        deliveryScheduleMap.put(ldsl.Delivery_Schedule_Header__c, dsls);

                    }
                }

                if (deliverySchedules.size() > 0 && deliveryScheduleMap.size() > 0) {
                    for (Id dslId : deliveryScheduleMap.keyset()) {
                        for (deliverySchedule ds : deliverySchedules) {
                            if (ds.dsId == dslId) {
                                ds.deliveryScheduleLines = deliveryScheduleMap.get(ds.dsId);
                            }
                        }
                    }
                }

            }
        }
    }

    private static void getDeliveryScheduleOfCurrentDSH(String recordId, List<deliverySchedule> deliverySchedules) {

        List<L2I_DSH__c> deliveryScheduleList = new List<L2I_DSH__c>();
        deliveryScheduleList = [select Id,
                                       Name,
                                       Aircraft_Type__r.Name,
                                       Account__r.Name,
                                       CreatedDate,
                                       CreatedBy.Name,
                                       Aircraft_Quantity__c,
                                       First_Class__c,
                                       Business_Class__c,
                                       Premium_Economy_Class__c,
                                       Economy_Class__c,
                                       Subscription_Term__c
                                  from L2I_DSH__c
                                 where Id = :recordId limit 1];

        if (deliveryScheduleList.size() > 0) {

            for (L2I_DSH__c lds : deliveryScheduleList) {

                System.debug('lds: ' + lds);
                deliverySchedule ds = new deliverySchedule(recordId, 'L2I_DSH__c', lds);

                deliverySchedules.add(ds);
                System.debug('ds: ' + ds);

            }

            List<L2I_DSL__c> deliveryScheduleLineList = new List<L2I_DSL__c>();
            Map<Id, List<deliveryScheduleLine>> deliveryScheduleMap = new Map<Id, List<deliveryScheduleLine>>();

            System.debug('recordId: ' + recordId);
            deliveryScheduleLineList = [select Id,
                                               Name,
                                               Aircraft__r.Name,
                                               L2I_Aircraft_Confirmation__c,
                                               Delivery_Date__c,
                                               CreatedDate,
                                               CreatedBy.Name,
                                               Delivery_Schedule_Header__c,
                                               Line_Number__c,
                                               Seat_End_Date__c,
                                               Head_End_Date__c,
                                               Out_of_Warranty_Date_1__c,
                                               Out_of_Warranty_Date_2__c
                                          from L2I_DSL__c
                                         where Delivery_Schedule_Header__c = :recordId
                                         order by Delivery_Date__c asc];

            System.debug('deliveryScheduleLineList: ' + deliveryScheduleLineList.size() + ' - ' + deliveryScheduleLineList);

            if (deliveryScheduleLineList.size() > 0) {

                for (L2I_DSL__c ldsl : deliveryScheduleLineList) {

                    if (deliveryScheduleMap.containsKey(ldsl.Delivery_Schedule_Header__c)) {

                        System.debug('map contains: ' + ldsl);
                        List<deliveryScheduleLine> dsls = deliveryScheduleMap.get(ldsl.Delivery_Schedule_Header__c);
                        deliveryScheduleLine dsl = new deliveryScheduleLine(ldsl);

                        dsls.add(dsl);
                        deliveryScheduleMap.put(ldsl.Delivery_Schedule_Header__c, dsls);

                    } else {

                        System.debug('map else: ' + ldsl);
                        List<deliveryScheduleLine> dsls = new List<deliveryScheduleLine>();
                        deliveryScheduleLine dsl = new deliveryScheduleLine(ldsl);

                        dsls.add(dsl);
                        deliveryScheduleMap.put(ldsl.Delivery_Schedule_Header__c, dsls);

                    }
                }

                if(deliveryScheduleMap.size() > 0) {
                    for(Id dslId : deliveryScheduleMap.keyset()) {
                        for(deliverySchedule ds : deliverySchedules) {
                            if(ds.dsId == dslId){
                                System.debug('added ds: ' + ds);
                                ds.deliveryScheduleLines = deliveryScheduleMap.get(ds.dsId);
                            }
                        }
                    }
                }
            }
        }
    }

    private static void getDeliveryScheduleOfSelectedDSH(String recordId, String deliveryScheduleId, List<deliverySchedule> deliverySchedules) {

        List<L2I_DSH__c> deliveryScheduleList = new List<L2I_DSH__c>();
        deliveryScheduleList = [select Id,
                                       Name,
                                       Aircraft_Type__r.Name,
                                       Account__r.Name,
                                       CreatedDate,
                                       CreatedBy.Name,
                                       Aircraft_Quantity__c,
                                       First_Class__c,
                                       Business_Class__c,
                                       Premium_Economy_Class__c,
                                       Economy_Class__c,
                                       Subscription_Term__c
                                  from L2I_DSH__c
                                 where Id = :deliveryScheduleId limit 1];

        Set<Id> deliveryScheduleIds = new Set<Id>();

        if (deliveryScheduleList.size() > 0) {

            for (L2I_DSH__c lds : deliveryScheduleList) {
                System.debug('lds: ' + lds);
                deliverySchedule ds = new deliverySchedule(recordId, 'L2I_DSH__c', lds);

                deliverySchedules.add(ds);
                System.debug('ds: ' + ds);
                deliveryScheduleIds.add(lds.Id);
            }

        } else {
            deliverySchedule ds = new deliverySchedule(recordId, 'L2I_DSH__c');

            deliverySchedules.add(ds);
        }

        List<L2I_DSL__c> deliveryScheduleLineList = new List<L2I_DSL__c>();
        Map<Id, List<deliveryScheduleLine>> deliveryScheduleMap = new Map<Id, List<deliveryScheduleLine>>();

        if (deliveryScheduleIds.size() > 0) {

            System.debug('deliveryScheduleIds: ' + deliveryScheduleIds);
            deliveryScheduleLineList = [select Id,
                                               Name,
                                               Aircraft__r.Name,
                                               L2I_Aircraft_Confirmation__c,
                                               Delivery_Date__c,
                                               CreatedDate,
                                               CreatedBy.Name,
                                               Delivery_Schedule_Header__c,
                                               Line_Number__c,
                                               Seat_End_Date__c,
                                               Head_End_Date__c,
                                               Out_of_Warranty_Date_1__c,
                                               Out_of_Warranty_Date_2__c
                                          from L2I_DSL__c
                                         where Delivery_Schedule_Header__c in :deliveryScheduleIds
                                         order by Delivery_Date__c asc];

            System.debug('deliveryScheduleLineList: ' + deliveryScheduleLineList);

            if (deliveryScheduleLineList.size() > 0) {

                for (L2I_DSL__c ldsl : deliveryScheduleLineList) {
                    if (deliveryScheduleMap.containsKey(ldsl.Delivery_Schedule_Header__c)) {

                        List<deliveryScheduleLine> dsls = deliveryScheduleMap.get(ldsl.Delivery_Schedule_Header__c);
                        deliveryScheduleLine dsl = new deliveryScheduleLine(ldsl);

                        dsls.add(dsl);
                        deliveryScheduleMap.put(ldsl.Delivery_Schedule_Header__c, dsls);

                    } else {

                        List<deliveryScheduleLine> dsls = new List<deliveryScheduleLine>();
                        deliveryScheduleLine dsl = new deliveryScheduleLine(ldsl);

                        dsls.add(dsl);
                        deliveryScheduleMap.put(ldsl.Delivery_Schedule_Header__c, dsls);

                    }
                }

                if (deliverySchedules.size() > 0 && deliveryScheduleMap.size() > 0) {
                    for (Id dslId : deliveryScheduleMap.keyset()) {
                        for (deliverySchedule ds : deliverySchedules) {
                            if (ds.dsId == dslId){
                                ds.deliveryScheduleLines = deliveryScheduleMap.get(ds.dsId);
                            }
                        }
                    }
                }
            }
        }
    }

    @AuraEnabled
    public static List<deliverySchedule> getDeliverySchedules(String recordId, String deliveryScheduleId) {

        List<deliverySchedule> deliverySchedules = new List<deliverySchedule>();

        if (recordId != null) {

            Id sObjectId = recordId;
            Schema.SObjectType sObjectName  = sObjectId.getSobjectType();
            System.debug('sObjectName: ' + String.valueOf(sObjectName));

            if (String.valueOf(sObjectName) == 'Opportunity') {
                // Code called from the "Delivery Schedule" tab in the Sales Opportunity page layout.
                // Here the recordId is the Id of the Opportunity instance

                getDeliveryScheduleOfCurrentOpportunity(recordId, sObjectName, deliverySchedules);

            } else {
                // Code called from the "Delivery Schedule Lines" Lightning Component action that lives on the
                // Delivery Schedule Header page layout. Here the recordId is the Id of the L2I_DSH__c instance
                // This results in DSLs being shown in modal window.

                getDeliveryScheduleOfCurrentDSH(recordId, deliverySchedules);
            }

        } else {
            // Code to handle User selected DSH from all existing delivery schedule headers associated with the deal opportunity

            getDeliveryScheduleOfSelectedDSH(recordId, deliveryScheduleId, deliverySchedules);

        }

        System.debug('deliverySchedules: ' + deliverySchedules);
        return deliverySchedules;

    }

    private class availableDeliverySchedule {
        @AuraEnabled private String label {get; set;}
        @AuraEnabled private String value {get; set;}
        @AuraEnabled private Boolean selected {get; set;}
    }

    @AuraEnabled
    public static List<availableDeliverySchedule> getAvailableDeliverySchedules(String recordId) {

        List<availableDeliverySchedule> dsList = new List<availableDeliverySchedule>();

        if (recordId != null) {

            Id sObjectId = recordId;
            Schema.SObjectType sObjectName  = sObjectId.getsobjecttype();
            System.debug('sObjectName: ' + String.valueOf(sObjectName));

            if(String.valueOf(sObjectName) == 'Opportunity'){

                Opportunity currentOpp = [select Id,
                                                 RecordType.Name,
                                                 L2I_Parent_Opportunity__c,
                                                 AccountId
                                            from Opportunity
                                           where Id = :recordId];

                String dealOpp = recordId;

                if (currentOpp.RecordType.Name != 'Deal') {
                    dealOpp = currentOpp.L2I_Parent_Opportunity__c;
                }

                List<L2I_DSH__c> deliveryScheduleList = new List<L2I_DSH__c>();
                //[RR]deliveryScheduleList = [SELECT Id, Name, Aircraft_Type__r.Name, Account__r.Name, CreatedDate, CreatedBy.Name,
                //[RR]                        Aircraft_Quantity__c, First_Class__c, Business_Class__c, Premium_Economy_Class__c,
                //[RR]                        Economy_Class__c, Subscription_Term__c
                //[RR]                        FROM L2I_DSH__c
                //[RR]                        WHERE Account__c = :currentOpp.AccountId];

                deliveryScheduleList = [select Id,
                                               Name,
                                               Aircraft_Type__r.Name,
                                               Account__r.Name,
                                               CreatedDate,
                                               CreatedBy.Name,
                                               Aircraft_Quantity__c,
                                               First_Class__c,
                                               Business_Class__c,
                                               Premium_Economy_Class__c,
                                               Economy_Class__c,
                                               Subscription_Term__c
                                          from L2I_DSH__c
                                         where Deal_Opportunity__c = :dealOpp];

                System.debug('deliveryScheduleList: ' + deliveryScheduleList);

                if (deliveryScheduleList.size() > 0){
                    for (L2I_DSH__c lds : deliveryScheduleList) {
                        availableDeliverySchedule ads = new availableDeliverySchedule();

                        ads.label    = lds.Name + ', Qty: ' + lds.Aircraft_Quantity__c + ', Type: ' + lds.Aircraft_Type__r.Name;
                        ads.value    = lds.Id;
                        ads.selected = false;

                        System.debug('ads: ' + ads);
                        dsList.add(ads);
                    }
                }
            }
        }

        System.debug('dsList: ' + dsList);
        return dsList;

    }

    @AuraEnabled
    public static String createDeliveryScheduleHeader(String deliveryScheduleInformation) {

        System.debug('deliveryScheduleInformation: ' + deliveryScheduleInformation);

        //List<deliverySchedule> deliverySchedules = new List<deliverySchedule>();
        String newDeliveryScheduleId = '';

        Map<String, Object> outerMap = (Map<String, Object>) JSON.deserializeUntyped(deliveryScheduleInformation);
        Map<String, Object> dsMap = (Map<String, Object>) outerMap.get('data');
        System.debug('dsMap: ' + dsMap);

        String recordId = String.valueOf(dsMap.get('recordId'));
        System.debug('recordId: ' + recordId);

        List<Opportunity> currentOppList = new List<Opportunity>();
        currentOppList = [select Id,
                                 RecordType.Name,
                                 L2I_Parent_Opportunity__c,
                                 AccountId,
                                 Account.Name,
                                 L2I_Delivery_Schedule__c
                            from Opportunity
                           where Id = :recordId];

        String dealOpp = recordId;

        if (currentOppList.size() > 0) {

            if (currentOppList[0].RecordType.Name != 'Deal') {
                dealOpp = currentOppList[0].L2I_Parent_Opportunity__c;
            }

            L2I_DSH__c newDeliverySchedule = new L2I_DSH__c(Deal_Opportunity__c      = dealOpp,
                                                            Account__c               = currentOppList[0].AccountId,
                                                            Aircraft_Type__c         = String.valueOf(dsMap.get('aircraftType')),
                                                            Aircraft_Quantity__c     = Integer.valueOf(dsMap.get('aircraftQuantity')),
                                                            Subscription_Term__c     = Integer.valueOf(dsMap.get('subscriptionTerm')),
                                                            First_Class__c           = Integer.valueOf(dsMap.get('firstClass')),
                                                            Business_Class__c        = Integer.valueOf(dsMap.get('businessClass')),
                                                            Premium_Economy_Class__c = Integer.valueOf(dsMap.get('premiumEconomyClass')),
                                                            Economy_Class__c         = Integer.valueOf(dsMap.get('economyClass')));

            try {
                System.debug('newDeliverySchedule: ' + newDeliverySchedule);
                insert newDeliverySchedule;
                newDeliveryScheduleId = newDeliverySchedule.Id;

                currentOppList[0].L2I_Delivery_Schedule__c = newDeliveryScheduleId;
                update currentOppList[0];
            } catch(DmlException e) {
                System.debug('error: ' + e);
                throw new AuraHandledException('There was an error while trying to save the record: ' + e.getMessage());
            }
        }

		System.debug('newDeliveryScheduleId: ' + newDeliveryScheduleId);
       	return newDeliveryScheduleId;

    }

    @AuraEnabled
    public static List<deliveryScheduleLine> createDeliveryScheduleLines(String deliveryScheduleInformation, Date deliveryDate, Integer interval, String deliveryInterval) {

        System.debug('deliveryScheduleInformation: ' + deliveryScheduleInformation);
        System.debug('deliveryDate: ' + deliveryDate + ', interval: ' + interval + ', deliveryInterval: ' + deliveryInterval);

        List<deliveryScheduleLine> deliveryScheduleLines = new List<deliveryScheduleLine>();

        if (deliveryDate == null) {
            throw new AuraHandledException('Please specify the First Aircraft Delivery Date');
        }

        Map<String, Object> outerMap = (Map<String, Object>) JSON.deserializeUntyped(deliveryScheduleInformation);
        Map<String, Object> dsMap = (Map<String, Object>) outerMap.get('data');
        System.debug('dsMap: ' + dsMap);

        String recordId = String.valueOf(dsMap.get('dsId'));
        System.debug('recordId: ' + recordId);

        Integer headEndDateOffset = -3;
        Integer seatEndDateOffset = -6;
        Integer outOfWarrantyDate1Offset = null;  // should be null if it is unspecified via the UI
        Integer outOfWarrantyDate2Offset = null;  // should be null if it is unspecified via the UI

        if (dsMap.containsKey('headEndDateOffset')) {
            headEndDateOffset = Integer.valueOf(dsMap.get('headEndDateOffset')) * -1;  // we need negative offset
        }
        if (dsMap.containsKey('seatEndDateOffset')) {
            seatEndDateOffset = Integer.valueOf(dsMap.get('seatEndDateOffset')) * -1;  // we need negative offset
        }
        if (dsMap.containsKey('outOfWarrantyDate1Offset')) {
            outOfWarrantyDate1Offset = Integer.valueOf(dsMap.get('outOfWarrantyDate1Offset'));
        }
        if (dsMap.containsKey('outOfWarrantyDate2Offset')) {
            outOfWarrantyDate2Offset = Integer.valueOf(dsMap.get('outOfWarrantyDate2Offset'));
        }


        List<L2I_DSH__c> deliveryScheduleList = new List<L2I_DSH__c>();
        deliveryScheduleList = [select Id,
                                       Name,
                                       Aircraft_Quantity__c,
                                       Aircraft_Type__r.Name,
                                       Account__r.Name,
                                       CreatedDate,
                                       CreatedBy.Name
                                  from L2I_DSH__c
                                 where Id = :recordId];

        System.debug('There are ' + deliveryScheduleList.size() + ' existing Delivery Schedule.');

        if (deliveryScheduleList.size() > 0) {

            Integer aircraftQuantity = Integer.valueOf(deliveryScheduleList[0].Aircraft_Quantity__c);
            System.debug('aircraftQuantity: ' + aircraftQuantity);

            DSLGeneratorAttributes genAttrs = new DSLGeneratorAttributes();

            genAttrs.aircraftQuantity         = aircraftQuantity;
            genAttrs.interval                 = interval;
            genAttrs.firstDeliveryDate        = deliveryDate;
            genAttrs.headEndDateOffset        = headEndDateOffset;
            genAttrs.seatEndDateOffset        = seatEndDateOffset;
            genAttrs.outOfWarrantyDate1Offset = outOfWarrantyDate1Offset;
            genAttrs.outOfWarrantyDate2Offset = outOfWarrantyDate2Offset;
            genAttrs.dshId                    = String.valueOf(dsMap.get('dsId'));

            List<L2I_DSL__c> newDeliveryScheduleLines = new List<L2I_DSL__c>();

            Integer monthOffset = null;
            switch on deliveryInterval {
                when 'Same Date' {
                    monthOffset = 0;
                }
                when 'Every Month' {
                    monthOffset = 1;
                }
                when 'Every Other Month' {
                    monthOffset = 2;
                }
                when 'Quarterly' {
                    monthOffset = 3;
                }
                when 'Yearly' {
                    monthOffset = 12;
                }
            }

            generateDeliveryScheduleLines(genAttrs, monthOffset, newDeliveryScheduleLines);

            if (newDeliveryScheduleLines.size() > 0) {

                try {
                    insert newDeliveryScheduleLines;
                } catch(DmlException e) {
                    System.debug('error: ' + e);
                    throw new AuraHandledException('There was an error while trying to save the record: ' + e.getMessage());
                } finally {

                    List<Id> dslsIds = new List<Id>();
                    List<deliveryScheduleLine> dsls = new List<deliveryScheduleLine>();
                    System.debug('newDeliveryScheduleLines: ' + newDeliveryScheduleLines);

                    for (L2I_DSL__c nds : newDeliveryScheduleLines) {
                        dslsIds.add(nds.Id);
                    }

                    if (dslsIds.size() > 0) {

                        List<L2I_DSL__c> newInsertDSL = [select Id,
                                                                Name,
                                                                Aircraft__r.Name,
                                                                L2I_Aircraft_Confirmation__c,
                                                                Delivery_Date__c,
                                                                CreatedBy.Name,
                                                                CreatedDate,
                                                                Line_Number__c,
                                                                Head_End_Date__c,
                                                                Seat_End_Date__c,
                                                                Out_of_Warranty_Date_1__c,
                                                                Out_of_Warranty_Date_2__c
                                                           from L2I_DSL__c
                                                          where Id in :dslsIds
                                                          order BY Delivery_Date__c asc];

                        for (L2I_DSL__c nds : newInsertDSL) {
                            deliveryScheduleLine dsl = new deliveryScheduleLine(nds);
                            deliveryScheduleLines.add(dsl);
                        }

                        try {
                            update newInsertDSL;
                        } catch (DmlException e) {
                            System.debug('error: ' + e);
                            throw new AuraHandledException('There was an error while trying to save the record: ' + e.getMessage());
                        }

                    }
                }

            }

        }

        System.debug('deliveryScheduleLines: ' + deliveryScheduleLines);
       	return deliveryScheduleLines;

    }

    /**
    @AuraEnabled
    public static String old_deleteDeliveryScheduleLines(String deliveryScheduleLinesToDelete) {

        System.debug('deliveryScheduleLinesToDelete: ' + deliveryScheduleLinesToDelete);

        Map<String, Object> outerMap = (Map<String, Object>) JSON.deserializeUntyped(deliveryScheduleLinesToDelete);
        List<Map<String, Object>> deleteList = new List<Map<String, Object>>();
        List<Object> deleteData = (List<Object>) outerMap.get('data');
        for(Object obj: deleteData){
            deleteList.add((Map<String, Object>)obj);
        }
        System.debug('deleteList: ' + deleteList);

        Set<Id> dslIds = new Set<Id>();

        if (deleteList.size() > 0) {

            for(Map<String, Object> dMap : deleteList) {

                System.debug('dMap id: ' + String.valueOf(dMap.get('dslId')));
                dslIds.add(String.valueOf(dMap.get('dslId')));

            }

            if(dslIds.size() > 0) {

                List<L2I_DSL__c> deleteDeliveryScheduleLines = new List<L2I_DSL__c>();
                deleteDeliveryScheduleLines = [select Id
                                                 from L2I_DSL__c
                                                where Id IN :dslIds];

                if (deleteDeliveryScheduleLines.size() > 0) {
                    try {
                        System.debug('deleteDeliveryScheduleLines: ' + deleteDeliveryScheduleLines);
                        delete deleteDeliveryScheduleLines;
                    } catch (DmlException e) {
                        System.debug('error: ' + e);
                        throw new AuraHandledException('There was an error while trying to save the record: ' + e.getMessage());
                    }
                }

            }
        }

        return 'Success';

    }
    **/

    @AuraEnabled
    public static String saveDeliveryScheduleToOpportunity(String recordId, String deliveryScheduleId) {

        List<Opportunity> currentOppList = new List<Opportunity>();
        currentOppList = [select Id,
                                 RecordType.Name,
                                 L2I_Parent_Opportunity__c,
                                 AccountId,
                                 Account.Name,
                                 L2I_Delivery_Schedule__c
                            from Opportunity
                           where Id = :recordId];

        currentOppList[0].L2I_Delivery_Schedule__c = deliveryScheduleId;

        try {
            update currentOppList[0];
        } catch (DmlException e) {
            System.debug('error: ' + e);
            throw new AuraHandledException('There was an error while trying to save the record: ' + e.getMessage());
        }

        return deliveryScheduleId;

    }

    @AuraEnabled
    public static void pushPullDeliveryDates(String method, String months, List<String> dslIds) {
        System.debug('====== Method Type : ' + method);
        System.debug('====== Months : ' + months);
        //for (String dslId : dslIds) {
        //    System.debug('    ======== DSL Id :' + dslId);
        //}
        Integer monthOffset = null;
        Integer monthMultiplier = null;
        try {
            monthOffset = Integer.valueOf(months);
        } catch (TypeException te) {
            throw new AuraHandledException('Error: Please specify a valid "Number of months" value');
        }

        switch on method {
            when '+1' {
                monthMultiplier = 1;
            }
            when '-1' {
                monthMultiplier = -1;
            }
        }

        List<L2I_DSL__c> affectedDsls = [select Id,
                                                Delivery_Date__c,
                                                Head_End_Date__c,
                                                Seat_End_Date__c,
                                                Out_of_Warranty_Date_1__c,
                                                Out_of_Warranty_Date_2__c
                                           from L2I_DSL__c
                                          where Id in :dslIds];

        if (affectedDsls.isEmpty()) {
            return;
        }

        monthOffset = monthMultiplier * monthOffset;
        for (L2I_DSL__c aDsl : affectedDsls) {
            if (aDsl.Delivery_Date__c != null) {
                aDsl.Delivery_Date__c = aDsl.Delivery_Date__c.addMonths(monthOffset);
            }
            if (aDsl.Head_End_Date__c != null) {
                aDsl.Head_End_Date__c = aDsl.Head_End_Date__c.addMonths(monthOffset);
            }
            if (aDsl.Seat_End_Date__c != null) {
                aDsl.Seat_End_Date__c = aDsl.Seat_End_Date__c.addMonths(monthOffset);
            }
            if (aDsl.Out_of_Warranty_Date_1__c != null) {
                aDsl.Out_of_Warranty_Date_1__c = aDsl.Out_of_Warranty_Date_1__c.addMonths(monthOffset);
            }
            if (aDsl.Out_of_Warranty_Date_2__c != null) {
                aDsl.Out_of_Warranty_Date_2__c = aDsl.Out_of_Warranty_Date_2__c.addMonths(monthOffset);
            }
        }

        try {
            update affectedDsls;
        } catch (DmlException dmle) {
            System.debug('error: ' + dmle);
            throw new AuraHandledException('There was an error while updating DSL record(s): ' + dmle.getMessage());
        }

    }

    @AuraEnabled
    public static void deleteDeliveryScheduleLines(List<String> dslIds) {

        List<L2I_DSL__c> affectedDsls = [select Id
                                           from L2I_DSL__c
                                          where Id in :dslIds];

        if (affectedDsls.isEmpty()) {
            return;
        }

        try {
            delete affectedDsls;
        } catch (DmlException dmle) {
            System.debug('error: ' + dmle);
            throw new AuraHandledException('There was an error while deleting DSL record(s): ' + dmle.getMessage());
        }

    }

}