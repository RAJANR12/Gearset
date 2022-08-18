public class L2I_CreateUsageRecords {
    
    public static boolean createUsageRecords(AggregateResult[] acServiceAgResult, Date batchRunDate) {
        
        List<blng__Usage__c> newUsageList = new List<blng__Usage__c>();

        for (AggregateResult ar : acServiceAgResult) {
            String matchingId = String.valueOf(ar.get('billMatch'));
            System.debug('*** Record Count ' + ar.get('recCount'));
            System.debug('*** Bill Matching Id ' + ar.get('billMatch'));
            
            Decimal count = Decimal.valueOf(Integer.valueOf(ar.get('recCount')));
            
            if (count > 0) {
                
                System.debug('*** filter criteria: ' + matchingId + ' - ' + batchRunDate);
                List<blng__UsageSummary__c> usageSummaries = new List<blng__UsageSummary__c>();
                usageSummaries = [
                      SELECT Id,
                            Name,
                            blng__SummaryStartDate__c,
                            blng__SummaryEndDate__c,
                            blng__MatchingId__c,
                            blng__InvoiceRunProcessingStatus__c,
                              L2I_Non_Prorated__c,
                              L2I_Active_Aircraft_Count__c,
                              L2I_Non_Prorated_Usage_Created__c
                      FROM blng__UsageSummary__c
                      WHERE blng__MatchingId__c = :matchingId
                      AND blng__SummaryStartDate__c <= :batchRunDate
                      AND blng__SummaryEndDate__c >= :batchRunDate
                      AND blng__Status__c <> 'Cancelled'
                      AND (blng__OverrideSummaryStartDate__c = NULL
                        OR blng__OverrideSummaryStartDate__c <= :batchRunDate)
                      AND (blng__OverrideSummaryEndDate__c = NULL
                        OR blng__OverrideSummaryEndDate__c >= :batchRunDate)
                      AND (blng__InvoiceRunProcessingStatus__c = NULL
                        OR blng__InvoiceRunProcessingStatus__c = ''
                        OR blng__InvoiceRunProcessingStatus__c = 'Pending Billing')
                ];
                
                System.debug('*** usageSummaries.size() ' + usageSummaries.size());
                
                if (usageSummaries.size() == 1) {
                    
                    System.debug('*** usageSummaries: ' + usageSummaries[0]);
                    blng__UsageSummary__c bus = usageSummaries[0];
                    // fix for DE381
                    Decimal daysInSummaryPeriod = bus.blng__SummaryStartDate__c.daysBetween(bus.blng__SummaryEndDate__c) + 1.0;
                    Decimal countFormula = count / daysInSummaryPeriod;
                    System.debug('*** daysInSummaryPeriod: ' + daysInSummaryPeriod + ' - ' + countFormula);
                    
                    List<blng__Usage__c> existingUsage = new List<blng__Usage__c>();
                    
                    //US1936 Added L2I_Tail_Count_Created_By_Usage_Batch__c update to Daily Usage duplicate check
                    existingUsage = [
                          SELECT Id,
                                blng__MatchingId__c,
                                blng__StartDateTime__c,
                                blng__EndDateTime__c
                          FROM blng__Usage__c
                          WHERE blng__EndDateTime__c = :batchRunDate
                          AND blng__MatchingId__c = :matchingId
                          AND L2I_Tail_Count_Created_By_Usage_Batch__c = TRUE
                    ];
                    
                    System.debug('*** existingUsage.size() ' + existingUsage.size());
                    if (existingUsage.size() == 0) {
                        System.debug('*** existingUsage: ' + existingUsage);
                        System.debug('*** mid: ' + matchingId);
                        blng__Usage__c usage = new blng__Usage__c();
                        Time noonTime = Time.newInstance(12, 0, 0, 0);
                        DateTime dt = DateTime.newInstance(batchRunDate, noonTime);
                        Boolean busUpdated = false;
                        Boolean inertUsage = false;
                        // if Product is Prorated then create usage in this manner
                        if (!bus.L2I_Non_Prorated__c){
                            usage.blng__StartDateTime__c = dt;
                            usage.blng__EndDateTime__c = dt;
                            usage.blng__Quantity__c = count / daysInSummaryPeriod; // must be in Decimal with adequate precision 15.3
                            usage.L2I_Actual_Quantity__c = count / daysInSummaryPeriod;
                            usage.blng__MatchingId__c = matchingId;
                            // US1936 Added L2I_Tail_Count_Created_By_Usage_Batch__c update to Daily Usage record
                            usage.L2I_Tail_Count_Created_By_Usage_Batch__c = true;
                            newUsageList.add(usage);
                            inertUsage = true;
                        } else if (!bus.L2I_Non_Prorated_Usage_Created__c) {
                            System.debug('@@@@ Entering non prorated.');
                            if (bus.L2I_Active_Aircraft_Count__c < count || bus.L2I_Active_Aircraft_Count__c == null) {
                                bus.L2I_Active_Aircraft_Count__c = count;
                                busUpdated = true;
                                System.debug('@@@@ Updating non prorated Count.');
                            }
                            if (!bus.L2I_Non_Prorated_Usage_Created__c && bus.blng__SummaryEndDate__c == batchRunDate ){
                                bus.L2I_Non_Prorated_Usage_Created__c = true;
                                busUpdated = true;
                                System.debug('@@@@ Creating non prorated usage record');

                                usage.blng__StartDateTime__c = bus.blng__SummaryStartDate__c;
                                usage.blng__EndDateTime__c = dt;
                                usage.blng__Quantity__c = count;
                                usage.L2I_Actual_Quantity__c = count;
                                usage.blng__MatchingId__c = matchingId;
                                // US1936 Added L2I_Tail_Count_Created_By_Usage_Batch__c update to Daily Usage record
                                usage.L2I_Tail_Count_Created_By_Usage_Batch__c = true;
                                newUsageList.add(usage);
                                inertUsage = true;
                            }

                        }
                        if (inertUsage || busUpdated) {
                            try {

                                System.debug('*** usage: ' + usage);
                                if (inertUsage) {
                                    insert usage;
                                }
                                System.debug('*** after insert');
                                if (busUpdated) {
                                    update bus;
                                }
                                Boolean logSuccess = [
                                        SELECT Log_Usage_Batch_Successes__c
                                        FROM L2I_General_Settings__mdt
                                ][0].Log_Usage_Batch_Successes__c;

                                if (Test.isRunningTest()) {
                                    logSuccess = true;
                                }

                                if (logSuccess) {
                                    L2I_Usage_Batch_Execution_Log__c ubel = new L2I_Usage_Batch_Execution_Log__c();
                                    ubel.Status__c = 'Success';
                                    ubel.Number_of_Records__c = newUsageList.size();
                                    ubel.Batch_Run_Date__c = batchRunDate;
                                    ubel.Exception__c = 'On Matching Id: ' + matchingId + ' and Usage Summary Id: ' + usageSummaries[0].Id;
                                    insert ubel;
                                }

                            } catch (DmlException dmle) {

                                System.debug('====== Exception Error Message :\n' + dmle.getMessage() + ' ' + dmle.getStackTraceString() + ' ' + dmle.getCause());
                                L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
                                        'DML Exception occured while creating Usage Records: ' + dmle.getMessage());

                                L2I_Usage_Batch_Execution_Log__c ubel = new L2I_Usage_Batch_Execution_Log__c();
                                ubel.Status__c = 'Failure';
                                ubel.Number_of_Records__c = newUsageList.size();
                                ubel.Batch_Run_Date__c = batchRunDate;
                                ubel.Exception__c = dmle.getMessage() + ' on Matching Id: ' + matchingId + ' and Usage Summary Id: ' + usageSummaries[0].Id;
                                insert ubel;

                            }
                        }
                    }
                } else {
                    System.debug('usageSummaries.size() != 1: ' + usageSummaries.size());
                    L2I_Usage_Batch_Execution_Log__c ubel = new L2I_Usage_Batch_Execution_Log__c();
                    ubel.Status__c = 'Failure';
                    ubel.Number_of_Records__c = newUsageList.size();
                    ubel.Batch_Run_Date__c = batchRunDate;
                    ubel.Exception__c = 'We are unable to find an exact, single Usage Summary record. Usage Summaries size: ' + usageSummaries.size() + ' on Matching Id: ' + matchingId;
                    insert ubel;
                }
            }
        }
        return true;
    }
    
    public static boolean reconcileUsageRecords(List<L2I_Aircraft_Service__c> affectedAircraftServices, Date batchRunDate) {
        System.debug('*** in reconcileUsageRecords affectedAircraftServices.size ' + affectedAircraftServices.size());
        List<blng__Usage__c> newUsageList = new List<blng__Usage__c>();
        List<L2I_Aircraft_Service__c> updateAircraftServiceList = new List<L2I_Aircraft_Service__c>();
        
        for (L2I_Aircraft_Service__c las : affectedAircraftServices) {

            if (las.L2I_Deactivation_Adjustment_Needed__c == true && las.L2I_Deactivation_Date__c >= batchRunDate) {
                las.L2I_Deactivation_Adjustment_Needed__c = false;
                updateAircraftServiceList.add(las);

            } else if (las.L2I_Activation_Adjustment_Needed__c == true && las.L2I_Activation_Date__c >= batchRunDate) {
                las.L2I_Activation_Adjustment_Needed__c = false;
                updateAircraftServiceList.add(las);

            } else {
                System.debug('*** filter criteria: ' + las.Matching_Id__c + ' - ' + batchRunDate);
                List<blng__UsageSummary__c> usageSummaries = new List<blng__UsageSummary__c>();
                usageSummaries = [
                        SELECT Id,
                                Name,
                                blng__SummaryStartDate__c,
                                blng__SummaryEndDate__c,
                                blng__InvoiceRunProcessingStatus__c
                        FROM blng__UsageSummary__c
                        WHERE blng__MatchingId__c = :las.Matching_Id__c
                        AND blng__SummaryStartDate__c <= :batchRunDate
                        AND blng__SummaryEndDate__c >= :batchRunDate
                        AND blng__Status__c <> 'Cancelled'
                        AND (blng__OverrideSummaryStartDate__c = NULL
                        OR blng__OverrideSummaryStartDate__c <= :batchRunDate)
                        AND (blng__OverrideSummaryEndDate__c = NULL
                        OR blng__OverrideSummaryEndDate__c >= :batchRunDate)
                        AND (blng__InvoiceRunProcessingStatus__c = NULL
                        OR blng__InvoiceRunProcessingStatus__c = ''
                        OR blng__InvoiceRunProcessingStatus__c = 'Pending Billing')];

                Date adjustedBatchDate = batchRunDate - 1;
                System.debug('*** usageSummaries.size() ' + usageSummaries.size() + ' - ' + batchRunDate);
                if (usageSummaries.size() == 1) {
                    System.debug('*** usageSummaries: ' + usageSummaries[0]);
                }

                if (las.Service_Activation_Type__c == 'Monthly') {

                    if (usageSummaries.size() == 1 &&
                            ((las.L2I_Activation_Adjustment_Needed__c == true && usageSummaries[0].blng__SummaryStartDate__c <= las.L2I_Activation_Date__c)
                                    || (las.L2I_Deactivation_Adjustment_Needed__c == true && usageSummaries[0].blng__SummaryStartDate__c <= las.L2I_Deactivation_Date__c))) {
                        blng__UsageSummary__c bus = usageSummaries[0];
                        // fix for DE381
                        Integer daysInSummaryPeriod = bus.blng__SummaryStartDate__c.daysBetween(bus.blng__SummaryEndDate__c) + 1;

                        blng__Usage__c usage = new blng__Usage__c();
                        usage.blng__EndDateTime__c = adjustedBatchDate;
                        if (las.L2I_Activation_Adjustment_Needed__c == true) {
                            System.debug('*** activation adjustment needed');
                            Date activationDate = date.newinstance(las.L2I_Activation_Date__c.year(), las.L2I_Activation_Date__c.month(), las.L2I_Activation_Date__c.day());
                            Time noonTime = Time.newInstance(12, 0, 0, 0);
                            DateTime dt = DateTime.newInstance(activationDate, noonTime);
                            usage.blng__StartDateTime__c = dt;
                            // fix for DE381
                            usage.blng__Quantity__c = (Decimal.valueOf(adjustedBatchDate.daysBetween(activationDate)) + 1.0) / Decimal.valueOf(daysInSummaryPeriod);
                            usage.L2I_Actual_Quantity__c = (Decimal.valueOf(adjustedBatchDate.daysBetween(activationDate)) + 1.0) / Decimal.valueOf(daysInSummaryPeriod);
                            System.debug('*** daysInSummaryPeriod ' + daysInSummaryPeriod);
                            System.debug('*** adjustedBatchDate ' + adjustedBatchDate);
                            System.debug('*** activationDate ' + activationDate);
                            las.L2I_Activation_Adjustment_Needed__c = false;
                            updateAircraftServiceList.add(las);
                        } else if (las.L2I_Deactivation_Adjustment_Needed__c == true) {
                            System.debug('*** deactivation adjustment needed');
                            Date deactivationDate = date.newinstance(las.L2I_Deactivation_Date__c.year(), las.L2I_Deactivation_Date__c.month(), las.L2I_Deactivation_Date__c.day());
                            Time noonTime = Time.newInstance(12, 0, 0, 0);
                            DateTime dt = DateTime.newInstance(deactivationDate, noonTime);
                            usage.blng__StartDateTime__c = dt;
                            // fix for DE381
                            usage.blng__Quantity__c = -1.00 * ((Decimal.valueOf(adjustedBatchDate.daysBetween(deactivationDate)) + 1.0) / Decimal.valueOf(daysInSummaryPeriod));
                            usage.L2I_Actual_Quantity__c = -1.00 * ((Decimal.valueOf(adjustedBatchDate.daysBetween(deactivationDate)) + 1.0) / Decimal.valueOf(daysInSummaryPeriod));
                            las.L2I_Deactivation_Adjustment_Needed__c = false;
                            updateAircraftServiceList.add(las);
                        }
                        usage.blng__MatchingId__c = las.Matching_Id__c;
                        System.debug('*** usage: ' + usage);
                        newUsageList.add(usage);
                        System.debug('*** newUsageList size: ' + newUsageList.size());

                    } else {
                        System.debug('*** checking manual ' + las.L2I_Activation_Adjustment_Needed__c);
                        if (las.L2I_Activation_Adjustment_Needed__c == true) {
                            las.Manual_Adjustment_Needed__c = true;
                            // refactor with a custom label - Manual_Activation_Adjustment_Needed
                            las.Manual_Adjustment_Notes__c = Label.Manual_Activation_Adjustment_Needed + adjustedBatchDate;
                            las.L2I_Activation_Adjustment_Needed__c = false;
                            updateAircraftServiceList.add(las);
                        } else if (las.L2I_Deactivation_Adjustment_Needed__c == true) {
                            las.Manual_Adjustment_Needed__c = true;
                            // refactor with a custom label -> Manual_Deactivation_Adjustment_Needed
                            las.Manual_Adjustment_Notes__c = Label.Manual_Deactivation_Adjustment_Needed + adjustedBatchDate;
                            las.L2I_Deactivation_Adjustment_Needed__c = false;
                            updateAircraftServiceList.add(las);
                        }
                    }
                } else if (las.service_Activation_Type__C == 'OneTime' && usageSummaries.size() == 1){
                    System.debug('*** In Servce Activaton Type = Onetime ***');
                    las.L2I_OneTime_Billed__c = batchRunDate;
                    updateAircraftServiceList.add(las);

                    blng__Usage__c u = new blng__Usage__c();
                    u.blng__EndDateTime__c = batchRunDate;
                    u.blng__StartDateTime__c = batchRunDate;
                    u.blng__Quantity__c = 1.00;
                    u.L2I_Actual_Quantity__c = 1.00;
                    u.blng__MatchingId__c = las.Matching_Id__c;     // SK added 12/22/2020

                    newUsageList.add(u);

                } else if (las.Service_Activation_Type__c == 'Yearly' && usageSummaries.size() == 1) {
                    System.debug('*** In Servce Activaton Type = Yearly ***');
                    // add a year for next year billing.
                    las.Yearly_Bill_Date__c = las.Yearly_Bill_Date__c.addYears(1);
                    updateAircraftServiceList.add(las);

                    blng__Usage__c u = new blng__Usage__c();
                    u.blng__EndDateTime__c = batchRunDate;
                    u.blng__StartDateTime__c = batchRunDate;
                    u.blng__Quantity__c = 1.00;
                    u.L2I_Actual_Quantity__c = 1.00;
                    u.blng__MatchingId__c = las.Matching_Id__c;     // SK added 12/22/2020

                    newUsageList.add(u);
                }
            }
        }
        
        try {
            
            if (newUsageList.size() > 0) {
                System.debug('*** newUsageList ' + newUsageList);
                System.debug('*** reconcile b4 newUsageList insert');
                insert newUsageList;
                System.debug('*** reconcile after newUsageList insert');
            }
            
            Boolean logSuccess = [
                  SELECT Log_Usage_Batch_Successes__c
                  FROM L2I_General_Settings__mdt
            ][0].Log_Usage_Batch_Successes__c;
            
            if (Test.isRunningTest()) {
                logSuccess = true;
            }
            
            if (logSuccess) {
                L2I_Usage_Batch_Execution_Log__c ubel = new L2I_Usage_Batch_Execution_Log__c();
                ubel.Status__c = 'Success';
                ubel.Number_of_Records__c = newUsageList.size();
                ubel.Batch_Run_Date__c = batchRunDate;
                ubel.Exception__c = String.valueOf(newUsageList);
                insert ubel;
            }
            
            System.debug('*** updateAircraftServiceList.size(): ' + updateAircraftServiceList.size());
            if (updateAircraftServiceList.size() > 0) {
                System.debug('update run updateAircraftServiceList');
                update updateAircraftServiceList;
            }
        
        } catch (DmlException dmle) {
            
            System.debug('====== Exception Error Message :\n' + dmle.getMessage());
            L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
                  'DML Exception occured while running the Adjustment Usage Batch: ' + dmle.getMessage());
            
            L2I_Usage_Batch_Execution_Log__c ubel = new L2I_Usage_Batch_Execution_Log__c();
            ubel.Status__c = 'Failure';
            ubel.Number_of_Records__c = newUsageList.size();
            ubel.Batch_Run_Date__c = batchRunDate;
            ubel.Exception__c = dmle.getMessage() + ' on Usage List: ' + String.valueOf(newUsageList);
            insert ubel;
        
        }
        
        return true;
    }
}