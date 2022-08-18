/**
 *      @author       Andy Fang
 *      @date         03/31/2020
 *      @description  L2I AircraftServiceAction Trigger Functions
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Andy Fang                     03/31/2020         Initial scaffold
 *
 */
public without sharing class L2I_ASAction_TriggerFunctions {

    //US1691 - Case Completion based on Aircraft service action Completion
    public static void updateCaseCompletion(List<L2I_ASA__c> newAircraftServiceActionList ) {
        System.debug('====== Checking to see if ASA are all completed within the same case');

        Set<Id> caseIdSets = new Set<Id>();

        //Getting all associated case Id
        for ( L2I_ASA__c asa : newAircraftServiceActionList ){
            if ( asa.Status__c == 'Completed'  ){
                caseIdSets.add( asa.Aircraft_Order__c );
            }
        }

        //Query all the related Aircraft Service Action related to the same case sets that is not completed
        List<L2I_ASA__c> asaList = [ select Id, Status__c
                                     from L2I_ASA__c
                                     where Aircraft_Order__c IN : caseIdSets AND Status__c != 'Completed'];

        //Remove any cases that still have status that is not completed
        if ( asaList.size() > 0 ) {
            for ( L2I_ASA__c asa : newAircraftServiceActionList ){
                caseIdSets.remove( asa.Aircraft_Order__c );
            }
        }

        if ( caseIdSets.size() > 0 ){

            List<Case> caseList = [ select Id, Status from Case where Id IN : caseIdSets and Status = 'New' ];
            List<Case> caseToBeUpdated = new List<Case>();
            for( Case c : caseList ){
                c.Status = 'Closed';
                caseToBeUpdated.add ( c );
            }

            if ( caseToBeUpdated.size() > 0 )
                update caseToBeUpdated;

        }

    }

}