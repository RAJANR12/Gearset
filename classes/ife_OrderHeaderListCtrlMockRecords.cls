public class ife_OrderHeaderListCtrlMockRecords {
 /*@TestVisible protected List<SObject> mockedRecords =
        new List<SObject>();

    public void addTestRecord(SObject record) {
        mockedRecords.add(record);
    }

    public void addTestRecords(List<SObject> records) {
        mockedRecords.addAll(records);
    }*/
    
    public static myIfeOrderHeaders__x getRecords()
    {
        myIfeOrderHeaders__x order1 = new myIfeOrderHeaders__x(
            ExternalId = '123',
            CUSTOMER_ID__c = '123',
            HEADER_ID__c  = '234',
            SALES_ADMIN__c  = 'admin'     
        );
      
     //   List<myIfeOrderHeaders__x> orderList = new List<myIfeOrderHeaders__x>{order1};
         
        return order1;
    }
}