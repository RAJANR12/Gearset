@isTest
private class ife_PackSlipBarCodeControllerTest {

    @isTest
    public static void getBarCodeSourceTest(){
        ife_PackSlipBarCodeController packSlipBar = new ife_PackSlipBarCodeController();
        packSlipBar.sourceCodeValue = '12335';
        packSlipBar.shouldCheckDigit = true;
        packSlipBar.barCode = 'test';
        packSlipBar.getBarCodeSource();
    }
    
    @isTest
    public static void getBarCodeStringTest(){
        ife_PackSlipBarCodeController packSlipBar = new ife_PackSlipBarCodeController();
        packSlipBar.sourceCodeValue = '12335';
        packSlipBar.shouldCheckDigit = true;
        packSlipBar.getBarCodeString();
    }
}