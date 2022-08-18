/**
 * @Description        : Trigger for sbaa__Approval__c
 * @Author             : Jan Denrick Geronga / Managed Services Simplus
 * @Modification Log   :
 * Ver       	Date       	  Author              Modification
 * W-004155   	Dec-14-2021   MS Simplus Jan      Initial Version
 **/

trigger Approval_Trigger on sbaa__Approval__c (before insert, before update, after insert, after update, after delete, after undelete) {
    // now handle it
    new Approval_TriggerHandler().run();
}