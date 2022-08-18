/*
 * Name: L2I_Constants 
 *
 * Created: 4.22.2020 : Kevin Antonioli (ATG)
 */
public with sharing class L2I_Constants
{
public void L2I_Constants(){}
    
    public static final String APPROVED_STRING = 'Approved';
    public static final String ORDER_OBJ_NAME = 'Order';
    public static final String RECORDJOB_STATUS_COMPLETED = 'Completed';

    public static final String SELECT_ONE = 'Select One';
    public static final String NONE = 'None';
    
    public static final String EDIT_MODE = 'edit';
    public static final String NEW_MODE = 'new';
    
    public static final String STATUS_NEW = 'New';
    public static final String STATUS_CLOSED = 'Closed';
    public static final String STATUS_FIXED = 'Fixed';
    public static final String STATUS_CANCELLED = 'Cancelled';
    public static final String STATUS_ON_MAINTENANCE = 'Active';
    public static final String STATUS_OFF_MAINTENANCE = 'Expired';
    public static final String STATUS_DECOMMISSION = 'Decommission';
    public static final String STATUS_ESCALATED_TO_DEV = 'Escalated to Development';
    public static final String STATUS_DRAFT = 'Draft';
    public static final String STATUS_ACTIVATED = 'Activated';
    public static final String STATUS_EXPIRED = 'Expired';
    public static final String STATUS_QUOTED = 'Quoted';
    public static final String STATUS_TERMINATED = 'Terminated';
    public static final String SEVERITY_ROUTINE = 'Routine';

    public static final String LINE_TYPE_NEW = 'New';
    
    public static final String ORDER_PRICE_CALCULATION_FIELD = 'SBQQ__PriceCalcStatus__c';
    public static final String ORDER_CALCULATION_STATUS_COMPLETED = 'Completed';

    public static final String SUCCESS_ENTRY = 'Success';
    public static final String ERROR_ENTRY = 'Error';

    public static final String QUOTE_TYPE_NEW = 'Quote';
    public static final String QUOTE_TYPE_QUOTE = 'Quote';
    public static final String QUOTE_TYPE_RENEWAL = 'Renewal';
    public static final String QUOTE_TYPE_AMENDMENT = 'Amendment';

    public static final String OPPORTUNITY_ORDERED_FIELD = 'SBQQ__Ordered__c';
    public static final String CONTRACT_STATUS_RENEWED = 'Renewed';

    public static final String DECOMMISSIONED_QTY_MAPKEY = '*decommissionedQuantity';
    public static final String CARRIED_FORWARD_QTY_MAPKEY = '*carriedForwardQuantity';
    public static final String NEW_QTY_MAPKEY = '*newQuantity';

    public static final String COMPLETED_STATUS = 'Completed';
    public static final String FAILED_STATUS = 'Failed';
    public static final String QUOTE_CLONE_COMPLETED_STATUS = 'Completed';
	public static final String QUOTE_CLONE_PROCESSING_STATUS = 'Processing';
    public static final String CURRENCY_FIELD_TYPE = 'CURRENCY';
    public static final String PRODUCT_CLASS_ADDON_SOFTWARE = 'Addon Software';
    public static final String LARGE_QUOTE_ASYNC_ORDERING_SCENARIO = 'AsyncOrdering';
    public static final String LARGE_QUOTE_CLONE_SCENARIO = 'CloneLargeQuote';
    public static final String LARGE_QUOTE_SPLIT_SCENARIO = 'SplitLargeQuote';
    public static final String LARGE_ORDER_SCENARIO = 'OrderLargeQuote';

    public static final String CPQ_OOB_CREATECONTRACT_SCENARIO = 'CreateContract';

    public static final String OPPORTUNITY_OBJ_NAME = 'Opportunity';
    public static final String QUOTE_OBJ_NAME = 'SBQQ__Quote__c';

    public static final String ERROR_INFLIGHT_INDICATOR = '_in-flight';
    public static final String GENERATE_LARGE_CONTRACT = 'Generate Large Contract';

    public static final String TABLE_BODY = 'Body';
    public static final String TABLE_HEADER = 'Header';
    public static final String TABLE_COLUMN_NAME_KEY = '*Column_Name';
    public static final String TABLE_STYLES_KEY = '*Styles';
    public static final String TABLE_CLASS_KEY = '*Class';
    public static final String TABLE_LINKIFIED_KEY = '*Linkified';
    public static final String TABLE_RELATED_LOOKUP_KEY = '*Related_Lookup';
    public static final String TABLE_FIELD_PATH_KEY = '*Field_Path';
    public static final String TABLE_OVERRIDE_FLS_KEY = '*Override_FLS';
    public static final String TABLE_READ_ONLY_KEY = '*Read_Only';
    public static final String DEFAULT_TABLE_HEAD_STYLES = 'text-align:center;';
    public static final String DEFAULT_TABLE_BODY_STYLES = 'text-align:right;'; 
    public static final String INPUT_TYPE_TEXT = 'text';
    public static final String INPUT_TYPE_NUMBER = 'number';
    
    public static final String PRODUCT2ID_FIELD = 'Product2Id';
    public static final String ORDERITEM_PRODUCT2ID_FIELD_REF = 'PricebookEntry.Product2Id';
    public static final String ORDERITEM_PRODUCTNAME_FIELD_REF = 'PricebookEntry.Product2.Name';
    public static final String ORDERITEM_OBJ_NAME = 'OrderItem';
    public static final String BLANK_STRING = '';
    public static final String USD_CURRENCY_SYMBOL = '$';
    public static final String ONE_SPACE_OF_INDENTATION = '\u00A0';

    public static final String CUSTOM_MODEL_PARENT_FIELD = 'L2I_Parent__c';
    public static final String CUSTOM_MODEL_OBJ_NAME = 'L2I_Custom_Model__mdt';
    public static final String UNDEFINED_STR = 'undefined';
    public static final String CM_LOWER_BOUND_FIELD = 'L2I_Lower_Bound__c';
    public static final String CM_UPPER_BOUND_FIELD = 'L2I_Upper_Bound__c';
    public static final String CM_PER_UNIT_PRICE_FIELD = 'L2I_Per_Unit_Price__c';
    public static final String CM_PRODUCT_ID_FIELD = 'L2I_Product_Id__c';
    public static final String CM_HAS_RATE_SCHEDULE_FIELD = 'L2I_Has_Rate_Schedule__c';

    public static final String TEMP_PLACEHOLDER = 'Temporary Placeholder'; // prevent validation from incorrectly
}