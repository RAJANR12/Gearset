@isTest
public class PT_AssignAssetsToCaseControllerTest {
    @isTest
    public static void assignAssetsToCaseTest() {
        L2I_DataFactory dt = new L2I_DataFactory();
        Account namedCustomer = dt.createCustomerAccount('Airline Customer', '123 Jump Street', 'San Diego', 'CA', '92122');
        insert namedCustomer;

        Product2 p = new Product2(Name = 'TestProd', ProductCode = 'ProdCode', L2I_Inventory_Item_Id__c = '99999803');

        PT_Program__c prog1 = new PT_Program__c();
        prog1.Name = 'Prog1';
        prog1.Program_Number__c = 'Prog1';
        insert prog1;

        Asset ast = new Asset(
                    Name = 'AssetName',
                    AccountId = namedCustomer.Id,
                    Product2Id = p.Id,
                    PT_Program__c = prog1.Id
        );
        insert ast;

        Case cases = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', PT_Program__c = prog1.Id);
        insert cases;

        PageReference pageRef = Page.PT_AddAssetsToCase;
        Test.setCurrentPage(pageRef);

        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('caseId', cases.Id);
        ApexPages.currentPage().getParameters().put('id', ast.Id);

        // Instantiate a new controller with all parameters in the page
        PT_AssignAssetsToCaseController controller = new PT_AssignAssetsToCaseController();
        controller.assignAssetsToCase();
    }
}