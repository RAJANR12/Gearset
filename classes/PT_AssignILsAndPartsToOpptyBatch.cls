public class PT_AssignILsAndPartsToOpptyBatch implements Database.Batchable<sObject> {

    static List <Asset> partsList_toBeInserted = new List <Asset>();
    static List <Asset> partsList_toBeUpdated = new List <Asset>();
    static List <PT_Install_Location__c> installLocationsList_toBeUpdated = new List <PT_Install_Location__c>();
    static List <PT_Install_Location__c> installLocationsList_toBeInserted = new List <PT_Install_Location__c>();
    static Map<Id, List<SBQQ__QuoteLine__c>> quoteLineGroupMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
    static Map<String, Id> prodAttributeMap = new Map<String, Id>();
    static String aircraftType;
    static Opportunity oppty;
    String opportunityId;
    Id submitterId;
    String primaryQuoteId;
    static String programId;
    static Integer opptyRevNumber;
    public String query;
    static String accId;

    public PT_AssignILsAndPartsToOpptyBatch(String primaryQuoteId) {
        this.primaryQuoteId = primaryQuoteId;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        //opportunityId = [SELECT SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id = :primaryQuoteId LIMIT 1][0].SBQQ__Opportunity2__c;
        query = 'SELECT OwnerId, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id = :primaryQuoteId';
        return Database.getQueryLocator(query);
     }
    public void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> scope) {
        opportunityId = scope[0].SBQQ__Opportunity2__c;
        submitterId = scope[0].OwnerId;
        oppty = [SELECT LastModifiedDate, LastModifiedById, L2I_Program_Num__c, PT_Parts_List_Revision_Number__c, L2I_Aircraft_Type__c, AccountId FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        programId = oppty.L2I_Program_Num__c;
        aircraftType = oppty.L2I_Aircraft_Type__c;
        accId = oppty.AccountId;
        opptyRevNumber = Integer.valueOf(oppty.PT_Parts_List_Revision_Number__c);
        System.debug('*** PT_AssignILsAndPartsToOpptyBatch opptyRevNumber ' + opptyRevNumber);
        //Opportunity updateOppty = new Opportunity(Id = oppty.Id, PT_Parts_List_Revision_Number__c = opptyRevNumber);
        //update updateOppty;
        syncQuoteData();
    }
    //Sync Quote data to Install Location and Assets
    public void syncQuoteData() {
        Set<Id> productIds = new Set<Id>();
        Set<Id> existigInstallLocationIds = new Set<Id>();
        String assetStatus = 'New';
        String revisedDescription = 'Asset added for the first time';

        for (PT_Install_Location__c exisingInstalLocation : [SELECT Id FROM PT_Install_Location__c WHERE Part_List_Opportunity__c = :opportunityId AND Status__c != 'Deleted']) {
            installLocationsList_toBeUpdated.add(new PT_Install_Location__c (Id = exisingInstalLocation.Id, Status__c = 'Deleted'));
            existigInstallLocationIds.add(exisingInstalLocation.Id);
        }

        for (Asset exisingPart : [SELECT Id FROM Asset WHERE PT_Install_Location__c IN :existigInstallLocationIds AND Status != 'Deleted']) {
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

        for (SBQQ__QuoteLineGroup__c quoteGroup : [SELECT Id, Name, PT_Seat_Count__c, PT_Seat_Model__c, PT_Seat_Vendor__c FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :primaryQuoteId]) {
            if (String.isNotBlank(quoteGroup.Name)) {
                String solutionGroup = solutionGroupNamesMap.get(quoteGroup.Name);
                installLocationsList_toBeInserted.add(new PT_Install_Location__c(
                                                        Status__c = 'Active',
                                                        Solution_Group__c = solutionGroup,
                                                        Quote_Line_Group__c = quoteGroup.id,
                                                        Part_List_Opportunity__c = opportunityId,
                                                        Name = quoteGroup.Name,
                                                        PT_Install_Location__c = quoteGroup.Name,
                                                        PT_Seat_Count__c = quoteGroup.PT_Seat_Count__c,
                                                        PT_Seat_Model__c = quoteGroup.PT_Seat_Model__c,
                                                        PT_Seat_Vendor__c = quoteGroup.PT_Seat_Vendor__c
                                                    ));
            }
        }

        if (installLocationsList_toBeInserted.size() > 0) {
            insert installLocationsList_toBeInserted;
        }

        Map<Id, Id> quoteGroupInstallLocationMap = new Map<Id, Id>();
        for (PT_Install_Location__c il :  installLocationsList_toBeInserted) {
            quoteGroupInstallLocationMap.put(il.Quote_Line_Group__c, il.Id);
        }

        Map<Id, Integer> quoteLineConfigQtyMap = new Map<Id, Integer>();
        Integer quoteLineConfigQty;
        /*Suresh commented     for (SBQQ__QuoteLine__c quoteLine : [SELECT Id, SBQQ__ListPrice__c, SBQQ__NetPrice__c, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Group__c, SBQQ__Quantity__c, PT_Configured_Quantity__c
                                                FROM SBQQ__QuoteLine__c
                                                WHERE SBQQ__Quote__c = :primaryQuoteId]) { Suresh Commented end */
        //Suresh added
        for (SBQQ__QuoteLine__c quoteLine : [SELECT Id, SBQQ__ListPrice__c, SBQQ__NetPrice__c, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Group__c, SBQQ__Quantity__c, PT_Configured_Quantity__c, PT_Proposed_Part_Code__c, PT_Proposed_Part_Nomenclature__c
                                                FROM SBQQ__QuoteLine__c
                                                WHERE SBQQ__Quote__c = :primaryQuoteId]) {                               
        //Suresh added end                                            
                                                    
            if (quoteLine.PT_Configured_Quantity__c == null || quoteLine.PT_Configured_Quantity__c < quoteLine.SBQQ__Quantity__c) {
                quoteLineConfigQty = (quoteLine.SBQQ__Quantity__c).intValue();
                quoteLineConfigQtyMap.put(quoteLine.Id, quoteLineConfigQty);
            } else {
                quoteLineConfigQty = (quoteLine.PT_Configured_Quantity__c).intValue();
                quoteLineConfigQtyMap.put(quoteLine.Id, quoteLineConfigQty);
            }
            partsList_toBeInserted.add(new Asset(
                                    Status = 'Active',
                                    SBQQ__QuoteLine__c = quoteLine.id,
                                    SBQQ__LatestQuoteLine__c = quoteLine.id,
                                    PT_Install_Location__c = quoteGroupInstallLocationMap.get(quoteLine.SBQQ__Group__c),
                                    Product2Id = quoteLine.SBQQ__Product__c,
                                    Quantity = quoteLine.SBQQ__Quantity__c,
                                    SBQQ__BundledQuantity__c = quoteLine.SBQQ__Quantity__c,
                                    Name = quoteLine.SBQQ__Product__r.Name,
                                    PT_Configured_Quantity__c = quoteLineConfigQty,
                                    PT_Extended_Product_Attribute__c = prodAttributeMap.get(aircraftType + '-' + quoteLine.SBQQ__Product__c),
                                    PT_Program__c = programId,
                                    AccountId = accId,
                                    PT_Status__c = assetStatus,
                                    PT_isApproved__c = true,
                                    PT_Revision_Number__c = opptyRevNumber,
                                    SBQQ__ListPrice__c = quoteLine.SBQQ__ListPrice__c,
                                    Price = quoteLine.SBQQ__Netprice__c, //Suresh added
                                    PT_Proposed_Part_Code__c =quoteLine.PT_Proposed_Part_Code__c,
                                    PT_Proposed_Part_Nomenclature__c =quoteLine.PT_Proposed_Part_Nomenclature__c //Suresh added end
                                ));
        }

        if (partsList_toBeInserted.size() > 0) {
            insert partsList_toBeInserted;
        }

        //List<PT_Parts_List_Revision__c> plrList = new List<PT_Parts_List_Revision__c>();
        List<SBQQ__QuoteLine__c> updateQuoteLines = new List<SBQQ__QuoteLine__c>();
        for (Asset ast :  partsList_toBeInserted) {
            updateQuoteLines.add(new SBQQ__QuoteLine__c(Id = ast.SBQQ__QuoteLine__c,
                                                        PT_Asset__c = ast.Id,
                                                        PT_Configured_Quantity__c = quoteLineConfigQtyMap.get(ast.SBQQ__QuoteLine__c)
                                                        ));
        }

        if (updateQuoteLines.size() > 0) {
            SBQQ.TriggerControl.disable();
            update updateQuoteLines;
            SBQQ.TriggerControl.enable();
        }
        List<Id> opportunityIds = new List<Id>{opportunityId};
        PT_PartList_Utils.syncPriceFromQuoteLinesToAssets(primaryQuoteId);
        PT_PartList_Utils.createPendingPartListRecords(opportunityIds);
        PT_PartList_Utils.updateOpportunityPostApproval(opportunityId);
        PT_PartList_Utils.updatePartListPostApproval(opportunityId);
        PT_PartList_Utils.updateAssetsOnPartListApproval(opportunityId);
        // Create platform events to Synchronize the parts list with Quote.
        PT_PartList_Utils.createSyncPartsListToQuoteEvent(opportunityId);
    }

    public void finish(Database.BatchableContext BC){

    }
}