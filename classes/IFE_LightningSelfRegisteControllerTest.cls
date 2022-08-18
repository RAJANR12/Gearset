@isTest
private class IFE_LightningSelfRegisteControllerTest {
    
   // private static String recaptchaSecretKey = '6Lcc7NkZAAAAANK7H2cOHc0zHVmXri3VRuJ-CsUo';
   
    @isTest static void captchVerifyTest(){
        Test.setMock(HttpCalloutMock.class, new IFE_LightningSelfRegisteCtrlCallout());
        IFE_LightningSelfRegisteController.captchVerify('gvvdcs');
        
    } 
    
    @isTest private static void testMethodOne(){
        IFE_LightningSelfRegisteController controller = new IFE_LightningSelfRegisteController(); 
    }
    @isTest static void isValidPasswordTest(){
        IFE_LightningSelfRegisteController.isValidPassword('123Test', '123Test');
    }
    @isTest static void siteAsContainerEnabled(){
        IFE_LightningSelfRegisteController.siteAsContainerEnabled('https://portaleu1-developer-edition.eu11.force.com');
    }
    @isTest static void validatePasswordTest(){
       
        
        User userObj = ife_TestDataUtil.CreateUser(true);
      IFE_LightningSelfRegisteController.validatePassword(userObj,'password','confirmPasswordCorrect');
        
		
    }
    @isTest static void testRegistrationSubmission(){
        Map < String, String > paramsMap = initializeParams();
        System.assertNotEquals(null, paramsMap);
        System.assertEquals('First Name is required', IFE_LightningSelfRegisteController.registrationSubmission('', paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('accountId'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('company'), paramsMap.get('position'), null, paramsMap.get('country'), null));
        System.assertEquals(Label.Site.lastname_is_required, IFE_LightningSelfRegisteController.registrationSubmission(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('accountId'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('company'), paramsMap.get('position'), null, paramsMap.get('country'), null));
       	System.assertEquals(Label.Site.email_is_required, IFE_LightningSelfRegisteController.registrationSubmission(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('accountId'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('company'), paramsMap.get('position'), null, paramsMap.get('country'), null));
        System.assertEquals('Company is required', IFE_LightningSelfRegisteController.registrationSubmission(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('accountId'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, '', paramsMap.get('position'), null, paramsMap.get('country'), null));
        System.assertEquals('Country is required', IFE_LightningSelfRegisteController.registrationSubmission(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('accountId'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('company') , paramsMap.get('position'), null, '', null));
        //System.assertEquals(Label.IFE_Public_Domain_Email, IFE_LightningSelfRegisteController.registrationSubmission(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('accountId'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('company'), paramsMap.get('position'), null, paramsMap.get('country'), null));        
    }
    @isTest static void dmlMethodTest(){
        Map < String, String > paramsMap = initializeParams();
          IFE_LightningSelfRegisteController.registrationSubmission(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('accountId'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('company'), paramsMap.get('position'), null, paramsMap.get('country'), null);
    }
    @isTest static void getExtraFieldsTest(){
        IFE_LightningSelfRegisteController.getExtraFields(null);
    }
    @isTest static void setExperienceIdTest(){
        IFE_LightningSelfRegisteController.setExperienceId('123Test');
    }
    
    @isTest
    public static void getUserCountryTest(){
        IFE_LightningSelfRegisteController.getUserCountry();
    }
    
    /* Helper method to initialize the parameters required for RegistrationSubmission. */
    private static Map< String, String > initializeParams(){
        Map < String, String > paramsMap = new Map < String, String > ();
        String firstName = 'test';
        String lastName = 'User';
        String email = 'taken@salesforce.com';
        String password = 'testuser123';
        String confirmPasswordCorrect = 'testuser123';
        String confirmPasswordWrong = 'wrongpassword';
        String accountId = 'testuser123';
        String regConfirmUrl = 'http://registration-confirm.com';
        String company = 'testcompany';
        String country = 'testcountry'; 
        String position = 'testPosition';
        String startUrl = 'http://my.company.salesforce.com';
        paramsMap.put('firstName', firstName);
        paramsMap.put('lastName', lastName);
        paramsMap.put('email', email);
        paramsMap.put('password', password);
        paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
        paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
        paramsMap.put('accountId', accountId);
        paramsMap.put('company', company);
        paramsMap.put('country', country);
        paramsMap.put('regConfirmUrl', regConfirmUrl);
        paramsMap.put('startUrl', startUrl);
        return paramsMap;                    
    }
    
}