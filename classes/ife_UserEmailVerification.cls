global class ife_UserEmailVerification implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        System.debug('The email Body ==> '+ email.plainTextBody);
        return result;
    }
}