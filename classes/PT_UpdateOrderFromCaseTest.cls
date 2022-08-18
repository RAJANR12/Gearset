@IsTest
private with sharing class PT_UpdateOrderFromCaseTest
{
    private static void setupTestData()
    {
       L2I_DataFactory dt = new L2I_DataFactory();
        List<SObject> blng_billingRules = Test.loadData(blng__BillingRule__c.sObjectType,
        L2I_StaticConstants.unitTestStaticResource.get('BillingRule_file'));

        Account namedCustomer = dt.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;

        PT_Program__c Ptobj = new PT_Program__c();
        Ptobj.Program_Number__c = 'ADL32X001';
        Ptobj.PT_Program_Number_Alt__c = 'HZZ2200A1';
        Ptobj.Name= 'ADL32X001';
        insert Ptobj;

        Product2 prod2 = new Product2(Name = 'TestProd', ProductCode = 'ProdCode', L2I_Inventory_Item_Id__c = '99999803');
       // prod2.L2I_Program_Num__c = Ptobj.id;
        insert prod2;

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                  Product2Id = prod2.Id,
                  UnitPrice = 1000,
                  IsActive = true);

        insert pbe;

        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;
        Opportunity opps = dt.createDealOpportunity('opps01','Open',10,namedCustomer.id);
        opps.PT_PPL_Type__c = 'EQ';
        opps.L2I_Program_Num__c = Ptobj.id;
        insert opps;

        SBQQ__Quote__c quote1 = dt.createQuote('draft',namedCustomer.id,opps.id, true);
        System.debug('Test.getStandardPricebookId();' + Test.getStandardPricebookId());
        quote1.SBQQ__PriceBook__c = Test.getStandardPricebookId();
        insert quote1;

        System.debug('CheckQuote::' + quote1.SBQQ__PriceBook__c);
        SBQQ__QuoteLine__c ql4 = dt.createQuoteLine(quote1.Id, prod2.Id, null);
        ql4.L2I_CPQMultiplier__c = 'Annual Subscription Term';
        ql4.L2I_Number_of_Shipments__c = 5;
        ql4.SBQQ__SubscriptionTerm__c = 12;
        ql4.L2I_MonthlyPrice2__c = 20;
        //ql4.SBQQ__Group__c = qlg.Id;
        ql4.SBQQ__Product__c = prod2.id;
        ql4.SBQQ__ListPrice__c = 20.0;
        ql4.L2I_TotalCostperAircraft2__c =20.0;
        ql4.SBQQ__PricebookEntryId__c = pbe.id;
        ql4.SBQQ__Quote__c = quote1.id;

        insert ql4;

        System.debug('CheckQ4::' + ql4);
         SBQQ__SolutionGroup__c sg = new SBQQ__SolutionGroup__c(
            Name = 'ALT'
         );
        insert sg;

        PT_Install_Location__c PtInstallationobj = new PT_Install_Location__c();
        PtInstallationobj.Solution_Group__c = sg.id;
        PtInstallationobj.Part_List_Opportunity__c = opps.id;
        insert PtInstallationobj;

        Case cases = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', PT_Program__c = prog1.Id,AccountId =namedCustomer.id );
        insert cases;
        Asset ast = new Asset(
                    Name = 'AssetName',
                    AccountId = namedCustomer.Id,
                    Product2Id = prod2.Id,
                    PT_Program__c = prog1.Id,
                    PT_Case__c = cases.id,
                    Quantity = 10,
                    PT_Install_Location__c = PtInstallationobj.id,
                    SBQQ__QuoteLine__c = ql4.id
        );
        insert ast;
    }

    @isTest
    private static void updateOrdersTest()
    {
        Test.startTest();
        setupTestData();
        List<case> Caslst = [Select id,Priority from case limit 1];
        System.debug('CheckkCaseid' +  Caslst[0].Priority);
        List<PT_UpdateOrderFromCase.FlowInput> FlowInputLst = new List<PT_UpdateOrderFromCase.FlowInput>();
        PT_UpdateOrderFromCase.FlowInput ObjFlowInput = new PT_UpdateOrderFromCase.FlowInput();
        ObjFlowInput.caseId = Caslst[0].id;
        FlowInputLst.add(ObjFlowInput);
        try {
            PT_UpdateOrderFromCase.updateOrders(FlowInputLst);
       } catch(Exception ex) {

       }
        Test.stopTest();
    }

    @isTest
    private static void updateOrdersTest2()
    {
        Test.startTest();
        setupTestData();
        List<case> Caslst = [Select id,Priority from case limit 1];

        System.debug('CheckkCaseid' +  Caslst[0].Priority);
        List<PT_CreateOrderController.FlowInput> FlowInputLst = new List<PT_CreateOrderController.FlowInput>();

        PT_CreateOrderController.FlowInput ObjFlowInput = new PT_CreateOrderController.FlowInput();
        ObjFlowInput.caseId = Caslst[0].id;
        FlowInputLst.add(ObjFlowInput);
        try {
          PT_CreateOrderController.createOrderFromFlow(FlowInputLst);
        } catch(Exception ex){

        }
        List<Order> Ordlst = [Select id,Status,SBQQ__PriceCalcStatus__c,L2I_Order_Process__c, PT_Ext_Order_Header_Status__c from Order limit 1];
        PT_UpdateOrderFromCase.publishCreateOrder(Ordlst);
        Test.stopTest();
    }
}