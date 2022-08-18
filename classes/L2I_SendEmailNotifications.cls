/**
 *  @author       Ryan Lobitana (Simplus)
 *  @date         JUL/20/2021
 *  @description  L2I_SendEmailNotifications class
 *
 *  Modification Log:
 *  ------------------------------------------------------------------------------------
 *  Developer                       Date                Description
 *  ------------------------------------------------------------------------------------
 *  Ryan Lobitana                  7/20/2020         Initial scaffold
 *
 */
public class L2I_SendEmailNotifications {
    
    private static List<String> exemptedEmailAddresses = new List<String>();
    
    @InvocableMethod(label='Send Email Notification')
    public static void sendEmailNotificationForClosedWonOppty(List<Id> opptyIds){
        
        try{
            Map<Id, String> closedWonOpptys = new Map<Id, String>();
            Map<Id, Opportunity> closedWonOpptyMap = new Map<Id, Opportunity>();
            
            for(Opportunity oppty: [Select Id, StageName, Name, L2I_Program_Num__r.Name, L2I_Oppt_Region__c, Owner.Name, L2I_AC_Operator__r.Name, L2I_PO_Issuer__r.Name, PT_Program_Mgr__r.Email, PT_Program_Mgr__r.Id,
                                    L2I_Fit_Type__c, L2I_Primary_System_Type__r.Name, L2I_AircraftQuantity__c, Opportunity_Link__c, L2I_Opportunity_Number__c,
                                    PT_Program_Mgr__r.Name, PT_PL_Approval_Approver__r.Name, Owner.Email, Account.Owner.Email, Owner.Id, Account.Owner.Id, Account.Name, L2I_Program_Num__r.PT_PMO_Group__r.Name,
                                    L2I_Program_Num__r.PT_PMO_Group__c, L2I_Program_Num__r.PT_PMO_Group__r.OwnerId, L2I_Program_Num__r.Program_Administrator__r.Email, L2I_Program_Num__r.Program_Administrator__r.Id, 
                                    L2I_Program_Num__r.Program_Manager__r.Email, L2I_Program_Num__r.Program_Manager__r.Id, L2I_AircraftType__c, L2I_Product_Category__c
                                    FROM Opportunity
                                    WHERE Id IN: opptyIds]){
                                        
                                        if (oppty.StageName == 'Closed Won'){
                                            closedWonOpptys.put(oppty.Id, constructHTMLEmailBodyClosedWonHandoffOppty(oppty, 'Closed Won'));               
                                        } else if (oppty.StageName == 'Handoff'){
                                            closedWonOpptys.put(oppty.Id, constructHTMLEmailBodyClosedWonHandoffOppty(oppty, 'Handoff'));
                                        } else if (oppty.StageName == 'Delivery'){
                                            closedWonOpptys.put(oppty.Id, constructHTMLEmailBody(oppty));
                                        }
                                        
                                        closedWonOpptyMap.put(oppty.Id, oppty);
                                    }
            
            sendEmailCustomBellNotifClosedWonOppty(closedWonOpptys, closedWonOpptyMap); 
        } catch(Exception ex){
            System.debug('exception --- ' + ex.getMessage() + ' ' + ex.getLineNumber());
        }
    }
    
    private static void sendEmailCustomBellNotifClosedWonOppty(Map<Id, String> closedWonOpptys, Map<Id, Opportunity> opptyMap){
        
        try{
            // Get the Id for our custom notification type        
        	CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Opportunity_StageName_Update_Notification'];
            
            List<Messaging.SingleEmailMessage> lstOfEmails = new List<Messaging.SingleEmailMessage>();
            // Create a new custom notification
        	Map<Messaging.CustomNotification, Set<String>> notifications = new Map<Messaging.CustomNotification, Set<String>>();
            Map<String, String> userEmailIdMapFromGroup = new Map<String, String>();
            Map<String, String> userEmailIdMapFromOpptyTeam = new Map<String, String>();
            //List<User> contractsTeam = new List<User>();
            //List<Opportunity_Stage_Send_Notification__mdt> contractsTeamInfoList = new List<Opportunity_Stage_Send_Notification__mdt>();
            
            String emailSubject = '';
            
            //get all users from public group
            userEmailIdMapFromGroup = getEmailFromPublicGroup();
            //get all the contracts team info from custom metadata
            //contractsTeam = getContractsTeam();
            //contractsTeamInfoList = getContractsTeamInfoList();
            
            for(Id opptyId: closedWonOpptys.keySet()){
                Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                Set<String> allRecipients = new Set<String>();
                List<String> ccEmailAddress = new List<String>();
                List<String> emailOnBCC = new List<String>();
                                
				//get all users from the opportunity team
				userEmailIdMapFromOpptyTeam = getUserEmailFromOpportunityTeam(opptyId);
                
                //add all the users id who will receive the notif bell
                allRecipients.add(opptyMap.get(opptyId).Owner.Id);
                allRecipients.add(opptyMap.get(opptyId).Account.Owner.Id);
                
                //add all the users email addresses who will receive the email notif                
                ccEmailAddress.add(opptyMap.get(opptyId).Owner.Email);
                ccEmailAddress.add(opptyMap.get(opptyId).Account.Owner.Email);                                
                
                //add user id from the opportunity team
                allRecipients.addAll(userEmailIdMapFromOpptyTeam.values());                                               
                
                //add user email addresses from the opportunity team
                if(!userEmailIdMapFromOpptyTeam.keySet().isEmpty()){
                    ccEmailAddress.addAll(userEmailIdMapFromOpptyTeam.keySet());                       
                }
                
                if(opptyMap.get(opptyId).StageName == 'Closed Won'){
                    if(!String.isBlank(Label.PMO_Award_Distribution_List)){
                        if(Label.PMO_Award_Distribution_List.contains(';')){
                           List<String> dlList = Label.PMO_Award_Distribution_List.split(';');
                            for(String dlString: dlList){
                                if(String.IsNotBlank(dlString)){
                                    ccEmailAddress.add(dlString);
                                }
                            }
                        }
                        else {
                        	ccEmailAddress.add(Label.PMO_Award_Distribution_List);                            
                        }                    	
                    }
                                        
                    if(!(String.isBlank(opptyMap.get(opptyId).L2I_Product_Category__c) && String.isBlank(opptyMap.get(opptyId).L2I_Oppt_Region__c))){
                        Map<Id, String> userIdEmailMap = getUserFromPublicGroup(opptyMap.get(opptyId).L2I_Product_Category__c, opptyMap.get(opptyId).L2I_Oppt_Region__c);
                        
                        if(!userIdEmailMap.keySet().isEmpty()){
                            for(String userId: userIdEmailMap.keySet()){
                                ccEmailAddress.add(userIdEmailMap.get(userId));
                                allRecipients.add(userId);
                            }
                        }                        
                    }                                        
                    /*
                    for(User userRec: contractsTeam){                        
                        if(!(String.isBlank(userRec.Assigned_Product_Category__c) && String.isBlank(userRec.Assigned_Region__c))){
                            if(userRec.Assigned_Region__c.containsIgnoreCase(opptyMap.get(opptyId).L2I_Oppt_Region__c) && userRec.Assigned_Product_Category__c.containsIgnoreCase(opptyMap.get(opptyId).L2I_Product_Category__c)){
                                ccEmailAddress.add(userRec.Email);
                                allRecipients.add(userRec.Id);
                            }
                        }                        
                    }*/
                    //ccEmailAddress.addAll(getUserEmailIdFromContractsList(opptyMap.get(opptyId).L2I_Product_Category__c, opptyMap.get(opptyId).L2I_Oppt_Region__c, contractsTeamInfoList, 'Email'));
                    //allRecipients.addAll(getUserEmailIdFromContractsList(opptyMap.get(opptyId).L2I_Product_Category__c, opptyMap.get(opptyId).L2I_Oppt_Region__c, contractsTeamInfoList, 'Bell' ));
                }
                
                if(opptyMap.get(opptyId).StageName == 'Handoff' || opptyMap.get(opptyId).StageName == 'Delivery'){
                    //custom bell notif
                    allRecipients.addAll(userEmailIdMapFromGroup.values());
                    //email notif
                    emailOnBCC.addAll(userEmailIdMapFromGroup.keySet());
                    if(!emailOnBCC.isEmpty()){
                        //set the cc email addresses of the email notif and remove all exempted addresses
                        emailMsg.setBccAddresses(removeExemptedEmailAddresses(emailOnBCC));
                    }
                    //add Program Manager in CC Address
                    if(!String.isBlank(opptyMap.get(opptyId).PT_Program_Mgr__r.Id)){
                        ccEmailAddress.add(opptyMap.get(opptyId).PT_Program_Mgr__r.Email);
                        //
                        allRecipients.add(opptyMap.get(opptyId).PT_Program_Mgr__r.Id);
                    }
                    
                    //additional cc email addresses and user id for StageName equals Delivery
                    if(opptyMap.get(opptyId).StageName == 'Delivery'){
                        if(!String.isBlank(opptyMap.get(opptyId).L2I_Program_Num__r.Program_Administrator__r.Id)){
                            ccEmailAddress.add(opptyMap.get(opptyId).L2I_Program_Num__r.Program_Administrator__r.Email);
                            //
                        	allRecipients.add(opptyMap.get(opptyId).L2I_Program_Num__r.Program_Administrator__r.Id);
                        }                                        		
                    }
                }
                
				//remove null and empty values from the bell notification user ID Set
				allRecipients.remove('');
                allRecipients.remove(null);
                System.debug('allRecipients----: ' + allRecipients); 
                //set up custom bell notif
				notifications.put((createCustomNotification(notification, opptyMap.get(opptyId), notificationType)), allRecipients);
                
                //create the email notification subject
                if (opptyMap.get(opptyId).StageName == 'Closed Won'){
                    emailSubject = opptyMap.get(opptyId).L2I_Opportunity_Number__c +', ' + opptyMap.get(opptyId).StageName + ' and ' + opptyMap.get(opptyId).Account.Name;
                } else if (opptyMap.get(opptyId).StageName == 'Delivery'){
                    emailSubject = opptyMap.get(opptyId).L2I_Opportunity_Number__c +', ' + opptyMap.get(opptyId).StageName + ', ' + opptyMap.get(opptyId).Account.Name;
                    if(!String.isBlank(opptyMap.get(opptyId).L2I_Program_Num__r.Name)){
                        emailSubject += ', ' +opptyMap.get(opptyId).L2I_Program_Num__r.Name;
                    }
                } else if (opptyMap.get(opptyId).StageName == 'Handoff'){
                    emailSubject = opptyMap.get(opptyId).L2I_Opportunity_Number__c +', ' + opptyMap.get(opptyId).StageName;
                    if(!String.isBlank(opptyMap.get(opptyId).L2I_Program_Num__r.Name)){
                        emailSubject += ' and ' + opptyMap.get(opptyId).L2I_Program_Num__r.Name;
                    }
                }
                //compose the email
                System.debug('ccEmailAddress --- '+ccEmailAddress);                
                //set the cc email addresses of the email notif, and remove the exempted email addresses
                emailMsg.setCcAddresses(removeExemptedEmailAddresses(ccEmailAddress));
                emailMsg.setSubject(emailSubject);
                emailMsg.setHtmlBody(closedWonOpptys.get(opptyId));
                
                lstOfEmails.add(emailMsg);
            }
            
            //actual sending of email
            if(!lstOfEmails.isEmpty()){
                System.debug('lstOfEmails ---- ' + lstOfEmails);
                Messaging.sendEmail(lstOfEmails);                                
            }
            
            //actual posting of bell notif
            if(!notifications.isEmpty()){
                for(Messaging.CustomNotification notif: notifications.keySet()){
                    System.debug('recipients ==== ' + notifications.get(notif));
                    notif.send(notifications.get(notif));
                }
            }
        } catch(Exception ex){
            System.debug('Exception ---- ' + ex.getMessage());
        }
    }    

    private static Messaging.CustomNotification createCustomNotification(Messaging.CustomNotification notification, Opportunity oppty, CustomNotificationType notificationType) {
        
        if (oppty.StageName == 'Closed Won'){
            // Set the contents for the notification
            notification.setTitle('An Opportunity is set to Closed Won!');
            notification.setBody('This Opportunity '+ oppty.L2I_Opportunity_Number__c+ ':' +oppty.Name +' has been set to Closed Won.');   
        } else if (oppty.StageName == 'Handoff'){
            // Set the contents for the notification
            notification.setTitle('An Opportunity is set to Handoff!');
            notification.setBody('This Opportunity '+ oppty.L2I_Opportunity_Number__c+ ':' +oppty.Name +' has been set to Handoff.');
        } else if (oppty.StageName == 'Delivery'){
            // Set the contents for the notification
            notification.setTitle('An Opportunity is set to Delivery!');
            notification.setBody('This Opportunity '+ oppty.L2I_Opportunity_Number__c+ ':' +oppty.Name +' has been set to Delivery.');
        }        

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(oppty.Id);
        
        return notification;
    }
    
    private static Map<Id, String> getUserFromPublicGroup(String prodCategory, String region){        
        Map<Id, String> userIdEmailMap = new Map<Id, String>();
        
        String groupName = region +'_'+ prodCategory;
        
        for(User  userRec: [Select Id, Email, isActive From User Where Id in (Select userorgroupid From groupmember Where Group.Name =: groupName )]){
            if(userRec.isActive){
                userIdEmailMap.put(userRec.Id, userRec.Email);
            }
        }        
        
        return userIdEmailMap;
    }
    /*
    private static List<User> getContractsTeam(){
        List<User> contractsTeam = new List<User>();        
        
        for(User  userRec: [Select Id, Email, isActive, Assigned_Product_Category__c, Assigned_Region__c From User WHERE IsActive = TRUE AND Is_Contract_User__c = TRUE]){
        	contractsTeam.add(userRec);          
        }
        system.debug('contractsTeam --- ' + contractsTeam);
        return contractsTeam;
    }*/
    
    private static List<String> removeExemptedEmailAddresses(List<String> emailAddressList){
        if(!exemptedEmailAddresses.isEmpty()){
            for(String emailStr: exemptedEmailAddresses){
                if(emailAddressList.contains(emailStr)){
                    emailAddressList.remove(emailAddressList.indexOf(emailStr));
                }
        	}
        }
        return emailAddressList;
    }
    
    /*private static List<String> getUserEmailIdFromContractsList(String productCategory, String region, List<Opportunity_Stage_Send_Notification__mdt> contractsTeamList, String notifType){
        
        List<String> userEmailList = new List<String>();
        
        System.debug('productCategory --- ' + productCategory);
        System.debug('region --- ' + region);
                        
        for(Opportunity_Stage_Send_Notification__mdt userRecInfo: contractsTeamList){
            if(userRecInfo.Product_Category__c.containsIgnoreCase(productCategory) && userRecInfo.Region__c.containsIgnoreCase(region)){
                if (notifType == 'Email'){
                    userEmailList.add(userRecInfo.Email__c);
                }
                else if (notifType == 'Bell'){
                    userEmailList.add(userRecInfo.User_ID__c);
                }
            }
        }        
        
        return userEmailList;
    }
   
    private static List<Opportunity_Stage_Send_Notification__mdt> getContractsTeamInfoList(){
        List<Opportunity_Stage_Send_Notification__mdt> contractsInfoList = new List<Opportunity_Stage_Send_Notification__mdt>();               
        
        //query the Opportunity_Stage_Send_Notification__mdt custom metadata for the contracts user info
        for(Opportunity_Stage_Send_Notification__mdt contractsUser: [SELECT Username__c, Region__c, Email__c, Product_Category__c, User_ID__c FROM Opportunity_Stage_Send_Notification__mdt WHERE Is_Active__c = TRUE]){     
            contractsInfoList.add(contractsUser);
        }
        
        return contractsInfoList;
    }*/
       
    private static Map<String, String> getUserEmailFromOpportunityTeam(String opptyID){
        Map<String, String> userEmailList = new Map<String, String>();
        
        for(OpportunityTeamMember member: [SELECT Id, Name, TeamMemberRole, User.Email, User.Id FROM OpportunityTeamMember WHERE OpportunityId =: opptyID ]){
            userEmailList.put(member.User.Email, member.User.Id);
        }
		System.debug('userEmailList --- ' +userEmailList);        
        return userEmailList;
    }
    
    private static Map<String, String> getEmailFromPublicGroup(){
        
        String publicGroupName = '';
        Map<String, String> userEmailSet= new Map<String, String>();        
        
        Send_Email_Notification_Setting__c settings = Send_Email_Notification_Setting__c.getInstance();	
        
        if(settings.Is_Active__c){
            if(!String.isBlank(settings.Public_Group__c)){
            	publicGroupName = settings.Public_Group__c;
            }
            System.debug('publicGroupName --- ' + publicGroupName);
            if(!String.isBlank(settings.Additional_Emails__c)){
                for(String emailString: settings.Additional_Emails__c.split(';')){
                    userEmailSet.put(emailString, '');
                }
            }
            System.debug('userEmailSet --- ' + userEmailSet);
            System.debug('Exception_Emails__c --- ' + settings.Exception_Emails__c);
            if(!String.isBlank(settings.Exception_Emails__c)){
                for(String emailString: settings.Exception_Emails__c.split(';')){                    
                    exemptedEmailAddresses.add(emailString);
                }
            }
            System.debug('exemptedEmailAddresses --- ' + exemptedEmailAddresses);
        }
                          
        for(User  userRec: [Select Id, Email, isActive From User Where Id in (Select userorgroupid From groupmember Where Group.Name =: publicGroupName)]){
            if(userRec.isActive){
                userEmailSet.put(userRec.Email, userRec.Id);
            }
        }
        
        System.debug('userEmailSet --- ' + userEmailSet);        
        return userEmailSet;
    }
    
    private static String constructHTMLEmailBodyClosedWonHandoffOppty(Opportunity opptyRec, String opptyStage){
        
        EmailContentFieldValueWrapper emailContent = new EmailContentFieldValueWrapper(opptyRec);
        
        String stageContent = ' has been Closed Won!';
        if(opptyStage == 'Handoff'){
            stageContent = ' has been set to Handoff!';
        }
        
        String htmlBody = 
            '<html>'
            +'<br/>'
            +'<div>Sales Opportunity '+ opptyRec.L2I_Opportunity_Number__c + stageContent + ' Please see the details below:</div>'
            +'<br/>'
            +'<table border="1" style="border-collapse: collapse; padding:5px">'
            +'<tr>'
                +'<th>Sales Opportunity</th>'               
                +'<th>Region</th>'
            	+'<th>Stage</th>'
                +'<th>Owner</th>'
                +'<th>Operator</th>'
                +'<th>PO Provider</th>'
            	+'<th>Fit Type</th>'
            	+'<th>Primary System Type</th>'                             
                +'<th>Aircraft</th>'
                +'<th>Aircraft Qty</th>';
        		if (opptyStage == 'Handoff'){
            		htmlBody +=
                    '<th>PM</th>';
                	//+'<th>PA</th>';
        		}
            htmlBody += '</tr>'
            +'<tr>'
            	+'<td><a href="'+opptyRec.Opportunity_Link__c+'">' + emailContent.OpportunityNumber + '</a></td>'                
            	+'<td>' + emailContent.Region + '</td>'
            	+'<td>' + emailContent.StageName + '</td>'
            	+'<td>' + emailContent.OwnerName + '</td>'
            	+'<td>' + emailContent.OperatorName + '</td>'
            	+'<td>' + emailContent.POIssuer + '</td>'
            	+'<td>' + emailContent.FitType + '</td>'
            	+'<td>' + emailContent.Primarytype + '</td>'
            	+'<td>' + emailContent.Aircraft + '</td>'
            	+'<td>' + emailContent.AircraftCount + '</td>';
        		if (opptyStage == 'Handoff'){
            		htmlBody +=
            		'<td>' + emailContent.ProgramManager + '</td>';
            		//+'<td>' + emailContent.PLApprover + '</td>';
        		}
            htmlBody += '</tr>'
            +'</table>'
            +'</html>';

    	system.debug('Email Body: ' + htmlBody);   
    	return htmlBody;

    }
    
    private static String constructHTMLEmailBody(Opportunity opptyRec){
        
        EmailContentFieldValueWrapper emailContent = new EmailContentFieldValueWrapper(opptyRec);
        
        String htmlBody = 
            '<html>'
            +'<br/>'
            +'<div>Sales Opportunity '+ emailContent.OpportunityNumber +' has been set to Delivery! Please see the details below:</div>'
            +'<br/>'
            +'<table border="1" style="border-collapse: collapse; padding:5px">'
            +'<tr>'
                +'<th>Sales Opportunity</th>'
                +'<th>Program Number</th>'
                +'<th>Region</th>'
            	+'<th>Stage</th>'
                +'<th>Owner</th>'
                +'<th>Operator</th>'
                +'<th>PO Provider</th>'
            	+'<th>Fit Type</th>'
            	+'<th>Primary System Type</th>'                             
                +'<th>Aircraft</th>'
                +'<th>Aircraft Qty</th>'
                +'<th>PM</th>'
                //+'<th>PA</th>'
            +'</tr>'
            +'<tr>'
            	+'<td><a href="'+ opptyRec.Opportunity_Link__c +'">' + emailContent.OpportunityNumber + '</a></td>'
            	+'<td>' + emailContent.ProgramNumber + '</td>'
            	+'<td>' + emailContent.Region + '</td>'
            	+'<td>' + emailContent.StageName + '</td>'
            	+'<td>' + emailContent.OwnerName + '</td>'
            	+'<td>' + emailContent.OperatorName + '</td>'
            	+'<td>' + emailContent.POIssuer + '</td>'
            	+'<td>' + emailContent.FitType + '</td>'
            	+'<td>' + emailContent.Primarytype + '</td>'
            	+'<td>' + emailContent.Aircraft + '</td>'
            	+'<td>' + emailContent.AircraftCount + '</td>'
            	+'<td>' + emailContent.ProgramManager + '</td>'
            	//+'<td>' + emailContent.PLApprover + '</td>'       
            +'</tr>'
            +'</table>'
            +'</html>';

    	system.debug('Email Body: ' + htmlBody);   
    	return htmlBody;
    }
    
    private class EmailContentFieldValueWrapper{
        
        String OpportunityNumber = '';
        String ProgramNumber = '';
        String Region = '';
        String StageName = '';
        String OwnerName = '';
        String OperatorName = '';
        String POIssuer = '';
        String FitType = '';
        String Primarytype = '';
        String Aircraft = '';
        String AircraftCount = '';
        String PMOGroup = '';
        String ProgramManager = '';
        String PLApprover = '';
                
        EmailContentFieldValueWrapper(Opportunity opptyRec){
            this.OpportunityNumber = opptyRec.L2I_Opportunity_Number__c != NULL ? opptyRec.L2I_Opportunity_Number__c : this.OpportunityNumber;
            this.ProgramNumber = opptyRec.L2I_Program_Num__r.Name != NULL ? opptyRec.L2I_Program_Num__r.Name : this.ProgramNumber;
            this.Region = opptyRec.L2I_Oppt_Region__c != NULL ? opptyRec.L2I_Oppt_Region__c : this.Region;
            this.StageName = opptyRec.StageName != NULL ? opptyRec.StageName : this.StageName;
            this.OwnerName = opptyRec.Owner.Name != NULL ? opptyRec.Owner.Name : this.OwnerName;
            this.OperatorName = opptyRec.L2I_AC_Operator__r.Name != NULL ? opptyRec.L2I_AC_Operator__r.Name : this.OperatorName;
            this.POIssuer = opptyRec.L2I_PO_Issuer__r.Name != NULL ? opptyRec.L2I_PO_Issuer__r.Name : this.POIssuer;
            this.FitType = opptyRec.L2I_Fit_Type__c != NULL ? opptyRec.L2I_Fit_Type__c : this.FitType;
            this.Primarytype = opptyRec.L2I_Primary_System_Type__r.Name != NULL ? opptyRec.L2I_Primary_System_Type__r.Name : this.Primarytype;
            this.Aircraft = opptyRec.L2I_AircraftType__c != NULL ? opptyRec.L2I_AircraftType__c : this.Aircraft;
            this.AircraftCount = opptyRec.L2I_AircraftQuantity__c != NULL ? opptyRec.L2I_AircraftQuantity__c+'' : this.AircraftCount;
            this.PMOGroup = opptyRec.L2I_Program_Num__r.PT_PMO_Group__r.Name != NULL ? opptyRec.L2I_Program_Num__r.PT_PMO_Group__r.Name : this.PMOGroup;
            this.ProgramManager = opptyRec.PT_Program_Mgr__r.Name != NULL ? opptyRec.PT_Program_Mgr__r.Name : this.ProgramManager;
            this.PLApprover = opptyRec.PT_PL_Approval_Approver__r.Name != NULL ? opptyRec.PT_PL_Approval_Approver__r.Name : this.PLApprover;            
        }        
    }

}