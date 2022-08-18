/**
* @File Name          : PT_PartsListGeneratorTest.cls
* @Description        : Test Class for PT_PartsListGenerator
* @Author             :
* @Last Modified By   : MS Simplus Khrisna
* @Last Modified On   : May 04, 2022
* @Modification Log   : 
* Ver           Date           Author               Modification
*                                                   Initial Version
* W-001727      Mar 31 2022    MS Simplus Khrisna   Primary System Type Validation Rule
* W-004382      May 04 2022    MS Simplus Khrisna   Import parts list from Excel file
**/
@isTest
private class PT_PartsListGeneratorTest {

    private static L2I_DataFactory factory;

    @testSetup
    static void testSetup() {
        factory = new L2I_DataFactory();

        Account acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');
        insert acc;
        System.assert(acc.Id != null, 'Named Customer Account must have an Id');

        Opportunity dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        System.assert(dealOpp.Id != null, 'Deal Opportunity must have an Id');
        // Added for W-001727
        Product2 prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesOpp = factory.createSalesOpportunityWithAmount('Sales', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        // salesOpp.L2I_Product_Category__c = 'DSS'; Removed by Khrisna to fix DmlException W-004018
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOpp;

        SBQQ__Quote__c quote = factory.createQuote('draft', acc.Id, salesOpp.Id, false);
        insert quote;

        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test Billable Rule', blng__InitialBillingTrigger__c = 'Order Product Activation Date', blng__PartialPeriodTreatment__c = 'Separate', blng__AmendmentBillCycleDateAlignment__c = 'Align to original Order Product', blng__GenerateInvoices__c = 'No', blng__Active__c = True);
        insert billingRule;

        blng__RevenueRecognitionRule__c revRec = new blng__RevenueRecognitionRule__c(name = 'Test Revenue Recognition Rule', blng__Active__c = true, blng__CreateRevenueSchedule__c = 'No');
        insert revRec;

        blng__TaxRule__c taxRule = new blng__TaxRule__c(Name = 'Test tax Rule', blng__Active__c = true, blng__TaxableYesNo__c = 'No');
        insert taxRule;

        List<Product2> products = new List<Product2>();
        Product2 testProd = factory.createProduct('905647-TEST10', 'Test product', null, null, null);
        testProd.blng__BillingRule__c = billingRule.Id;
        testProd.blng__RevenueRecognitionRule__c = revRec.Id;
        testProd.blng__TaxRule__c = taxRule.Id;
        products.add(testProd);
        insert products;

        List<PricebookEntry> entries = new List<PricebookEntry>();
        for (SObject prod : products) {
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
            entries.add(pbe);
        }
        insert entries;

        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();

        for (Product2 prod : products) {
            SBQQ__QuoteLine__c quoteLine = factory.createQuoteLine( quote.Id, prod.Id, null );
            quoteLine.SBQQ__Quantity__c = 1;
            qlList.add(quoteLine);
        }
        insert qlList;

        SBQQ__SolutionGroup__c solution = new SBQQ__SolutionGroup__c(
            Name = 'Test',
            CurrencyIsoCode = 'USD'
        );
        insert solution;

        SBQQ__SolutionGroup__c solution1 = new SBQQ__SolutionGroup__c(
            Name = 'VCC',
            CurrencyIsoCode = 'USD'
        );
        insert solution1;

        SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__SolutionGroup__c = solution.Id,
            Name = solution.Name
        );
        insert quoteLineGroup;
    }

    @isTest
    static void testPLGAttachementResponse() {
        SBQQ__Quote__c quote = [Select Id, L2I_Version__c From SBQQ__Quote__c LIMIT 1];
        Attachment att = new Attachment();
    	att.Name = 'Unit Test Attachment';
    	Blob bodyBlob = Blob.valueOf('{' +
        '"economyClassSeatConfig":"economyClassSeatConfigText",' +
        '"economyClassSeatCount":1,' +
        '"premiumEconomySeatConfig":"premiumEconomySeatConfigText",' +
        '"premiumEconomySeatCount":2,' +
        '"businessClassSeatConfig":"businessClassSeatConfigText",' +
        '"businessClassSeatCount":3,' +
        '"firstClassSeatConfig":"firstClassSeatConfigText",' +
        '"firstClassSeatCount":4,' +
        '"ofarSeatConfig":"ofarSeatConfigText",' +
        '"ofarSeatCount":5,' +
        '"ofcrSeatConfig":"ofcrSeatConfigText",' +
        '"ofcrSeatCount":6,' +
        '"crewRestSeatConfig":"crewRestSeatConfigText",' +
        '"crewRestSeatCount":7,' +
        '"flightDeckSeatConfig":"flightDeckSeatConfigText",' +
        '"flightDeckSeatCount":8,' +
        '"quoteLines":[' +
           '{"installLocation":"VCC", "partnumber":"RD-AA903258-01", "nomenclature":"CWS, eX3, UNDER STAIR", "quantity":1, "price":245564, "cost":44771 }' +
        ']}');
    	att.body = bodyBlob;
        att.parentId = quote.id;
        insert att;
        PT_PartsListGenerator.Requests req = new PT_PartsListGenerator.Requests();
        req.quoteId = quote.Id;
        req.attachId = att.Id;
        Test.startTest();
        PT_PartsListGenerator.getQuoteAndAttachmentId(new List<PT_PartsListGenerator.Requests>{req});
        Test.stopTest();
        List<SBQQ__QuoteLine__c> partsList = [SELECT Id, SBQQ__Product__r.ProductCode, SBQQ__Quantity__c, SBQQ__Group__r.Name
                                                    FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.Id = :quote.Id];
        System.assertNotEquals(1, partsList.size());
    }

    @isTest
    static void testPLGDocumentResponse() {
        SBQQ__Quote__c quote = [Select Id, L2I_Version__c, SBQQ__Opportunity2__c From SBQQ__Quote__c LIMIT 1];
        quote.ApprovalStatus__c = 'Approved';
        update quote;
        ContentVersion cv = new ContentVersion(
            Title = 'Unit Test Attachment',
            PathOnClient = 'Unit Test Attachment.txt',
            VersionData = Blob.valueOf('{' +
                '"economyClassSeatConfig":"economyClassSeatConfigText",' +
                '"economyClassSeatCount":1,' +
                '"premiumEconomySeatConfig":"premiumEconomySeatConfigText",' +
                '"premiumEconomySeatCount":2,' +
                '"businessClassSeatConfig":"businessClassSeatConfigText",' +
                '"businessClassSeatCount":3,' +
                '"firstClassSeatConfig":"firstClassSeatConfigText",' +
                '"firstClassSeatCount":4,' +
                '"ofarSeatConfig":"ofarSeatConfigText",' +
                '"ofarSeatCount":5,' +
                '"ofcrSeatConfig":"ofcrSeatConfigText",' +
                '"ofcrSeatCount":6,' +
                '"crewRestSeatConfig":"crewRestSeatConfigText",' +
                '"crewRestSeatCount":7,' +
                '"flightDeckSeatConfig":"flightDeckSeatConfigText",' +
                '"flightDeckSeatCount":8,' +
                '"quoteLines":[' +
                   '{"installLocation":"ALT", "partnumber":"RD-AA903258-01", "nomenclature":"CWS, eX3, UNDER STAIR", "quantity":1, "price":245564, "cost":44771 }' +
                ']}'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = quote.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        PT_PartsListGenerator.Requests req = new PT_PartsListGenerator.Requests();
        req.quoteId = quote.Id;
        req.attachId = documents[0].Id;
        Test.startTest();
        PT_PartsListGenerator.getQuoteAndAttachmentId(new List<PT_PartsListGenerator.Requests>{req});
        Test.stopTest();
        List<SBQQ__QuoteLine__c> partsList = [SELECT Id, SBQQ__Product__r.ProductCode, SBQQ__Quantity__c, SBQQ__Group__r.Name
                                                    FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.SBQQ__Primary__c = TRUE AND SBQQ__Quote__r.SBQQ__Opportunity2__c = :quote.SBQQ__Opportunity2__c LIMIT 1];
        System.assertNotEquals(1, partsList.size());
    }

    @isTest
    static void testProcessPartListExcelContent(){
        factory = new L2I_DataFactory();

        Product2 prod = factory.createProduct('526407','SMART MONITOR','IFEC','IFE HW', '', '');
        prod.ProductCode = 'RD-FD6815-01';
        insert prod;

        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        String excelContent = '[{"Install Location":"FC","Part #":"RD-FD6815-01","Description":"SMART MONITOR","Purchase Qty":31}]';
        Test.startTest();
        PT_PartsListGenerator.processPartListExcelContent(quote.Id, excelContent);
        Test.stopTest();
        List<SBQQ__QuoteLine__c> partsList = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id];
        System.assertEquals(1, partsList.size(), 'Parts list not processed.');
    }

    @isTest
    static void testGetContentVersionData(){
        ContentVersion cv = new ContentVersion(
            Title = 'Parts List Template Format',
            PathOnClient = 'Parts List Template Format.xlsx',
            VersionData = Blob.valueOf('Parts List Template Body'),
            IsMajorVersion = true
        );
        insert cv;
        String cvId = cv.Id;

        Test.startTest();
        PT_PartsListGenerator.getContentVersionData(cvId);
        Test.stopTest();
        List<ContentVersion> files = [SELECT Id FROM ContentVersion WHERE Id = :cv.Id];
        System.assertEquals(1, files.size(), 'Not able to retrieve file.');
    }

}