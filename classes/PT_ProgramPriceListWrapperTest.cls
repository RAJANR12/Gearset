@IsTest
public class PT_ProgramPriceListWrapperTest {

	static testMethod void testParse() {
		String json = '{'+
		'\"sourceSystem\": \"Salesforce\",'+
		'\"header\": {'+
		'\"priceListName\": \"REPAIR PRICE LIST - INTERNAL - sri\",'+
		'\"priceListDescription\": \"Standard Cost price for PANASONIC repairs - sri\", '+
		'\"headerExternalId\": \"\",'+
		'\"currencyCode\": \"USD\",'+
		'\"originalHeaderID\": \"8018A000000MrwaQAC\",'+
		'\"activationStartDate\": \"\",'+
		'\"operationType\": \"\"'+
		'},'+
		'\"lines\": ['+
		'{'+
		'\"itemValuePerUnit\": \"598\",'+
		'\"inventoryItemID\": \"151955\",'+
		'\"primaryUnitOfMeasure\": \"EA\",'+
		'\"originalLineId\": \"8028A000000u2afQA\",'+
		'\"operationType\": \"\",'+
		'\"activationStartDate\": \"\",'+
		'\"lineExternalId\": \"\"'+
		'}'+
		']'+
		'}';
		PT_ProgramPriceListWrapper obj = PT_ProgramPriceListWrapper.parse(json);
		System.assert(obj != null);
	}
}