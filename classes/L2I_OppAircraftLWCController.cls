/**
 *      @author       Sarah Kennedy
 *      @date         03/31/2020
 *      @description  Manage Aircraft data for Opportunity
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 03/31/2020         Initial Creation
 */
public with sharing class L2I_OppAircraftLWCController {
    
    @AuraEnabled
    public static oppAircraft getAircraft(String recordId) {
        System.debug('*** oppAircraft recordId ' + recordId);
        try {
            Opportunity opp = [
                  SELECT Id,
                        L2I_Aircraft_Type__c,
                        L2I_Aircraft_Type__r.Name,
                        L2I_AircraftQuantity__c,
                        L2I_Product_Category__c
                  FROM Opportunity
                  WHERE Id = :recordId
            ];
            System.debug('*** opp ' + opp);
            oppAircraft aircraft = new oppAircraft();
            aircraft.oppId = opp.Id;
            aircraft.aircraftTypeName = opp.L2I_Aircraft_Type__r.Name;
            aircraft.aircraftTypeId = opp.L2I_Aircraft_Type__c;
            aircraft.aircraftQty = opp.L2I_AircraftQuantity__c;
            aircraft.prodCategory = opp.L2I_Product_Category__c;
            System.debug('*** aircraft ' + aircraft);
            return aircraft;
        } catch (DmlException e) {
            System.debug('error: ' + e);
            throw new AuraHandledException('There was an error retrieving the Aircraft Qty and Type on Opportunity ' + recordId + ': ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateAircraft(String oppId, String aircraftId, Decimal aircraftQty) {
        try {
            Opportunity opp = [
                  SELECT Id,
                        L2I_Aircraft_Type__c,
                        L2I_AircraftQuantity__c
                  FROM Opportunity
                  WHERE Id = :oppId
            ];
            opp.L2I_Aircraft_Type__c = aircraftId;
            opp.L2I_AircraftQuantity__c = aircraftQty;
            update opp;
            System.debug('*** update opp ' + opp);
        } catch (DmlException e) {
            System.debug('error: ' + e);
            throw new AuraHandledException('There was an error updating the Aircraft Qty on Opportunity ' + oppId + ': ' + e.getMessage());
        }
    }
    
    public class oppAircraft {
        @AuraEnabled public String oppId { get; set; }
        @AuraEnabled public String aircraftTypeName { get; set; }
        @AuraEnabled public String aircraftTypeId { get; set; }
        @AuraEnabled public String prodCategory { get; set; }
        @AuraEnabled public Decimal aircraftQty { get; set; }
    }
}