public with sharing class TestExportToExcelController
{
    public Opportunity oppty { get; set; }
//    public List<PartListRevision> plrListWrapper { get; set; }
//    public List<NoteWrapper> noteWrapperList { get; set; }
//    public List<InstallLocWrapper> iLocWrapperList { get; set; }
    public OppWrapper oppw { get; set; }

    public List<Account> accountList{get;set;}
    public List<Contact> contactList{get;set;}
    public String xlsHeader
    {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }

    public TestExportToExcelController(ApexPages.StandardController controller)
    {
        accountList = [select id, name from Account LIMIT 50];
        contactList = [Select id, name, account.name, email from Contact LIMIT 50];
        oppty = [
              SELECT Id, Name, PT_Program_Mgr__r.email, PT_Program_Mgr__r.Name,
                    PT_PL_Approval_Approver__r.Name, PT_PL_Approval_Approver_Comments__c,
                    PT_PL_Approval_Submitter__r.Name, PT_PL_Approval_Submitter_Comments__c,
                    PT_Part_List_Name__c, PT_Revised_Parts_List_Version_Trans__c,
                    PT_PL_Approval_Date__c, L2I_Program_Num__r.Name, L2I_AC_Operator__r.Name, L2I_Aircraft_Owner__r.Name,
                    L2I_Fit_Type__c, L2I_Aircraft_Type__r.Name,
                    L2I_Primary_System_Type__r.Name
              FROM Opportunity
              WHERE Id = :controller.getId()
        ];

        oppw = new OppWrapper();
        oppw.aircraftType = oppty.L2I_Aircraft_Type__r.Name;
        oppw.fitType = oppty.L2I_Fit_Type__c + ' - ' + oppty.L2I_Primary_System_Type__r.Name;
        oppw.operator = oppty.L2I_AC_Operator__r.Name;
        oppw.owner = oppty.L2I_Aircraft_Owner__r.Name;
        oppw.program = oppty.L2I_Program_Num__r.Name;
        oppw.partListName = oppty.PT_Part_List_Name__c;
        oppw.rev = oppty.PT_Revised_Parts_List_Version_Trans__c;

        for (L2I_DSL__c dsl : [
              SELECT Id, PT_Aircraft_Program_Identification_Field__c, Aircraft__r.Name
              FROM L2I_DSL__c
              WHERE Original_Opportunity__c = :controller.getId()
        ]) {
            SSWrapper ssw = new SSWrapper();
            ssw.ssName = dsl.Aircraft__c != null ? dsl.Aircraft__r.Name : '';
            ssw.programAircraftField = dsl.PT_Aircraft_Program_Identification_Field__c;
            oppw.ssWrapperList.add(ssw);
            if (ssw.ssName != '') {
                oppw.eff += oppw.eff == '' ? ssw.ssName : ';' + ssw.ssName;
            }
        }

    }

    public Pagereference TestExportToExcel2()
    {
        return new Pagereference('/apex/TestExportToExcel2');
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
        public List<SSWrapper> ssWrapperList { get; set; }

        public OppWrapper() {
            this.ssWrapperList = new List<SSWrapper>();
            this.eff = '';
        }
    }

    public class SSWrapper {
        public String ssName { get; set; }
        public String programAircraftField { get; set; }
    }
}