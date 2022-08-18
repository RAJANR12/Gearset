/**
 *      @author       Raj Rajen
 *      @date         07/17/2019
 *      @description  Data factory class used by Test Classes
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Raj Rajen                     07/17/2019         Initial scaffold
 *      Arun                          08/11/2019         Added createQuoteLine method
 *      Sarah Kennedy                 02/18/2020         Added createDeliverySchedule method without the DSH Deal_opportunity which is to be removed
 *      Sarah Kennedy                 03/04/2020         Removed references to Aircraft_Type__c, Business_Class__c, Economy_Class__c, First_Class__c,
 *                                                       Premium_Economy_Class__c, Subscription_Term__c, Term_Type__c (US1520)
 *      Sarah Kennedy                 03/05/2020         Removed call to factory.createDeliverySchedule with dealOppty.Id parameter (US1520)
 *      Sarah Kennedy                 03/11/2020         Modified setupAccountThruContract method to use a DSS Opportunity
 *      Sarah Kennedy                 05/05/2020         Removed LIMITS debug statements
 */

public class L2I_DataFactory {

    public L2I_DataFactory() {}

    public Account createCustomerAccount() {
        Account customer = new Account(Name = 'Utopian Airlines',
                                       RecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID,
                                       BillingStreet = '400 N.Beck Avenue',
                                       BillingCity = 'Chandler',
                                       BillingState = 'AZ',
                                       BillingPostalCode = '85226');
        return customer;
    }

    public Account createCompetitorAccount() {
        Account competitor = new Account(Name = 'InFlight Entertainment Systems R Us',
                                         RecordTypeId = L2I_StaticConstants.COMPETITOR_ACCOUNT_RT_ID,
                                         BillingStreet = '36455 Corporate Dr',
                                         BillingCity = 'Farmington Hills',
                                         BillingState = 'MI',
                                         BillingPostalCode = '48331');
        return competitor;
    }



    public Account createCustomerAccount(String name, String street, String city, String state, String zip) {
        Account customer = new Account(Name = name,
                                       RecordTypeId = L2I_StaticConstants.CUSTOMER_ACCOUNT_RT_ID,
                                       BillingStreet = street,
                                       BillingCity = city,
                                       BillingState = state,
                                       BillingPostalCode = zip);
        return customer;
    }

    public Account createCompetitorAccount(String name, String street, String city, String state, String zip) {
        Account competitor = new Account(Name = name,
                                         RecordTypeId = L2I_StaticConstants.COMPETITOR_ACCOUNT_RT_ID,
                                         BillingStreet = street,
                                         BillingCity = city,
                                         BillingState = state,
                                         BillingPostalCode = zip);
        return competitor;
    }

    public User createTestUser(Id roleId, Id profID, String fName, String lName) {
        // https://forceadventure.wordpress.com/2013/04/11/creating-test-users/
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(firstName = fName,
                              lastName = lName,
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = profId,
                              UserRoleId = roleId);
        return tuser;
    }

    public Product2 createProduct(String externalId, String name, String category, String subCategory1, String subCategory2) {
        Product2 prod = new Product2(L2I_Inventory_Item_Id__c=externalId,
                                     Name=name,
                                     L2I_Category__c=category,
                                     L2I_Sub_Category_1__c=subCategory1,
                                     L2I_Sub_Category_2__c=subCategory2);
        prod.L2I_System_Type_Translation__c = 'G';
        return prod;
    }
    
    public Product2 createProduct(String externalId, String name, String category, String subCategory1, String subCategory2, String sysTypeTrans) {
        Product2 prod = new Product2(L2I_Inventory_Item_Id__c=externalId,
                                     Name=name,
                                     L2I_Category__c=category,
                                     L2I_Sub_Category_1__c=subCategory1,
                                     L2I_Sub_Category_2__c=subCategory2,
                                     L2I_System_Type_Translation__c=sysTypeTrans);
        return prod;
    }

    public Opportunity createDealOpportunity(String name, String stage, Integer daysBeforeClose, Id acctId) {
        Opportunity dealOpp = new Opportunity(Name = name,
                                              StageName = stage,
                                              CloseDate = Date.today() + daysBeforeClose,
                                              accountId = acctId,
                                              recordtypeId = L2I_StaticConstants.DEAL_OPPORTUNITY_RT_ID);
        return dealOpp;
    }

    public Opportunity createSalesOpportunity(String name, String stage, Integer daysBeforeClose, Id acctId,
                                              Id parentDealOppty) {
        Opportunity salesOpp = new Opportunity(Name = name,
                                               StageName = stage,
                                               CloseDate = Date.today() + daysBeforeClose,
                                               accountId = acctId,
                                               L2I_Parent_Opportunity__c = parentDealOppty,
                                               recordtypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID);
        return salesOpp;
    }

    public Opportunity createSalesOpportunityWithAmount(String name, String stage, Integer daysBeforeClose, Id acctId,
                                                        Id parentDealOppty, Double amount, String productCategory) {
        Opportunity salesOpp = new Opportunity(Name = name,
                                               StageName = stage,
                                               CloseDate = Date.today() + daysBeforeClose,
                                               accountId = acctId,
                                               Probability = 40,
                                               L2I_Parent_Opportunity__c = parentDealOppty,
                                               recordtypeId = L2I_StaticConstants.SALES_OPPORTUNITY_RT_ID,
                                               Amount = amount,
                                               L2I_Product_Category__c = productCategory,
                                               L2I_Business_Class_Cabin_Configuration__c = 'None; N/A',
                                               L2I_First_Class_Cabin_Configuration__c = 'None; N/A',
                                               L2I_Economy_Cabin_Configuration__c = 'None; N/A',
                                               L2I_Premium_Economy_Cabin_Configuration__c = 'None; N/A',
                                               L2I_Are_These_Follow_On_Aircraft__c = 'No',
                                               L2I_Are_These_Partial_Shipsets__c = 'No');

        if ( salesOpp.L2I_Product_Category__c == 'IFEC' ){

            salesOpp.L2I_Cabin_Configuration__c = '1-Class';
            salesOpp.L2I_First_Class_Cabin_Configuration__c = 'In-Seat Audio Only';
            salesOpp.L2I_Business_Class_Cabin_Configuration__c = 'In-Seat Audio Only';
            salesOpp.L2I_Premium_Economy_Cabin_Configuration__c = 'In-Seat Audio Only';
            salesOpp.L2I_Economy_Cabin_Configuration__c = 'In-Seat Audio Only';
			salesOpp.L2I_Fit_Type__c = 'Retrofit';
        }

        return salesOpp;
    }

    public SBQQ__Quote__c createQuote(String qType, Id accountId, Id opportunityId, Boolean isPrimary) {
        SBQQ__Quote__c quote = null;

        switch on qType.toLowerCase() {
            when 'draft' {
                quote = new SBQQ__Quote__c(recordtypeId = L2I_StaticConstants.DRAFT_QUOTE_RT_ID,
                                           SBQQ__Account__c = accountId,
                                           SBQQ__Opportunity2__c = opportunityId,
                                          L2I_System_Type1__c = 'All',
                                          L2I_Connectivity_System_Type1__c = 'All',
                                           SBQQ__Primary__c = isPrimary);
            }
            when 'approved' {
                quote = new SBQQ__Quote__c(recordtypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
                                           SBQQ__Account__c = accountId,
                                           SBQQ__Opportunity2__c = opportunityId,
                                           L2I_System_Type1__c = 'All',
                                           L2I_Connectivity_System_Type1__c = 'All',
                                           SBQQ__Primary__c = isPrimary);
            }
            when 'pending' {
                quote = new SBQQ__Quote__c(recordtypeId = L2I_StaticConstants.PENDING_QUOTE_RT_ID,
                                           SBQQ__Account__c = accountId,
                                           SBQQ__Opportunity2__c = opportunityId,
                                          L2I_System_Type1__c = 'All',
                                          L2I_Connectivity_System_Type1__c = 'All',
                                           SBQQ__Primary__c = isPrimary);
            }
            when else {
                // do nothing, just return a null quote.
            }
        }

        quote.L2I_Cabin_Configuration__c = '1-Class';
        quote.L2I_First_Class_Cabin_Configuration__c = 'In-Seat Audio Only';
        quote.L2I_Business_Class_Cabin_Configuration__c = 'In-Seat Audio Only';
        quote.L2I_Premium_Economy_Cabin_Configuration__c = 'In-Seat Audio Only';
        quote.L2I_Economy_Cabin_Configuration__c = 'In-Seat Audio Only';

        return quote;
    }

    public SBQQ__QuoteLine__c createQuoteLine(Id quoteId, Id productId, Id reqQuoteId) {
        return new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteId,
                                      SBQQ__Product__c = productId,
                                      SBQQ__RequiredBy__c = reqQuoteId);
    }


    public L2I_Aircraft_Type__c createAircraftType( Id acctId, Integer partyID ){
        L2I_Aircraft_Type__c aircrafttype = new L2I_Aircraft_Type__c();
        aircrafttype.Name = 'F-18';
        aircrafttype.L2I_Is_Active__c = true;
        aircrafttype.Manufacturer__c = acctId;
        aircrafttype.L2I_Make__c = 'Mustand';
        aircrafttype.L2I_Model__c = 'GT';
        aircrafttype.L2I_Series__c = 'Racing';
        aircrafttype.L2I_Manufacturer_Party_ID__c = partyID;
        aircrafttype.L2I_PAC_Type_Designator__c = 'ABCD';
        aircrafttype.L2I_Aircraft_Type__c = 'Testing';
        aircrafttype.L2I_Program_Code__c = '001';
        return aircrafttype;

    }

    public L2I_Aircraft__c createAircraft(Id aircraftTypeId, String acName, String gpin, Id operatorId){

        L2I_Aircraft__c ac = new L2I_Aircraft__c();
        ac.Name = acName;
        ac.Aircraft_Type__c = aircraftTypeId;
        ac.L2I_GPIN__c = gpin;
        ac.L2I_Approved__c = true;
        // new fields that are required as of 8/26
        ac.L2I_Operator__c = operatorId;
        ac.L2I_Serial_Number__c = 'abc12289';
        ac.L2I_Aircraft_Delivery_Date__c = Date.today().addDays(30);
        ac.L2I_Aircraft_Status__c = 'In Service';

        return ac;
    }

    //L2I_DSH__c
//    public L2I_DSH__c createDeliverySchedule(Id accountId, Id acTypeId, Id oppoId) {
//        L2I_DSH__c dsh = new L2I_DSH__c();
//        dsh.Account__c = accountId;
//        dsh.Aircraft_Quantity__c = 5;
//        dsh.Aircraft_Type__c = acTypeId;
//        dsh.Business_Class__c = 20;
//        dsh.Deal_Opportunity__c = oppoId;
//        dsh.Economy_Class__c = 20;
//        dsh.First_Class__c = 20;
//        dsh.Premium_Economy_Class__c = 20;
//        dsh.Subscription_Term__c = 36;
//        dsh.Term_Type__c = 'Fixed';
//        return dsh;
//    }
    //L2I_DSH__c
    public L2I_DSH__c createDeliverySchedule(Id accountId, Id acTypeId) {
        L2I_DSH__c dsh = new L2I_DSH__c();
        dsh.Account__c = accountId;
        return dsh;
    }

    //L2I_DSL__c
    public L2I_DSL__c createDeliveryScheduleLine( Id dshId ) {
        L2I_DSL__c dsl = new L2I_DSL__c();
        //Aircraft__c
        dsl.Delivery_Schedule_Header__c = dshId;
        dsl.Delivery_Date__c = Date.today();
        dsl.Line_Number__c = '01';
        //dsh.L2I_Advertising_Est_Start_Date__c = Date.today();
        //dsh.L2I_Aircraft_Confirmation__c = true;
        return dsl;
    }

    //L2I_P_L_Sales_Opportunity__c
    public L2I_P_L_Sales_Opportunity__c createPLSalesOpp( Id approvalId, Id salesOppId ) {
        L2I_P_L_Sales_Opportunity__c sOpp = new L2I_P_L_Sales_Opportunity__c();
        sOpp.L2I_P_L_Approval__c = approvalId;
        sOpp.L2I_Sales_Opportunity__c = salesOppId;
        return sOpp;
    }

    //L2I_P_L_Approval__c
    public L2I_P_L_Approval__c createPLApproval( Id dealOppId, String approvalStatus ) {
        L2I_P_L_Approval__c approval = new L2I_P_L_Approval__c();
        approval.L2I_Approval_Deal_Opportunity__c = dealOppId;
        approval.ApprovalStatus__c = approvalStatus;
        return approval;
    }

    //L2I_Competitors__c
    public L2I_Competitors__c createCompetitor( Id salesOppId, Id acctId, String sType ) {
        L2I_Competitors__c comp = new L2I_Competitors__c();
        comp.Opportunity__c = salesOppId;
        comp.CompetitorAccount__c = acctId;
        comp.Type__c = sType;
        return comp;
    }

    // OpportunityTeamMember
    public OpportunityTeamMember createOpportunityTeamMember(String teamMemberRole, String accessLevel, Id opptyId, Id userId) {
        OpportunityTeamMember opptyTeamMbr = new OpportunityTeamMember(
              TeamMemberRole = teamMemberRole,
              OpportunityAccessLevel = accessLevel,
              OpportunityId = opptyId,
              UserId = userId
        );
        return opptyTeamMbr;
    }

    public void setupTestContext(List<SObject> products, List<PricebookEntry> pbEntries, Boolean loadFinancePeriods) {
        List<SObject> blng_GLRules = Test.loadData(blng__GLRule__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('GLRule_file'));


        List<SObject> blng_LegalEntities = Test.loadData(blng__LegalEntity__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('LegalEntity_file'));


        List<SObject> blng_financeBooks = Test.loadData(blng__FinanceBook__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('FinanceBook_file'));


        List<SObject> blng_billingRules = Test.loadData(blng__BillingRule__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('BillingRule_file'));


        List<SObject> blng_taxRules = Test.loadData(blng__TaxRule__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('TaxRule_file'));


        List<SObject> blng_revrecRules = Test.loadData(blng__RevenueRecognitionRule__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('RevenueRecognitionRule_file'));


        List<SObject> blng_GLAccounts = Test.loadData(blng__GLAccount__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('GLAccount_file'));


        List<SObject> blng_GLTreatments = Test.loadData(blng__GLTreatment__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('GLTreatment_file'));

        // the following is a time-consuming load. Turn it on only if it is needed. In all likelihood, this is needed
        // for Invoice runs, which is not in scope for the set of tests in this UnitTest class
        if (loadFinancePeriods) {
            List<SObject> blng_financePeriods = Test.loadData(blng__FinancePeriod__c.sObjectType,
                                                              L2I_StaticConstants.unitTestStaticResource.get('FinancePeriod_file'));
        }

        List<SObject> blng_billingTreatments = Test.loadData(blng__BillingTreatment__c.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('BillingTreatment_file'));


        products = Test.loadData(Product2.sObjectType,
              L2I_StaticConstants.unitTestStaticResource.get('Product2_file'));


        pbEntries = new List<PricebookEntry>();
        for (SObject prod : products) {
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                  Product2Id = prod.Id,
                  UnitPrice = 1000,
                  IsActive = true);
            pbEntries.add(pbe);
        }
        insert pbEntries;
    }


    // set up Account through Contract objects
    // For Products, Pricebooks and Rules to be set properly - run setupTestContext() first
    // NOTE: Running this causes SOQL Limit errors
//    public void setupAccountThruContract(List<SObject> products, List<PricebookEntry> pbEntries, Boolean loadFinancePeriods) {
//        // set rules, products
//        setupTestContext(products, pbEntries, loadFinancePeriods);
//
//        // create objects
//        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
//        objFactory.loadResource('Unit_Test_AccountThruQuote');
//        L2I_DSH__c dsh = [select id from l2i_DSH__c];
//        Opportunity salesOpp = [select Id , L2I_Delivery_Schedule__c, L2I_Product_Category__c, L2I_Fit_Type__c FROM Opportunity WHERE RecordType.DeveloperName = 'Sales'];
//        salesOpp.L2I_Delivery_Schedule__c = dsh.Id;
//        update salesOpp;
//
//        Map<String, SObject> registry = objFactory.getRegistry();
//        for (String key : registry.keySet()) {
//            SObject obj = objFactory.getRegistryItem(key);
//        }
//
//        // get created records
//        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
//        Account competitorCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Competitor' LIMIT 1];
//        Opportunity DealOppty = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'Deal' LIMIT 1];
//
//        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
//        Opportunity salesOppty = new Opportunity(
//              Name = 'TestSalesOpp',
//              StageName = 'Quotation',
//              CloseDate = Date.today(),
//              L2I_Parent_Opportunity__c = DealOppty.Id,
//              L2I_Product_Category__c = 'DSS',
//              RecordTypeId = salesId);
//        insert salesOppty;
//        System.debug('*** D. LIMIT ' + LIMITS.getQueries());
//
//        L2I_Competitors__c comp = new L2I_Competitors__c();
//        comp.Opportunity__c = salesOppty.Id;
//        comp.CompetitorAccount__c = competitorCustomer.Id;
//        comp.Type__c = 'DSS';
//        comp.Primary__c = true;
//        insert comp;
//
//        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(
//              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
//              SBQQ__Account__c = namedCustomer.Id,
//              SBQQ__Opportunity2__c = salesOppty.Id,
//              SBQQ__Primary__c = true,
//              L2I_System_Type1__c = 'All',
//              L2I_Connectivity_System_Type1__c = 'All'
//        );
//        insert quote1;
//        System.debug('*** E. LIMIT ' + LIMITS.getQueries());
//
//        L2I_DSH__c dsHeader = [SELECT Id FROM L2I_DSH__c LIMIT 1];
//
//        // create Quotelines
//        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
//        Map<Id, String> prodCategoryMap = new Map<Id, String>();
//        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
//        Map<String, Id> prodIdMap = new Map<String, Id>();
//        for (Product2 p : prodList) {
//            prodIdMap.put(p.Name, p.Id);
//            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
//        }
//        Set<String> ProductNameList = new Set<String>();
//        ProductNameList.add('Live Television - Monthly Additional Satellite Capacity - per aircraft');
//        Set<Id> prodIdList = New Set<Id>();
//        for (String s : ProductNameList) {
//            Id pid = prodIdMap.get(s);
//            prodIdList.add(pid);
//            SBQQ__QuoteLine__c quoteLine = createQuoteLine(quote1.Id, pid, null);
//            qlList.add(quoteLine);
//        }
//        insert qlList;
//        System.debug('*** F. LIMIT ' + LIMITS.getQueries());
//        // create Order
//        List<PricebookEntry> pbeList = [
//              select Id,
//                    Product2Id,
//                    Pricebook2Id,
//                    UnitPrice,
//                    IsActive
//              from PricebookEntry
//              where Product2Id in:prodIdList
//        ];
//
//        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
//        for (PricebookEntry pbe : pbeList) {
//            pricebookMap.put(pbe.Product2Id, pbe);
//        }
//        Order theTestOrder = new Order(AccountId = namedCustomer.Id,
//              PoNumber = 'Test',
//              EffectiveDate = Date.today(),
//              Status = 'Draft',
//              Pricebook2Id = Test.getStandardPricebookId(),
//              blng__BillingDayOfMonth__c = '30',
//              OpportunityId = salesOppty.Id,
//              SBQQ__Quote__c = quote1.Id,
//              L2I_Delivery_Schedule__c = dsHeader.Id);
//        insert theTestOrder;
//        System.debug('*** G. LIMIT ' + LIMITS.getQueries());
//        // create OrderItems
//        List<OrderItem> OrderItemList = new List<OrderItem>();
//        blng__BillingRule__c billingrule = [select Id from blng__BillingRule__c where name = 'Non-Billable Product Rule' limit 1];
//        for (Id pid : prodIdList) {
//            OrderItem theTestOrderItem = new OrderItem(OrderId = theTestOrder.id,
//                  Quantity = 1,
//                  Product2Id = pid,
//                  PricebookEntryId = pricebookMap.get(pid).Id,
//                  UnitPrice = pricebookMap.get(pid).UnitPrice,
//                  L2I_Sub_Category_2__c = prodCategoryMap.get(pid),
//                  SBQQ__ChargeType__c = 'Recurring',
//                  SBQQ__BillingFrequency__c = 'Monthly',
//                  SBQQ__BillingType__c = 'Advance',
//                  blng__BillingRule__c = billingrule.Id,
//                  SBQQ__DefaultSubscriptionTerm__c = 24,
//                  L2I_blng_MatchingId__c = '00N18000001Vkc2',
//                  SBQQ__Activated__c = true);
//            OrderItemList.add(theTestOrderItem);
//        }
//
//        insert OrderItemList;
//
//        System.debug('*** H. LIMIT ' + LIMITS.getQueries());
//        theTestOrder.Status = 'Activated';
//        theTestOrder.StatusCode = 'Activated';
//        update theTestOrder;
//
//        theTestOrder.SBQQ__Contracted__c = true;
//        update theTestOrder;
//
//        // create Contract
//        Contract ctr = new Contract(
//              AccountId = namedCustomer.Id,
//              SBQQ__Order__c = theTestOrder.Id,
//              SBQQ__Opportunity__c = salesOppty.Id,
//              SBQQ__Quote__c = quote1.Id,
//              Status = 'Draft',
//              Pricebook2Id = Test.getStandardPricebookId(),
//              CurrencyIsoCode = 'USD',
//              ContractTerm = 24,
//              StartDate = Date.today().addMonths(3),
//              SBQQ__PreserveBundleStructureUponRenewals__c = true,
//              SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
//              SBQQ__DefaultRenewalPartners__c = true,
//              SBQQ__DefaultRenewalContactRoles__c = true
//        );
//        insert ctr;
//        System.debug('*** J. LIMIT ' + LIMITS.getQueries());
//    }

    // set up Account through Order objects
    // For Products, Pricebooks and Rules to be set properly - run setupTestContext() first
    public void setupAccountThruOrder(List<SObject> products, List<PricebookEntry> pbEntries, Boolean loadFinancePeriods, String ordStatus) {
        // set rules, products
        setupTestContext(products, pbEntries, loadFinancePeriods);

        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        // Added for W-001727
        Product2 prodSysType = createProduct('9876543','EX3','IFEC','IFE HW', 'X-Series');
        insert prodSysType;
        
        L2I_DSH__c dsh = [select id from l2i_DSH__c];
        Opportunity salesOpp = [select Id , L2I_Delivery_Schedule__c, L2I_Product_Category__c, L2I_Fit_Type__c, L2I_Primary_System_Type__c FROM Opportunity WHERE RecordType.DeveloperName = 'Sales'];
        salesOpp.L2I_Delivery_Schedule__c = dsh.Id;
        // Added for W-001727
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        
        update salesOpp;

        Map<String, SObject> registry = objFactory.getRegistry();
        for (String key : registry.keySet()) {
            SObject obj = objFactory.getRegistryItem(key);
        }

        // get created records
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        SBQQ__Quote__c quote1 = [SELECT Id FROM SBQQ__QUOTE__c LIMIT 1];
        quote1.SBQQ__PriceBook__c = Test.getStandardPricebookId();
        update quote1;

        // create Quotelines
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        Map<Id, String> prodCategoryMap = new Map<Id, String>();
        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];
        Map<String, Id> prodIdMap = new Map<String, Id>();
        for (Product2 p : prodList) {
            System.debug('*** p ' + p);
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }
        Set<String> ProductNameList = new Set<String>();
        ProductNameList.add('Panasonic WIFI');
        // ProductNameList.add('Live Television - Monthly Additional Satellite Capacity - per aircraft');
        Set<Id> prodIdList = New Set<Id>();
        for (String s : ProductNameList) {
            Id pid = prodIdMap.get(s);
            prodIdList.add(pid);
        }
        System.debug('*** ProductNameList ' + ProductNameList);
        List<PricebookEntry> pbeList = [SELECT Id,Product2Id,Pricebook2Id,UnitPrice,IsActive FROM PricebookEntry WHERE Product2Id in:prodIdList];
        System.debug('*** pbeList ' + pbeList);
        
        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : pbeList) {
            pricebookMap.put(pbe.Product2Id, pbe);
        }
        String pbe;
        for (String s : ProductNameList) {
            Id pid = prodIdMap.get(s);
            pbe = pricebookMap.get(pid).Id;
            SBQQ__QuoteLine__c quoteLine = createQuoteLine(quote1.Id, pid, null);
            quoteLine.SBQQ__PricebookEntryId__c = pricebookMap.get(pid).Id;
            System.debug('*** pricebookMap.get(pid).Id '+ pricebookMap.get(pid).Id);
            System.debug('*** quoteLine ' + quoteLine);
            qlList.add(quoteLine);
        }
        insert qlList;
        qlList[0].SBQQ__PricebookEntryId__c = pbe;
        qlList[0].L2I_blng_MatchingId__c = '00N18000001Vkc2';
        update qlList;
        System.debug('*** update qlList ' + [SELECT Id, SBQQ__Quote__c, SBQQ__Product__c, SBQQ__PricebookEntryId__c FROM SBQQ__QuoteLine__c]);
        // create Order
        Order theTestOrder = new Order(AccountId = namedCustomer.Id,PoNumber = 'Test',EffectiveDate = Date.today(),Status = 'Draft',Pricebook2Id = Test.getStandardPricebookId(),
                                       blng__BillingDayOfMonth__c = '30',OpportunityId = salesOpp.Id,SBQQ__Quote__c = quote1.Id,L2I_Product_Category_2__c = 'TV/Media',
                                       L2I_Order_Process__c = 'Contract Management',L2I_Delivery_Schedule__c = dsh.Id);
        insert theTestOrder;

        // create OrderItems
        List<OrderItem> OrderItemList = new List<OrderItem>();
        blng__BillingRule__c billingrule = [select Id from blng__BillingRule__c where name = 'Non-Billable Product Rule' limit 1];
        for (Id pid : prodIdList) {
            System.debug('*** pricebookMap.get(pid).Id ' + pricebookMap.get(pid).Id);
            OrderItem theTestOrderItem = new OrderItem(OrderId = theTestOrder.id,Quantity = 1,Product2Id = pid,PricebookEntryId = pricebookMap.get(pid).Id,
                                                       UnitPrice = pricebookMap.get(pid).UnitPrice,L2I_Sub_Category_2__c = prodCategoryMap.get(pid),SBQQ__ChargeType__c = 'Recurring',SBQQ__BillingFrequency__c = 'Monthly',
                                                       SBQQ__BillingType__c = 'Advance',blng__BillingRule__c = billingrule.Id,SBQQ__DefaultSubscriptionTerm__c = 24,SBQQ__Activated__c = true);
            OrderItemList.add(theTestOrderItem);
        }
        insert OrderItemList;


        if (ordStatus == 'Activated') {
            theTestOrder.Status = 'Activated';
            theTestOrder.StatusCode = 'Activated';
            update theTestOrder;
        }
    }


     public PL_MD__c createPLMD() {
                         PL_MD__c plmd = new PL_MD__c();
                         plmd.Name='IFE Hardware';
                         plmd.Pillar__c='IFE';
                         plmd.Product_Group__c='IFE Hardware';
                         plmd.Sort_Order__c=1;
                         //plmd.Sub_Total_Label__c='IFE';
                         plmd.MD_Type__c ='Product Group';
        return plmd;
    }
    
    // set up Account through Order objects
    // For Products, Pricebooks and Rules to be set properly - run setupTestContext() first
    public void setupAccountThruOrder2(List<SObject> products, List<PricebookEntry> pbEntries, Boolean loadFinancePeriods, String ordStatus) {
        String pbe;
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();        
        List<OrderItem> OrderItemList = new List<OrderItem>();
        Set<String> ProductNameList = new Set<String>();
        Set<Id> prodIdList = New Set<Id>();
        Map<Id, String> prodCategoryMap = new Map<Id, String>();
        Map<String, Id> prodIdMap = new Map<String, Id>();        
        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
        
        // set rules, products
        setupTestContext(products, pbEntries, loadFinancePeriods);
       
        // create objects
        L2I_ObjectFactory objFactory = new L2I_ObjectFactory();
       
        objFactory.loadResource('Unit_Test_AccountThruQuote');
        
        // Added for W-001727
        Product2 prodSysType = createProduct('1236541','EXW','IFEC','IFE HW', 'X-Series','C');
        insert prodSysType;
       
        L2I_DSH__c dsh = [SELECT id FROM l2i_DSH__c LIMIT 1];
        
        Opportunity salesOpp = [SELECT Id , L2I_Delivery_Schedule__c, L2I_Product_Category__c, L2I_Fit_Type__c, L2I_Primary_System_Type__c FROM Opportunity WHERE RecordType.DeveloperName = 'Sales' LIMIT 1];
        salesOpp.L2I_Delivery_Schedule__c = dsh.Id;
        // Added for W-001727
        salesOpp.L2I_Primary_System_Type__c = prodSysType.Id;
        System.debug(salesOpp);
        update salesOpp;
        
        Map<String, SObject> registry = objFactory.getRegistry();
        for (String key : registry.keySet()) {
            SObject obj = objFactory.getRegistryItem(key);
        }
        
        test.startTest();
        
        // get created records
        Account namedCustomer = [SELECT Id FROM Account WHERE Recordtype.Developername = 'Customer' LIMIT 1];
        SBQQ__Quote__c quote1 = [SELECT Id FROM SBQQ__QUOTE__c LIMIT 1];
        quote1.SBQQ__PriceBook__c = Test.getStandardPricebookId();
        update quote1;
        
        // create Quotelines
        List<Product2> prodList = [SELECT Id, Name, L2I_Sub_Category_2__c FROM Product2];

        for (Product2 p : prodList) {
            prodIdMap.put(p.Name, p.Id);
            prodCategoryMap.put(p.Id, p.L2I_Sub_Category_2__c);
        }        

        ProductNameList.add('Panasonic WIFI');
        // ProductNameList.add('Live Television - Monthly Additional Satellite Capacity - per aircraft');
        
        for (String s : ProductNameList) {
            Id pid = prodIdMap.get(s);
            prodIdList.add(pid);
        }
        
        List<PricebookEntry> pbeList = [
              SELECT Id,
                    Product2Id,
                    Pricebook2Id,
                    UnitPrice,
                    IsActive
              FROM PricebookEntry
              WHERE Product2Id in:prodIdList
        ];
        
        for (PricebookEntry pbes : pbeList) {
            pricebookMap.put(pbes.Product2Id, pbes);
        }        
        
        for (String s : ProductNameList) {
            Id pid = prodIdMap.get(s);
            pbe = pricebookMap.get(pid).Id;
            SBQQ__QuoteLine__c quoteLine = createQuoteLine(quote1.Id, pid, null);
            quoteLine.SBQQ__PricebookEntryId__c = pricebookMap.get(pid).Id;
            qlList.add(quoteLine);
        }
        insert qlList;
        
        qlList[0].SBQQ__PricebookEntryId__c = pbe;
        qlList[0].L2I_blng_MatchingId__c = '00N18000001Vkc2';
        update qlList;
        
        // create Order
        Order theTestOrder = new Order(AccountId = namedCustomer.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',
              OpportunityId = salesOpp.Id,
              SBQQ__Quote__c = quote1.Id,
              L2I_Product_Category_2__c = 'TV/Media',
              L2I_Order_Process__c = 'Contract Management',
              L2I_Delivery_Schedule__c = dsh.Id);
        insert theTestOrder;
        
        // create OrderItems       
        blng__BillingRule__c billingrule = [SELECT Id FROM blng__BillingRule__c WHERE name = 'Non-Billable Product Rule' LIMIT 1];
        
        for (Id pid : prodIdList) {
            OrderItem theTestOrderItem = new OrderItem(OrderId = theTestOrder.id,
                  Quantity = 1,
                  Product2Id = pid,
                  PricebookEntryId = pricebookMap.get(pid).Id,
                  UnitPrice = pricebookMap.get(pid).UnitPrice,
                  L2I_Sub_Category_2__c = prodCategoryMap.get(pid),
                  SBQQ__ChargeType__c = 'Recurring',
                  SBQQ__BillingFrequency__c = 'Monthly',
                  SBQQ__BillingType__c = 'Advance',
                  blng__BillingRule__c = billingrule.Id,
                  SBQQ__DefaultSubscriptionTerm__c = 24,
                  L2I_blng_MatchingId__c = '00N18000001Vkc2',
                  SBQQ__Activated__c = true);
            OrderItemList.add(theTestOrderItem);
        }
        insert OrderItemList;

        if (ordStatus == 'Activated') {
            theTestOrder.Status = 'Activated';
            theTestOrder.StatusCode = 'Activated';
            update theTestOrder;
        }
        test.stopTest();
    }

}