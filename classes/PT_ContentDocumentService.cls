/**
 *      @author       Sarah Kennedy
 *      @date         12/08/2020
 *      @description  Service class for Content Document object
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 12/08/2020         Initial creation
 *
 */

public with sharing class PT_ContentDocumentService {
    public static void createFile (String docTitle, String docPath, Id docLink, String docJSON){
//        System.debug('*** Starting PT_ContentDocumentService.createFile ');
//        Blob b = Blob.valueOf(docJSON);
//        String ser =  EncodingUtil.base64Encode(b);
//        // create the file and add it to the Opportunity
//        ContentVersion conVer = new ContentVersion();
//        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
//        conVer.PathOnClient = docPath;
//        conVer.Title = docTitle; // Display name of the files
//        conVer.VersionData = EncodingUtil.base64Decode(ser);
//        insert conVer;    //Insert ContentVersion
//
//        // First get the Content Document Id from ContentVersion Object
//        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
//        //create ContentDocumentLink  record
//        ContentDocumentLink conDocLink = new ContentDocumentLink();
//        conDocLink.LinkedEntityId = docLink; // record the file is added to
//        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
//        conDocLink.ShareType = 'V'; // view only
//        insert conDocLink;
//        System.debug('*** Exiting PT_ContentDocumentService.createFile ');
    }
}