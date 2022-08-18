/**
 *      @author       Sarah Kennedy
 *      @date         01/30/2020
 *      @description  see CPQ Developer Guide API Models
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 01/30/2020        Initial
 */
public class L2I_QuoteModel {
    public SBQQ__Quote__c record;
    public L2I_QuoteLineModel[] lineItems;
    public L2I_QuoteLineGroupModel[] lineItemGroups;
    public Integer nextKey;
    public Boolean applyAdditionalDiscountLast;
    public Boolean applyPartnerDiscountFirst;
    public Boolean channelDiscountsOffList;
    public Decimal customerTotal;
    public Decimal netTotal;
    public Decimal netNonSegmentTotal;
}