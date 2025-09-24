@RestResource(urlMapping='/UpdateLeadScore/*')
global class UpdateLeadScoreWebService {
    
    global class WebhookRequestBody {
        public String document;
        public String score;
    }

    @HttpPost
    global static String updateLeadScore(String document, String score) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
        
        system.debug('UpdateLeadScoreWebService - updateLeadScore - document : ' + document);
        system.debug('UpdateLeadScoreWebService - updateLeadScore - score : ' + score);

        // Desserializa o JSON do corpo da requisição para o formato da classe WebhookRequestBody
        
        //WebhookRequestBody body = (WebhookRequestBody)JSON.deserialize(req.requestBody.toString(), WebhookRequestBody.class);

        // Limpa o CNPJ para remover pontuações e espaços
        String cleanedCnpj = document.replaceAll('[^\\d]', '');

        // Procura por Leads com o CNPJ correspondente
        List<Lead> leads = [SELECT Id, Name, CNPJ__c, ScoreFinanceiro__c, byPassGetScoreFin__c FROM Lead WHERE CNPJ__c = :cleanedCnpj LIMIT 1];
        
        String retorno = ''; 

        if (!leads.isEmpty()) {
            Lead leadToUpdate = leads.get(0);
            system.debug('UpdateLeadScoreWebService - updateLeadScore - leadToUpdate : ' + leadToUpdate);
            // Atualiza o score financeiro do Lead
            leadToUpdate.ScoreFinanceiro__c = Decimal.valueOf(score);
            leadToUpdate.byPassGetScoreFin__c = true;
            update leadToUpdate;
			res.statusCode = 200;
            retorno = 'Score financeiro atualizado com sucesso para o Lead: ' + leadToUpdate.Name;
        } else {
            res.statusCode = 404; // Not Found
            retorno = 'Nenhum Lead encontrado com o CNPJ fornecido.';
        }

        return retorno;
    }

}