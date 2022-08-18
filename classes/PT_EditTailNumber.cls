public class PT_EditTailNumber {
    @InvocableMethod
    public static List<String> getAvailableAirCrafts(List<Requests> requests) {
        List<String> results = new List<String>();
        //system.assertEquals(requests, null);
        String aircraftsName = '';
        
        List<String> lEff = new List<String>();
        Set<String> sEff = new Set<String>();
        
        if (requests[0].dslId != null) {
            //Get dsl record
            L2I_DSL__c dslRec = [SELECT Id, PT_Program__c, PT_Program__r.PT_Program_Aircraft_IDs__c,
                                 Original_Opportunity__c // Added by Jan Geronga for W-003864
                                FROM L2I_DSL__c
                                WHERE Id = :requests[0].dslId LIMIT 1];
            
            //Added by Jan Geronga for W-003864: Start
            if (dslRec.PT_Program__c != null && dslRec.Original_Opportunity__c != null) {
                Opportunity opp = [SELECT Id, Effectivity__c From Opportunity WHERE ID =: dslRec.Original_Opportunity__c];
                if(opp.Effectivity__c != null){
                    lEff.addAll(opp.Effectivity__c.split(';'));
                    sEff.addAll(lEff);
                }

                for (L2I_Aircraft__c aircraft : [SELECT Id, L2I_Registration_Number__c, Name FROM L2I_Aircraft__c WHERE L2I_Registration_Number__c IN: sEff]) {
                    aircraftsName = aircraftsName + aircraft.Name + ';';
                }
                
                aircraftsName = aircraftsName.removeEnd(';');
                if(aircraftsName == null || aircraftsName == ''){
                    results.add('No Aircraft Available');
                } else {
                    results.add(aircraftsName);
                }
            }
            //Added by Jan Geronga for W-003864: End
            
            /*if (dslRec.PT_Program__c != null && dslRec.PT_Program__r.PT_Program_Aircraft_IDs__c != null) {
                List<String> splitProgramAircrafts = dslRec.PT_Program__r.PT_Program_Aircraft_IDs__c.removeEnd(';').split('\\;');
                Set<String> allAircraftsForProgram = new Set<String>(splitProgramAircrafts);
                for (L2I_DSL__c dsl : [SELECT Id, Name, Aircraft__c, Aircraft__r.Name
                                        FROM L2I_DSL__c
                                        WHERE PT_Program__c = :dslRec.PT_Program__c AND Aircraft__c != null]) {
                    if (allAircraftsForProgram.contains(dsl.Aircraft__c)) {
                        allAircraftsForProgram.remove(dsl.Aircraft__c);
                    }
                }
                for (L2I_Aircraft__c aircraft : [SELECT Id, Name FROM L2I_Aircraft__c WHERE Id IN :allAircraftsForProgram]) {
                    aircraftsName = aircraftsName + aircraft.Name + ';';
                }
                aircraftsName = aircraftsName.removeEnd(';');
                if(aircraftsName == null || aircraftsName == ''){
                    results.add('No Aircraft Available');
                } else {
                    results.add(aircraftsName);
                }
            }*/
                        
            else {
                results.add('No Aircraft Available');
            }
        }
        return results;
    }
    public class Requests {
    @InvocableVariable
    public Id dslId;
    }
}