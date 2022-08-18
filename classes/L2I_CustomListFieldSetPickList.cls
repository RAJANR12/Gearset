global class L2I_CustomListFieldSetPickList extends VisualEditor.DynamicPickList{   
    global override VisualEditor.DataRow getDefaultValue(){
        //VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('red', 'RED');
        return null;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        Set<String> uniqueTablePropertyNames = new Set<String>();
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        for(Schema.SObjectType objTyp : L2I_ApexUtils.globalDescribe.Values()){
            String fieldAPIName = objTyp.getDescribe().getName();
            Map<String, Schema.FieldSet> fieldSetMap = L2I_ApexUtils.globalDescribe.get(fieldAPIName).getDescribe().FieldSets.getMap();
            for(String fieldSetName : fieldSetMap.keySet()) {
                if(!uniqueTablePropertyNames.contains(fieldSetName)) {
                    VisualEditor.DataRow value = new VisualEditor.DataRow(fieldSetName, fieldSetName);
                    myValues.addRow(value);
                }
                uniqueTablePropertyNames.add(fieldSetName);
            }
        }          
        return myValues;
    }
}