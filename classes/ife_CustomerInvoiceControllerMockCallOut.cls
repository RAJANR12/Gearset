@isTest
global class ife_CustomerInvoiceControllerMockCallOut implements HttpCalloutMock {
  
    global HTTPResponse respond(HTTPRequest req) {
       
       HttpResponse res = new HttpResponse();
       res.setHeader('Content-Type', 'application/json');
       res.setBody('{"Header": { "CP_INCIDENT_NUM": null, "CUSTOMER_NUMBER": "4908", "CF_WAYBILL": "422761171447", "ORDER_NUMBER": "3740716", "TRX_TYPE_NAME": null, "REPORT_ALL_AMOUNT": 19000, "LINE_ID": "13737750", "C_BILL_TO_CONCATENATED": "Attn: Accounts Payable VIETNAM AIRLINES PASSENGER SERVICE DEPARTMENT, SERVICE COST MGT (HDQHHVN) 200 NGUYEN SON STREET LONG BIEN DISTRICT HANOI Viet Nam", "CP_FREIGHT_CODE": "Bill Third Party", "INVOICE_CURRENCY_CODE": "USD", "CP_PROGRAM_NUMBER": "CVNMCS01ME", "CP_TAIL_NUMBER": null, "CF_DATABASE": "PLMTST", "PURCHASE_ORDER_NUMBER": "VN/PAC-06/2020", "CP_SHIP_TO_CONCATENATED": "VAN ANH VIETNAM AIRLINES 414 NGUYEN VAN CU STR LONG BIEN DISTRICT HANOI Viet Nam", "SHIP_VIA_DESCRIPTION": "Fedex - Domestic Services", "CF_INCIDENT_ITEM": null, "H_ORDER_TYPE_ID": 1857, "REPORT_ITEM_AMOUNT": 19000, "BILL_TO_ATTN": null, "REPORT_TAX_AMOUNT": 0, "CP_LOT_OR_SERIAL_NO": null, "REPORT_FREIGHT_AMOUNT": 0, "TRX_DATE": "18-MAR-20", "CF_CUSTTRXTYPE_ID": 13001, "CF_DELIVERY_NUMBER": "972337241", "INV_SALES_ORDER": 3740716, "TERM_NAME": "30 NET -a", "CP_REMIT_TO_CONCATENATED": "Panasonic Avionics Corporation n P.O. Box 894503 LOS ANGELES CA 90189-4503 United States", "TRX_NUMBER": "14953089", "CF_LOCATION": null, "SHIP_VIA": "FDX", "SHIP_DATE_ACTUAL": "18-MAR-2020" }, "lines": [ { "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": " CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 },{ "PO_LINE_REF": "Cust. PO Line Ref.: APR/2020/eFX", "LINE_UOM": "EACH", "LINE_NUMBER": 1, "LINE_TYPE": "LINE", "ORDER_NUMBER": "3740716", "LINE_ITEM_DESCRIPTION": "CVNMCS01-0021 / eFX April 2020", "ORD_COMMENTS": "Comments : APR/2020/eFX", "LINE_QTY_ORDERED": 1, "LINE_EXTENDED_AMOUNT": 19000, "LINE_ID": 13737750, "LINE_UNIT_SELLING_PRICE": 19000 } ] }');
       res.setStatusCode(200);        
       return res;    
   }
}