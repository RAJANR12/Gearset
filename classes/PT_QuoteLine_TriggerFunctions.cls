/**
 *  @author       Sarah Kennedy
 *  @date         10/13/2020
 *  @description  PT_QuoteLine_TriggerFunctions
 *
 *  Modification Log:
 *  ------------------------------------------------------------------------------------
 *  Developer                       Date                Description
 *  ------------------------------------------------------------------------------------
 *  Sarah Kennedy                 10/13/2020         Initial scaffold
 *
 */
public without sharing class PT_QuoteLine_TriggerFunctions {

    public static Id salesTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
    public static Id pplTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PPL').getRecordTypeId();

    public static void validationDeliveryStageOppty(List<SBQQ__QuoteLine__c> newQuoteLineList) {
        Set<Id> quoteIds = new Set<Id>();
        for (SBQQ__QuoteLine__c ql : newQuoteLineList){
            quoteIds.add(ql.SBQQ__Quote__c);
        }

        Map<Id, SBQQ__Quote__c> quotesMap = new Map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__Opportunity2__r.RecordTypeId,
                                                                                        SBQQ__Opportunity2__r.StageName
                                                                                        FROM SBQQ__Quote__c
                                                                                        WHERE Id IN :quoteIds AND SBQQ__Opportunity2__r.StageName = 'Delivery']);

        for (SBQQ__QuoteLine__c ql : newQuoteLineList){
            if (quotesMap.containsKey(ql.SBQQ__Quote__c)){
                if ((quotesMap.get(ql.SBQQ__Quote__c).SBQQ__Opportunity2__r.RecordTypeId == salesTypeId ||
                    quotesMap.get(ql.SBQQ__Quote__c).SBQQ__Opportunity2__r.RecordTypeId == pplTypeId) &&
                    quotesMap.get(ql.SBQQ__Quote__c).SBQQ__Opportunity2__r.StageName == 'Delivery' &&
                    ql.PT_Asset__c == null) {
                    ql.addError('Quote lines without Asset cannot be added when Oppotunity is in Delivery stage');
                }
            }
        }
    }

    public static void validationAssetStatusNotDeleted(List<SBQQ__QuoteLine__c> oldQuoteLineList) {
        Map<Id, SBQQ__QuoteLine__c> quoteLinesMap = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, PT_Asset__r.PT_Status__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.RecordTypeId,
                                                                                        SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName
                                                                                        FROM SBQQ__QuoteLine__c
                                                                                        WHERE Id IN :oldQuoteLineList]);

        for (SBQQ__QuoteLine__c ql : oldQuoteLineList){
            if (quoteLinesMap.containsKey(ql.Id) && quoteLinesMap.get(ql.Id).PT_Asset__c != null){
                if ((quoteLinesMap.get(ql.Id).SBQQ__Quote__r.SBQQ__Opportunity2__r.RecordTypeId == salesTypeId ||
                        quoteLinesMap.get(ql.Id).SBQQ__Quote__r.SBQQ__Opportunity2__r.RecordTypeId == pplTypeId) &&
                        quoteLinesMap.get(ql.Id).SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName == 'Delivery' &&
                        quoteLinesMap.get(ql.Id).PT_Asset__r.PT_Status__c != 'Removed') {
                    ql.addError('Cannot Delete the QuoteLine with asset status not equal to Deleted.');
                }
            }
        }
    }

    /*
    * @author           Lipton Abillar
    * @date             08/03/2021
    * @workitem         W-003670
    * @description      Sync Unit Net Price of Qoute Lines and Price List Entry
    * @trigger          L2I_QuoteLine_TriggerHandler.afterUpdate()
    *
    * Developer:        Lipton Abillar      08/07/2021      Create
    */

    public static void syncQLandPLE(List<SBQQ__QuoteLine__c> newQuoteLineList, Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap) {
        Map<Id, PT_PriceList_Entry__c> pleToUpdate = new Map<Id, PT_PriceList_Entry__c>();

        for(SBQQ__QuoteLine__c ql : newQuoteLineList) {
            if (ql.PT_Price_List_Entry__c != null && ql.SBQQ__NetPrice__c != oldQuoteLineMap.get(ql.Id).SBQQ__NetPrice__c
                && !pleToUpdate.containsKey(ql.PT_Price_List_Entry__c)) {
                pleToUpdate.put(ql.PT_Price_List_Entry__c, new PT_PriceList_Entry__c(Id = ql.PT_Price_List_Entry__c, PT_UnitPrice__c = ql.SBQQ__NetPrice__c));
            }
        }

        if (!pleToUpdate.isEmpty()) {
            update pleToUpdate.values();
        }
    }

    /*
    * @author           Lipton Abillar
    * @date             10/29/2021
    * @workitem         W-004027
    * @description      Validate quote lines to ensure PPL part numbers are not listed in CPL install locations
    * @trigger          L2I_QuoteLine_TriggerHandler.beforeInsert()
    *
    * Developer:        Lipton Abillar      10/29/2021      Create
    */
    public static void validatePartNumbers(List<SBQQ__QuoteLine__c> newQuoteLineList) {
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> qlgIds = new Set<Id>();

        for (SBQQ__QuoteLine__c ql : newQuoteLineList){
            if (ql.SBQQ__Quote__c != null) {
                quoteIds.add(ql.SBQQ__Quote__c);
            }
            if (ql.SBQQ__Product__c != null) {
                productIds.add(ql.SBQQ__Product__c);
            }
            if (ql.SBQQ__Group__c != null) {
                qlgIds.add(ql.SBQQ__Group__c);
            }
        }

        Map<Id, SBQQ__Quote__c> quotesMap = new Map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__Opportunity2__r.RecordTypeId,
                                                                                SBQQ__Opportunity2__r.L2I_Product_Category__c
                                                                        FROM SBQQ__Quote__c
                                                                        WHERE Id IN :quoteIds]);

        Map<Id, Product2> productsMap = new Map<Id, Product2>([SELECT Id, Name, L2I_CPL_PPL_Mapping__c, ProductCode, L2I_PMO_Install_Code__c, L2I_Category__c FROM Product2 WHERE Id IN :productIds]);

        Map<Id, SBQQ__QuoteLineGroup__c> groupMap = new Map<Id, SBQQ__QuoteLineGroup__c>([SELECT Id, Name, SBQQ__SolutionGroup__r.Name, SBQQ__SolutionGroup__r.Type__c FROM SBQQ__QuoteLineGroup__c WHERE Id IN :qlgIds]);

        SBQQ__Quote__c quote = null;
        Product2 product = null;
        SBQQ__QuoteLineGroup__c qlGroup = null;
        String qlGroupName = null;
        String qlGroupType = null;
        
        for (SBQQ__QuoteLine__c ql : newQuoteLineList){
            if (quotesMap.containsKey(ql.SBQQ__Quote__c) && productsMap.containsKey(ql.SBQQ__Product__c)){
                quote = quotesMap.get(ql.SBQQ__Quote__c);
                product = productsMap.get(ql.SBQQ__Product__c);
                qlGroup = groupMap.get(ql.SBQQ__Group__c);
                qlGroupName = qlGroup != null ? qlGroup.SBQQ__SolutionGroup__r.Name : '';
                qlGroupType = qlGroup != null ? qlGroup.SBQQ__SolutionGroup__r.Type__c : '';

                System.debug('#### Product: ' + product);
                System.debug('#### Group: ' + qlGroup);
                System.debug('#### Group Name: ' + qlGroupName);
                System.debug('#### Group Type: ' + qlGroupType);

                // Modified by Lipton for W-004403, W-004404, W-004395
                // IFEC Opportunity
                if (quote.SBQQ__Opportunity2__r.RecordTypeId == salesTypeId && quote.SBQQ__Opportunity2__r.L2I_Product_Category__c == 'IFEC') {
                    // Validation for AC Products
                    if (product.L2I_CPL_PPL_Mapping__c == 'AC' && product.ProductCode !='PLACEHOLDER-IFECCHANGEREQUEST-YYYY') {
                        // Validate first if the Product is in an AC installation group type
                        // If it is, check if the installation group name is correct based of PMO Install Code field
                        if (qlGroupType != 'AC') {
                            ql.addError('PPL part numbers cannot be added to ' + qlGroupName + ' install location. Product Code: ' + product.ProductCode);
                        } else if (product.L2I_PMO_Install_Code__c == null) { 
                            ql.addError('PMO Install Code on the product ' + product.Name + ' is missing.');
                        } else if(qlGroupName != product.L2I_PMO_Install_Code__c) {
                            ql.addError(product.Name + ' product must be placed in ' + product.L2I_PMO_Install_Code__c);
                        }
                    }
                    // Validation for Non-AC Products (Hardware poducts)
                    else {
                        // Check if Hardware products is added to an AC Installation code
                        if (qlGroupType == 'AC' && product.ProductCode !='PLACEHOLDER-IFECCHANGEREQUEST-YYYY' ) {
                            ql.addError('Hardware or DSS products cannot be added to ' + qlGroupName +' PPL installation location. Product Code: ' + product.ProductCode);
                        }
                        // Check if DSS products is added to an IFEC Opportunity
                        else if (product.L2I_Category__c == 'DSS') {
                            ql.addError('DSS products cannot be added to an IFEC quote. Product Code: ' + product.ProductCode);
                        }
                    }
                }
                // DSS Opportunity
                else if (quote.SBQQ__Opportunity2__r.RecordTypeId == salesTypeId && quote.SBQQ__Opportunity2__r.L2I_Product_Category__c == 'DSS') {
                    // Check if product is not DSS
                    if (product.L2I_Category__c == 'IFEC') {
                        ql.addError('IFEC products cannot be added to a DSS quote. Product Code: ' + product.ProductCode);
                    }
                }
            }
        }
    }

    // /*
    // * @author           Lipton Abillar
    // * @date             02/02/2022
    // * @workitem         W-004253 and W-004254
    // * @description      Prevent update if Quote is in Pending or Approved status
    // * @trigger          L2I_QuoteLine_TriggerHandler.beforeInsert()
    // *
    // * Developer:        Lipton Abillar      02/02/2022      Create
    // */
    // public static void validateQuoteStatus(List<SBQQ__QuoteLine__c> newQuoteLineList) {
    //     Set<Id> quotesId = new Set<Id>();
    //     set<Id> invalidQuotes = new Set<Id>();
    //     for (SBQQ__QuoteLine__c ql : newQuoteLineList) {
    //         if (ql.SBQQ__Quote__c != null) {
    //             quotesId.add(ql.SBQQ__Quote__c);
    //         }
    //     }

    //     if (!quotesId.isEmpty()) {
    //         Id sysAdProfileId = L2I_StaticConstants.getProfileByName('System Administrator').Id;
    //         for (SBQQ__Quote__c quote : [SELECT Id, ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id IN :quotesId]) {
    //             if ((quote.ApprovalStatus__c == 'Pending' || quote.ApprovalStatus__c == 'Approved') && 
    //                 sysAdProfileId != UserInfo.getProfileId()) {
    //                     invalidQuotes.add(quote.Id);
    //             }
    //         }

    //         if (!invalidQuotes.isEmpty()) {
    //             for (SBQQ__QuoteLine__c ql : newQuoteLineList) {
    //                 if (invalidQuotes.contains(ql.SBQQ__Quote__c)) {
    //                     ql.addError('You can not edit Quote Line if the Quote is in Approved or Submitted For Approval.');
    //                 }
    //             }
    //         }
    //     }
    // }

//    public static void addSolGroupToQLGroup(List<SBQQ__QuoteLine__c> newQuoteLineList,
//          Map<Id, SBQQ__QuoteLine__c> newQuoteLineMap,
//          Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap) {
//        // process selected Solution Group values on QuoteLines and create QuoteLineGroups if needed
//        System.debug('====== Executing PT_QuoteLine_TriggerFunctions::addSolGroupToQLGroup');
//
//        Set<Id> quoteIds = new Set<Id>();
//        Set<Id> quoteIFECIds = new Set<Id>();
//        List<SBQQ__QuoteLineGroup__c> newQLGList = new List<SBQQ__QuoteLineGroup__c>();
//        Map<Id, List<SBQQ__QuoteLineGroup__c>> quoteQLGroupsMap = new Map<Id, List<SBQQ__QuoteLineGroup__c>>();
//        Map<Id, SBQQ__SolutionGroup__c> sgMap = new Map<Id, SBQQ__SolutionGroup__c>();
//        Map<Id, Id> quoteAcctMap = new Map<Id, Id>();
//        Map<Id, Decimal> quoteNumMap = new Map<Id, Decimal>();
//        List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
//
//        for (SBQQ__QuoteLine__c qitem : newQuoteLineList) {
//            if (qitem.PT_Solution_Group_Parent__c != null) {
//                quoteIds.add(qitem.SBQQ__Quote__c);
//            }
//        }
//        for (SBQQ__Quote__c qt : [
//              SELECT Id, SBQQ__Account__c, L2I_Opportunity_Product_Category_Value__c,
//                    SBQQ__Opportunity2__r.RecordType.DeveloperName, SBQQ__Opportunity2__r.PT_Is_CPL__c
//              FROM SBQQ__Quote__c
//              WHERE Id IN :quoteIds
//              AND SBQQ__Opportunity2__r.PT_Is_CPL__c = true
//        ]) {
//            quoteIFECIds.add(qt.Id);
//            quoteAcctMap.put(qt.Id, qt.SBQQ__Account__c);
//        }
//        for (SBQQ__QuoteLine__c qitem : newQuoteLineList) {
//            System.debug('*** qitem ' + qitem);
//            if (quoteIFECIds.contains(qitem.SBQQ__Quote__c)) {
//                qitem.SBQQ__Product__c = qitem.PT_Hardware_Product__c;
//                qitem.L2I_Category__c = 'IFEC';
//                if (qitem.SBQQ__Quantity__c == null ||
//                      qitem.SBQQ__Quantity__c == 0) {
//                    qitem.SBQQ__Quantity__c = 1;
//                }
//            }
//        }
//        System.debug('*** quoteIFECIds ' + quoteIFECIds);
//
//        for (SBQQ__SolutionGroup__c sg : [
//              SELECT Id, Name, SBQQ__Description__c
//              FROM SBQQ__SolutionGroup__c
//        ]) {
//            sgMap.put(sg.Id, sg);
//        }
//        System.debug('*** sgMap ' + sgMap);
//
//        if (!quoteIFECIds.isEmpty()) {
//
//            qlgList = [
//                  SELECT Id,
//                        Name,
//                        SBQQ__Account__c,
//                        SBQQ__CustomerTotal__c,
//                        SBQQ__Description__c,
//                        SBQQ__ListTotal__c,
//                        SBQQ__NetTotal__c,
//                        SBQQ__Number__c,
//                        SBQQ__Quote__c,
//                        SBQQ__SolutionGroup__c
//                  FROM SBQQ__QuoteLineGroup__c
//                  WHERE SBQQ__Quote__c IN :quoteIFECIds
//                  ORDER BY SBQQ__Quote__c, SBQQ__Number__c
//            ];
//            System.debug('*** qlgList ' + qlgList);
//            System.debug('*** qlgList.size() ' + qlgList.size());
//
//            for (SBQQ__QuoteLineGroup__c qlg : qlgList) {
//                System.debug('*** qlg ' + qlg);
//                quoteNumMap.put(qlg.SBQQ__Quote__c, qlg.SBQQ__Number__c);   // will end up with the highest number
//                if (qlg.SBQQ__SolutionGroup__c != null) {
//                    if (!quoteQLGroupsMap.containsKey(qlg.SBQQ__Quote__c)) {
//                        quoteQLGroupsMap.put(qlg.SBQQ__Quote__c, new List<SBQQ__QuoteLineGroup__c>());
//                    }
//                    List<SBQQ__QuoteLineGroup__c> tempqlg = quoteQLGroupsMap.get(qlg.SBQQ__Quote__c);
//                    tempqlg.add(qlg);
//                    quoteQLGroupsMap.put(qlg.SBQQ__Quote__c, tempqlg);
//                }
//            }
//            System.debug('*** quoteQLGroupsMap ' + quoteQLGroupsMap);
//
//            for (SBQQ__QuoteLine__c qline : newQuoteLineList) {
//                if (quoteIFECIds.contains(qline.SBQQ__Quote__c)) {
//                    // does the selected Solution Group exist in the QuoteLinesGroup
//                    Boolean foundQLG = false;
//                    if (!quoteQLGroupsMap.isEmpty()) {
//                        for (SBQQ__QuoteLineGroup__c qlg : quoteQLGroupsMap.get(qline.SBQQ__Quote__c)) {
//                            System.debug('*** qlg ' + qlg);
//                            if (qlg.SBQQ__SolutionGroup__c == qline.PT_Solution_Group_Parent__c) {
//                                foundQLG = true;
//                                // set quotelinegroup
//                                //qline.SBQQ__Group__c = qlg.Id;
//                                System.debug('*** foundQLG qline ' + qline);
//                                break;
//                            }
//                        }
//                    }
//                    if (!foundQLG &&
//                          !sgMap.isEmpty()) {
//                        // create new QuoteLineGroup
//                        SBQQ__SolutionGroup__c sg = sgMap.get(qline.PT_Solution_Group_Parent__c);
//                        System.debug('*** qline.PT_Solution_Group_Parent__c ' + qline.PT_Solution_Group_Parent__c);
//                        System.debug('*** sg ' + sg);
//                        SBQQ__QuoteLineGroup__c newQLG = new SBQQ__QuoteLineGroup__c(
//                              Name = sg.Name,
//                              SBQQ__Account__c = quoteAcctMap.get(qline.SBQQ__Quote__c),
//                              SBQQ__CustomerTotal__c = 0,
//                              SBQQ__Description__c = sg.SBQQ__Description__c,
//                              SBQQ__ListTotal__c = 0,
//                              SBQQ__NetTotal__c = 0,
//                              SBQQ__Number__c = quoteNumMap == null || quoteNumMap.get(qline.SBQQ__Quote__c) == null ? 1 : quoteNumMap.get(qline.SBQQ__Quote__c) + 1,
//                              SBQQ__Quote__c = qline.SBQQ__Quote__c,
//                              SBQQ__SolutionGroup__c = sg.Id
//                        );
//                        newQLGList.add(newQLG);
//                        System.debug('*** newQLG ' + newQLG);
//                    }
//                }
//            }
//
//            if (newQLGList.size() > 0) {
//                insert newQLGList;
//                for (SBQQ__QuoteLineGroup__c qlg : newQLGList) {
//                    qlgList.add(qlg);
//                }
//            }
//
//            for (SBQQ__QuoteLine__c qline : newQuoteLineList) {
//                if (quoteIFECIds.contains(qline.SBQQ__Quote__c)) {
//                    // does the selected Solution Group exist in the QuoteLinesGroup
//                    for (SBQQ__QuoteLineGroup__c qlg : qlgList) {
//                        if (qlg.SBQQ__SolutionGroup__c == qline.PT_Solution_Group_Parent__c) {
//                            // set quotelinegroup
//                            qline.SBQQ__Group__c = qlg.Id;
//                            break;
//                        }
//                    }
//                }
//            }
//        }
//        for (SBQQ__QuoteLine__c qline : newQuoteLineList) {
//            System.debug('*** qline.Name  ' + qline.Name);
//            System.debug('*** qline.PT_Hardware_Product__c  ' + qline.PT_Hardware_Product__c);
//            System.debug('*** qline.SBQQ__Product__c  ' + qline.SBQQ__Product__c);
//            System.debug('*** qline.PT_Solution_Group_Parent__c  ' + qline.PT_Solution_Group_Parent__c);
//            System.debug('*** qline.SBQQ__Group__c  ' + qline.SBQQ__Group__c);
//            System.debug('====== Finished Executing PT_QuoteLine_TriggerFunctions::addSolGroupToQLGroup');
//        }
//    }
}