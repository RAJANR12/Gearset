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
 *      Sarah Kennedy                 01/03/2020         Created for LWC
 *      Andy Fang                     02/19/2020         Switch field name from L2I_Aircraft_Quantity__c to
 *                                                       L2I_AircraftQuantity__c (US1425)
 *      Sarah Kennedy                 06/12/2020         US1981, US2018, US2048, US1977, US2010, US2002, DE482
 */
public class L2I_DeliverySchedLWCController {

    private class deliveryScheduleLine {

        @AuraEnabled public String dslId { get; set; }
        @AuraEnabled public String dslName { get; set; }
        @AuraEnabled public String linkName { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String origOpp { get; set; }
        @AuraEnabled public String origOppId { get; set; }
        @AuraEnabled public String origOppLink { get; set; }
        @AuraEnabled public String aircraftName { get; set; }
        @AuraEnabled public Boolean aircraftConfirmation { get; set; }
        @AuraEnabled public String aircraftId { get; set; }
        @AuraEnabled public String aircraftLink { get; set; }
        @AuraEnabled public L2I_Aircraft__c aircraft { get; set; }
        @AuraEnabled public String lineNumber { get; set; }
        @AuraEnabled public Date deliveryDate { get; set; }
        @AuraEnabled public Date seatEndDate { get; set; }
        @AuraEnabled public Date headEndDate { get; set; }
        @AuraEnabled public Date outOfWarrantyDate1 { get; set; }
        @AuraEnabled public Date outOfWarrantyDate2 { get; set; }
        @AuraEnabled public String createdBy { get; set; }
        @AuraEnabled public Date createdDate { get; set; }
        @AuraEnabled public String ifecDSLId { get; set; }
        @AuraEnabled public Date ifecDSLDeliveryDate { get; set; }
        @AuraEnabled public Date ifecDSLForecastedDeliveryDate { get; set; }
        @AuraEnabled public String ifecDSLAircraftName { get; set; }
        @AuraEnabled public String ifecDSLAircraftLink { get; set; }
        @AuraEnabled public Boolean cannotDelete { get; set; }
        @AuraEnabled public Boolean cannotChangeConfirm { get; set; }
        @AuraEnabled public Boolean ordered { get; set; }
        @AuraEnabled public Boolean isOpenStage { get; set; }

        public deliveryScheduleLine(L2I_DSL__c ldsl) {
            this.dslId = ldsl.Id;
            this.dslName = ldsl.Name;
            this.linkName = '/' + ldsl.Id;
            this.aircraftName = ldsl.Aircraft__r.Name;
            this.aircraftId = ldsl.Aircraft__c;
            this.aircraftLink = ldsl.Aircraft__c == null ? '' : '/' + ldsl.Aircraft__c;
            this.aircraftConfirmation = ldsl.L2I_Aircraft_Confirmation__c;
            this.lineNumber = ldsl.Line_Number__c;
            this.deliveryDate = ldsl.Delivery_Date__c;
            this.seatEndDate = ldsl.Seat_End_Date__c;
            this.headEndDate = ldsl.Head_End_Date__c;
            this.outOfWarrantyDate1 = ldsl.Out_of_Warranty_Date_1__c;
            this.outOfWarrantyDate2 = ldsl.Out_of_Warranty_Date_2__c;
            this.createdBy = ldsl.CreatedBy.Name;
            this.createdDate = Date.valueOf(ldsl.CreatedDate);
            this.ifecDSLId = ldsl.IFEC_DSL__c;
            this.ifecDSLDeliveryDate = ldsl.IFEC_Delivery_Date__c;
            this.ifecDSLForecastedDeliveryDate = ldsl.Forecasted_Delivery_Date__c;
            this.ifecDSLAircraftName = ldsl.Aircraft_Identifier__c;
            this.ifecDSLAircraftLink = '';
            if (ldsl.IFEC_DSL__c != null){
                if (ldsl.IFEC_DSL__r.Aircraft__c != null){
                    this.ifecDSLAircraftLink = '/' + ldsl.IFEC_DSL__r.Aircraft__c;
                }
            } else {
                if (ldsl.Aircraft__c != null){
                    this.ifecDSLAircraftLink = '/' + ldsl.Aircraft__c;
                }
            }
            this.status = ldsl.Status__c;
            this.origOpp = ldsl.Original_Opportunity__r.L2I_Opportunity_Number__c;
            this.origOppLink = '/' + ldsl.Original_Opportunity__c;
            this.origOppId = ldsl.Original_Opportunity__c;
            this.cannotDelete = false;
            this.cannotChangeConfirm = false;
            this.ordered = false;
            this.isOpenStage = true;
        }

        public deliveryScheduleLine(L2I_DSL__c ldsl, Boolean cannotDelete, Boolean cannotChangeConfirm, Boolean ordered, Boolean isOpenStage) {
            this.dslId = ldsl.Id;
            this.dslName = ldsl.Name;
            this.linkName = '/' + ldsl.Id;
            this.aircraftName = ldsl.Aircraft__r.Name;
            this.aircraftId = ldsl.Aircraft__c;
            this.aircraftLink = ldsl.Aircraft__c == null ? '' : '/' + ldsl.Aircraft__c;
            this.aircraftConfirmation = ldsl.L2I_Aircraft_Confirmation__c;
            this.lineNumber = ldsl.Line_Number__c;
            this.deliveryDate = ldsl.Delivery_Date__c;
            this.seatEndDate = ldsl.Seat_End_Date__c;
            this.headEndDate = ldsl.Head_End_Date__c;
            this.outOfWarrantyDate1 = ldsl.Out_of_Warranty_Date_1__c;
            this.outOfWarrantyDate2 = ldsl.Out_of_Warranty_Date_2__c;
            this.createdBy = ldsl.CreatedBy.Name;
            this.createdDate = Date.valueOf(ldsl.CreatedDate);
            this.ifecDSLId = ldsl.IFEC_DSL__c;
            this.ifecDSLDeliveryDate = ldsl.IFEC_Delivery_Date__c;
            this.ifecDSLForecastedDeliveryDate = ldsl.Forecasted_Delivery_Date__c;
            this.ifecDSLAircraftName = ldsl.Aircraft_Identifier__c;
            this.ifecDSLAircraftLink = '';
            if (ldsl.IFEC_DSL__c != null){
                if (ldsl.IFEC_DSL__r.Aircraft__c != null){
                    this.ifecDSLAircraftLink = '/' + ldsl.IFEC_DSL__r.Aircraft__c;
                }
            } else {
                if (ldsl.Aircraft__c != null){
                    this.ifecDSLAircraftLink = '/' + ldsl.Aircraft__c;
                }
            }
            this.status = ldsl.Status__c;
            this.origOpp = ldsl.Original_Opportunity__r.L2I_Opportunity_Number__c;
            this.origOppLink = '/' + ldsl.Original_Opportunity__c;
            this.origOppId = ldsl.Original_Opportunity__c;
            this.cannotDelete = cannotDelete;
            this.cannotChangeConfirm = cannotChangeConfirm;
            this.ordered = ordered;
            this.isOpenStage = isOpenStage;
        }
    }

    private class deliverySchedule {

        @AuraEnabled public String objectName { get; set; }
        @AuraEnabled public String recordId { get; set; }
        @AuraEnabled public String dsId { get; set; }
        @AuraEnabled public String dsName { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public Opportunity oppty { get; set; }
        @AuraEnabled public String createdBy { get; set; }
        @AuraEnabled public Date createdDate { get; set; }
        @AuraEnabled public Decimal deliveryDateOffset { get; set; }

        @AuraEnabled public List<deliveryScheduleLine> deliveryScheduleLines { get; set; }

        public deliverySchedule(String recordId, String sObjectName, Opportunity oppty) {
            this.objectName = sObjectName;
            this.recordId = recordId;
            this.dsId = '';
            this.oppty = oppty;
            this.deliveryScheduleLines = new List<deliveryScheduleLine>();
        }

        public deliverySchedule(String recordId, String sObjectName, Opportunity oppty, L2I_DSH__c lds) {
            this.recordId = recordId;
            this.objectName = sObjectName;
            this.dsId = lds.Id;
            this.oppty = oppty;
            this.dsName = lds.Name;
            this.accountName = lds.Account__r.Name;
            this.createdBy = lds.CreatedBy.Name;
            this.createdDate = Date.valueOf(lds.CreatedDate);
            this.deliveryDateOffset = lds.Delivery_Date_Offset__c;
            this.deliveryScheduleLines = new List<deliveryScheduleLine>();
        }
    }

    private class DSLGeneratorAttributes {
        private Integer aircraftQuantity { get; set; }
        private Integer interval { get; set; }
        private Date firstDeliveryDate { get; set; }
        private Integer headEndDateOffset { get; set; }
        private Integer seatEndDateOffset { get; set; }
        private Integer outOfWarrantyDate1Offset { get; set; }
        private Integer outOfWarrantyDate2Offset { get; set; }
        private String dshId { get; set; }
        private String opptyId { get; set; }
    }

    private static void generateDeliveryScheduleLines(DSLGeneratorAttributes attrs, Integer monthOffset, List<L2I_DSL__c> newDeliveryScheduleLines) {
        System.debug('*** attrs ' + attrs);
        Integer aircraftQuantity = attrs.aircraftQuantity;
        Integer interval = attrs.interval;
        Date deliveryDate = attrs.firstDeliveryDate;
        Integer headEndDateOffset = attrs.headEndDateOffset;
        Integer seatEndDateOffset = attrs.seatEndDateOffset;
        Integer outOfWarrantyDate1Offset = attrs.outOfWarrantyDate1Offset;
        Integer outOfWarrantyDate2Offset = attrs.outOfWarrantyDate2Offset;
        String dshId = attrs.dshId;
        String opptyId = attrs.opptyId;
        Integer highLineNumber = 0;
        // find the highest line number
        for (L2I_DSL__c currentLine : [SELECT Id, Line_Number__c FROM L2I_DSL__c WHERE Delivery_Schedule_Header__c = :dshId]) {
            if (currentLine.Line_Number__c.isNumeric()) {
                if (Integer.valueOf(currentLine.Line_Number__c) > highLineNumber) {
                    highLineNumber = Integer.valueOf(currentLine.Line_Number__c);
                }
            }
        }
        System.debug('*** highLineNumber ' + highLineNumber);

        List<Integer> lstAirplanes = new List<Integer>();
        for (Integer i = 0; i < aircraftQuantity; i++) {
            lstAirplanes.add(i);
        }

        List<List<Integer>> lstShipsets = new List<List<Integer>>();
        Integer perPeriod = interval;

        for (Integer i = 0; i < (lstAirplanes.size() / perPeriod) + 1; i++) {
            List<Integer> lstTemp = new List<Integer>();
            for (Integer j = (i * perPeriod); (j < (i * perPeriod) + perPeriod) && j < lstAirplanes.size(); j++) {
                lstTemp.add(lstAirplanes.get(j));
            }
            lstShipsets.add(lstTemp);
        }

        Integer monthsToAdd = 0;
        for (List<Integer> ss : lstShipsets) {

            if (ss.size() > 0) {
                for (Integer i = 0; i < ss.size(); i++) {
                    System.debug('ss size: ' + ss.size() + ' - ' + monthsToAdd);

                    String lineNumber;
                    if (highLineNumber + 1 < 10) {
                        lineNumber = '00' + String.valueOf(highLineNumber + 1);
                    } else if (highLineNumber + 1 > 9 && highLineNumber + 1 < 100) {
                        lineNumber = '0' + String.valueOf(highLineNumber + 1);
                    } else {
                        lineNumber = String.valueOf(highLineNumber + 1);
                    }
//                    String lineNumber = highLineNumber + 1 < 10 ? '0' + String.valueOf(highLineNumber + 1) : String.valueOf(highLineNumber + 1);
                    String currentLineNumber = String.valueOf(highLineNumber);
                    highLineNumber++;
                    L2I_DSL__c ndsl = new L2I_DSL__c();
                    ndsl.Delivery_Schedule_Header__c = dshId;
                    ndsl.Original_Opportunity__c = opptyId;
                    System.debug('*** deliveryDate ' + deliveryDate);
                    if (deliveryDate != null) {
                        System.debug('*** b4 calcDeliveryDate ');
                        Date calcDeliveryDate = deliveryDate.addMonths(Integer.valueOf(monthsToAdd));
                        System.debug('calcDeliveryDate: ' + calcDeliveryDate);
                        ndsl.Delivery_Date__c = calcDeliveryDate;
                        ndsl.Head_End_Date__c = headEndDateOffset == null ? null : calcDeliveryDate.addMonths(headEndDateOffset);
                        ndsl.Seat_End_Date__c = seatEndDateOffset == null ? null : calcDeliveryDate.addMonths(seatEndDateOffset);
                        ndsl.Out_of_Warranty_Date_1__c = outOfWarrantyDate1Offset == null ? null : calcDeliveryDate.addMonths(outOfWarrantyDate1Offset);
                        ndsl.Out_of_Warranty_Date_2__c = outOfWarrantyDate2Offset == null ? null : calcDeliveryDate.addMonths(outOfWarrantyDate2Offset);
                    }
                    ndsl.Line_Number__c = lineNumber;
                    ndsl.PT_Line_Number__c = PT_Program_Utils.characterSequencer(currentLineNumber);
                    ndsl.L2I_Aircraft_Confirmation__c = false;

                    newDeliveryScheduleLines.add(ndsl);
                }
                monthsToAdd += monthOffset;
            }
        }
    }

    private static void getDeliveryScheduleOfCurrentOpportunity(String recordId, Schema.SObjectType sObjectName, List<deliverySchedule> deliverySchedules) {
        System.debug('*** in getDeliveryScheduleOfCurrentOpportunity');
        Set<String> excludeStatuses =
              L2I_JSON_Settings.getSpecificSettingCollection('Delivery_Schedule_Settings',
                    'Exclude_Statuses');
        Opportunity currentOpp = [
              SELECT Id,
                    RecordType.DeveloperName,
                    StageName,
                    AccountId,
                    Account.Name,
                    L2I_Delivery_Schedule__c,
                    L2I_Parent_Opportunity__c,
                    L2I_Product_Category__c,
                    L2I_AircraftQuantity__c, (
                    SELECT ID, SBQQ__Ordered__c, SBQQ__Primary__c
                    FROM SBQQ__Quotes2__r
                    WHERE SBQQ__Primary__c = true
                    AND SBQQ__Ordered__c = true
              )
              FROM Opportunity
              WHERE Id = :recordId
        ];

        String currentDeliveryScheduleId = recordId;

        if (currentOpp.RecordType.DeveloperName != 'Deal') {
            currentDeliveryScheduleId = currentOpp.L2I_Delivery_Schedule__c;
        }

        List<L2I_DSH__c> deliveryScheduleList = new List<L2I_DSH__c>();
        deliveryScheduleList = [
              select Id,
                    Name,
                    Account__r.Name,
                    CreatedDate,
                    CreatedBy.Name,
                    Product_Category__c,
                    Delivery_Date_Offset__c,
                    Line_Count__c
              from L2I_DSH__c
              where Id = :currentDeliveryScheduleId
        ];

        Set<Id> deliveryScheduleIds = new Set<Id>();

        if (deliveryScheduleList.size() > 0) {
            for (L2I_DSH__c lds : deliveryScheduleList) {
                deliverySchedule ds = new deliverySchedule(recordId, String.valueOf(sObjectName), currentOpp, lds);

                deliverySchedules.add(ds);
                deliveryScheduleIds.add(lds.Id);
            }
        } else {
            deliverySchedule ds = new deliverySchedule(recordId, String.valueOf(sObjectName), currentOpp);
            deliverySchedules.add(ds);
        }
        System.debug('*** get deliverySchedules ' + deliverySchedules);

        List<L2I_DSL__c> deliveryScheduleLineList = new List<L2I_DSL__c>();
        Map<Id, List<deliveryScheduleLine>> deliveryScheduleMap = new Map<Id, List<deliveryScheduleLine>>();

        if (deliveryScheduleIds.size() > 0) {
            deliveryScheduleLineList = [
                  select Id,
                        Name,
                        Aircraft__r.Name,
                        L2I_Aircraft_Confirmation__c,
                        Aircraft__c,
                        Delivery_Date__c,
                        CreatedDate,
                        CreatedBy.Name,
                        Delivery_Schedule_Header__c,
                        Delivery_Schedule_Header__r.Product_Category__c,
                        Line_Number__c,
                        Seat_End_Date__c,
                        Head_End_Date__c,
                        Out_of_Warranty_Date_1__c,
                        Out_of_Warranty_Date_2__c,
                        IFEC_DSL__c,
                        IFEC_DSL__r.Aircraft__c,
                        IFEC_Delivery_Date__c,
                        Forecasted_Delivery_Date__c,
                        Aircraft_Identifier__c,
                        Original_Opportunity__c,
                        Original_Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c,
                        Original_Opportunity__r.L2I_Opportunity_Number__c,
                        Original_Opportunity__r.StageName,
                        Modified_on_Opportunity__c,
                        Status__c
                  from L2I_DSL__c
                  where Delivery_Schedule_Header__c in :deliveryScheduleIds
                  order by Forecasted_Delivery_Date__c asc, Line_Number__c asc
            ];
            System.debug('deliveryScheduleLineList: ' + deliveryScheduleLineList.size() + ' - ' + deliveryScheduleLineList);
            deliveryScheduleLineList = L2I_DSLService.pruneDSLList(deliveryScheduleLineList, currentOpp.Id);
            System.debug('deliveryScheduleLineList after: ' + deliveryScheduleLineList.size() + ' - ' + deliveryScheduleLineList);

            Map<Id, Id> dslAircraftMap = new Map<Id, Id>();
            if (deliveryScheduleLineList.size() > 0) {
                for (L2I_DSL__c dsl : deliveryScheduleLineList) {
                    if (dsl.L2I_Aircraft_Confirmation__c){
                        if (dsl.Aircraft__c != NULL) {
                            dslAircraftMap.put(dsl.Id, dsl.Aircraft__c);
                        } else if (dsl.IFEC_DSL__r.Aircraft__c != NUll){
                            dslAircraftMap.put(dsl.Id, dsl.IFEC_DSL__r.Aircraft__c );
                        }
                    }
                }
            }
            // see if there are any cases for the DSLs and Aircrafts
            Set<Id> dslWithCases = L2I_DSLService.countCases4DSLAircraft(dslAircraftMap);
            System.debug('*** dslsithCases ' + dslWithCases.size() + ' ' + dslwithCases);

            if (deliveryScheduleLineList.size() > 0) {
                for (L2I_DSL__c ldsl : deliveryScheduleLineList) {
                    Boolean cannotDelete = false;
                    Boolean cannotChangeConfirm = false;
                    Boolean ordered = false;
                    Boolean isOpenStage = false;
                    if (excludeStatuses.contains(ldsl.Status__c)){
                        cannotDelete = true;
                        cannotChangeConfirm = true;
                    }
                    if (ldsl.L2I_Aircraft_Confirmation__c &&
                          dslWithCases.contains(ldsl.Id) ){
                        cannotChangeConfirm = true;
                    }

                    if (ldsl.Original_Opportunity__r.SBQQ__PrimaryQuote__c != null &&
                          ldsl.Original_Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c) {
                        ordered = true;
                    }

                    if (ldsl.Original_Opportunity__r.StageName != 'Pending Close' &&
                          ldsl.Original_Opportunity__r.StageName != 'Closed Won' &&
                          ldsl.Original_Opportunity__r.StageName != 'Cancelled' &&
                          ldsl.Original_Opportunity__r.StageName != 'Closed Lost' &&
                          ldsl.Original_Opportunity__r.StageName != 'No Bid' &&
                          ldsl.Original_Opportunity__r.StageName != 'Closed') {
                        isOpenStage = true;
                    }

                    if (deliveryScheduleMap.containsKey(ldsl.Delivery_Schedule_Header__c)) {

                        List<deliveryScheduleLine> dsls = deliveryScheduleMap.get(ldsl.Delivery_Schedule_Header__c);
                        deliveryScheduleLine dsl = new deliveryScheduleLine(ldsl, cannotDelete, cannotChangeConfirm, ordered, isOpenStage );

                        dsls.add(dsl);
                        deliveryScheduleMap.put(ldsl.Delivery_Schedule_Header__c, dsls);
                        System.debug('*** ldsl dsl ' + dsl);

                    } else {

                        List<deliveryScheduleLine> dsls = new List<deliveryScheduleLine>();
                        deliveryScheduleLine dsl = new deliveryScheduleLine(ldsl, cannotDelete, cannotChangeConfirm, ordered, isOpenStage );

                        dsls.add(dsl);
                        deliveryScheduleMap.put(ldsl.Delivery_Schedule_Header__c, dsls);
                        System.debug('*** ldsl dsl ' + dsl);
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

    @AuraEnabled
    public static List<deliverySchedule> getDeliverySchedules(String recordId, String deliveryScheduleId) {

        List<deliverySchedule> deliverySchedules = new List<deliverySchedule>();

        if (recordId != null) {

            Id sObjectId = recordId;
            Schema.SObjectType sObjectName = sObjectId.getSobjectType();
            System.debug('sObjectName: ' + String.valueOf(sObjectName));

            if (String.valueOf(sObjectName) == 'Opportunity') {
// Code called from the "Delivery Schedule" tab in the Sales Opportunity page layout.
// Here the recordId is the Id of the Opportunity instance
                System.debug('*** calling getDeliveryScheduleOfCurrentOpportunity');
                getDeliveryScheduleOfCurrentOpportunity(recordId, sObjectName, deliverySchedules);
            }
        }

        System.debug('deliverySchedules: ' + deliverySchedules);
        return deliverySchedules;
    }

    private class availableDeliverySchedule {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
    }

    @AuraEnabled
    public static String createDeliveryScheduleHeader(String deliveryScheduleInformation) {
        System.debug('deliveryScheduleInformation: ' + deliveryScheduleInformation);

        String newDeliveryScheduleId = '';
        Map<String, Object> outerMap = (Map<String, Object>) JSON.deserializeUntyped(deliveryScheduleInformation);
        Map<String, Object> dsMap = (Map<String, Object>) outerMap.get('data');
        System.debug('dsMap: ' + dsMap);

        String recordId = String.valueOf(dsMap.get('recordId'));
        System.debug('recordId: ' + recordId);

        List<Opportunity> currentOppList = new List<Opportunity>();
        currentOppList = [
              SELECT Id,
                    RecordType.DeveloperName,
                    L2I_Parent_Opportunity__c,
                    StageName,
                    AccountId,
                    Account.Name,
                    L2I_Delivery_Schedule__c,
                    L2I_Product_Category__c,
                    L2I_AircraftQuantity__c, (
                    SELECT ID, SBQQ__Ordered__c, SBQQ__Primary__c
                    FROM SBQQ__Quotes2__r
                    WHERE SBQQ__Primary__c = true
                    AND SBQQ__Ordered__c = true
              )
              FROM Opportunity
              WHERE Id = :recordId
        ];

//        String dealOpp = recordId;

        if (currentOppList.size() > 0) {
            System.debug('*** current opp ' + currentOppList);

            System.debug('currentOppList: ' + currentOppList);
            L2I_DSH__c newDeliverySchedule = new L2I_DSH__c(
                  Account__c = currentOppList[0].AccountId,
                  Product_Category__c = currentOppList[0].L2I_Product_Category__c);
            System.debug('newDeliverySchedule: ' + newDeliverySchedule);
            try {
                System.debug('newDeliverySchedule: ' + newDeliverySchedule);
                insert newDeliverySchedule;
                newDeliveryScheduleId = newDeliverySchedule.Id;

                currentOppList[0].L2I_Delivery_Schedule__c = newDeliveryScheduleId;
                update currentOppList[0];
            } catch (DmlException e) {
                System.debug('error: ' + e);
                throw new AuraHandledException('There was an error while trying to save the record: ' + e.getMessage());
            }
        }

        System.debug('newDeliveryScheduleId: ' + newDeliveryScheduleId);
        return newDeliveryScheduleId;
    }

    @AuraEnabled
    public static Integer createDeliveryScheduleLines(String deliveryScheduleInformation, Date deliveryDate, String opptyId) {
        System.debug('deliveryScheduleInformation: ' + deliveryScheduleInformation);
        System.debug('deliveryDate: ' + deliveryDate);

        List<deliveryScheduleLine> deliveryScheduleLines = new List<deliveryScheduleLine>();

        Map<String, Object> outerMap = (Map<String, Object>) JSON.deserializeUntyped(deliveryScheduleInformation);
        Map<String, Object> dsMap = (Map<String, Object>) outerMap.get('data');
        System.debug('dsMap: ' + dsMap);

        if (deliveryDate == null && dsMap.get('productcategory') == 'IFEC') {
            throw new AuraHandledException('Please specify the First Aircraft Delivery Date');
        }

        String recordId = String.valueOf(dsMap.get('dsId'));
        System.debug('recordId: ' + recordId);

//        Integer headEndDateOffset = -3;
//        Integer seatEndDateOffset = -6;
        Integer headEndDateOffset = null;
        Integer seatEndDateOffset = null;
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
        deliveryScheduleList = [
              select Id,
                    Name,
                    Account__r.Name,
                    CreatedDate,
                    CreatedBy.Name,
                    Product_Category__c,
                    Delivery_Date_Offset__c,
                    Line_Count__c
              from L2I_DSH__c
              where Id = :recordId
        ];

        System.debug('There are ' + deliveryScheduleList.size() + ' existing Delivery Schedule.');

        if (deliveryScheduleList.size() > 0) {
            DSLGeneratorAttributes genAttrs = new DSLGeneratorAttributes();
            Integer aircraftQuantity = Integer.valueOf(dsMap.get('aircraftQuantity'));
            genAttrs.aircraftQuantity = aircraftQuantity;
            genAttrs.interval = Integer.valueOf(dsMap.get('interval'));

            genAttrs.firstDeliveryDate = deliveryDate;
            genAttrs.headEndDateOffset = headEndDateOffset;
            genAttrs.seatEndDateOffset = seatEndDateOffset;
            genAttrs.outOfWarrantyDate1Offset = outOfWarrantyDate1Offset;
            genAttrs.outOfWarrantyDate2Offset = outOfWarrantyDate2Offset;
            genAttrs.dshId = String.valueOf(dsMap.get('dsId'));
            genAttrs.opptyId = String.valueOf(dsMap.get('opptyId'));

            System.debug('*** genAttrs ' + genAttrs);

            List<L2I_DSL__c> newDeliveryScheduleLines = new List<L2I_DSL__c>();
            String deliveryInterval = String.valueOf(dsMap.get('deliveryInterval'));

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
            System.debug('*** genAttrs ' + genAttrs);

            generateDeliveryScheduleLines(genAttrs, monthOffset, newDeliveryScheduleLines);

            if (newDeliveryScheduleLines.size() > 0) {

                try {
                    insert newDeliveryScheduleLines;
                } catch (DmlException e) {
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
                        List<L2I_DSL__c> newInsertDSL = [
                              select Id,
                                    Name,
                                    Aircraft__r.Name,
                                    L2I_Aircraft_Confirmation__c,
                                    Aircraft__c,
                                    Delivery_Date__c,
                                    CreatedBy.Name,
                                    CreatedDate,
                                    Line_Number__c,
                                    Head_End_Date__c,
                                    Seat_End_Date__c,
                                    Out_of_Warranty_Date_1__c,
                                    Out_of_Warranty_Date_2__c,
                                    IFEC_DSL__c,
                                    IFEC_DSL__r.Aircraft__c,
                                    IFEC_Delivery_Date__c,
                                    Forecasted_Delivery_Date__c,
                                    Aircraft_Identifier__c,
                                    Original_Opportunity__c,
                                    Original_Opportunity__r.L2I_Opportunity_Number__c,
                                    Original_Opportunity__r.StageName,
                                    Modified_on_Opportunity__c,
                                    Status__c
                              from L2I_DSL__c
                              where Id in :dslsIds
                              order BY Forecasted_Delivery_Date__c asc, Line_Number__c asc
                        ];

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
        System.debug('deliveryScheduleLines.size(): ' + deliveryScheduleLines.size());
        Set<String> excludeStatuses =
              L2I_JSON_Settings.getSpecificSettingCollection('Delivery_Schedule_Settings',
                    'Exclude_Statuses');
        System.debug('*** opptyId ' + opptyId);
        return [
              SELECT COUNT()
              FROM L2I_DSL__c
              WHERE Delivery_Schedule_Header__c = :recordId
              AND Status__c NOT IN :excludeStatuses
              AND
              ((Original_Opportunity__c = :opptyId) OR
              (Original_Opportunity__c <> :opptyId AND
              (Original_Opportunity__r.StageName IN ('Pending Close', 'Closed Won', 'Closed') OR
              (Original_Opportunity__r.SBQQ__PrimaryQuote__c <> null AND
              Original_Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c = true))))

        ];
    }

    @AuraEnabled
    public static String saveDeliveryScheduleToOpportunity(String recordId, String deliveryScheduleId) {

        List<Opportunity> currentOppList = new List<Opportunity>();
        currentOppList = [
              SELECT Id,
                    RecordType.DeveloperName,
                    L2I_Parent_Opportunity__c,
                    StageName,
                    AccountId,
                    Account.Name,
                    L2I_Delivery_Schedule__c,
                    L2I_Product_Category__c,
                    L2I_AircraftQuantity__c, (
                    SELECT ID, SBQQ__Ordered__c, SBQQ__Primary__c
                    FROM SBQQ__Quotes2__r
                    WHERE SBQQ__Primary__c = true
                    AND SBQQ__Ordered__c = true
              )
              FROM Opportunity
              WHERE Id = :recordId
        ];

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
    public static void pushPullDeliveryDates(String method, String months, List<String> dslIds, String schedId) {
        System.debug('====== Method Type : ' + method);
        System.debug('====== Months : ' + months);

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

        List<L2I_DSL__c> affectedDsls = [
              SELECT Id,
                    Name,
                    Aircraft__r.Name,
                    L2I_Aircraft_Confirmation__c,
                    Aircraft__c,
                    Delivery_Date__c,
                    CreatedDate,
                    CreatedBy.Name,
                    Delivery_Schedule_Header__c,
                    Delivery_Schedule_Header__r.Product_Category__c,
                    Line_Number__c,
                    Seat_End_Date__c,
                    Head_End_Date__c,
                    Out_of_Warranty_Date_1__c,
                    Out_of_Warranty_Date_2__c,
                    IFEC_DSL__c,
                    IFEC_DSL__r.Aircraft__c,
                    IFEC_Delivery_Date__c,
                    Forecasted_Delivery_Date__c,
                    Aircraft_Identifier__c,
                    Original_Opportunity__c,
                    Original_Opportunity__r.L2I_Opportunity_Number__c,
                    Original_Opportunity__r.StageName,
                    Modified_on_Opportunity__c,
                    Status__c
              from L2I_DSL__c
              where Id in :dslIds
        ];

        if (!affectedDsls.isEmpty()) {
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
            System.debug('*** affectedDsls ' + affectedDsls);
            try {
                update affectedDsls;
            } catch (DmlException dmle) {
                System.debug('error: ' + dmle);
                throw new AuraHandledException('There was an error while updating DSL record(s): ' + dmle.getMessage());
            }
        }
    }

    @AuraEnabled
    public static Integer deleteDeliveryScheduleLines(List<String> dslIds, String opptyId) {
        List<L2I_DSL__c> dslsToDelete = new List<L2I_DSL__c>();
        List<L2I_DSL__c> dslsToUpdate = new List<L2I_DSL__c>();
        String dshId = '';
        for (L2I_DSL__c dsl : [
              SELECT Id,
                    Delivery_Schedule_Header__c,
                    L2I_Aircraft_Confirmation__c,
                    Status__c,
                    Original_Opportunity__c,
                    Modified_on_Opportunity__c
              FROM L2I_DSL__c
              WHERE Id in :dslIds
        ]) {
            dshId = dsl.Delivery_Schedule_Header__c;
            if (dsl.Original_Opportunity__c == opptyId) {
                dslsToDelete.add(dsl);
            } else if (dsl.L2I_Aircraft_Confirmation__c) {
                dsl.Status__c = 'Deactivate';
                dsl.Modified_on_Opportunity__c = opptyId;
                dslsToUpdate.add(dsl);
            } else {
                dsl.Status__c = 'Deleted';
                dsl.Modified_on_Opportunity__c = opptyId;
                dslsToUpdate.add(dsl);
            }
        }

        try {
            if (!dslsToDelete.isEmpty() && dslsToDelete.size() > 0) {
                delete dslsToDelete;
            }
            if (!dslsToUpdate.isEmpty() && dslsToUpdate.size() > 0) {
                update dslsToUpdate;
            }

        } catch (DmlException dmle) {
            System.debug('error: ' + dmle);
            throw new AuraHandledException('There was an error while deleting DSL record(s): ' + dmle.getMessage());
        }
        Set<String> excludeStatuses =
              L2I_JSON_Settings.getSpecificSettingCollection('Delivery_Schedule_Settings',
                    'Exclude_Statuses');
        return [
              SELECT COUNT()
              FROM L2I_DSL__c
              WHERE Delivery_Schedule_Header__c = :dshId
              AND Status__c NOT IN :excludeStatuses
              AND
              ((Original_Opportunity__c = :opptyId) OR
              (Original_Opportunity__c <> :opptyId AND
              (Original_Opportunity__r.StageName IN ('Pending Close', 'Closed Won', 'Closed') OR
              (Original_Opportunity__r.SBQQ__PrimaryQuote__c <> null AND
              Original_Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c = true))))

        ];
    }

    @AuraEnabled
    public static Integer resetDeliveryScheduleLines(String opptyId) {
        System.debug('*** Start L2I_DeliverySchedLWCController.resetDeliveryScheduleLines ' +  opptyId);
        List<L2I_DSL__c> dslsToDelete = new List<L2I_DSL__c>();
        List<L2I_DSL__c> dslsToUpdate = new List<L2I_DSL__c>();
        String dshId = '';
        Opportunity oppty = [
              SELECT Id,
                    L2I_Initiate_Reset__c,
                    L2I_Delivery_Schedule__c
              FROM Opportunity
              WHERE Id = :opptyId
        ];
        oppty.L2I_Initiate_Reset__c = true;

        try {
            update oppty;
            System.debug('*** oppty ' + oppty);
        } catch (DmlException dmle) {
            System.debug('error: ' + dmle);
            throw new AuraHandledException('There was an error while resetting DSL records for this Opportunity: ' + opptyId + ' ' + dmle.getMessage());
        }
        Set<String> excludeStatuses =
              L2I_JSON_Settings.getSpecificSettingCollection('Delivery_Schedule_Settings',
                    'Exclude_Statuses');
        return [
              SELECT COUNT()
              FROM L2I_DSL__c
              WHERE Delivery_Schedule_Header__c = :oppty.L2I_Delivery_Schedule__c
              AND Status__c NOT IN :excludeStatuses
              AND
              ((Original_Opportunity__c = :opptyId) OR
              (Original_Opportunity__c <> :opptyId AND
              (Original_Opportunity__r.StageName IN ('Pending Close', 'Closed Won', 'Closed') OR
              (Original_Opportunity__r.SBQQ__PrimaryQuote__c <> null AND
              Original_Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c = true))))

        ];
    }

    @AuraEnabled
    public static void deleteDeliverySchedule(String dshId) {
        System.debug('*** delete dshId ' + dshId);
        try {
            L2I_DSH__c dsh = [SELECT Id FROM L2I_DSH__c WHERE Id = :dshId];
            delete dsh;
        } catch (DmlException dmle) {
            System.debug('error: ' + dmle);
            throw new AuraHandledException('There was an error while deleting the Delivery Schedule Header: ' + dmle.getMessage());
        }
    }

    @AuraEnabled
    public static void updateDeliverySchedule(String dsh) {
        System.debug('*** update dsh ' + dsh);
        Map<String, Object> outerMap = (Map<String, Object>) JSON.deserializeUntyped(dsh);
        List<Object> dshList = (List<Object>) outerMap.get('data');
        List<L2I_DSH__c> dshToUpdate = new List<L2I_DSH__c>();

        System.debug('*** dshList ' + dshList);
        String dsId = '';
        String offset = '';
        Decimal deliveryDateOffset = 0;
        for (Object dslRow : dshList) {
            SObject aDsh = new L2I_DSH__c();
            Map<String, Object> dsMap = (Map<String, Object>) dslRow;
            if (dsMap.containsKey('dsId')) {
                dsId = String.valueOf(dsMap.get('dsId'));
                aDsh.put('Id', dsId);
            }
            if (dsMap.containsKey('deliveryDateOffset')) {
                offset = String.valueOf(dsMap.get('deliveryDateOffset'));
                if (offset.isNumeric()) {
                    deliveryDateOffset = Decimal.valueOf(offset);
                }
                aDsh.put('Delivery_Date_Offset__c', deliveryDateOffset);
            }

            dshToUpdate.add((L2I_DSH__c) aDsh);
            if (!dshToUpdate.isEmpty()) {
                try {
                    System.debug('*** dshToUpdate ' + dshToUpdate);
                    update dshToUpdate;
                } catch (DmlException dmle) {
                    System.debug('====== DmlException encountered while attempting to save DSH record: ' + dmle);
                    throw new AuraHandledException('There was an error while trying to save the modified record(s): ' + dmle.getMessage());
                }
            }
        }
    }
}