/**
 * Created by sanjay.singhal on 12/23/20.
 */

public class PL_UtilsFunctions {
    public SBQQ__Quote__c myQuote;
    public List<SBQQ__QuoteLine__c> myQL;
    public Set <Id> myQLProdIds;
    public Set <String> myQLInstLocs;
    public Map <String, PL_MD__c> psMDMap;
    public Map <String, PL_Product_Group__c> pgMap;
    public Map <String, SBQQ__SolutionGroup__c> ilMap;
    //public Map <String, String> pil2psMap; PL_IL2PS__c not used
    public Map <String, PL_PS__c> quotePSMap;
    public List <PL_PS__c> quotePSLst;
    public Decimal corpTaxRate;
    public Boolean isIFC;
    public String strBusinessPillars;
    public List <String> ErrorLogString;
    public List <L2I_P_L_Sales_Opportunity__c> updatePLSalesOpp = new List <L2I_P_L_Sales_Opportunity__c>();

    // constructor to get the data needed for the P&L Process
    public PL_UtilsFunctions(Id QuoteId){
        // Initialize class variables
        myQL = new List<SBQQ__QuoteLine__c>();
        myQLProdIds = new Set <Id>();
        myQLInstLocs = new Set <String>();
        //retrieve product summary master data
        psMDMap = PL_Utils.getProductSummaryMasterDataMap();
        // retrieve active product group master data
        pgMap = PL_Utils.getProductGroupMDMap();
        // retrieve Install Loction Data
        ilMap = PL_Utils.getInstallLocationMap();
        // PL_IL2PS__c not used
        //pil2psMap = new Map <String, String>();
        quotePSMap = new Map<String, PL_PS__c>();
        quotePSLst = new List <PL_PS__c> ();
        corpTaxRate = L2I_GeneralSettings.getCorporateTaxRate();
        ErrorLogString = new List <String>();


        isIFC = false;
        strBusinessPillars = '';

        ErrorLogString.add('Last Process Run Time : ' + System.now());
        try {
            if (quoteId != null) {
                // get quote record
                myQuote = [
                        SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.RecordType.DeveloperName,
                                SBQQ__Opportunity2__r.L2I_Delivery_Schedule__c, SBQQ__Opportunity2__r.SBQQ__RenewedContract__c, SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate,
                                SBQQ__SubscriptionTerm__c, L2I_Bookings_Adj_Amount__c, L2I_Booking_Adj_AC_Service_Months__c, L2I_Bookings_Adj_Subscription_Term__c,
                                L2I_Total_Aircraft_Service_Months__c, L2I_Aircraft_Quantity__c, L2I_Opportunity_Product_Category_Value__c,
                                SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Order__r.SBQQ__Quote__r.L2I_Aircraft_Quantity__c,
                                SBQQ__Opportunity2__r.L2I_Total_Shipset_Credit_Amount__c, SBQQ__Opportunity2__r.L2I_Total_Non_Shipset_Credit_Amount__c,
                                PL_PTS_Total_Cost__c, PL_PTS_Total_Line_Maintenance__c, SBQQ__Opportunity2__r.L2I_Warranty_Cost__c, PL_CAL__c, pl_ProcessLogs__c
                        FROM SBQQ__Quote__c
                        WHERE Id = :QuoteId
                ];

                System.debug('Quote record read : ' + myQuote);
                // get Quote lines
                // Get All Quote Lines Excluding Bundle Level Product
                //
                system.debug('CheckQuoteid' + QuoteId);

                myQL = [
                        SELECT Id, SBQQ__Quote__c, PL_Eff_Inst_Code__c, L2I_TotalListperAircraft__c, L2I_TotalCostperAircraft__c,
                                L2I_TotalPriceperAircraft__c, SBQQ__Product__r.PL_Product_Summary__c, SBQQ__Product__r.PL_Product_Summary__r.name,
                                SBQQ__Product__r.PL_Product_Summary__r.L2I_Migration_External_Id__c, SBQQ__Group__r.SBQQ__SolutionGroup__r.pl_ps__r.name,
                                SBQQ__Product__c, SBQQ__ProductCode__c, SBQQ__Product__r.PL_Product_Summary__r.Translated_Value__c
                        FROM SBQQ__QuoteLine__c
                        WHERE SBQQ__Quote__c = :QuoteId AND SBQQ__Bundle__c != true
                ];
                system.debug('CheckSBQQ__QuoteLine__c' + myql);
                System.debug('# of Quote lines read : ' + myql.size());
                if (myql.size() > 0) {
                    //create sets for quering Product - Install Location to Product Summary Data.
                    for (SBQQ__QuoteLine__c ql : myQL) {
                        if (ql.PL_Eff_Inst_Code__c != null) {
                            myQLProdIds.add(ql.SBQQ__Product__c);
                            myQLInstLocs.add(ql.PL_Eff_Inst_Code__c);
                        }

                        if ((ql.SBQQ__Group__r.SBQQ__SolutionGroup__r.pl_ps__r.name == null || ql.SBQQ__Group__r.SBQQ__SolutionGroup__r.pl_ps__r.name == '')
                                && (ql.SBQQ__Product__r.PL_Product_Summary__r.name == null || ql.SBQQ__Product__r.PL_Product_Summary__r.name == '')) {
                            // missing product summary on install location or on product used.
                            ErrorLogString.add('Product Code : ' + QL.SBQQ__ProductCode__c + ', ' + ql.SBQQ__Group__r.SBQQ__SolutionGroup__r.pl_ps__r.name + '-'
                                    + ql.SBQQ__Product__r.PL_Product_Summary__r.name + '; ');

                        }
                    }
                    // comented out as PL_IL2PS__c is not being used.
                    //pil2psMap = PL_Utils.GetProduct2InstallLocationMap(myQLProdIds, myQLInstLocs);
                }
            }
        } catch (ListException e) {
            updateQuoteProcessLog(e);
        }
    }
    public void updateQuoteProcessLog(ListException e) {
        if (myQuote != null){
            if (e == null ) {
                myQuote.pl_ProcessLogs__c = '' + ErrorLogString;
            } else {
                myQuote.pl_ProcessLogs__c = '' + ErrorLogString + e;
            }
            update myQuote;
        }
    }

    public void delQuotePSData(Id qId) {
        List<PL_PS__c> PSList = new List<PL_PS__c>();
        PSList = [SELECT Id FROM PL_PS__c WHERE Quote__c = :qId];
        System.debug('*** Deleting ProductSummaryRecords for QuoteID :' + qId + 'Size :' + PSList.size() + ' ***');
        if (PSList.size() > 0) {
            delete PSList;
        }
    }
    
    public void updatePLSalesOpp() {
           //W-004396
           Map<ID,L2I_P_L_Sales_Opportunity__c> mapPLSalesOppQuote = new Map<ID,L2I_P_L_Sales_Opportunity__c>([SELECT Id, L2I_Sales_Opportunity__c, PL_Quote_Lookup__c  FROM L2I_P_L_Sales_Opportunity__c WHERE L2I_P_L_Approval__r.ApprovalStatus__c NOT IN ('Approved','Pending') AND L2I_Sales_Opportunity__c =: myQuote.SBQQ__Opportunity2__c]);
           System.debug('myQuote='+ myQuote.Id);
           if(!mapPLSalesOppQuote.isEmpty()){
               for(L2I_P_L_Sales_Opportunity__c  plSalesOpp: mapPLSalesOppQuote.values() ){
                   if(plSalesOpp != null){
                       if(plSalesOpp.PL_Quote_Lookup__c  != myQuote.Id){
                           plSalesOpp.PL_Quote_Lookup__c  = myQuote.Id;
                           updatePLSalesOpp.add(plSalesOpp);
                       }
                   }
               }
           }
           
           if(updatePLSalesOpp.size() > 0){
               update updatePLSalesOpp;
           }
    }
    

    public void createQuotePSData() {
        try {
            //loop all quote line to create Quote Product Summary data pl_ps__c from current quote's quote lines.
            for (SBQQ__QuoteLine__c ql : myQL) {
                if (ql.L2I_TotalListperAircraft__c != 0 || ql.L2I_TotalPriceperAircraft__c != 0 || ql.L2I_TotalCostperAircraft__c != 0) {
                    // process quote line if $ can be rolled up.
                    //Get or create Quote Product Summary record.
                    System.debug('ps key : ' + ql.SBQQ__Product__r.PL_Product_Summary__r.L2I_Migration_External_Id__c);

                    PL_PS__c myQPS = getQPSRecord(getpsKey(ql.PL_Eff_Inst_Code__c, ql.SBQQ__Product__c, ql.SBQQ__Product__r.PL_Product_Summary__r.L2I_Migration_External_Id__c, ql.SBQQ__Product__r.PL_Product_Summary__r.Translated_Value__c));
                    if (ql.L2I_TotalPriceperAircraft__c != 0 && ql.L2I_TotalPriceperAircraft__c != null) {
                        myQPS.Net_Sales__c += ql.L2I_TotalPriceperAircraft__c;
                    }
                    if (ql.L2I_TotalCostperAircraft__c != 0 && ql.L2I_TotalCostperAircraft__c != null) {
                        myQPS.Cost__c += ql.L2I_TotalCostperAircraft__c;
                    }
                    if (ql.L2I_TotalListperAircraft__c != 0 && ql.L2I_TotalListperAircraft__c != null
                            //this needs to be checked as many products are showing list less then price.
                            && ql.L2I_TotalListperAircraft__c > ql.L2I_TotalPriceperAircraft__c) {
                        myQPS.Gross_Sales__c += ql.L2I_TotalListperAircraft__c;
                    } else /*if (myQuote.L2I_Opportunity_Product_Category_Value__c == 'PTS') */ {
                        if (ql.L2I_TotalPriceperAircraft__c != 0 && ql.L2I_TotalPriceperAircraft__c != null) {
                            myQPS.Gross_Sales__c += ql.L2I_TotalPriceperAircraft__c;
                        }
                    }
                }

            }
            // add code related to revise opportunity adjustments.
            if (myQuote.SBQQ__Opportunity2__r.RecordType.DeveloperName == 'Renewal' && myQuote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c != NULL && myQuote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate != NULL &&
                    myQuote.SBQQ__StartDate__c < myQuote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate || test.isRunningTest()) {
                //initialize variables
                Id contractId = myQuote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c;
                Decimal bookingsAdjACServiceMths = myQuote.L2I_Booking_Adj_AC_Service_Months__c;
                Decimal bookingsAdjSubTerm = myQuote.L2I_Bookings_Adj_Subscription_Term__c ;
                for (SBQQ__Subscription__c sub : [
                        SELECT Id, SBQQ__TerminatedDate__c, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.L2I_CPQMultiplier__c,
                                SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c, SBQQ__QuoteLine__r.L2I_Number_of_Shipments__c, SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c,
                                SBQQ__QuoteLine__r.L2I_Service_Activation_Type__c, SBQQ__QuoteLine__r.SBQQ__UnitCost__c, SBQQ__QuoteLine__r.SBQQ__ListPrice__c,
                                SBQQ__QuoteLine__r.PL_Eff_Inst_Code__c, SBQQ__QuoteLine__r.SBQQ__Product__c, SBQQ__QuoteLine__r.SBQQ__Product__r.PL_Product_Summary__r.L2I_Migration_External_Id__c,
                                SBQQ__QuoteLine__r.L2I_TotalListperAircraft__c, SBQQ__QuoteLine__r.L2I_TotalPriceperAircraft__c, SBQQ__QuoteLine__r.L2I_TotalCostperAircraft__c,
                                SBQQ__QuoteLine__r.SBQQ__Product__r.PL_Product_Summary__r.Translated_Value__c
                        FROM SBQQ__Subscription__c
                        WHERE SBQQ__Contract__c = :contractId
                        AND SBQQ__TerminatedDate__c = NULL AND SBQQ__EndDate__c > TODAY
                ]) {
                    System.debug('*** sub ' + sub);
                    System.debug('*** sub.SBQQ__QuoteLine__r.L2I_CPQMultiplier__c ' + sub.SBQQ__QuoteLine__r.L2I_CPQMultiplier__c);
                    Decimal adjGrossSales = 0;
                    Decimal adjCost = 0;
                    Decimal adjNetSales = 0;

                    switch on sub.SBQQ__QuoteLine__r.L2I_CPQMultiplier__c {
                        when 'AC Qty' {         // one-time charge
                            if (sub.SBQQ__QuoteLine__r.L2I_Service_Activation_Type__c == 'OneTime') {
                                if (sub.SBQQ__QuoteLine__r.L2I_TotalListperAircraft__c != null && sub.SBQQ__QuoteLine__r.L2I_TotalListperAircraft__c != 0
                                        && sub.SBQQ__QuoteLine__r.L2I_TotalListperAircraft__c < sub.SBQQ__QuoteLine__r.L2I_TotalPriceperAircraft__c) {
                                    adjGrossSales = sub.SBQQ__QuoteLine__r.L2I_TotalListperAircraft__c;
                                } else if (sub.SBQQ__QuoteLine__r.L2I_TotalPriceperAircraft__c != null && sub.SBQQ__QuoteLine__r.L2I_TotalPriceperAircraft__c != 0) {
                                    adjGrossSales = sub.SBQQ__QuoteLine__r.L2I_TotalPriceperAircraft__c;
                                }
                                if (sub.SBQQ__QuoteLine__r.L2I_TotalCostperAircraft__c != null && sub.SBQQ__QuoteLine__r.L2I_TotalCostperAircraft__c != 0) {
                                    adjCost = sub.SBQQ__QuoteLine__r.L2I_TotalCostperAircraft__c;
                                }
                                if (sub.SBQQ__QuoteLine__r.L2I_TotalPriceperAircraft__c != null && sub.SBQQ__QuoteLine__r.L2I_TotalPriceperAircraft__c != 0) {
                                    adjNetSales = sub.SBQQ__QuoteLine__r.L2I_TotalPriceperAircraft__c;
                                }
                            }
                        }
                        when 'Total AC Service Months' {
                            if (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != NULL && bookingsAdjACServiceMths != null && bookingsAdjACServiceMths != 0) {
                                //bookingsAdjAmt += sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c * bookingsAdjACServiceMths;
                                if (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != null && sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != 0) {
                                    adjNetSales = sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c * bookingsAdjACServiceMths;
                                }
                                if (sub.SBQQ__QuoteLine__r.SBQQ__UnitCost__c != null && sub.SBQQ__QuoteLine__r.SBQQ__UnitCost__c != 0) {
                                    adjCost = sub.SBQQ__QuoteLine__r.SBQQ__UnitCost__c * bookingsAdjACServiceMths;
                                }
                                if (sub.SBQQ__QuoteLine__r.SBQQ__ListPrice__c != null && sub.SBQQ__QuoteLine__r.SBQQ__ListPrice__c != 0
                                        && sub.SBQQ__QuoteLine__r.SBQQ__ListPrice__c < sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c) {
                                    adjGrossSales = sub.SBQQ__QuoteLine__r.SBQQ__ListPrice__c * bookingsAdjACServiceMths;
                                } else if (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != null && sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != 0) {
                                    adjGrossSales = sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c * bookingsAdjACServiceMths;
                                }
                            }
                        }
                        When 'Total AC Service Years' { // for calculating Yearly charge forecast amount
                            if (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != NULL && bookingsAdjACServiceMths != null && bookingsAdjACServiceMths != 0) {
                                if (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != null && sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != 0) {
                                    adjNetSales = sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c * (bookingsAdjACServiceMths / 12);
                                }
                                if (sub.SBQQ__QuoteLine__r.SBQQ__UnitCost__c != null && sub.SBQQ__QuoteLine__r.SBQQ__UnitCost__c != 0) {
                                    adjCost = sub.SBQQ__QuoteLine__r.SBQQ__UnitCost__c * (bookingsAdjACServiceMths / 12);
                                }
                                if (sub.SBQQ__QuoteLine__r.SBQQ__ListPrice__c != null && sub.SBQQ__QuoteLine__r.SBQQ__ListPrice__c != 0
                                        && sub.SBQQ__QuoteLine__r.SBQQ__ListPrice__c < sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c) {
                                    adjGrossSales = sub.SBQQ__QuoteLine__r.SBQQ__ListPrice__c * (bookingsAdjACServiceMths / 12);
                                } else if (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != null && sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != 0) {
                                    adjGrossSales = sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c * (bookingsAdjACServiceMths / 12);
                                }
                            }
                        }
                        when 'Contracted Shipments' {       // media shipments
                            if (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != NULL &&
                                    sub.SBQQ__QuoteLine__r.L2I_Number_of_Shipments__c != NULL &&
                                    sub.SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c != NULL &&
                                    sub.SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c != 0 &&
                                    bookingsAdjSubTerm != null && bookingsAdjSubTerm != 0) {

                                adjNetSales += (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c * bookingsAdjSubTerm *
                                        (sub.SBQQ__QuoteLine__r.L2I_Number_of_Shipments__c /
                                                sub.SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c)).setScale(2);
                                adjCost += (sub.SBQQ__QuoteLine__r.SBQQ__UnitCost__c * bookingsAdjSubTerm *
                                        (sub.SBQQ__QuoteLine__r.L2I_Number_of_Shipments__c /
                                                sub.SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c)).setScale(2);
                                adjGrossSales += (sub.SBQQ__QuoteLine__r.SBQQ__ListPrice__c * bookingsAdjSubTerm *
                                        (sub.SBQQ__QuoteLine__r.L2I_Number_of_Shipments__c /
                                                sub.SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c)).setScale(2);
                            }
                        }
                        when 'Quote Subscription Term' {        // non-aircraft nased standard subscriptions
                            if (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != NULL &&
                                    bookingsAdjSubTerm != null && bookingsAdjSubTerm != 0) {
                                adjNetSales += sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c * bookingsAdjSubTerm;
                                adjCost = sub.SBQQ__QuoteLine__r.SBQQ__UnitCost__c * bookingsAdjSubTerm;
                                adjGrossSales = sub.SBQQ__QuoteLine__r.SBQQ__ListPrice__c * bookingsAdjSubTerm;
                            }
                        }
                        when 'Annual Subscription Term' {       // no products defined yet
                            if (sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c != NULL && sub.SBQQ__QuoteLine__r.l2I_Service_Activation_Type__C != 'Yearly' &&
                                    bookingsAdjSubTerm != null && bookingsAdjSubTerm != 0) {
                                adjNetSales += sub.SBQQ__QuoteLine__r.L2I_MonthlyPrice2__c * (bookingsAdjSubTerm / 12);
                                adjCost = sub.SBQQ__QuoteLine__r.SBQQ__UnitCost__c * (bookingsAdjSubTerm / 12);
                                adjGrossSales = sub.SBQQ__QuoteLine__r.SBQQ__ListPrice__c * (bookingsAdjSubTerm / 12);
                            }
                        }
                    }

                    if (adjNetSales != 0 || adjCost != 0 || adjGrossSales != 0) {
                        PL_PS__c subQPS = getQPSRecord(getpsKey(sub.SBQQ__QuoteLine__r.PL_Eff_Inst_Code__c,
                                sub.SBQQ__QuoteLine__r.SBQQ__Product__c, sub.SBQQ__QuoteLine__r.SBQQ__Product__r.PL_Product_Summary__r.L2I_Migration_External_Id__c, sub.SBQQ__QuoteLine__r.SBQQ__Product__r.PL_Product_Summary__r.Translated_Value__c));

                        if (adjCost != 0) {
                            subQPS.Cost__c -= adjCost;
                        }
                        if (adjNetSales != 0) {
                            subQPS.Net_Sales__c -= adjNetSales;
                        }
                        if (adjGrossSales < adjNetSales && adjNetSales > 0) {
                            subQPS.Gross_Sales__c -= adjNetSales;
                        } else {
                            subQPS.Gross_Sales__c -= adjGrossSales;
                        }
                        System.debug('*** subQPS ' + subQPS);
                    }

                }
            }

            // ship set Credit Spread user story W-002717
            if (myQuote.L2I_Opportunity_Product_Category_Value__c == 'IFEC' && myQuote.SBQQ__Opportunity2__r.L2I_Total_Shipset_Credit_Amount__c > 0
                    && quotePSLst.size() > 0) {
                ShipsetCreditSpread();
            }

            // swarranty cost Spread user story for consolidated display
            if (myQuote.L2I_Opportunity_Product_Category_Value__c == 'IFEC' && myQuote.SBQQ__Opportunity2__r.L2I_Warranty_Cost__c > 0
                    && quotePSLst.size() > 0) {
                WarrantyCostSpread();
            }

            // non Shipset Credit Spread user Story W-
            if (myQuote.SBQQ__Opportunity2__r.L2I_Total_Non_Shipset_Credit_Amount__c > 0 && quotePSLst.size() > 0) {
                NonShipsetCreditSpread();
            }

            // Spread PTS Cost PL_PTS_Total_Cost__c
            if (myQuote.PL_PTS_Total_Cost__c != null && myQuote.L2I_Opportunity_Product_Category_Value__c == 'PTS') { //W-004407
                getQPSRecord('PTS-Maint').Cost__c += myQuote.PL_PTS_Total_Cost__c;
                // Spread PTS Cost PL_PTS_Total_Line_Maintenance__c
            }
            
            if (myQuote.PL_PTS_Total_Line_Maintenance__c != null && myQuote.L2I_Opportunity_Product_Category_Value__c == 'PTS') { //W-004407
                getQPSRecord('PTS-Maint').Line_Maintenance_Cost__c += myQuote.PL_PTS_Total_Line_Maintenance__c;
                getQPSRecord('PTS-Maint').Cost__c += myQuote.PL_PTS_Total_Line_Maintenance__c;
            }
            
            //W-004396
            Map<ID,L2I_P_L_Sales_Opportunity__c> mapPLSalesOppQuote = new Map<ID,L2I_P_L_Sales_Opportunity__c>([SELECT Id, L2I_Sales_Opportunity__c, PL_Quote_Lookup__c  FROM L2I_P_L_Sales_Opportunity__c WHERE L2I_Sales_Opportunity__c =: myQuote.SBQQ__Opportunity2__c]);
           System.debug('myQuote='+ myQuote.Id);
           if(!mapPLSalesOppQuote.isEmpty()){
               for(L2I_P_L_Sales_Opportunity__c  plSalesOpp: mapPLSalesOppQuote.values() ){
                   if(plSalesOpp != null){
                       if(plSalesOpp.PL_Quote_Lookup__c  != myQuote.Id){
                           plSalesOpp.PL_Quote_Lookup__c  = myQuote.Id;
                           updatePLSalesOpp.add(plSalesOpp);
                       }
                   }
               }
           }
           
           if(updatePLSalesOpp.size() > 0){
               update updatePLSalesOpp;
           }

            // insert the quote product summary records
            if (quotePSLst.size() > 0) {
                insert quotePSLst;
                UpdateQuoteTotalCAL();
            }
            // add success message
            ErrorLogString.add('Success fully Completed.');
            // no exceptions to pass
            updateQuoteProcessLog(null);

        } catch (ListException e) {
            updateQuoteProcessLog(e);
        }
    }

    public void UpdateQuoteTotalCAL() {
        AggregateResult [] quoteVals = [SELECT SUM(CAL_COGS__c)cogs, Sum(CAL_AllOtherCost__c)cals FROM PL_PS__c WHERE Quote__c = :myQuote.Id ];
        DEcimal cogs = Integer.valueOf(quoteVals[0].get('cogs'));
        DEcimal cals = Integer.valueOf(quoteVals[0].get('cals'));
        myQuote.PL_CAL__c =  cogs + cals;
        // update quote ifc flag if at least one ifc product summary exists.
        myQuote.is_IFC__c = isIFC;
        myQuote.PL_Business_Pillars__c = strBusinessPillars;
    }

    public void NonShipsetCreditSpread(){
        Id oppId = myQuote.SBQQ__Opportunity2__c;
        // Get Credit Type to PS name map in a map
        Map<String, String> crt2psnMap = new Map<String, String>();
        //name contains migraation key of product summary for credit type mapping data
        for (PL_MD__c md : [SELECT Credit_Type__c, Name FROM PL_MD__c WHERE MD_Type__c = 'CreditType2PS']){
            crt2psnMap.put(md.Credit_Type__c, md.Name);
        }
        // process all non shipset credits
        for (L2I_Credit__c cr : [SELECT id, Name, Credit_Type__c, Credit_Amount__c FROM L2I_Credit__c
                                 WHERE Credit_Type__c != 'Shipset' AND Opportunity__c = :oppId ] ) {
            if (cr.Credit_Amount__c > 0){
                getQPSRecord(crt2psnMap.get(cr.Credit_Type__c).trim()).Credit__c += cr.Credit_Amount__c;
            }
        }
    }

    public void WarrantyCostSpread(){
        Decimal totWarrCost = myQuote.SBQQ__Opportunity2__r.L2I_Warranty_Cost__c;
        // Start - Previous Warranty Allocation Logic --//
        // Decimal TotalGross = 0;
        // System.Debug('Warranty Cost from Opportunity : ' + totWarrCost);
        // for(PL_PS__c qps : quotePSLst){
        //     // if hardware product Summary total up gross sales amount
        //     if(psMDMap.get(qps.PS_Key__c).Sort_Order__c < 100){
        //         TotalGross += qps.Gross_Sales__c;
        //     }
        // }
        // // spread the credit if hardware product summaries exists.
        // if (TotalGross > 0 ) {
        //     System.Debug('Warranty Cost from Opportunity 2: ' + TotalGross);
        //     Decimal WarCostBalance = totWarrCost;
        //     String lastPSKey = '';
        //     for(PL_PS__c qps : quotePSLst){
        //         // if hardware product Summary
        //         if(psMDMap.get(qps.PS_Key__c).Sort_Order__c < 100){
        //             Decimal warCost = (totWarrCost * (qps.Gross_Sales__c/TotalGross));
        //             qps.Warranty_Cost__c = warCost;
        //             WarCostBalance -= warCost;
        //             lastPSKey = qps.PS_Key__c;
        //         }
        //     }

        //     // check if balance is there due to rounding errors then apply to the last ps item
        //     if (lastPSKey != '' && WarCostBalance !=0){
        //         quotePSMap.get(lastPSKey).Warranty_Cost__c += WarCostBalance;
        //     }

        // }else{
        //     // unable to apply credit as no hardware product summary exists.
        // }
        // End - Previous Warranty Allocation Logic -- //
        
        // W-004465 - Start - Updates to P&L Warranty Cost Allocation - Only apply to IFE HW and/or IFC HW
        System.Debug('Warranty Cost from Opportunity : ' + totWarrCost);
        Decimal totalQPSCost = 0;
        for(PL_PS__c qps : quotePSLst){
            // quote product summary with sort order less than 100 are HW products
            if(psMDMap.get(qps.PS_Key__c).Sort_Order__c < 100){
                totalQPSCost += qps.Cost__c;
            }
        }
        System.Debug('==>totalQPSCost: ' + totalQPSCost);
        if(totalQPSCost > 0) {
            Decimal warCostBalance = totWarrCost;
            String lastPSKey = '';
            for(PL_PS__c qps : quotePSLst){
                if(psMDMap.get(qps.PS_Key__c).Sort_Order__c < 100){
                    Decimal warCost = qps.Cost__c * 0.0388; // 3.88% of QPS Cost
                    qps.Warranty_Cost__c = warCost;
                    WarCostBalance -= warCost;
                    lastPSKey = qps.PS_Key__c;
                    System.Debug('==>warCost of ' + qps.PS_Key__c + ': ' + warCost);
                }
            }
            // check if balance is there due to rounding errors then apply to the last ps item
            if (lastPSKey != '' && warCostBalance !=0){
                quotePSMap.get(lastPSKey).Warranty_Cost__c += warCostBalance;
            }
        }
        // W-004465 - End
    }

    public void ShipsetCreditSpread(){
        Decimal totalshipsetCredit = myQuote.SBQQ__Opportunity2__r.L2I_Total_Shipset_Credit_Amount__c;
        Decimal TotalGross = 0;
        for(PL_PS__c qps : quotePSLst){
            // if hardware product Summary total up gross sales amount
            if(psMDMap.get(qps.PS_Key__c).Sort_Order__c < 100){
                TotalGross += qps.Gross_Sales__c;
            }
        }
        // spread the credit if hardware product summaries exists.
        if (TotalGross > 0  ) {
            Decimal CreditBalance = totalshipsetCredit;
            String lastPSKey = '';
            for(PL_PS__c qps : quotePSLst){
                // if hardware product Summary
                if(psMDMap.get(qps.PS_Key__c).Sort_Order__c < 100){
                    Decimal credit = (totalshipsetCredit * (qps.Gross_Sales__c/TotalGross));
                    qps.Credit__c = credit;
                    CreditBalance -= credit;
                    lastPSKey = qps.PS_Key__c;
                }
            }

            // check if balance is there due to rounding errors then apply to the last ps item
            if (lastPSKey != '' && CreditBalance !=0){
                quotePSMap.get(lastPSKey).Credit__c += CreditBalance;
            }

        }else{
            // unable to apply credit as no hardware product summary exists.
        }
    }

    // get Quote product summary record from map by ps name if not found create a new one.
    public PL_PS__c getQPSRecord(String psKey){
        PL_PS__c qpsRecord = quotePSMap.get(psKey);
        if (qpsRecord == null && psKey != null) {
            // create a new record
            // Get product Group based on Product Summary id.
            System.debug('psKey value : ' + psKey);
            qpsRecord = new PL_PS__c();
            qpsRecord.Product_Group__c = pgMap.get(psMDMap.get(psKey).Product_Group__c.trim()).Id;
            qpsRecord.Product_Summary__c = psMDMap.get(psKey).Id;
            qpsRecord.Quote__c = myQuote.Id;
            qpsRecord.Name = psMDMap.get(psKey).Name;
            qpsRecord.PS_Key__c = psKey;
            qpsRecord.Net_Sales__c = 0;
            qpsRecord.Gross_Sales__c = 0;
            qpsRecord.Cost__c = 0;
            qpsRecord.Credit__c = 0;
            qpsRecord.Line_Maintenance_Cost__c = 0;
            quotePSMap.put(psKey, qpsRecord);
            quotePSLst.add(qpsRecord);
        }
        return qpsRecord;
    }

    // get effective ps name based on business logic.
    public String getpsKey(String qlEffInstCode, Id qlProductId, String qlProdPSKey, String tanslatedValue){
        String psKey = '';
        String strBP = '';
        
        //W-004013 changed the Prioritization on how Grouping is created. Check first if Quote Line Record has product Summary defined before trying to group it via Install Location.
        // Get key from Product's Product Summary.
        if (qlProdPSKey != null && qlProdPSKey.trim() != '' ) {
            PSKey = qlProdPSKey;          
        }
        
        // if PSKey is still null get  from install location
        if (PSKey == '' || Pskey == null) {
            if (qlEffInstCode != null && qlEffInstCode.trim() != '') {
                // get product summary id from product inst loc 2 product summary map.
                System.debug('getPSKey  : 1');
                // PL_IL2PS__c not used
                //psKey = pil2psMap.get(qlProductId + ':' + qlEffInstCode.trim());
                //if (psKey == '' || Pskey == null) {
                //System.debug('getPSKey  : 2'+qlEffInstCode);
                // if still null get product summary id by install location
                String psKeyTemp = ilMap.get(qlEffInstCode.trim()).PL_PS__r.L2I_Migration_External_Id__c;
                PSKey = (psKeyTemp != NULL && String.isNotBlank(psKeyTemp)) ? psKeyTemp : 'IFE-S-Other' ;
                //}
            } else {
                // otherwise use default product summary
                PSKey = 'IFE-S-Other';
            }
        }
        
        System.debug('get PS ?Key value : ' + PSKey);
        if (PSKey.contains('IFC')){
            isIFC = true;
            /*if (!strBusinessPillars.contains('IFC')) {
                 strBP = 'IFC';
            }*/
        }
        

        // Updated by Lipton for W-004443
        // Description: Changes the logic to use a new field instead of hard coded values
        String productGroup = '';
        if (String.isNotEmpty(tanslatedValue)) {
            productGroup = tanslatedValue;
        } else if (qlEffInstCode != null && qlEffInstCode.trim() != '') {
            productGroup = ilMap.get(qlEffInstCode.trim()).PL_PS__r.Translated_Value__c ;
        }
        
        if (String.isNotEmpty(productGroup) && !strBusinessPillars.contains(productGroup)) {
            if (strBusinessPillars.length() > 0) {
                strBusinessPillars += '-';
            }
            strBusinessPillars += productGroup;
        }
        
        
        /*else if (PSKey.contains('IFE') && !strBusinessPillars.contains('IFE')){
            strBP = 'IFE';
        }else if (PSKey.contains('DSS')&& !strBusinessPillars.contains('DSS')){
            strBP = 'DSS';
        } else if ( PSKey.contains('PTS') && !strBusinessPillars.contains('PTS')){
            strBP = 'PTS';
        }

        if ( strBP.length() >0){
            if (strBusinessPillars.length() >0){
                strBusinessPillars += '-' + strBP;
            } else {
                strBusinessPillars = strBP;
            }
        }*/
        return PSKey;
    }
}