global class L2I_CustomListObjPickList extends VisualEditor.DynamicPickList{
    global override VisualEditor.DataRow getDefaultValue(){
        //VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('red', 'RED');
        return null;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        for(Schema.SObjectType objTyp : L2I_ApexUtils.globalDescribe.Values()){
            String fieldAPIName = objTyp.getDescribe().getName();
            VisualEditor.DataRow value = new VisualEditor.DataRow(fieldAPIName, fieldAPIName);
            myValues.addRow(value);
        }          
        return myValues;
    }
}