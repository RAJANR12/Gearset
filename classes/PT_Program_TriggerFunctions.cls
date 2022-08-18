/**
 *      @author       Sarah Kennedy
 *      @date         04/27/2020
 *      @description  Trigger Functions for PT_ProgramTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy               04/27/2020          Initial scaffold
 *      Dan Morris                  07/17/2020          Modified Name generation
 *      Sarah Kennedy               09/29/2020          Manage PM queue for Approval process
 */

public without sharing class PT_Program_TriggerFunctions {
    static public Id inactiveTypeId = Schema.SObjectType.PT_Program__c.getRecordTypeInfosByDeveloperName().get('Inactive').getRecordTypeId();
    static public Id productionTypeId = Schema.SObjectType.PT_Program__c.getRecordTypeInfosByDeveloperName().get('Production').getRecordTypeId();
    static public Id retrofitTypeId = Schema.SObjectType.PT_Program__c.getRecordTypeInfosByDeveloperName().get('Retrofit').getRecordTypeId();
    
    public static void addUpdateProgramName(List<PT_Program__c> newProgramList) {
        for (PT_Program__c program : newProgramList) {
            // Always update the program with the program number
            //program.Name = program.Program_Number__c;
            // enforce Aircraft_Identifier_Field__c
            if (program.PT_Program_Type__c == 'Production-AIRBUS' && program.Aircraft_Identifier_Field__c != 'Serial Number') {
                program.Aircraft_Identifier_Field__c = 'Serial Number';
            } else if (program.PT_Program_Type__c == 'Production-BOEING' && program.Aircraft_Identifier_Field__c != 'Block Number') {
                program.Aircraft_Identifier_Field__c = 'Block Number';
            }
            // If program is marked as inactive, update record type to inactive
            if (program.PT_isActive__c == 'Inactive') {
                        program.RecordTypeId = inactiveTypeId;
            } else { // if marked active, then update record type based on aircraft type
                if (program.PT_Program_Type__c != null && program.PT_Program_Type__c.startsWith('Retrofit')) {
                    program.RecordTypeId = retrofitTypeId;
                } else {
                    program.RecordTypeId = productionTypeId;
                }
            }
        }
    }
    
    public static void updateProgramOnOpportunity(List<PT_Program__c> newProgramList) {
        
        Map<Id, String> programOppMap = new Map<Id, String>();
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        // if the program name is the opportunity Id, then we need to update that opportunity Id with the real program name
        // this would happen if an Opp was IFEC and Closed Won with no Program relationship
        // in that case the Program is created and we need to update the Opp Program Name field now that we know the Program Id
        for (PT_Program__c program : newProgramList) {
            if (program.Sales_Opportunity__c != null) {
                programOppMap.put(program.Id, program.Sales_Opportunity__c);
            }
        }
        if (!programOppMap.isEmpty()) {
            for (Opportunity opp : [
                  SELECT Id,
                        L2I_Program_Num__c,
                        AccountId,
                        Account.L2I_Operator_Number__c,
                        L2I_Delivery_Schedule__r.Aircraft_Type__r.L2I_PAC_Type_Designator__c
                  FROM Opportunity
                  WHERE Id IN :programOppMap.values()
            ]) {
                oppMap.put(opp.Id, opp);
            }
            for (PT_Program__c prog : [
                  SELECT Id,
                        Name,
                        Name__c,
                        Sales_Opportunity__c
                  FROM PT_Program__c
                  WHERE Id IN :programOppMap.keySet()
            ]) {
                Opportunity oppty = oppMap.get(prog.Sales_Opportunity__c);
                oppty.L2I_Program_Num__c = prog.Id;
                oppty.PT_Part_List_Name__c = 'CPL-' + prog.Name + '-1';
                oppToUpdateList.add(oppty);
            }
            update oppToUpdateList;
        }
    }
    
    public static void inactiveProgramValidation(List<PT_Program__c> newProgramList, Map<Id, PT_Program__c> oldProgramMap) {
        Set<Id> progIds = new Set<Id>();
        for (PT_Program__c newPgm : newProgramList) {
            PT_Program__c oldPgm = oldProgramMap.get(newPgm.Id);
            
            if (newPgm.PT_isActive__c == 'Inactive' && newPgm.PT_isActive__c != oldPgm.PT_isActive__c) {
                progIds.add(newPgm.Id);
            }
        }
        if (!progIds.isEmpty()) {
            Map<Id, PT_Program__c> programActiveDslMap = new Map<Id, PT_Program__c>(
            [
                  SELECT Id, (SELECT Id FROM Delivery_Schedule_Lines__r WHERE PT_isActive__c = 'Active' LIMIT 1)
                  FROM PT_Program__c
                  Where Id IN :progIds
            ]);
            
            for (PT_Program__c newPgm : newProgramList) {
                if (programActiveDslMap.containsKey(newPgm.Id)) {
                    PT_Program__c prog = programActiveDslMap.get(newPgm.Id);
                    if (prog.Delivery_Schedule_Lines__r != null && prog.Delivery_Schedule_Lines__r.size() > 0) {
                        newPgm.addError('Program cannot be marked Inactive with Active Shipsets.');
                    }
                }
            }
        }
    }
    
    public static void addProgramMgrToPMQueue(List<PT_Program__c> newProgramList) {
        Set<Id> pgmMgrs = new Set<Id>();
        
        for (PT_Program__c newPgm : newProgramList) {
            if (newPgm.Program_Manager__c != null) {
                pgmMgrs.add(newPgm.Program_Manager__c);
            }
        }
        
        Group grp = [
              SELECT Id
              FROM Group
              WHERE Group.Name = 'Program PM Group'
              AND Group.Type = 'Regular'
              LIMIT 1
        ];
        if (grp != null &&
              !pgmMgrs.isEmpty()) {
            // calling future method to avoid MIXED_DML_OPERATION (Program was inserted then inserting into GroupMember setup object)
            addMembersToQueue (pgmMgrs, grp.Id);
        }
    }
    
    @future
    private static void addMembersToQueue(Set<Id> pgmMgrs, Id grpId) {
        List<GroupMember> newGmList = new List<GroupMember>();
        for (User u : [
              SELECT Id, Name
              FROM User
              WHERE Id IN :pgmMgrs
              AND Id NOT IN (
                    SELECT UserOrGroupId
                    FROM GroupMember
                    WHERE Group.Id = :grpId
              )
        ]) {
            newGmList.add(new GroupMember(GroupId = grpId, UserOrGroupId = u.Id));
        }
        
        if (newGmList != null && newGmList.size() > 0) {
            insert newGmList;
        }
        System.debug('*** newGMList ' + newGmList);
    }
    
    public static void deleteProgramMgrFromPMQueue(List<PT_Program__c> oldProgramList) {
        Set<Id> pgmMgrsToRemove = new Set<Id>();
        Set<Id> pgmsDeleted = new Set<Id>();
        
        for (PT_Program__c oldPgm : oldProgramList) {
            if (oldPgm.Program_Manager__c != null) {
                pgmMgrsToRemove.add(oldPgm.Program_Manager__c);
                pgmsDeleted.add(oldPgm.Id);
            }
        }
        
        Group grp = [
              SELECT Id
              FROM Group
              WHERE Group.Name = 'Program PM Group'
              AND Group.Type = 'Regular'
              LIMIT 1
        ];
        
        if (grp != null &&
              !pgmMgrsToRemove.isEmpty()) {
            // calling future method to avoid MIXED_DML_OPERATION (Program was deleted then deleting into GroupMember setup object)
            deleteMembersFromQueue (pgmMgrsToRemove, pgmsDeleted, grp.Id);
        }
    }
    
    @future
    private static void deleteMembersFromQueue(Set<Id> pgmMgrsToRemove, Set<Id> pgmsDeleted, Id grpId) {
        List<GroupMember> deleteGmList = new List<GroupMember>();
        
        // if other Programs have the PM, don't delete from the queue
        for (PT_Program__c pg : [
              SELECT Id, Name, Program_Manager__c, Program_Manager__r.Name
              FROM PT_Program__c
              WHERE Id NOT IN :pgmsDeleted
        ]) {
            if (pgmMgrsToRemove.contains(pg.Program_Manager__c)) {
                System.debug('*** Cannot remove from queue - Program Manager ' + pg.Program_Manager__r.Name + ' ' + pg.Program_Manager__c + ' exists in another Program ' + pg.Name + ' ' + pg.Id);
                pgmMgrsToRemove.remove(pg.Program_Manager__c);
            }
        }
        
        if (!pgmMgrsToRemove.isEmpty()) {
            for (GroupMember gm : [
                  SELECT Id
                  FROM GroupMember
                  WHERE Group.Id = :grpId
                  AND UserOrGroupId IN :pgmMgrsToRemove
            ]) {
                deleteGmList.add(gm);
            }
            System.debug('*** deleteGmList ' + deleteGmList);
            if (deleteGmList != null && deleteGmList.size() > 0) {
                delete deleteGmList;
            }
        }
    }
    
    public static void changeProgramMgrForPMQueue(List<PT_Program__c> newProgramList, Map<Id, PT_Program__c> oldProgramMap) {
        List<PT_Program__c> deletePgmList = new List<PT_Program__c>();
        List<PT_Program__c> addPgmList = new List<PT_Program__c>();
        
        for (PT_Program__c newPgm : newProgramList) {
            PT_Program__c oldPgm = oldProgramMap.get(newPgm.Id);
            
            if (newPgm.Program_Manager__c != oldPgm.Program_Manager__c) {
                if (oldPgm.Program_Manager__c != null) {
                    deletePgmList.add(oldPgm);
                }
                if (newPgm.Program_Manager__c != null) {
                    addPgmList.add(newPgm);
                }
            }
        }
        if (deletePgmList.size() > 0) {
            deleteProgramMgrFromPMQueue(deletePgmList);
        }
        if (addPgmList.size() > 0) {
            addProgramMgrToPMQueue(addPgmList);
        }
    }
    
    
    public static void getNewPMOUser(List<PT_Program__c> newProgramList) {
        Set<Id> pmoIds = new Set<Id>();
        
        for (PT_Program__c newPgm : newProgramList) {
            if (newPgm.PT_PMO_Group__c != null) {
                pmoIds.add(newPgm.PT_PMO_Group__c);
            }
            if (newPgm.PT_PMO_SubGroup__c != null) {
                pmoIds.add(newPgm.PT_PMO_SubGroup__c);
            }
        }
        
        if (!pmoIds.isEmpty()) {
            for (PT_PMO_Groups__c pmoGrp : [SELECT Id, OwnerId, Group_Type__c FROM PT_PMO_Groups__c WHERE Id In :pmoIds]) {
                for (PT_Program__c newPgm : newProgramList) {
                    if (newPgm.PT_PMO_Group__c == pmoGrp.Id &&
                          pmoGrp.Group_Type__c == 'Group') {
                        newPgm.PMO_Regional_Director__c = pmoGrp.OwnerId;
                    }
                    if (newPgm.PT_PMO_SubGroup__c == pmoGrp.Id &&
                          pmoGrp.Group_Type__c == 'Sub Group') {
                        newPgm.Principal_Program_Manager__c = pmoGrp.OwnerId;
                    }
                }
            }
        }
    }
    
    public static void getChangedPMOUser(List<PT_Program__c> newProgramList, Map<Id, PT_Program__c> oldProgramMap) {
        Set<Id> pmoIds = new Set<Id>();
        
        for (PT_Program__c newPgm : newProgramList) {
            PT_Program__c oldPgm = oldProgramMap.get(newPgm.Id);
            
            if (newPgm.PT_PMO_Group__c != oldPgm.PT_PMO_Group__c) {
                if (newPgm.PT_PMO_Group__c == null) {
                    newPgm.PMO_Regional_Director__c = null;
                } else {
                    pmoIds.add(newPgm.PT_PMO_Group__c);
                }
            }
            if (newPgm.PT_PMO_SubGroup__c != oldPgm.PT_PMO_SubGroup__c) {
                if (newPgm.PT_PMO_SubGroup__c == null) {
                    newPgm.Principal_Program_Manager__c = null;
                } else {
                    pmoIds.add(newPgm.PT_PMO_SubGroup__c);
                }
            }
        }
        System.debug('*** pmoIDs ' + pmoIds);
        
        if (!pmoIds.isEmpty()) {
            for (PT_PMO_Groups__c pmoGrp : [SELECT Id, OwnerId, Group_Type__c FROM PT_PMO_Groups__c WHERE Id IN :pmoIds]) {
                for (PT_Program__c newPgm : newProgramList) {
                    if (newPgm.PT_PMO_Group__c == pmoGrp.Id &&
                          pmoGrp.Group_Type__c == 'Group') {
                        newPgm.PMO_Regional_Director__c = pmoGrp.OwnerId;
                    }
                    if (newPgm.PT_PMO_SubGroup__c == pmoGrp.Id &&
                          pmoGrp.Group_Type__c == 'Sub Group') {
                        newPgm.Principal_Program_Manager__c = pmoGrp.OwnerId;
                    }
                    System.debug('*** newPgm ' + newPgm);
                }
            }
        }
    }
    
    public static void preventSubmitterFromApproving(List<PT_Program__c> newProgramList, Map<Id, PT_Program__c> oldProgramMap) {
        Set<Id> pgmIds = new Set<Id>();
        Set<Id> pgmD1Ids = new Set<Id>();
        String userProfileName = '';
        Id userProfileId = UserInfo.getProfileId();
        Map<Id, Id> pgmIdSubmitterMap = new Map<Id, Id>();
        Map<Id, Id> pgmD1IdSubmitterMap = new Map<Id, Id>();
        Set<Id> pgmsWithError = new Set<Id>();
        Set<Id> pgmsD1WithError = new Set<Id>();
        Boolean skipSubmitterCheck = false;
        
        Id userId = UserInfo.getUserId();
        String userName = UserInfo.getUserName();
        System.debug('*** userName ' + userName);
        if (!userName.startsWith('autoproc')) {      // Automated Process user has no profile - it's an internal fake user
            userProfileName = [SELECT Id, Name FROM Profile WHERE Id = :userProfileId].Name;
            System.debug('====== Running user profile name :' + userProfileName);
        }
        // let admins and auto-process continue even if they were the submitter
        if (userName.startsWith('autoproc') ||
              userProfileName == 'System Administrator' ||
              userProfileName == 'PAC System Administrator') {
            return;
        }
        
        // when MROD approval step changes, the submitter cannot also be the approver
        for (PT_Program__c newPgm : newProgramList) {
            PT_Program__c oldPgm = oldProgramMap.get(newPgm.Id);
            System.debug('*** newPgm.MROD_Approval_Step__c ' + newPgm.MROD_Approval_Step__c);
            System.debug('*** oldPgm.MROD_Approval_Step__c ' + oldPgm.MROD_Approval_Step__c);
            System.debug('*** newPgm.MROD_Approval_Submitter__c ' + newPgm.MROD_Approval_Submitter__c);
            System.debug('*** UserInfo.getUserId() ' + UserInfo.getUserId());
            if (newPgm.MROD_Approval_Step__c != oldPgm.MROD_Approval_Step__c &&
                  !String.isBlank(newPgm.MROD_Approval_Step__c)) {
                if (newPgm.MROD_Approval_Submitter__c == UserInfo.getUserId()) {
                    newPgm.addError('Submitter cannot also Approve');
                }
            }
        }
    }
    public static void  preventnonQueueMemberFromApproving(List<PT_Program__c> newProgramList, Map<Id, PT_Program__c> oldProgramMap) {
        System.debug('*** Starting prevent nonQueueMemberFromApproving ***');
     
         Map<Id, Id> cplpplIdApproverMap = new Map<Id, Id>();
         Set<Id> prgmsWithError = new Set<Id>();
         String userProfileName = '';
         Id userProfileId = UserInfo.getProfileId();
        
         //Get the queueid
         QueueSobject qo = [SELECT Queue.Id, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName = 'Program_PM_PPM_Queue' LIMIT 1];
         //Get the GroupMember Groups
         Set<id> groupIdSet = new Set<id>();
             for( groupMember gm : [Select id, UserorGroupId from GroupMember where GroupId = :qo.Queue.id]){
                 GroupIdSet.Add(gm.UserorGroupId);
             }
         //Get the user ids
         Set<id> userIdSet = new Set<id>();
             for(GroupMember gm : [Select Id, UserOrGroupId from GroupMember where GroupId in : GroupIdSet]){
                 userIdSet.Add(gm.UserOrGroupId);
             }
 
         Id userId = UserInfo.getUserId();
         String userName = UserInfo.getUserName();
     
         if (!userName.startsWith('autoproc')) {      // Automated Process user has no profile - it's an internal fake user
             userProfileName = [SELECT Id, Name FROM Profile WHERE Id = :userProfileId].Name;
         }
 
        if (userName.startsWith('autoproc') ||
             userProfileName == 'System Administrator'){
             return;
         }  
 
         for(user thisuser  :[ select firstname, lastname from user where id in :userIdSet order by lastname]){
             system.debug(thisuser.firstname +' ' + thisuser.lastname);
         } 
 
         for (PT_Program__c newPgm : newProgramList) {
            PT_Program__c oldPgm = oldProgramMap.get(newPgm.Id);
            System.debug('*** newPgm.MROD_Approval_Step__c ' + newPgm.MROD_Approval_Step__c);
            System.debug('*** oldPgm.MROD_Approval_Step__c ' + oldPgm.MROD_Approval_Step__c);
            System.debug('*** newPgm.MROD_Approval_Submitter__c ' + newPgm.MROD_Approval_Submitter__c);
            System.debug('*** UserInfo.getUserId() ' + UserInfo.getUserId());
            if (newPgm.MROD_Approval_Step__c != oldPgm.MROD_Approval_Step__c &&
                  !String.isBlank(newPgm.MROD_Approval_Step__c)) {
                if (!userIdSet.contains(userinfo.getUserId())) {
                    newPgm.addError('This user cannot approve because they are not a member of the Program PM PPM Queue ');
                }
            }
        }   
     }
    
    public static void updateAssetsInstLocsOnProgramMRODApproved(List<PT_Program__c> newProgramList, Map<Id, PT_Program__c> oldProgramMap) {
        Set<Id> pgmIds = new Set<Id>();
        Set<Id> pgmD1Ids = new Set<Id>();
        //Set<Id> instLocIds = new Set<Id>();
        Map<Id, List<Asset>> instLocIds = new Map<Id, List<Asset>>();
        List<PT_Install_Location__c> installLocList = new List<PT_Install_Location__c>();
        List<PT_Install_Location__c> installUpdateLocList = new List<PT_Install_Location__c>();
        List<Asset> assetList = new List<Asset>();
        List<Asset> assetUpdateList = new List<Asset>();
        Map<Id, List<Asset>> dslIdAssetMap = new Map<Id, List<Asset>>();
        List<L2I_DSL__c> dslUpdateList = new List<L2I_DSL__c>();
        
        for (PT_Program__c newPgm : newProgramList) {
            PT_Program__c oldPgm = oldProgramMap.get(newPgm.Id);
            if (newPgm.MROD_Approval_Status__c != oldPgm.MROD_Approval_Status__c &&
                  newPgm.MROD_Approval_Status__c == 'Approved') {
                System.debug('*** Approved Program: ' + newPgm.Name);
                pgmIds.add(newPgm.Id);
            }
        }
        
        for (PT_Program__c newPgm : newProgramList) {
            PT_Program__c oldPgm = oldProgramMap.get(newPgm.Id);
            if (newPgm.Airbus_MROD_Approval_Status__c != oldPgm.Airbus_MROD_Approval_Status__c &&
                  newPgm.Airbus_MROD_Approval_Status__c == 'Approved') {
                System.debug('*** Approved D1 Program: ' + newPgm.Name);
                pgmD1Ids.add(newPgm.Id);
            }
        }
        
        if (!pgmIds.isEmpty()) {
            assetList = [
                  SELECT Id, PT_MROD__c, PT_Pending__c, PT_Install_Location__c, PT_Status__c, PT_Install_Location__r.Status__c,
                        PT_Install_Location__r.Solution_Group__r.PT_is_Head_End__c, PT_Install_Location__r.Solution_Group__r.PT_is_Seat_End__c,
                        PT_Install_Location__r.ShipSet__c,
                        PT_Program__c, PT_Can_Be_Processed__c,
                        PT_Install_Location__r.Part_List_Opportunity__c,
                        PT_Install_Location__r.Part_List_Opportunity__r.PT_PL_Approval_Status__c
                  FROM Asset
                  WHERE PT_Program__c IN :pgmIds
                  AND PT_Can_Be_Processed__c = true
            ];
            System.debug('*** assetList.size() ' + assetList.size());
            
            for (Asset ast : assetList) {
                System.debug('*** ast ' + ast);
                System.debug('*** ast.PT_Install_Location__r.Status__c ' + ast.PT_Install_Location__r.Status__c);
                System.debug('*** ast.PT_Install_Location__r.Part_List_Opportunity__c  ' + ast.PT_Install_Location__r.Part_List_Opportunity__c);
                System.debug('*** ast.PT_Install_Location__r.Part_List_Opportunity__r.PT_PL_Approval_Status__c  ' + ast.PT_Install_Location__r.Part_List_Opportunity__r.PT_PL_Approval_Status__c);
                if (ast.PT_Install_Location__r.Status__c == 'Active') {
                    // skip updating assets if there is an in-process Part List Approval for the same asset
                    if (ast.PT_Install_Location__c != null &&
                          (ast.PT_Install_Location__r.Part_List_Opportunity__c != null &&
                                ast.PT_Install_Location__r.Part_List_Opportunity__r.PT_PL_Approval_Status__c != 'Pending') ||
                          (ast.PT_Install_Location__r.ShipSet__c != null)) {
                        if (ast.PT_Pending__c != null) {
                            ast.PT_MROD__c = ast.PT_Pending__c;
                            ast.PT_Pending__c = null;
                            assetUpdateList.add(ast);
                        }
                        if (ast.PT_Install_Location__c != NULL) {
                            //instLocIds.add(ast.PT_Install_Location__c);
                            if(!instLocIds.containsKey(ast.PT_Install_Location__c)){
                                instLocIds.put(ast.PT_Install_Location__c, new List<Asset>());
                            }
                            List<Asset> sList = instLocIds.get(ast.PT_Install_Location__c);
                            sList.add(ast);
                            instLocIds.put(ast.PT_Install_Location__c, sList);
                        }
                        // save off Assets in Shipsets for Date Rollup logic
                        if (ast.PT_MROD__c != null &&
                              ast.PT_Install_Location__r.ShipSet__c != null) {
                            if (!dslIdAssetMap.containsKey(ast.PT_Install_Location__r.ShipSet__c)) {
                                dslIdAssetMap.put(ast.PT_Install_Location__r.ShipSet__c, new List<Asset>());
                            }
                            List<Asset> sList = dslIdAssetMap.get(ast.PT_Install_Location__r.ShipSet__c);
                            sList.add(ast);
                            dslIdAssetMap.put(ast.PT_Install_Location__r.ShipSet__c, sList);
                        }
                    }
                }
            }
            installLocList = [
                  SELECT Id, MROD__c, Pending_MROD__c, Allow_Past_Due_Pending_MROD_Date__c
                  FROM PT_Install_Location__c
                  WHERE Id IN :instLocIds.keySet()
            ];
            for (PT_Install_Location__c iloc : installLocList) {
                if (iloc.Pending_MROD__c != null) {
                    iloc.MROD__c = iloc.Pending_MROD__c;
                    // allow past due Pending MROD Dates
                    // this should have been caught when updating the Pending MROD Date for the Install Loc on the Grid.
                    iloc.Allow_Past_Due_Pending_MROD_Date__c = true;
                    iloc.Pending_MROD__c = null;
                    installUpdateLocList.add(iloc);
                }
                
                Date minDate;
                Date avgMRODDate;
                
                for(Asset ast: instLocIds.get(iloc.Id)){
                    System.debug('*** ast ' + ast);
                    if (ast.PT_MROD__c != null) {
                        if (minDate == null || ast.PT_MROD__c < minDate) {
                            minDate = ast.PT_MROD__c;
                        }
                    }
                }
                System.debug('*** minDate ' + minDate);
                if (minDate != null) {
                    Integer astCount = 0;
                    Integer daysBtwn = 0;
                    for (Asset ast : instLocIds.get(iloc.Id)) {
                        System.debug('*** checking headend ' + ast);
                        if (ast.PT_MROD__c != null) {
                            daysBtwn += minDate.daysBetween(ast.PT_MROD__c);
                            astCount++;
                            System.debug('*** daysBtwn ' + daysBtwn);
                            System.debug('*** astCount ' + astCount);
                        }
                    }
                    if (astCount != 0) {
                        Integer avgHeadDays = daysBtwn / astCount;
                        System.debug('*** avgHeadDays ' + avgHeadDays);
                        avgMRODDate = minDate.addDays(avgHeadDays);
                        System.debug('*** avgMRODDate ' + avgMRODDate);
                    }
                }
                
                //assign the unweighted ave
                iloc.MROD__c = avgMRODDate;
                
                if(!installUpdateLocList.contains(iloc)){
                    installUpdateLocList.add(iloc);
                }
            }
            
            System.debug('*** Pending installUpdateLocList.size() ' + installUpdateLocList.size());
            System.debug('*** Pending assetUpdateList.size() ' + assetUpdateList.size());
            
            if (installUpdateLocList.size() > 0) {
                update installUpdateLocList;
            }
            // now clear the allowed past due flag
            for (PT_Install_Location__c iloc : installUpdateLocList) {
                if (iloc.Pending_MROD__c == null &&
                      iloc.Allow_Past_Due_Pending_MROD_Date__c == true) {
                    iloc.Allow_Past_Due_Pending_MROD_Date__c = false;
                }
            }
            System.debug('*** starting dsl rollup logic ');
            // Shipset Date Rollup Logic
            if (!dslIdAssetMap.isEmpty()) {
                Date minDate;
                Date avgHeadEndDate;
                Date avgSeatEndDate;
                for (L2I_DSL__c dsl : [
                      SELECT Id, Asset_Min_MROD_Date__c, Asset_Avg_Head_End_MROD_Date__c, Asset_Avg_Seat_End_MROD_Date__c
                      FROM L2I_DSL__c
                      WHERE Id IN :dslIdAssetMap.keySet()
                ]) {
                    System.debug('*** dsl rollup ' + dsl);
                    for (Asset ast : dslIdAssetMap.get(dsl.Id)) {
                        System.debug('*** ast ' + ast);
                        if (ast.PT_MROD__c != null) {
                            if (minDate == null || ast.PT_MROD__c < minDate) {
                                minDate = ast.PT_MROD__c;
                            }
                        }
                    }
                    System.debug('*** minDate ' + minDate);
                    if (minDate != null) {
                        Integer headCount = 0;
                        Integer headDays = 0;
                        for (Asset ast : dslIdAssetMap.get(dsl.Id)) {
                            System.debug('*** checking headend ' + ast);
                            if (ast.PT_MROD__c != null &&
                                  ast.PT_Install_Location__r.Solution_Group__r.PT_is_Head_End__c) {
                                headDays += minDate.daysBetween(ast.PT_MROD__c);
                                headCount++;
                                System.debug('*** headDays ' + headDays);
                                System.debug('*** headCount ' + headCount);
                            }
                        }
                        if (headCount != 0) {
                            Integer avgHeadDays = headDays / headCount;
                            System.debug('*** avgHeadDays ' + avgHeadDays);
                            avgHeadEndDate = minDate.addDays(avgHeadDays);
                            System.debug('*** avgHeadEndDate ' + avgHeadEndDate);
                        }
                    }
                    if (minDate != null) {
                        Integer seatCount = 0;
                        Integer seatDays = 0;
                        for (Asset ast : dslIdAssetMap.get(dsl.Id)) {
                            System.debug('*** checking seatend ' + ast);
                            if (ast.PT_MROD__c != null &&
                                  ast.PT_Install_Location__r.Solution_Group__r.PT_is_Seat_End__c) {
                                seatDays += minDate.daysBetween(ast.PT_MROD__c);
                                seatCount++;
                                System.debug('*** seatDays ' + seatDays);
                                System.debug('*** seatCount ' + seatCount);
                            }
                        }
                        if (seatCount != 0) {
                            Integer avgSeatDays = seatDays / seatCount;
                            System.debug('*** avgSeatDays ' + avgSeatDays);
                            avgSeatEndDate = minDate.addDays(avgSeatDays);
                            System.debug('*** avgSeatEndDate ' + avgSeatEndDate);
                        }
                    }
                    dsl.Asset_Min_MROD_Date__c = minDate;
                    dsl.Asset_Avg_Head_End_MROD_Date__c = avgHeadEndDate;
                    dsl.Asset_Avg_Seat_End_MROD_Date__c = avgSeatEndDate;
                    System.debug('*** dsl for update ' + dsl);
                    dslUpdateList.add(dsl);
                }
                if (!dslUpdateList.isEmpty() &&
                      dslUpdateList.size() > 0) {
                    System.debug('*** dslUpdateList.size() ' + dslUpdateList.size());
                    update dslUpdateList;
                }
            }
        }
        
        if (!pgmD1Ids.isEmpty()) {
            assetList = [
                  SELECT Id, PT_MROD__c, PT_Airbus_D1_Date__c, PT_Use_D1_Date__c,
                        PT_Install_Location__c, PT_Status__c, PT_Install_Location__r.Status__c,
                        PT_Program__c, PT_Can_Be_Processed__c, PT_Install_Location__r.ShipSet__c,
                        PT_Install_Location__r.Part_List_Opportunity__c, PT_Pending__c,
                        PT_Install_Location__r.Part_List_Opportunity__r.PT_PL_Approval_Status__c
                  FROM Asset
                  WHERE PT_Program__c IN :pgmD1Ids
                  AND PT_Can_Be_Processed__c = true
            ];
            for (Asset ast : assetList) {
                if (ast.PT_Install_Location__r.Status__c == 'Active') {
                    if (ast.PT_Install_Location__c != null &&
                          (ast.PT_Install_Location__r.Part_List_Opportunity__c != null &&
                                ast.PT_Install_Location__r.Part_List_Opportunity__r.PT_PL_Approval_Status__c != 'Pending') ||
                          (ast.PT_Install_Location__r.ShipSet__c != null)) {
                        if (ast.PT_Use_D1_Date__c == 'Yes') {
                            if (ast.PT_Airbus_D1_Date__c != null) {
                                ast.PT_MROD__c = ast.PT_Airbus_D1_Date__c;
                                ast.PT_Airbus_D1_Date__c = null;
                                assetUpdateList.add(ast);
                            }
                        } else {
                            if (ast.PT_Pending__c != null) {
                                ast.PT_MROD__c = ast.PT_Pending__c;
                                ast.PT_Pending__c = null;
                                assetUpdateList.add(ast);
                            }
                        }
                        if (ast.PT_Install_Location__c != NULL) {
                            //instLocIds.add(ast.PT_Install_Location__c);
                            instLocIds.put(ast.PT_Install_Location__c, null);
                        }
                    }
                }
            }
    
            installLocList = [
                  SELECT Id, MROD__c, Pending_D1_Date__c, Allow_Past_Due_Pending_MROD_Date__c
                  FROM PT_Install_Location__c
                  WHERE Id IN :instLocIds.keySet()
            ];
            for (PT_Install_Location__c iloc : installLocList) {
                if (iloc.Pending_D1_Date__c != null) {
                    iloc.MROD__c = iloc.Pending_D1_Date__c;
                    // allow past due Pending MROD Dates
                    // this should have been caught when updating the Pending MROD Date for the Install Loc on the Grid.
                    iloc.Allow_Past_Due_Pending_MROD_Date__c = true;
                    iloc.Pending_D1_Date__c = null;
                    installUpdateLocList.add(iloc);
                }
            }
    
            System.debug('*** Pending installUpdateLocList.size() ' + installUpdateLocList.size());
            System.debug('*** Pending assetUpdateList.size() ' + assetUpdateList.size());
    
            if (installUpdateLocList.size() > 0) {
                update installUpdateLocList;
            }
            // now clear the allowed past due flag
            for (PT_Install_Location__c iloc : installUpdateLocList) {
                if (iloc.Pending_D1_Date__c == null &&
                      iloc.Allow_Past_Due_Pending_MROD_Date__c == true) {
                    iloc.Allow_Past_Due_Pending_MROD_Date__c = false;
                }
            }
            
            System.debug('*** D1 assetUpdateList.size() ' + assetUpdateList.size());
        }
        
        if (installUpdateLocList.size() > 0) {
            update installUpdateLocList;
        }
        
        if (assetUpdateList.size() > 0) {
            update assetUpdateList;
        }
        
        // remove the Pending MROD Revision records by Program if the Pending MROD has been cleared
        List<PT_MROD_Revision__c> mrList = new List<PT_MROD_Revision__c>();
        System.debug('*** pgmIds ' + pgmIds);
        System.debug('*** pgmD1Ids ' + pgmD1Ids);
        if (!pgmIds.isEmpty() || !pgmD1Ids.isEmpty()) {
            mrList = [
                  SELECT Id, Asset__r.PT_Pending__c
                  FROM PT_MROD_Revision__c
                  WHERE (Program__c IN :pgmIds OR Program__c IN :pgmD1Ids)
                  AND Asset__r.PT_Pending__c = NULL
            ];
            System.debug('*** mrList ' + mrList);
            if (!mrList.isEmpty() && mrList.size() > 0) {
                System.debug('*** delete mrList');
                delete mrList;
            }
        }
    }
    
    public static void removeMRODRevisionRecordsOnRejectedRecalled(List<PT_Program__c> newProgramList, Map<Id, PT_Program__c> oldProgramMap) {
        Set<Id> pgmIds = new Set<Id>();
        Set<Id> pgmD1Ids = new Set<Id>();
        
        for (PT_Program__c newPgm : newProgramList) {
            PT_Program__c oldPgm = oldProgramMap.get(newPgm.Id);
            if (newPgm.MROD_Approval_Status__c != oldPgm.MROD_Approval_Status__c &&
                  (newPgm.MROD_Approval_Status__c == 'Rejected' ||
                        newPgm.MROD_Approval_Status__c == 'Recalled')) {
                System.debug('*** Recalled/Rejected Program: ' + newPgm.Name);
                pgmIds.add(newPgm.Id);
            }
        }
        
        for (PT_Program__c newPgm : newProgramList) {
            PT_Program__c oldPgm = oldProgramMap.get(newPgm.Id);
            if (newPgm.Airbus_MROD_Approval_Status__c != oldPgm.Airbus_MROD_Approval_Status__c &&
                  (newPgm.Airbus_MROD_Approval_Status__c == 'Rejected' ||
                        newPgm.Airbus_MROD_Approval_Status__c == 'Recalled')) {
                System.debug('*** Recalled/Rejected Program: ' + newPgm.Name);
                pgmD1Ids.add(newPgm.Id);
            }
        }
        
        List<PT_MROD_Revision__c> mrList = new List<PT_MROD_Revision__c>();
        if (!pgmIds.isEmpty() || !pgmD1Ids.isEmpty()) {
            mrList = [
                  SELECT Id
                  FROM PT_MROD_Revision__c
                  WHERE Program__c IN :pgmIds OR Program__c IN :pgmD1Ids
            ];
            if (!mrList.isEmpty() && mrList.size() > 0) {
                delete mrList;
            }
        }
    }
    
    public static void callUdpateProgramAircrafts(List<PT_Program__c> newProgramList) {
        for (PT_Program__c program : newProgramList) {
            if (program.Sales_Opportunity__c != null) {
                PT_Program_Utils.udpateProgramAircrafts(program.Sales_Opportunity__c, program.Id);
            }
        }
    }
    /*
	* Work Item W-003555 Ryan (Simplus)
	*/
    public static void updateFirstDeliveryDate(List<PT_Program__c> newProgramList){
        Set<Id> programIds = new Set<Id>();
        Map<Id, Date> programEarliestDeliveryMap = new Map<Id, Date>();
        
        for(PT_Program__c program: newProgramList){
            programIds.add(program.Id);
        }
        
        for(L2I_DSL__c shipset: [SELECT Id, Name, PT_Program__c, Delivery_Date__c FROM L2I_DSL__c WHERE PT_isActive__c = 'Active' AND PT_Program__c IN:programIds]){
            
            if(programEarliestDeliveryMap.containsKey(shipset.PT_Program__c)){
                if(programEarliestDeliveryMap.get(shipset.PT_Program__c) > shipset.Delivery_Date__c){
                    programEarliestDeliveryMap.put(shipset.PT_Program__c, shipset.Delivery_Date__c);
                }
            }
            else {
                programEarliestDeliveryMap.put(shipset.PT_Program__c, shipset.Delivery_Date__c);
            }            
        }
        
        for(PT_Program__c program: newProgramList){
            if(programEarliestDeliveryMap.containsKey(program.Id)){
                if(program.PT_First_Aircraft_Delivery__c == NULL){
                    program.PT_First_Aircraft_Delivery__c = programEarliestDeliveryMap.get(program.Id);
                }
                else {
                    if(program.PT_First_Aircraft_Delivery__c > programEarliestDeliveryMap.get(program.Id)){
                        program.PT_First_Aircraft_Delivery__c = programEarliestDeliveryMap.get(program.Id);
                    }
                }
            }
        }
    }
    /***/
    public static void sendApprovalEmail(List<PT_Program__c> newProgramList){
        List<Id> progRecIDs = new List<Id>();
        for(PT_Program__c pg: newProgramList){
            if(pg.Send_Approval_Email__c == TRUE){
                pg.Send_Approval_Email__c = FALSE;
                
                if(pg.MROD_Approval_Step__c == 'PPM Approval' && pg.Expedite_MROD_Approval__c == TRUE && pg.PMO_Regional_Director__c != NULL){
                    progRecIDs.add(pg.Id);
                }
                else if(pg.MROD_Approval_Step__c != 'PPM Approval'){
                    progRecIDs.add(pg.Id);
                }                
            }
        }
        
        if(!progRecIDs.isEmpty()){
            PT_SendEmailApprovalPendingMROD.sendApprovalEmail(progRecIDs);
        }
    }

    /*
    * @author           Lipton Abillar
    * @date             10/28/2021
    * @workitem         W-003988
    * @description      Copy over Sub System Type from Program to Opportunity if updated
    * @trigger          PT_Program_TriggerHandler.afterUpdate()
    *
    * Developer:        Lipton Abillar      10/28/2021      Create
    */
    public static void updateOpportunity(List<PT_Program__c> newProgramList, Map<Id, PT_Program__c> oldProgramMap){
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for (PT_Program__c prog : newProgramList) {
            if (prog.PT_Sub_System_Type__c != oldProgramMap.get(prog.Id).PT_Sub_System_Type__c) {
                oppsToUpdate.add(new Opportunity(Id = prog.Sales_Opportunity__c, PT_Sub_System_Type__c = prog.PT_Sub_System_Type__c));
            }
        }

        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }

//    public static void addProgramMgrToPMQueue(List<PT_Program__c> newProgramList, Map<Id, PT_Program__c> oldProgramMap) {
//        for (PT_Program__c newPgm : newProgramList) {
//            PT_Program__c oldPgm = oldProgramMap.get(newPgm.Id);
//
//            if (newPgm.StageName == 'Closed Won' &&
//                  newPgm.StageName != oldPgm.StageName &&
//                  newPgm.L2I_Product_Category__c == 'IFEC' &&
//                  !String.isBlank(newPgm.PT_CPL_Name__c) &&
//                  newPgm.SBQQ__PrimaryQuote__c != null) {
//            }
//        }
//    }

// Deprecated - Not being used. Need to comment out/remove this
/*
public static void updateProgramName(List<PT_Program__c> newProgramList) {
    System.debug('====== executing createProgramUpdateDSLs');
    System.debug('*** newProgramList ' + newProgramList);
    Map<Id, String> programOppMap = new Map<Id, String>();
    Set<Id> splitProgramIds = new Set<Id>();
    List<Opportunity> oppToUpdateList = new List<Opportunity>();
    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
    List<PT_Program__c> programToUpdateList = new List<PT_Program__c>();
    // if the program name is the opportunity Id, then we need to update that opportunity Id with the real program name
    // this would happen if an Opp was IFEC and Closed Won with no Program relationship
    // in that case the Program is created and we need to update the Opp Program Name field now that we know the Program Id
    for (PT_Program__c program : newProgramList) {
        System.debug('*** program.Name ' + program.name);
        // if (!String.isBlank(program.Name) &&
        //       program.Name.length() > 2 &&
        //       String.valueOf(program.Name).substring(0, 3) == '006') {
        //     programOppMap.put(program.Id, program.Name);
        // } else {
            if (program.Name == 'Split Program') {
                splitProgramIds.add(program.Id);
            } else {
                if (program.Sales_Opportunity__c != null) {
                    programOppMap.put(program.Id, program.Sales_Opportunity__c);
                } else {
                    System.debug(logginglevel.ERROR, '*** updateProgramName, null opportunity lookup');
                }
            }
//            }
    }
    System.debug('*** programOppMap ' + programOppMap);
    System.debug('*** splitProgramIds ' + splitProgramIds);
    if (!programOppMap.isEmpty()) {
        for (Opportunity opp : [
              SELECT Id,
                    L2I_Program_Num__c,
                    AccountId,
                    Account.L2I_Operator_Number__c,
                    L2I_Delivery_Schedule__r.Aircraft_Type__r.L2I_PAC_Type_Designator__c
              FROM Opportunity
              WHERE Id IN :programOppMap.values()
        ]) {
            oppMap.put(opp.Id, opp);
        }
        System.debug('*** oppMap ' + programOppMap);

        // add auto number to the program number
        // auto numbers are only available in 'after' triggers
        // FIXME  This needs to use the program number sequencer PT_Program_Utils.characterSequencer
        for (PT_Program__c prog : [
              SELECT Id,
                    Name,
                    Name__c,
                    Sales_Opportunity__c
              FROM PT_Program__c
              WHERE Id IN :programOppMap.keySet()
        ]) {
            System.debug('*** prog ' + prog);
            System.debug('*** prog.Name__c ' + prog.Name__c);
            Opportunity oppty = oppMap.get(prog.Sales_Opportunity__c);
//                prog.Name = 'SYSTYP';
//                String oppNbr = String.isBlank(oppty.Account.L2I_Operator_Number__c) ? '' : oppty.Account.L2I_Operator_Number__c;
//                String designator = String.isBlank(oppty.L2I_Delivery_Schedule__r.Aircraft_Type__r.L2I_PAC_Type_Designator__c) ? '' : ' - ' +
//                      oppty.L2I_Delivery_Schedule__r.Aircraft_Type__r.L2I_PAC_Type_Designator__c;
//                prog.Name += oppNbr + designator;

            // if (prog.Name__c != null) {
            //     List<String> nameSplit = prog.Name__c.split('-');
            //     if (nameSplit.size() == 2) {
            //         prog.Name += ' - ' + nameSplit[1];
            //         System.debug('*** prog ' + prog);
            //     }
            // }
//                programToUpdateList.add(prog);

            oppty.L2I_Program_Num__c = prog.Id;
            oppToUpdateList.add(oppty);
        }
        //update programToUpdateList;

        update oppToUpdateList;
    }

    if (!splitProgramIds.isEmpty()) {
        for (PT_Program__c prog : [
              SELECT Id,
                    Name,
                    Name__c
              FROM PT_Program__c
              WHERE Id IN :splitProgramIds
        ]) {

            if (prog.Name__c != null) {
                List<String> nameSplit = prog.Name__c.split('-');
                if (nameSplit.size() == 2) {
                    prog.Name += ' - ' + nameSplit[1];
                    System.debug('*** prog ' + prog);
                }
            }
            programToUpdateList.add(prog);
        }
        update programToUpdateList;
    }
}
*/
}