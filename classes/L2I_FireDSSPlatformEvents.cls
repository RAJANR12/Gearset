/**
 *      @author       Raj Rajen
 *      @date         09/05/2019
 *      @description  Queueable class to fire off DSS Platform Events.
 *
 *                    The queueable approach was created to introduce a delay between when
 *                    order and orderitems are created and when the platform event gets
 *                    fired. In some situations, it turns out that if mulesoft consumes
 *                    the event within say 5 seconds of the event being published, mule is
 *                    not able to retrieve order items associated with the order. Introducing
 *                    a delay on the mule side with a sleep call is a way to introduce a
 *                    processing delay, but that is not ideal either.
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/28/2019         Initial creation
 *
 */

public class L2I_FireDSSPlatformEvents implements Queueable {

    private Set<Id> ordIds;

    public L2I_FireDSSPlatformEvents(Set<Id> orderIds) {
        this.ordIds = orderIds;
    }

    public void execute(QueueableContext context) {

        System.debug('====== Executing L2I_FireDSSPlatformEvents Queueable Job');
        List<L2I_Order_Create_Media__e> ocmList = new List<L2I_Order_Create_Media__e>();
        for (Id oid : ordIds) {
            System.debug('======= Setting up Order Create Media Platform Event for Order Id :' + oid);
            L2I_Order_Create_Media__e ocm = new L2I_Order_Create_Media__e();
            ocm.RecordID__c = oid;
            ocmList.add(ocm);
        }

        System.debug('======= Publishing ' + ocmList.size() + ' DSS Order Create Platform Event(s)');
        if ( ocmList.size() > 0 ) {
            EventBus.publish( ocmList );
        }
    }

}