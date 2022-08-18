/**
 * @Class Name         : PT_AddEffectivityController
 * @Description        : Controller for LWC pt_AddEffectivity
 * @Author             : Jan Denrick Geronga / Managed Services Simplus
 * @Modification Log   :
 * Ver       	Date       	  Author              Modification
 * W-001972    	Aug-23-2021   MS Simplus Jan      Initial Version
**/

public class PT_AddEffectivityController {
    
    @AuraEnabled(cacheable=true)
    public static aircraftReturnWrapper findEffectivity(Id oppId) {
        String msg = '';
        List<String> lEff = new List<String>();
        List<String> lDelEff = new List<String>();
        Set<String> sEff = new Set<String>();
        List<aircraftWrapper> acReturnList = new List<aircraftWrapper>();
        aircraftReturnWrapper acrw = new aircraftReturnWrapper();
        try {
            for(Opportunity opp : [SELECT Id, Effectivity__c, Pending_Delete_Effectivity__c FROM Opportunity WHERE Id =: oppId]){
                lEff.addAll(opp.Effectivity__c.split(';'));
                if(opp.Pending_Delete_Effectivity__c != null){
                    lDelEff.addAll(opp.Pending_Delete_Effectivity__c.split(';'));
                }
            }
            sEff.addAll(lEff);

            if (sEff.size() < 1) {
                Msg = 'Opportunity ' + oppId + ' does not have Effectivity';
            } else {
                for(L2I_Aircraft__c ac : [SELECT Id, Name, PT_PMO_Serial__c, L2I_Serial_Number__c, L2I_Registration_Number__c, 
                                          L2I_Block_Number__c FROM L2I_Aircraft__c WHERE L2I_Registration_Number__c IN: sEff ORDER BY Name ASC LIMIT 500]){
                    if(!lDelEff.isEmpty() && lDelEff.contains(ac.L2I_Registration_Number__c)){
                        aircraftWrapper acw = new aircraftWrapper();
                        acw.Id = ac.Id;
                        acw.Aircarft = ac.Name;
                        acw.PMO_Serial = ac.PT_PMO_Serial__c;
                        acw.Serial_Number = ac.L2I_Serial_Number__c;
                        acw.Tail_Number = ac.L2I_Registration_Number__c;
                        acw.Block_Number = ac.L2I_Block_Number__c;
                        acw.Msg = 'Delete';
                        acReturnList.add(acw);
                    }
                    else{
                        aircraftWrapper acw = new aircraftWrapper();
                        acw.Id = ac.Id;
                        acw.Aircarft = ac.Name;
                        acw.PMO_Serial = ac.PT_PMO_Serial__c;
                        acw.Serial_Number = ac.L2I_Serial_Number__c;
                        acw.Tail_Number = ac.L2I_Registration_Number__c;
                        acw.Block_Number = ac.L2I_Block_Number__c;
                        acw.Msg = 'Success';
                        acReturnList.add(acw);
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        acrw.msg = msg;
        acrw.acList = acReturnList;
        return acrw;
    }
    
    @AuraEnabled(cacheable=true)
    public static aircraftReturnWrapper findPendingEffectivity(Id oppId) {
        String msg = '';
        List<String> lEff = new List<String>();
        Set<String> sEff = new Set<String>();
        List<aircraftWrapper> acReturnList = new List<aircraftWrapper>();
        aircraftReturnWrapper acrw = new aircraftReturnWrapper();
        try {
            for(Opportunity opp : [SELECT Id, Pending_Effectivity__c FROM Opportunity WHERE Id =: oppId]){
                lEff.addAll(opp.Pending_Effectivity__c.split(';'));
            }
            sEff.addAll(lEff);

            if (sEff.size() < 1) {
                Msg = 'Opportunity ' + oppId + ' does not have Effectivity';
            } else {
                for(L2I_Aircraft__c ac : [SELECT Id, Name, PT_PMO_Serial__c, L2I_Serial_Number__c, L2I_Registration_Number__c, 
                                          L2I_Block_Number__c FROM L2I_Aircraft__c WHERE L2I_Registration_Number__c IN: sEff ORDER BY Name ASC LIMIT 500]){
                    aircraftWrapper acw = new aircraftWrapper();
                    acw.Id = ac.Id;
                    acw.Aircarft = ac.Name;
                    acw.PMO_Serial = ac.PT_PMO_Serial__c;
                    acw.Serial_Number = ac.L2I_Serial_Number__c;
                    acw.Tail_Number = ac.L2I_Registration_Number__c;
                    acw.Block_Number = ac.L2I_Block_Number__c;
                    acw.Msg = 'Success';
                    acReturnList.add(acw);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        acrw.msg = msg;
        acrw.acList = acReturnList;
        return acrw;
    }
    
    @AuraEnabled
    public static aircraftReturnWrapper searchAircraft(String searchEntry) {
        String msg = '';
        String QueryWhere = '';
        List<aircraftWrapper> acReturnList = new List<aircraftWrapper>();
        aircraftReturnWrapper acrw = new aircraftReturnWrapper();
        List<L2I_Aircraft__c> lstAC = new List<L2I_Aircraft__c>();
        
        if(searchEntry.length() > 2){
            String Query = 'SELECT Id, Name, PT_PMO_Serial__c, L2I_Serial_Number__c, L2I_Registration_Number__c, L2I_Block_Number__c FROM L2I_Aircraft__c ';
            List<String> whereQueries = new List<String>();
            whereQueries.add('L2I_Registration_Number__c LIKE \'%' + searchEntry + '%\'');
            whereQueries.add('PT_PMO_Serial__c LIKE \'%' + searchEntry + '%\'');
            whereQueries.add('L2I_Serial_Number__c LIKE \'%' + searchEntry + '%\'');
            whereQueries.add('L2I_Block_Number__c LIKE \'%' + searchEntry + '%\'');
            
            QueryWhere = 'WHERE ' + String.join(whereQueries, ' OR ') + ' ORDER BY Name ASC LIMIT 500';
            
            if(QueryWhere != ''){
                Query += QueryWhere;
                lstAC = Database.query(Query);
            }
            if(lstAC.size() > 0){
                for(L2I_Aircraft__c ac : lstAC){
                    aircraftWrapper acw = new aircraftWrapper();
                    acw.Id = ac.Id;
                    acw.Aircarft = ac.Name;
                    acw.PMO_Serial = ac.PT_PMO_Serial__c;
                    acw.Serial_Number = ac.L2I_Serial_Number__c;
                    acw.Tail_Number = ac.L2I_Registration_Number__c;
                    acw.Block_Number = ac.L2I_Block_Number__c;
                    acw.Msg = 'Success';
                    acReturnList.add(acw);
                }
            }
            
            if(lstAC.isEmpty()) {
                msg = 'No records found..';
            }            
        }  
        
        if(searchEntry.length() < 3){
            msg = 'Please input three or more characters';
        }
        
        acrw.msg = msg;
        acrw.acList = acReturnList;
        return acrw;
    }
    
    @AuraEnabled
    public static aircraftReturnWrapper saveEffectivity(Id oppId, List<String> tailNumber) {
        Map<String, String> mapError = new Map<String, String>();
        List<String> lEff = new List<String>();
        List<String> lPEff = new List<String>();
        List<String> lTail = new List<String>();
        String msg = '';
        List<String> lPendEff = new List<String>();
        Set<String> sEff = new Set<String>();
        List<aircraftWrapper> acReturnList = new List<aircraftWrapper>();
        aircraftReturnWrapper acrw = new aircraftReturnWrapper();

        Opportunity opp = [SELECT Id, Effectivity__c, Pending_Effectivity__c FROM Opportunity WHERE Id =: oppId];
        if(opp.Effectivity__c != null){
            lEff.addAll(opp.Effectivity__c.split(';'));
        }
        
        if(opp.Pending_Effectivity__c != null){
            lPEff.addAll(opp.Pending_Effectivity__c.split(';'));        
        }
        
        for(String ac : tailNumber){
            if(!lEff.contains(ac) && !lPEff.contains(ac)){
                lTail.add(ac);
            }
            else{
                mapError.put(ac, ac);
            }
        }
        
        if(lTail.size() > 0){
            opp.Pending_Effectivity__c = !String.isBlank(opp.Pending_Effectivity__c) ? opp.Pending_Effectivity__c + ';' + String.join(lTail, ';') : String.join(lTail, ';');
            update opp;
        }

        lPendEff.addAll(opp.Pending_Effectivity__c.split(';'));
        
        sEff.addAll(lPendEff);
        
        for(L2I_Aircraft__c ac : [SELECT Id, Name, PT_PMO_Serial__c, L2I_Serial_Number__c, L2I_Registration_Number__c, 
                                  L2I_Block_Number__c FROM L2I_Aircraft__c WHERE L2I_Registration_Number__c IN: sEff ORDER BY Name ASC LIMIT 500]){
            aircraftWrapper acw = new aircraftWrapper();
            acw.Id = ac.Id;
            acw.Aircarft = ac.Name;
            acw.PMO_Serial = ac.PT_PMO_Serial__c;
            acw.Serial_Number = ac.L2I_Serial_Number__c;
            acw.Tail_Number = ac.L2I_Registration_Number__c;
            acw.Block_Number = ac.L2I_Block_Number__c;
            acw.Msg = 'Success';
            acReturnList.add(acw);
        }
        
        if(!mapError.isEmpty()){
            String errMsg = ': Already added as Pending or Approved Effectivity.';
            msg = string.join(mapError.values(), '; ') + errMsg;
        }
        
        acrw.msg = msg;
        acrw.acList = acReturnList;
        return acrw;
    }
    
    @AuraEnabled
    public static aircraftReturnWrapper createAircraft(L2I_Aircraft__c ac, Id oppId) {
        Map<String, String> mapError = new Map<String, String>();
        List<String> lEff = new List<String>();
        List<String> lPEff = new List<String>();
        List<String> lTail = new List<String>();
        List<String> lPendEff = new List<String>();
        Set<String> sEff = new Set<String>();
        List<aircraftWrapper> acReturnList = new List<aircraftWrapper>();
        aircraftReturnWrapper acrw = new aircraftReturnWrapper();
        String msg = '';
        
        Opportunity opp = [SELECT Id, Effectivity__c, Pending_Effectivity__c FROM Opportunity WHERE Id =: oppId];
 
        try{
            insert ac;
            
            if(ac.L2I_Registration_Number__c != null){
                if(opp.Pending_Effectivity__c != null){
                    opp.Pending_Effectivity__c = (!opp.Pending_Effectivity__c.contains(ac.L2I_Registration_Number__c)) ? opp.Pending_Effectivity__c + ';' + ac.L2I_Registration_Number__c : opp.Pending_Effectivity__c;
                }
                else{
                    opp.Pending_Effectivity__c = ac.L2I_Registration_Number__c;
                }
                update opp;
            }
            
            if(!String.isBlank(opp.Pending_Effectivity__c)){
                lPendEff.addAll(opp.Pending_Effectivity__c.split(';'));
                sEff.addAll(lPendEff);
            }
            
            if(!sEff.isEmpty()){
                for(L2I_Aircraft__c acList : [SELECT Id, Name, PT_PMO_Serial__c, L2I_Serial_Number__c, L2I_Registration_Number__c, 
                                              L2I_Block_Number__c FROM L2I_Aircraft__c WHERE L2I_Registration_Number__c IN: sEff ORDER BY Name ASC LIMIT 500]){
                    aircraftWrapper acw = new aircraftWrapper();
                    acw.Id = acList.Id;
                    acw.Aircarft = acList.Name;
                    acw.PMO_Serial = acList.PT_PMO_Serial__c;
                    acw.Serial_Number = acList.L2I_Serial_Number__c;
                    acw.Tail_Number = acList.L2I_Registration_Number__c;
                    acw.Block_Number = acList.L2I_Block_Number__c;
                    acw.Msg = 'Success';
                    acReturnList.add(acw);
                }
            }
            
        } catch (Exception e) {
            String errMsg = e.getMessage();

                msg = errMsg.substringAfter(', ');
                msg = msg.substringBeforeLast(':');
            
        }
        acrw.msg = msg;
        acrw.acList = acReturnList;
        return acrw;
    }
    
    @AuraEnabled
    public static aircraftReturnWrapper deleteEffectivity(Id oppId, String tailNumber, String action) {
        Map<String, String> mapError = new Map<String, String>();
        List<String> lEff = new List<String>();
        List<String> lDelEff = new List<String>();
        String msg = '';
        Set<String> sTail = new Set<String>();
        Set<String> sEff = new Set<String>();
        Set<String> sPEff = new Set<String>();
        Set<String> sPDelEff = new Set<String>();
        
        
        List<L2I_DSL__c> listDSL = new List<L2I_DSL__c>();
        List<aircraftWrapper> acReturnList = new List<aircraftWrapper>();
        aircraftReturnWrapper acrw = new aircraftReturnWrapper();
        
        Opportunity opp = [SELECT Id, Effectivity__c, Pending_Delete_Effectivity__c, Pending_Effectivity__c FROM Opportunity WHERE Id =: oppId];
        
        sTail.add(tailNumber);
        
        try{
            if(action == 'Pending'){
                if(opp.Pending_Effectivity__c != tailNumber){
                    sPEff.addAll(opp.Pending_Effectivity__c.split(';'));
                    sPEff.removeAll(sTail);
                    opp.Pending_Effectivity__c = String.join(new List<String>(sPEff), ';');
                }
                else{
                    opp.Pending_Effectivity__c = null;
                }
                update opp;
                
                if(!String.isBlank(opp.Pending_Effectivity__c)){
                    lEff.addAll(opp.Pending_Effectivity__c.split(';'));
                    sEff.addAll(lEff);
                }
            }
            
            if(action == 'Approved'){
                if(opp.Pending_Delete_Effectivity__c != null){
                    sPDelEff.addAll(opp.Pending_Delete_Effectivity__c.split(';'));
                    if(!opp.Pending_Delete_Effectivity__c.contains(tailNumber)){
                        opp.Pending_Delete_Effectivity__c = opp.Pending_Delete_Effectivity__c + ';' + tailNumber;
                    }
                    else{
                        sPDelEff.removeAll(sTail);
                        opp.Pending_Delete_Effectivity__c = String.join(new List<String>(sPDelEff), ';');
                    }
                }
                else{
                    opp.Pending_Delete_Effectivity__c = tailNumber;
                }
                update opp;
                
                if(opp.Pending_Delete_Effectivity__c != null){
                    lDelEff.addAll(opp.Pending_Delete_Effectivity__c.split(';'));
                }
                
                if(!String.isBlank(opp.Effectivity__c)){
                    lEff.addAll(opp.Effectivity__c.split(';'));
                    sEff.addAll(lEff);
                }
            }
            
            if(!sEff.isEmpty()){
                for(L2I_Aircraft__c acList : [SELECT Id, Name, PT_PMO_Serial__c, L2I_Serial_Number__c, L2I_Registration_Number__c, 
                                              L2I_Block_Number__c FROM L2I_Aircraft__c WHERE L2I_Registration_Number__c IN: sEff ORDER BY Name ASC LIMIT 500]){
                    if(!lDelEff.isEmpty() && lDelEff.contains(acList.L2I_Registration_Number__c)){
                        aircraftWrapper acw = new aircraftWrapper();
                        acw.Id = acList.Id;
                        acw.Aircarft = acList.Name;
                        acw.PMO_Serial = acList.PT_PMO_Serial__c;
                        acw.Serial_Number = acList.L2I_Serial_Number__c;
                        acw.Tail_Number = acList.L2I_Registration_Number__c;
                        acw.Block_Number = acList.L2I_Block_Number__c;
                        acw.Msg = 'Delete';
                        acReturnList.add(acw);
                    }
                    else{
                        aircraftWrapper acw = new aircraftWrapper();
                        acw.Id = acList.Id;
                        acw.Aircarft = acList.Name;
                        acw.PMO_Serial = acList.PT_PMO_Serial__c;
                        acw.Serial_Number = acList.L2I_Serial_Number__c;
                        acw.Tail_Number = acList.L2I_Registration_Number__c;
                        acw.Block_Number = acList.L2I_Block_Number__c;
                        acw.Msg = 'Success';
                        acReturnList.add(acw);
                    }
                }
            }
            
            else if(sEff.isEmpty()){
                acrw.acList = null;
            }
            
            if(!mapError.isEmpty()){
                String errMsg = ': Already Added.';
                msg = string.join(mapError.values(), '; ') + errMsg;
                throw new AuraHandledException(msg);
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        acrw.msg = msg;
        acrw.acList = acReturnList;
        return acrw;
    }
    
    public class aircraftReturnWrapper {
        @AuraEnabled public String msg { get; set; }
        @AuraEnabled public List<aircraftWrapper> acList { get; set; }
        @AuraEnabled public String oppId { get; set; }
        public aircraftReturnWrapper() {
        }
    }
    public class aircraftWrapper {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String Aircarft { get; set; }
        @AuraEnabled public String PMO_Serial { get; set; }
        @AuraEnabled public String Serial_Number { get; set; }
        @AuraEnabled public String Tail_Number { get; set; }
        @AuraEnabled public String Block_Number { get; set; }
        @AuraEnabled public String Msg { get; set; }
        
        public aircraftWrapper() {
        }
    }
}