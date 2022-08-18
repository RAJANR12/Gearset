@isTest
global class ife_PackSlipReportControllerMockCallout implements HttpCalloutMock {
  
    global HTTPResponse respond(HTTPRequest req) {
       
       HttpResponse res = new HttpResponse();
       res.setHeader('Content-Type', 'application/json');
       res.setBody('{"Header":{"DELIVERY_ID": 944390537, "H_ORDER_TYPE_ID": 1515, "C_SHIP_DATE": "2005-09-29T18:05:47", "NUMBER_OF_LPN": null, "C_DELIVERY_NAME": "944390537", "C_WAYBILL": "705404376445", "C_GROSS_WEIGHT": 416, "C_WEIGHT_UOM": "Kg", "C_VOLUME": 56, "C_VOLUME_UOM_CODE": "Bx", "TRIP_NAME": "619021", "CF_FROM_LOCATION": "OSAKA", "C_TO_ADDRESS_1": "C O AIRBUS COM", "CF_TO_ADDR_2": "USINE CLEMENT ADER AVENUE JEAN MONNET", "CF_TO_ADDR_3": "MAGASIN 7P2-TIT CC60Q", "CF_TO_ADDR_4": null, "CF_TO_CITY": "COLOMIERS 31770, FR", "CF_TERM": "30 NET -a", "CF_FREIGHT_CARRIER": "FEDEX", "CF_FREIGHT_TERMS": "PA Pays Freight (old)", "CONSIGNEE_NAME": "QATAR AIRWAYS", "CP_PACKING_INSTRUCTIONS": "DHL ACCT# 961085829", "CF_FOB": null, "F_BILL_TO_CUST_NAME": "QATAR AIRWAYS", "CP_WAREHOUSE_NAME": "OSAKA", "CP_WAREHOUSE_CODE": "OSA", "lines": [ { "CF_ITEM_NUM": "RD-AA5101-10", "C_SO_NUMBER": "1536600", "LINE_NUM": 50, "C_ITEM_DESCRIPTION": "TAPPING UNIT", "C_SHIP_QTY": 1, "C_REQ_QTY_UOM": "EA", "CF_INST_LOCATION": "OH", "CF_PO_LINE_NUM": "16", "CF_REF_PO": null, "CF_REF_IPO": null, "CF_LPN_NAME": null, "CP_DEST_SUB_INV": null, "CF_LINE_NOTES": null, "CF_CUST_PO_NUM": "2508252-11", "CF_ECCN_NUM": "9A991.d JPN" } ] } }');
       res.setStatusCode(200);        
       return res;    
   }
}