public class L2I_DealSummaryFunctions {


    /* Pre population of Deal Summary from opportunity
     Created date : 11/19/2020
     Params : Deal Summary record id
     @InvocableMethod(label='Deal Summary Data')
    */
    @InvocableMethod(label='Populate Deal Summary')
    public static void PopulateDealSummary(List<id> lstIds) {
        if (lstIDs.size()>0){
            // process only first Deal Summary record for performance reasons.
            L2I_Deal_Summary__c recDS = [Select id, L2I_P_L_Approval__c,
                    L2I_VIP_VVIP__c, DS_Financials_Included__c,
                    DS_IFE_Program_Numbers__c, DS_IFE_Fit_Type__c, DS_IFE_Obsolescence_Provisions_Included__c,
                    DS_IFE_Warranty_Months__c, DS_IFE_Warranty_TAT__c, DS_IFE_Warranty_Start_Date__c,
                    L2I_IFEC_Shipset_Quantity__c, L2I_IFEC_Hardware_System_Type__c, L2I_IFEC_Escalation__c,
                    L2I_IFEC_Total_Values_of_Shipset_Credits__c, L2I_IFEC_Initial_Ship_Date__c,
                    L2I_IFECTotal_Value_of_Other_Concessions__c, L2I_IFEC_Escalation_Applicability__c,
                    L2I_IFEC_Delivery_Guarantee__c, L2I_IFEC_Delivery_Penalty_Cap__c,
                    L2I_IFEC_Summary_of_Incentives__c, DS_IFE_Dedicated_Rack__c, IFE_Service_Types__c,


                    DS_IFC_Program_Numbers__c, DS_IFC_Fit_Type__c, DS_IFC_Obsolescence_Provisions_Included__c,
                    DS_IFC_Warranty_Months__c, DS_IFC_Warranty_TAT__c, DS_IFC_Warranty_Start_Date__c,
                    DS_IFC_Aircraft_Quantity__c, DS_IFC_System_Type__c, DS_IFC_Escalation__c,
                    DS_IFC_Total_Value_of_Shipset_Credits__c, DS_IFC_Initial_Ship_Date__c,
                    DS_IFC_Total_Value_of_Other_Concessions__c, DS_IFC_Escalation_Applicability__c,
                    DS_IFC_SLA_Guarantee__c, DS_IFC_Delivery_SLA_Penalty_Cap__c, DS_IFC_Hardware_System_Type__c,
                    DS_IFC_Service_Term_Months__c, DS_IFC_Summary_of_Incentives__c,
                    L2I_Forecasted_Data_Usage_per_AC_per_Mo__c, L2I_Connectivity_Revenue_Model__c,
                    DS_IFC_Service_Types__c,

                    DS_DSS_Fit_Type__c, L2I_DSS_Aircraft_Quantity__c, L2I_DSS_Service_Term_Months__c,
                    L2I_DSS_Escalation__c, L2I_DSS_Total_Value_of_Other_Concessions__c,
                    DS_DSS_Escalation_Applicability__c, L2I_DSS_SLA_Guarantee__c, L2I_DSS_SLA_Penalty_Cap__c,
                    L2I_DSS_Services_Start_Date__c, L2I_DSS_Summary_of_Incentives__c, L2I_DSS_Service_Types__c,

                    DS_PTS_Fit_Type__c, L2I_PTS_Aircraft_Quantity__c, L2I_Spares_Pricing_Contract_Terms__c,
                    L2I_PTS_Service_Term_Months__c, L2I_PTS_Escalation__c, L2I_PTS_SLA_Guarantee__c,
                    L2I_PTS_Total_Value_of_Other_Concessions__c, DS_PTS_Escalation_Applicability__c,
                    L2I_PTS_SLA_Penalty_Cap__c, L2I_PTS_Services_Start_Date__c, L2I_PTS_Summary_of_Incentives__c,
                    L2I_PTS_Service_Types__c,

                    L2I_Aircraft_Type__c

            From L2I_Deal_Summary__c where id = :lstIds[0] limit 1];

            if (recDS != null ){
                List <Opportunity> lstPLOpptys = [SELECT id, name, RecordType.developerName, PL_Business_Pillars__c,
                        L2I_Business_Initiative__c, L2I_Product_Category__c, L2I_AircraftType__c,
                        L2I_Program_Num__r.Name, L2I_Fit_Type__c, L2I_Obsolescence_Provisions_Included__c,
                        L2I_Warranty__c, L2I_Standard_in_Warranty_TAT__c, L2I_Warranty_Start_Date__c,
                        L2I_AircraftQuantity__c, L2I_First_Delivery_Date__c, L2I_Spares_Pricing_Contract_Terms__c,
                        SBQQ__PrimaryQuote__r.SBQQ__SubscriptionTerm__c, SBQQ__PrimaryQuote__r.L2I_Connectivity_System_Type1__c,
                        L2I_Escalation__c, L2I_Total_Shipset_Credit_Amount__c, L2I_Total_Non_Shipset_Credit_Amount__c,
                        L2I_IFEC_Escalation_Applicability__c, L2I_Delivery_SLA_Guarantee__c,
                        L2I_Delivery_SLA_Penalty_Cap_Percent__c, L2I_Delivery_SLA_Penalty_Cap_Amount__c,
                        L2I_Primary_System_Type__c, SBQQ__PrimaryQuote__c,
                        L2I_Primary_System_Type__r.Name // Added by Lipton for W-004087

                FROM opportunity WHERE id IN (SELECT L2I_Sales_Opportunity__c
                FROM L2I_P_L_Sales_Opportunity__c
                WHERE L2I_P_L_Approval__c = :recDS.L2I_P_L_Approval__c )];
                if (lstPLOpptys != null && lstPLOpptys.size() > 0){
                    InitDSRecord(recDS);
                    ProcessDSAutomation(recDS, lstPLOpptys);
                    update recDS;
                }
            }
        }
    }

    public static void InitDSRecord(L2I_Deal_Summary__c recDS){
        recDS.L2I_VIP_VVIP__c = '';
        recDS.DS_Financials_Included__c = '';
        recDS.DS_IFE_Fit_Type__c = '';
        recDS.DS_IFC_Fit_Type__c = '';
        recDS.DS_DSS_Fit_Type__c = '';
        recDS.DS_PTS_Fit_Type__c = '';
        recDS.DS_IFE_Obsolescence_Provisions_Included__c = '';
        recDS.DS_IFC_Obsolescence_Provisions_Included__c = '';
        recDS.DS_IFE_Warranty_Months__c = '';
        recDS.DS_IFC_Warranty_Months__c = '';
        recDS.DS_IFE_Warranty_TAT__c = '';
        recDS.DS_IFC_Warranty_TAT__c = '';
        recDS.DS_IFE_Warranty_Start_Date__c = '';
        recDS.DS_IFC_Warranty_Start_Date__c = '';
        recDS.L2I_IFEC_Shipset_Quantity__c = '';
        recDS.DS_IFC_Aircraft_Quantity__c = '';
        recDS.L2I_DSS_Aircraft_Quantity__c = '';
        recDS.L2I_PTS_Aircraft_Quantity__c = '';
        recDS.L2I_Spares_Pricing_Contract_Terms__c = '';
        recDS.L2I_DSS_Service_Term_Months__c = '';
        recDS.L2I_PTS_Service_Term_Months__c = '';
        recDS.DS_IFC_System_Type__c = '';
        recDS.L2I_IFEC_Escalation__c = '';
        recDS.DS_IFC_Escalation__c = '';
        recDS.L2I_DSS_Escalation__c = '';
        recDS.L2I_PTS_Escalation__c = '';
        recDS.L2I_IFEC_Total_Values_of_Shipset_Credits__c = '';
        recDS.DS_IFC_Total_Value_of_Shipset_Credits__c = '';
        recDS.L2I_IFEC_Initial_Ship_Date__c = '';
        recDS.DS_IFC_Initial_Ship_Date__c = '';
        recDS.L2I_IFECTotal_Value_of_Other_Concessions__c = '';
        recDS.DS_IFC_Total_Value_of_Other_Concessions__c = '';
        recDS.L2I_DSS_Total_Value_of_Other_Concessions__c = '';
        recDS.L2I_PTS_Total_Value_of_Other_Concessions__c = '';
        recDS.DS_PTS_Escalation_Applicability__c = '';
        recDS.L2I_IFEC_Escalation_Applicability__c = '';
        recDS.DS_IFC_Escalation_Applicability__c = '';
        recDS.DS_DSS_Escalation_Applicability__c = '';
        recDS.L2I_IFEC_Delivery_Guarantee__c = '';
        recDS.DS_IFC_SLA_Guarantee__c = '';
        recDS.L2I_DSS_SLA_Guarantee__c = '';
        recDS.L2I_PTS_SLA_Guarantee__c = '';
        recDS.L2I_IFEC_Delivery_Penalty_Cap__c = '';
        recDS.DS_IFC_Delivery_SLA_Penalty_Cap__c = '';
        recDS.L2I_DSS_SLA_Penalty_Cap__c     = '';
        recDS.L2I_PTS_SLA_Penalty_Cap__c = '';
        recDS.L2I_IFEC_Hardware_System_Type__c = '';
        recDS.DS_IFC_Hardware_System_Type__c = '';
        recDS.L2I_PTS_Services_Start_Date__c = '';
        recDS.L2I_DSS_Services_Start_Date__c = '';
        recDS.DS_IFC_Service_Term_Months__c = '';
        recDS.L2I_IFEC_Summary_of_Incentives__c = '';
        recDS.DS_IFC_Summary_of_Incentives__c = '';
        recDS.L2I_DSS_Summary_of_Incentives__c = '';
        recDS.L2I_PTS_Summary_of_Incentives__c = '';
        recDS.DS_IFE_Dedicated_Rack__c = '';
        recDS.L2I_Forecasted_Data_Usage_per_AC_per_Mo__c = '';
        recDS.L2I_DSS_Service_Types__c = '';
        recDS.L2I_PTS_Service_Types__c = '';
        recDS.L2I_Connectivity_Revenue_Model__c = '';
        recDS.DS_IFC_Service_Types__c = '';
        recDS.L2I_Aircraft_Type__c = '';
        recDS.L2I_IFEC_Program_Number__c = ''; // Added by Lipton for W-003627
        recDS.IFE_Service_Types__c = ''; // Added by Matthew for W-004481


    }

    public static void ProcessDSAutomation(L2I_Deal_Summary__c recDS, List <Opportunity> lstPLOpptys){
        Set <Id> setOppIdsforCredit = new Set <Id>();
        Set <Id> setQuoteIds = new Set <Id> ();
        Map <Id, String> mapOptyCredits = new Map <Id, String>();
        Map <Id, QuoteLineInfo> mapQLInfo = new Map <Id, QuoteLineInfo> ();

        // set id sets and maps
        for (Opportunity opt : lstPLOpptys){
            if (opt.L2I_Product_Category__c == 'DSS' || opt.L2I_Product_Category__c == 'PTS' || opt.L2I_Product_Category__c == 'IFEC'){
                setQuoteIds.add(opt.SBQQ__PrimaryQuote__c);
            }
            if (opt.L2I_Total_Non_Shipset_Credit_Amount__c != null && opt.L2I_Total_Non_Shipset_Credit_Amount__c != 0){
                setOppIdsforCredit.add(opt.Id);
            }
            if (opt.L2I_Total_Shipset_Credit_Amount__c != null && opt.L2I_Total_Shipset_Credit_Amount__c != 0){
                setOppIdsforCredit.add(opt.Id);
            }
        }

        // Process Credit Types - setOppIdsforCredit
        if (setOppIdsforCredit != null && setOppIdsforCredit.size() >0) {
            mapOptyCredits = getCreditTypes(setOppIdsforCredit);
        }
        // Process Quote Lines - setQuoteIds
        if (setQuoteIds != null && setQuoteIds.size() >0) {
            mapQLInfo = getQuoteLineInfo(setQuoteIds);
        }

        for (Opportunity opt : lstPLOpptys) {

            String strAircraftType = '';
            String strAircraftQty = '';
            String strSubsterm = '';
            String strShipsetCredit = '';
            String strNonShipsetCredit = '';
            String strShipDate = '';
            String strSLAPenalty = '';
            String strPriSysType = '';
            String strCreditSummary = '';
            QuoteLineInfo qlInfo = new QuoteLineInfo();

            if (mapOptyCredits != null){ // get credit summary from the map.
                if (mapOptyCredits.get(opt.Id) != null) {
                    strCreditSummary = mapOptyCredits.get(opt.Id);
                }
            }
            if (mapQLInfo != null){
                if (mapQLInfo.get(opt.Id) != null) {
                    qlInfo = mapQLInfo.get(opt.Id);
                    System.debug('Quote Line Info instance : ' + qlInfo);
                }
            }

            if (opt.L2I_Primary_System_Type__c != null && opt.L2I_Primary_System_Type__r.Name != null){
                strPriSysType = opt.L2I_Primary_System_Type__r.Name; // Added by Lipton for W-004087 - Use the Name field instead of Id
            }

            if(opt.L2I_Delivery_SLA_Penalty_Cap_Percent__c != null && opt.L2I_Delivery_SLA_Penalty_Cap_Percent__c != 0){
                strSLAPenalty = opt.L2I_Delivery_SLA_Penalty_Cap_Percent__c + '%';
            } else if (opt.L2I_Delivery_SLA_Penalty_Cap_Amount__c != null && opt.L2I_Delivery_SLA_Penalty_Cap_Amount__c != 0) {
                strSLAPenalty = '$' + opt.L2I_Delivery_SLA_Penalty_Cap_Amount__c;
            }
            if (opt.L2I_First_Delivery_Date__c != null){
                Datetime dtShipDate = opt.L2I_First_Delivery_Date__c;
                strShipDate = dtShipDate.formatGmt('MM-dd-YYYY');
            }

            if (opt.L2I_Total_Non_Shipset_Credit_Amount__c != null && opt.L2I_Total_Non_Shipset_Credit_Amount__c != 0){
                strNonShipsetCredit = '' + opt.L2I_Total_Non_Shipset_Credit_Amount__c;
            }
            if (opt.L2I_Total_Shipset_Credit_Amount__c != null && opt.L2I_Total_Shipset_Credit_Amount__c != 0){
                strShipsetCredit = '' + opt.L2I_Total_Shipset_Credit_Amount__c;
            }

            System.debug('Opportunity Name before AC type set : ' + opt.Name);
            System.debug('AC Name before AC type set : ' + opt.L2I_AircraftType__c);
            System.debug('DC AC Name before AC type set : ' + recDS.L2I_Aircraft_Type__c);

            if (opt.L2I_AircraftType__c != null){
                strAircraftType = opt.L2I_AircraftType__c;
                recDS.L2I_Aircraft_Type__c = AppendValue(recDS.L2I_Aircraft_Type__c, strAircraftType, null, true);
            }
            System.debug('DC AC Name before AC type set : ' + recDS.L2I_Aircraft_Type__c);

            if (opt.L2I_AircraftQuantity__c != null){
                strAircraftQty = opt.L2I_AircraftQuantity__c.setScale(0) + '';
            }
            if (opt.SBQQ__PrimaryQuote__r.SBQQ__SubscriptionTerm__c !=null) {
                strSubsterm = opt.SBQQ__PrimaryQuote__r.SBQQ__SubscriptionTerm__c.setScale(0) + '';
            }

            // automate common fields
            if (opt.L2I_Business_Initiative__c == 'VIP/VVIP') {
                recDS.L2I_VIP_VVIP__c = AppendValue(recDS.L2I_VIP_VVIP__c, 'Yes', '', true);
            }
            if (opt.L2I_Product_Category__c != null && opt.L2I_Product_Category__c != '') {
                recDS.DS_Financials_Included__c = AppendValue(recDS.DS_Financials_Included__c, opt.L2I_Product_Category__c, '', false);
            }
            if (opt.PL_Business_Pillars__c != null) {
                if (opt.PL_Business_Pillars__c.contains('IFE')) {
                    // Automate IFE section fields
                    if (opt.L2I_Program_Num__c != null){ // Automate Program Number
                        if (opt.L2I_Program_Num__r.Name.length() > 0) {
                            // field DS_FE_Program_Numbers__c, prefix strAircraftType, value L2I_Program_Num__r.Name
                            // recDS.DS_IFE_Program_Numbers__c = AppendValue(recDS.DS_IFE_Program_Numbers__c, opt.L2I_Program_Num__r.Name, strAircraftType, true);
                            recDS.L2I_IFEC_Program_Number__c = AppendValue(recDS.L2I_IFEC_Program_Number__c, opt.L2I_Program_Num__r.Name, strAircraftType, true); // Added by Lipton for W-003627
                        }
                    }
                    recDS.DS_IFE_Fit_Type__c = AppendValue(recDS.DS_IFE_Fit_Type__c, opt.L2I_Fit_Type__c, strAircraftType, false);
                    // recDS.DS_IFE_Obsolescence_Provisions_Included__c = AppendValue(recDS.DS_IFE_Obsolescence_Provisions_Included__c, opt.L2I_Obsolescence_Provisions_Included__c, strAircraftType, false);
                    recDS.DS_IFE_Obsolescence_Provisions_Included__c = validateField(recDS.DS_IFE_Obsolescence_Provisions_Included__c, opt.L2I_Obsolescence_Provisions_Included__c); // Added by Lipton for W-003774
                    recDS.DS_IFE_Warranty_Months__c = AppendValue(recDS.DS_IFE_Warranty_Months__c, opt.L2I_Warranty__c, strAircraftType, false);
                    recDS.DS_IFE_Warranty_TAT__c = AppendValue(recDS.DS_IFE_Warranty_TAT__c, opt.L2I_Standard_in_Warranty_TAT__c, strAircraftType, false);
                    recDS.DS_IFE_Warranty_Start_Date__c = AppendValue(recDS.DS_IFE_Warranty_Start_Date__c, opt.L2I_Warranty_Start_Date__c, strAircraftType, false);
                    recDS.L2I_IFEC_Shipset_Quantity__c = AppendValue(recDS.L2I_IFEC_Shipset_Quantity__c, strAircraftQty, strAircraftType, false);
                    // recDS.L2I_IFEC_Escalation__c = AppendValue(recDS.L2I_IFEC_Escalation__c, opt.L2I_Escalation__c, strAircraftType, false);
                    recDS.L2I_IFEC_Escalation__c = validateField(recDS.L2I_IFEC_Escalation__c, opt.L2I_Escalation__c); // Added by Lipton for W-003774
                    recDS.L2I_IFEC_Total_Values_of_Shipset_Credits__c = AppendValue(recDS.L2I_IFEC_Total_Values_of_Shipset_Credits__c, strShipsetCredit, strAircraftType, false);
                    recDS.L2I_IFEC_Initial_Ship_Date__c = AppendValue(recDS.L2I_IFEC_Initial_Ship_Date__c, strShipDate, strAircraftType, false);
                    recDS.L2I_IFECTotal_Value_of_Other_Concessions__c = AppendValue(recDS.L2I_IFECTotal_Value_of_Other_Concessions__c, strNonShipsetCredit, strAircraftType, false);
                    recDS.L2I_IFEC_Escalation_Applicability__c = AppendValue(recDS.L2I_IFEC_Escalation_Applicability__c, opt.L2I_IFEC_Escalation_Applicability__c, strAircraftType, false);
                    // recDS.L2I_IFEC_Delivery_Guarantee__c = AppendValue(recDS.L2I_IFEC_Delivery_Guarantee__c, opt.L2I_Delivery_SLA_Guarantee__c, strAircraftType, false);
                    recDS.L2I_IFEC_Delivery_Guarantee__c = validateField(recDS.L2I_IFEC_Delivery_Guarantee__c, opt.L2I_Delivery_SLA_Guarantee__c); // Added by Lipton for W-003774
                    // recDS.L2I_IFEC_Delivery_Penalty_Cap__c = AppendValue(recDS.L2I_IFEC_Delivery_Penalty_Cap__c, strSLAPenalty, strAircraftType, false);
                    recDS.L2I_IFEC_Delivery_Penalty_Cap__c = validateField(recDS.L2I_IFEC_Delivery_Penalty_Cap__c, strSLAPenalty); // Added by Lipton for W-003774
                    recDS.L2I_IFEC_Hardware_System_Type__c = AppendValue(recDS.L2I_IFEC_Hardware_System_Type__c, strPriSysType, strAircraftType, false);
                    recDS.L2I_IFEC_Summary_of_Incentives__c = AppendValue(recDS.L2I_IFEC_Summary_of_Incentives__c, strCreditSummary, strAircraftType, false);
                    // recDS.DS_IFE_Dedicated_Rack__c = AppendValue(recDS.DS_IFE_Dedicated_Rack__c, qlInfo.dedicatedRack, strAircraftType, false);
                    recDS.DS_IFE_Dedicated_Rack__c = validateField(recDS.DS_IFE_Dedicated_Rack__c, qlInfo.dedicatedRack); // Added by Lipton for W-003774
                    System.debug('#### qlInfo.IFESubCat1Types: ' + qlInfo.IFESubCat1Types);
                    recDS.IFE_Service_Types__c = AppendValue(recDS.IFE_Service_Types__c, qlInfo.IFESubCat1Types, strAircraftType, false);
                    //recDS. = AppendValue(recDS., opt., strAircraftType, false);

                }
                if (opt.PL_Business_Pillars__c.contains('IFC')) {
                    // Automate IFC section fields
                    if (opt.L2I_Program_Num__c != null){ // Automate Program Number
                        if (opt.L2I_Program_Num__r.Name.length() > 0) {
                            // field DS_FE_Program_Numbers__c, prefix L2I_AircraftType__c, value L2I_Program_Num__r.Name
                            // recDS.DS_IFC_Program_Numbers__c = AppendValue(recDS.DS_IFC_Program_Numbers__c, opt.L2I_Program_Num__r.Name, strAircraftType, true);
                            recDS.L2I_IFEC_Program_Number__c = AppendValue(recDS.L2I_IFEC_Program_Number__c, opt.L2I_Program_Num__r.Name, strAircraftType, true); // Added by Lipton for W-003627
                        }
                    }
                    recDS.DS_IFC_Fit_Type__c = AppendValue(recDS.DS_IFC_Fit_Type__c, opt.L2I_Fit_Type__c, strAircraftType, false);
                    recDS.DS_IFC_Obsolescence_Provisions_Included__c = AppendValue(recDS.DS_IFC_Obsolescence_Provisions_Included__c, opt.L2I_Obsolescence_Provisions_Included__c, strAircraftType, false);
                    recDS.DS_IFC_Warranty_Months__c = AppendValue(recDS.DS_IFC_Warranty_Months__c, opt.L2I_Warranty__c, strAircraftType, false);
                    recDS.DS_IFC_Warranty_TAT__c = AppendValue(recDS.DS_IFC_Warranty_TAT__c, opt.L2I_Standard_in_Warranty_TAT__c, strAircraftType, false);
                    recDS.DS_IFC_Warranty_Start_Date__c = AppendValue(recDS.DS_IFC_Warranty_Start_Date__c, opt.L2I_Warranty_Start_Date__c, strAircraftType, false);
                    recDS.DS_IFC_Aircraft_Quantity__c = AppendValue(recDS.DS_IFC_Aircraft_Quantity__c, strAircraftQty, strAircraftType, false);
                    recDS.DS_IFC_System_Type__c = AppendValue(recDS.DS_IFC_System_Type__c, strPriSysType, strAircraftType, false); // Modified by Alvin for W-004131
                    // recDS.DS_IFC_Escalation__c = AppendValue(recDS.DS_IFC_Escalation__c, opt.L2I_Escalation__c, strAircraftType, false);
                    recDS.DS_IFC_Escalation__c = validateField(recDS.DS_IFC_Escalation__c, opt.L2I_Escalation__c); // Added by Lipton for W-003774
                    if (opt.PL_Business_Pillars__c == 'IFC') { // to avoid duplicate representation of Credit amount.
                        recDS.DS_IFC_Total_Value_of_Shipset_Credits__c = AppendValue(recDS.DS_IFC_Total_Value_of_Shipset_Credits__c, strShipsetCredit, strAircraftType, false);
                        recDS.DS_IFC_Total_Value_of_Other_Concessions__c = AppendValue(recDS.DS_IFC_Total_Value_of_Other_Concessions__c, strNonShipsetCredit, strAircraftType, false);
                        recDS.DS_IFC_Summary_of_Incentives__c = AppendValue(recDS.DS_IFC_Summary_of_Incentives__c, strCreditSummary, strAircraftType, false);
                    }
                    recDS.DS_IFC_Initial_Ship_Date__c = AppendValue(recDS.DS_IFC_Initial_Ship_Date__c, strShipDate, strAircraftType, false);
                    recDS.DS_IFC_Escalation_Applicability__c = AppendValue(recDS.DS_IFC_Escalation_Applicability__c, opt.L2I_IFEC_Escalation_Applicability__c, strAircraftType, false);
                    // recDS.DS_IFC_SLA_Guarantee__c = AppendValue(recDS.DS_IFC_SLA_Guarantee__c, opt.L2I_Delivery_SLA_Guarantee__c, strAircraftType, false);
                    recDS.DS_IFC_SLA_Guarantee__c = validateField(recDS.DS_IFC_SLA_Guarantee__c, opt.L2I_Delivery_SLA_Guarantee__c); // Added by Lipton for W-003774
                    // recDS.DS_IFC_Delivery_SLA_Penalty_Cap__c = AppendValue(recDS.DS_IFC_Delivery_SLA_Penalty_Cap__c, strSLAPenalty, strAircraftType, false);
                    recDS.DS_IFC_Delivery_SLA_Penalty_Cap__c = validateField(recDS.DS_IFC_Delivery_SLA_Penalty_Cap__c, strSLAPenalty); // Added by Lipton for W-003774
                    if (opt.L2I_Product_Category__c == 'IFEC') { // only applicable for IFEC opportunity as IFC can be under DSS opporrunity.
                        recDS.DS_IFC_Hardware_System_Type__c = AppendValue(recDS.DS_IFC_Hardware_System_Type__c, strPriSysType, strAircraftType, false);
                    } else { // populate when non IFEC opportunity has IFC
                        recDS.DS_IFC_Service_Term_Months__c = AppendValue(recDS.DS_IFC_Service_Term_Months__c, strSubsterm, strAircraftType, false);
                    }
                    recDS.L2I_Forecasted_Data_Usage_per_AC_per_Mo__c = AppendValue(recDS.L2I_Forecasted_Data_Usage_per_AC_per_Mo__c, qlInfo.ForecastedData, strAircraftType, false);
                    recDS.L2I_Connectivity_Revenue_Model__c = AppendValue(recDS.L2I_Connectivity_Revenue_Model__c, qlInfo.WiFiModel, strAircraftType, false);
                    recDS.DS_IFC_Service_Types__c= AppendValue(recDS.DS_IFC_Service_Types__c, qlInfo.IFCSubCat2Types, strAircraftType, false);
                }
                if (opt.PL_Business_Pillars__c.contains('DS')) {
                    // Automate DSS section fields
                    recDS.DS_DSS_Fit_Type__c = AppendValue(recDS.DS_DSS_Fit_Type__c, opt.L2I_Fit_Type__c, strAircraftType, false);
                    recDS.L2I_DSS_Aircraft_Quantity__c = AppendValue(recDS.L2I_DSS_Aircraft_Quantity__c, strAircraftQty, strAircraftType, false);
                    recDS.L2I_DSS_Service_Term_Months__c = AppendValue(recDS.L2I_DSS_Service_Term_Months__c, strSubsterm, strAircraftType, false);
                    // recDS.L2I_DSS_Escalation__c = AppendValue(recDS.L2I_DSS_Escalation__c, opt.L2I_Escalation__c, strAircraftType, false);
                    recDS.L2I_DSS_Escalation__c = validateField(recDS.L2I_DSS_Escalation__c, opt.L2I_Escalation__c); // Added by Lipton for W-003774
                    recDS.L2I_DSS_Total_Value_of_Other_Concessions__c = AppendValue(recDS.L2I_DSS_Total_Value_of_Other_Concessions__c, strNonShipsetCredit, strAircraftType, false);
                    recDS.DS_DSS_Escalation_Applicability__c = AppendValue(recDS.DS_DSS_Escalation_Applicability__c, opt.L2I_IFEC_Escalation_Applicability__c, strAircraftType, false);
                    // recDS.L2I_DSS_SLA_Guarantee__c = AppendValue(recDS.L2I_DSS_SLA_Guarantee__c, opt.L2I_Delivery_SLA_Guarantee__c, strAircraftType, false);
                    recDS.L2I_DSS_SLA_Guarantee__c = validateField(recDS.L2I_DSS_SLA_Guarantee__c, opt.L2I_Delivery_SLA_Guarantee__c); // Added by Lipton for W-003774
                    // recDS.L2I_DSS_SLA_Penalty_Cap__c = AppendValue(recDS.L2I_DSS_SLA_Penalty_Cap__c, strSLAPenalty, strAircraftType, false);
                    recDS.L2I_DSS_SLA_Penalty_Cap__c = validateField(recDS.L2I_DSS_SLA_Penalty_Cap__c, strSLAPenalty); // Added by Lipton for W-003774
                    recDS.L2I_DSS_Services_Start_Date__c = AppendValue(recDS.L2I_DSS_Services_Start_Date__c , strShipDate, strAircraftType, false);
                    recDS.L2I_DSS_Summary_of_Incentives__c = AppendValue(recDS.L2I_DSS_Summary_of_Incentives__c, strCreditSummary, strAircraftType, false);
                    recDS.L2I_DSS_Service_Types__c = AppendValue(recDS.L2I_DSS_Service_Types__c, qlInfo.DSSSubCat1Types, strAircraftType, false);

                }
                if (opt.PL_Business_Pillars__c.contains('PTS')) {
                    // Automate PTS section fields
                    recDS.DS_PTS_Fit_Type__c = AppendValue(recDS.DS_PTS_Fit_Type__c, opt.L2I_Fit_Type__c, strAircraftType, false);
                    recDS.L2I_PTS_Aircraft_Quantity__c = AppendValue(recDS.L2I_PTS_Aircraft_Quantity__c, strAircraftQty, strAircraftType, false);
                    // recDS.L2I_Spares_Pricing_Contract_Terms__c = AppendValue(recDS.L2I_Spares_Pricing_Contract_Terms__c, opt.L2I_Spares_Pricing_Contract_Terms__c, strAircraftType, false);
                    recDS.L2I_Spares_Pricing_Contract_Terms__c = validateField(recDS.L2I_Spares_Pricing_Contract_Terms__c, opt.L2I_Spares_Pricing_Contract_Terms__c); // Added by Lipton for W-003774
                    recDS.L2I_PTS_Service_Term_Months__c = AppendValue(recDS.L2I_PTS_Service_Term_Months__c, strSubsterm, strAircraftType, false);
                    // recDS.L2I_PTS_Escalation__c = AppendValue(recDS.L2I_PTS_Escalation__c, opt.L2I_Escalation__c, strAircraftType, false);
                    recDS.L2I_PTS_Escalation__c = validateField(recDS.L2I_PTS_Escalation__c, opt.L2I_Escalation__c); // Added by Lipton for W-003774
                    recDS.L2I_PTS_Total_Value_of_Other_Concessions__c = AppendValue(recDS.L2I_PTS_Total_Value_of_Other_Concessions__c, strNonShipsetCredit, strAircraftType, false);
                    recDS.DS_PTS_Escalation_Applicability__c = AppendValue(recDS.DS_PTS_Escalation_Applicability__c, opt.L2I_IFEC_Escalation_Applicability__c, strAircraftType, false);
                    // recDS.L2I_PTS_SLA_Guarantee__c = AppendValue(recDS.L2I_PTS_SLA_Guarantee__c , opt.L2I_Delivery_SLA_Guarantee__c, strAircraftType, false);
                    recDS.L2I_PTS_SLA_Guarantee__c = validateField(recDS.L2I_PTS_SLA_Guarantee__c, opt.L2I_Delivery_SLA_Guarantee__c); // Added by Lipton for W-003774
                    // recDS.L2I_PTS_SLA_Penalty_Cap__c = AppendValue(recDS.L2I_PTS_SLA_Penalty_Cap__c, strSLAPenalty, strAircraftType, false);
                    recDS.L2I_PTS_SLA_Penalty_Cap__c = validateField(recDS.L2I_PTS_SLA_Penalty_Cap__c, strSLAPenalty); // Added by Lipton for W-003774
                    recDS.L2I_PTS_Services_Start_Date__c = AppendValue(recDS.L2I_PTS_Services_Start_Date__c, strShipDate, strAircraftType, false);
                    recDS.L2I_PTS_Summary_of_Incentives__c = AppendValue(recDS.L2I_PTS_Summary_of_Incentives__c, strCreditSummary, strAircraftType, false);
                    recDS.L2I_PTS_Service_Types__c = AppendValue(recDS.L2I_PTS_Service_Types__c, qlInfo.PTSSubCat3Types, strAircraftType, false);
                }
            }
        }
    }

    // method to append value with specified delimiter
    public static String AppendValue2(String strTarget, String strValue, String strPrifix, Boolean bUnique, String strDlim){
        String strReturn = '';
        String strAppend = '';

        // handle null pointer exceptions
        if (strValue == null) {
            strValue = '';
        }
        if (strPrifix == null) {
            strPrifix = '';
        }
        // generate append string if nothing to append then return target string
        if (strPrifix != '' && strValue != ''){
            strAppend = strPrifix + ' (' + strValue + ')'; // Added by Lipton for W-004082 -- Replaced dash with parenthesis
        }else if (strValue != '') {
            strAppend = strValue;
        } else {
            return strTarget;
        }

        // Check unique values if applicable
        if (bUnique) {
            if (strTarget.contains(strAppend)) {
                // value already exists return the same value as is
                return strTarget;
            }
        }

        //Added by Lipton for W-004082
        strDlim = ': ';
        
        // Append string
        if (strTarget.length() > 0) {
            strReturn = strTarget + strDlim + strAppend;
        } else {
            strReturn = strAppend;
        }

        return strReturn;
    }
    // method to append values with ';'
    public static String AppendValue(String strTarget, String strValue, String strPrifix, Boolean bUnique) {
        return AppendValue2(strTarget, strValue, strPrifix, bUnique, ': ') ;
    }

    // W-003774 Added by Lipton Abillar
    // Description: Logic change from appending values to just binary Yes or No
    public static String validateField(String target, String value) {
        String result = 'No';
        
        if ((target == 'Yes' || String.isBlank(target)) && (!String.isBlank(value) && value != 'No' && value != '0')) {
            result = 'Yes';
        }

        return result;
    }

    public static Map<ID, String> getCreditTypes(Set <Id> setOptyIds) {
        Map <ID, String> mapCredits = new Map <ID, String>();
        for (L2I_Credit__c cdt : [SELECT Id, Credit_Type__c, Opportunity__c FROM L2I_Credit__c WHERE Opportunity__c in :setOptyIds]){
            // get opportunity Credit type from the map
            String strCreditTypes = '';
            if (mapCredits !=null && mapCredits.get(cdt.Opportunity__c) != null) {
                strCreditTypes = mapCredits.get(cdt.Opportunity__c);
            }

            // Append Credit Type
            strCreditTypes = AppendValue2(strCreditTypes, cdt.Credit_Type__c, '', true, ', ');
            mapCredits.put(cdt.Opportunity__c, strCreditTypes);
        }
        System.debug('Credit Data as Created :' + mapCredits);
        return mapCredits;
    }

    // method to get map of quote line info based on quote id set
    public static Map <Id, QuoteLineInfo> getQuoteLineInfo(Set <Id> QIds){
        Map <Id, QuoteLineInfo> mapQLInfo = new Map <Id, QuoteLineInfo> ();
        for (SBQQ__QuoteLine__c ql : [SELECT Id, SBQQ__Quote__r.SBQQ__Opportunity2__c, L2I_Sub_Category_2__c, L2I_Sub_Category_1__c, L2I_Sub_Category3__c,
                        SBQQ__ProductCode__c, L2I_Connect_Forecasted_Data_Usage__c, SBQQ__Product__r.PL_Product_Summary__r.Product_Group__c,
                        SBQQ__Group__r.SBQQ__SolutionGroup__r.PL_PS__r.Product_Group__c // Added by Lipton for W-004481
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c in :QIds]){
            //initialize the instance
            QuoteLineInfo qlInfo;
            
            // Updated by Lipton for W-004481
            String qlProdGroup = ql.SBQQ__Product__r.PL_Product_Summary__r.Product_Group__c;
            if (qlProdGroup == null && ql.SBQQ__Group__r.SBQQ__SolutionGroup__r.PL_PS__r.Product_Group__c != null) {
           		qlProdGroup = ql.SBQQ__Group__r.SBQQ__SolutionGroup__r.PL_PS__r.Product_Group__c;
            }
            qlProdGroup = qlProdGroup + '';
            // End: W-004481

            if (mapQLInfo != null && mapQLInfo.get(ql.SBQQ__Quote__r.SBQQ__Opportunity2__c) != null){
                qlInfo = mapQLInfo.get(ql.SBQQ__Quote__r.SBQQ__Opportunity2__c);
            } else {
                qlInfo = new QuoteLineInfo();
                mapQLInfo.put(ql.SBQQ__Quote__r.SBQQ__Opportunity2__c, qlInfo);
            }

            // process business rules.
            if (ql.L2I_Sub_Category_2__c != null && ql.L2I_Sub_Category_2__c !='') {
                if (qlProdGroup.contains('IFC')) { // seperating IFC from others.
                    qlInfo.IFCSubCat2Types = AppendValue2(qlInfo.IFCSubCat2Types, ql.L2I_Sub_Category_2__c, '', true, ', ');
                // } else if (qlProdGroup.contains('DSS')) {
                    // qlInfo.DSSSubCat2Types = AppendValue2(qlInfo.DSSSubCat2Types, ql.L2I_Sub_Category_2__c, '', true, ', ');
                // }else if (qlProdGroup.contains('PTS')) {
                    // qlInfo.PTSSubCat2Types = AppendValue2(qlInfo.PTSSubCat2Types, ql.L2I_Sub_Category_2__c, '', true, ', ');
                // }else if (qlProdGroup.contains('IFE')) {
                    // qlInfo.IFESubCat2Types = AppendValue2(qlInfo.IFESubCat2Types, ql.L2I_Sub_Category_2__c, '', true, ', ');   
                }
            }
            if (ql.L2I_Sub_Category_1__c != null && ql.L2I_Sub_Category_1__c !='') { // added by Matthew for W-004481
                if (qlProdGroup.contains('IFE')) {
                    qlInfo.IFESubCat1Types = AppendValue2(qlInfo.IFESubCat1Types, ql.L2I_Sub_Category_1__c, '', true, ', ');    
                } else if (qlProdGroup.contains('DSS')) {
                    qlInfo.DSSSubCat1Types = AppendValue2(qlInfo.DSSSubCat1Types, ql.L2I_Sub_Category_1__c, '', true, ', ');
                // }else if (qlProdGroup.contains('PTS')) {
                    // qlInfo.PTSSubCat1Types = AppendValue2(qlInfo.PTSSubCat1Types, ql.L2I_Sub_Category_1__c, '', true, ', ');
                }
            }
            if (ql.L2I_Sub_Category3__c != null && ql.L2I_Sub_Category3__c !='') { // added by Matthew for W-004481
                if (qlProdGroup.contains('PTS')) {
                    qlInfo.PTSSubCat3Types = AppendValue2(qlInfo.PTSSubCat3Types, ql.L2I_Sub_Category3__c, '', true, ', ');    
                 }
            }
            if (ql.SBQQ__ProductCode__c == 'PA-CPSTPAC-YYYY' || ql.SBQQ__ProductCode__c == 'PA-CPSPERMB-YYYY'){
                qlInfo.ForecastedData = AppendValue2(qlInfo.ForecastedData, ql.L2I_Connect_Forecasted_Data_Usage__c + '', '', true, ', ');
            }
            if (ql.SBQQ__ProductCode__c == 'PA-MRNRE01-001' || ql.SBQQ__ProductCode__c == 'PA-MRNRE02-001' || ql.SBQQ__ProductCode__c == 'PA-MRNRE03-001'
                    || ql.SBQQ__ProductCode__c == 'PA-PRUR001-YYYY,' || ql.SBQQ__ProductCode__c == 'PA-PRURMR01-YYYY') { // dedicated rack
                qlInfo.dedicatedRack = 'Yes';
            }
            if (ql.SBQQ__ProductCode__c == 'PA-CPSULAC-YYYY' || ql.SBQQ__ProductCode__c == 'PA-CPSTPAC-YYYY' || ql.SBQQ__ProductCode__c == 'PA-CPSPERMB-YYYY'
                    || ql.SBQQ__ProductCode__c == '(PA-CPSREVSH-YYYY' ) { // Wifi Model
                String WifiModel = '';
                if (ql.SBQQ__ProductCode__c == 'PA-CPSULAC-YYYY'){
                    WifiModel = 'CIR Model';
                }else if (ql.SBQQ__ProductCode__c == 'PA-CPSTPAC-YYYY') {
                    WifiModel = 'GB Model';
                }else if (ql.SBQQ__ProductCode__c == 'PA-CPSPERMB-YYYY') {
                    WifiModel = 'MB Model';
                }else if (ql.SBQQ__ProductCode__c == '(PA-CPSREVSH-YYYY') {
                    WifiModel = 'RevShare Model';
                }
                qlInfo.WiFiModel = AppendValue2(qlInfo.WiFiModel, WifiModel, '', true, ', ');
            }
        }

        System.debug('Quoteline Info Map : ' + mapQLInfo);

        return mapQLInfo;
    }

    public class QuoteLineInfo {
        public String ForecastedData { get; set; }
        public String IFESubCat1Types {get; set;}
        public String IFCSubCat2Types {get; set;}
        public String DSSSubCat1Types {get; set;}
        public String PTSSubCat3Types {get; set;}
        public String WiFiModel {get; set;}
        public String dedicatedRack {get; set;}

        public QuoteLineInfo () {
            ForecastedData = '';
            IFESubCat1Types = '';
            IFCSubCat2Types = '';
            DSSSubCat1Types = '';
            PTSSubCat3Types = '' ;
            WiFiModel = '';
            dedicatedRack = '';
        }
    }
}