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
public class L2I_OptionModel { 
    public SBQQ__ProductOption__c record; 
    public Map<String,String> externalConfigurationData; 
    public Boolean configurable; 
    public Boolean configurationRequired; 
    public Boolean quantityEditable; 
    public Boolean priceEditable; 
    public Decimal productQuantityScale; 
    public Boolean priorOptionExists; 
    public Set<Id> dependentIds; 
    public Map<String,Set<Id>> controllingGroups; 
    public Map<String,Set<Id>> exclusionGroups; 
    public String reconfigureDimensionWarning; 
    public Boolean hasDimension; 
    public Boolean isUpgrade; 
    public String dynamicOptionKey; 
}