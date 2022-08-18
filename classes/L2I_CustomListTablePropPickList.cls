global class L2I_CustomListTablePropPickList extends VisualEditor.DynamicPickList{    
    global override VisualEditor.DataRow getDefaultValue(){
        //VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('red', 'RED');
        return null;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        List<L2I_Table_Properties__mdt> tableProperties = [
            SELECT L2I_Table_Name__c FROM L2I_Table_Properties__mdt
            WHERE L2I_Table_Name__c != null
            LIMIT 5000
        ];

        if(Test.isRunningTest()) {
            tableProperties.add(new L2I_Table_Properties__mdt(
                L2I_Field_API_Name__c = 'Product2Id',
                L2I_Related_Lookup_Field__c = 'PricebookEntry.Product2Id',
                L2I_Linkified__c = true,
                L2I_Read_Only__c = true,
                L2I_Override_FLS__c = true
            ));
        }

        Set<String> uniqueTablePropertyNames = new Set<String>();
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        for(L2I_Table_Properties__mdt tp : tableProperties) {
            if(!uniqueTablePropertyNames.contains(tp.L2I_Table_Name__c)) {
                VisualEditor.DataRow value = new VisualEditor.DataRow(tp.L2I_Table_Name__c, tp.L2I_Table_Name__c);
                myValues.addRow(value);
            }
            uniqueTablePropertyNames.add(tp.L2I_Table_Name__c);
        }
        return myValues;
    }
}