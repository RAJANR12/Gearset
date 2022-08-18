@isTest
public class ife_MaintenanceDetailsControllerTest {
    
    @isTest public static void ife_MaintenanceDetailsControllerTest(){
        Test.setMock(HttpCalloutMock.class, new ife_MaintenanceDetailsCtrlMockCallout());
        
        ife_MaintenanceDetailsController mainDetailsController = new ife_MaintenanceDetailsController();
        mainDetailsController.getMaintenanceDetails();
    }
    /*@isTest public static void PerfFmrHeaderDataTest(){
        ife_MaintenanceDetailsController.PerfFmrHeaderData  perfFmrHeadData = new ife_MaintenanceDetailsController.PerfFmrHeaderData();
        ife_MaintenanceDetailsController.PerfGetActionsRecs perfActionRecs = new ife_MaintenanceDetailsController.PerfGetActionsRecs();
     } */
    @isTest public static void cls_PerfFmrHeaderDataTest(){
        ife_MaintenanceDetailsController.cls_Defects clsDefects = new ife_MaintenanceDetailsController.cls_Defects();         
        
        ife_MaintenanceDetailsController.cls_PerfFmrDetail cls_HeaderData = new ife_MaintenanceDetailsController.cls_PerfFmrDetail();
        cls_HeaderData.fmr_id = 'Test';
        cls_HeaderData.fmr_station = 'Test';
        cls_HeaderData.airline = 'Test';
        cls_HeaderData.fmr_tail_no = 'Test';    
        cls_HeaderData.fmr_flight_no_in = 'Test';    
        cls_HeaderData.arr_from = 'Test';
        cls_HeaderData.fmr_schd_arrvd = 'Test';    
        cls_HeaderData.fmr_actl_arrvd = 'Test';    
        cls_HeaderData.fmr_flight_no_out = 'Test';    
        cls_HeaderData.fmr_dept_to = 'Test';    
        cls_HeaderData.fmr_schd_dept = 'Test';    
        cls_HeaderData.fmr_actl_dept = 'Test';
        cls_HeaderData.fmr_qmp = 'Test';
        cls_HeaderData.msr = 'Test';    
        cls_HeaderData.fmr_fan = 'Test';    
        cls_HeaderData.fmr_far = 'Test';    
        cls_HeaderData.fmr_fa_trng = 'Test';    
        cls_HeaderData.bite = 'Test';    
        cls_HeaderData.sweep = 'Test';
        cls_HeaderData.arr_seq = 'Test';
        cls_HeaderData.arr_date = 'Test';
        cls_HeaderData.tailnum = 'Test';
        cls_HeaderData.arr_flight_no = 'testt';
        cls_HeaderData.fmr_airline = 'test';
        cls_HeaderData.arr_code = 'test';    
            
      //  String str = JSON.serialize(cls_HeaderData);
        
        ife_MaintenanceDetailsController.cls_PerfGetActionsRecs cls_PerfGet = new ife_MaintenanceDetailsController.cls_PerfGetActionsRecs();
        cls_PerfGet.act_seq = 'Test';
        cls_PerfGet.takenby = 'Test';    
        cls_PerfGet.asactiontaken = 'Test';    
        cls_PerfGet.act_time = 'Test';    
        cls_PerfGet.actiondescription = 'Test';    
      //  String str2 = JSON.serialize(cls_PerfGet);    
            
        ife_MaintenanceDetailsController.cls_PerfDefects clsPerfDefects = new ife_MaintenanceDetailsController.cls_PerfDefects();
        clsPerfDefects.afffunc = 'Test';
        clsPerfDefects.defectstation = 'Test';    
        clsPerfDefects.status  = 'Test';   
        clsPerfDefects.defecttype  = 'Test';   
        clsPerfDefects.defnum = 'Test';    
        clsPerfDefects.logpage = 'Test';    
        clsPerfDefects.logitem  = 'Test';   
        clsPerfDefects.reason = 'Test';
        clsPerfDefects.paxabuse = 'Test';    
        clsPerfDefects.deferred = 'Test';    
        clsPerfDefects.resets = 'Test';
        clsPerfDefects.description = 'Test';    
        clsPerfDefects.afflocs  = 'Test';   
        clsPerfDefects.defectseq  = 'Test';   
        clsPerfDefects.faultfound   = 'Test';
      //  String str3 = JSON.serialize(clsPerfDefects);
   	
        ife_MaintenanceDetailsController.cls_PerfParts clsPerfParts = new ife_MaintenanceDetailsController.cls_PerfParts();
            clsPerfParts.fmr_id = 'Test';
            clsPerfParts.fmr_station = 'Test';
            clsPerfParts.def_seq = 'Test';
            clsPerfParts.act_seq = 'Test';
            clsPerfParts.prt_no_on = 'Test';
            clsPerfParts.prt_serial_on = 'Test';
            clsPerfParts.prt_mod_on = 'Test';
            clsPerfParts.prt_no_off = 'Test';
            clsPerfParts.prt_mod_off = 'Test';
            clsPerfParts.prt_serial_off = 'Test';
            clsPerfParts.nomenclature = 'Test';
            clsPerfParts.removalreason = 'Test';
            clsPerfParts.prt_mro = 'Test';
        
        ife_MaintenanceDetailsController.cls_PerfGetDefectUdfRecs clsPerfGet = new ife_MaintenanceDetailsController.cls_PerfGetDefectUdfRecs();
            clsPerfGet.def_udf_tag = 'Test';
            clsPerfGet.def_udf_desc = 'Test';
            clsPerfGet.def_udf_text = 'Test';
        	
        ife_MaintenanceDetailsController.cls_PerfFmrUdfRecs clsPerf = new ife_MaintenanceDetailsController.cls_PerfFmrUdfRecs();
        	    clsPerf.udf_desc = 'Test';
                clsPerf.udf_seq = 'Test';
                clsPerf.udf_tag = 'Test';
                clsPerf.udf_text = 'Test';
                   
    } 
}