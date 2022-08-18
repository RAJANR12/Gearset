public class PT_PLG_Response_Model {

	public class QuoteLines {
		public String InstallLocation {get;set;}
		public String PartNumber {get;set;}
		public String Nomenclature {get;set;}
		public Integer Quantity {get;set;}
		public String ProposedPartCode {get;set;}
		//public String Caveat {get;set;}
		//public String SFQuoteId {get;set;}
	}

	public String economyClassSeatConfig;
	public Integer economyClassSeatCount;
	public String premiumEconomySeatConfig;
	public Integer premiumEconomySeatCount;
	public String businessClassSeatConfig;
	public Integer businessClassSeatCount;
	public String firstClassSeatConfig;
	public Integer firstClassSeatCount;
	public String ofarSeatConfig;
	public Integer ofarSeatCount;
	public String ofcrSeatConfig;
	public Integer ofcrSeatCount;
	public String crewRestSeatConfig;
	public Integer crewRestSeatCount;
	public String flightDeckSeatConfig;
	public Integer flightDeckSeatCount;
	public List<QuoteLines> quoteLines;

	public PT_PLG_Response_Model parsePartsListFromJSON(String jsonData) {
		return (PT_PLG_Response_Model) System.JSON.deserialize(jsonData, PT_PLG_Response_Model.class);
	}
}