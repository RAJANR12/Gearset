public without sharing class PT_PartsListPDFController {
    public Opportunity oppty { get; set; }
    public List<PartListRevision> plrListWrapper { get; set; }
    public List<NoteWrapper> noteWrapperList { get; set; }
    public List<InstallLocWrapper> iLocWrapperList { get; set; }
    public OppWrapper oppw { get; set; }
    public String oppStatus { get; set; }
    public String nextRev { get; set; }

    public String xlsHeader
    {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }

    public PT_PartsListPDFController(ApexPages.StandardController controller) {
        oppStatus = ApexPages.currentPage().getParameters().get('status');
        nextRev = ApexPages.currentPage().getParameters().get('nextRev');
        oppty = [
              SELECT Id, Name, PT_Program_Mgr__r.email, PT_Program_Mgr__r.Name,
                    PT_PL_Approval_Approver__r.Name, PT_PL_Approval_Approver_Comments__c,
                    PT_PL_Approval_Submitter__r.Name, PT_PL_Approval_Submitter_Comments__c,
                    PT_Part_List_Name__c, PT_Revised_Parts_List_Version_Trans__c,
                    PT_PL_Approval_Date__c, L2I_Program_Num__r.Name, L2I_AC_Operator__r.Name, L2I_Aircraft_Owner__r.Name,
                    L2I_Fit_Type__c, L2I_Aircraft_Type__r.Name, PT_PL_Approval_Status__c,
                    L2I_Primary_System_Type__r.Name, L2I_Program_Num__r.PT_Program_Type__c,
                    RecordType.Name, // Added by Lipton for W-003629
            		Effectivity__c, //Added by Jan Geronga for W-003766
                    Pending_Effectivity__c //Added by Michael W-003071
              FROM Opportunity
              WHERE Id = :controller.getId()
        ];

        oppw = new OppWrapper();
        oppw.aircraftType = oppty.L2I_Aircraft_Type__r.Name;
        oppw.fitType = oppty.L2I_Program_Num__r.PT_Program_Type__c + ' - ' + oppty.L2I_Primary_System_Type__r.Name;
        oppw.operator = oppty.L2I_AC_Operator__r.Name;
        oppw.owner = oppty.L2I_Aircraft_Owner__r.Name;
        oppw.program = oppty.L2I_Program_Num__r.Name;
        oppw.partListName = oppty.PT_Part_List_Name__c;
        oppw.eff = oppty.Effectivity__c; //Added by Jan Geronga for W-003766
        if (oppStatus == 'Pending'){
            oppw.rev = nextRev;
        } else {
            oppw.rev = oppty.PT_Revised_Parts_List_Version_Trans__c;
        }
        // Added by Lipton for W-003629
        if (oppty.RecordType.Name == 'PPL') {
            oppw.documentHeaderTitle = 'PROGRAM';
        } else {
            oppw.documentHeaderTitle = 'COMPONENT';
        }
        // END for W-003629
        oppw.approvalStatus = oppStatus;

        for (L2I_DSL__c dsl : [
              SELECT Id, PT_Aircraft_Program_Identification_Field__c, Aircraft__r.Name
              FROM L2I_DSL__c
              WHERE Original_Opportunity__c = :controller.getId()
        ]) {
            SSWrapper ssw = new SSWrapper();
            ssw.ssName = dsl.Aircraft__c != null ? dsl.Aircraft__r.Name : '';
            ssw.programAircraftField = dsl.PT_Aircraft_Program_Identification_Field__c;
            oppw.ssWrapperList.add(ssw);
            //Removed by Jan Geronga W-003766
            /*if (ssw.ssName != '') {
                oppw.eff += oppw.eff == '' ? ssw.ssName : ';' + ssw.ssName;
            }*/
        }

        List<PT_Parts_List_Revision__c> plrList = new List<PT_Parts_List_Revision__c>();
        plrListWrapper = new List<PartListRevision>();
        plrList = [
              SELECT CreatedDate, LastModifiedDate,
                    Asset__c, Asset__r.Name,
                    Id,
                    Name,
                    OwnerId,
                    Parts_List__c,
                    PT_Approver__c, PT_Approver__r.Name,
                    PT_Approver_Comments__c,
                    PT_Current_Part_List_Approval_Date__c,
                    PT_Current_Part_List_Name__c,
                    PT_Current_Part_List_Rev_Nbr__c,
                    PT_Current_Part_List_Rev_Trans__c,
                    PT_Current_Part_List_Submitter__c,
                    PT_Date_approved__c,
                    PT_Install_Loc__c,
                    PT_Part_Code__c,
                    PT_Part_List_Name__c,
                    PT_Part_List_Opportunity__c, PT_Part_List_Opportunity__r.Name,
                    PT_Part_List_Opportunity__r.PT_PL_Approval_Submitter_Comments__c,
                    PT_Part_List_Opportunity__r.PT_PL_Approval_Submitted_Date__c,
                    PT_Part_List_Revision_Number_Text__c,
                    PT_Parts_List_Revision_Number__c,
                    PT_Pending_Approved__c,
                    PT_Revised_Parts_List_Version_Trans__c,
                    PT_Shipset__c,
                    PT_Submitter__c, PT_Submitter__r.Name,
                    Revised_Description__c, 
                    PT_Submitter_Comments__c //Khrisna W-003269
              FROM PT_Parts_List_Revision__c
              WHERE PT_Part_List_Opportunity__c = :controller.getId() 
              ORDER BY Revised_Description__c asc //added by Jan Geronga for W-003767
        ];
        system.debug('>>>>>> plrList: '+plrList);


        List<PartListRevisionDetails> plrdList;
        List<List<PartListRevisionDetails>> plrdListList;
        Integer counter = 0;
        Integer loopCount = 0;
        final Integer listLimit = 990;  // limit for collections is 1000
        for (PT_Parts_List_Revision__c plr : plrList) {
//            System.debug('*** plr.PT_Revised_Parts_List_Version_Trans__c ' + plr.PT_Revised_Parts_List_Version_Trans__c);
            Boolean foundPlrw = false;
//            String rev = plr.PT_Revised_Parts_List_Version_Trans__c != null ? plr.PT_Revised_Parts_List_Version_Trans__c : '**Pending**';
            String rev = plr.PT_Revised_Parts_List_Version_Trans__c != null ? plr.PT_Revised_Parts_List_Version_Trans__c : nextRev;
//            System.debug('*** rev ' + rev);
            for (Integer i = 0; i < plrListWrapper.size(); i++) {
                // was revision already added?
                if (plrListWrapper[i].revision == rev) {
                    loopCount = plrListWrapper[i].plrDetailsList.size();    // number of revision details lists
                    plrdList = plrListWrapper[i].plrDetailsList[loopCount - 1];
                    counter = plrdList.size();      // number of revision details in this list

                    foundPlrw = true;
                    PartListRevisionDetails plrd = new PartListRevisionDetails(plr.Revised_Description__c, '');
                    if (counter < listLimit) {      // are we below the limit?
                        plrdList.add(plrd);
                        plrListWrapper[i].plrDetailsList[loopCount - 1] = plrdList;
                    } else {
                        plrdList = new List<PartListRevisionDetails>();
                        plrdList.add(plrd);
                        List<List<PartListRevisionDetails>> listList = plrListWrapper[i].plrDetailsList;
                        listList.add(plrdList);
                        plrListWrapper[i].plrDetailsList = listList;
                    }

                    break;
                }
            }
            if (!foundPlrw) {
//                System.debug('*** not found');
                PartListRevision plrRev = new PartListRevision();
                plrRev.revision = rev;
                plrRev.approver = plr.PT_Approver__r.Name;
                
                plrRev.submittedDate = plr.PT_Part_List_Opportunity__r.PT_PL_Approval_Submitted_Date__c != null ? plr.PT_Part_List_Opportunity__r.PT_PL_Approval_Submitted_Date__c.format('MMM dd, yyyy') : null;
                plrRev.approvedDate = plr.PT_Date_Approved__c != null ? plr.PT_Date_Approved__c.format('MMM dd, yyyy') : null;
                if (plr.PT_Pending_Approved__c == 'Pending'){
                    plrRev.comments = plr.PT_Part_List_Opportunity__r.PT_PL_Approval_Submitter_Comments__c;
                    plrRev.appSubDate = plrRev.submittedDate;
                    plrRev.submitter = plr.PT_Current_Part_List_Submitter__c;
                } else {
                    // plrRev.comments = plr.PT_Approver_Comments__c;
                    plrRev.comments = plr.PT_Submitter_Comments__c; // Khrisna W-003269
                    plrRev.appSubDate = plrRev.approvedDate;
                    plrRev.submitter = plr.PT_Submitter__r.Name;
                }
                PartListRevisionDetails plrd = new PartListRevisionDetails(plr.Revised_Description__c, 'Reason/Description');
                List<PartListRevisionDetails> detList = new List<PartListRevisionDetails>();
                List<List<PartListRevisionDetails>> detListList = new  List<List<PartListRevisionDetails>>();
                detList.add(plrd);
                detListList.add(detList);
                plrRev.plrDetailsList = detListList;

                System.debug('*** plrRev.plrDetailsList.size() ' + plrRev.plrDetailsList.size());
                plrListWrapper.add(plrRev);
                System.debug('*** plrListWrapper.size() ' + plrListWrapper.size());
            }
        }
        plrListWrapper.sort();

//        for (Integer i = 0; i < plrListWrapper.size(); i++){
//            System.debug('*** i ' + i);
//            for (Integer K = 0; K < plrListWrapper[i].plrDetailsList.size(); k++){
//                System.debug('*** k ' + k);
//                for (Integer m = 0; m < plrListWrapper[i].plrDetailsList[k].size(); m++){
//                    System.debug('*** m ' + m);
//                }
//            }
//
//
//        }

        // get the CPL Notes
        noteWrapperList = new List<NoteWrapper>();
        List<PT_Note__c> noteList = new List<PT_Note__c>();

        noteList = [
              SELECT Id, PT_Note_Name__c, PT_Notes__c, PT_Opportunity__c, PT_Sequence__c,
                    PT_Rev_Note_Added__c, PT_Rev_Note_Deleted__c,
                    PT_Delete_Note__c // Added by Lipton for W-003567
              FROM PT_Note__c
              WHERE PT_Opportunity__c = :controller.getId()
              ORDER BY PT_Sequence__c
        ];

        for (PT_Note__c note : noteList) {
            // Only show notes that are PT_Delete_Note__c == false
            // Added by Lipton for W-003567
            if(!note.PT_Delete_Note__c) {
                NoteWrapper nw = new NoteWrapper();
                nw.noteName = note.PT_Note_Name__c;
                nw.notes = note.PT_Notes__c;
                nw.revAdded = note.PT_Rev_Note_Added__c;
                nw.revDeleted = note.PT_Rev_Note_Deleted__c;
                noteWrapperList.add(nw);
            }
        }

        iLocWrapperList = new List<InstallLocWrapper>();
        for (Asset ast : [
              SELECT Id, ProductCode, Name, Quantity, PT_Pending_Quantity__c, PT_Configured_Quantity__c,
                    PT_Pending_Configured_Quantity__c, PT_Status__c, PT_Install_Location__r.Status__c,
                    PT_Install_Location__c, PT_Can_Be_Processed__c, PT_Reason__c, PT_Pending_Reason__c,
                    PT_Notes__c, PT_Pending_Notes__c, PT_Notes_Status__c,
                    PT_Install_Location__r.Name,
                    PT_Install_Location__r.PT_Seat_Vendor__c,
                    PT_Install_Location__r.Part_List_Opportunity__c, PT_Revision_Number__c,
                    PT_Install_Location__r.Part_List_Opportunity__r.PT_Parts_List_Revision_Number__c,
                    PT_Install_Location__r.Solution_Group__r.SBQQ__Description__c,
                    PT_Proposed_Part_Code__c, PT_Proposed_Part_Nomenclature__c // Added by Lipton for W-003649
              FROM Asset
              WHERE PT_Install_Location__r.Part_List_Opportunity__c = :controller.getId()
              AND PT_Install_Location__r.Status__c = 'Active'
              AND PT_Can_Be_Processed__c = true
              ORDER BY PT_Install_Location__r.Name, ProductCode
        ]) {
            Boolean foundMatch = false;
            Integer configQty;
            Integer qty;
            String notes;

            // Added by Lipton for W-003649
            // Description: Use PT_Proposed_Part_Code__c as product code if the asset is IFE MISCELLANEOUS
            String productCode = ast.ProductCode;
            String productName = ast.Name;
            if(ast.ProductCode == 'IFE MISCELLANEOUS') {
                productCode = !String.isBlank(ast.PT_Proposed_Part_Code__c) ? ast.PT_Proposed_Part_Code__c : productCode;
                productName = !String.isBlank(ast.PT_Proposed_Part_Code__c) ? ast.PT_Proposed_Part_Code__c : productName;
            }
            // END for W-003649

            if (oppw.approvalStatus == 'Pending'){
                configQty = ast.PT_Pending_Configured_Quantity__c == null ? Integer.valueOf(ast.PT_Configured_Quantity__c) : Integer.valueOf(ast.PT_Pending_Configured_Quantity__c);
                qty = ast.PT_Pending_Quantity__c == null ? Integer.valueOf(ast.Quantity) : Integer.valueOf(ast.PT_Pending_Quantity__c);
                if (ast.PT_Pending_Notes__c == 'Remove Notes'){
                    notes = '';
                } else if (!String.isBlank(ast.PT_Pending_Notes__c)) {
                    notes = ast.PT_Pending_Notes__c;
                } else {
                    notes = ast.PT_Notes__c;
                }
            } else {
                configQty = Integer.valueOf(ast.PT_Configured_Quantity__c);
                qty = Integer.valueOf(ast.Quantity);
                notes = ast.PT_Notes__c;
            }
//            System.debug('*** b4 iLocWrapperList.size() ' + iLocWrapperList.size());
            for (Integer i = 0; i < iLocWrapperList.size(); i++) {
                if (iLocWrapperList[i].installLoc == ast.PT_Install_Location__r.Name) {
                    foundMatch = true;
                    AssetWrapper aw = new AssetWrapper();
                    // aw.productCode = ast.ProductCode;
                    aw.productCode = productCode; // Added by Lipton for W-003649
                    aw.productName = productName; // Added by Lipton for W-003649
//                    aw.pendReason = ast.PT_Pending_Reason__c;
                    aw.configQty = configQty;
                    aw.qty = qty;
                    aw.noteName = notes;
//                    aw.reason = ast.PT_Reason__c;
                    aw.status = ast.PT_Status__c;
                    aw.noteStatus = ast.PT_Notes_Status__c;
                    iLocWrapperList[i].assetWrapperList.add(aw);
//                    System.debug('*** found iLocWrapperList[i].assetWrapperList.size() ' + iLocWrapperList[i].assetWrapperList.size());
//                    System.debug('*** found iLocWrapperList[i] ' + iLocWrapperList[i]);
                    break;
                }
            }
            if (!foundMatch) {
                InstallLocWrapper ilw = new InstallLocWrapper();
                ilw.installLoc = ast.PT_Install_Location__r.Name;
                ilw.installLocDescription = ast.PT_Install_Location__r.Solution_Group__r.SBQQ__Description__c;
                ilw.vendor = ast.PT_Install_Location__r.PT_Seat_Vendor__c;
                AssetWrapper aw = new AssetWrapper();
                // aw.productCode = ast.ProductCode;
                // aw.productName = ast.Name;
                aw.productCode = productCode; // Added by Lipton for W-003649
                aw.productName = productName;
//                aw.pendReason = ast.PT_Pending_Reason__c;
                aw.configQty = configQty;
                aw.qty = qty;
                aw.noteName = notes;
//                aw.reason = ast.PT_Reason__c;
                aw.status = ast.PT_Status__c;
                aw.noteStatus = ast.PT_Notes_Status__c;
                ilw.assetWrapperList.add(aw);
//                System.debug('*** ilw.assetWrapperList.size() ' + ilw.assetWrapperList.size());
                iLocWrapperList.add(ilw);
//                System.debug('*** iLocWrapperList.size() ' + iLocWrapperList.size());
            }
        }
    Integer totalSeats = 0;
        List<String> lILoc = new List<String>{'BC', 'BC1', 'BC2', 'EC', 'EC1', 'EC2', 'EC3', 'EC4', 'EC5', 'EC6', 'ECP', 'ECP1', 'ECP2', 'FC', 'FC1', 'FC2', 'FC3'}; //Added by Jan Geronga for W-003766
        
        Map<String, Integer> locSeatsMap = new Map<String, Integer>();
        for (PT_Install_Location__c iLoc : [
              SELECT Id, Name, PT_Seat_Count__c, Solution_Group__r.PT_is_Seat_End__c, Solution_Group__r.SBQQ__Description__c
              FROM PT_Install_Location__c
              WHERE Part_List_Opportunity__c = :controller.getId()
              AND Status__c = 'Active'
              AND Solution_Group__r.PT_is_Seat_End__c = true
              ORDER BY Name
        ]) {
            if (lIloc.contains(iLoc.Name)) { //Added by Jan Geronga for W-003766
            //if (!iLoc.Solution_Group__r.SBQQ__Description__c.contains('HARNESS')) { //Removed by Jan Geronga for W-003766
                Integer seats = iLoc.PT_Seat_Count__c != null ? Integer.valueOf(iLoc.PT_Seat_Count__c) : 0;
                totalSeats += seats;
                if (!locSeatsMap.containsKey(iLoc.Name)) {
                    locSeatsMap.put(iLoc.Name, 0);
                }
                Integer tempSeats = locSeatsMap.get(iLoc.Name);
                tempSeats += seats;
                locSeatsMap.put(iLoc.Name, tempSeats);
            }
        }
        String seatString = totalSeats + ' (SEAT CONFIGURATION - ';
        Boolean firstKey = true;
        for (String key : locSeatsMap.keySet()){
            if (!firstKey) {
            seatString += ', ';
            }
            firstKey = false;
            seatString += locSeatsMap.get(key) + '(' + key + ')';
        }
        seatString += ')';
        oppw.seats = seatString;
    }

    public class OppWrapper {
        public String operator { get; set; }
        public String owner { get; set; }
        public String fitType { get; set; }
        public String aircraftType { get; set; }
        public String program { get; set; }
        public String partListName { get; set; }
        public String rev { get; set; }
        public String eff { get; set; }
        public String seats { get; set; }
        public String approvalStatus { get; set;}
        public List<SSWrapper> ssWrapperList { get; set; }
        public String documentHeaderTitle { get; set;} // Added by Lipton for W-003629

        public OppWrapper() {
            this.ssWrapperList = new List<SSWrapper>();
            this.eff = '';
        }
    }

    public class SSWrapper {
        public String ssName { get; set; }
        public String programAircraftField { get; set; }
    }

    public class PartListRevision implements Comparable {
        public String revision { get; set; }
        public String approver { get; set; }
        public String submitter { get; set; }
        public String submittedDate { get; set; }
        public String approvedDate { get; set; }
        public String appSubDate { get; set;}
        public String comments { get; set; }
        public List<List<PartListRevisionDetails>> plrDetailsList { get; set; }
//        public Integer blockNumber { get; set;}

        public PartListRevision() {
//            plrDetailsList = new List<PartListRevisionDetails>();
        }
    
        public Integer compareTo(Object objToCompare) {
            return revision.compareTo(((PartListRevision)objToCompare).revision);
        }


//        public PartListRevision(List<PartListRevisionDetails> plrDetails, Integer i) {
//            plrDetailsList = plrDetails;
//            blockNumber = 1;
//        }
    }

    public class PartListRevisionDetails {
        public String detailsLabel { get; set; }
        public String details { get; set; }

        public PartListRevisionDetails(String details, String detailsLabel) {
            this.details = details;
            this.detailsLabel = detailsLabel;
        }
    }

    public class NoteWrapper {
        public String noteName { get; set; }
        public String notes { get; set; }
        public String revAdded { get; set; }
        public String revDeleted { get; set; }

        public NoteWrapper() {
        }
    }

    public class InstallLocWrapper {
        public String installLoc { get; set; }
        public String installLocDescription { get; set; }
        public String vendor { get; set; }
        public List<AssetWrapper> assetWrapperList { get; set; }

        public InstallLocWrapper() {
            assetWrapperList = new List<AssetWrapper>();
        }
    }

    public class AssetWrapper {
        public String productCode { get; set; }
        public String productName { get; set; }
        public Integer pendConfigQty { get; set; }
        public Integer pendQty { get; set; }
        public String pendNoteName { get; set; }
        public String pendReason { get; set; }
        public Integer configQty { get; set; }
        public Integer qty { get; set; }
        public String noteName { get; set; }
        public String status { get; set; }
        public String reason { get; set; }
        public String noteStatus { get; set; }
    }
}