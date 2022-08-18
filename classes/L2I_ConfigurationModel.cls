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
public class L2I_ConfigurationModel { 
    public Id configuredProductId; 
    public Id optionId; 
    public SBQQ__ProductOption__c optionData; // Editable data about the option in question, such as quantity or discount 
    public SBQQ__ProductOption__c configurationData; 
    public SBQQ__ProductOption__c inheritedConfigurationData; 
    public L2I_ConfigurationModel[] optionConfigurations; 
    public Boolean configured; 
    public Boolean changedByProductActions; 
    public Boolean isDynamicOption; 
    public Boolean isUpgrade; 
    public Set<Id> disabledOptionIds; 
    public Set<Id> hiddenOptionIds; 
    public Decimal listPrice; 
    public Boolean priceEditable; 
    public String[] validationMessages; 
    public String dynamicOptionKey; 
}