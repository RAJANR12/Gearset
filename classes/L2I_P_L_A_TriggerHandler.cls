/**
 *      @author       Sanjay Singhal
 *      @date         09/29/2020
 *      @description  L2I P & L Approval Trigger Handler
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sanjay Singhal                 09/29/2020         Initial scaffold
 *		Jan Denrick Geronga            07/02/2021         Added beforeInsert and afterInsert for W-003812
 *		Francis Jan Macam 			   08/12/2021		  Added afterUpdate for W-003815
 */
public without sharing class L2I_P_L_A_TriggerHandler extends L2I_TriggerHandler {
    private Map<Id, L2I_P_L_Approval__c> newPLAMap;
    private List<L2I_P_L_Approval__c> newPLAList;

    private Map<Id, L2I_P_L_Approval__c> oldPLAMap;
    private List<L2I_P_L_Approval__c> oldPLAList;

    public L2I_P_L_A_TriggerHandler() {
        this.newPLAMap = (Map<Id, L2I_P_L_Approval__c>) Trigger.newMap;
        this.newPLAList = (List<L2I_P_L_Approval__c>) Trigger.new;

        this.oldPLAMap = (Map<Id, L2I_P_L_Approval__c>) Trigger.oldMap;
        this.oldPLAList = (List<L2I_P_L_Approval__c>) Trigger.old;
    }

    public override void beforeUpdate() {
        // Modified by mstraw 06/23/21 W-003864 removed call to ValidatePLARecordUpdate
        
    }
    
    public override void beforeInsert() {
        L2I_P_L_A_TriggerFunctions.updateApprovalStatusAndDate(newPLAList);//Added by Jan Geronga for W-003812
        L2I_P_L_A_TriggerFunctions.updateSnapshotVersionField(newPLAList); //Added by Queenie Ong for W-003854
    }
    
    public override void afterInsert() {
        L2I_P_L_A_TriggerFunctions.clonePLApproval(newPLAList);//Added by Jan Geronga for W-003812
    }  
    
    /**
    * @Method Name        : attachPnLPDF
    * @Description        : This attaches the P&L View PDF upon update of P&L Record
    * @Author             : Francis Jan Macam / Managed Services Simplus
    * @Modification Log   : 
    * Ver       	Date       	  Author              Modification
    * W-003815    	Aug-12-2021   MS Simplus Francis  Initial Version
    **/   
    public override void afterUpdate() {
        L2I_P_L_A_TriggerFunctions.processPLAsAfterUpdate(newPLAList, oldPLAMap);
    }
}