/**
 * @Class Name  	: L2I_P_L_A_TriggerFunctions_Test
 * @Description		: Test Class for L2I_P_L_A_TriggerFunctions
 **/
@IsTest
private class L2I_P_L_A_TriggerFunctions_Test {
    
   /**
    * @Method Name  : testBehavior
    * @Description	: test Method for checking P_L_Version__c and Cloning Process
    **/
    @IsTest
    static void testBehavior() {
        L2I_DataFactory df = new L2I_DataFactory();
        Account namedCustomer = df.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = df.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
    
        Opportunity salesOppty = df.createSalesOpportunity('SalesOpp', 'Quotation', 5, namedCustomer.Id, dealOppty.Id);
        insert salesOppty;
    
        SBQQ__Quote__c quote = df.createQuote('draft', namedCustomer.Id, salesOppty.Id, false);
        quote.SBQQ__Primary__c = true;
        quote.ApprovalStatus__c = 'Approved';
        quote.L2I_Final_Proposal_Submission_Date__c = Date.today();
        quote.SubmittedDate__c = Date.today(); // Added by Khrisna for W-004060
        insert quote;
        
        L2I_DSH__c dsh = df.createDeliverySchedule(namedCustomer.Id, null);
        insert dsh;
        
        L2I_DSL__c dsl = df.createDeliveryScheduleLine(dsh.Id);
        insert dsl;
    
        salesOppty.SBQQ__PrimaryQuote__c = quote.Id;
        salesOppty.StageName = 'Pending Close';
        salesOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesOppty;
        
        L2I_P_L_Approval__c pla = df.createPLApproval(dealOppty.Id, 'Pending');
        pla.L2I_Revision_Status__c = 'Initial';
        insert pla;
    
        L2I_P_L_Sales_Opportunity__c plso = df.createPLSalesOpp( pla.Id, salesOppty.Id );
        insert plso;
        
        pla.ApprovalStatus__c = 'Approved';
        pla.L2I_Revision_Status__c = 'Award';
        update pla;
        
        //Added by Jan Geronga for W-003812: Start
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = pla.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'I';
        insert cdl;

        L2I_Compliance_Matrix__c cMatrix = new L2I_Compliance_Matrix__c();
        cMatrix.P_L_Approval__c = pla.Id;
        cMatrix.L2I_MIR_Flag__c = true;
		insert cMatrix;
        
        PTS_P_L_Files__c filesPTS = new PTS_P_L_Files__c();
        filesPTS.P_L_Approval__c = pla.Id;
        insert filesPTS;

        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.LinkedEntityId = filesPTS.Id;
        cdl2.ContentDocumentId = documents[0].Id;
        cdl2.ShareType = 'I';
        insert cdl2;
        
        Test.startTest();
        L2I_P_L_Approval__c pla2 = pla.clone();
        insert pla2;
        Test.stopTest();
        //Added by Jan Geronga for W-003812: End
        system.assertEquals('PandL-B',[SELECT P_L_Version__c FROM L2I_P_L_Approval__c WHERE Id =: pla2.Id].P_L_Version__c);
        system.assertEquals(1,[SELECT Count() FROM PTS_P_L_Files__c WHERE P_L_Approval__c =: pla2.Id ]);
        system.assertEquals(1,[SELECT Count() FROM PTS_P_L_Files__c WHERE PTS_P_L_Source__c =: filesPTS.Id ]);
    }
    
    /**
    * @Method Name  : processPLAsAfterUpdate
    * @Description	: test Method for checking PDF generation and attachment after approval
    **/
    @IsTest
    static void testProcessPLAsAfterUpdate() {
        final string filenameDelim = ' - ';
        String approvalName = 'PAC - PandL-00443 - Initial - PandL-A';
        Account testAccount = new Account(Name = 'testAcc', L2I_Airline_Code__c = 'PAC');
        Opportunity testOpportunity;
        L2I_P_L_Approval__c pnlApproval;
        ContentVersion contentVer;
        ContentDocumentLink contentDocLink;
        
        Test.startTest();
        insert testAccount;
        
        testOpportunity = new Opportunity(Name = 'testOpp', 
                                          StageName = 'Open',
                                          CloseDate = Date.today(),
                                          AccountId = testAccount.Id);
        insert testOpportunity;
        
        pnlApproval = new L2I_P_L_Approval__c(ApprovalStatus__c = null,
                                             L2I_Approval_Deal_Opportunity__c = testOpportunity.Id,
                                             L2I_Revision_Status__c = 'Initial');
        insert pnlApproval;
        
        pnlApproval.ApprovalStatus__c = 'Approved';
        update pnlApproval;        
        Test.stopTest();
        
        pnlApproval = [SELECT Id, ApprovalStatus__c, L2I_Approval_Deal_Opportunity__c, L2I_Revision_Status__c, Name, P_L_Version__c
                      FROM L2I_P_L_Approval__c WHERE Id =: pnlApproval.Id]; 
           
        approvalName = testAccount.L2I_Airline_Code__c + filenameDelim +
            		   pnlApproval.Name + filenameDelim + 
                       pnlApproval.L2I_Revision_Status__c + filenameDelim + 
                       pnlApproval.P_L_Version__c;
        
        contentVer = [SELECT Id, VersionData, ContentLocation, PathOnClient, Title, ContentDocumentId
                      FROM ContentVersion WHERE Title =: approvalName];
        contentDocLink = [SELECT Id, LinkedEntityId, ContentDocumentId, shareType, Visibility 
                          FROM ContentDocumentLink WHERE LinkedEntityId =: pnlApproval.Id];
        
        system.assertEquals(approvalName, contentVer.Title);
        system.assertEquals(blob.valueof('testData').size(), contentVer.VersionData.size());
        system.assertEquals('S', contentVer.ContentLocation);
        system.assertEquals(approvalName +'.pdf', contentVer.PathOnClient);        
        system.assertEquals(pnlApproval.Id, contentDocLink.LinkedEntityId);
        system.assertEquals(contentVer.ContentDocumentId, contentDocLink.ContentDocumentId);
        system.assertEquals('V', contentDocLink.shareType);
        system.assertEquals('AllUsers', contentDocLink.Visibility);
    }
}