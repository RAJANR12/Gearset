/**
 *      @author       Sarah Kennedy
 *      @date         02/18/2020
 *      @description  Service class for ConnectAPI object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 02/23/2020         Initial creation
 *
 */
public with sharing class L2I_ConnectAPIService {
    public static Integer createChat(List<ConnectAPIWrap> caWrapList) {
        System.debug('*** caWrapList ' + caWrapList);
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        for (ConnectAPIWrap  caw : caWrapList) {
            System.debug('*** caw ' + caw);
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            mentionSegmentInput.id = caw.ownerId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            
            textSegmentInput.text = caw.message;
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = caw.objectId;
            
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
            batchInputs.add(batchInput);
        }
        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        System.debug('*** ConnectAPI batchInputs size ' + batchInputs.size());
        return batchInputs.size();
    }
    
    public class ConnectAPIWrap {
        public String objectId { get; set; }
        public String ownerId { get; set; }
        public String message { get; set; }

        public ConnectAPIWrap() {
        }
    }
}