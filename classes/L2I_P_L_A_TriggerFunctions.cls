/**
 *      @author       anjay.singhal
 *      @date         9/28/2020
 *      @description  L2I_P_L_A_TriggerFunctions Trigger Functions
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      sanjay.singhal                9/28/2020           Initial scaffold
 *      mstraw (Simplus)              6/22/2021           W-003684 Removed Method ValidatePLARecordUpdate code backed up in file attcahed to WI
 * 		MS Simplus Jan Geronga 	      07/08/2021          W-003812 Added clonePLApproval Method
 * 		MS Simplus Jan Geronga        07/08/2021          W-003812 added updateApprovalStatusAndDate
 *      MS Simplus Queenie            07-30-2021          W-003854 added updateSnapshotVersionField
 * 		MS Simplus Francis Macam	  08/12/2021		  W-003815 added attachPnLPDF
 */

public without sharing class L2I_P_L_A_TriggerFunctions {
    
    /**
    * @Method Name        : updateApprovalStatusAndDate
    * @Description        : This updates the Approval Status and Approved Date to null before insert
    * @Author             : Jan Denrick Geronga / Managed Services Simplus
    * @Modification Log   : 
    * Ver       	Date       	  Author              Modification
    * W-003812    	Jul-08-2021   MS Simplus Jan      Initial Version
    **/
    public static void updateApprovalStatusAndDate(List<L2I_P_L_Approval__c> newPLAList){
        for(L2I_P_L_Approval__c pLApproval : newPLAList){
            if(pLApproval.isClone() && pLApproval.getCloneSourceId() != null){
                pLApproval.ApprovalStatus__c = null;
                pLApproval.Last_Approved_Date__c = null;
                pLApproval.P_L_Source__c = pLApproval.getCloneSourceId();
            }
        }
    }
    
    /**
    * @Method Name        : clonePLApproval
    * @Description        : Deep clone feature of the PLApproval record
    * @Author             : Jan Denrick Geronga / Managed Services Simplus
    * @Modification Log   : 
    * Ver       	Date       	  Author              Modification
    * W-003812    	Jul-08-2021   MS Simplus Jan      Initial Version
    **/
    public static void clonePLApproval(List<L2I_P_L_Approval__c> newPLAList){
        Map<Id, L2I_P_L_Approval__c> mapPLA = new Map<Id, L2I_P_L_Approval__c>();
        Map<Id, ContentDocumentLink> mapPTSFiles = new Map<Id, ContentDocumentLink>();
        List<L2I_P_L_Sales_Opportunity__c> newSalesOpp = new List<L2I_P_L_Sales_Opportunity__c>();
        List<ContentDocumentLink> newNotes = new List<ContentDocumentLink>();
        List<PTS_P_L_Files__c> newPTSPLFiles = new List<PTS_P_L_Files__c>();
        List<L2I_Compliance_Matrix__c> newCompMatrix = new List<L2I_Compliance_Matrix__c>();
        List<ContentDocumentLink> newPTSNotes = new List<ContentDocumentLink>();
        
        for(L2I_P_L_Approval__c pLApproval : newPLAList){
            if(plApproval.P_L_Source__c != null){
                mapPLA.put(plApproval.P_L_Source__c, plApproval);
            }
        }
        
        if(!mapPLA.isEmpty()){
            for(L2I_P_L_Sales_Opportunity__c salesOpp : [SELECT Id, L2I_P_L_Approval__c, L2I_Sales_Opportunity__c FROM L2I_P_L_Sales_Opportunity__c WHERE L2I_P_L_Approval__c IN: mapPLA.keySet()]){
                newSalesOpp.add(new L2I_P_L_Sales_Opportunity__c(L2I_Sales_Opportunity__c = salesOpp.L2I_Sales_Opportunity__c,
                                                                 L2I_P_L_Approval__c = mapPLA.get(salesOpp.L2I_P_L_Approval__c).Id));
            }
            
            for(L2I_P_L_Approval__c oldPLA : [SELECT Id, (SELECT ContentDocumentId FROM ContentDocumentLinks) FROM L2I_P_L_Approval__c WHERE Id IN: mapPLA.keySet()]){
                for(ContentDocumentLink cdl: oldPLA.ContentDocumentLinks){
                    newNotes.add(new ContentDocumentLink(LinkedEntityId = mapPLA.get(oldPLA.Id).Id, ContentDocumentId = cdl.ContentDocumentId, ShareType = 'I'));
                }
            }
            
            for(PTS_P_L_Files__c oldPTSPLFiles : [SELECT Id, P_L_Approval__c, CurrencyIsoCode, PTS_P_L_Source__c, (SELECT ContentDocumentId FROM ContentDocumentLinks) FROM PTS_P_L_Files__c WHERE P_L_Approval__c IN: mapPLA.keySet()]){
                PTS_P_L_Files__c newPTS = new PTS_P_L_Files__c();
                newPTS.P_L_Approval__c = mapPLA.get(oldPTSPLFiles.P_L_Approval__c).Id;
                newPTS.CurrencyIsoCode = oldPTSPLFiles.CurrencyIsoCode;
                newPTS.PTS_P_L_Source__c = oldPTSPLFiles.Id;
                newPTSPLFiles.add(newPTS);
                
                for(ContentDocumentLink cdl: oldPTSPLFiles.ContentDocumentLinks){
                    mapPTSFiles.put(oldPTSPLFiles.Id, cdl);
                }
            }
            
            for(L2I_Compliance_Matrix__c oldCompMatrix : [SELECT P_L_Approval__c, L2I_AnswerText__c, L2I_AuthorList__c, L2I_Compliant__c, CurrencyIsoCode, L2I_Header_ExternalId__c, 
                                                          L2I_MIR_Flag__c, L2I_QuestionText__c, L2I_ReviewerList__c, L2I_RFPIO_Project_ID__c, L2I_RiskRequirement_Flag__c 
                                                          FROM L2I_Compliance_Matrix__c WHERE P_L_Approval__c IN: mapPLA.keySet()]){
                                                              
                                                              L2I_Compliance_Matrix__c newCM = new L2I_Compliance_Matrix__c();
                                                              newCM.P_L_Approval__c = mapPLA.get(oldCompMatrix.P_L_Approval__c).Id;
                                                              newCM.L2I_AnswerText__c = oldCompMatrix.L2I_AnswerText__c;
                                                              newCM.L2I_AuthorList__c = oldCompMatrix.L2I_AuthorList__c;
                                                              newCM.L2I_Compliant__c = oldCompMatrix.L2I_Compliant__c;
                                                              newCM.CurrencyIsoCode = oldCompMatrix.CurrencyIsoCode;
                                                              newCM.L2I_Header_ExternalId__c = oldCompMatrix.L2I_Header_ExternalId__c;
                                                              newCM.L2I_MIR_Flag__c = oldCompMatrix.L2I_MIR_Flag__c;
                                                              newCM.L2I_QuestionText__c = oldCompMatrix.L2I_QuestionText__c;
                                                              newCM.L2I_ReviewerList__c = oldCompMatrix.L2I_ReviewerList__c;
                                                              newCM.L2I_RFPIO_Project_ID__c = oldCompMatrix.L2I_RFPIO_Project_ID__c;
                                                              newCM.L2I_RiskRequirement_Flag__c = oldCompMatrix.L2I_RiskRequirement_Flag__c;
                                                              newCompMatrix.add(newCM);
                                                          }
        }
        if(newSalesOpp.size()>0){
            insert newSalesOpp;
        }
        
        if(newNotes.size()>0){
            insert newNotes;
        }
        
        if(newCompMatrix.size()>0){
            insert newCompMatrix;
        }
        
        if(newPTSPLFiles.size()>0){
            insert newPTSPLFiles;
            
            for(PTS_P_L_Files__c newPTSFiles : newPTSPLFiles){
                if(mapPTSFiles.get(newPTSFiles.PTS_P_L_Source__c).ContentDocumentId != null){
                    newPTSNotes.add(new ContentDocumentLink(LinkedEntityId = newPTSFiles.Id, ContentDocumentId = mapPTSFiles.get(newPTSFiles.PTS_P_L_Source__c).ContentDocumentId, ShareType = 'I'));
                }
            }
        }
        
        if(newPTSNotes.size() > 0){
            insert newPTSNotes;
        }
    }
    
   /**
    * @Method Name        : updateSnapshotVersionField
    * @Description        : This updates the Snapshot Version and Snapshot Text Version Field upon insert of P&L Record
    * @Author             : Queenie Rose Ong / Managed Services Simplus
    * @Modification Log   : 
    * Ver       	Date       	  Author              Modification
    * W-3854    	Jul-30-2021   MS Simplus Queenie   Initial Version
    **/
    public static void updateSnapshotVersionField(List<L2I_P_L_Approval__c> newPLAList){
        List<L2I_P_L_Approval__c> lPLApproval = new List<L2I_P_L_Approval__c>();
        Set<Id> sOpportunityId = new Set<Id>();
        Map<Id, Integer> mOppToVersionNumber = new Map<Id,Integer>();
        Map<Id, Integer> mOppToNumber = new Map<Id,Integer>();
        
        for(L2I_P_L_Approval__c pLApproval: newPLAList){
            if(pLApproval.L2I_Approval_Deal_Opportunity__c != NULL){
                lPLApproval.add(pLApproval);
                sOpportunityId.add(pLApproval.L2I_Approval_Deal_Opportunity__c);
            }           
        }
        
        if(!sOpportunityId.isEmpty()){ 
            for(AggregateResult agr: [SELECT L2I_Approval_Deal_Opportunity__c, MAX(Snapshot_Version__c) max 
                                      FROM L2I_P_L_Approval__c 
                                      WHERE L2I_Approval_Deal_Opportunity__c IN : sOpportunityId  
                                      GROUP BY L2I_Approval_Deal_Opportunity__c]){
                if(!mOppToVersionNumber.containsKey((Id) agr.get('L2I_Approval_Deal_Opportunity__c'))){
                    mOppToVersionNumber.put((Id) agr.get('L2I_Approval_Deal_Opportunity__c'), Integer.valueOf(agr.get('max')));
                }
            }
        }
        
        if(mOppToVersionNumber != NULL && !mOppToVersionNumber.isEmpty()){
            for(L2I_P_L_Approval__c pLApproval: lPLApproval){
                if(mOppToVersionNumber.containsKey(pLApproval.L2I_Approval_Deal_Opportunity__c)){
                    Integer x = mOppToNumber.containsKey(pLApproval.L2I_Approval_Deal_Opportunity__c) ? 
                        mOppToNumber.get(pLApproval.L2I_Approval_Deal_Opportunity__c) : mOppToVersionNumber.get(pLApproval.L2I_Approval_Deal_Opportunity__c);
                    
                    pLApproval.Snapshot_Version__c = x + 1;
                    pLApproval.Snapshot_Text_Version__c = revisionCharacter(x + 1);
                    mOppToNumber.put(pLApproval.L2I_Approval_Deal_Opportunity__c, Integer.valueOf(pLApproval.Snapshot_Version__c));
                } else{
                    pLApproval.Snapshot_Text_Version__c = revisionCharacter(Integer.valueOf(pLApproval.Snapshot_Version__c));     
                }
            }
        } else{
            for(L2I_P_L_Approval__c pLApproval: newPLAList){
                pLApproval.Snapshot_Text_Version__c = revisionCharacter(Integer.valueOf(pLApproval.Snapshot_Version__c));     
            }
        }       
    }
    
   /************************************************************
    * simple function to encode an alpha Revision character
    * Uses only (non-ambiguous) alpha characters
    * go to 2 alpha digits (not padded)
    * Input: Numeric
    * Output: Corresponding "Revision" character
    ************************************************************/
    public static String revisionCharacter(Integer revision) {
        String charIndex = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        Integer modulus = charIndex.length();
        String thisRevision = '';
        while (revision > 0) {
            Integer thisDigit = math.mod(revision, modulus) == 0 ? modulus : math.mod(revision, modulus);
            thisRevision += charIndex.mid(thisDigit - 1, 1);
            revision = math.mod(revision, modulus) == 0 ? (revision / modulus) -1 : (revision / modulus);
        }
        return thisRevision.reverse();
    }
    
    /**
    * @Method Name        : attachPnLPDF
    * @Description        : This attaches the P&L View PDF upon update of P&L Record
    * @Author             : Francis Jan Macam / Managed Services Simplus
    * @Modification Log   : 
    * Ver       	Date       	  Author              Modification
    * W-003815    	Aug-12-2021   MS Simplus Francis  Initial Version
    **/      
    public static void processPLAsAfterUpdate(List<L2I_P_L_Approval__c> newPLAList, Map<Id, L2I_P_L_Approval__c> oldPLAMap){
        final string approved = 'Approved';
        List<id> plApprovalIdList = new List<id>();
        
       	for(L2I_P_L_Approval__c plApproval: newPLAList){            
            if(plApproval.ApprovalStatus__c == approved && oldPLAMap.get(plApproval.Id).ApprovalStatus__c != approved ){
            	plApprovalIdList.add(plApproval.Id);
            }
        } 
        
        if(!plApprovalIdList.isEmpty()){
        	L2I_P_L_A_TriggerFunctions.attachPnLPDF(UserInfo.getSessionId(), plApprovalIdList);
        }
    }
    
    /**
    * @Method Name        : attachPnLPDF
    * @Description        : This attaches the P&L View PDF upon update of P&L Record
    * @Author             : Francis Jan Macam / Managed Services Simplus
    * @Modification Log   : 
    * Ver       	Date       	  Author              Modification
    * W-003815    	Aug-12-2021   MS Simplus Francis  Initial Version
    **/    
    @Future(callout=true)
    private static void attachPnLPDF(string sessionId, List<id> plApprovalIdList){
        final Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9- ]');
        final String filenameDelim = ' - ';
		List<ContentVersion> contentVList = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();        
        Map<Id, ContentVersion> contentVMap = new Map<id, ContentVersion>();        
        Map<Id, Id> contentVApprovalIdMap = new Map<id, id>();
        String fileName;
        Matcher strMatcher;
        Database.SaveResult[] resultList;
        
        for(L2I_P_L_Approval__c pnlApproval : [SELECT Id, L2I_Approval_Deal_Opportunity__r.Account.L2I_Airline_Code__c, Name, 
                                               L2I_Revision_Status__c, P_L_Version__c 
											   FROM L2I_P_L_Approval__c WHERE ID IN: plApprovalIdList]){
            fileName = pnlApproval.L2I_Approval_Deal_Opportunity__r.Account.L2I_Airline_Code__c + filenameDelim + 
                       pnlApproval.Name + filenameDelim + 
                       pnlApproval.L2I_Revision_Status__c + filenameDelim + 
                       pnlApproval.P_L_Version__c;
            
            PageReference pnlViewPdf = Page.PL_NewViewPDF;
            pnlViewPdf.getParameters().put('id', pnlApproval.Id);
            
            ContentVersion contentV = new ContentVersion();
            strMatcher = nonAlphanumeric.matcher(fileName);
			fileName = strMatcher.replaceAll('');
                                                   
            if(Test.isRunningTest()) { 
	            contentV.VersionData = blob.valueOf('testData');
            } else {
              	contentV.VersionData = pnlViewPdf.getContent();
            }
            
			contentV.ContentLocation = 'S';
            contentV.PathOnClient = fileName +'.pdf';
            contentV.Title = fileName;           
            
            contentVMap.put(pnlApproval.Id, contentV);
            contentVList.add(contentV);   
        }
       
        if(!contentVList.isEmpty()){
            resultList = Database.insert(contentVList, false);
            
            for (Database.SaveResult result : resultList) {
                if (result.isSuccess() == false) {                    
                    for(Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.' + err.getStatusCode() + ': ' + 
                                     err.getMessage() + 'Fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        
		for(Id pnlApprovalId : plApprovalIdList){
            ContentVersion contentV = contentVMap.get(pnlApprovalId);
            contentVApprovalIdMap.put(contentV.id, pnlApprovalId);
        }
        
        for(ContentVersion contentV : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVApprovalIdMap.keySet()]){
            ContentDocumentLink contentDocLink = New ContentDocumentLink();            
            contentDocLink.LinkedEntityId = contentVApprovalIdMap.get(contentV.id);            
            contentDocLink.ContentDocumentId = contentV.ContentDocumentId;
            contentDocLink.shareType = 'V';
            contentDocLink.Visibility = 'AllUsers';
            
            contentDocLinkList.add(contentDocLink);            
        }
        
        if(!contentDocLinkList.isEmpty()){
            resultList = Database.insert(contentDocLinkList, false);
            
            for (Database.SaveResult result : resultList) {
                if (result.isSuccess() == false) {                    
                    for(Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.' + err.getStatusCode() + ': ' + 
                                     err.getMessage() + 'Fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }	
    }
}