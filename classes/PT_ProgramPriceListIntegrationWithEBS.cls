public class PT_ProgramPriceListIntegrationWithEBS {

    @InvocableMethod( label='Integrate Program Price List with EBS' )
    public static void invokeProgramPriceListToEBS (List <String> inputs) {
        processProgPriceListToEBS(inputs.get(0));
    }

    @future(callout=true)
    public static void processProgPriceListToEBS (Id progPLId) {
        PT_PriceList__c priceListWithPLEs = [SELECT Id, CreatedDate, CurrencyIsoCode, L2I_Header_ExternalId__c, PT_Description__c, PT_Price_List_Name__c, PT_Status__c,
                                                (SELECT Id, L2I_Line_ExternalId__c, PT_UnitPrice__c, PT_ProductCode__c, PT_Product__r.L2I_Inventory_Item_Id__c, PT_Product__r.L2I_Primary_Unit_Code__c, PT_StartDate__c
                                                FROM Program_Price_List_Entries__r WHERE PT_Status__c = 'Approved' OR (PT_Status__c = 'Integrated' AND L2I_IntegrationStatus__c != 'Success'))
                                            FROM PT_PriceList__c
                                            WHERE Id = :progPLId];
        PT_ProgramPriceListWrapper postBody = getPriceListJSON(priceListWithPLEs);
        HttpResponse response = sendPriceListToEBS(postBody);
        if (response != null && response.getStatusCode() == 200) {
            System.debug(response.getBody());
            // update Program Price List and related PLEs
            List<PT_PriceList_Entry__c> updatePLEList = new List<PT_PriceList_Entry__c>();
            for (PT_PriceList_Entry__c ple : priceListWithPLEs.Program_Price_List_Entries__r) {
                PT_PriceList_Entry__c updatePLE = new PT_PriceList_Entry__c(Id = ple.Id, PT_Status__c = 'Integrated');
                updatePLEList.add(updatePLE);
            }
            if (updatePLEList.size() > 0) {
                update updatePLEList;
            }

            priceListWithPLEs.PT_Status__c = 'Integration Completed';
            update priceListWithPLEs;
        }
    }
    public static PT_ProgramPriceListWrapper getPriceListJSON (PT_PriceList__c priceListWithPLEs) {
        PT_ProgramPriceListWrapper plJSON = new PT_ProgramPriceListWrapper();
        plJSON.sourceSystem = 'Salesforce';
        PT_ProgramPriceListWrapper.Header header = new PT_ProgramPriceListWrapper.Header();
        header.priceListName = priceListWithPLEs.PT_Price_List_Name__c;
        header.priceListDescription = priceListWithPLEs.PT_Description__c;
        header.headerExternalId = priceListWithPLEs.L2I_Header_ExternalId__c != null ? priceListWithPLEs.L2I_Header_ExternalId__c : '';
        header.currencyCode = priceListWithPLEs.CurrencyIsoCode;
        header.originalHeaderID = priceListWithPLEs.Id;
        header.activationStartDate = String.ValueOf(priceListWithPLEs.CreatedDate);
        header.operationType = 'CREATE';
        plJSON.Header = header;
        List<PT_ProgramPriceListWrapper.Lines> lines = new List<PT_ProgramPriceListWrapper.Lines>();
        for (PT_PriceList_Entry__c ple : priceListWithPLEs.Program_Price_List_Entries__r) {
            PT_ProgramPriceListWrapper.Lines line = new PT_ProgramPriceListWrapper.Lines();
            line.itemValuePerUnit = ple.PT_UnitPrice__c != null ? String.ValueOf(ple.PT_UnitPrice__c) : '';
            line.inventoryItemID = ple.PT_Product__r.L2I_Inventory_Item_Id__c != null ? ple.PT_Product__r.L2I_Inventory_Item_Id__c : '';
            line.primaryUnitOfMeasure = ple.PT_Product__r.L2I_Primary_Unit_Code__c != null ? ple.PT_Product__r.L2I_Primary_Unit_Code__c : '';
            line.originalLineId = ple.Id;
            line.operationType = 'CREATE';
            line.activationStartDate = ple.PT_StartDate__c != null ? String.ValueOf(ple.PT_StartDate__c) : '';
            line.lineExternalId = ple.L2I_Line_ExternalId__c != null ? ple.L2I_Line_ExternalId__c : '';
            lines.add(line);
        }
        plJSON.lines = lines;
        System.Debug(JSON.serialize(plJSON));
        return plJSON;
    }
    public static HttpResponse sendPriceListToEBS (PT_ProgramPriceListWrapper postBody) {
        HttpResponse response;
        PT_Integration__mdt integrationMdtObj = [SELECT Id, Client_Secret__c, Client_Id__c, URL__c, MasterLabel
		                                          FROM PT_Integration__mdt
		                                          WHERE MasterLabel = 'ProgramPriceList_EBS'
		                                          LIMIT 1];
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('client_id', integrationMdtObj.Client_Id__c);
            request.setHeader('client_secret', integrationMdtObj.Client_Secret__c);
            request.setHeader('Content-Type', 'application/json');
            request.setEndpoint(integrationMdtObj.URL__c);
            request.setMethod('POST');
            String reqBody = JSON.serialize(postBody);
            request.setBody(reqBody);
            response = http.send(request);
        } catch (Exception e) {
            System.debug('e---------' + e);
        }
        return response;
    }
}