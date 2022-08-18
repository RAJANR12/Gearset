/**
 * Test class for L2I_TablePropertyUtils
 */
@isTest
private class L2I_TablePropertyUtilsTest {

    @testSetup
    static void setBaseScenario() {
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        Product2 product = new Product2();
        product.Name = ' Test Product ';
        product.Description='Test Product Entry 1';
        product.ProductCode = 'ABC';
        product.L2I_Inventory_Item_Id__c = '123';
        product.isActive = true;
        insert product;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = product.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        
        /*Order order = new Order();
        order.Name = 'Test Order ';
        order.Status = 'Draft';
        order.EffectiveDate = system.today();
        order.EndDate = system.today() + 4;
        order.AccountId = account.id;
        order.Pricebook2Id = Test.getStandardPricebookId();
        insert order;
*/
        
        //Opportunity DealOppty = [SELECT Id FROM Opportunity WHERE Recordtype.Developername = 'Deal' LIMIT 1];
L2I_DataFactory factory = new L2I_DataFactory();
        L2I_DataFactory_Test.test_load_products();

        Account namedCustomer = factory.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;
        Opportunity dealOppty = factory.createDealOpportunity('Deal', 'Open', 30, namedCustomer.Id);
        insert dealOppty;
        
        Id salesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Opportunity salesOppty = new Opportunity(
              Name = 'TestSalesOpp',
              StageName = 'Quotation',
              CloseDate = Date.today(),
              L2I_Parent_Opportunity__c = dealOppty.Id,
              L2I_Product_Category__c = 'DSS',
              RecordTypeId = salesId);
        insert salesOppty;

/*
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(
              RecordTypeId = L2I_StaticConstants.APPROVED_QUOTE_RT_ID,
              SBQQ__Account__c = account.Id,
              SBQQ__Opportunity2__c = salesOppty.Id,
              SBQQ__Primary__c = true
        );
        insert quote1;
        
        //L2I_DSH__c dsHeader = [SELECT Id FROM L2I_DSH__c LIMIT 1];
                L2I_Aircraft_Type__c att = factory.createAircraftType( namedCustomer.Id, 123456);
        insert att;
L2I_DSH__c dsh = factory.createDeliverySchedule(namedCustomer.Id, att.Id);
        insert dsh;
        
                List<PricebookEntry> pbeList = [
              select Id,
                    Product2Id,
                    Pricebook2Id,
                    UnitPrice,
                    IsActive
              from PricebookEntry limit 1
        ];

        Map<Id, PricebookEntry> pricebookMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : pbeList) {
            pricebookMap.put(pbe.Product2Id, pbe);
        }
        Order theTestOrder = new Order(AccountId = account.Id,
              PoNumber = 'Test',
              EffectiveDate = Date.today(),
              Status = 'Draft',
              Pricebook2Id = Test.getStandardPricebookId(),
              blng__BillingDayOfMonth__c = '30',                        
              OpportunityId = salesOppty.Id,
              SBQQ__Quote__c = quote1.Id,
              L2I_Delivery_Schedule__c = dsh.Id);
        insert theTestOrder;
        
*/

        
        blng__BillingRule__c billingrule = [select Id from blng__BillingRule__c limit 1];
		blng__BillingTreatment__c billingTreatments = [select Id from blng__BillingTreatment__c limit 1];
        blng__TaxRule__c taxrules = [select Id from blng__TaxRule__c limit 1];
        system.debug('Nick1 '+billingrule.Id);
		system.debug('Nick2 '+billingTreatments.Id);
        system.debug('Nick3 '+taxrules.Id);
        
       /* OrderItem orderItem = new OrderItem();
        orderItem.OrderId = theTestOrder.id;
        orderItem.Quantity = 24;
        orderItem.UnitPrice = 248;
        orderItem.blng__BillingRule__c=billingrule.Id;
        orderItem.blng__TaxRule__c=taxrules.id;
        //orderItem.blng__RevenueRecognitionRule__c=billingTreatments.id;
        orderItem.SBQQ__BillingType__c = 'Advance';
        orderItem.SBQQ__ChargeType__c = 'Recurring';
        orderItem.SBQQ__BillingFrequency__c = 'Monthly';
        orderItem.Product2id = product.id;
        orderItem.PricebookEntryId = standardPrice.id;
        insert orderItem;
		*/
    }

    @isTest
    static void test_buildHeaderDataCellPropertyPack() {
        L2I_TablePropertyUtils.getMasterPropertiesMap(null, null);
        //
        List<Schema.FieldSetMember> fieldSetMemberList = L2I_ApexUtils.readFieldSet('SBQQ__SearchFilters', 'Asset');
//L2I_ApexUtils.readFieldSet('Order_Product_Field_Set', 'OrderItem');
        Map<String, String> masterPropertiesMap = new Map<String, String>();

        List<L2I_TablePropertyUtils.DataCellPropertyPack> dataCellPropertyPacks = new List<L2I_TablePropertyUtils.DataCellPropertyPack>();
        //
		for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
            Integer index = fieldSetMemberList.indexOf(fieldSetMemberObj);
            L2I_TablePropertyUtils.FieldSetMemberWrapper fieldSetMemberWrapper = new L2I_TablePropertyUtils.FieldSetMemberWrapper(fieldSetMemberObj);
            L2I_TablePropertyUtils.DataCellPropertyPack dcpp = L2I_TablePropertyUtils.buildHeaderDataCellPropertyPack(
                masterPropertiesMap, fieldSetMemberWrapper, index
            );

            dataCellPropertyPacks.add(dcpp);
        }//
    }

    @isTest
    static void test_buildBodyDataCellPropertyPack() {
        L2I_TablePropertyUtils t = new L2I_TablePropertyUtils();
        L2I_TablePropertyUtils.DataCellPropertyPack prop = new L2I_TablePropertyUtils.DataCellPropertyPack();
        //L2I_TablePropertyUtils.FieldSetMemberWrapper prop2 = new L2I_TablePropertyUtils.FieldSetMemberWrapper.FieldSetMemberWrapper();
        //L2I_TablePropertyUtils.FieldSetMemberWrapper fieldSetMemberWrapper = new L2I_TablePropertyUtils.FieldSetMemberWrapper(fieldSetMemberObj);

        prop.step = '123';
        
        prop.index = 1;
        prop.formatter = '123';
        prop.min = .1;
        prop.minLength = 1;
        prop.required = true;
        
        prop.field = '123';
        prop.fieldLabel = '123';
        prop.columnName = '123';
        prop.fieldType = '123';
        prop.gridCellValue = '123';
        prop.cssClass = '123';
        prop.styles = '123';
        prop.linkifyIt = true;
        prop.relatedLookupId = '123';
        prop.outputLink = '123';
        prop.indentation = '123';
        prop.textAlignment = '123';
        
        
        
        prop.isEditable = true;
        prop.isDisabled = true;
        prop.isReadOnly = true;
       prop.isValid = true;
        prop.inputType= '123';
        prop.isChecked = true;
        
        
        //t.DataCellPropertyPack();
        L2I_TablePropertyUtils.getMasterPropertiesMap(null, null);
        ///////L2I_TablePropertyUtils.DataCellPropertyPack.buildHeaderDataCellPropertyPack(null, null,null);
        List<Schema.FieldSetMember> fieldSetMemberList = L2I_ApexUtils.readFieldSet('SBQQ__SearchFilters', 'Asset');
        Map<String, String> masterPropertiesMap = new Map<String, String>();

        SObjectType rowObjType = L2I_ApexUtils.globalDescribe.get('Asset');
        Map<String, Schema.SObjectField> rowObjFieldsMap = rowObjType.getDescribe().fields.getMap();

        Set<String> fieldsToQuerySet = new Set<String>{'Id'};
        // get fields from the field set:
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
            String fieldAPIPath = String.valueOf(fieldSetMemberObj.getFieldPath());
            if(!fieldsToQuerySet.contains(fieldAPIPath)) {
                fieldsToQuerySet.add(fieldAPIPath);
            }
        }
        List<String> fieldsToQuery = new List<String>(fieldsToQuerySet);

        //Order order = [SELECT Id FROM Order LIMIT 1];
        //Id orderId = order.Id;
 /*       List<OrderItem> orderItems = Database.query(
            'SELECT ' + String.join(fieldsToQuery, ',') + ' FROM OrderItem WHERE OrderId = :orderId AND UnitPrice =248 '
        );*/
        //List<OrderItem> orderItems = Database.query(
        //    'SELECT blng__TaxRule__c FROM OrderItem WHERE OrderId = :orderId AND UnitPrice =248 '
       // );

        Test.startTest();
        /*for(OrderItem orderItem : orderItems) {
            Integer rowIndex = orderItems.indexOf(orderItem);
            List<L2I_TablePropertyUtils.DataCellPropertyPack> dataCellPropertyPacks = new List<L2I_TablePropertyUtils.DataCellPropertyPack>();
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                Integer index = fieldSetMemberList.indexOf(fieldSetMemberObj);
                L2I_TablePropertyUtils.FieldSetMemberWrapper fieldSetMemberWrapper = new L2I_TablePropertyUtils.FieldSetMemberWrapper(fieldSetMemberObj);
                L2I_TablePropertyUtils.DataCellPropertyPack dcpp = L2I_TablePropertyUtils.buildBodyDataCellPropertyPack(
                    masterPropertiesMap, fieldSetMemberWrapper, orderItem, 1, rowObjFieldsMap, index, rowIndex
                );
                dataCellPropertyPacks.add(dcpp);
            }
        }*/
        Test.stopTest();
        
    }
}