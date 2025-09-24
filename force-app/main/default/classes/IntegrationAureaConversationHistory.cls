@RestResource(urlMapping='/aurea/conversation/*')
global class IntegrationAureaConversationHistory {
    global class ConversationRequestBody {
        public String id;
        public String status;
        public Date primeiroContato;
        public Date primeiroAcesso;
        public Date finalizouFormulario;
        public Date celebridadePreAprovado;
        public Date entregaRoteiro;
        public Date aprovouRoteiro;
        public Date startProducao;
        public Date aprovouCampanha;
        public Date celebridadeAprovou;
        public Date finalizado;
    }

    @HttpPost
    global static String updateCaseFromConversation() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String retorno;

        if (req.requestBody.toString().length() == 0 || req.requestBody == null) {
            res.statusCode = 400;
            retorno = 'A requisição é inválida';
            return retorno;
        }

        try {
            String body = req.requestBody.toString();

            ConversationRequestBody requestBody = (ConversationRequestBody) JSON.deserialize(body, ConversationRequestBody.class);
            System.debug('requestBody: ' + requestBody);

            if (String.isBlank(requestBody.id)) {
                res.statusCode = 400;
                return 'Campo Id é obrigatório';
            }

            if (String.isBlank(requestBody.status)) {
                res.statusCode = 400;
                return 'Campo Status é obrigatório';
            }

            Case[] caseToUpdate = [
                SELECT Id,
                       Status,
                       PrimeiroContato__c,
                       PrimeiroAcesso__c,
                       FinalizouFormulario__c,
                       CelebridadePreAprovado__c,
                       EntregaRoteiro__c,
                       AprovouRoteiro__C,
                       StartProducao__c,
                       AprovouCampanha__c,
                       CelebridadeAprovou__c,
                       Finalizado__c
                FROM Case
                WHERE Id = :requestBody.id
            ];

            if (caseToUpdate.isEmpty()) {
                res.statusCode = 400;
                return 'Caso não encontrado para o Id informado';
            }

            Case caseUpdate = caseToUpdate[0];
            caseUpdate.Status = requestBody.Status;
            caseUpdate.PrimeiroContato__c = requestBody.primeiroContato;
            caseUpdate.PrimeiroAcesso__c = requestBody.primeiroAcesso;
            caseUpdate.FinalizouFormulario__c = requestBody.finalizouFormulario;
            caseUpdate.CelebridadePreAprovado__c = requestBody.celebridadePreAprovado;
            caseUpdate.EntregaRoteiro__c = requestBody.entregaRoteiro;
            caseUpdate.AprovouRoteiro__c = requestBody.aprovouRoteiro;
            caseUpdate.StartProducao__c = requestBody.startProducao;
            caseUpdate.AprovouCampanha__c = requestBody.aprovouCampanha;
            caseUpdate.CelebridadeAprovou__c = requestBody.celebridadeAprovou;
            caseUpdate.Finalizado__c = requestBody.finalizado;

            update caseUpdate;

            res.statusCode = 201;
            retorno = 'Atualizado com sucesso';

        } catch (JSONException e) {
            res.statusCode = 400;
            retorno = 'Erro: Formato de JSON inválido. Detalhes: ' + e.getMessage();
        } catch (Exception e) {
            res.statusCode = 500;
            retorno = 'Erro interno no servidor. Detalhes: ' + e.getMessage();
        }

        System.debug('Retorno: ' + retorno);
        return retorno;
    }
}