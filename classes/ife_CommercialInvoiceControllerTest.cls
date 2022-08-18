@isTest
public class ife_CommercialInvoiceControllerTest {
    @isTest public static void ife_CommercialInvoiceControllerTest(){
        Integer recordPerPage = 10;
        Integer totalRecords = 0;
        Integer breakBeforLastPage = 0;
        ife_CommercialInvoiceController ife = new ife_CommercialInvoiceController();
    }
    @isTest public static void getPageValueTest(){
        Test.setMock(HttpCalloutMock.class, new IfeMockServiceCallout());
        ife_CommercialInvoiceController commercialClass = new ife_CommercialInvoiceController();
        commercialClass.getPageValue();
    }
    @isTest public static void createJsonRecord(){
        ife_CommercialInvoiceController.HeaderWrapper wrapper  =  new ife_CommercialInvoiceController.HeaderWrapper();
        wrapper.CF_ULT_SHIP_ADDR2 = 'Test';
        wrapper.CF_ULTIMATE_SHIP_TO = 'Test'; 
        wrapper.CF_ULTI_BILLCITYSTATEZIP = 'Test';
        wrapper.CF_FREIGHT_TERMS_CODE = 'Test';
        wrapper.CF_WAYBILL = 'Test';
        wrapper.CF_1STDEST_CUSTOMER1 = 'Test'; 
        wrapper.CURRENCY_CODE = 'Test'; 
        wrapper.CF_BILL_COUNTRY = 'Test';
        wrapper.CF_1STDEST_ADDRESS3 = 'Test';
        wrapper.CPP_IMPORTED_FROM = 'Test';
        wrapper.CF_1STDEST_ADDRESS1 = 'Test';
        wrapper.CF_1STDEST_ADDRESS2 = 'Test';
        wrapper.CP_DUB_SHIPFROM_ADD1 = 'Test';
        wrapper.C_SHIP_VIA = 'Test';
        wrapper.CF_1STDEST_BILLCITYSTATEZIP = 'Test';
        wrapper.WT_UOM_CODE = 'Test';  
        wrapper.CP_DUB_SHIPFROM_ADD3 = 'Test';
        wrapper.CF_ACTUAL_REP_TOTAL = 123;
        wrapper.CP_DUB_SHIPFROM_ADD2 = 'Test';
        wrapper.GROSS_WEIGHT = 'Test';
        wrapper.FOB_CODE = 'Test';
        wrapper.CF_BILL_CUSTOMER = 'Test'; 
        wrapper.CP_DUB_SHIPFROM_ADD4 = 'Test'; 
        wrapper.CF_BILL_CITYSTATEZIP = 'Test';
        wrapper.C_NUM_BOXES = 'Test';
        wrapper.CF_ORG_CODE = 'Test';
        wrapper.CF_1STDEST_COUNTRY = 'Test';
        wrapper.WEIGHT_UOM_CODE = 'Test';
        wrapper.CF_1STDEST_CUSTOMER = 'Test';
        wrapper.F_DELIVERY_NAME = 'Test';
        wrapper.CP_DUB_SHIPFROM_CITY_STATE = 'Test';
        wrapper.SHIP_VIA = 'Test';
        wrapper.CF_ULTI_SHIP_ADDR3 = 'Test';
        wrapper.CF_BILL_ADDRESS1 = 'Test';
        wrapper.CF_BILL_ADDRESS2 = 'Test';
        wrapper.CF_ULTI_SHIP_ADDR1 = 'Test';
        wrapper.CF_BILL_ADDRESS3 = 'Test'; 
        wrapper.CP_DUB_SHIPFROM_COUNTRY = 'Test';
        wrapper.CF_ULTI_COUNTRY = 'Test';
        wrapper.SHIP_DATE = 'Test';
        
        //	String jsonBody = JSON.serialize(wrapper);
        
        ife_CommercialInvoiceController.LinesWapper linesWapper  = new ife_CommercialInvoiceController.LinesWapper();
        linesWapper.CF_COUNTRY_OF_ORIGIN = 'Test';
        linesWapper.CF_UNIT_WEIGHT = 'Test';
        linesWapper.CF_ECCN = 'Test';
        linesWapper.SOURCE_UOM = 'Test';
        linesWapper.CF_ITEM_NAME = 'Test';
        linesWapper.CF_ATTR7 = 'Test';
        linesWapper.CF_EL1_NEW = 'Test';
        linesWapper.C_ITEM_COST_FMT = 12;
        linesWapper.CF_HARMONIZED1 = 'Test';
        linesWapper.CF_EL2_NEW = 'Test';
        linesWapper.UNIT_OF_MEASURE = 'Test';
        linesWapper.C_ITEM_DISP = 'Test';
        linesWapper.C_EXT_COST_FMT = 12;
        linesWapper.ORDER_NUM = 'Test';
        linesWapper.CATEGORY = 'Test';
        linesWapper.NVL_WDD_SHIPPED_QUANTITY_WDD_R = 12;
        linesWapper.SOURCE_CODE = 'Test';
        linesWapper.PO = 'Test';
        linesWapper.Program = 'Test'; 
        linesWapper.Shipset = 'Test'; 
        linesWapper.Tail = 'Test';
        
        
        
        //     ife_CommercialInvoiceController.JSONWrapper jsonwrapper = new ife_CommercialInvoiceController.JSONWrapper();
        
    }
}