/**
 *      @author       Sanjay Singhal
 *      @date         09/29/2020
 *      @description  Trigger on the P&L Approval object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sanjay Singhal                 09/29/2020         Initial scaffold
 *      
 *    
 */
trigger L2I_P_L_Approval_Trigger on L2I_P_L_Approval__c (before insert, before update, after insert, after update, after delete, after undelete) {

    // now handle it
    new L2I_P_L_A_TriggerHandler().run();
   
}