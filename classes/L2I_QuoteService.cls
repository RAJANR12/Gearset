/**
 *      @author       Sarah Kennedy
 *      @date         02/18/2020
 *      @description  Service class for Quote object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 02/23/2020         Initial creation
 *      Sarah Kennedy                 06/19/2020         US2033 - exclude Deleted and Deactivate DSLs
 *      Sarah Kennedy                 06/30/2020         US2046 - AutoExtend
 *      Sarah Kennedy                 08/24/2020         US2034 - fix for calculations
 *      Sarah Kennedy                 09/22/2020         W-001777 - generate quote proposal document
 *
 */
public without sharing class L2I_QuoteService {
//    public static void generateQuoteProposal(String quoteId, String documentName, String documentTemplateId) {
//        System.debug('*** Starting L2I_QuoteService.generateQuoteProposal with quoteId ' + quoteId);
//        System.debug('*** documentName ' + documentName);
//        System.debug('*** documentTemplateId ' + documentTemplateId);
//
//        L2I_QuoteProposalModel model = new L2I_QuoteProposalModel();
//        model.quoteId = quoteId;
//        model.name = documentName;
//        model.templateId = documentTemplateId;
//        L2I_GenerateQuoteProposal proposalGenerator = new L2I_GenerateQuoteProposal();
//        String jobId = proposalGenerator.save(model);
//        System.debug('*** jobId ' + jobId);
//
//    }
    
    public static void calculateTotalAircraftServiceMonths(Id quoteId) {
        System.debug('*** Starting L2I_QuoteService.calculateTotalAircraftServiceMonths with quoteId ' + quoteId);
        
        if (String.isBlank(quoteId)) {
            throw new QuoteServiceException('Quote Id is null');
        }
        SBQQ__Quote__c quote = [
              SELECT
                    Id,
                    SBQQ__StartDate__c,
                    SBQQ__EndDate__c,
                    SBQQ__Opportunity2__c,
                    SBQQ__Opportunity2__r.RecordType.DeveloperName,
                    SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c,
                    SBQQ__Opportunity2__r.SBQQ__RenewedContract__c,
                    SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate,
                    SBQQ__SubscriptionTerm__c,
                    L2I_Bookings_Adj_Amount__c,
                    L2I_Booking_Adj_AC_Service_Months__c,
                    L2I_Bookings_Adj_Subscription_Term__c,
                    L2I_Total_Aircraft_Service_Months__c,
                    L2I_Total_Aircraft_Service_Years__c,
                    L2I_Offset_Years_Default_Value__c,
                      L2I_Aircraft_Quantity__c,
                      SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Order__r.SBQQ__Quote__r.L2I_Aircraft_Quantity__c

              FROM SBQQ__Quote__c
              WHERE Id = :quoteId
              AND SBQQ__Opportunity2__r.RecordType.DeveloperName IN ('Sales', 'Renewal', 'Amendment')
        ] ;
        System.debug('*** quote ' + quote);
        
        if (calculateTotalAircraftServiceMonths(quote)) {
            System.debug('*** quote for update ' + quote);
            update quote;
        }
        System.debug('*** Exiting L2I_QuoteService.calculateTotalAircraftServiceMonths with quoteId');
    }
    
    public static Boolean calculateTotalAircraftServiceMonths(SBQQ__Quote__c quote) {
        System.debug('*** Starting L2I_QuoteService.calculateTotalAircraftServiceMonths with quote ' + quote);
        Set<String> excludeStatuses =
              L2I_JSON_Settings.getSpecificSettingCollection('Delivery_Schedule_Settings',
                    'Exclude_Statuses');
        Decimal bookingsAdjAmt = 0;
        Decimal bookingsAdjACQty = 0;
        Decimal bookingsAdjACServiceMths = 0;
        Decimal bookingsAdjSubTerm = 0;
        Integer diff = 0;
        
        
        if (quote == NULL) {
            throw new QuoteServiceException('Quote is null');
        }
        
        System.debug('*** quote ' + quote);
        // calculate Bookings Adjustment Subscription Term
        if (quote.SBQQ__Opportunity2__r.RecordType.DeveloperName == 'Renewal' &&
              quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c != NULL &&
              quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate != NULL &&
              quote.SBQQ__StartDate__c < quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate) {
            bookingsAdjSubTerm = quote.SBQQ__StartDate__c.monthsBetween(quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate.addDays(1));
            // Calculate bookings Adjustment AC Qty
            if (quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Order__r.SBQQ__Quote__r.L2I_Aircraft_Quantity__c != quote.L2I_Aircraft_Quantity__c &&
                    quote.L2I_Aircraft_Quantity__c !=null &&
                    quote.L2I_Aircraft_Quantity__c > 0) {
                // pending requirements from PAC - 12/3/2020 Sanjay Singhal
                //bookingsAdjACQty = quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Order__r.SBQQ__Quote__r.L2I_Aircraft_Quantity__c - quote.L2I_Aircraft_Quantity__c;
            }
        }
        System.debug('*** quote.SBQQ__StartDate__c ' + quote.SBQQ__StartDate__c);
        System.debug('*** quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate ' + quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate);
        System.debug('*** bookingsAdjSubTerm ' + bookingsAdjSubTerm);
        Date endDate;


        if (quote.SBQQ__Opportunity2__r.RecordType.DeveloperName == 'Sales' ||
              quote.SBQQ__Opportunity2__r.RecordType.DeveloperName == 'Renewal') {
            if (quote.SBQQ__StartDate__c != null && quote.SBQQ__SubscriptionTerm__c != null) {
                endDate = quote.SBQQ__StartDate__c.addMonths(Integer.valueOf(quote.SBQQ__SubscriptionTerm__c));
            }
        } else {
            endDate = quote.SBQQ__EndDate__c;
        }
        System.debug('*** quote.SBQQ__SubscriptionTerm__c ' + quote.SBQQ__SubscriptionTerm__c);
        System.debug('*** quote.SBQQ__StartDate__c ' + quote.SBQQ__StartDate__c);
        System.debug('*** quote.SBQQ__EndDate__c ' + quote.SBQQ__EndDate__c);
        System.debug('*** endDate ' + endDate);
        Integer totalASM = 0;
        Decimal totalASY = 0.0;
        for (L2I_DSL__c dsl : [
              SELECT Id, Name, Forecasted_Delivery_Date__c, Status__c,
                    Modified_on_Opportunity__c,
                    Original_Opportunity__c
              FROM L2I_DSL__c
              WHERE Delivery_Schedule_Header__c = :quote.SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c
        ]) {
            Date delDate;
            diff = 0;
            System.debug('*** dsl' + dsl);
            System.debug('*** dsl.Forecasted_Delivery_Date__c ' + dsl.Forecasted_Delivery_Date__c);
            if (endDate != null /* commenting to allow deleted dsl to get a del date.&&
                  !excludeStatuses.contains(dsl.Status__c) */) {
                delDate = null;
                if (quote.SBQQ__StartDate__c == null) {
                    System.debug('*** delDate quote start');
                    delDate = dsl.Forecasted_Delivery_Date__c;
                } else if (dsl.Forecasted_Delivery_Date__c != null) {
                    if (dsl.Forecasted_Delivery_Date__c < quote.SBQQ__StartDate__c) {
                        System.debug('*** delDate quote start');
                        delDate = quote.SBQQ__StartDate__c;
                    } else {
                        System.debug('*** delDate  forecast');
                        delDate = dsl.Forecasted_Delivery_Date__c;
                    }
                } else {
                    System.debug('*** delDate quote start');
                    delDate = quote.SBQQ__StartDate__c;
                }
                System.debug('*** delDate ' + delDate); 
                if (delDate != null 
                    && endDate != null 
                    && !excludeStatuses.contains(dsl.Status__c)
                    && endDate > delDate) { // Added by Khrisna for W-003955
                    Integer monthDiff = delDate.monthsBetween(endDate);
                    Decimal yearDiff = monthDiff/12.0;
                    totalASM += monthDiff;
                    totalASY += yearDiff.round(System.RoundingMode.UP); // Added by Alvin for Aircraft Services Years
                    System.debug('*** yearDiffDiff ' + yearDiff );
                    System.debug('*** totalASY ' + totalASY );
                    System.debug('*** monthDiff ' + monthDiff);
                    System.debug('*** totalASM ' + totalASM);
                }
            }
            // calculate Bookings values
            if (quote.SBQQ__Opportunity2__r.RecordType.DeveloperName == 'Renewal' &&
                  quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c != NULL &&
                  quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate != NULL &&
                  quote.SBQQ__StartDate__c < quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate) {
                System.debug('*** quote.SBQQ__Opportunity2__c ' + quote.SBQQ__Opportunity2__c);
                System.debug('***  dsl.Modified_on_Opportunity__c ' + dsl.Modified_on_Opportunity__c);
                System.debug('***  dsl.Original_Opportunity__c ' + dsl.Original_Opportunity__c);
                
                if ((!excludeStatuses.contains(dsl.Status__c) &&
                      dsl.Original_Opportunity__c != quote.SBQQ__Opportunity2__c) ||
                      (excludeStatuses.contains(dsl.Status__c) &&
                            dsl.Modified_on_Opportunity__c == quote.SBQQ__Opportunity2__c)) {
                    if (delDate <= quote.SBQQ__StartDate__c) {
                        System.debug('*** del forecast <= quote start');
                        diff = quote.SBQQ__StartDate__c.monthsBetween(quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate.addDays(1));
                    } else if (delDate > quote.SBQQ__StartDate__c &&
                          delDate <= quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate) {
                        System.debug('*** delDate > quote start and <= contract end');
                        diff = delDate.monthsBetween(quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate.addDays(1));
                    } else if (delDate > quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate) {
                        System.debug('*** delDate > contract end');
                    } else {
                        System.debug('*** else all else');
                        //quote.SBQQ__StartDate__c.monthsBetween(quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate.addDays(1));
                    }
                    bookingsAdjACServiceMths += diff;
                    System.debug('*** diff ' + diff);
                    System.debug('*** bookingsAdjACServiceMths ' + bookingsAdjACServiceMths);
                }
            }
        }
        // calculate Bookings Adjustment Amt
        if (quote.SBQQ__Opportunity2__r.RecordType.DeveloperName == 'Renewal' &&
              quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c != NULL &&
              quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate != NULL &&
              quote.SBQQ__StartDate__c < quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate ) {
            bookingsAdjAmt = calculateBookingsAdjAmt(quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c, bookingsAdjACServiceMths, bookingsAdjSubTerm, bookingsAdjACQty);
        }
        
        System.debug('*** Exiting L2I_QuoteService.calculateTotalAircraftServiceMonths with quote');
        
        if ((totalASM > 0 && totalASM != quote.L2I_Total_Aircraft_Service_Months__c) ||
              bookingsAdjAmt != quote.L2I_Bookings_Adj_Amount__c ||
              bookingsAdjACServiceMths != quote.L2I_Booking_Adj_AC_Service_Months__c ||
              bookingsAdjSubTerm != quote.L2I_Bookings_Adj_Subscription_Term__c
              ) {

            quote.L2I_Total_Aircraft_Service_Months__c = totalASM;
            quote.L2I_Total_Aircraft_Service_Years__c = totalASY;
            quote.L2I_Bookings_Adj_Amount__c = bookingsAdjAmt;
            quote.L2I_Booking_Adj_AC_Service_Months__c = bookingsAdjACServiceMths;
            quote.L2I_Bookings_Adj_Subscription_Term__c = bookingsAdjSubTerm;
            System.debug('*** quote.L2I_Total_Aircraft_Service_Months__c ' + quote.L2I_Total_Aircraft_Service_Months__c);
            System.debug('*** quote.L2I_Bookings_Adj_Amount__c ' + quote.L2I_Bookings_Adj_Amount__c);
            System.debug('*** quote.L2I_Booking_Adj_AC_Service_Months__c ' + quote.L2I_Booking_Adj_AC_Service_Months__c);
            System.debug('*** quote.L2I_Bookings_Adj_Subscription_Term__c ' + quote.L2I_Bookings_Adj_Subscription_Term__c);
            return true;
        } else {
            return false;
        }
    }
    
    private static Decimal calculateBookingsAdjAmt(Id contractId, Decimal bookingsAdjACServiceMths, Decimal bookingsAdjSubTerm, Decimal bookingsAdjACQty) {
        System.debug('*** in calculateBookingsAdjAmt ' + contractId + ' ' + bookingsAdjACServiceMths + ' ' + bookingsAdjSubTerm);
        Decimal bookingsAdjAmt = 0;
        for (SBQQ__Subscription__c sub : [
              SELECT Id,
                    SBQQ__TerminatedDate__c,
                    SBQQ__QuoteLine__c,
                    SBQQ__QuoteLine__r.L2I_CPQMultiplier__c,
                    SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c,
                    SBQQ__QuoteLine__r.L2I_Number_of_Shipments__c,
                    SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c,
                    SBQQ__QuoteLine__r.L2I_Service_Activation_Type__c
              FROM SBQQ__Subscription__c
              WHERE SBQQ__Contract__c = :contractId
              AND SBQQ__TerminatedDate__c = NULL
              AND SBQQ__EndDate__c > TODAY
        ]) {
            System.debug('*** sub ' + sub);
            System.debug('*** sub.SBQQ__QuoteLine__r.L2I_CPQMultiplier__c ' + sub.SBQQ__QuoteLine__r.L2I_CPQMultiplier__c);
            switch on sub.SBQQ__QuoteLine__r.L2I_CPQMultiplier__c {
                when 'AC Qty' {         // one-time charge
                    if (sub.SBQQ__QuoteLine__r.L2I_Service_Activation_Type__c == 'OneTime'){
                        bookingsAdjAmt += sub.SBQQ__QuoteLine__r.L2I_TotalPriceperAircraft__c;
                    }
                }
                when 'Total AC Service Months' {
                    if (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != NULL) {
                        bookingsAdjAmt += sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c * bookingsAdjACServiceMths;
                    }
                }
                When 'Total AC Service Years'{ // for calculating Yearly charge forecast amount
                    if (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != NULL) {
                        bookingsAdjAmt += sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c * (bookingsAdjACServiceMths/12);
                    }
                }
                when 'Contracted Shipments' {       // media shipments
                    if (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != NULL &&
                          sub.SBQQ__QuoteLine__r.L2I_Number_of_Shipments__c != NULL &&
                          sub.SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c != NULL &&
                          sub.SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c != 0) {
                        bookingsAdjAmt += (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c *
                              bookingsAdjSubTerm *
                              (sub.SBQQ__QuoteLine__r.L2I_Number_of_Shipments__c / sub.SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c)).setScale(2);
                    }
                }
                when 'Quote Subscription Term' {        // non-aircraft nased standard subscriptions
                    if (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != NULL) {
                        bookingsAdjAmt += sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c * bookingsAdjSubTerm;
                    }
                }
                when 'Annual Subscription Term' {       // no products defined yet
                    if (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != NULL && sub.SBQQ__QuoteLine__r.l2I_Service_Activation_Type__C != 'Yearly') {
                        bookingsAdjAmt += sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c * (bookingsAdjSubTerm/12);
                    }
                }
            }
            System.debug('*** bookingsAdjAmt ' + bookingsAdjAmt);
        }
        
        return bookingsAdjAmt;
    }
    
//    public static void processApprovedPartsList(String quoteId) {
//        System.debug('*** Starting L2I_QuoteService.processApprovedPartsList with quoteId ' + quoteId);
//
//        SBQQ__Quote__c qt = [
//              Select Id,
//                    L2I_Verified_ConnectivityPriceCost__c,
//                    L2I_Verified_LiveTelevisionPriceCost__c,
//                    L2I_Verified_MediaServicesPriceCost__c,
//                    L2I_Reviewed_PO_Required__c,
//                    SBQQ__Opportunity2__c,
//                    SBQQ__Opportunity2__r.RecordTypeId,
//                    SBQQ__Opportunity2__r.PT_Part_List_Name__c,
//                    SBQQ__Opportunity2__r.StageName,
//                    SBQQ__Opportunity2__r.PT_Is_CPL__c,
//                    SBQQ__Opportunity2__r.PT_Is_PPL__c,
//                    SBQQ__Type__c,
//                    SBQQ__Source__c,
//                    L2I_TotalCostperAircraft__c,
//                    L2I_TotalPriceperAircraft__c,
//                    SBQQ__Opportunity2__r.L2I_Product_Category__c
//              From SBQQ__Quote__c
//              Where id = :quoteId
//        ];
////        String quoteId = qt.Id;
//        // build the revision records
//        buildPartsListRevisions(quoteId);
//        Integer plCount = [SELECT COUNT() FROM PT_Parts_List_Revision__c WHERE Parts_List__c = :quoteId];
//        // process as a Revision if there have been any changes between the current approved quote or its cloned from source
//        // or if this is the first approved quote being processed for a CPL/PPL
//        if (plCount > 0 ||
//              qt.SBQQ__Source__c == NULL) {
//            // update rev values
//            System.debug('*** updatePartsListRev');
//            updatePartsListRev(quoteId);
//            // create the CPL Integration document
//            // generate quote proposal
//            // to be used for creating CPL document to send to PAC Agile (W-001777)
//            System.debug('*** before gendoc');
//            String documentTemplateId = String.valueOf (
//                  L2I_JSON_Settings.getSpecificSetting('CPL_Settings', 'CPLDocTemplateId'));
//
//            if (Test.isRunningTest()) {
//                SBQQ__QuoteTemplate__c qtemplate = new SBQQ__QuoteTemplate__c(Name = 'Test Template');
//                insert qtemplate;
//                documentTemplateId = qtemplate.Id;
//            }
//
//            System.debug('*** qt.SBQQ__Opportunity2__r.PT_Part_List_Name__c ' + qt.SBQQ__Opportunity2__r.PT_Part_List_Name__c);
//            System.debug('*** documentTemplateId ' + documentTemplateId);
//            if (qt.SBQQ__Opportunity2__r.StageName == 'Delivery' &&
//                  !String.IsBlank(qt.SBQQ__Opportunity2__r.PT_Part_List_Name__c) &&
//                  !String.IsBlank(documentTemplateId)) {
//                L2I_QuoteService.generateQuoteProposal(quoteId, qt.SBQQ__Opportunity2__r.PT_Part_List_Name__c, documentTemplateId);
//                System.debug('*** L2I_QuoteApprovalController - generated QuoteProposal for quoteId: ' + quoteId +
//                      ' StageName: ' + qt.SBQQ__Opportunity2__r.StageName +
//                      ' CPL Name: ' + qt.SBQQ__Opportunity2__r.PT_Part_List_Name__c +
//                      ' CPL Document Template Id: ' + documentTemplateId);
//            } else {
//                System.debug('*** L2I_QuoteApprovalController - Was not generateQuoteProposal for quoteId: ' + quoteId +
//                      ' StageName: ' + qt.SBQQ__Opportunity2__r.StageName +
//                      ' CPL Name: ' + qt.SBQQ__Opportunity2__r.PT_Part_List_Name__c +
//                      ' CPL Document Template Id: ' + documentTemplateId);
//            }
//        }
////        //clone quote, quotelines, quoteline groups
////        L2I_QuoteCloneUtility.cloneSBQQQuotes(new Set<String>{
////              quoteId
////        });
////        // snapshot the shipsets
////        snapShotShipsets(quoteId);
////        // save original QLGs
////        saveOriginalQLGs(quoteId);
////        System.debug('*** Ending L2I_QuoteService.processApprovedPartsList with quoteId ' + quoteId);
//
//    }
//
//    public static void updatePartsListRev(Id quoteId) {
//        System.debug('*** start updatePartsListRev');
//        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
//        // get the quote and update the Parts Lists revision
//        quoteList = [
//              SELECT Id,
//                    PT_Revised_Parts_List_Version__c,
//                    SBQQ__Opportunity2__c
//              FROM SBQQ__Quote__c
//              WHERE Id = :quoteId
//        ];
//        System.debug('*** quoteList ' + quoteList);
//        System.debug('*** quoteList.size() ' + quoteList.size());
//        SBQQ__Quote__c quot;
//        if (quoteList != null &&
//              quoteList.size() > 0) {
//            quot = quoteList[0];
//            if (quot.PT_Revised_Parts_List_Version__c == null) {
//                quot.PT_Revised_Parts_List_Version__c = 1;
//            } else {
//                quot.PT_Revised_Parts_List_Version__c = quot.PT_Revised_Parts_List_Version__c + 1;
//            }
//            update quot;
//        }
//        System.debug('*** after update quot ' + quot);
//        // update the Opportunity with link to quote and translated parts List version
//        Opportunity opp = [
//              SELECT Id,
//                    PT_Current_Parts_List__c,
//                    PT_Revised_Parts_List_Version_Trans__c
//              FROM Opportunity
//              WHERE Id = :quoteList[0].SBQQ__Opportunity2__c
//        ];
//        opp.PT_Current_Parts_List__c = quoteList[0].Id;
//        Integer revNbr = Integer.valueOf(quoteList[0].PT_Revised_Parts_List_Version__c);
//        opp.PT_Revised_Parts_List_Version_Trans__c = PT_Program_Utils.revisionCharacter(revNbr);
//        System.debug('*** opp updaterev ' + opp);
//        update opp;
//    }
    
//    public static void buildPartsListRevisions(Id quoteId) {
//        System.debug('*** Starting L2I_QuoteService.buildPartsListRevisions with quoteId ' + quoteId);
//        List<SBQQ__QuoteLine__c> approvedQuoteLinesList = new List<SBQQ__QuoteLine__c>();
//        List<SBQQ__QuoteLine__c> sourceQuoteLinesList = new List<SBQQ__QuoteLine__c>();
//        Map<Id, SBQQ__QuoteLine__c> approvedQLMap = new Map<Id, SBQQ__QuoteLine__c>();
//        Map<Id, SBQQ__QuoteLine__c> sourceQLMap = new Map<Id, SBQQ__QuoteLine__c>();
//        List<L2I_DSL__c> approvedShipsetsList = new List<L2I_DSL__c>();
//        List<L2I_DSL__c> sourceShipsetsList = new List<L2I_DSL__c>();
//        Set<String> approvedShipsetsAC = new Set<String>();
//        Set<String> sourceShipsetsAC = new Set<String>();
//        Map<String, String> acMap = new Map<String, String>();
//        Id sourceQuoteId;
//        Id dshId;
//        List<PT_Parts_List_Revision__c> plrList = new List<PT_Parts_List_Revision__c>();
//        List<PT_Parts_List_Revision__c> plrListToDelete = new List<PT_Parts_List_Revision__c>();
//
//        // get Quote Line revisions
//        // get Approved QuoteLines
//        for (SBQQ__QuoteLine__c approvedQLine : [
//              SELECT Id,
//                    Name,
//                    SBQQ__Quote__c,
//                    SBQQ__Quote__r.SBQQ__Source__c,
//                    SBQQ__Quantity__c,
//                    PT_Configured_Quantity__c,
//                    SBQQ__ProductCode__c,
//                    SBQQ__Group__c,
//                    SBQQ__Group__r.Name,
//                    SBQQ__Source__c
//              FROM SBQQ__QuoteLine__c
//              WHERE SBQQ__Quote__c = :quoteId
//        ]) {
//            if (approvedQLine.SBQQ__Quote__r.SBQQ__Source__c != null) {
//                sourceQuoteId = approvedQLine.SBQQ__Quote__r.SBQQ__Source__c;
//            }
//            approvedQLMap.put(approvedQLine.SBQQ__Source__c, approvedQLine);
//        }
//
//        if (sourceQuoteId == null) {
//            System.debug('***No Source Quote and QuoteLines were found');
//            return;
//        }
//
//        // clear any existing records so we don't end up with duplicates
//        plrListToDelete = [SELECT Id FROM PT_Parts_List_Revision__c WHERE Parts_List__c = :quoteId];
//        if (plrListToDelete != null &&
//              plrListToDelete.size() > 0) {
//            delete plrListToDelete;
//        }
//
//        //  get QuoteLines for Current Part List
//        for (SBQQ__QuoteLine__c sourceQLine : [
//              SELECT Id,
//                    Name,
//                    SBQQ__Quote__c,
//                    SBQQ__Quantity__c,
//                    PT_Configured_Quantity__c,
//                    SBQQ__ProductCode__c,
//                    SBQQ__Group__c,
//                    SBQQ__Group__r.Name,
//                    SBQQ__Source__c
//              FROM SBQQ__QuoteLine__c
//              WHERE SBQQ__Quote__c = :sourceQuoteId
//        ]) {
//            sourceQLMap.put(sourceQLine.Id, sourceQLine);
//        }
//
//        for (SBQQ__QuoteLine__c appQL : approvedQLMap.values()) {
//            System.debug('*** appQL ' + appQl);
//            // find the source quote line
//            if (sourceQLMap.get(appQL.SBQQ__Source__c) != null) {
//                SBQQ__QuoteLine__c sourceQL = sourceQLMap.get(appQL.SBQQ__Source__c);
//                System.debug('*** sourceQL ' + sourceQL);
//                // find any changes
//                System.debug('*** appQL.SBQQ__Group__r.Name ' + appQL.SBQQ__Group__r.Name);
//                System.debug('*** sourceQL.SBQQ__Group__r.Name ' + sourceQL.SBQQ__Group__r.Name);
//                if (appQL.SBQQ__Group__r.Name != sourceQL.SBQQ__Group__r.Name) {
//                    // Moved P/N
//                    plrList.add(createPLR(
//                          quoteId,
//                          '',
//                          'Moved P/N',
//                          appQL.SBQQ__ProductCode__c + ' from ' + sourceQL.SBQQ__Group__r.Name + ' to ' + appQL.SBQQ__Group__r.Name
//                    )
//                    );
//                } else if (appQL.SBQQ__ProductCode__c != sourceQL.SBQQ__ProductCode__c) {
//                    // Replaced P/N
//                    plrList.add(createPLR(
//                          quoteId,
//                          appQL.SBQQ__Group__r.Name,
//                          'Replace P/N',
//                          sourceQL.SBQQ__ProductCode__c + ': A/C Qty ' + sourceQL.PT_Configured_Quantity__c + ' to ' + appQL.SBQQ__ProductCode__c + ': A/C Qty ' + appQL.PT_Configured_Quantity__c
//                    )
//                    );
//                } else if (appQL.SBQQ__Quantity__c != sourceQL.SBQQ__Quantity__c ||
//                      appQL.PT_Configured_Quantity__c != sourceQL.PT_Configured_Quantity__c) {
//                    // Change Quantity
//                    plrList.add(createPLR(
//                          quoteId,
//                          appQL.SBQQ__Group__r.Name,
//                          'Change Quantity',
//                          appQL.SBQQ__ProductCode__c + ': A/C Qty ' + sourceQL.PT_Configured_Quantity__c + ' to A/C Qty ' + appQL.PT_Configured_Quantity__c + ',  Purchase Qty ' + sourceQL.SBQQ__Quantity__c + ' to Purchase Qty ' + appQL.SBQQ__Quantity__c
//                    )
//                    );
//                } else {
//                    // No Change
//                }
//            } else {
//                // Added
//                plrList.add(createPLR(
//                      quoteId,
//                      appQL.SBQQ__Group__r.Name,
//                      'Added',
//                      appQL.SBQQ__ProductCode__c + ' : A/C Qty ' + appQL.PT_Configured_Quantity__c
//                )
//                );
//            }
//        }
//        // find any deleted Quote Lines
//        for (SBQQ__QuoteLine__c sourceQL : sourceQLMap.values()) {
//            // find the qpproved quote line
//            System.debug('*** delete? sourceQL ' + sourceQL);
//            System.debug('*** approvedQLMap.get(sourceQL.Id) ' + approvedQLMap.get(sourceQL.Id));
//            if (approvedQLMap.get(sourceQL.Id) == null) {
//                // Deleted
//                plrList.add(createPLR(
//                      quoteId,
//                      sourceQL.SBQQ__Group__r.Name,
//                      'Deleted',
//                      sourceQL.SBQQ__ProductCode__c + ' : A/C Qty ' + sourceQL.PT_Configured_Quantity__c
//                )
//                );
//            }
//        }
//
//        // find effectivity changes
//        // find DSH of Approved Quote
//        dshId = [
//              SELECT Id, SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c
//              FROM SBQQ__Quote__c
//              WHERE Id = :quoteId
//        ].SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c;
//        if (dshId == null) {
//            System.debug('***No Delivery Schedule was found');
//        } else {
//            for (L2I_DSL__c dsl : [
//                  SELECT Id, Aircraft__c, Aircraft__r.Name
//                  FROM L2I_DSL__c
//                  WHERE Delivery_Schedule_Header__c = :dshId
//            ]) {
//                if (dsl.Aircraft__c != null) {
//                    approvedShipsetsAC.add(dsl.Aircraft__c);
//                    System.debug('*** approved dsl ' + dsl.Aircraft__c);
//                    acMap.put(dsl.Aircraft__c, dsl.Aircraft__r.Name);
//                }
//            }
//
//            for (PT_Parts_List_Revision_Shipset__c plrs : [
//                  SELECT Id, Aircraft__c, Aircraft__r.Name
//                  FROM PT_Parts_List_Revision_Shipset__c
//                  WHERE Delivery_Schedule_Header__c = :dshId
//            ]) {
//                if (plrs.Aircraft__c != null) {
//                    sourceShipsetsAC.add(plrs.Aircraft__c);
//                    System.debug('*** snapshot dsl ' + plrs.Aircraft__c);
//                    acMap.put(plrs.Aircraft__c, plrs.Aircraft__r.Name);
//                }
//            }
//
//            // create revision records for effectivity
//            for (String approvedAC : approvedShipsetsAC) {
//                if (!sourceShipsetsAC.contains(approvedAC)) {
//                    // Added
//                    plrList.add(createPLR(
//                          quoteId,
//                          'Effectivity',
//                          'Added',
//                          acMap.get(approvedAC)
//                    )
//                    );
//                }
//            }
//            for (String sourceAC : sourceShipsetsAC) {
//                if (!approvedShipsetsAC.contains(sourceAC)) {
//                    // Deleted
//                    plrList.add(createPLR(
//                          quoteId,
//                          'Effectivity',
//                          'Deleted',
//                          acMap.get(sourceAC)
//                    )
//                    );
//                }
//            }
//        }
//
//        if (plrList != null &&
//              plrList.size() > 0) {
//            insert plrList;
//        }
//        System.debug('*** End of L2I_QuoteService.buildPartsListRevisions with quoteId ' + quoteId);
//    }
    
//    private static PT_Parts_List_Revision__c createPLR(Id quoteId, String element, String action, String description) {
//        System.debug('*** createPLR element ' + element);
//        System.debug('*** createPLR action ' + action);
//        System.debug('*** createPLR description ' + description);
//        return new PT_Parts_List_Revision__c(
//              Parts_List__c = quoteId,
//              Revised_Element__c = element,
//              Revised_Action__c = action,
//              Revised_Description__c = description
//        );
//    }
    
//    public static void snapShotShipsets(Id sourceQuoteId) {
//        System.debug('*** Starting L2I_QuoteService.snapShotShipsets with sourceQuoteId ' + sourceQuoteId);
//        List<PT_Parts_List_Revision_Shipset__c> plrsList = new List<PT_Parts_List_Revision_Shipset__c>();
//        List<PT_Parts_List_Revision_Shipset__c> plrsListToDelete = new List<PT_Parts_List_Revision_Shipset__c>();
//        List<L2I_DSL__c> dslList = new List<L2I_DSL__c>();
//        Id dshId;
//
//        dshId = [
//              SELECT Id, SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c
//              FROM SBQQ__Quote__c
//              WHERE Id = :sourceQuoteId
//        ].SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c;
//        if (dshId == null) {
//            System.debug('***No Delivery Schedule was found');
//            return;
//        }
//        System.debug('*** dshId ' + dshId);
//        // clear any existing records so we don't end up with duplicates
//        plrsListToDelete = [SELECT Id FROM PT_Parts_List_Revision_Shipset__c WHERE Delivery_Schedule_Header__c = :dshId];
//        if (plrsListToDelete != null &&
//              plrsListToDelete.size() > 0) {
//            delete plrsListToDelete;
//        }
//        System.debug('*** plrsListToDelete ' + plrsListToDelete);
//
//        dslList = [
//              SELECT Id, Name, Aircraft__c, PT_Line_Number__c, Delivery_Schedule_Header__c
//              FROM L2I_DSL__c
//              WHERE Delivery_Schedule_Header__c = :dshId
//        ];
//        for (L2I_DSL__c dsl : dslList) {
//            PT_Parts_List_Revision_Shipset__c plrs = new PT_Parts_List_Revision_Shipset__c(
//                  Parts_List__c = sourceQuoteId,
//                  PT_Line_Number__c = dsl.PT_Line_Number__c,
//                  Aircraft__c = dsl.Aircraft__c,
//                  Delivery_Schedule_Header__c = dsl.Delivery_Schedule_Header__c,
//                  Source_Shipset__c = dsl.Id
//            );
//            System.debug('*** plrs ' + plrs);
//            plrsList.add(plrs);
//        }
//        if (plrsList != null &&
//              plrsList.size() > 0) {
//            insert plrsList;
//        }
//        System.debug('*** End of L2I_QuoteService.snapShotShipsets with sourceQuoteId ' + sourceQuoteId);
//
//    }
    
//    public static void saveOriginalQLGs(Id quoteId) {
//        System.debug('*** Starting L2I_QuoteService.saveOriginalQLGs ' + quoteId);
//        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
//
//        qLineList = [
//              SELECT Id, SBQQ__Quote__c, SBQQ__Group__c, PT_Original_Quote_Line_Group__c
//              FROM SBQQ__QuoteLine__c
//              WHERE SBQQ__Quote__c = :quoteId
//        ];
//
//        for (SBQQ__QuoteLine__c qLine : qLineList) {
//            qLine.PT_Original_Quote_Line_Group__c = qLine.SBQQ__Group__c;
//        }
//        if (qLineList != null &&
//              qLineList.size() > 0) {
//            update qLineList;
//        }
//        System.debug('*** End of L2I_QuoteService.saveOriginalQLGs');
//    }
    
    public class QuoteServiceException extends Exception {
    }
}