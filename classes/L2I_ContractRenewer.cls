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
public with sharing class L2I_ContractRenewer {
    public L2I_QuoteModel[] load(String masterContractId, String context) {
        String quotesJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractRenewer', masterContractId, context);
        return (L2I_QuoteModel[]) JSON.deserialize(quotesJSON, List<L2I_QuoteModel>.class);
    }
}