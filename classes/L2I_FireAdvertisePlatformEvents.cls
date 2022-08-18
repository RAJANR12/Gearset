/**
 *      @author       Andy Fang
 *      @date         10/31/2019
 *      @description  Queueable class to fire off Advertising Platform Events.
 *                    Note from Raj Rajen:
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
 *      Andy Fang                      07/28/2019         Initial creation
 *
 */

public with sharing class L2I_FireAdvertisePlatformEvents implements Queueable {
    
    private Set<Id> ordIds;
    
    public L2I_FireAdvertisePlatformEvents(Set<Id> orderIds) {
        this.ordIds = orderIds;
    }
    
    public void execute(QueueableContext context) {
        
        System.debug('====== Executing L2I_FireAdvertisePlatformEvents Queueable Job');
        List<L2I_Order_Create_Advertising__e> ocaList = new List<L2I_Order_Create_Advertising__e>();
        for (Id oid : ordIds) {
            System.debug('======= Setting up Order Create Advertising Platform Event for Order Id :' + oid);
            L2I_Order_Create_Advertising__e oca = new L2I_Order_Create_Advertising__e();
            oca.RecordID__c = oid;
            ocaList.add(oca);
        }
        
        System.debug('======= Publishing ' + ocaList.size() + ' Advertising Order Create Platform Event(s)');
        if ( ocaList.size() > 0 ) {
            EventBus.publish( ocaList );
        }
    }

}