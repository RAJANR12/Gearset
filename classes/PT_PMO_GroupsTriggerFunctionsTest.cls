@IsTest
private class PT_PMO_GroupsTriggerFunctionsTest {
    @testSetup
    private static void dataSetup() {
        L2I_DataFactory df = new L2I_DataFactory();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'PAC Sales'].Id;
        Id profileSAId = [SELECT Id FROM Profile WHERE Name = 'PAC System Administrator'].Id;
        User u1 = df.createTestUser(null, profileId, 'User1', 'Test');
        insert u1;
        User u2 = df.createTestUser(null, profileId, 'User2', 'Test');
        insert u2;
        User u3 = df.createTestUser(null, profileId, 'User3', 'Test');
        insert u3;
        User sa = df.createTestUser(null, profileSAId, 'SA', 'Test');
        insert sa;
    }
    
    // Test RD
    @IsTest
    private static void addMemberToRDQueueTest() {
        User u1 = [SELECT Id FROM User WHERE FirstName = 'User1' LIMIT 1];
        User sa = [SELECT Id FROM User WHERE FirstName = 'SA' LIMIT 1];
        Group grpObj = [SELECT Id FROM Group WHERE Name = 'Program RD Group' LIMIT 1];
        System.debug('*** ' + [SELECT count() FROM GroupMember WHERE GroupId = :grpObj.Id]);
        System.runAs(sa) {
            PT_PMO_Groups__c pg = new PT_PMO_Groups__c();
            pg.Group_Type__c = 'Group';
            Test.startTest();
            insert pg;
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :sa.Id]);
    }
    @IsTest
    private static void deleteMemberToRDQueueTest() {
        User u1 = [SELECT Id FROM User WHERE FirstName = 'User1' LIMIT 1];
        User sa = [SELECT Id FROM User WHERE FirstName = 'SA' LIMIT 1];
        Group grpObj = [SELECT Id FROM Group WHERE Name = 'Program RD Group' LIMIT 1];
        System.debug('*** ' + [SELECT count() FROM GroupMember WHERE GroupId = :grpObj.Id]);
        System.runAs(sa) {
            PT_PMO_Groups__c pg = new PT_PMO_Groups__c();
            pg.Group_Type__c = 'Group';
            insert pg;
            Test.startTest();
            delete pg;
            Test.stopTest();
        }
        System.assertEquals(0, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :sa.Id]);
    }
    @IsTest
    private static void deleteMemberExistingToRDQueueTest() {
        User u1 = [SELECT Id FROM User WHERE FirstName = 'User1' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE FirstName = 'User2' LIMIT 1];
        User u3 = [SELECT Id FROM User WHERE FirstName = 'User3' LIMIT 1];
        User sa = [SELECT Id FROM User WHERE FirstName = 'SA' LIMIT 1];
        Group grpObj = [SELECT Id FROM Group WHERE Name = 'Program RD Group' LIMIT 1];
        System.debug('*** ' + [SELECT count() FROM GroupMember WHERE GroupId = :grpObj.Id]);
        System.runAs(sa) {
            PT_PMO_Groups__c pg1 = new PT_PMO_Groups__c();
            pg1.Group_Type__c = 'Group';
            insert pg1;
            PT_PMO_Groups__c pg2 = new PT_PMO_Groups__c();
            pg2.Group_Type__c = 'Group';
            insert pg2;
            PT_PMO_Groups__c pg3 = new PT_PMO_Groups__c();
            pg3.Group_Type__c = 'Group';
            insert pg3;
            pg3.OwnerId = u1.Id;
            update pg3;
            Test.startTest();
            delete pg1;
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :sa.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :u1.Id]);
        System.assertEquals(2, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND (UserOrGroupId = :sa.Id OR UserOrGroupId = :u1.Id)]);
    }
    @IsTest
    private static void changeMemberToRDQueueTest() {
        User u1 = [SELECT Id FROM User WHERE FirstName = 'User1' LIMIT 1];
        User sa = [SELECT Id FROM User WHERE FirstName = 'SA' LIMIT 1];
        Group grpObj = [SELECT Id FROM Group WHERE Name = 'Program RD Group' LIMIT 1];
        System.debug('*** ' + [SELECT count() FROM GroupMember WHERE GroupId = :grpObj.Id]);
        System.runAs(sa) {
            PT_PMO_Groups__c pg = new PT_PMO_Groups__c();
            pg.Group_Type__c = 'Group';
            insert pg;
            pg.OwnerId = u1.Id;
            Test.startTest();
            update pg;
            Test.stopTest();
        }
        System.assertEquals(0, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :sa.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :u1.Id]);
    }
    
    // Test PPM
    @IsTest
    private static void addMemberToPPMQueueTest() {
        User u1 = [SELECT Id FROM User WHERE FirstName = 'User1' LIMIT 1];
        User sa = [SELECT Id FROM User WHERE FirstName = 'SA' LIMIT 1];
        Group grpObj = [SELECT Id FROM Group WHERE Name = 'Program PPM Group' LIMIT 1];
        System.debug('*** ' + [SELECT count() FROM GroupMember WHERE GroupId = :grpObj.Id]);
        System.runAs(sa) {
            PT_PMO_Groups__c pg = new PT_PMO_Groups__c();
            pg.Group_Type__c = 'Sub Group';
            Test.startTest();
            insert pg;
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :sa.Id]);
    }
    @IsTest
    private static void deleteMemberToPPMQueueTest() {
        User u1 = [SELECT Id FROM User WHERE FirstName = 'User1' LIMIT 1];
        User sa = [SELECT Id FROM User WHERE FirstName = 'SA' LIMIT 1];
        Group grpObj = [SELECT Id FROM Group WHERE Name = 'Program PPM Group' LIMIT 1];
        System.debug('*** ' + [SELECT count() FROM GroupMember WHERE GroupId = :grpObj.Id]);
        System.runAs(sa) {
            PT_PMO_Groups__c pg = new PT_PMO_Groups__c();
            pg.Group_Type__c = 'Sub Group';
            insert pg;
            Test.startTest();
            delete pg;
            Test.stopTest();
        }
        System.assertEquals(0, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :sa.Id]);
    }
    @IsTest
    private static void deleteMemberExistingToPPMQueueTest() {
        User u1 = [SELECT Id FROM User WHERE FirstName = 'User1' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE FirstName = 'User2' LIMIT 1];
        User u3 = [SELECT Id FROM User WHERE FirstName = 'User3' LIMIT 1];
        User sa = [SELECT Id FROM User WHERE FirstName = 'SA' LIMIT 1];
        Group grpObj = [SELECT Id FROM Group WHERE Name = 'Program PPM Group' LIMIT 1];
        System.debug('*** ' + [SELECT count() FROM GroupMember WHERE GroupId = :grpObj.Id]);
        System.runAs(sa) {
            PT_PMO_Groups__c pg1 = new PT_PMO_Groups__c();
            pg1.Group_Type__c = 'Sub Group';
            insert pg1;
            PT_PMO_Groups__c pg2 = new PT_PMO_Groups__c();
            pg2.Group_Type__c = 'Sub Group';
            insert pg2;
            PT_PMO_Groups__c pg3 = new PT_PMO_Groups__c();
            pg3.Group_Type__c = 'Sub Group';
            insert pg3;
            pg3.OwnerId = u1.Id;
            update pg3;
            Test.startTest();
            delete pg1;
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :sa.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :u1.Id]);
        System.assertEquals(2, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND (UserOrGroupId = :sa.Id OR UserOrGroupId = :u1.Id)]);
    }
    @IsTest
    private static void changeMemberToPPMQueueTest() {
        User u1 = [SELECT Id FROM User WHERE FirstName = 'User1' LIMIT 1];
        User sa = [SELECT Id FROM User WHERE FirstName = 'SA' LIMIT 1];
        Group grpObj = [SELECT Id FROM Group WHERE Name = 'Program PPM Group' LIMIT 1];
        System.debug('*** ' + [SELECT count() FROM GroupMember WHERE GroupId = :grpObj.Id]);
        System.runAs(sa) {
            PT_PMO_Groups__c pg = new PT_PMO_Groups__c();
            pg.Group_Type__c = 'Sub Group';
            insert pg;
            pg.OwnerId = u1.Id;
            Test.startTest();
            update pg;
            Test.stopTest();
        }
        System.assertEquals(0, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :sa.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :grpObj.Id AND UserOrGroupId = :u1.Id]);
    }
    
    @IsTest
    private static void changeOwnerToRDTest() {
        System.debug('*** changeOwnerToRDTest');
        User u1 = [SELECT Id FROM User WHERE FirstName = 'User1' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE FirstName = 'User2' LIMIT 1];
        User sa = [SELECT Id FROM User WHERE FirstName = 'SA' LIMIT 1];
        System.debug('*** sa ' + sa);
        System.debug('*** u1 ' + u1);
    
        System.runAs(sa) {
            PT_PMO_Groups__c pg1 = new PT_PMO_Groups__c();
            pg1.Group_Type__c = 'Group';
            insert pg1;
    
            PT_PMO_Groups__c pg2 = new PT_PMO_Groups__c();
            pg2.Group_Type__c = 'Sub Group';
            insert pg2;

            PT_Program__c prog1 = new PT_Program__c();
            prog1.Name = 'Prog1';
            prog1.Program_Number__c = 'Prog1';
            prog1.Program_Manager__c = u1.Id;
            prog1.PT_PMO_Group__c = pg1.Id;
            prog1.PT_PMO_SubGroup__c = pg2.Id;
            insert prog1;
            System.assertEquals(1, [SELECT COUNT() FROM PT_Program__c WHERE PMO_Regional_Director__c = :sa.Id]);
    
            pg1.OwnerId = u1.Id;
    
            Test.startTest();
            update pg1;
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT COUNT() FROM PT_Program__c WHERE PMO_Regional_Director__c = :u1.Id]);
    }
    
    @IsTest
    private static void changeOwnerToPPMTest() {
        System.debug('*** changeOwnerToRDTest');
        User u1 = [SELECT Id FROM User WHERE FirstName = 'User1' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE FirstName = 'User2' LIMIT 1];
        User sa = [SELECT Id FROM User WHERE FirstName = 'SA' LIMIT 1];
        System.debug('*** sa ' + sa);
        System.debug('*** u1 ' + u1);
        
        System.runAs(sa) {
            PT_PMO_Groups__c pg1 = new PT_PMO_Groups__c();
            pg1.Group_Type__c = 'Group';
            insert pg1;
            
            PT_PMO_Groups__c pg2 = new PT_PMO_Groups__c();
            pg2.Group_Type__c = 'Sub Group';
            insert pg2;
            
            PT_Program__c prog1 = new PT_Program__c();
            prog1.Name = 'Prog1';
            prog1.Program_Number__c = 'Prog1';
            prog1.Program_Manager__c = u1.Id;
            prog1.PT_PMO_Group__c = pg1.Id;
            prog1.PT_PMO_SubGroup__c = pg2.Id;
            insert prog1;
            System.assertEquals(1, [SELECT COUNT() FROM PT_Program__c WHERE Principal_Program_Manager__c = :sa.Id]);
            
            pg2.OwnerId = u2.Id;
            
            Test.startTest();
            update pg2;
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT COUNT() FROM PT_Program__c WHERE Principal_Program_Manager__c = :u2.Id]);
    }
}