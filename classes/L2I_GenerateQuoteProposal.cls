/**
 *      @author       Sarah Kennedy
 *      @date         09/22/2020
 *      @description  see Create and Save Quote Proposal API
 *                    https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_quote_document.htm
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Sarah Kennedy                 09/22/2020        Initial
 */
public with sharing class L2I_GenerateQuoteProposal {
    public String save(L2I_QuoteProposalModel context) {
        return SBQQ.ServiceRouter.save('SBQQ.QuoteDocumentAPI.Save', JSON.serialize(context));
    }
}