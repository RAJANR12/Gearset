@isTest
private with sharing class PT_CloneAssetsToCaseControllerTest {
    
    static L2I_DataFactory dt = new L2I_DataFactory();

    @isTest
    static void cloneAssetsFromCase() {
        Account namedCustomer = dt.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;

        Product2 p = new Product2(Name = 'TestProd', ProductCode = 'ProdCode', L2I_Inventory_Item_Id__c = '99999803');

        PT_Program__c prog1 = new PT_Program__c(Name = 'Test Name', Program_Number__c = 'Test Name');
        insert prog1;

        Case cases = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', PT_Program__c = prog1.Id);
        insert cases;

        Asset ast = new Asset(Name = 'AssetName', AccountId = namedCustomer.Id, Product2Id = p.Id, PT_Program__c = prog1.Id, PT_Case__c = cases.Id);
        insert ast;

        PageReference pageRef = Page.PT_CloneAssetsToCase;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('caseId', cases.Id);
        ApexPages.currentPage().getParameters().put('id', ast.Id);

        Test.startTest();
        PT_CloneAssetsToCaseController ctrl = new PT_CloneAssetsToCaseController();
        ctrl.cloneAssetsToCase();
        Test.stopTest();
    }
}