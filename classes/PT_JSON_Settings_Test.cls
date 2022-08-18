@IsTest
public class PT_JSON_Settings_Test {

    private static void setupTestData()
    {
        L2I_DataFactory factory = new L2I_DataFactory();
        factory.setupTestContext(null, null, false);
        
      
        
    }
    
     @isTest
    private static void TestDataOnLoad() 
    {
        Map<String, String> maprec = new Map<String,String>();
        maprec.put('Test', 'Test');
        
         PT_JSON_Settings.ConfigurationData PtJsonobjchild = new PT_JSON_Settings.ConfigurationData();
         PtJsonobjchild.SystemTypeTranslations = maprec;
        
        String Checktranslation = PT_JSON_Settings.SystemTypeTranslation('Test');
        PT_JSON_Settings.SystemTypeTranslations();
        List<String> lstseeting = PT_JSON_Settings.settings();
        List<String > lststr = new List<String>();
        lststr.add('url');
        
        PT_JSON_Settings.initialize();
        
       system.assertEquals(lststr, lstseeting);
        PT_JSON_Settings PtJsonobj = new PT_JSON_Settings();
        PT_JSON_Settings.PLGCalloutSettings();
        PT_JSON_Settings.settings();
    }
}