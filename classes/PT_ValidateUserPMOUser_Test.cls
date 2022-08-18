@IsTest
private class PT_ValidateUserPMOUser_Test {
    @IsTest
    static void testBehavior() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'PAC System Administrator' LIMIT 1];
        User u = new User(
              LastName = 'SMITH',
              FirstName = 'JOHN',
              Alias = 'main',
              Email = 'testPACuser@testfactory.com',
              Phone = '1234567890',
              Username = 'testPACuser@testfactory.com.' + Math.random(),
              TimeZoneSidKey = 'Europe/Berlin',
              LanguageLocaleKey = 'en_US',
              EmailEncodingKey = 'UTF-8',
              LocaleSidKey = 'en_US',
              ProfileId = profile.Id);
        insert u;
        
        System.runAs(u){
            List<Boolean> bList = PT_ValidateUserPMOUser.validatePMOUser();
            System.assertEquals(false, bList[0]);
        }
    }
}