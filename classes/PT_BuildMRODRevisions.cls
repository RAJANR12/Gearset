/**
 *  @author       Sarah Kennedy
 *  @date         12/18/2020
 *  @description  PT_BuildMRODRevisions class - runs prior to submitting the MROD approval
 *
 *  Modification Log:
 *  ------------------------------------------------------------------------------------
 *  Developer                       Date                Description
 *  ------------------------------------------------------------------------------------
 *  Sarah Kennedy                  12/18/2020         Initial scaffold
 *
 */
public class PT_BuildMRODRevisions {
    @InvocableMethod(Label = 'Build Pending MROD Revisions')
    public static List<Boolean> buildPendingMRODRecords(List<Id> programId) {
        List<Asset> astList = new List<Asset>();
        List<PT_MROD_Revision__c> mrList = new List<PT_MROD_Revision__c>();
        //
        // first delete any revision rcds to avoid duplicates
        List<PT_MROD_Revision__c> mrListRemove = new List<PT_MROD_Revision__c>();
        mrListRemove = [
                SELECT Id, Asset__r.PT_Pending__c
                FROM PT_MROD_Revision__c
                WHERE (Program__c = :programId[0])
        ];
        System.debug('*** mrListRemove ' + mrListRemove);
        if (!mrListRemove.isEmpty() && mrListRemove.size() > 0) {
            System.debug('*** delete mrListRemove ' + mrListRemove);
            delete mrListRemove;
        }
        // Get all Assets related to the Program Id
        astList = [
                SELECT Id,
                        PT_Program__r.Is_Airbus__c,
                        PT_Program__r.PT_PMO_Group__r.Name,
                        PT_Program__r.PT_PMO_SubGroup__r.Name,
                        PT_Install_Location__r.Part_List_Opportunity__c,
                        PT_Install_Location__r.Part_List_Opportunity__r.L2I_AC_Operator__r.Name,
                        PT_Install_Location__r.ShipSet__r.Original_Opportunity__r.L2I_AC_Operator__r.Name,
                        PT_Install_Location__r.Part_List_Opportunity__r.PT_CPL_Opportunity__r.L2I_AC_Operator__r.Name,
                        PT_Install_Location__r.Part_List_Opportunity__r.PT_Part_List_Name_Rev__c,
                        PT_Program__r.Program_Manager__c,
                        PT_Program__r.Program_Manager__r.Name,
                        PT_Program__r.Program_Administrator__r.Name,
                        PT_Program__r.Name,
                        PT_Program__r.Latest_Approval_Process_Type__c,
                        PT_Program__r.MROD_Revision__c,
                        PT_Program__c,
                        PT_Install_Location__r.ShipSet__r.Name,
                        PT_Install_Location__r.ShipSet__c,
                        PT_Install_Location__r.Name,
                        ProductCode,
                        Name,
                        Quantity,
                        Product2.L2I_Exclude_From_Orders__c,
                        PT_MROD__c,
                        PT_Pending__c,
                        PT_MROD_Forecast_Date__c,
                        PT_Airbus_D1_Date__c,
                        PT_Use_D1_Date__c,
                        PT_Expedited__c,
                        PT_Expedited_D1__c,
                        PT_Lead_Time__c,
                        Product2.L2I_Lead_Time__c,
                        PT_Default_Shipping_Org__c,
                        PT_Extended_Price__c,
                        Shipset_PPL_Link__c,
                        PT_Install_Location_Parent__c,
                        PT_PPL_Type__c
                FROM Asset
                WHERE PT_Program__c = :programId[0]
                AND ((PT_Pending__c <> null AND PT_Program__r.Latest_Approval_Process_Type__c = 'MROD')
                   OR (PT_Airbus_D1_Date__c <> null  AND PT_Program__r.Latest_Approval_Process_Type__c = 'Airbus MROD' AND
                (PT_Use_D1_Date__c = 'Yes' OR (PT_Use_D1_Date__c = 'No' AND PT_Pending__c <> null))))
                AND PT_Install_Location_Parent__c <> NULL
                AND PT_Can_be_Processed__c = true
                AND isPTAsset__c = true
        ];
        System.debug('*** astList.size() ' + astList.size());
        if (astList.isEmpty() || astList.size() == 0){
            return new List<Boolean>{false};   // no changes are pending
        }
        if (!astList.isEmpty() &&
                astList.size() > 0) {
            for (Asset ast2 : astList) {
                PT_MROD_Revision__c mr = new PT_MROD_Revision__c();
                mr.Asset__c = ast2.Id;
                mr.Region__c = ast2.PT_Program__r.PT_PMO_Group__r.Name;
                mr.Sub_Group__c = ast2.PT_Program__r.PT_PMO_SubGroup__r.Name;
                if (ast2.PT_Install_Location__c != NULL) {
                    if (ast2.PT_Install_Location__r.ShipSet__c == NULL) {
                        if (ast2.PT_Install_Location__r.Part_List_Opportunity__c != NULL &&
                                ast2.PT_Install_Location__r.Part_List_Opportunity__r.PT_CPL_Opportunity__c != NULL &&
                                ast2.PT_Install_Location__r.Part_List_Opportunity__r.PT_CPL_Opportunity__r.L2I_AC_Operator__c != NULL) {
                            mr.Operator__c = ast2.PT_Install_Location__r.Part_List_Opportunity__r.PT_CPL_Opportunity__r.L2I_AC_Operator__r.Name;
                            mr.PPL_Type__c = ast2.PT_PPL_Type__c;
                        }
                    } else {
                        if (ast2.PT_Install_Location__r.ShipSet__c != NULL &&
                                ast2.PT_Install_Location__r.ShipSet__r.Original_Opportunity__c != NULL &&
                                ast2.PT_Install_Location__r.ShipSet__r.Original_Opportunity__r.L2I_AC_Operator__c != NULL) {
                            mr.Operator__c = ast2.PT_Install_Location__r.ShipSet__r.Original_Opportunity__r.L2I_AC_Operator__r.Name;
                        }
                    }
                }
                mr.Program_Manager__c = ast2.PT_Program__r.Program_Manager__r.Name;
                mr.Program_Administrator__c = ast2.PT_Program__r.Program_Administrator__r.Name;
                mr.Program_Number__c = ast2.PT_Program__r.Name;
                mr.Program_MROD_Rev__c = ast2.PT_Program__r.MROD_Revision__c;
                mr.Shipset__c = ast2.PT_Install_Location__r.ShipSet__r.Name;
                mr.Install_Location__c = ast2.PT_Install_Location__c;
                mr.Installation_Location__c = ast2.PT_Install_Location__r.Name;
                mr.Part_Number__c = ast2.ProductCode;
                mr.Description__c = ast2.Name;
                mr.Purchase_Qty__c = ast2.Quantity;
                mr.Orderable_Item__c = !ast2.Product2.L2I_Exclude_From_Orders__c;
                mr.Current_MROD__c = ast2.PT_MROD__c;
                mr.Requested_MROD__c = ast2.PT_Pending__c;
                mr.Expedite__c = ast2.PT_Expedited__c;
                mr.Lead_Time__c = ast2.PT_Lead_Time__c;
                mr.Lead_Time_Days__c = ast2.Product2.L2I_Lead_Time__c;
                mr.Default_Shipping_Org__c = ast2.PT_Default_Shipping_Org__c;
                mr.Extended_Price__c = ast2.PT_Extended_Price__c;
                mr.Program__c = ast2.PT_Program__c;
                mr.Part_List_Opportunity__c = ast2.PT_Install_Location__r.Part_List_Opportunity__c;
                mr.ShipsetId__c = ast2.PT_Install_Location__r.ShipSet__c;
                mr.Part_List_Name_Rev__c = ast2.PT_Install_Location__r.Part_List_Opportunity__r.PT_Part_List_Name_Rev__c;
                mr.MROD_FORECAST_DATE__c = ast2.PT_MROD_Forecast_Date__c;
                mr.Latest_Approval_Process_Type__c = ast2.PT_Program__r.Latest_Approval_Process_Type__c;
//                if (ast2.PT_Program__r.Is_Airbus__c) {
                    mr.D1_Date__c = ast2.PT_Airbus_D1_Date__c;
                    mr.Expedite_D1__c = ast2.PT_Expedited_D1__c;
                    mr.Use_D1__c = ast2.PT_Use_D1_Date__c;
//                } else {
                    mr.Requested_MROD__c = ast2.PT_Pending__c;
                    mr.Expedite__c = ast2.PT_Expedited__c;
//                }

                mrList.add(mr);
            }
        }

        if (!mrList.isEmpty() &&
                mrList.size() > 0) {
            insert mrList;
        }
    
        return new List<Boolean>{true};
    }
}