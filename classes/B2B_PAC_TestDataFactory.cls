@IsTest
public with sharing class B2B_PAC_TestDataFactory 
{
    public static final String TEST_STOREFRONT = 'DefaultStore';
    public static final String TEST_STOREFRONT_USER_PROFILE = 'PAC Customer';

    // Parent Billing Address
    public static final String PARENT_BILL_STREET = 'Parent Billing Address';
    public static final String PARENT_BILL_CITY = 'New York';
    public static final String PARENT_BILL_STATE = 'NY';
    public static final String PARENT_BILL_COUNTRY = 'US';
    public static final String PARENT_BILL_POSTAL_CODE = '67890';

    // Parent Shipping Address
    public static final String PARENT_SHIP_STREET = 'Parent Shipping Address';
    public static final String PARENT_SHIP_CITY = 'New York';
    public static final String PARENT_SHIP_STATE = 'NY';
    public static final String PARENT_SHIP_COUNTRY = 'US';
    public static final String PARENT_SHIP_POSTAL_CODE = '67890';

    public static final String TEST_ACCOUNT = 'TestAccount';
    public static final String TEST_CONTACT = 'TestContact';
    public static final String TEST_USER = 'TestUser';
    public static final String TEST_PRODUCTS = 'TestProducts';
    public static final String TEST_SKU = 'TestSKU';
    public static final String PRODUCT_TYPE_PRODUCT = 'Product';
    public static final String PRODUCT_STATUS_RELEASED = 'Released';
    public static final Integer TEST_PRODUCT_PRICE = 50;
    public static final String TEST_CURRENCY_CODE = 'USD';
    private static final String TEST_STORE_COUNTRY = 'US';
    public static final String TEST_CATEGORY = 'TestCategory';
    public static final String TEST_PRODCAT = 'TestProdCat';
    public static final String TEST_PRICELIST = 'TestPriceList';
    public static final String TEST_PRICELISTITEMS ='TestPriceListItems';
    public static final String TEST_PRICELISTID ='ORACLE-001';

    /**
     * @description Setups a test storefront.
     */
    public static void initCCSettings() 
    {
        ccrz.cc_util_Reflection.createStorefrontSetting(TEST_STOREFRONT);

        Map<String, Map<String, Object>> ccSettings = new Map<String, Map<String, Object>>{
                ccrz.ccApiTestData.SERVICE_SETTINGS => new Map<String, Object>{
                        TEST_STOREFRONT => new Map<String, Object>{
                               'ccServiceOrder' => 'c.B2B_PAC_ccServiceOrder',
                               'ccServiceOrderItem' => 'c.B2B_PAC_ccServiceOrderItem',
                               'ccServiceCartItem' => 'c.B2B_PAC_ccServiceCartItem',
                               'ccServicePL' => 'c.B2B_PAC_ccServicePL',
                               'ccServicePLI' => 'c.B2B_PAC_ccServicePLI',
                               'ccServiceAccount' => 'c.B2B_PAC_ccServiceAccount',
                               'ccServiceContact' => 'c.B2B_PAC_ccServiceContact',
                               'ccServiceWishListItem' => 'c.B2B_PAC_ccServiceWishListItem',
                               'ccServiceAddressBook' => 'c.B2B_PAC_ccServiceAddressBook'
                        }
                },
                ccrz.ccApiTestData.LOGIC_SETTINGS => new Map<String, Object>
                {
                        TEST_STOREFRONT => new Map<String, Object>
                        {
                                'ccLogicProductPricing' => 'c.B2B_PAC_ccLogicProductPricing',
                                'ccLogicCartPrice' => 'c.B2B_PAC_ccLogicCartPrice',
                                'ccLogicWLAddTo' => 'c.B2B_PAC_ccLogicWLAddTo',
                                'ccLogicCartAddTo' => 'c.B2B_PAC_ccLogicCartAddTo',
                                'ccLogicCartPlace' =>'c.B2B_PAC_ccLogicCartPlace',
                                'ccLogicOrderReOrder' =>'c.B2B_PAC_ccLogicOrderReorder'
                        }
                },
                ccrz.ccApiTestData.HOOK_SETTINGS => new Map<String, Object>
                {
                        TEST_STOREFRONT => new Map<String, Object>
                        {
                               ccrz.cc_hk_Order.HK_ID => 'c.B2B_PAC_cchkOrder',
                               ccrz.cc_hk_Payment.HK_ID => 'c.B2B_PAC_cchkPayment'
                        }
                },
                ccrz.ccApiTestData.CONFIG_SETTINGS => new Map<String, Object>{
                    'qo.chkinc' => 'false',
                    'qo.wrninc' => 'false',
                    'qo.addsep' => 'true'
                }
        };
        ccrz.ccApiTestData.setupData(ccSettings);
    }

   
    /**
     * @description Returns a test Store Account.
     */
    public static Account createInsertTestAccount(ccrz__E_AccountGroup__c accountGroup) 
    {
        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.ccrz__E_AccountGroup__c = accountGroup.Id;
        testAcc.B2B_PAC_EnablePO__c = false;
        
        insert testAcc;
        return testAcc;
    }

    /**
     * @description Creates a test account group.
     */
    public static ccrz__E_AccountGroup__c createInsertTestAccountGroup() 
    {
        ccrz__E_AccountGroup__c accGroup = new ccrz__E_AccountGroup__c(Name = 'Default Account Group',ccrz__PriceListSelectionMethod__c = 'Sequence' );

        insert accGroup;
        return accGroup;
    }

    /**
     * @description Creates a test user.
     */
    public static User createDefaultUser(Contact contact) 
    {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :TEST_STOREFRONT_USER_PROFILE LIMIT 1];

        User user = new User(
                LastName = 'SMITH',
                FirstName = 'JOHN',
                Alias = 'main',
                Email = 'testuser@testfactory.com',
                Phone = '1234567890',
                Username = 'testuser@testfactory.com.' + Math.random(),
                TimeZoneSidKey = UserInfo.getTimeZone().toString(),
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                ContactId = contact.Id,
                ProfileId = profile.Id
        );
        insert user;
        return user;
    }


    /**
     * @description Creates a test contact.
     */
    public static Contact createInsertDefaultContact(Account account) 
    {
        Contact contact = new Contact(
                AccountId = account.Id,
                FirstName = 'Default Contact',
                LastName = 'Default Contact',
                Email = 'defaultcontact@domain.com',
                MailingStreet = 'testMailingStreet',
                MailingPostalCode = '90210',
                MailingCity = 'testMailingCity',
                IFE_B2B_Access__c = true
        );
        insert contact;
        return contact;
    }


    /**
     * @description Creates and returns a test price list.
     */
    public static ccrz__E_PriceList__c createInsertTestPricelist() 
    {
        ccrz__E_PriceList__c priceList = new ccrz__E_PriceList__c(
                Name = 'Standard US',
                ccrz__CurrencyISOCode__c = TEST_CURRENCY_CODE,
                ccrz__Enabled__c = true,
                ccrz__Storefront__c = TEST_STOREFRONT,
                B2B_PAC_OrderSource__c = 'Oracle',
                ccrz__Desc__c = 'Standard Pricing',
                ccrz__PricelistId__c = TEST_PRICELISTID,
                ccrz__StartDate__c = System.today().addYears(-1)
        );
        insert priceList;
        return priceList;
    }

    /**
     * @description Associates the pricelist to an account group.
     */
    public static ccrz__E_AccountGroupPriceList__c createInsertTestAccountGroupPriceList(ccrz__E_AccountGroup__c accountGroup, ccrz__E_PriceList__c priceList) 
    {
        ccrz__E_AccountGroupPriceList__c accountGroupPriceList = new ccrz__E_AccountGroupPriceList__c(
                ccrz__AccountGroup__c = accountGroup.Id,
                ccrz__Pricelist__c = priceList.Id,
                ccrz__StartDate__c = System.today().addYears(-1),
                ccrz__Enable__c = true

        );
        insert accountGroupPriceList;
        return accountGroupPriceList;
    }

    /**
     * @description Creates and inserts price list items.
     */
    public static List<ccrz__E_PriceListItem__c> createInsertPriceListItems(List<ccrz__E_Product__c> products, ccrz__E_PriceList__c pricelist) 
    {
        List<ccrz__E_PriceListItem__c> items = new List<ccrz__E_PriceListItem__c>();

        for (ccrz__E_Product__c product : products) 
        {
            ccrz__E_PriceListItem__c priceListItem = new ccrz__E_PriceListItem__c(
                    ccrz__Price__c = TEST_PRODUCT_PRICE,
                    ccrz__Product__c = product.Id,
                    ccrz__Pricelist__c = pricelist.Id,
                    B2B_PAC_LeadTime__c = 20,
                    ccrz__StartDate__c = System.today().addYears(-1)
            );
            items.add(priceListItem);
        }
        insert items;

        return items;
    }



    /**
     * @description Creates and Returns the specified number of CC products.
     */
    public static List<ccrz__E_Product__c> createInsertTestProducts(Integer size) 
    {
        List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>();

        for (Integer i = 0; i < size; i++) 
        {
            ccrz__E_Product__c product = new ccrz__E_Product__c(
                    Name = TEST_SKU + i,
                    ccrz__SKU__c = TEST_SKU + i,
                    ccrz__ProductStatus__c = PRODUCT_STATUS_RELEASED,
                    ccrz__ProductType__c = PRODUCT_TYPE_PRODUCT,
                    ccrz__Storefront__c = TEST_STOREFRONT,
                    ccrz__ShortDesc__c = TEST_SKU,
                    ccrz__ShortDescRT__c = TEST_SKU,
                    ccrz__StartDate__c = System.today().addYears(-1),
                    ccrz__EndDate__c = System.today().addYears(+1),
                    ccrz__ShippingWeight__c = 1,
                    ccrz__UnitOfMeasure__c = 'CS'
            );

            products.add(product);
        }

        insert products;
        return products;
    }

   

       
        
    /**
     * @description Creates Account, Account group, Users, PriceLists, Products, PriceListItems.
     */
    public static Map<String, Object> setupAccountContactUser() 
    {
        ccrz__E_AccountGroup__c accountGroup = createInsertTestAccountGroup();

        Account testAccount = createInsertTestAccount(accountGroup);
        Contact testContact = createInsertDefaultContact(testAccount);
        User testUser = createDefaultUser(testContact);

        //PriceLists
        ccrz__E_PriceList__c pricelist = createInsertTestPricelist();

        createInsertTestAccountGroupPriceList(accountGroup, pricelist);

        //Products and PriceListItems
        List<ccrz__E_Product__c> products = createInsertTestProducts(2);

        List<ccrz__E_PriceListItem__c> priceListItems = createInsertPriceListItems(products, pricelist);

        ccrz__E_Category__c category = createCategory();
      
        return new Map<String, Object>{
                TEST_ACCOUNT => testAccount,
                TEST_CONTACT => testContact,
                TEST_USER => testUser,
                TEST_PRODUCTS => products,
                TEST_PRICELIST => pricelist,
                TEST_PRICELISTITEMS => priceListItems
        };
    }



    /**
     * @description Creates and inserts a test contact address record.
     */
    public static ccrz__E_ContactAddr__c createInsertTestContactAddress() 
    {
        ccrz__E_ContactAddr__c testAddress = new ccrz__E_ContactAddr__c();
        testAddress.ccrz__FirstName__c = 'Test';
        testAddress.ccrz__LastName__c = 'Test';
        testAddress.ccrz__AddressFirstline__c = PARENT_BILL_STREET;
        testAddress.ccrz__City__c = PARENT_BILL_CITY;
        testAddress.ccrz__StateISOCode__c = PARENT_BILL_STATE;
        testAddress.ccrz__Country__c = PARENT_BILL_COUNTRY;
        testAddress.ccrz__CountryISOCode__c = PARENT_BILL_COUNTRY;
        testAddress.ccrz__PostalCode__c = PARENT_BILL_POSTAL_CODE;
        testAddress.ccrz__ContactAddrId__c ='ABC123';

        insert testAddress;
        return testAddress;
    }



    public static ccrz__E_AccountAddressBook__c createInsertTestAccountAddressBook(Account account, ccrz__E_ContactAddr__c contactAddress) 
    {
        ccrz__E_AccountAddressBook__c testAcctAddress = new ccrz__E_AccountAddressBook__c();
        testAcctAddress.ccrz__Account__c = account.Id;
        testAcctAddress.Name = 'Test';
        testAcctAddress.ccrz__AccountId__c = account.Id;
        testAcctAddress.ccrz__AddressType__c = 'Billing';
        testAcctAddress.ccrz__Default__c = true;
        testAcctAddress.ccrz__E_ContactAddress__c = contactAddress.Id;

        insert testAcctAddress;
        return testAcctAddress;
    }


    public static L2I_Site__c createInsertTestSite(Account account) 
    {
        L2I_Site__c testSite = new L2I_Site__c();
        testSite.Address_Line_1__c = PARENT_BILL_STREET;
        testSite.Address_Line_2__c =PARENT_BILL_STREET;
        testSite.City__c = PARENT_BILL_CITY;
        testSite.State__c = PARENT_BILL_STATE;
        testSite.Country__c = PARENT_BILL_COUNTRY;
        testSite.Postal_Code__c = '123456789098';
        testSite.L2I_Status__c = 'Active';
        testSite.L2I_Site_Use_Code__c = 'Bill_To';
        testSite.PT_AccountId__c = account.Id;
        testSite.Primary_Flag__c = 'Y';

        insert testSite;
        return testSite;
    }
   
    

    public static ccrz__E_Category__c createCategory() 
    {
        ccrz__E_Category__c category = new ccrz__E_Category__c(
                Name = 'Assembly',
                ccrz__StartDate__c = Date.today().addDays(-1),
                ccrz__CategoryID__c = '1',
                ccrz__EndDate__c = Date.today().addDays(1)
        );
        insert category;
        return category;
    }

    public static List <ccrz__E_ProductCategory__c> createProductCategory(ccrz__E_Category__c category, List <ccrz__E_Product__c> productList) 
    {
        List <ccrz__E_ProductCategory__c> prodCatToInsert = new List<ccrz__E_ProductCategory__c>();

        for (ccrz__E_Product__c product : productList)
         {
            ccrz__E_ProductCategory__c prodCat = new ccrz__E_ProductCategory__c (
                    ccrz__Product__c = product.ID,
                    ccrz__Category__c = category.ID,
                    ccrz__StartDate__c = Date.today().addDays(-1),
                    ccrz__EndDate__c = Date.today().addDays(1)
            );
            prodCatToInsert.add(prodCat);
        }

        insert prodCatToInsert;

        return prodCatToInsert;
    }


    public static List<ccrz__E_ProductIndex__c> createProductIndices(Map<String, Object> testData) 
    {
        List<ccrz__E_ProductIndex__c> newProductIndices = new List<ccrz__E_ProductIndex__c>();

        ccrz__E_Category__c category = (ccrz__E_Category__c) testData.get(TEST_CATEGORY);

        ccrz__E_PriceList__c pricelist = (ccrz__E_PriceList__c) testData.get(TEST_PRICELIST);

        Decimal count = 0;

        for (ccrz__E_Product__c product : (List<ccrz__E_Product__c>) testData.get(TEST_PRODUCTS)) {
            for (ccrz__E_ProductCategory__c productCategory : (List<ccrz__E_ProductCategory__c>) testData.get(TEST_PRODCAT)) {
                newProductIndices.add(new ccrz__E_ProductIndex__c(
                        ccrz__ProductCategory__c = productCategory.Id,
                        ccrz__ProductCategoryStartDate__c = productCategory.ccrz__StartDate__c,
                        ccrz__ProductCategoryEndDate__c = productCategory.ccrz__EndDate__c,
                        ccrz__ProductCategorySequence__c = productCategory.ccrz__Sequence__c,
                        ccrz__Category__c = category.Id,
                        ccrz__CategoryStartDate__c = category.ccrz__StartDate__c,
                        ccrz__CategoryEndDate__c = category.ccrz__EndDate__c,
                        ccrz__PriceLists__c = pricelist.Id,
                        ccrz__Locale__c = 'en_US',
                        ccrz__Product__c = product.Id,
                        ccrz__ProductName__c = product.Name,
                        ccrz__ProductStatus__c = product.ccrz__ProductStatus__c,
                        ccrz__Storefront__c = TEST_STOREFRONT,
                        ccrz__ProductStartDate__c = product.ccrz__StartDate__c,
                        ccrz__ProductEndDate__c = product.ccrz__EndDate__c,
                        ccrz__ShortDescription__c = 'TEST',
                        ccrz__SKU__c = product.ccrz__SKU__c,
                        ccrz__IndexPrice__c = String.valueOf(count).leftPad(19, '0'),
                        ccrz__Active__c = TRUE,
                        ccrz__IndexCurrency__c = 'USD'
                ));
                count++;
            }
        }

        insert newProductIndices;

        return newProductIndices;
    }
}