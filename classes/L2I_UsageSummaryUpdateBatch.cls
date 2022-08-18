public class L2I_UsageSummaryUpdateBatch implements Database.Batchable<blng__UsageSummary__c>, Database.Stateful, Schedulable {
    
    Set<String> orderIds;
    Date todayDate;
    
    public L2I_UsageSummaryUpdateBatch() {}
    
    public L2I_UsageSummaryUpdateBatch(Set<String> orderIds) {
        this.orderIds = orderIds;
    }
    
    public List<blng__UsageSummary__c> start(Database.BatchableContext bc) {
        todayDate = System.today();
        if(orderIds != null) {
            return [Select Id, blng__OverrideSummaryStartDate__c, blng__SummaryEndDate__c From blng__UsageSummary__c Where blng__Order__c in : orderIds];
        }
        return [Select Id, blng__OverrideSummaryStartDate__c, blng__SummaryEndDate__c From blng__UsageSummary__c Where blng__OrderProduct__r.L2I_Sub_Category_2__c = 'MCS' And blng__Status__c = 'Queued for Invoice' And blng__InvoiceRunProcessingStatus__c = 'Pending Billing'];
    }
    
    public void execute(Database.BatchableContext bc, List<blng__UsageSummary__c> scope) {
        List<blng__UsageSummary__c> toUpdate = new List<blng__UsageSummary__c>();
        for(blng__UsageSummary__c summary : scope) {
            if(System.today() <= summary.blng__SummaryEndDate__c) {
                summary.blng__OverrideSummaryEndDate__c = this.todayDate;
                toUpdate.add(summary);
            }
        }
        update toUpdate;
    }
    
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedById FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedById};
        mail.setToAddresses(toAddresses);
        mail.setSubject('L2I_UsageSummaryUpdateBatch');
        mail.setPlainTextBody('The batch Apex job processed '+a.TotalJobItems+' batches with '+a.NumberOfErrors+' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public void execute(SchedulableContext sc){
        Database.executeBatch(new L2I_UsageSummaryUpdateBatch(), 200);
    }
}