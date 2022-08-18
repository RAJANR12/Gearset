/**
 * @Class Name    : PTI_CreateProgramController_Test
 * @Description    : Test Class for PTI_CreateProgramController
 **/
@IsTest
private class PTI_CreateProgramController_Test{
/**
    * @Method Name  : testCreateProgram
    * @Description  : test Method for covering PTI_CreateProgramController
    **/
    @IsTest
    public static void onCreateProgramFromFlow() {
        L2I_DataFactory df = new L2I_DataFactory();
        Account namedCustomer = df.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        
        Opportunity dealOppty = df.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        L2I_Aircraft_Type__c airType = df.createAircraftType(namedCustomer.Id, null);        
        airType.Name = airType.Name + '1';
        airType.Available_in_Oracle_PT__c = TRUE;
        
        insert airType;
            
        L2I_Aircraft__c airCraft = df.createAircraft(airType.Id, 'Testac', 'A319-1100', namedCustomer.Id);
        insert airCraft;
            
        L2I_DSH__c dsh = df.createDeliverySchedule(namedCustomer.Id, airType.Id);
        insert dsh;

        L2I_DSL__c dsl = new L2I_DSL__c(
              Delivery_Schedule_Header__c = dsh.Id,
              PT_isActive__c = 'Active'
        );
        insert dsl;

        PT_Install_Location__c instLoc2 = new PT_Install_Location__c(
              Name = 'EC',
              ShipSet__c = dsl.Id,
              Status__c = 'Active'
        );
        insert instLoc2;        
        
        Product2 prodSysType = df.createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        Opportunity salesIFECOppty = df.createSalesOpportunity('SalesOppIFEC', 'Quotation', 5, namedCustomer.Id, dealOppty.Id);
        salesIFECOppty.L2I_Aircraft_Type__c = airType.Id;
        salesIFECOppty.L2I_Product_Category__c = 'IFEC';
        salesIFECOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesIFECOppty;
        
        SBQQ__Quote__c IFECQuote = df.createQuote('draft', namedCustomer.Id, salesIFECOppty.Id, false);
        IFECQuote.SBQQ__Primary__c = true;
        IFECQuote.ApprovalStatus__c = 'Approved';
        IFECQuote.L2I_Final_Proposal_Submission_Date__c = Date.today();
        IFECQuote.SubmittedDate__c = Date.today(); // Added by Khrisna for W-004060
        insert IFECQuote;
        
                
        Product2 prodIFEC = new product2(Name = 'Test IFEC', productCode = 'TBD-Hardware', L2I_Inventory_Item_Id__c = '99999788', L2I_PMO_Install_Code__c = 'EC');
        insert prodIFEC;
        
        List<SBQQ__QuoteLine__c> qls = new List<SBQQ__QuoteLine__c>();
        qls.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = IFECQuote.Id, SBQQ__Product__c = prodIFEC.Id));
        insert qls;
        
                SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
              Name = 'EC'
        );
        insert sg;

        List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
        for (SBQQ__QuoteLine__c ql : qls) {
            if(ql.SBQQ__Product__c == prodIFEC.Id){
                SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
                qlg.SBQQ__Account__c = namedCustomer.id;
                qlg.SBQQ__SolutionGroup__c = sg.Id;
                qlg.SBQQ__Quote__c = IFECQuote.Id;
                qlgList.add(qlg);
            }
        }
        insert qlgList;
        
        for (SBQQ__QuoteLine__c ql : qls) {
            if(ql.SBQQ__Product__c == prodIFEC.Id){ql.SBQQ__Group__c = qlgList[0].Id;}
        }
        update qls;

        Test.startTest();
        Opportunity salesDSSOppty = df.createSalesOpportunity('SalesOppDSS', 'Quotation', 5, namedCustomer.Id, dealOppty.Id);
        salesDSSOppty.L2I_Aircraft_Type__c = airType.Id;
        salesDSSOppty.L2I_Product_Category__c = 'DSS';
        salesDSSOppty.L2I_Primary_System_Type__c = prodSysType.Id;
        insert salesDSSOppty;
        
        SBQQ__Quote__c DSSQuote = df.createQuote('draft', namedCustomer.Id, salesDSSOppty.Id, false);
        DSSQuote.SBQQ__Primary__c = true;
        DSSQuote.ApprovalStatus__c = 'Approved';
        DSSQuote.L2I_Final_Proposal_Submission_Date__c = Date.today();
        DSSQuote.SubmittedDate__c = Date.today(); // Added by Khrisna for W-004060
        insert DSSQuote;
        
        Product2 prodY = new product2(Name = 'Test YYY', productCode = 'TBD-OneTime', L2I_Inventory_Item_Id__c = '99999804', L2I_PMO_Install_Code__c = 'EC',L2I_Primary_Charge_Method__c  = 'AIRLINE');
        insert prodY;
        
        Product2 prodRecurY = new product2(Name = 'Test Rec', productCode = 'TBD-Recurring', L2I_Inventory_Item_Id__c = '99999448', L2I_PMO_Install_Code__c = 'EC',L2I_Primary_Charge_Method__c  = 'AIRCRAFT');
        insert prodRecurY;
        
        qls = new List<SBQQ__QuoteLine__c>();
        qls.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = DSSQuote.Id, SBQQ__Product__c = prodRecurY.Id));
        insert qls;

        
        salesDSSOppty.SBQQ__PrimaryQuote__c = DSSQuote.Id;
        salesDSSOppty.StageName = 'Handoff';
        salesDSSOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesDSSOppty;
        
        salesIFECOppty.SBQQ__PrimaryQuote__c = IFECQuote.Id;
        salesIFECOppty.StageName = 'Handoff';
        salesIFECOppty.L2I_Delivery_Schedule__c = dsh.Id;
        update salesIFECOppty;
        
        L2I_P_L_Approval__c pla = df.createPLApproval(dealOppty.Id, 'Pending');
        pla.L2I_Revision_Status__c = 'Initial';
        insert pla;
    
        L2I_P_L_Sales_Opportunity__c plso = df.createPLSalesOpp( pla.Id, salesDSSOppty.Id );
        insert plso;
        
        L2I_P_L_Sales_Opportunity__c plso2 = df.createPLSalesOpp( pla.Id, salesIFECOppty.Id );
        insert plso2;
        
        pla.ApprovalStatus__c = 'Approved';
        pla.L2I_Revision_Status__c = 'Award';
        update pla;
        List<Id> plSalesOpp = new List<Id>{pla.Id};
        
        
        PTI_CreateProgramController.onCreateProgramFromFlow(plSalesOpp);
        Test.stopTest();
             
    }
  
}