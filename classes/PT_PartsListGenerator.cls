global class PT_PartsListGenerator {
    public static Id priceBookId;
    public static Set<Id> productIds = new Set<Id>();
    // Call this method from Lightning Flow and get Quote ID and Attachment ID for part list.
    @InvocableMethod(label='Program Table Part List Generator'
        description='Process to modify an existing quote to match a parts list document')
    public static void getQuoteAndAttachmentId (List<Requests> requests) {
        if (requests[0].quoteId != null && requests[0].attachId != null) {
            SBQQ__Quote__c quoteRec = [SELECT Id, ApprovalStatus__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Pricebook2Id
                                        FROM SBQQ__Quote__c WHERE Id = :requests[0].quoteId];
            //Update price book to the latest  - To be updated later for more robust code
            List<Pricebook2> pb = [SELECT Id, L2I_Migration_External_Id__c FROM Pricebook2 WHERE L2I_IFEC_Default_Pricebook__c = TRUE ORDER BY Id Desc LIMIT 1];
            if (pb.size() == 1 && quoteRec.SBQQ__PriceBook__c == null) {
                priceBookId = pb[0].Id;
                quoteRec.SBQQ__PriceBook__c = priceBookId;
                quoteRec.SBQQ__LineItemsGrouped__c = true;
                update quoteRec;
                //If opportunity price book is null, then assign the price book.
                if (quoteRec.SBQQ__Opportunity2__r.Pricebook2Id == null) {
                    Opportunity opp = new Opportunity();
                    opp.Id = quoteRec.SBQQ__Opportunity2__c;
                    opp.Pricebook2Id = priceBookId;
                    update opp;
                }
            } else if (quoteRec.SBQQ__PriceBook__c != null) {
                priceBookId = quoteRec.SBQQ__PriceBook__c;
            }
            Boolean isQuoteApproved = checkQuoteApprovalStatus(quoteRec);
            if (isQuoteApproved) {
                PT_PLG_Invoke_Revise.Requests req = new PT_PLG_Invoke_Revise.Requests();
                req.quoteobj = requests[0].quoteId;
                List<PT_PLG_Invoke_Revise.Results> resp = PT_PLG_Invoke_Revise.ProcessPartsList(new List<PT_PLG_Invoke_Revise.Requests>{req});
                getPartListContentJSON(resp[0].quotes[0].Id, requests[0].attachId);
            } else {
                getPartListContentJSON(requests[0].quoteId, requests[0].attachId);
            }
        }
    }
    public static boolean checkQuoteApprovalStatus(SBQQ__Quote__c quoteRec) {
        String quoteStatus = quoteRec.ApprovalStatus__c;
        if (quoteStatus == 'Approved') {
            return true;
        } else {
            return false;
        }
    }

    //Input - Quote ID and Attachment ID for part list
    // Convert attachment JSON data into part list JSON response model.
    public static void getPartListContentJSON (Id quoteId, Id attachId) {
        String fileBodyStr;
        List<Attachment> att =   [Select Id, body From Attachment where id = :attachId LIMIT 1];
        if(att.size() == 1) { //If the JSON is sent as Attachment
            fileBodyStr = att[0].body.toString();
        } else { // If the JSON is sent as File and not an attachment
            List<ContentVersion> cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :attachId AND IsLatest = true Limit 1];
            if (cv.size() == 1) {
                Blob fileBody =cv[0].VersionData;
                fileBodyStr = fileBody.toString();
            }
        }
        if (String.isNotBlank(fileBodyStr)) {
            PT_PLG_Response_Model response = new PT_PLG_Response_Model();
            PT_PLG_Response_Model newPartsListWithHeader = response.parsePartsListFromJSON(fileBodyStr);
            List<PT_PLG_Response_Model.QuoteLines> newPartsList = newPartsListWithHeader.quoteLines;
            updateQuoteRecord(quoteId, newPartsListWithHeader);
            processPartLists(quoteId, newPartsList);
            // Invoke flow for Calculating the Quote using CPQ API
            Map<String, Object> params = new Map<String, Object>();
            params.put('quoteId', quoteId);
            Flow.Interview.Calculate_Quote myFlow = new Flow.Interview.Calculate_Quote(params);
            myFlow.start();
        }
    }

    //update seat count related fields from the attachment to quote
    public static void updateQuoteRecord(Id quoteId, PT_PLG_Response_Model newPartsListWithHeader) {
        SBQQ__Quote__c updateQuote = new SBQQ__Quote__c();
        updateQuote.Id = quoteId;
        updateQuote.L2I_Economy_Cabin_Configuration__c = newPartsListWithHeader.economyClassSeatConfig;
        updateQuote.L2I_Economy_Class__c = newPartsListWithHeader.economyClassSeatCount;
        updateQuote.L2I_Premium_Economy_Cabin_Configuration__c = newPartsListWithHeader.premiumEconomySeatConfig;
        updateQuote.L2I_Premium_Economy_Class__c = newPartsListWithHeader.premiumEconomySeatCount;
        updateQuote.L2I_Business_Class_Cabin_Configuration__c = newPartsListWithHeader.businessClassSeatConfig;
        updateQuote.L2I_Business_Class__c = newPartsListWithHeader.businessClassSeatCount;
        updateQuote.L2I_First_Class_Cabin_Configuration__c = newPartsListWithHeader.firstClassSeatConfig;
        updateQuote.L2I_First_Class__c = newPartsListWithHeader.firstClassSeatCount;
        updateQuote.L2I_OFAR_Cabin_Configuration__c = newPartsListWithHeader.ofarSeatConfig;
        updateQuote.L2I_OFAR_Seat_Count__c = newPartsListWithHeader.ofarSeatCount;
        updateQuote.L2I_OFCR_Cabin_Configuration__c = newPartsListWithHeader.ofcrSeatConfig;
        updateQuote.L2I_OFCR_Seat_Count__c = newPartsListWithHeader.ofcrSeatCount;
        updateQuote.L2I_Crew_Rest_Cabin_Configuration__c = newPartsListWithHeader.crewRestSeatConfig;
        updateQuote.L2I_Crew_Rest_Seat_Count__c = newPartsListWithHeader.crewRestSeatCount;
        updateQuote.L2I_Flight_Deck_Cabin_Configuration__c = newPartsListWithHeader.flightDeckSeatConfig;
        updateQuote.L2I_Flight_Deck_Seat_Count__c = newPartsListWithHeader.flightDeckSeatCount;
        updateQuote.SBQQ__LineItemsGrouped__c = true;
        update updateQuote;
    }

    // Add, Update & Delete the Part List into Quote Lines.
    public static void processPartLists(Id quoteId, List<PT_PLG_Response_Model.QuoteLines> newPartsList) {
        List<SBQQ__QuoteLine__c> oldPartsList = [SELECT Id, PT_Proposed_Part_Code__c, SBQQ__Product__r.ProductCode, SBQQ__Quantity__c, SBQQ__Group__r.Name
                                                FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.Id = :quoteId];
        //Create Map for old part list (Combination of Porduct Code + Group Name as key and Quote Line as value)
        Map<String, SBQQ__QuoteLine__c> oldPartsMap = new  Map<String, SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c oldpart : oldPartsList) {
            if (oldpart.SBQQ__Product__r.ProductCode == 'IFE MISCELLANEOUS') {
                oldPartsMap.put (oldpart.PT_Proposed_Part_Code__c + oldpart.SBQQ__Group__r.Name, oldpart);
            } else {
                oldPartsMap.put (oldpart.SBQQ__Product__r.ProductCode + oldpart.SBQQ__Group__r.Name, oldpart);
            }
        }
        //Create Map for new part list (Combination of product Code + Group Name as key and Part List as value)
        List<String> installLocations = new List<String>();
        Set<String> products = new Set<String>();
        Map<String, PT_PLG_Response_Model.QuoteLines> newPartsMap = new  Map<String, PT_PLG_Response_Model.QuoteLines>();
        for (PT_PLG_Response_Model.QuoteLines newpart : newPartsList) {
            newPartsMap.put (newpart.partNumber + newpart.installLocation, newpart);
            if (!installLocations.contains(newpart.installLocation)) {
                installLocations.add(newpart.installLocation);
            }
            products.add(newpart.partNumber);
        }

        // Create quote line group if it does not exist
        List<SBQQ__QuoteLineGroup__c> prodGroupLst = createQuoteLineGroupRecords(installLocations, quoteId);

        // Update or delete part lists after comparing the old and new part list
        List<SBQQ__QuoteLine__c> deletePartsList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> updatePartsList = new List<SBQQ__QuoteLine__c>();
        for (String key : oldPartsMap.keySet()) {
            if(newPartsMap.get(key) != null) {
                if (oldPartsMap.get(key).SBQQ__Quantity__c != newPartsMap.get(key).quantity && newPartsMap.get(key).quantity != null) {
                    SBQQ__QuoteLine__c updatePart = oldPartsMap.get(key);
                    updatePart.SBQQ__Quantity__c = newPartsMap.get(key).quantity;
                    updatePartsList.add(updatePart);
                }
            }
            else if(newPartsMap.containsKey(key) == false) {
                deletePartsList.add(oldPartsMap.get(key));
            }
        }

        //Create Map for Group Name Id and Product Name Id.
        List<Product2> prodLst = [SELECT Id, ProductCode, SBQQ__CostEditable__c , SBQQ__PriceEditable__c FROM Product2
                                    WHERE ProductCode IN :products OR ProductCode = 'IFE MISCELLANEOUS'];
        Map<String, Id> groupNameIdMap = new  Map<String, Id>();
        Map<String, Id> productNameIdMap = new  Map<String, Id>();
        Map<String, Product2> productMap = new Map<String, Product2>(); // Added by Alvin for W-004223

        for (SBQQ__QuoteLineGroup__c grp : prodGroupLst) {
            groupNameIdMap.put(grp.Name, grp.Id);
        }
        for(Product2 prod : prodLst){
            productNameIdMap.put(prod.ProductCode, prod.Id);
            productIds.add(prod.Id);
            productMap.put(prod.Id, prod); // Added by Alvin for W-004223
        }
        Map<Id,PricebookEntry> pbeProductMap = getPBEProductMap();
        // Add part lists after comparing the old and new part list
        List<SBQQ__QuoteLine__c> addPartsList = new List<SBQQ__QuoteLine__c>();
        for (String key : newPartsMap.keySet()) {
            if (oldPartsMap.isEmpty() || oldPartsMap.containsKey(key) == false) {
                PT_PLG_Response_Model.QuoteLines newPart = newPartsMap.get(key);
                SBQQ__QuoteLine__c addPart = new SBQQ__QuoteLine__c();
                ID prodId;
                if (
                    productNameIdMap.get(newPart.partNumber) != null
                    && newPart.partNumber != 'IFE MISCELLANEOUS' // Added by Khrisna for W-004018
                ) {
                    prodId = productNameIdMap.get(newPart.partNumber);
                } else {
                    addPart.PT_Proposed_Part_Code__c = newPart.ProposedPartCode != null ? newPart.ProposedPartCode : newPart.partNumber; // Modified by Khrisna for W-004018
                    addPart.PT_Proposed_Part_Nomenclature__c = newPart.Nomenclature;
                    prodId = productNameIdMap.get('IFE MISCELLANEOUS');
                }
                addPart.SBQQ__Product__c = prodId;
                addPart.SBQQ__Group__c = groupNameIdMap.get(newPart.installLocation);
                if (newPart.quantity != null) {
                    addPart.SBQQ__Quantity__c = newPart.quantity;
                } else {
                    addPart.SBQQ__Quantity__c = 1;
                }
                addPart.SBQQ__Quote__c = quoteId;
                addPart.L2I_CPQMultiplier__c = pbeProductMap.get(prodId) != null ? (pbeProductMap.get(prodId)).Product2.L2I_CPQMultiplier__c : null;
                addPart.SBQQ__ListPrice__c = pbeProductMap.get(prodId) != null ? (pbeProductMap.get(prodId)).UnitPrice : null;
                addPart.SBQQ__PricebookEntryId__c = pbeProductMap.get(prodId) != null ? (pbeProductMap.get(prodId)).Id : null;
                addPart.SBQQ__CostEditable__c = productMap.get(prodId) != null ? (productMap.get(prodId)).SBQQ__CostEditable__c : FALSE; // Added by Alvin for W-004223
                addPart.SBQQ__PriceEditable__c = productMap.get(prodId) != null ? (productMap.get(prodId)).SBQQ__PriceEditable__c : FALSE; // Added by Alvin  for W-004223
                // addPart.PT_Proposed_Part_Code__c = newPart.ProposedPartCode; // Added by Lipton for W-003682 // Commented by Khrisna for W-004018
                addPartsList.add(addPart);
            }
        }
        if (deletePartsList.size() > 0) {
            Database.delete(deletePartsList, false);
        }
        if (addPartsList.size() > 0) {
            Database.insert(addPartsList, false);
        }
        if (updatePartsList.size() > 0) {
            Database.update(updatePartsList, false);
        }
    }

    public static Map<Id,PricebookEntry> getPBEProductMap() {
        Id priceBookId;
        Map<Id,PricebookEntry> pbeProdMap = new Map<Id,PricebookEntry>();
        for (PriceBookEntry pbe: [SELECT Id, Name, IsActive, UnitPrice, L2I_PART_DESCRIPTION__c, ProductCode, Product2Id, Product2.L2I_CPQMultiplier__c, UseStandardPrice
                                    FROM PriceBookEntry
                                    WHERE Product2Id IN :productIds
                                    AND Pricebook2Id = :priceBookId]) {
            pbeProdMap.put(pbe.Product2Id, pbe);
        }
        return pbeProdMap;
    }

    // Create quote line group if it does not exist and preservce the quote group order as per part list response
    public static List<SBQQ__QuoteLineGroup__c> createQuoteLineGroupRecords(List<String> installLocations, Id quoteId) {
        Id accId = [SELECT SBQQ__Account__c FROM SBQQ__Quote__c WHERE Id = :quoteId][0].SBQQ__Account__c;
        Map<String,SBQQ__QuoteLineGroup__c> quoteGroupMap = new Map<String,SBQQ__QuoteLineGroup__c>();
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupList = [SELECT Id, Name, SBQQ__Number__c, SBQQ__SolutionGroup__c, SBQQ__SolutionGroup__r.Name, SBQQ__Quote__c FROM SBQQ__QuoteLineGroup__c
                                                            WHERE SBQQ__Quote__c = :quoteId
                                                            ORDER BY SBQQ__Number__c Desc];
        for (SBQQ__QuoteLineGroup__c qlg : quoteLineGroupList) {
            if (qlg.SBQQ__SolutionGroup__c != null) {
            quoteGroupMap.put(qlg.SBQQ__SolutionGroup__r.Name, qlg);
            } else {
                quoteGroupMap.put(qlg.Name, qlg);
            }
        }
        //Create quote line group if it does not exist
        List<SBQQ__QuoteLineGroup__c> newQuoteLineGroupList = new List<SBQQ__QuoteLineGroup__c>();
        List<String> tempGroups = installLocations.clone();
        for (SBQQ__SolutionGroup__c g : [SELECT Id, Name, SBQQ__Description__c FROM SBQQ__SolutionGroup__c WHERE Name IN :installLocations]) {
            if (tempGroups.indexOf(g.Name) != -1) {
                tempGroups.remove(tempGroups.indexOf(g.Name));
            }
            if (quoteGroupMap.get(g.Name) == null) {
                SBQQ__QuoteLineGroup__c qlgNew = new SBQQ__QuoteLineGroup__c();
                qlgNew.SBQQ__Quote__c = quoteId;
                qlgNew.SBQQ__SolutionGroup__c = g.Id;
                qlgNew.Name = g.Name;
                qlgNew.SBQQ__Description__c = g.SBQQ__Description__c;
                qlgNew.SBQQ__ListTotal__c = 0.0;
                qlgNew.SBQQ__CustomerTotal__c = 0.0;
                qlgNew.SBQQ__NetTotal__c = 0.0;
                qlgNew.SBQQ__Account__c = accId;
                newQuoteLineGroupList.add(qlgNew);
            }
        }
        //create quote groups if solution groups are not available.
        for (String tmp : tempGroups) {
            if(quoteGroupMap.get(tmp) == null) {
                SBQQ__QuoteLineGroup__c qlgNew = new SBQQ__QuoteLineGroup__c();
                qlgNew.SBQQ__Quote__c = quoteId;
                qlgNew.Name = tmp;
                qlgNew.SBQQ__ListTotal__c = 0.0;
                qlgNew.SBQQ__CustomerTotal__c = 0.0;
                qlgNew.SBQQ__NetTotal__c = 0.0;
                qlgNew.SBQQ__Account__c = accId;
                newQuoteLineGroupList.add(qlgNew);
            }
        }
        quoteLineGroupList.addAll(newQuoteLineGroupList);
        //Preserve the quote group order as per part list response. If group is not part of response, then move it to bottom.
        Integer resequence = installLocations.size() + 1;
        for (SBQQ__QuoteLineGroup__c qlg : quoteLineGroupList) {
            if (installLocations.contains(qlg.Name)) {
                qlg.SBQQ__Number__c = installLocations.indexOf(qlg.Name) + 1;
            } else {
                qlg.SBQQ__Number__c = resequence;
                resequence++;
            }
        }
        Database.upsert(quoteLineGroupList, false);
        return quoteLineGroupList;
    }

    /**
    * This method gets the VersionData of an uploaded Excel File (used in pt_CPLExcelReader LWC) [Added for W-004382]
    * param       cvId  Id of the Content Version file
    * return      base64 Encoded String of VersionData
    */
    @AuraEnabled
    public static String getContentVersionData(String cvId) {
        List<ContentVersion> cv = [SELECT VersionData 
                                     FROM ContentVersion 
                                    WHERE Id = :cvId 
                                      AND IsLatest = true
                                    LIMIT 1
        ];
        return EncodingUtil.base64Encode(cv[0].VersionData);
    }

    /**
    * This method processes the parts list from an uploaded Excel file (used in pt_CPLExcelReader LWC) [Added for W-004382]
    * param       quoteId - Id of the Quote where the uploaded file is attached
    *             fileBodyStr - JSON String of data from an Excel sheet
    * return      
    */
    @AuraEnabled
    public static void processPartListExcelContent(Id quoteId, String fileBodyStr) {
        // based on PT_PLG_Response_Model.QuoteLines properties
        String installLocation = 'InstallLocation';
        String nomenclature = 'Nomenclature';
        String partNumber = 'PartNumber';
        String quantity = 'Quantity';

        // replace Excel Column Headers with its respective mapping in PT_PLG_Response_Model
        fileBodyStr = fileBodyStr.replace('Install Location', installLocation);
        fileBodyStr = fileBodyStr.replace('Description', nomenclature);
        fileBodyStr = fileBodyStr.replace('Part #', partNumber);
        fileBodyStr = fileBodyStr.replace('Purchase Qty', quantity);
        // return an error if the required column headers are not found on the excel file
        if (!fileBodyStr.contains(installLocation) 
            || !fileBodyStr.contains(nomenclature) 
            || !fileBodyStr.contains(partNumber) 
            || !fileBodyStr.contains(quantity)) {
                throw new AuraHandledException('Unable to process file due to incorrect parts list template format.');
        } else {
            // add "quotelines:" to JSON string to meet the PT_PLG_Response_Model format
            fileBodyStr = '{ \"quotelines\": ' + fileBodyStr +'}';
            System.debug('fileBodyStr: ' + fileBodyStr);

            try {
                PT_PLG_Response_Model response = new PT_PLG_Response_Model();
                PT_PLG_Response_Model newPartsListWithHeader = response.parsePartsListFromJSON(fileBodyStr);
                List<PT_PLG_Response_Model.QuoteLines> newPartsList = newPartsListWithHeader.quoteLines;
                System.debug('newPartsListWithHeader==> ' + newPartsListWithHeader);
                System.debug('newPartsList==> ' + newPartsList);
                updateQuoteRecord(quoteId, newPartsListWithHeader);
                processPartLists(quoteId, newPartsList);
                // Invoke flow for Calculating the Quote using CPQ API
                Map<String, Object> params = new Map<String, Object>();
                params.put('quoteId', quoteId);
                Flow.Interview.Calculate_Quote myFlow = new Flow.Interview.Calculate_Quote(params);
                myFlow.start();
            } catch (Exception e) {
                String errorMsg = e.getMessage();
                throw new AuraHandledException(errorMsg);
            }
        }
    }

    global class Requests {
        @InvocableVariable
        global Id quoteId;

        @InvocableVariable
        global String attachId;
    }
}