/**
 *      @author       Sarah Kennedy
 *      @date         06/25/2020
 *      @description  L2I_AE_CreateOppQuoteBatch - AutoExtend Batch creates Revise Opportunity and Quote from Contract
 *      This class can be run as a Batch or a Schedulable that calls the Batch.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 06/25/2020         Initial scaffold
 *
 */
global class L2I_AE_CreateOppQuoteBatch implements Database.Batchable<SObject>, Database.Stateful {
    private L2I_LoggingStringBuffer logBuffer;
    private L2I_Order_Activation_Execution_Log__c oaeLog;
    private String logGuid = '';
    private Set<Id> allContractIds = new Set<Id>();
    private Set<Id> contractErrorIds = new Set<Id>();
    private String contractErrorMsg = '';
    private String logStatus = 'Completed';
    
    public L2I_AE_CreateOppQuoteBatch() {
        // for independent batch run
    }
    
    public L2I_AE_CreateOppQuoteBatch(String guid) {
        logGuid = guid;
        logBuffer = new L2I_LoggingStringBuffer();
        logBuffer.append('Executing AutoExtend Step 1');
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('*** Starting L2I_AE_CreateOppQuoteBatch');
        Date tomorrow = Date.today().addDays(1);
        System.debug('*** tomorrow ' + tomorrow);
        String query = 'SELECT Id, ContractNumber ' +
              ' FROM Contract ' +
              ' WHERE Status = \'Activated\' ' +
              ' AND L2I_Auto_Extend__c <= :tomorrow' +
              ' AND L2I_Last_Auto_Extend_Processed__c = NULL ' +
              ' AND L2I_OrderActivationAlert__c = NULL ';
        System.debug('*** query ' + query);
//        System.debug('*** result ' + [SELECT Id, ContractNumber, L2I_Auto_Extend__c, L2I_Last_Auto_Extend_Processed__c, status, L2I_OrderActivationAlert__c , L2I_Terminated__c     FROM Contract  WHERE L2I_Terminated__c = false  AND Status = 'Activated'
//        AND L2I_Auto_Extend__c <= :tomorrow AND L2I_Last_Auto_Extend_Processed__c = NULL  AND L2I_OrderActivationAlert__c = NULL]);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        System.debug('*** Executing L2I_AE_CreateOppQuoteBatch');
        
        List<Contract> contracts = (List<Contract>) scope;
        Set<Id> validContractIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        Set<String> contractsIdNbr = new Set<String>();
        Set<Id> contractsWithValidSubscriptions = new Set<Id>();
        Set<Id> contractsWithValidOpportunities = new Set<Id>();
        System.debug('*** contracts.size() ' + contracts.size());
        Savepoint sp = Database.setSavepoint();
        try {
            if (contracts.size() != 1) {
                if (logGuid != '') {
                    logBuffer.append('Skipping processing: Batch Size not = 1');
                    logStatus = 'Encountered Exception';
                }
            } else {
                for (Contract ctr : contracts) {
                    contractIds.add(ctr.Id);
                    contractsIdNbr.add(ctr.ContractNumber + ' (' + ctr.Id + ') ');
                }
                String idStr = '';
                for (String s : contractsIdNbr) {
                    idStr += (idStr == '' ? '' : ',') + s;
                }
                if (logGuid != '') {
                    logBuffer.append('Contracts identified: ' + idStr);
                }
                
                System.debug('*** contractIds in ' + contractIds);
                // validate that the contracts have valid subscriptions and opportunities
                contractsWithValidSubscriptions = validSubscriptions(contractIds);
                System.debug('*** subscription valid contracts ' + contractsWithValidSubscriptions);
                if (!contractsWithValidSubscriptions.isEmpty()) {
                    contractsWithValidOpportunities = validOpportunities(contractIds);
                    System.debug('*** opportunities with valid contracts ' + contractsWithValidOpportunities);
                    if (!contractsWithValidOpportunities.isEmpty()) {
                        // find the common Contracts that pass both validations
                        for (String s : contractsWithValidSubscriptions) {
                            if (contractsWithValidOpportunities.contains(s)) {
                                validContractIds.add(s);
                            }
                        }
                        // keep a running list of all Contract Ids across all batches
                        allContractIds.addAll(validContractIds);
                        System.debug('*** allContractIds ' + allContractIds);
                        System.debug('*** validContractIds ' + validContractIds);
                        //do updates
                        System.debug('*** AE Create Opportunity and Quote Batch validContractIds ' + validContractIds.size());
                        Set<Id> renewalOppIds = new Set<Id>();
                        Set<Id> renewalQuoteIds = new Set<Id>();
                        Map<Id, Date> oppIdContractDate = new Map<Id, Date>();
                        List<Contract> cList = [
                              SELECT Id,
                                    SBQQ__RenewalQuoted__c,
                                    L2I_Last_Auto_Extend_Processed__c,
                                    SBQQ__RenewalOpportunity__c,
                                    L2I_Auto_Extend__c,
                                    SBQQ__Quote__c,
                                    StartDate,
                                    SBQQ__RenewalTerm__c,
                                    EndDate
                              FROM Contract
                              WHERE Id IN :validContractIds
                        ];
                        for (Contract c : cList) {
                            c.SBQQ__RenewalQuoted__c = true;
                            c.L2I_Last_Auto_Extend_Processed__c = DateTime.now();
                        }
                        System.debug('*** cList for update ' + cList);
                        if (cList != null && cList.size() > 0) {
                            update cList;
                        }
                        System.debug('*** after cList update ');
                    }
                }
            }
        } catch (Exception e) {
            Database.rollback(sp);
            contractErrorIds.addAll(validContractIds);
            contractErrorMsg = e.getMessage() + ' ' + e.getStackTraceString();
            if (contractErrorMsg != '') {
                setException(contractErrorMsg, contractErrorIds);
            }
            contractErrorIds.clear();
            contractErrorMsg = '';
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug('*** Finishing L2I_AE_CreateOppQuoteBatch');
        if (!allContractIds.isEmpty()) {
            if (logGuid != '') {
                logBuffer.append('Processed Contracts: ' + allContractIds);
            }
        }
        
        if (logGuid != '') {
            String logTrace = logBuffer.toStr();
            if (logTrace.length() > L2I_StaticConstants.LONGTEXT_AREA_LIMIT) {
                logTrace = logTrace.substring(0, L2I_StaticConstants.LONGTEXT_AREA_LIMIT);
            }
            oaeLog = L2I_OAExecutionLog_Helper.getLogEntry(logGuid);
            oaeLog.Step1_Status__c = logStatus;
            oaeLog.Step1_Log_Message__c = logTrace;
            L2I_OAExecutionLog_Helper.updateLogEntry(oaeLog);
    
            // call the next step
            Datetime now = System.now();
            Integer minsOffset = 1; // Schedule it a minute after the final batch has been completed.
            String cronTab = L2I_UtilityHelper.getCRONexpression(now, 0, minsOffset, 0);
    
            if (!Test.isRunningTest()) {
                L2I_AE_PrepareQuoteSched step2 = new L2I_AE_PrepareQuoteSched(logGuid);
                String jobId = System.schedule('AutoExtend Step2 ' + logGuid, cronTab, step2);
                System.debug('AutoExtend Step 2 ' + logGuid + ' has been scheduled as :' + jobId);
            }
        }
    }
    
    private Set<Id> validSubscriptions(Set<Id> contractIds) {
        Set<Id> validContractIds = new Set<Id>();
        for (SBQQ__Subscription__c sub : [
              SELECT Id,
                    SBQQ__Contract__c
              FROM SBQQ__Subscription__c
              WHERE SBQQ__Contract__c IN :contractIds
              AND SBQQ__TerminatedDate__c = NULL
              AND SBQQ__SubscriptionType__c = 'Renewable'
        ]) {
            validContractIds.add(sub.SBQQ__Contract__c);
        }
        return validContractIds;
    }
    
    private Set<Id> validOpportunities(Set<Id> contractIds) {
        Set<Id> validContractIds = new Set<Id>();
        validContractIds.addAll(contractIds);
        System.debug('*** Starting validOpportunities validContractIds ' + validContractIds);
        Set<Id> opptyIds = new Set<Id>();
        // check for any open opportunities
        for (Opportunity oppty : [
              SELECT Id,
                    StageName,
                    SBQQ__RenewedContract__c,
                    SBQQ__AmendedContract__c
              FROM Opportunity
              WHERE (SBQQ__RenewedContract__c IN :contractIds
              OR SBQQ__AmendedContract__c IN :contractIds)
        ]) {
            Id cId;
            if (oppty.SBQQ__RenewedContract__c != NULL) {
                cId = oppty.SBQQ__RenewedContract__c;
            }
            if (oppty.SBQQ__AmendedContract__c != NULL) {
                cId = oppty.SBQQ__AmendedContract__c;
            }
            if (oppty.StageName != 'Closed Won' &&
                  oppty.StageName != 'Pending Close' &&
                  oppty.StageName != 'Cancelled' &&
                  oppty.StageName != 'No Bid' &&
                  oppty.StageName != 'Closed Lost' &&
                  oppty.StageName != 'Closed') {
                if (validContractIds.contains(cId)) {
                    validContractIds.remove(cId);
                }
            }
        }
        if (!validContractIds.isEmpty()) {
            // check for any pending orders for the valid contracts we found
            for (Contract c : [
                  SELECT Id,
                        SBQQ__Order__c,
                        SBQQ__Order__r.Status
                  FROM Contract
                  WHERE Id IN :validContractIds
            ]) {
                // remove contract from list is there are pending orders
                if (c.SBQQ__Order__r.Status == 'Draft') {
                    if (validContractIds.contains(c.Id)) {
                        validContractIds.remove(c.Id);
                    }
                }
            }
        }
        return validContractIds;
    }
    
    @TestVisible
    private void setException(String msgs, Set<Id> validContractIds) {
        System.debug('*** Starting setException validContractIds ' + validContractIds);
        Id systemAlertId = L2I_SystemAlertNotifier.createSystemAlert('Batch Job Exception',
              'DML Exception occurred while setting creating AutoExtend Opportunity and Quote :' + msgs,
              'Contract', 'see Order Contract Management Log', UserInfo.getUserId(), false);
    
        if (!validContractIds.isEmpty()) {
            List<Contract> cList = [SELECT Id, L2I_OrderActivationAlert__c FROM Contract WHERE Id IN :validContractIds];
            for (Contract c : cList) {
                c.L2I_OrderActivationAlert__c = systemAlertId;
            }
            if (cList != NULL && cList.size() > 0) {
                update cList;
            }
        }
        if (logGuid != '') {
            logStatus = 'Encountered Exception';
            logBuffer.append('Exception occurred while setting creating AutoExtend Create Opportunity and Quote :' + msgs + ' for Contracts ' + validContractIds);
        }
    }
}