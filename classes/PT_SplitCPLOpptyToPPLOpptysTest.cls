/**
 *      @author
 *      @date
 *      @description  PT SplitCPLOpptyToPPLOpptys Tests
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *		Francis macam				  12/01/2021		    W-003708 Improvement of test execution speed
 *      MS Simplus Khrisna            03/31/2022            W-001727 Primary System Type Validation Rule
 */
@isTest
public class PT_SplitCPLOpptyToPPLOpptysTest {
    /**
    * @Method Name        : prepareTestData
    * @Description        : Prepare Test Data for all test cases
    * @Author             : Francis Jan Macam / Managed Services Simplus
    * @Modification Log   :
    * Ver       	Date       	  Author              Modification
    * W-003708    	Nov-22-2021   MS Simplus Francis  Initial Version
    **/
    @testSetup
    static void prepareTestData() {        
        Account acc;
        Opportunity dealOpp, salesOpp;
        L2I_P_L_Approval__c plApproval;
        L2I_P_L_Sales_Opportunity__c plSalesOpp;
        L2I_Aircraft_Type__c att;
        L2I_DSH__c dsHeaderlList;
        L2I_DSL__c dsLineList;
        SBQQ__Quote__c quote;
        blng__BillingRule__c billingRule;
        blng__RevenueRecognitionRule__c revRec;
        blng__TaxRule__c taxRule;
        Product2 testProd;
        SBQQ__SolutionGroup__c sg, sg1, sg2;
        Product2 prodSysType;
        
        L2I_DataFactory factory = new L2I_DataFactory();
        List<Product2> products = new List<Product2>();
        List<PricebookEntry> entries = new List<PricebookEntry>();
        List<SBQQ__SolutionGroup__c> slGrpsList = new List<SBQQ__SolutionGroup__c>();
        List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        Boolean isPrimaryQuote = true;
        
        acc = factory.createCustomerAccount('Test Customer', '123 Augustine Street', 'San Diego', 'CA', '91890');        
        insert acc;

        dealOpp = factory.createDealOpportunity('Deal', 'Open', 30, acc.Id);
        insert dealOpp;
        // Added for W-001727
        prodSysType = factory.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
		
        salesOpp = factory.createSalesOpportunityWithAmount('Sales PTSCPLOTPPLO-ICPLOS Test', 'Open', 30, acc.Id, dealOpp.Id, 200000, 'IFEC');
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesOpp;

        plApproval = factory.createPLApproval(dealOpp.Id, 'Approved');
        insert plApproval;

        plSalesOpp = factory.createPLSalesOpp(plApproval.Id, salesOpp.Id);
        insert plSalesOpp;

        att = factory.createAircraftType(acc.Id, 123456);
        insert att;

        dsHeaderlList = factory.createDeliverySchedule(acc.Id, att.Id);
        insert dsHeaderlList;

        dsLineList = factory.createDeliveryScheduleLine(dsHeaderlList.Id);
        insert dsLineList;
        
        quote = factory.createQuote('approved', acc.Id, salesOpp.Id, isPrimaryQuote);
        quote.L2I_Reviewed_PO_Required__c = true;
        quote.SBQQ__BillingFrequency__c = 'Monthly';
        quote.SBQQ__StartDate__c = Date.today();
        quote.ApprovalStatus__c = 'Approved';
        quote.SBQQ__OrderByQuoteLineGroup__c = true;
        quote.SBQQ__LineItemsGrouped__c = true;
        insert quote;

        billingRule = new blng__BillingRule__c(Name = 'Test Billable Rule', 
                                               blng__InitialBillingTrigger__c = 'Order Product Activation Date', 
                                               blng__PartialPeriodTreatment__c = 'Separate', 
                                               blng__AmendmentBillCycleDateAlignment__c = 'Align to original Order Product', 
                                               blng__GenerateInvoices__c = 'No', blng__Active__c = True);
        insert billingRule;

        revRec = new blng__RevenueRecognitionRule__c(name = 'Test Revenue Recognition Rule', 
                                                     blng__Active__c = true, 
                                                     blng__CreateRevenueSchedule__c = 'No');
        insert revRec;

        taxRule = new blng__TaxRule__c(Name = 'Test tax Rule', blng__Active__c = true, blng__TaxableYesNo__c = 'No');
        insert taxRule;
        
        testProd = factory.createProduct('905647-TEST10', 'Test product', null, null, null);
        testProd.blng__BillingRule__c = billingRule.Id;
        testProd.blng__RevenueRecognitionRule__c = revRec.Id;
        testProd.blng__TaxRule__c = taxRule.Id;
        products.add(testProd);
        insert products;
        
        for (SObject prod : products) {
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), 
                                                    Product2Id = prod.Id, 
                                                    UnitPrice = 1000, 
                                                    IsActive = true);
            entries.add(pbe);
        }
        insert entries;
        
        sg = new SBQQ__SolutionGroup__c(Name = 'ALT', Type__c = 'CPL');
        //slGrpsList.add(sg);
        sg1 = new SBQQ__SolutionGroup__c(Name = 'FIT', Type__c = 'FC');
        //slGrpsList.add(sg1);
        sg2 = new SBQQ__SolutionGroup__c(Name = 'RACK', Type__c = 'EQ');
        slGrpsList.add(sg2);
        insert slGrpsList;

        for(SBQQ__SolutionGroup__c slg : slGrpsList) {
            SBQQ__QuoteLineGroup__c qlg1 = new SBQQ__QuoteLineGroup__c(Name = slg.Name, 
                                                                       SBQQ__SolutionGroup__c = slg.Id, 
                                                                       SBQQ__Quote__c = quote.Id);
            qlgList.add(qlg1);
        }
        insert qlgList;

        for(SBQQ__QuoteLineGroup__c qlg : qlgList) {
            SBQQ__QuoteLine__c ql1 = factory.createQuoteLine(quote.Id, products[0].Id, null);
            ql1.SBQQ__Group__c = qlg.Id;
            ql1.SBQQ__NetPrice__c = 10.0;
            qlList.add(ql1);
        }
        insert qlList;
    }
    
    /**
    * @Method Name        : invokeCPLOpptySplitTest
    * @Description        : Tests method of invokeCPLOpptySplit Class PT_SplitCPLOpptyToPPLOpptys
    * @Author             : Francis Jan Macam / Managed Services Simplus
    * @Modification Log   :
    * Ver       	Date       	  Author              Modification
    * W-003708    	Nov-22-2021   MS Simplus Francis  Improvement
    **/
    @isTest
    static void invokeCPLOpptySplitTest() { 
        test.startTest();
        Opportunity salesOpp = [SELECT Name, StageName, CloseDate, accountId, Probability, L2I_Parent_Opportunity__c,
                                       recordtypeId, Amount, L2I_Product_Category__c, L2I_Business_Class_Cabin_Configuration__c,
                                	   L2I_First_Class_Cabin_Configuration__c, L2I_Economy_Cabin_Configuration__c, 
                                	   L2I_Premium_Economy_Cabin_Configuration__c, L2I_Are_These_Follow_On_Aircraft__c,
                                	   L2I_Are_These_Partial_Shipsets__c 
                                FROM Opportunity 
                                WHERE Name = 'Sales PTSCPLOTPPLO-ICPLOS Test'];
            
        List<PT_SplitCPLOpptyToPPLOpptys.Requests> requests = new List<PT_SplitCPLOpptyToPPLOpptys.Requests>();
        PT_SplitCPLOpptyToPPLOpptys.Requests req = new PT_SplitCPLOpptyToPPLOpptys.Requests();
        req.opportunityId = salesOpp.Id;
        requests.add(req);

        PT_SplitCPLOpptyToPPLOpptys.invokeCPLOpptySplit(requests);
        test.stopTest();
    }
}