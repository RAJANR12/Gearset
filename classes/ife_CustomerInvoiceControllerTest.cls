@isTest
private class ife_CustomerInvoiceControllerTest {
    @isTest
    public static void getPageValueTest(){
        Test.setMock(HttpCalloutMock.class, new ife_CustomerInvoiceControllerMockCallOut());
        
        ife_CustomerInvoiceController customCntrl = new ife_CustomerInvoiceController();
        customCntrl.getPageValue();
    }
     @isTest
    public static void getPageValuenullTest(){
       // Test.setMock(HttpCalloutMock.class, new null);
        
        ife_CustomerInvoiceController customCntrl = new ife_CustomerInvoiceController();
        customCntrl.getPageValue();
    }
    @isTest 
    public static void createWrapper(){
        ife_CustomerInvoiceController.JSONWrapper  jsonWrap= new ife_CustomerInvoiceController.JSONWrapper();
        ife_CustomerInvoiceController.HeaderWrapper  hwrapper = new ife_CustomerInvoiceController.HeaderWrapper();
            hwrapper.CP_INCIDENT_NUM = 'Test';
            hwrapper.CUSTOMER_NUMBER = 'Test';
            hwrapper.CF_WAYBILL = 'Test';
            hwrapper.ORDER_NUMBER = 'Test';
            hwrapper.TRX_TYPE_NAME = 'Test';
            hwrapper.REPORT_ALL_AMOUNT = 123;
            hwrapper.LINE_ID = 'Test';
            hwrapper.C_BILL_TO_CONCATENATED = 'Test';
            hwrapper.INVOICE_CURRENCY_CODE = 'Test';
            hwrapper.CP_PROGRAM_NUMBER = 'Test';
            hwrapper.CP_TAIL_NUMBER = 'Test';
            hwrapper.CF_DATABASE = 'Test';
            hwrapper.PURCHASE_ORDER_NUMBER = 'Test';
            hwrapper.CP_SHIP_TO_CONCATENATED = 'Test';
            hwrapper.SHIP_VIA_DESCRIPTION = 'Test';
            hwrapper.CF_INCIDENT_ITEM = 'Test';
            hwrapper.H_ORDER_TYPE_ID = 123;
            hwrapper.REPORT_ITEM_AMOUNT = 123;
            hwrapper.BILL_TO_ATTN = 'Test';
            hwrapper.REPORT_TAX_AMOUNT = 123;
            hwrapper.CP_LOT_OR_SERIAL_NO = 'Test';
            hwrapper.REPORT_FREIGHT_AMOUNT = 123;
            hwrapper.TRX_DATE = 'Test';
            hwrapper.CF_CUSTTRXTYPE_ID = 123;
            hwrapper.CF_DELIVERY_NUMBER = 'Test';
            hwrapper.INV_SALES_ORDER = 123;
            hwrapper.TERM_NAME = 'Test';
            hwrapper.CP_REMIT_TO_CONCATENATED = 'Test';
            hwrapper.TRX_NUMBER = 'Test'; 
            hwrapper.CF_LOCATION = 'Test';
            hwrapper.SHIP_VIA = 'Test';
            hwrapper.SHIP_DATE_ACTUAL = 'Test';
            hwrapper.CP_FREIGHT_CODE = 'Test';
            
        ife_CustomerInvoiceController.LinesWapper lWrapper = new ife_CustomerInvoiceController.LinesWapper();
         lWrapper.PO_LINE_REF  = 'Test';

		 lWrapper.LINE_UOM = 'Test';

		  lWrapper.LINE_NUMBER = 123;
		  lWrapper.LINE_TYPE = 'Test';

		  lWrapper.ORDER_NUMBER = 'Test';

		  lWrapper.LINE_ITEM_DESCRIPTION = 'Test';
		  lWrapper.ORD_COMMENTS = 'Test';

		  lWrapper.LINE_EXTENDED_AMOUNT = 123;

		  lWrapper.LINE_ID = 123;

		  lWrapper.LINE_UNIT_SELLING_PRICE = 123;
    }
}