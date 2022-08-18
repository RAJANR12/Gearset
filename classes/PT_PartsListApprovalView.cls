public without sharing class PT_PartsListApprovalView {
    @AuraEnabled
    public static List<PLApprovalWrapper> getPendingPLApprovals() {
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Map<Id, PT_Program__c> programMap = new Map<Id, PT_Program__c>();
        List<PLApprovalWrapper> pawList = new List<PLApprovalWrapper>();
        List<ProcessInstance> piList = new List<ProcessInstance>();
        piList = [
              SELECT
                    Id, Status,ProcessDefinitionId, ProcessDefinition.Name,
                    TargetObject.Name, TargetObjectId, SubmittedById, SubmittedBy.Name, CreatedDate, ElapsedTimeInDays, (
                    SELECT
                          Id
                          , ActorId
                          , Actor.Name
                          , Comments
                          , CreatedById
                          , CreatedDate
                          ,ElapsedTimeInDays
                          , IsPending
                          , OriginalActorId
                          , OriginalActor.Name
                          , ProcessInstanceId
                          , ProcessNodeId
                          , ProcessNode.Name
                          , StepStatus
                          , TargetObjectId
                          , TargetObject.Name
                    FROM StepsAndWorkitems
                    WHERE IsPending = TRUE
                    ORDER BY ProcessNode.Name
              )
              FROM ProcessInstance
              WHERE Status = 'Pending'
              AND (ProcessDefinition.Name LIKE '%Part List%'
              OR ProcessDefinition.Name LIKE '%MROD%')
              ORDER BY ProcessDefinition.Name
        ];
        for (ProcessInstance pi : piList) {
            if (String.valueOf(pi.TargetObjectId).startsWith('006')) {
                oppMap.put(pi.TargetObjectId, null);
            } else {        // assuming Program if not Opportunity
                programMap.put(pi.TargetObjectId, null);
            }
            for (ProcessInstanceHistory pih : pi.StepsAndWorkitems) {
                // only return users, not queues
                // Part List Approval on;y has a queue approval as the Program Manager is sent email from PT_PartsListApproval class in the SUbmit Part List APproval flow
                if (String.valueOf(pih.ActorId).startsWith('005') ||
                      pi.ProcessDefinition.Name.contains('Part List')) {
                    PLApprovalWrapper paw = new PLApprovalWrapper();
                    paw.approvalId = pi.ProcessDefinitionId;
                    paw.approvalName = pi.ProcessDefinition.Name;
                    paw.submittedById = pi.SubmittedById;
                    paw.submittedByName = pi.SubmittedBy.Name;
                    paw.submittedDate = pi.CreatedDate;
                    paw.submittedElapsedDays = (Date.valueOf(pi.CreatedDate)).daysBetween(System.today());
                    paw.submittedElapsedDays = paw.submittedElapsedDays < 0 ? 0 : paw.submittedElapsedDays;
                    paw.targetObjectId = pih.TargetObjectId;
                    paw.targetObjectName = pih.TargetObject.Name;
                    if (pi.ProcessDefinition.Name.contains('Airbus')){
                        paw.targetObjectName = 'Airbus MROD';
                    } else if (pi.ProcessDefinition.Name.contains('MROD')){
                        paw.targetObjectName = 'MROD';
                    }
                    paw.stepId = pih.Id;
                    paw.stepName = 'Pending ' + pih.ProcessNode.Name;
                    paw.stepCreatedDate = pih.CreatedDate;
//                    paw.stepElapsedDays = Integer.valueOf(pih.ElapsedTimeInDays);
                    paw.stepElapsedDays = (Date.valueOf(pih.CreatedDate)).daysBetween(System.today());
                    paw.stepElapsedDays = paw.stepElapsedDays < 0 ? 0 : paw.stepElapsedDays;
                    paw.stepComments = pih.Comments;
                    pawList.add(paw);
                }
            }
        }
        if (!oppMap.isEmpty()) {
            for (Opportunity opp : [
                  SELECT Id, PT_Program_Mgr__c, PT_Program_Mgr__r.Name, L2I_Program_Num__r.Name,
                        L2I_Program_Num__r.PT_PMO_SubGroup__r.Name, L2I_Program_Num__r.Program_Administrator__r.Name,
                        L2I_Program_Num__r.Operator__r.Name
                  FROM Opportunity
                  WHERE Id IN :oppMap.keySet()
            ]) {
                oppMap.put(opp.Id, opp);
            }
        }
        
        if (!programMap.isEmpty()) {
            for (PT_Program__c prog : [
                  SELECT Id, Name, Program_Manager__c, Program_Manager__r.Name,
                        Principal_Program_Manager__c, Principal_Program_Manager__r.Name,
                        PMO_Regional_Director__c, PMO_Regional_Director__r.Name,
                        PAC_Airbus_Manager__c, PAC_Airbus_Manager__r.Name,
                        PT_PMO_SubGroup__r.Name, Program_Administrator__r.Name, Operator__r.Name
                  FROM PT_Program__c
                  WHERE Id IN :programMap.keySet()
            ]) {
                programMap.put(prog.Id, prog);
            }
        }
        
        for (PLApprovalWrapper paw : pawList) {
            if (oppMap.containsKey(paw.targetObjectId)) {
                paw.progMgrId = oppMap.get(paw.targetObjectId).PT_Program_Mgr__c;
                paw.progMgrName = oppMap.get(paw.targetObjectId).PT_Program_Mgr__r.Name;
                paw.targetObjectType = 'Opportunity';
                paw.programName = oppMap.get(paw.targetObjectId).L2I_Program_Num__r.Name;
                paw.subGroup = oppMap.get(paw.targetObjectId).L2I_Program_Num__r.PT_PMO_SubGroup__r.Name;
                paw.customer = oppMap.get(paw.targetObjectId).L2I_Program_Num__r.Operator__r.Name;
                paw.programAdmin = oppMap.get(paw.targetObjectId).L2I_Program_Num__r.Program_Administrator__r.Name;
            }
            if (programMap.containsKey(paw.targetObjectId)) {
                paw.progMgrId = programMap.get(paw.targetObjectId).Program_Manager__c;
                paw.progMgrName = programMap.get(paw.targetObjectId).Program_Manager__r.Name;
                paw.ppmId = programMap.get(paw.targetObjectId).Principal_Program_Manager__c;
                paw.ppmName = programMap.get(paw.targetObjectId).Principal_Program_Manager__r.Name;
                paw.rdId = programMap.get(paw.targetObjectId).PMO_Regional_Director__c;
                paw.rdName = programMap.get(paw.targetObjectId).PMO_Regional_Director__r.Name;
                paw.airbusId = programMap.get(paw.targetObjectId).PAC_Airbus_Manager__c;
                paw.airbusName = programMap.get(paw.targetObjectId).PAC_Airbus_Manager__r.Name;
                paw.targetObjectType = 'Program';
                paw.programName = programMap.get(paw.targetObjectId).Name;
                paw.subGroup = programMap.get(paw.targetObjectId).PT_PMO_SubGroup__r.Name;
                paw.customer = programMap.get(paw.targetObjectId).Operator__r.Name;
                paw.programAdmin = programMap.get(paw.targetObjectId).Program_Administrator__r.Name;
            }
        }
        return pawList;
    }
    
    public class PLApprovalWrapper {
        @AuraEnabled public String approvalId { get; set; }
        @AuraEnabled public String approvalName { get; set; }
        @AuraEnabled public String submittedById { get; set; }
        @AuraEnabled public String submittedByName { get; set; }
        @AuraEnabled public DateTime submittedDate { get; set; }
        @AuraEnabled public Integer submittedElapsedDays { get; set; }
        @AuraEnabled public String targetObjectId { get; set; }
        @AuraEnabled public String targetObjectType { get; set; }
        @AuraEnabled public String targetObjectName { get; set; }
        @AuraEnabled public String stepId { get; set; }
        @AuraEnabled public String stepName { get; set; }
        @AuraEnabled public DateTime stepCreatedDate { get; set; }
        @AuraEnabled public Integer stepElapsedDays { get; set; }
        @AuraEnabled public String stepComments { get; set; }
        @AuraEnabled public String progMgrId { get; set; }
        @AuraEnabled public String progMgrName { get; set; }
        @AuraEnabled public String ppmId { get; set; }
        @AuraEnabled public String ppmName { get; set; }
        @AuraEnabled public String rdId { get; set; }
        @AuraEnabled public String rdName { get; set; }
        @AuraEnabled public String airbusId { get; set; }
        @AuraEnabled public String airbusName { get; set; }
        @AuraEnabled public String Msg { get; set; }
        @AuraEnabled public String linkTarget { get; set; }
        @AuraEnabled public String programName { get; set; }
        @AuraEnabled public String subGroup { get; set; }
        @AuraEnabled public String customer { get; set; }
        @AuraEnabled public String programAdmin { get; set; }
        
        public PLApprovalWrapper() {
            this.linkTarget = 'link';
        }
    
    }
}