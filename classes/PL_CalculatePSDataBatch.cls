/**
 * Created by sanjay.singhal on 10/29/20.
 */

global class PL_CalculatePSDataBatch implements Database.Batchable<SObject>{

    Id qId;

    global PL_CalculatePSDataBatch(ID quoteId){
        qId = quoteId;
    }

    global Database.QueryLocator Start(Database.BatchableContext BC) {
        System.debug('*** Starting Start Method in PL_CalculatePSDataBatch  ***');
        String query = 'SELECT Id, Name FROM SBQQ__Quote__c WHERE Id = \'' + qId + '\'';
        System.debug('*** query ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope){

        List <ID> QuoteIds = new List <Id>();
        for(SBQQ__Quote__c q :(List<SBQQ__Quote__c>)scope){
            // call method here.
            QuoteIds.add(q.Id);
        }

        if (QuoteIds.size()>0){
            PL_Utils.createPLData(QuoteIds);
        }
    }

    global void finish(Database.BatchableContext BC){

    }

}