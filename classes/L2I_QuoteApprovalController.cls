public with sharing class L2I_QuoteApprovalController {
    @AuraEnabled
    public static void onSubmit(Id quoteId) {
        if (quoteId == null) {
            System.debug('====== L2I_QuoteApprovalController onSubmit was called with a null quote');
            return;
        }
        
System.debug('====== L2I_QuoteApprovalController onSubmit was called');        

        Boolean validationFailed = false;
        Set<String> validationProds = new Set<String>();
        Set<String> errorMessages = new Set<String>();

        Set<Id> oppRecTypes = new Set<Id>();
        for (String recType : L2I_JSON_Settings.getSpecificSettingCollection('Order_Creation_Settings', 'Opp_Type_Exclude_PO_Req')) {
            oppRecTypes.add(Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get(recType).getRecordTypeId());
        }
        // Added for price list validation
        String errorMsg = PT_QuotePriceValidation.quotePriceValidation(quoteId);
        if(errorMsg != '') throw new AuraHandledException(errorMsg);
System.debug('====== L2I_QuoteApprovalController Afer Price List Validation'); 
        SBQQ__Quote__c quote = [
              Select Id,
                    L2I_Verified_ConnectivityPriceCost__c,
                    L2I_Verified_LiveTelevisionPriceCost__c,
                    L2I_Verified_MediaServicesPriceCost__c,
                    L2I_Reviewed_PO_Required__c,
                    SBQQ__Opportunity2__c,
                    SBQQ__Opportunity2__r.RecordTypeId,
                    SBQQ__Opportunity2__r.PT_Part_List_Name__c,
                    SBQQ__Opportunity2__r.StageName,
                    SBQQ__Opportunity2__r.PT_Is_CPL__c,
                    SBQQ__Opportunity2__r.PT_Is_PPL__c,
                    SBQQ__Type__c,
                    SBQQ__Source__c,
                    L2I_TotalCostperAircraft__c,
                    L2I_TotalPriceperAircraft__c,
                    SBQQ__Opportunity2__r.L2I_Product_Category__c,
                    L2I_AircraftType_ReadOnly__c,
                    L2I_Crew_Rest_Cabin_Configuration__c,
                    L2I_Crew_Rest_Seat_Count__c,
                    L2I_Flight_Deck_Cabin_Configuration__c,
                    L2I_Flight_Deck_Seat_Count__c,
                    L2I_OpportunityType__c,
                    L2I_Cabin_Configuration__c,
                    L2I_First_Class_Cabin_Configuration__c,
                    L2I_Business_Class_Cabin_Configuration__c,
                    L2I_Premium_Economy_Cabin_Configuration__c,
                    L2I_Economy_Cabin_Configuration__c,
                    L2I_OFAR_Cabin_Configuration__c,
                    L2I_OFCR_Cabin_Configuration__c,
                    L2I_Proposal_Due_Date__c,
                    SubmittedDate__c,
                    L2I_Final_Proposal_Submission_Date__c
              From SBQQ__Quote__c
              Where id = :quoteId
        ];
        
        System.debug('====== L2I_QuoteApprovalController before Listing Quote LInes'); 

        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>([Select Id From SBQQ__QuoteLine__c Where SBQQ__Quote__c = :quoteId]);

        if (quoteLines.size() == 0) {
            errorMessages.add('You cannot finalize a quote without products');
            validationFailed = true;
        }

        System.debug('====== L2I_QuoteApprovalController Afer Price List Validation'); 
        
        List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c>([
              Select Id,
                    SBQQ__RequiredBy__r.SBQQ__ProductCode__c
              From SBQQ__QuoteLine__c
              Where SBQQ__Quote__c = :quoteId
              and SBQQ__ProductCode__c like '%YYYY'
        ]);
        
        System.debug('====== L2I_QuoteApprovalController Afer '); 
        
        
        for (SBQQ__QuoteLine__c ql : qlines) {
            validationProds.add(ql.SBQQ__RequiredBy__r.SBQQ__ProductCode__c);
        }

        String errMsg;
        for (String pCode : validationProds) {
            if (pCode == 'MCS BUNDLE' && !quote.L2I_Verified_MediaServicesPriceCost__c) {
                errMsg = (errMsg == null) ? 'Media Services, ' : errMsg + 'Media Services, ';
            } else if (pCode == 'CONNECTIVITY BUNDLE' && !quote.L2I_Verified_ConnectivityPriceCost__c) {
                errMsg = (errMsg == null) ? 'Connectivity, ' : errMsg + 'Connectivity, ';
            } else if (pCode == 'TV/MEDIA BUNDLE' && !quote.L2I_Verified_LiveTelevisionPriceCost__c) {
                errMsg = (errMsg == null) ? 'Live Television, ' : errMsg + 'Live Television, ';
            }
        }

        if (errMsg != null) {
            errMsg = errMsg.subString(0, errMsg.trim().length() - 1);
            errMsg = 'Have you verified all ' + errMsg + ' YYYY part numbers are accurately populated with cost and price? If so, please check the Verified ' + errMsg + ' Price/Cost checkbox';
            System.debug(errMsg);
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errMsg));
            errorMessages.add(errMsg);
            validationFailed = true;
        }
   //Following Code is Commented by Srikanth Vudutha on 09/30/2020
        /*if (!quote.L2I_Reviewed_PO_Required__c && (quote.SBQQ__Opportunity2__c == null || (quote.SBQQ__Opportunity2__c != null && !oppRecTypes.contains(quote.SBQQ__Opportunity2__r.RecordTypeId) && quote.SBQQ__Opportunity2__r.L2I_Product_Category__c != 'IFEC'))) {
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please check that you have reviewed the PO Required checkbox on your quote before submitting for approval'));
            errorMessages.add('Please check that you have reviewed the PO Required checkbox on your quote before submitting for approval');
            validationFailed = true;
        }*/

        List<SBQQ__QuoteLine__c> qls = new List<SBQQ__QuoteLine__c>([
              Select Id,
                    SBQQ__ProductCode__c
              From SBQQ__QuoteLine__c
              Where SBQQ__Quote__c = :quoteId
              AND SBQQ__ProductCode__c in ('TBD-Recurring', 'TBD-OneTime')
              AND (SBQQ__NetTotal__c = 0 OR SBQQ__NetTotal__c = null)
        ]);
        String partNumbers;

        if (qls.size() > 0) {
            for (SBQQ__QuoteLine__c ql : qls) {
                partNumbers = (partNumbers != null) ? partNumbers + ',' + ql.SBQQ__ProductCode__c : ql.SBQQ__ProductCode__c;
            }
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a price for Placeholder Part:'+partNumbers+' in order to submit your quote'));
            errorMessages.add('You must enter a price for Placeholder Part:' + partNumbers + ' in order to submit your quote');
            validationFailed = true;
        }

        List<SBQQ__QuoteLine__c> rateLines = new List<SBQQ__QuoteLine__c>([
              Select Id
              From SBQQ__QuoteLine__c
              Where SBQQ__Quote__c = :quoteId
              AND ((SBQQ__ProductCode__c = 'PA-CPSTPAC-YYYY' and L2I_Model_Type__c = 'Average GB per Tail - Tiered') and (L2I_Has_Rate_Schedule__c = false))
        ]);

        if (rateLines.size() > 0) {
            errorMessages.add('Tiered pricing for this Quote has not been finalized, click Edit Lines to finalize tiered pricing.');
            validationFailed = true;
        }

        /*if(quote.SBQQ__Type__c == 'Renewal' && (quote.L2I_TotalCostperAircraft__c == 0 || quote.L2I_TotalCostperAircraft__c == null) && (quote.L2I_TotalPriceperAircraft__c == 0 || quote.L2I_TotalPriceperAircraft__c == null)) {
            errorMessages.add('Please click on Edit Lines to calculate Total Cost and Total Net Price before finalizing the quote');
            validationFailed = true;
        }*/

        // Added by Arun - 02.22.21 -- Removed by Matthew 6/22/2022 W-004456
        // L2I_Cabin_Configuration_Airbus_A350 validation rule
//        if(quote.L2I_AircraftType_ReadOnly__c == 'AIRBUS A350' && (String.isBlank(quote.L2I_Crew_Rest_Cabin_Configuration__c) || quote.L2I_Crew_Rest_Seat_Count__c == null)) {
//            errorMessages.add('When Aircraft Type is Airbus A350 then Crew Rest Seat Count and Crew Rest Cabin Configuration is required.');
//            validationFailed = true;
//        }

        // Added by Arun - 02.22.21 -- Removed by Matthew 6/21/2022 W-004456
        // L2I_Cabin_Configuration_Boeing_787 validation rule
//        if(quote.L2I_AircraftType_ReadOnly__c == 'BOEING 787' && (String.isBlank(quote.L2I_Flight_Deck_Cabin_Configuration__c) || quote.L2I_Flight_Deck_Seat_Count__c == null)) {
//            errorMessages.add('When Aircraft Type is Boeing 787 then Flight Deck Seat Count and Flight Deck Cabin Configuration is required.');
//            validationFailed = true;
//        }

        // Added by Arun - 02.22.21 -- Removed by Sarah 3/8/2021 W-003275
        // L2I_IFEC_Product_Category_Required_Field validation rule
//        L2I_Rule_Settings__c ruleSettings = L2I_Rule_Settings__c.getInstance(UserInfo.getUserId());
//        if(ruleSettings.Enforce_Validation_Rule__c
//            && quote.L2I_OpportunityType__c == 'Sales'
//            && quote.SBQQ__Opportunity2__r.L2I_Product_Category__c == 'IFEC'
//            && (String.isBlank(quote.L2I_Cabin_Configuration__c) ||
//                String.isBlank(quote.L2I_First_Class_Cabin_Configuration__c) ||
//                String.isBlank(quote.L2I_Business_Class_Cabin_Configuration__c) ||
//                String.isBlank(quote.L2I_Premium_Economy_Cabin_Configuration__c) ||
//                String.isBlank(quote.L2I_Economy_Cabin_Configuration__c) ||
//                String.isBlank(quote.L2I_OFAR_Cabin_Configuration__c) ||
//                String.isBlank(quote.L2I_OFCR_Cabin_Configuration__c))) {
//            errorMessages.add('For Product Type = IFEC, the following fields are required: Cabin Config, First Class Cabin Config, Business Class Cabin Config, Premium Economy Cabin Config, Economy Cabin Config, OFAR Cabin Config, OFCR Cabin Config');
//            validationFailed = true;
//        }

        // Added by Arun - 02.22.21
        // L2I_Proposal_Due_Date validation rule
        if(quote.SBQQ__Source__c == null && (quote.L2I_Proposal_Due_Date__c == null ||
                                            quote.SubmittedDate__c == null ||
                                            quote.L2I_Final_Proposal_Submission_Date__c == null)) {
            errorMessages.add('Proposal Due Date, Initial Proposal Submission Date and Final Proposal Submission Date are required fields');
            validationFailed = true;
        }

        if (validationFailed) {
            String allErrors = 'Validation failed with following ' + errorMessages.size() + ' error(s):\n';
            Integer count = 1;
            for (String emsg : errorMessages) {
                allErrors = allErrors + '[' + count + '] ' + emsg + '\n';
                count++;
            }
            throw new AuraHandledException(allErrors);
        }
        if (quoteId != null) {
            if (!Test.isRunningTest()) {
                // initate P&L Calculation batch process.
                database.executeBatch(new PL_CalculatePSDataBatch(quoteId));
            }

            SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
            // make sure all quote lines have a matching id
            // DE454 to replace same functionality in QuoteLine Trigger Functions where there was a conflict with SBQQ trigger
            L2I_QuoteLineService.setMatchingIds(new Set<Id>{
                  quoteId
            });

            // process Parts List revisions
//            if (quote.SBQQ__Opportunity2__r.StageName == 'Delivery' &&
//                  (quote.SBQQ__Opportunity2__r.PT_Is_CPL__c ||
//                        quote.SBQQ__Opportunity2__r.PT_Is_PPL__c)) {
//               // L2I_QuoteService.processApprovedPartsList(quoteId);
//            }
        }
    }

    @AuraEnabled
    public static void onRecall(Id quoteId) {
        if (quoteId != null) {
            SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
            System.debug('====== L2I_QuoteApprovalController onRecall was called');
        }
    }
}