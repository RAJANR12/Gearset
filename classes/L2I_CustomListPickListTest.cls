/**
 * Test class for CustomListObjPickList, CustomListTablePropPickList, CustomListFieldSetPickList
 * TODO: need to finish this class.
 */
@isTest
private class L2I_CustomListPickListTest {
    @isTest
    static void test_standard() {
        L2I_CustomListObjPicklist customListObjPicklist = new L2I_CustomListObjPicklist();
        customListObjPicklist.getDefaultValue();
        customListObjPicklist.getValues();

        L2I_CustomListFieldSetPickList customListFieldSetPickList = new L2I_CustomListFieldSetPickList();
        customListFieldSetPickList.getDefaultValue();
        customListFieldSetPickList.getValues();
        
        L2I_CustomListTablePropPickList customListTablePropPickList = new L2I_CustomListTablePropPickList();
        customListTablePropPickList.getDefaultValue();
        customListTablePropPickList.getValues();
    }
}