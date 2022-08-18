public with sharing class RelatedOpportunitiesController{

    public static List<Opportunity> fetchOpportunities(InputWrapper input){
        Id recordId = input.recordId;
        String lookupField = input.lookupField;
        String filter = input.filter;
        Integer rows = input.rows;
        Integer offset = input.offset;
        String sortBy = input.sortBy;
        String sortDirection = input.sortDirection;
        String sObjectName = input.sObjectName;

        String query = 'SELECT Id, Name, PT_Part_List_Name__c, L2I_AircraftQuantity__c, L2I_AircraftType__c, L2I_Program_Num__c, L2I_Program_Num__r.Name, L2I_Delivery_Schedule__c, L2I_Product_Category__c FROM Opportunity';
        query += ' WHERE '+ lookupField +' = :recordId';
        if (sObjectName != 'PT_Program__c') {
            query += !String.isBlank(filter) ? ' AND (' + filter + ')': '';
            query += ' ORDER BY  ' + sortBy + ' ' + sortDirection;
            query += ' NULLS ' + (sortDirection == 'ASC' ? 'FIRST' : 'LAST');
            query += ' LIMIT :rows';
            query += ' OFFSET :offset';
        }

		return Database.query(query);
	}

    public static Integer getTotal(InputWrapper input) {
        Id recordId = input.recordId;
        String lookupField = input.lookupField;
        String filter = input.filter;

        String query = 'SELECT COUNT() FROM Opportunity';
        query += ' WHERE '+ lookupField +' = :recordId';
        query += !String.isBlank(filter) ? ' AND (' + filter + ')' : '';

        Integer count = Database.countQuery(query);
        return count;
    }

    public static List<L2I_DSL__c> fetchDSL (Set<Id> dshIds) {
        return [SELECT Id, Delivery_Schedule_Header__c, Original_Opportunity__c, IFEC_DSL__r.Original_Opportunity__r.L2I_Program_Num__c,
                    IFEC_DSL__r.Original_Opportunity__r.L2I_Program_Num__r.Name, 
                    (SELECT Id, Original_Opportunity__c, Original_Opportunity__r.Name,
                        Original_Opportunity__r.SBQQ__PrimaryQuote__c, Original_Opportunity__r.SBQQ__PrimaryQuote__r.Name  
                    FROM Delivery_Schedule_Lines__r)
                FROM L2I_DSL__c
                WHERE Delivery_Schedule_Header__c IN :dshIds];
    }

    public static Map<Id, Map<Id, String>> fetchDSSRelatedPrograms(Set<Id> dshIds){
        Map<Id, Map<Id, String>> dssPrograms = new Map<Id, Map<Id, String>>();

        for (L2I_DSL__c dsl : fetchDSL(dshIds)) {
            if (!dssPrograms.containsKey(dsl.Original_Opportunity__c)) {
                dssPrograms.put(dsl.Original_Opportunity__c, new Map<Id, String>());
            }

            if (dsl.IFEC_DSL__r.Original_Opportunity__r.L2I_Program_Num__c != null) {
                dssPrograms.get(dsl.Original_Opportunity__c).put(dsl.IFEC_DSL__r.Original_Opportunity__r.L2I_Program_Num__c,
                                                                dsl.IFEC_DSL__r.Original_Opportunity__r.L2I_Program_Num__r.Name);
            }
        }

        return dssPrograms;
    }

    public static Map<Id, DSSOpportunity> fetchProgramsRelatedDSS (Set<Id> dshIds) {
        Map<Id, DSSOpportunity> dssOppty = new Map<Id, DSSOpportunity>();
        for (L2I_DSL__c dsl : fetchDSL(dshIds)) {
            for (L2I_DSL__c dslRelated : dsl.Delivery_Schedule_Lines__r) {
                if (!dssOppty.containsKey(dslRelated.Original_Opportunity__c)) {
                    dssOppty.put(dslRelated.Original_Opportunity__c, new DSSOpportunity(
                        dslRelated.Original_Opportunity__c,
                        dslRelated.Original_Opportunity__r.Name,
                        dslRelated.Original_Opportunity__r.SBQQ__PrimaryQuote__c,
                        dslRelated.Original_Opportunity__r.SBQQ__PrimaryQuote__r.Name
                    ));
                }
            }
        }

        return dssOppty;
    }
	
	@AuraEnabled
	public static ResponseWrapper fetchData(String inputJson){
		ResponseWrapper response = new ResponseWrapper();
        InputWrapper input = (InputWrapper)JSON.deserialize(inputJson, InputWrapper.class);
        Set<Id> dshIds = new Set<Id>();
        
        response.opportunities = fetchOpportunities(input);

        if (input.sObjectName != 'PT_Program__c') {
            response.totalOppCount = getTotal(input);

            for (Opportunity opp : response.opportunities) {
                if (opp.L2I_Delivery_Schedule__c != null && opp.L2I_Product_Category__c == 'DSS') {
                    dshIds.add(opp.L2I_Delivery_Schedule__c);
                }
            }

            if (!dshIds.isEmpty()) {
                response.dssPrograms = fetchDSSRelatedPrograms(dshIds);
            }
        } else {
            for (Opportunity opp : response.opportunities) {
                if (opp.L2I_Delivery_Schedule__c != null) {
                    dshIds.add(opp.L2I_Delivery_Schedule__c);
                }
            }
            if (!dshIds.isEmpty()) {
                response.opportunitiesDSS = fetchProgramsRelatedDSS(dshIds).values();
                response.totalOppCount = response.opportunitiesDSS.size();
            }
        }
        
		return response;
	}

    public class ResponseWrapper {
        @AuraEnabled
		public List<Opportunity> opportunities{ get; set; }

        @AuraEnabled
		public List<DSSOpportunity> opportunitiesDSS{ get; set; }

        @AuraEnabled
		public Map<Id, Map<Id, String>> dssPrograms{ get; set; }

        @AuraEnabled
		public Integer totalOppCount{ get; set; }
    }

	public class InputWrapper{
		@AuraEnabled
		public Id recordId { get; set; }

        @AuraEnabled
		public String sObjectName { get; set; }

        @AuraEnabled
		public String lookupField { get; set; }

		@AuraEnabled
		public String filter { get; set; }

		@AuraEnabled
		public Integer rows { get; set; }

        @AuraEnabled
		public Integer offset { get; set; }

        @AuraEnabled
		public String sortBy { get; set; }

        @AuraEnabled
		public String sortDirection { get; set; }
	}

    public class DSSOpportunity {
        @AuraEnabled
        public Id Id { get; set; }

        @AuraEnabled
        public String Name { get; set; }

        @AuraEnabled
        public Id PrimaryQuote { get; set; }

        @AuraEnabled
        public String PrimaryQuoteName { get; set; }

        public DSSOpportunity(Id Id, String Name, Id PrimaryQuote, String PrimaryQuoteName) {
            this.Id = Id;
            this.Name = Name;
            this.PrimaryQuote = PrimaryQuote;
            this.PrimaryQuoteName = PrimaryQuoteName;
        }
    }
}