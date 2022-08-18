/**
 *      @author       Nitin Gupta
 *      @date         01/12/2021
 *      @description  Trigger Functions for PT_NotesTrigger
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Nitin Gupta                  01/12/2021          Initial scaffold
 */

public class PT_Notes_TriggerFunctions {
    public static void updateName(List<PT_Note__c> newNoteList) {
        Map<String, Integer> noteHighSequence = new Map<String, Integer>();
//        Set<String> coreOpptys = new Set<String>();
        Map<String, String> coreOpptysRevMap = new Map<String, String>();
        Integer sequence;
        for (PT_Note__c note : newNoteList) {
            if (note.PT_Opportunity__c != null) {
                coreOpptysRevMap.put(note.PT_Opportunity__c, '');
            }
        }
        for (Opportunity opp : [
              SELECT Id, PT_Revised_Parts_List_Version_Trans__c
              FROM Opportunity
              WHERE Id IN :coreOpptysRevMap.keySet()
        ]) {
            coreOpptysRevMap.put(opp.Id, opp.PT_Revised_Parts_List_Version_Trans__c);
        }
        List<AggregateResult> opptySequences = [
              SELECT PT_Opportunity__c, MAX(PT_Sequence__c) HIGHSEQ
              FROM PT_Note__c
              WHERE PT_Opportunity__c IN :coreOpptysRevMap.keySet()
              GROUP BY PT_Opportunity__c
        ];
        System.debug(opptySequences);
        for (AggregateResult ar : opptySequences) {
            noteHighSequence.put((String) ar.get('PT_Opportunity__c'), Integer.valueOf(ar.get('HIGHSEQ')));
        }
        for (PT_Note__c note : newNoteList) {
            if (noteHighSequence != null) {
                sequence = noteHighSequence.get(note.PT_Opportunity__c) == null ? 0 : noteHighSequence.get(note.PT_Opportunity__c);
            } else {
                sequence = 0;
            }
            Integer nextSequence = sequence + 1;
            note.PT_Sequence__c = nextSequence;
            note.PT_Rev_Note_Added__c = coreOpptysRevMap.get(note.PT_Opportunity__c);
//            note.Name = 'Note ' + PT_Program_Utils.revisionCharacter(nextSequence);
            note.PT_Note_Name__c = PT_Program_Utils.revisionCharacter(nextSequence);
            noteHighSequence.put(note.PT_Opportunity__c, nextSequence);
        }
    }
    
    public static void retainName(List<PT_Note__c> newNoteList) {
        Map<String, String> coreOpptysRevMap = new Map<String, String>();
        for (PT_Note__c note : newNoteList) {
            if (note.PT_Opportunity__c != null) {
                coreOpptysRevMap.put(note.PT_Opportunity__c, '');
            }
        }
        for (Opportunity opp : [
              SELECT Id, PT_Revised_Parts_List_Version_Trans__c
              FROM Opportunity
              WHERE Id IN :coreOpptysRevMap.keySet()
        ]) {
            coreOpptysRevMap.put(opp.Id, opp.PT_Revised_Parts_List_Version_Trans__c);
        }
        
        for (PT_Note__c note : newNoteList) {
//            note.Name = 'Note ' + PT_Program_Utils.revisionCharacter((Integer)note.PT_Sequence__c);
            note.PT_Note_Name__c = PT_Program_Utils.revisionCharacter((Integer) note.PT_Sequence__c);
            if (note.PT_Delete_Note__c) {
                if (String.isBlank(note.PT_Rev_Note_Deleted__c)) {
                    note.PT_Rev_Note_Deleted__c = coreOpptysRevMap.get(note.PT_Opportunity__c);
                }
            } else {
                note.PT_Rev_Note_Deleted__c = '';
            }
        }
    }
    
    public static void preventDelete(List<PT_Note__c> oldNoteList) {
        Id userProfileId = UserInfo.getProfileId();
        String userProfileName = [SELECT Id, Name FROM Profile WHERE Id = :userProfileId].Name;
        Boolean isPMOUser = PT_ValidateUserPMOUser.validatePMOUser()[0];
        System.debug('*** isPMOUser ' + isPMOUser);
        if (isPMOUser &&
              userProfileName != 'System Administrator') {
            for (PT_Note__c note : oldNoteList) {
                note.addError('To Delete a Note, check the -Delete Note?- check box and click Save.');
            }
        }
    }
    
    public static void deleteAssetNotes(List<PT_Note__c> newNoteList, Map<Id, PT_Note__c> oldNoteMap) {
        Set<String> oppIds = new Set<String>();
        Set<String> deleteNotes = new Set<String>();
        List<String> notesList = new List<String>();
        List<String> pendingNotesList = new List<String>();
        List<PT_OpportunityService.NoteStatusWrapper> nswList = new List<PT_OpportunityService.NoteStatusWrapper>();
        List<PT_OpportunityService.NoteStatusWrapper> nswNewList = new List<PT_OpportunityService.NoteStatusWrapper>();
        String newNotes = '';
        String newPendingNotes = '';
        List<Asset> assetsToUpdate = new List<Asset>();
        
        for (PT_Note__c note : newNoteList) {
            if (note.PT_Delete_Note__c &&
                //   !oldNoteMap.get(note.Id).PT_Delete_Note__c &&
                note.PT_Approval_Status__c == 'Approved' && // Only Approved Notes can be deleted
                note.PT_Opportunity__c != null){
                oppIds.add(note.PT_Opportunity__c);
                deleteNotes.add(note.PT_Note_Name__c);
            }
        }
        System.debug('*** deleteNotes ' + deleteNotes);
        
        Boolean updateAsset = false;
        for (Asset ast : [SELECT Id, Name, PT_Notes__c, PT_Pending_Notes__c, PT_Notes_Status__c
                          FROM Asset
                          WHERE PT_Install_Location__r.Part_List_Opportunity__c IN :oppIds]){
            System.debug('*** ast.Name ' + ast.Name);
            System.debug('*** ast.PT_Notes__c ' + ast.PT_Notes__c);
            System.debug('*** ast.PT_Pending_Notes__c ' + ast.PT_Pending_Notes__c);
            System.debug('*** ast.PT_Notes_Status__c ' + ast.PT_Notes_Status__c);
            updateAsset = false;
            newNotes = '';
            newPendingNotes = '';
            nswNewList.clear();
            
            if (!String.isBlank(ast.PT_Notes__c)) {
                notesList = ast.PT_Notes__c.split(',');
                for (String sNote : notesList) {
                    if (!deleteNotes.contains(sNote)) {
                        System.debug('*** Notes not in deleteNotes ' + ast.PT_Notes__c);
                        newNotes = String.isBlank(newNotes) ? sNote : newNotes + ',' + sNote;
                    }
                }
                if (ast.PT_Notes__c != newNotes) {
                    // a note was deleted, set the correct values
                    updateAsset = true;
                    ast.PT_Notes__c = newNotes;
                    System.debug('*** Notes astToupdate ' + ast);
                }
            }
    
            if (!String.isBlank(ast.PT_Pending_Notes__c)) {
                pendingNotesList = ast.PT_Pending_Notes__c.split(',');
                for (String sNote : pendingNotesList) {
                    if (!deleteNotes.contains(sNote)) {
                        System.debug('*** pendingNotes not in deleteNotes ' + ast.PT_Pending_Notes__c);
                        newPendingNotes = String.isBlank(newPendingNotes) ? sNote : newPendingNotes + ',' + sNote;
                    }
                }
                if (ast.PT_Pending_Notes__c != newPendingNotes) {
                    // a pending note was deleted, set the correct values
                    updateAsset = true;
                    ast.PT_Pending_Notes__c = newPendingNotes;
                    System.debug('*** pendingNotes astToupdate ' + ast);
                }
            }
            
            if (!String.isBlank(ast.PT_Notes_Status__c)) {
                nswList = (List<PT_OpportunityService.NoteStatusWrapper>) JSON.deserialize(ast.PT_Notes_Status__c, List<PT_OpportunityService.NoteStatusWrapper>.class);
                Integer startCount = nswList.size();
                Integer endCount = 0;
                for (PT_OpportunityService.NoteStatusWrapper nsw : nswList) {
                    if (!deleteNotes.contains(nsw.noteName)) {
                        System.debug('*** status not in deleteNotes ' + ast.PT_Notes_Status__c);
                        nswNewList.add(nsw);
                        endCount++;
                    }
                }
                if (startCount != endCount) {
                    updateAsset = true;
                    ast.PT_Notes_Status__c = JSON.serialize(nswNewList);
                    System.debug('*** status astToupdate ' + ast);
                }
            }
            
            if (updateAsset){
                assetsToUpdate.add(ast);
            }
        }
        
        if (assetsToUpdate != null &&
              assetsToUpdate.size() > 0){
            update assetsToUpdate;
        }
    }

    /*
    * @author           Lipton Abillar
    * @date             09/21/2021
    * @workitem         W-003567
    * @description      Change the Approval Status to Pending everytime the record is updated or created
    * @trigger          PT_NotesTriggerHandler.beforeUpdate() && PT_NotesTriggerHandler.beforeInsert
    *
    * Developer:        Lipton Abillar      09/21/2021      Create
    */
    public static void setStatusPending(List<PT_Note__c> newNoteList, Map<Id, PT_Note__c> oldNoteMap, Boolean isInsert) {
        for (PT_Note__c note : newNoteList) {
            if (isInsert) {
                note.PT_Approval_Status__c = 'Pending';
                note.PT_Revision_Notes__c = 'Created Note ' + note.PT_Note_Name__c;
                note.PT_IsNew__c = true;
            } else if ( // Check if there are any changes to Notes or No longer available field
                note.PT_Notes__c != oldNoteMap.get(note.Id).PT_Notes__c ||
                note.PT_Delete_Note__c != oldNoteMap.get(note.Id).PT_Delete_Note__c
            ){
                note.PT_Approval_Status__c = 'Pending';
                // Move the new Notes value to Pending
                if (note.PT_Notes__c != oldNoteMap.get(note.Id).PT_Notes__c) {
                    note.PT_Pending_Notes__c = note.PT_Notes__c;
                    note.PT_Notes__c = oldNoteMap.get(note.Id).PT_Notes__c;
                    if (!note.PT_IsNew__c) {
                        note.PT_Revision_Notes__c = 'Updated Note ' + note.PT_Note_Name__c + ' description';
                    }
                }
                if (!note.PT_IsNew__c && note.PT_Delete_Note__c != oldNoteMap.get(note.Id).PT_Delete_Note__c) {
                    if (note.PT_Delete_Note__c) {
                        note.PT_Revision_Notes__c = 'Note ' + note.PT_Note_Name__c + ' no longer available';
                    } else {
                        note.PT_Revision_Notes__c = 'Note ' + note.PT_Note_Name__c + ' is available';
                    }
                }
            }
        }
    }

    /*
    * @author           Lipton Abillar
    * @date             09/21/2021
    * @workitem         W-003567
    * @description      If the Approval Status is changed to Approved
    * @trigger          PT_NotesTriggerHandler.beforeUpdate()
    * Developer:        Lipton Abillar      09/21/2021      Create
    */
    public static void setStatusApproved(List<PT_Note__c> newNoteList, Map<Id, PT_Note__c> oldNoteMap) {
        for (PT_Note__c note : newNoteList) {
            if ( // Check if there are any changes to Approval Status field
                note.PT_Approval_Status__c == 'Approved' &&
                note.PT_Approval_Status__c != oldNoteMap.get(note.Id).PT_Approval_Status__c
            ){
                note.PT_Approval_Status__c = 'Approved';
                note.PT_IsNew__c = false;

                // If the there's a Pending Notes, move it to the Notes
                if (!String.isEmpty(note.PT_Pending_Notes__c)) {
                    note.PT_Notes__c = note.PT_Pending_Notes__c;
                    note.PT_Pending_Notes__c = null;
                }
            }
        }
    }
}