public with sharing class PT_ProgramService {
    @InvocableMethod(Label = 'MROD Approval Questions')
    public static List<String> processMRODApprovalQuestions() {
        List<String> questions = new List<String>();
    
        List<PT_MROD_Approval_Question__mdt> questionList =
        [SELECT Question_Nbr__c, Question__c
        FROM PT_MROD_Approval_Question__mdt
        ORDER BY Question_Nbr__c];
        
        String q = '';
    
        for (PT_MROD_Approval_Question__mdt question : questionList) {
            q += question.Question_Nbr__c + '. ' +
                  question.Question__c + '\n';
        }
        questions.add(q);
        System.debug('*** questions ' + questions);
        
        return questions;
    }
}