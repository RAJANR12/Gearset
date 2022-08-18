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
public class L2I_ProductModel {
    public Product2 record;
    public Id upgradedAssetId;
    public String currencySymbol;
    public String currencyCode;
    public String[] featureCategories;
    public L2I_OptionModel[] options;
    public L2I_FeatureModel[] features;
    public L2I_ConfigurationModel configuration;
    public L2I_ConfigAttributeModel[] configurationAttributes;
    public L2I_ConfigAttributeModel[] inheritedConfigurationAttributes;
    public L2I_ConstraintModel[] constraints; 
}