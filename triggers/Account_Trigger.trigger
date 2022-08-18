/**
 * @Description        : Trigger for Account
 * @Author             : Jan Denrick Geronga / Managed Services Simplus
 * @Modification Log   :
 * Ver          Date          Author              Modification
 * W-003956     Oct-18-2021   MS Simplus Jan      Initial Version
 **/

trigger Account_Trigger on Account (before insert, before update, after insert, after update, after delete, after undelete) {
    // now handle it
    new Account_TriggerHandler().run();
}