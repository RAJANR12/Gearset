@isTest
private class ife_SOReportControllerTest {
	@isTest
    public static void getPageValueTest(){
        Test.setMock(HttpCalloutMock.class, new ife_SOReportControllerMockCallout());
        
        ife_SOReportController sOReportCntrl = new ife_SOReportController();
        sOReportCntrl.getPageValue();
    }
    @isTest
    public static void getPageValuenullTest(){
       // Test.setMock(HttpCalloutMock.class, new null);
        
        ife_SOReportController sOReportCntrl = new ife_SOReportController();
        sOReportCntrl.getPageValue();
    }
    @isTest 
    public static void createWrapper(){
        ife_SOReportController.cls_Header wrapper = new ife_SOReportController.cls_Header();
          wrapper.RP_TAXABLE_AMOUNT = 123;
		  wrapper.B_COUNTRY_NAME= 'Test';
		  wrapper.HEADER_ID= 123;
		  wrapper.BILL_TO_LOCATION= 'Test';
		  wrapper.F_AC_NUMBER= 'Test';
		  wrapper.ORDER_NUMBER= 123;
		  wrapper.PAYMENT_TERMS= 'Test';
		  wrapper.S_CITY_ST_ZIP= 'Test';
		  wrapper.CF_SR_NUMBER= 'Test';
		  wrapper.BILL_CUSTOMER= 'Test';
		  wrapper.F_SO_CONTACT = 'Test';
		  wrapper.B_ADDRESS3= 'Test';
		  wrapper.H_ORDER_TYPE_ID= 123;
		  wrapper.B_ADDRESS4= 'Test';
		  wrapper.B_ADDRESS1= 'Test';
		  wrapper.FREIGHT_TERMS= 'Test';
		  wrapper.F_AC_TYPE= 'Test';
		  wrapper.ORDER_DATE= 'Test';
		  wrapper.S_ADDRESS4= 'Test';
		  wrapper.CF_HDR_HOLD= 123;
		  wrapper.CARRIER= 'Test';
		  wrapper.CURRENCY1= 'Test';
          wrapper.S_ADDRESS2= 'Test';
		  wrapper.S_ADDRESS3= 'Test';
		  wrapper.PURCHASE_ORDER= 'Test';
		  wrapper.CF_DSP_EXTND_AMT= 123.2;
		  wrapper.S_ADDRESS1= 'Test';
		  wrapper.SHIP_TO_LOCATION= 'Test';
		  wrapper.ATTRIBUTE1= 'Test';
		  wrapper.FOB= 'Test';
          wrapper.B_ADDRESS2 = 'Test';
          wrapper.S_COUNTRY_NAME= 'Test';
		  wrapper.SHIP_CUSTOMER= 'Test';
		  wrapper.B_CITY_ST_ZIP1= 'Test';
        
        ife_SOReportController.cls_lines  wrapp = new ife_SOReportController.cls_lines();
        
            wrapp.DECODE_SUBSTR_UPPER_P_PRINT_DE = 'Test';
            wrapp.ITEM_DESCRIPTION2 = 'Test';
            wrapp.QUANTITY_ORDERED = 123;
            wrapp.CF_LINE_HOLD = 123;
            wrapp.C_EXTENDED_PRICE_DSP = 123.3;
            wrapp.SELLING_PRICE = 123.3;
            wrapp.UNIT = 'Test';
            wrapp.SHIP_NUMBER = 123;
            wrapp.SCHEDULE_DATE = 'Test';
            wrapp.HEADER_ID = 123;
            
        ife_SOReportController.fromJSON jsonWrap = new ife_SOReportController.fromJSON();
    }
}