global class PT_AssignPTCPLBatch implements Database.Batchable<sObject> {

    static List <Asset> partsList_toBeInserted = new List <Asset>();
    static List <Asset> partsList_toBeUpdated = new List <Asset>();
    static List <PT_Install_Location__c> installLocationsList_toBeUpdated = new List <PT_Install_Location__c>();
    static List <PT_Install_Location__c> installLocationsList_toBeInserted = new List <PT_Install_Location__c>();
    static Map<Id, List<SBQQ__QuoteLine__c>> quoteLineGroupMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
    static Map<String, Id> prodAttributeMap = new Map<String, Id>();
    static Integer opptyRevNumber;
    static String aircraftType;
    static String programId;
    static String accId;
    static SBQQ__Quote__c quote;
    static List<Id> dslIds = new List<Id>();
    String opportunityId;
    String primaryQuoteId;
    public String query;

    public PT_AssignPTCPLBatch(String primaryQuoteId) {
        this.primaryQuoteId = primaryQuoteId;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        opportunityId = [SELECT SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id = :primaryQuoteId LIMIT 1][0].SBQQ__Opportunity2__c;
        query = 'SELECT Id FROM L2I_DSL__c WHERE Original_Opportunity__c = :opportunityId';
        return Database.getQueryLocator(query);
     }
    public void execute(Database.BatchableContext BC, List<L2I_DSL__c> scope) {
        quote = [SELECT OwnerId, SBQQ__Opportunity2__r.LastModifiedDate, SBQQ__Opportunity2__r.LastModifiedById, SBQQ__Opportunity2__r.L2I_Aircraft_Type__c, SBQQ__Opportunity2__r.L2I_Program_Num__c,
                                    SBQQ__Opportunity2__r.AccountId, SBQQ__Opportunity2__r.PT_Parts_List_Revision_Number__c
                                    FROM SBQQ__Quote__c
                                    WHERE Id = :primaryQuoteId LIMIT 1];
        aircraftType = quote.SBQQ__Opportunity2__r.L2I_Aircraft_Type__c;
        programId = quote.SBQQ__Opportunity2__r.L2I_Program_Num__c;
        accId = quote.SBQQ__Opportunity2__r.AccountId;
        opptyRevNumber = Integer.valueOf(quote.SBQQ__Opportunity2__r.PT_Parts_List_Revision_Number__c);
        for (L2I_DSL__c dsl : scope) {
            dslIds.add(dsl.Id);
        }
        syncQuoteData();
    }

//Sync Quote data to Install Location and Assets
    public void syncQuoteData() {
        Set<Id> productIds = new Set<Id>();
        Set<Id> existigInstallLocationIds = new Set<Id>();
        String assetStatus = 'New';
        String revisedDescription = 'Asset added for the first time';

        for (PT_Install_Location__c exisingInstalLocation : [SELECT Id FROM PT_Install_Location__c WHERE ShipSet__c IN :dslIds]) {
            installLocationsList_toBeUpdated.add(new PT_Install_Location__c (Id = exisingInstalLocation.Id, Status__c = 'Deleted'));
            existigInstallLocationIds.add(exisingInstalLocation.Id);
        }

        for (Asset exisingPart : [SELECT Id FROM Asset WHERE PT_Install_Location__c IN :existigInstallLocationIds]) {
            partsList_toBeUpdated.add(new Asset (Id = exisingPart.Id, PT_Status__c = 'Removed', Status = 'Deleted'));
        }

        if (installLocationsList_toBeUpdated.size() > 0) {
            database.update(installLocationsList_toBeUpdated, false);
        }

        if (partsList_toBeUpdated.size() > 0) {
            assetStatus = 'Reinitialized';
            revisedDescription = 'Asset Existed when Parts List was Initialized';
            database.update(partsList_toBeUpdated, false);
        }

        for (SBQQ__QuoteLine__c quoteLine : [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :primaryQuoteId]) {
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
        for (SBQQ__QuoteLineGroup__c quoteGroup : [SELECT Id, Name, PT_Seat_Count__c,  PT_Seat_Model__c, PT_Seat_Vendor__c FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :primaryQuoteId]) {
            if (String.isNotBlank(quoteGroup.Name)) {
                String solutionGroup = solutionGroupNamesMap.get(quoteGroup.Name);
                for (Id dslId : dslIds) {
                    installLocationsList_toBeInserted.add(new PT_Install_Location__c(
                                                        Status__c = 'Active',
                                                        Solution_Group__c = solutionGroup,
                                                        Quote_Line_Group__c = quoteGroup.id,
                                                        ShipSet__c = dslId,
                                                        Name = quoteGroup.Name,
                                                        PT_Install_Location__c = quoteGroup.Name,
                                                        PT_Seat_Count__c = quoteGroup.PT_Seat_Count__c,
                                                        PT_Seat_Model__c = quoteGroup.PT_Seat_Model__c,
                                                        PT_Seat_Vendor__c = quoteGroup.PT_Seat_Vendor__c
                                                    ));
                }
            }
        }

        if (installLocationsList_toBeInserted.size() > 0) {
            database.insert(installLocationsList_toBeInserted, false);
        }

        Map<String,Id> quoteGroupInstallLocationMap = new Map<String, Id>();
        for (PT_Install_Location__c il :  installLocationsList_toBeInserted) {
            quoteGroupInstallLocationMap.put(il.ShipSet__c + '-' + il.Quote_Line_Group__c, il.Id);
        }

        Map<Id, Integer> quoteLineConfigQtyMap = new Map<Id, Integer>();
        Integer quoteLineConfigQty;
        for (SBQQ__QuoteLine__c quoteLine : [SELECT Id, SBQQ__NetPrice__c, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Group__c, SBQQ__Quantity__c, PT_Configured_Quantity__c
                                                FROM SBQQ__QuoteLine__c
                                                WHERE SBQQ__Quote__c = :primaryQuoteId]) {
            if (quoteLine.PT_Configured_Quantity__c == null || quoteLine.PT_Configured_Quantity__c < quoteLine.SBQQ__Quantity__c) {
                quoteLineConfigQty = (quoteLine.SBQQ__Quantity__c).intValue();
                quoteLineConfigQtyMap.put(quoteLine.Id, quoteLineConfigQty);
            } else {
                quoteLineConfigQty = (quoteLine.PT_Configured_Quantity__c).intValue();
                quoteLineConfigQtyMap.put(quoteLine.Id, quoteLineConfigQty);
            }
            for (Id dslId : dslIds) {
                partsList_toBeInserted.add(new Asset(
                                    Status = 'Active',
                                    SBQQ__QuoteLine__c = quoteLine.id,
                                    SBQQ__LatestQuoteLine__c = quoteLine.id,
                                    PT_Install_Location__c = quoteGroupInstallLocationMap.get(dslId + '-' + quoteLine.SBQQ__Group__c),
                                    Product2Id = quoteLine.SBQQ__Product__c,
                                    Quantity = quoteLine.SBQQ__Quantity__c,
                                    SBQQ__BundledQuantity__c = quoteLine.SBQQ__Quantity__c,
                                    Name = quoteLine.SBQQ__Product__r.Name,
                                    PT_Configured_Quantity__c = quoteLineConfigQty,
                                    PT_Extended_Product_Attribute__c = prodAttributeMap.get(aircraftType + '-' + quoteLine.SBQQ__Product__c),
                                    PT_Program__c = programId,
                                    AccountId = accId,
                                    PT_Status__c = 'Active',
                                    PT_isApproved__c = true,
                                    PT_Revision_Number__c = opptyRevNumber
                                    ));
            }
        }

        if (partsList_toBeInserted.size() > 0) {
            database.insert(partsList_toBeInserted, false);
        }

        //Sync Price from Quote Lines to DSL Assets
        PT_PartList_Utils.syncPriceFromQuoteLinesToDSLAssets(primaryQuoteId);

//Update PT_Assigned_Part_List__c
        List<L2I_DSL__c> dslRecordToBeUpdated = new List<L2I_DSL__c>();
        for (L2I_DSL__c dslRecord : [SELECT Id, PT_Assigned_Part_List__c, CPQ_Quote__c FROM L2I_DSL__c WHERE id IN :dslIds]) {
            System.debug ('For Update PT_Assigned_Part_List__c, CPQ_Quote__c: ' + dslRecord.CPQ_Quote__c + ', PT_Assigned_Part_List__c: ' + dslRecord.PT_Assigned_Part_List__c);
            if (dslRecord.CPQ_Quote__c <> dslRecord.PT_Assigned_Part_List__c) {
                System.debug ('For Update PT_Assigned_Part_List__c, not matched. updating DSL..');
                dslRecord.PT_Assigned_Part_List__c = dslRecord.CPQ_Quote__c;
                dslRecordToBeUpdated.add(dslRecord);
                System.debug ('For Update PT_Assigned_Part_List__c, Updated DSL!');
            }
        }

        if (dslRecordToBeUpdated.size() > 0) {
            database.update(dslRecordToBeUpdated, false);
        }
    }

    public void finish(Database.BatchableContext BC){
    }
}