@isTest
global class ife_DocumentTabsControllerMockCallOut implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success"}');
        res.setStatusCode(200);        
        return res;    
    }
}