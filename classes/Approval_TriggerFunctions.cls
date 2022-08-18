/**
 * @Description        : Helper for for Approval_TriggerHandler
 * @Author             : Jan Denrick Geronga / Managed Services Simplus
 * @Modification Log   :
 * Ver       	Date       	  Author              Modification
 * W-004155   	Dec-14-2021   MS Simplus Jan      Initial Version
 **/

public class Approval_TriggerFunctions {

    public static void setRecordType(List<sbaa__Approval__c> newApprovalList) {
        for(sbaa__Approval__c approval : newApprovalList) {
            if(approval.sbaa__RecordField__c == 'P_L_Approval__c'){
                approval.RecordTypeId = Schema.SObjectType.sbaa__Approval__c.getRecordTypeInfosByName().get('P&L Approval').getRecordTypeId();
            }
            else if(approval.sbaa__RecordField__c == 'Quote__c'){
                approval.RecordTypeId = Schema.SObjectType.sbaa__Approval__c.getRecordTypeInfosByName().get('Quote').getRecordTypeId();
            }
            else{
                approval.RecordTypeId = Schema.SObjectType.sbaa__Approval__c.getRecordTypeInfosByName().get('Opportunity').getRecordTypeId();
            }
        }
    }
    
    /**
    * @Method Name        : copyFieldValues
    * @Description        : Copies values from P&L Record fields to Approval record fields
    * @Author             : Jan Denrick Geronga / Managed Services Simplus
    * @Modification Log   :
    * Ver       	Date       	  Author              Modification
    * W-004266   	Jan-27-2022   MS Simplus Jan      Initial Version
    **/
    
    public static void copyFieldValues(List<sbaa__Approval__c> newApprovalList) {
        Set<ID> setPL = new Set<ID>();
        Map<ID, L2I_P_L_Approval__c> mapPL = new Map<ID, L2I_P_L_Approval__c>();
        for(sbaa__Approval__c approval : newApprovalList){
            if(approval.sbaa__RecordField__c == 'P_L_Approval__c'){
                setPL.add(approval.P_L_Approval__c);
            }
        }
        
        if(!setPL.isEmpty()){
            for(L2I_P_L_Approval__c pl : [SELECT Id, L2I_Revision_Status__c, Notes__c, L2I_Summary__c, L2I_Additional_Description__c, PL_PTS_Station__c, Automated_Sales_Opportunity_Description__c FROM L2I_P_L_Approval__c WHERE ID IN: setPL]){
                mapPL.put(pl.Id, pl);
            }
        }
        
        if(!mapPL.isEmpty()){
            for(sbaa__Approval__c approval : newApprovalList) {
                L2I_P_L_Approval__c mapApproval = mapPL.get(approval.P_L_Approval__c);
                if(mapApproval != null){
                    approval.Revision_Status__c = mapApproval.L2I_Revision_Status__c;
                    approval.Notes__c = mapApproval.Notes__c;
                    approval.Summary__c = mapApproval.L2I_Summary__c;
                    approval.Additional_Description__c = mapApproval.L2I_Additional_Description__c;
                    approval.PTS_Station__c = mapApproval.PL_PTS_Station__c;
                    approval.Automated_Sales_Opportunity_Description__c = mapApproval.Automated_Sales_Opportunity_Description__c;
                }
            }
        }
    }
}