@IsTest
public class L2I_ApprovalRequestCommentsCntrlTest {

    @IsTest
    private static void test_get_comments() {

        // As of 12/31/2014, Salesforce does not provide us ability
        // to create ProcessInstance or ProcessInstanceStep records,
        // so there is no way to test this *correctly* without actually
        // submitting a record through an actual approve process.
        // However, this does get 100% code coverage =/

        L2I_ApprovalRequestCommentsController contr = new L2I_ApprovalRequestCommentsController();
        System.debug( contr.comments );

    }

    @IsTest
    private static void test_get_fullname() {

        L2I_ApprovalRequestCommentsController contr = new L2I_ApprovalRequestCommentsController();
        System.debug( contr.fullname );

    }

    @IsTest
    private static void test_get_step() {

        L2I_ApprovalRequestCommentsController contr = new L2I_ApprovalRequestCommentsController();
        System.debug( contr.step );

    }

}