global class PT_UpdateDSLWIthPartsListBatch implements Database.Batchable<sObject> {

    static List <Asset> partsList_toBeInserted = new List <Asset>();
    static List <Asset> partsList_toBeUpdated = new List <Asset>();
    static List <Asset> partsList_toBeUpdated_2nd_iteration = new List <Asset>();
    static Map<Id, List<Asset>> existingPartInstallLocationMap = new Map<Id, List<Asset>>();
    static Map<Id, List<SBQQ__QuoteLine__c>> quoteLineGroupMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
    static Map<String, Id> prodAttributeMap = new Map<String, Id>();
    static String aircraftType;
    static String programId;
    String dslId;
    List<String> dslIds;
    String opportunityId;
    String primaryQuoteId;

    public String query;

    public PT_UpdateDSLWIthPartsListBatch(String primaryQuoteId) {
        this.primaryQuoteId = primaryQuoteId;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        opportunityId = [SELECT SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id = :primaryQuoteId LIMIT 1][0].SBQQ__Opportunity2__c;
        query = 'SELECT Id FROM L2I_DSL__c WHERE Original_Opportunity__c = :opportunityId';
        return Database.getQueryLocator(query);
     }
    public void execute(Database.BatchableContext BC, List<L2I_DSL__c> scope) {
        SBQQ__Quote__c Quote = [SELECT SBQQ__Opportunity2__r.L2I_Aircraft_Type__c, SBQQ__Opportunity2__r.L2I_Program_Num__c FROM SBQQ__Quote__c WHERE Id = :primaryQuoteId LIMIT 1];
        aircraftType = Quote.SBQQ__Opportunity2__r.L2I_Aircraft_Type__c;
        programId = Quote.SBQQ__Opportunity2__r.L2I_Program_Num__c;
        dslId = scope[0].Id;
        syncQuoteData();
    }

//Sync Quote data to Install Location and Assets
    public void syncQuoteData() {
        Set<Id> productIds = new Set<Id>();

        if (String.isBlank(primaryQuoteId)) {
            primaryQuoteId = [SELECT CPQ_Quote__c FROM L2I_DSL__c where id = :dslId][0].CPQ_Quote__c;
        }

        for (Asset exisingPart : [SELECT Id, Name, Status, PT_Status__c, PT_Program__c, SBQQ__QuoteLine__c, PT_Install_Location__c, SBQQ__LatestQuoteLine__c, Product2Id, Quantity, AccountId, PT_Configured_Quantity__c, PT_Extended_Product_Attribute__c FROM Asset WHERE PT_Install_Location__r.ShipSet__c = :dslId AND PT_Status__c = 'Active']) {
            if (existingPartInstallLocationMap.containsKey(exisingPart.PT_Install_Location__c)) {
                existingPartInstallLocationMap.get(exisingPart.PT_Install_Location__c).add(exisingPart);
            } else {
                existingPartInstallLocationMap.put(exisingPart.PT_Install_Location__c, new List<Asset>{exisingPart});
            }
        }

        for (SBQQ__QuoteLine__c quoteLine : [SELECT Id, SBQQ__ListPrice__c, SBQQ__Netprice__c, SBQQ__Product__c, SBQQ__Group__c, SBQQ__Product__r.Name,  SBQQ__Quantity__c, PT_Configured_Quantity__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :primaryQuoteId]) {
            if (quoteLineGroupMap.containsKey(quoteLine.SBQQ__Group__c)) {
                quoteLineGroupMap.get(quoteLine.SBQQ__Group__c).add(quoteLine);
            } else {
                quoteLineGroupMap.put(quoteLine.SBQQ__Group__c, new List<SBQQ__QuoteLine__c>{quoteLine});
            }
            productIds.add(quoteLine.SBQQ__Product__c);
        }

        List<L2I_Product_Attributes__c> prodAttributes = [SELECT Id, L2I_Product__c, L2I_Aircraft_Type__c FROM L2I_Product_Attributes__c
                                                            WHERE L2I_Aircraft_Type__c = :aircraftType AND L2I_Product__c IN :productIds];
        for (L2I_Product_Attributes__c prodAttr : prodAttributes) {
            prodAttributeMap.put(prodAttr.L2I_Aircraft_Type__c + '-' + prodAttr.L2I_Product__c, prodAttr.Id);
        }

//Get Solution Group Names to be mapped and added at IL level.
        Map <String, Id> solutionGroupNamesMap = new Map <String, Id>();
        for (SBQQ__SolutionGroup__c sg : [SELECT Name, Id from SBQQ__SolutionGroup__c]) {
            solutionGroupNamesMap.put(sg.Name, sg.Id);
        }

//Get IL records to be created, updated (deleted are also part of this, with status updated to inactive)
        List <PT_Install_Location__c> installLocationsList_toBeInserted = new List <PT_Install_Location__c>();
        List <PT_Install_Location__c> installLocationsList_toBeUpdated = new List <PT_Install_Location__c>();
        Set <String> sourceQuoteGroupNames = new Set <String> ();
        Set <Id> sourceQuoteGroupIds = new Set <Id> ();
        Map <String, PT_Install_Location__c> exisingInstalLocationsMap = new Map<String, PT_Install_Location__c> ();

        for (PT_Install_Location__c exisingInstalLocation : [SELECT Id, Status__c, Name, PT_Install_Location__c, Solution_Group__c, Quote_Line_Group__c, ShipSet__c FROM PT_Install_Location__c WHERE ShipSet__c = :dslId AND Status__c = 'Active']) {
            exisingInstalLocationsMap.put(exisingInstalLocation.Name, exisingInstalLocation);
        }

        for (SBQQ__QuoteLineGroup__c quoteGroup : [SELECT Id, Name FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :primaryQuoteId]) {

            sourceQuoteGroupNames.add(quoteGroup.Name);
            sourceQuoteGroupIds.add(quoteGroup.Id);

            if (String.isNotBlank(quoteGroup.Name)) {

                String solutionGroup = solutionGroupNamesMap.get(quoteGroup.Name);

//For update, record should be found and values are different
                if (exisingInstalLocationsMap.containsKey(quoteGroup.Name)) {

//Check for any fields to be updated
                    PT_Install_Location__c iLRecord = exisingInstalLocationsMap.get(quoteGroup.Name);
                    if (iLRecord.Solution_Group__c <> solutionGroup || iLRecord.Quote_Line_Group__c <> quoteGroup.id || iLRecord.Name <> quoteGroup.Name) {
                        iLRecord.Solution_Group__c = solutionGroup;
                        iLRecord.Quote_Line_Group__c = quoteGroup.id;
                        iLRecord.Name = quoteGroup.Name;
                        installLocationsList_toBeUpdated.add(iLRecord);
                    } else {
                        System.debug('No change to IL: ' + iLRecord.id);
                    }

                } else {
//Create a new record.
                    installLocationsList_toBeInserted.add(
                          new PT_Install_Location__c(
                                Status__c = 'Active',
                                Solution_Group__c = solutionGroup,
                                Quote_Line_Group__c = quoteGroup.id,
                                ShipSet__c = dslId,
                                Name = quoteGroup.Name,
                                PT_Install_Location__c = quoteGroup.Name
                          )
                    );
                }
            }
        }

//Also, iterate through the Install Location records to find any to be marked deleted
        for (String exisingInstalLocationName : exisingInstalLocationsMap.keyset()) {
            if (!sourceQuoteGroupNames.contains(exisingInstalLocationName)) {
                PT_Install_Location__c iLRecord = exisingInstalLocationsMap.get(exisingInstalLocationName);
                if (iLRecord.Status__c <> 'Deleted') {
                    iLRecord.Status__c = 'Deleted';
                    installLocationsList_toBeUpdated.add(iLRecord);
                }
            }
        }

        if (installLocationsList_toBeInserted.size() > 0) {
            database.insert(installLocationsList_toBeInserted, false);
        }

        if (installLocationsList_toBeUpdated.size() > 0) {
            // Remove dupes from list if any.
            Map<Id, PT_Install_Location__c> mapSObj = new Map<Id, PT_Install_Location__c>();
            mapSObj.putAll(installLocationsList_toBeUpdated);
            database.update(mapSObj.values(), false) ;
        }

//For the latest list of Install Locations, synchronize Parts data
        for (PT_Install_Location__c installLocation : [SELECT Id, Quote_Line_Group__c, ShipSet__r.Delivery_Schedule_Header__r.Account__c, Status__c
                                                        FROM PT_Install_Location__c
                                                        WHERE Quote_Line_Group__c in :sourceQuoteGroupIds AND ShipSet__c = :dslId AND Status__c = 'Active']) {
//            syncPartsData(installLocation.Quote_Line_Group__c, installLocation.Id, installLocation.ShipSet__r.Delivery_Schedule_Header__r.Account__c, installLocation.status__c, isPCLSSProcess);
                syncPartsData(installLocation.Quote_Line_Group__c, installLocation.Id, installLocation.ShipSet__r.Delivery_Schedule_Header__r.Account__c, installLocation.status__c);
        }

        if (partsList_toBeInserted.size() > 0) {
            database.insert (partsList_toBeInserted,false);
        }

        if (partsList_toBeUpdated.size() > 0) {
            // Remove dupes from list if any.
            Map<Id, Asset> mapSObj = new Map<Id, Asset>();
            mapSObj.putAll(partsList_toBeUpdated);
            database.update(mapSObj.values(), false);
        }

        if (partsList_toBeUpdated_2nd_iteration.size() > 0) {
            // Remove dupes from list if any.
            Map<Id, Asset> mapSObj = new Map<Id, Asset>();
            mapSObj.putAll(partsList_toBeUpdated_2nd_iteration);
            database.update(mapSObj.values(), false);
        }

//Finally, sync ILs and Assets based on the status
        //updateILsAndAsset(dslId);

    }

//Sync Quote line data to Parts
//    private static void syncPartsData(String quoteGroupId, String installLocationId, String acctId, String ilStatus, Boolean isPCLSSProcess) {
       public static void syncPartsData(String quoteGroupId, String installLocationId, String acctId, String ilStatus) {
        Set <String> sourcequoteLineIDs = new Set <String>();
        Map <String, Asset> exisingPartsMap = new Map<String, Asset>();
        if(existingPartInstallLocationMap.containsKey(installLocationId)) {
            for (Asset exisingPart : existingPartInstallLocationMap.get(installLocationId)) {
                exisingPartsMap.put(exisingPart.Product2Id, exisingPart);
            }
        }

        if (quoteLineGroupMap.containsKey(quoteGroupId)) {
            for (SBQQ__QuoteLine__c quoteLine : quoteLineGroupMap.get(quoteGroupId)) {
                sourcequoteLineIDs.add(quoteLine.SBQQ__Product__c);

                //For update, record should be found and values are different
                if (exisingPartsMap.containsKey(quoteLine.SBQQ__Product__c)) {

                    //Check for any fields to be updated
                    Asset partRecord = exisingPartsMap.get(quoteLine.SBQQ__Product__c);
                    if (partRecord.Name <> quoteLine.SBQQ__Product__r.Name || partRecord.Quantity <> quoteLine.SBQQ__Quantity__c ||
                        partRecord.AccountId <> acctId || partRecord.PT_Configured_Quantity__c <> quoteLine.PT_Configured_Quantity__c ||
                        partRecord.PT_Program__c == null || partRecord.PT_Program__c != programId) {
                        partRecord.SBQQ__LatestQuoteLine__c = quoteLine.id;
                        partRecord.SBQQ__QuoteLine__c = quoteLine.id;
                        partRecord.Product2Id = quoteLine.SBQQ__Product__c;
                        partRecord.Quantity = quoteLine.SBQQ__Quantity__c;
                        partRecord.Name = quoteLine.SBQQ__Product__r.Name;
                        partRecord.PT_Configured_Quantity__c = quoteLine.PT_Configured_Quantity__c;
                        partRecord.AccountId = acctId;
                        partRecord.PT_Extended_Product_Attribute__c = prodAttributeMap.get(aircraftType + '-' + quoteLine.SBQQ__Product__c);
                        partRecord.PT_Program__c = programId;
                        partsList_toBeUpdated.add(partRecord);
                    } else if (ilStatus == 'Deleted' && partRecord.Status <> 'Deleted') {
                        partRecord.Status = 'Deleted';
                        partsList_toBeUpdated.add(partRecord);
                    } else {
                        System.debug('No change to Part: ' + partRecord.id);
                    }

                } else {
                //Create a new record
                    partsList_toBeInserted.add(new Asset(
                                                Status = 'Active',
                                                PT_Status__c = 'Active',
                                                SBQQ__QuoteLine__c = quoteLine.id,
                                                SBQQ__LatestQuoteLine__c = quoteLine.id,
                                                PT_Install_Location__c = installLocationId,
                                                Product2Id = quoteLine.SBQQ__Product__c,
                                                Quantity = quoteLine.SBQQ__Quantity__c,
                                                SBQQ__BundledQuantity__c = quoteLine.SBQQ__Quantity__c,
                                                Name = quoteLine.SBQQ__Product__r.Name,
                                                PT_Configured_Quantity__c = quoteLine.PT_Configured_Quantity__c,
                                                PT_Extended_Product_Attribute__c = prodAttributeMap.get(aircraftType + '-' + quoteLine.SBQQ__Product__c),
                                                PT_Program__c = programId,
                                                AccountId = acctId,
                                                SBQQ__ListPrice__c = quoteLine.SBQQ__ListPrice__c,
                                                Price = quoteLine.SBQQ__Netprice__c
                        ));
                }
            }
        }


//Also, iterate through the Install Location records to find any to be marked deleted
        for (String exisingPartQuoteLineId : exisingPartsMap.keyset()) {
            if (!sourcequoteLineIDs.contains(exisingPartQuoteLineId)) {
                Asset partRecord = exisingPartsMap.get(exisingPartQuoteLineId);
                if (partRecord.PT_Status__c <> 'Removed') {
                    partRecord.Status = 'Deleted';
                    partRecord.PT_Status__c = 'Removed';
                    partsList_toBeUpdated_2nd_iteration.add(partRecord);
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC){
    }
}