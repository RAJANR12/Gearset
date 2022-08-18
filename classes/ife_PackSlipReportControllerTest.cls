@isTest
private class ife_PackSlipReportControllerTest {
    @isTest
    public static void getPageValueTest(){
        Test.setMock(HttpCalloutMock.class, new ife_PackSlipReportControllerMockCallout());
        
        ife_PackSlipReportController.HeaderWrapper hw = new ife_PackSlipReportController.HeaderWrapper();
      //  hw.DELIVERY_ID = 12;
        //    ife_PackSlipReportController.JSONWrapper.HeaderWrapper hw = new ife_PackSlipReportController.JSONWrapper.HeaderWrapper();
        ife_PackSlipReportController packSlipReportCntrl = new ife_PackSlipReportController();
        packSlipReportCntrl.getPageValue();
    }
    
    @isTest
    public static void crearteWrapperData(){
        ife_PackSlipReportController.JSONWrapper  jWrap= new ife_PackSlipReportController.JSONWrapper();
        ife_PackSlipReportController.HeaderWrapper hWrap = new ife_PackSlipReportController.HeaderWrapper();
        hWrap.DELIVERY_ID =123;
        hWrap.C_SHIP_DATE  ='Test';
        hWrap.NUMBER_OF_LPN  ='Test';
        hWrap.C_DELIVERY_NAME ='Test';
        hWrap.C_WAYBILL  ='Test';
        hWrap.C_GROSS_WEIGHT  =123;
        hWrap.C_WEIGHT_UOM  ='Test';
        hWrap.C_VOLUME  =123;
        hWrap.C_VOLUME_UOM_CODE  ='Test';
        hWrap.TRIP_NAME  ='Test';
        hWrap.CF_FROM_LOCATION  ='Test';
        hWrap.C_TO_ADDRESS_1 ='Test';
        hWrap.CF_TO_ADDR_2  ='Test';
        hWrap.CF_TO_ADDR_3  ='Test';
        hWrap.CF_TO_ADDR_4 ='Test';
        hWrap.CF_TO_CITY  ='Test';
        hWrap.CF_TERM  ='Test';
        hWrap.CF_FREIGHT_CARRIER  ='Test';  //FEDEX
        hWrap.CF_FREIGHT_TERMS  ='Test';
        hWrap.CONSIGNEE_NAME  ='Test';
        hWrap.CP_PACKING_INSTRUCTIONS  ='Test';
        hWrap.CF_FOB  ='Test';
        hWrap.F_BILL_TO_CUST_NAME  ='Test';
        hWrap.CP_WAREHOUSE_NAME  ='Test';
        hWrap.CP_WAREHOUSE_CODE  ='Test';
        hWrap.CP_SHIP_TO_PHONE_NO = 'test';
        hWrap.CF_SHIP_TO_CONTACT = 'test';
        hWrap.CF_PROGRAM_NUMBER = 'test';
        hWrap.C_SO_NUMBER = 'test';
        hWrap.CF_PROGRAM_TYPE = 'test';
        hWrap.CF_ULT_TO_ADDR1 = 'test';
        hWrap.CF_ULT_TO_ADDR2 = 'test';
        hWrap.CF_ULT_TO_ADDR3 = 'test';
        hWrap.CF_ULT_TO_ADDR4 = 'test';
        hWrap.CF_ULT_TO_CITY_STATE_ZIP = 'test';
        hWrap.CP_SHIPPING_INSTRUCTIONS = 'test';  
        hWrap.CP_ORIG_SYS_DOCUMENT_REF = 'test';  
        hWrap.CF_SHIP_SET = 'test';  
        hWrap.CF_TAIL_NUMBER = 'test';
        // hWrap.LinesWapper[] lines  ='Test';
        
        ife_PackSlipReportController.LinesWapper lWrap = new ife_PackSlipReportController.LinesWapper();
        lWrap.CF_ITEM_NUM   ='Test';
        lWrap.C_SO_NUMBER  ='Test';
        lWrap.LINE_NUM   =123;
        lWrap.C_ITEM_DESCRIPTION   ='Test';
        lWrap.C_SHIP_QTY   =123;
        lWrap.C_REQ_QTY_UOM   ='Test';
        lWrap.CF_INST_LOCATION   ='Test';
        lWrap.CF_PO_LINE_NUM   ='Test';
        lWrap.CF_REF_PO   ='Test';
        lWrap.CF_REF_IPO   ='Test';
        lWrap.CF_LPN_NAME  ='Test';
        lWrap.CP_DEST_SUB_INV  ='Test';
        lWrap.CF_LINE_NOTES  ='Test';
        lWrap.CF_CUST_PO_NUM  ='Test';
        lWrap.CF_ECCN_NUM  ='Test';
    } 
}