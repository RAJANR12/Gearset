public with sharing class PT_ProgramPriceListWrapper {
    public String sourceSystem;
	public Header header;
	public List<Lines> lines;

	public class Header {
		public String priceListName;
		public String priceListDescription;
		public String headerExternalId;
		public String currencyCode;
		public String originalHeaderID;
		public String activationStartDate;
		public String operationType;
	}

	public class Lines {
		public String itemValuePerUnit;
		public String inventoryItemID;
		public String primaryUnitOfMeasure;
		public String originalLineId;
		public String operationType;
		public String activationStartDate;
		public String lineExternalId;
	}

	public static PT_ProgramPriceListWrapper parse(String json) {
		return (PT_ProgramPriceListWrapper) System.JSON.deserialize(json, PT_ProgramPriceListWrapper.class);
	}
}