global class PT_ImportQuoteFromCPLOppty {
    @InvocableMethod(label='Import CPL Opportunity'
        description='Process to Import CPL Opportunity to a Quote')
    public static void processCPLImport (List<Requests> requests) {
        PT_PLG_Response_Model plgJSON = new PT_PLG_Response_Model();
        if (requests[0].quoteId != null && requests[0].opptyId != null) {
            //Get the Destination Quote Record Details
            SBQQ__Quote__c quoteRec = [SELECT Id, ApprovalStatus__c
                                        FROM SBQQ__Quote__c WHERE Id = :requests[0].quoteId];
            //Get the Source Opprtunity Record Details
            Opportunity oppty = [SELECT Id, SBQQ__PrimaryQuote__c FROM Opportunity WHERE Id = :requests[0].opptyId];
            //Get the Source Quite and Quote Lines Record Details
            SBQQ__Quote__c quoteWithQLs = [SELECT Id,
                                            L2I_Economy_Cabin_Configuration__c, L2I_Economy_Class__c,
                                            L2I_Premium_Economy_Cabin_Configuration__c, L2I_Premium_Economy_Class__c,
                                            L2I_Business_Class_Cabin_Configuration__c, L2I_Business_Class__c,
                                            L2I_First_Class_Cabin_Configuration__c, L2I_First_Class__c,
                                            L2I_OFAR_Cabin_Configuration__c, L2I_OFAR_Seat_Count__c,
                                            L2I_OFCR_Cabin_Configuration__c, L2I_OFCR_Seat_Count__c,
                                            L2I_Crew_Rest_Cabin_Configuration__c, L2I_Crew_Rest_Seat_Count__c,
                                            L2I_Flight_Deck_Cabin_Configuration__c, L2I_Flight_Deck_Seat_Count__c,
                                                (SELECT Id, PT_Proposed_Part_Nomenclature__c,
                                                SBQQ__Product__r.ProductCode, SBQQ__Quantity__c, SBQQ__Group__r.Name,
                                                PT_Proposed_Part_Code__c // Added by Lipton for W-003682
                                                FROM SBQQ__LineItems__r)
                                            FROM SBQQ__Quote__c
                                            WHERE Id = :oppty.SBQQ__PrimaryQuote__c];

            Boolean isQuoteApproved = quoteRec.ApprovalStatus__c == 'Approved' ? true : false;
            // If destination quote is approve, do revise.
            if (isQuoteApproved) {
                PT_PLG_Invoke_Revise.Requests req = new PT_PLG_Invoke_Revise.Requests();
                req.quoteobj = requests[0].quoteId;
                List<PT_PLG_Invoke_Revise.Results> resp = PT_PLG_Invoke_Revise.ProcessPartsList(new List<PT_PLG_Invoke_Revise.Requests>{req});
                plgJSON = getPLGJSON(resp[0].quotes[0].Id, quoteWithQLs);
            } else {
                plgJSON = getPLGJSON(requests[0].quoteId, quoteWithQLs);
            }
            // Insert attachment with CPL Quote and Quote Lines into the Destination Quote
            Attachment att = new Attachment();
    	    att.Name = 'CPL_Import_' + requests[0].quoteId + '.txt';
    	    Blob bodyBlob = Blob.valueOf(JSON.serialize(plgJSON));
    	    att.body = bodyBlob;
            att.parentId = requests[0].quoteId;
            insert att;

            //Publish an event to consume the above attachment and replicate the quote lines from source to destination.
            List<Parts_List__e> addEvents = new List<Parts_List__e>();
            Parts_List__e event = new Parts_List__e();
            event.Quote_Id__c = requests[0].quoteId;
            event.Attachment_Id__c = att.Id;
            addEvents.add(event);
            if (addEvents.size() > 0) {
                List<Database.SaveResult> results = EventBus.publish(addEvents);
            }
        }
    }
    // Parse Source Quote and Quote Lines into PT_PLG_Response_Model Wrapper class
    public static PT_PLG_Response_Model getPLGJSON (Id quoteId, SBQQ__Quote__c quoteWithQLs) {
        PT_PLG_Response_Model response = new PT_PLG_Response_Model();
        response.economyClassSeatConfig = quoteWithQLs.L2I_Economy_Cabin_Configuration__c != null ? quoteWithQLs.L2I_Economy_Cabin_Configuration__c : '';
        response.economyClassSeatCount = Integer.valueOf(quoteWithQLs.L2I_Economy_Class__c) > 0 ? Integer.valueOf(quoteWithQLs.L2I_Economy_Class__c) : 0;
        response.premiumEconomySeatConfig = quoteWithQLs.L2I_Premium_Economy_Cabin_Configuration__c != null ? quoteWithQLs.L2I_Premium_Economy_Cabin_Configuration__c : '';
        response.premiumEconomySeatCount = Integer.valueOf(quoteWithQLs.L2I_Premium_Economy_Class__c) > 0 ? Integer.valueOf(quoteWithQLs.L2I_Premium_Economy_Class__c) : 0;
        response.businessClassSeatConfig = quoteWithQLs.L2I_Business_Class_Cabin_Configuration__c != null ? quoteWithQLs.L2I_Business_Class_Cabin_Configuration__c : '';
        response.businessClassSeatCount = Integer.valueOf(quoteWithQLs.L2I_Business_Class__c) > 0 ? Integer.valueOf(quoteWithQLs.L2I_Business_Class__c) : 0;
        response.firstClassSeatConfig = quoteWithQLs.L2I_First_Class_Cabin_Configuration__c != null ? quoteWithQLs.L2I_First_Class_Cabin_Configuration__c : '';
        response.firstClassSeatCount = Integer.valueOf(quoteWithQLs.L2I_First_Class__c) > 0 ? Integer.valueOf(quoteWithQLs.L2I_First_Class__c) : 0;
        response.ofarSeatConfig = quoteWithQLs.L2I_OFAR_Cabin_Configuration__c != null ? quoteWithQLs.L2I_OFAR_Cabin_Configuration__c : '';
        response.ofarSeatCount = Integer.valueOf(quoteWithQLs.L2I_OFAR_Seat_Count__c) > 0 ? Integer.valueOf(quoteWithQLs.L2I_OFAR_Seat_Count__c) : 0;
        response.ofcrSeatConfig = quoteWithQLs.L2I_OFCR_Cabin_Configuration__c != null ? quoteWithQLs.L2I_OFCR_Cabin_Configuration__c : '';
        response.ofcrSeatCount  = Integer.valueOf(quoteWithQLs.L2I_OFCR_Seat_Count__c) > 0 ? Integer.valueOf(quoteWithQLs.L2I_OFCR_Seat_Count__c) : 0;
        response.crewRestSeatConfig = quoteWithQLs.L2I_Crew_Rest_Cabin_Configuration__c != null ? quoteWithQLs.L2I_Crew_Rest_Cabin_Configuration__c : '';
        response.crewRestSeatCount = Integer.valueOf(quoteWithQLs.L2I_Crew_Rest_Seat_Count__c) > 0 ? Integer.valueOf(quoteWithQLs.L2I_Crew_Rest_Seat_Count__c) : 0;
        response.flightDeckSeatConfig = quoteWithQLs.L2I_Flight_Deck_Cabin_Configuration__c != null ? quoteWithQLs.L2I_Flight_Deck_Cabin_Configuration__c : '';
        response.flightDeckSeatCount = Integer.valueOf(quoteWithQLs.L2I_Flight_Deck_Seat_Count__c) > 0 ? Integer.valueOf(quoteWithQLs.L2I_Flight_Deck_Seat_Count__c) : 0;

        List<PT_PLG_Response_Model.QuoteLines> quoteLines = new List<PT_PLG_Response_Model.QuoteLines>();
        for (SBQQ__QuoteLine__c ql : quoteWithQLs.SBQQ__LineItems__r) {
            PT_PLG_Response_Model.QuoteLines importQuoteLine = new PT_PLG_Response_Model.QuoteLines();
            importQuoteLine.InstallLocation = ql.SBQQ__Group__r.Name;
            importQuoteLine.PartNumber = ql.SBQQ__Product__r.ProductCode;
            importQuoteLine.Nomenclature = ql.PT_Proposed_Part_Nomenclature__c != null ? ql.PT_Proposed_Part_Nomenclature__c : '';
            importQuoteLine.Quantity = Integer.valueOf(ql.SBQQ__Quantity__c) > 0 ? Integer.valueOf(ql.SBQQ__Quantity__c) : 0;
            importQuoteLine.ProposedPartCode = ql.PT_Proposed_Part_Code__c;
            quoteLines.add(importQuoteLine);
        }
        response.QuoteLines = quoteLines;

        return response;
    }

    global class Requests {
        @InvocableVariable
        global Id quoteId;

        @InvocableVariable
        global Id opptyId;
    }
}