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
public class L2I_ConfigAttributeModel { 
    public String name; 
    public String targetFieldName; 
    public Decimal displayOrder; 
    public String colmnOrder;
    public Boolean required;
    public Id featureId;
    public String position;
    public Boolean appliedImmediately;
    public Boolean applyToProductOptions;
    public Boolean autoSelect;
    public String[] shownValues;
    public String[] hiddenValues;
    public Boolean hidden;
    public String noSuchFieldName;
    public Id myId;
}