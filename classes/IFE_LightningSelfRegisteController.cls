global class IFE_LightningSelfRegisteController {

    private static String recaptchaSecretKey = '6Lcc7NkZAAAAANK7H2cOHc0zHVmXri3VRuJ-CsUo';

    public IFE_LightningSelfRegisteController() {

    }

    @TestVisible 
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
    @TestVisible 
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    @TestVisible 
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
        Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }
    
    /*@AuraEnabled
    public static String selfRegister(String firstname ,String lastname, String email, String password, String confirmPassword, String accountId, String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword) {
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();
            
            if (lastname == null || String.isEmpty(lastname)) {
                return Label.Site.lastname_is_required;
            }
            
            if (email == null || String.isEmpty(email)) {
                return Label.Site.email_is_required;
            }
            
            User u = new User();
            u.Username = email;
            u.put('Email',email);
            
            u.FirstName = firstname;
            u.LastName = lastname;
            
            String networkId = Network.getNetworkId();

            // If using site to host the community the user should not hit s1 after logging in from mobile.
            if(networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
                u.put('UserPreferencesHideS1BrowserUI',true);
            }
            
            String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
            u.put('CommunityNickname', nickname);
                     
            if (extraFields != null) {
                List<Object> extraFieldsList = (List<Object>) JSON.deserializeUntyped(extraFields);        
                for (Object thisFieldObject : extraFieldsList) {
                    Map<String,Object> thisField = (Map<String,Object>) thisFieldObject;
                    Schema.SObjectField sof = Schema.SObjectType.User.fields.getMap().get((String) thisField.get('fieldPath'));
                    u.put(sof, thisField.get('value'));
                }
            }
                        
            if (includePassword) {    
                if (!isValidPassword(password, confirmPassword)) {
                    return Label.site.passwords_dont_match;
                }
             validatePassword(u, password, confirmPassword);
            }
            else {
                password = null;
            }
            
            // lastName is a required field on user, but if it isn't specified, we'll default it to the username
            String userId = Site.createPortalUser(u, accountId, password);
            // create a fake userId for test.
            if (Test.isRunningTest()) {
                userId = 'fakeUserId';           
            }
            if (userId != null) { 
                if (password != null && password.length() > 1) {
                    ApexPages.PageReference lgn = Site.login(email, password, startUrl);
                    if(!Test.isRunningTest()) {
                     aura.redirect(lgn);
                    }
                }
                else {
                    ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
                    if(!Test.isRunningTest()) {
                    aura.redirect(confirmRef);
                   }

                }
            }
            return null;
        }
        catch (Exception ex) {
            Database.rollback(sp);
            return ex.getMessage();            
        }
    }*/

    @AuraEnabled
    public static String registrationSubmission(String firstname ,String lastname, String email, String password, String confirmPassword, String accountId, 
    String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword, String company, String position, String phone, String country, String b2boption) {
    
        List<IFE_Public_Domain_Email__mdt> publicDomainEmails = [Select MasterLabel 
                                                                 FROM IFE_Public_Domain_Email__mdt];
         Set<String> publicEmails = new Set<String>();
         for(IFE_Public_Domain_Email__mdt publicEmail : publicDomainEmails){
             publicEmails.add(publicEmail.MasterLabel);
         }           

        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();

           if (firstname == null || String.isEmpty(firstname)) {
                return 'First Name is required';
            }

            if (lastname == null || String.isEmpty(lastname)) {
                return Label.Site.lastname_is_required;
            }
            
            if (email == null || String.isEmpty(email)) {
                return Label.Site.email_is_required;
            }

            if( publicEmails.contains(email.substringAfter('@'))){
                return Label.IFE_Public_Domain_Email;
            }

            if (company == null || String.isEmpty(company)) {
                return 'Company is required';
            }

            if (country == null || String.isEmpty(country)) {
                return 'Country is required';
            }

            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true; 
            dmo.EmailHeader.triggerUserEmail = true;

            Lead ld = new Lead();
            ld.firstname = firstname;
            ld.lastName = lastName;
            ld.Company = company;
            ld.Email = email;
            ld.LeadSource = 'Communities';
            ld.Title = position;
            ld.phone = phone;
            ld.country = country;
            ld.IFE_B2B_Access__c = (b2boption == 'Yes')? true : false;
            ld.Policy_Agreement__c = true;
            ld.recordtypeid = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('External Customer').getRecordTypeId();
            List<Lead> leads = new List<Lead>{ld};
            ld.setOptions(dmo);

            insert leads;
            
            ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
            aura.redirect(confirmRef);

            return null;
        }
        catch (Exception ex) {
            Database.rollback(sp);
            System.debug('ERROR COMMUNITY REGISTRATION '+ ex.getMessage());
            return ex.getMessage();            
        }
    }
    
    @AuraEnabled
    public static List<Map<String,Object>> getExtraFields(String extraFieldsFieldSet) { 
        List<Map<String,Object>> extraFields = new List<Map<String,Object>>();
        Schema.FieldSet fieldSet = Schema.SObjectType.User.fieldSets.getMap().get(extraFieldsFieldSet);
        if(!Test.isRunningTest()) {
        if (fieldSet != null) {
            for (Schema.FieldSetMember f : fieldSet.getFields()) {
                Map<String, Object> fieldDetail = new Map<String, Object>();
                fieldDetail.put('dbRequired', f.getDBRequired());
                fieldDetail.put('fieldPath', f.getFieldPath());
                fieldDetail.put('label', f.getLabel());
                fieldDetail.put('required', f.getRequired());
                fieldDetail.put('type', f.getType());
                fieldDetail.put('value', '');   // client will populate
                extraFields.add(fieldDetail);
            }}}
        return extraFields;
    }
    
    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);   
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }        
    }  


    public static String captchVerify(String reCaptchaResponse){
        //https://developers.google.com/recaptcha/docs/verify
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
        request.setMethod('POST');
        request.setBody('secret=' + recaptchaSecretKey + '&response=' + reCaptchaResponse);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            System.debug('response.getBody()'+response.getBody());
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			System.debug('result>>'+result);
            System.debug('result.containsKey()>>>'+result.containsKey('success'));
            if (result.containsKey('success') && result.get('success') == true) {
                if (result.containsKey('score')) {
                    //score logic is only needed/returned for v3 (0.0 - 1.0)
                    //https://developers.google.com/recaptcha/docs/v3
                    //TODO: verify action name for the request
                    String action = (String)result.get('action');
                    //TODO: get threshold configuration for each action
                    Decimal threshold = .4;
                    Decimal score = (Decimal)result.get('score');
                    if (score > threshold) {
                        //TODO: perform action on record
                        
                        return 'Success - v3';
                    }
                } else {
                    //TODO: perform action on record
                    
                    return 'Success - v2';
                }
            } else {
                return 'Invalid Verification';
            }
        }
        //consider letting this through
        return 'Invalid Verification Request';
    }

    @AuraEnabled
    public static List<String> getUserCountry(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = User.IFE_Country__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }

}