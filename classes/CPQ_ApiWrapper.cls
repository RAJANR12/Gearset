public without sharing class CPQ_ApiWrapper {

    public static Boolean debug = false;

    /** CPQ API METHODS */
    public static final String PRODUCT_LOADER = 'SBQQ.ProductAPI.ProductLoader';

    public static final String QUOTE_READER = 'SBQQ.QuoteAPI.QuoteReader';
    public static final String QUOTE_PRODUCT_ADDER = 'SBQQ.QuoteAPI.QuoteProductAdder';
    public static final String QUOTE_CALCULATOR = 'SBQQ.QuoteAPI.QuoteCalculator';
    public static final String QUOTE_SAVER = 'SBQQ.QuoteAPI.QuoteSaver';


    /** Mini Wrapper around SBQQ API METHODS */
    private static String read(String name, String uid) {
        return SBQQ.ServiceRouter.read(name, uid);
    }
    private static String load(String name, String uid, Object payload) {
        return loadStr(name, uid, JSON.serialize(payload));
    }
    private static String loadStr(String name, String uid, String payloadJson) {
        return SBQQ.ServiceRouter.load(name, uid, payloadJson);
    }
    private static String save(String name, Object model) {
        return saveStr(name, JSON.serialize(model));
    }
    private static String saveStr(String name, String modelJson) {
        return SBQQ.ServiceRouter.save(name, modelJson);
    }

  public static CPQ_ApiDataModels.QuoteModel getQuoteModel(Id quoteId) {
      String jsonResult = read(QUOTE_READER, (String) quoteId);
      CPQ_ApiDataModels.QuoteModel quoteModel = (CPQ_ApiDataModels.QuoteModel) JSON.deserialize(jsonResult, CPQ_ApiDataModels.QuoteModel.class);
      if(debug) {
          System.debug(LoggingLevel.WARN, 'jsonResult: ' + jsonResult);
          System.debug(LoggingLevel.WARN, 'quoteModel: ' + quoteModel);
      }
      return quoteModel;
  }

    public static CPQ_ApiDataModels.ProductModel loadProduct(Id productId, Id pricebookId, String currencyCode) {
        CPQ_ApiDataModels.ProductLoadContext productLoadPayload = new CPQ_ApiDataModels.ProductLoadContext(pricebookId, currencyCode);
        String jsonResultProduct = load(PRODUCT_LOADER, (String) productId, productLoadPayload);
        CPQ_ApiDataModels.ProductModel productModel = (CPQ_ApiDataModels.ProductModel) JSON.deserialize(jsonResultProduct, CPQ_ApiDataModels.ProductModel.class);
        if(debug) {
            System.debug(LoggingLevel.WARN, 'jsonResultProduct: ' + jsonResultProduct);
            System.debug(LoggingLevel.WARN, 'productModel: ' + productModel);
        }
        return productModel;
    }

    public static CPQ_ApiDataModels.ProductModel setOptionsConfigured(CPQ_ApiDataModels.ProductModel productModel) {
        if(productModel.configuration != null){
            productModel.configuration.configured = true;
            productModel.configuration.configurationEntered = true;
            for(CPQ_ApiDataModels.ConfigurationModel configModel : productModel.configuration.optionConfigurations) {
                configModel.configured = true;
                configModel.configurationEntered = true;
            }
            return productModel;
        } else{
          return productModel;
        }
        
    }

    public static CPQ_ApiDataModels.QuoteModel addProductsToQuote(CPQ_ApiDataModels.ProductAddContext productAddPayload) {
        if(debug) {
            System.debug(LoggingLevel.WARN, 'productAddPayloadJSON: ' + JSON.serialize(productAddPayload));
        }
        String updatedQuoteJSON = load(QUOTE_PRODUCT_ADDER, null, productAddPayload);
        CPQ_ApiDataModels.QuoteModel updatedQuoteModel = (CPQ_ApiDataModels.QuoteModel) JSON.deserialize(updatedQuoteJSON, CPQ_ApiDataModels.QuoteModel.class);
        if(debug) {
            System.debug(LoggingLevel.WARN, 'updatedQuoteJSON: ' + updatedQuoteJSON);
            System.debug(LoggingLevel.WARN, 'updatedQuoteModel: ' + updatedQuoteModel);
        }

        return updatedQuoteModel;
    }

    public static CPQ_ApiDataModels.QuoteModel saveQuote(CPQ_ApiDataModels.QuoteModel quoteModel) {
        String savedQuoteJSON = save(QUOTE_SAVER, quoteModel);

        CPQ_ApiDataModels.QuoteModel updatedQuoteModel = (CPQ_ApiDataModels.QuoteModel) JSON.deserialize(savedQuoteJSON, CPQ_ApiDataModels.QuoteModel.class);
        if(debug) {
            System.debug(LoggingLevel.WARN, 'updatedQuoteModel: ' + updatedQuoteModel);
        }

        return updatedQuoteModel;
    }

    /*
     * Make sure that the calculation call happens outside of quote updates
     * to prevent a mixed DML operation error
     */
    public static void calculateQuote(CPQ_ApiDataModels.QuoteModel quoteModel) {
        CPQ_ApiDataModels.QuoteCalculatorContext ctx = new CPQ_ApiDataModels.QuoteCalculatorContext(quoteModel, 'L2I_CalculatorCallback');
        load(QUOTE_CALCULATOR,null,ctx);
    }

}