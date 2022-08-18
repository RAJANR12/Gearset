@IsTest
private class L2I_CancelReplaceService_Test {
//    @IsTest
//    static void testActivatedOrderTerminate() {
//        L2I_DataFactory factory = new L2I_DataFactory();
//        factory.setupAccountThruContract(null, null, false);
//
//        Test.startTest();
//        Account acct = [SELECT Id FROM Account LIMIT 1];
//        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate, SBQQ__Contracted__c FROM Order LIMIT 1];
//        ord.L2I_Order_Process__c = 'Contract Management';
//        ord.Type = 'Renewal';
//        ord.Status = 'Activated';
//        update ord;
//        Date termDate = ord.EffectiveDate.addDays(-1);
//
//        Contract ctr = [
//              SELECT Id,
//                    AccountId,
//                    SBQQ__Order__c,
//                    SBQQ__Opportunity__c,
//                    SBQQ__Quote__c,
//                    Status,
//                    Pricebook2Id,
//                    CurrencyIsoCode,
//                    ContractTerm,
//                    StartDate,
//                    EndDate,
//                    SBQQ__PreserveBundleStructureUponRenewals__c,
//                    SBQQ__AmendmentRenewalBehavior__c,
//                    SBQQ__DefaultRenewalPartners__c,
//                    SBQQ__DefaultRenewalContactRoles__c
//              FROM Contract
//              LIMIT 1
//        ];
//        Opportunity oppty = [SELECT Id, SBQQ__RenewedContract__c FROM Opportunity WHERE Id = :ord.OpportunityId];
//        oppty.SBQQ__RenewedContract__c = ctr.Id;
//        update oppty;
//
//        OrderItem oItem = [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate, Order.Type, Order.Status, Order.OpportunityId, Order.Opportunity.SBQQ__RenewedContract__c, Order.L2I_Order_Process__c
//            FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c LIMIT 1];
//        oItem.ServiceDate = Date.Today();
//        update oItem;
//        System.debug('*** oItem.Order.Type ' + oItem.Order.Type);
//        System.debug('*** oItem.Order.Status ' + oItem.Order.Status);
//        System.debug('*** oItem.Order.OpportunityId ' + oItem.Order.OpportunityId);
//        System.debug('*** oItem.Order.Opportunity.SBQQ__RenewedContract__c ' + oItem.Order.Opportunity.SBQQ__RenewedContract__c);
//        System.debug('*** oItem.Order.L2I_Order_Process__c ' + oItem.Order.L2I_Order_Process__c);
//        System.debug('*** oItem.L2I_blng_MatchingId__c ' + oItem.L2I_blng_MatchingId__c);
//
//        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
//        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
//            SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
//            obj.SBQQ__Account__c = acct.Id;
//            obj.SBQQ__Product__c = oi.Product2Id;
//            obj.SBQQ__Contract__c = ctr.Id;
//            obj.SBQQ__Quantity__c = 10.00;
//            obj.SBQQ__ProductSubscriptionType__c = 'Renewable';
//            obj.SBQQ__SubscriptionType__c = 'Renewable';
//            obj.SBQQ__OrderProduct__c = oi.Id;
//            obj.L2I_blng_MatchingId__c = oi.L2I_blng_MatchingId__c;
//            subList.add(obj);
//        }
//        insert subList;
//
//        oppty.SBQQ__RenewedContract__c = ctr.Id;
//        update oppty;
//        ord.Status = 'Activated';
//        ord.Type = 'Renewal';
//        ord.OpportunityId = oppty.Id;
//        ord.EffectiveDate = Date.Today();
//        update ord;
//
//        L2I_CancelReplaceService.cancelPrior(new Set<Id>{
//              ctr.Id
//        });
//        Test.stopTest();
//
//        System.assertEquals(1, [SELECT COUNT() FROM SBQQ__Subscription__c WHERE SBQQ__TerminatedDate__c = :termDate]);
//        System.assertEquals(1, [SELECT COUNT() FROM OrderItem WHERE SBQQ__TerminatedDate__c = :termDate]);
//    }
//
//    @IsTest
//    static void testActivatedOrderNoTerminate() {
//        L2I_DataFactory factory = new L2I_DataFactory();
//        factory.setupAccountThruContract(null, null, false);
//
//        Test.startTest();
//        Account acct = [SELECT Id FROM Account LIMIT 1];
//        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate FROM Order LIMIT 1];
//        Date termDate = ord.EffectiveDate.addDays(-1);
//        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :ord.OpportunityId];
//        Contract ctr = [
//              SELECT Id,
//                    AccountId,
//                    SBQQ__Order__c,
//                    SBQQ__Opportunity__c,
//                    SBQQ__Quote__c,
//                    Status,
//                    Pricebook2Id,
//                    CurrencyIsoCode,
//                    ContractTerm,
//                    StartDate,
//                    EndDate,
//                    SBQQ__PreserveBundleStructureUponRenewals__c,
//                    SBQQ__AmendmentRenewalBehavior__c,
//                    SBQQ__DefaultRenewalPartners__c,
//                    SBQQ__DefaultRenewalContactRoles__c
//              FROM Contract
//              LIMIT 1
//        ];
//
//        List<OrderItem> oiList = new List<OrderItem>();
//        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
//            oi.ServiceDate = ctr.EndDate.addDays(1);
//            oiList.add(oi);
//        }
//        update oiList;
//
//        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
//        for (OrderItem oi : [SELECT Id, Product2Id, L2I_blng_MatchingId__c, ServiceDate FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
//            SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
//            obj.SBQQ__Account__c = acct.Id;
//            obj.SBQQ__Product__c = oi.Product2Id;
//            obj.SBQQ__Contract__c = ctr.Id;
//            obj.SBQQ__Quantity__c = 10.00;
//            obj.SBQQ__ProductSubscriptionType__c = 'Renewable';
//            obj.SBQQ__SubscriptionType__c = 'Renewable';
//            obj.SBQQ__OrderProduct__c = oi.Id;
//            obj.L2I_blng_MatchingId__c = oi.L2I_blng_MatchingId__c;
//            subList.add(obj);
//        }
//        System.debug('*** sub enddate ' + [select SBQQ__EndDate__c from SBQQ__Subscription__c]);
//        System.debug('*** oi startdate ' + [select servicedate from orderitem]);
//        insert subList;
//        System.debug('*** subList ' + subList);
//
//        oppty.SBQQ__RenewedContract__c = ctr.Id;
//        update oppty;
//        ord.Status = 'Activated';
//        ord.Type = 'Renewal';
//        ord.OpportunityId = oppty.Id;
//        ord.EffectiveDate = Date.Today();
//        update ord;
//        L2I_CancelReplaceService.cancelPrior(new Set<Id>{
//              ctr.Id
//        });
//        Test.stopTest();
//
//        System.assertEquals(0, [SELECT COUNT() FROM SBQQ__Subscription__c WHERE SBQQ__TerminatedDate__c = :termDate]);
//        System.assertEquals(0, [SELECT COUNT() FROM OrderItem WHERE SBQQ__TerminatedDate__c = :termDate]);
//    }
//
//    @IsTest
//    static void testNoCancel() {
//        L2I_DataFactory factory = new L2I_DataFactory();
//        factory.setupAccountThruContract(null, null, false);
//
//        Test.startTest();
//        Account acct = [SELECT Id FROM Account LIMIT 1];
//        Order ord = [SELECT Id, OpportunityId, Status, EffectiveDate FROM Order LIMIT 1];
//        Date termDate = ord.EffectiveDate.addDays(-1);
//        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :ord.OpportunityId];
//        Contract ctr = [
//              SELECT Id,
//                    AccountId,
//                    SBQQ__Order__c,
//                    SBQQ__Opportunity__c,
//                    SBQQ__Quote__c,
//                    Status,
//                    Pricebook2Id,
//                    CurrencyIsoCode,
//                    ContractTerm,
//                    StartDate,
//                    EndDate,
//                    SBQQ__PreserveBundleStructureUponRenewals__c,
//                    SBQQ__AmendmentRenewalBehavior__c,
//                    SBQQ__DefaultRenewalPartners__c,
//                    SBQQ__DefaultRenewalContactRoles__c
//              FROM Contract
//              LIMIT 1
//        ];
//        ctr.StartDate = Date.today().addYears(-1);
//        ctr.ContractTerm = 1;
//        update ctr;
//
//        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
//        for (OrderItem oi : [SELECT Id, Product2Id FROM OrderItem WHERE OrderId = :ctr.SBQQ__Order__c]) {
//            SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
//            obj.SBQQ__Account__c = acct.Id;
//            obj.SBQQ__Product__c = oi.Product2Id;
//            obj.SBQQ__Contract__c = ctr.Id;
//            obj.SBQQ__Quantity__c = 10.00;
//            obj.SBQQ__ProductSubscriptionType__c = 'Renewable';
//            obj.SBQQ__SubscriptionType__c = 'Renewable';
//            obj.SBQQ__OrderProduct__c = oi.Id;
//            subList.add(obj);
//        }
//        insert subList;
//        System.debug('*** subList ' + subList);
//
//        oppty.SBQQ__RenewedContract__c = ctr.Id;
//        update oppty;
//        ord.Status = 'Activated';
//        ord.Type = 'Renewal';
//        ord.OpportunityId = oppty.Id;
//        update ord;
//
//        L2I_CancelReplaceService.cancelPrior(new Set<Id>{
//              ctr.Id
//        });
//        Test.stopTest();
//
//        System.assertEquals(0, [SELECT COUNT() FROM SBQQ__Subscription__c WHERE SBQQ__TerminatedDate__c = :termDate]);
//        System.assertEquals(0, [SELECT COUNT() FROM OrderItem WHERE SBQQ__TerminatedDate__c = :termDate]);
//    }
//
//    @IsTest
//    static void testNoValidOrders() {
//        L2I_CancelReplaceService.cancelPrior(new Set<Id>());
//    }
}