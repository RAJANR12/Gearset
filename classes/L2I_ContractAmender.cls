/**
 *      @author       Sarah Kennedy
 *      @date         01/30/2020
 *      @description  see CPQ Developer Guide Contract APIs
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 01/30/2020        Initial
 */
public with sharing class L2I_ContractAmender {
    public L2I_QuoteModel load(String contractId) {
        String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, null);
        return (L2I_QuoteModel) JSON.deserialize(quoteJSON, L2I_QuoteModel.class);
    }
}