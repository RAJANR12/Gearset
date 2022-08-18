public  class ife_SalesOrderDashboardController{
public ife_SalesOrderDashboardController(){
}

@AuraEnabled
public static myIfeOrderHeadersWrapper groupByAccount(){
	
	User userObj = [SELECT Id, Name, Contact.AccountId, Contact.Account.L2I_Customer_ID__c
					FROM User
					WHERE Id = :UserInfo.getUserId()];
					myIfeOrderHeadersWrapper myIfeOrderHeadersWrapper =new myIfeOrderHeadersWrapper();
	
					if(userObj.Contact != null && userObj.Contact.Account!= null){
						list<myIfeOrderHeaders__x>  myIfeOrderHeadersOpen = [SELECT Status__c
																	FROM myIfeOrderHeaders__x
																	WHERE CUSTOMER_ID__c = :userObj.Contact.Account.L2I_Customer_ID__c AND Status__c ='Open'
																	ORDER BY ORDERED_DATE__c  DESC
																	LIMIT 2000];
					   	
                        System.debug('myIfeOrderHeadersOpen '+myIfeOrderHeadersOpen.size());
						list<myIfeOrderHeaders__x>  myIfeOrderHeadersBooked = [SELECT Status__c
																	FROM myIfeOrderHeaders__x
																	WHERE CUSTOMER_ID__c = :userObj.Contact.Account.L2I_Customer_ID__c AND Status__c ='Booked'
																	ORDER BY ORDERED_DATE__c  DESC
																	LIMIT 2000];	
						System.debug(' myIfeOrderHeadersBooked'+ myIfeOrderHeadersBooked.size());											
						list<myIfeOrderHeaders__x>  myIfeOrderHeadersClosed = [SELECT Status__c
																	FROM myIfeOrderHeaders__x
																	WHERE CUSTOMER_ID__c = :userObj.Contact.Account.L2I_Customer_ID__c AND Status__c ='Closed'
																	ORDER BY ORDERED_DATE__c  DESC
																	LIMIT 2000];
							System.debug(' myIfeOrderHeadersClosed'+  myIfeOrderHeadersClosed.size());											
						list<myIfeOrderHeaders__x>  myIfeOrderHeadersShipped = [SELECT Status__c
																	FROM myIfeOrderHeaders__x
																	WHERE CUSTOMER_ID__c = :userObj.Contact.Account.L2I_Customer_ID__c AND Status__c ='Shipped'
																	ORDER BY ORDERED_DATE__c  DESC
																	LIMIT 2000];											   										   									   
						System.debug(' myIfeOrderHeadersShipped'+ myIfeOrderHeadersShipped.size());
			            if( myIfeOrderHeadersOpen.size() == 2000){
							myIfeOrderHeadersWrapper.OpenStatus.put('Open', ''+myIfeOrderHeadersOpen.size()+'+');
						}
						else{
							myIfeOrderHeadersWrapper.OpenStatus.put('Open', ''+myIfeOrderHeadersOpen.size());
						}
						if(myIfeOrderHeadersClosed.size()==2000){
							myIfeOrderHeadersWrapper.ClosedStatus.put('Closed',''+myIfeOrderHeadersClosed.size()+'+');

						}	
						else{
							myIfeOrderHeadersWrapper.ClosedStatus.put('Closed',''+myIfeOrderHeadersClosed.size());

						}		
						if(myIfeOrderHeadersBooked.size()==2000){
							myIfeOrderHeadersWrapper.BookedStatus.put('Booked',''+myIfeOrderHeadersBooked.size()+'+');

						}
						else{
							myIfeOrderHeadersWrapper.BookedStatus.put('Booked',''+myIfeOrderHeadersBooked.size());

						}
						if(myIfeOrderHeadersShipped.size()==2000){
							myIfeOrderHeadersWrapper.ShippedStatus.put('Shippped',''+myIfeOrderHeadersShipped.size()+'+');

						}
						else{
							myIfeOrderHeadersWrapper.ShippedStatus.put('Shippped',''+myIfeOrderHeadersShipped.size());
						}
						
						
					 }	
					 return myIfeOrderHeadersWrapper;
						
}



public class myIfeOrderHeadersWrapper{
	
	@AuraEnabled 
    public Map<String,String> OpenStatus {get;set;}
	@AuraEnabled 
    public Map<String,String> ClosedStatus {get;set;}
	@AuraEnabled
    public Map<String,string> BookedStatus {get;set;}
	@AuraEnabled  
	public Map<String,string> ShippedStatus {get;set;}
	public  myIfeOrderHeadersWrapper(){
		OpenStatus = new Map<String,String>();
		ClosedStatus = new Map<String,string>();
		BookedStatus = new Map<String,string>();
		ShippedStatus = new Map<String,string>();

	}
}


}