/**
 * As of Winter '14 release, email templates used with approval processes can
 * include {!ApprovalRequest.field_name} merge fields.
 * For example, {!ApprovalRequest.Comments} merge field returns the most recently
 * entered comment in emails for an approval step.
 *
 * However, the merge fields do not work in visualforce email templates.
 * Thankfully, Pradeep on Developer Forums came up with a solution to use
 * a visualforce component in the template backed by controller that queries
 * the approval step information.
 *
 * This class represents the controller in this workaround solution.
 * Also see ApprovalRequestComments visualforce component.
 *
 * Inspired by https://developer.salesforce.com/forums/ForumsMain?id=906F00000008xjUIAQ
 *
 * http://docs.releasenotes.salesforce.com/en-us/winter14/release-notes/rn_186_forcecom_process_approval_comment_merge_fields.htm
 */
public class L2I_ApprovalRequestCommentsController {

    // ID of the record whose most recent approval process comments to retrieve
    public ID targetObjectId { get; set; }

    // The most recent approval process comments
    // Could show in visualforce email template, for example
    public String comments {
        get {
            if ( comments == null ) {
                ProcessInstanceStep lastStep = getLastApprovalStep();
                comments = ( lastStep != null ) ? lastStep.comments : '';
            }
            return comments;
        }
        private set;
    }

    public String fullname {
        get {
            if ( fullname == null ) {
                ProcessInstanceStep lastStep = getLastApprovalStep();
                if (lastStep != null ) {
                    fullname = lastStep.CreatedBy.FirstName + ' ' + lastStep.CreatedBy.LastName;
                } else {
                    fullname = '';
                }
            }
            return fullname;
        }
        private set;
    }

    public String step {
        get {
            if ( step == null ) {
                ProcessInstanceWorkitem workItem = getRelatedWorkItem();
                if (workItem != null ) {
                    String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                    step = ' ' + baseUrl + '/lightning/r/ProcessInstanceWorkItem/' + workItem.Id + '/view';
                } else {
                    step = '';
                }
            }
            return step;
        }
        private set;
    }

    public L2I_ApprovalRequestCommentsController() {}


    // Queries the most recent approval process step for the target record
    private ProcessInstanceStep getLastApprovalStep() {
        List<ProcessInstanceStep> steps = new List<ProcessInstanceStep>([
                SELECT
                        Comments, CreatedBy.FirstName, CreatedBy.LastName
                FROM
                        ProcessInstanceStep
                WHERE
                        ProcessInstance.TargetObjectId = :targetObjectId
                ORDER BY
                        SystemModStamp DESC
                LIMIT
                        1
        ]);
        return ( steps.size() > 0 ) ? steps[0] : null;
    }

    // Queries the most recent approval process step for the target record
    private ProcessInstanceWorkitem getRelatedWorkItem() {
        List<ProcessInstanceWorkitem> steps = new List<ProcessInstanceWorkitem>([
                SELECT
                        Id
                FROM
                        ProcessInstanceWorkitem
                WHERE
                        ProcessInstance.TargetObjectId = :targetObjectId
                ORDER BY
                        SystemModStamp DESC
                LIMIT
                        1
        ]);
        return ( steps.size() > 0 ) ? steps[0] : null;
    }
}