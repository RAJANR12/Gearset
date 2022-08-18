@isTest
global class IFE_LightningSelfRegisteCtrlCallout implements HttpCalloutMock{
    
    private static String recaptchaSecretKey = '6Lcc7NkZAAAAANK7H2cOHc0zHVmXri3VRuJ-CsUo';
    global HTTPResponse respond(HTTPRequest req){
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);     
        res.setBody('{"success": true,"score": 0.9}');
        
        return res;
    }
}