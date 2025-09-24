public class IntegrationAureaService {

    public static void buscarEnviarDados(List<Id> caseIds) {
        List<Case> caseList = [SELECT Id, Id_da_Oportunidade__c FROM Case WHERE Id IN :caseIds AND Id_da_Oportunidade__c <> null];

        Set<Id> oppIds = new Set<Id>();
        for (Case caso : caseList) {
            oppIds.add(caso.Id_da_Oportunidade__c);
        }

        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id,
                   EndOfContractDate__c,
                   Owner.Name,
                   ContractStartDate__c,
                   ContatosMarketing__r.email,
                   ContatosMarketing__r.MarketingContactPhone__c,
                   ContatosMarketing__r.Name,
                   Emaill__c,
                   Telefone__c,
                   Company__c,
                   AccountId,
                   Link_Oportunidade_SGC__c
            FROM Opportunity
            WHERE id IN :oppIds
        ]);

        Set<Id> accIds = New Set<Id>();
        for (Opportunity opp : oppMap.values()) {
            accIds.add(opp.AccountId);
        }

        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Name,
                   CNPJ__c,
                   Phone,
                   TradeName__c,
                   BillingPostalCode,
                   BillingStreet,
                   BillingCity,
                   BillingState,
                   BillingCountry,
                   Instagram__c,
                   Segmento__c
            FROM Account
            WHERE id IN :accIds
        ]);


        List<QuoteLineItem> allQuoteLineItems = [
            SELECT id,
                   Product2.Name,
                   QuoteId,
                   Quote.OpportunityId,
                   Estado__c,
                   Cidade__c,
                   Meses__c,
                   TotalPrice,
                   ProductType__c,
                   Quantity,
                   UnitPrice,
                   Segmento__c,
                   Subsegmento__c,
                   Regiao__c
            FROM QuoteLineItem
            WHERE Quote.OpportunityId IN :oppIds
            AND (Quote.Sincronizado__c = true
            OR Quote.PagamentoFuturo__c = true)
            AND (ProductType__c = 'Direito de Uso' OR ProductType__c = 'Performance') //'performance' adicionado em 28/05 por Bárbara Mór
        ];

        Map<Id, List<QuoteLineItem>> pracasByOppId = new Map<Id, List<QuoteLineItem>>();
        Map<Id, List<QuoteLineItem>> pecasByOppId = new Map<Id, List<QuoteLineItem>>();
        Map<Id, List<QuoteLineItem>> performanceByOppId = new Map<Id, List<QuoteLineItem>>(); //'performance' adicionado em 28/05 por Bárbara Mór

        for (QuoteLineItem qli : allQuoteLineItems) {
            Id oppId = qli.Quote.OpportunityId;

            if (qli.ProductType__c == 'Direito de Uso') {
                if (!pracasByOppId.containsKey(oppId)) {
                    pracasByOppId.put(oppId, new List<QuoteLineItem>());
                }
                pracasByOppId.get(oppId).add(qli);

            } else if(qli.ProductType__c == 'Performance') { //'performance' adicionado em 28/05 por Bárbara Mór
                if(!performanceByOppId.containsKey(oppId)){
                    performanceByOppId.put(oppId, new List<QuoteLineItem>());
                }
                performanceByOppId.get(oppId).add(qli);

            } else {
                if (!pecasByOppId.containsKey(oppId)) {
                    pecasByOppId.put(oppId, new List<QuoteLineItem>());
                }
                pecasByOppId.get(oppId).add(qli);
            }
        }

        // Processa cada Case e chama enviarDados
        for (Case caso : caseList) {
            Opportunity opp = oppMap.get(caso.Id_da_Oportunidade__c);
            Account cliente = accMap.get(opp.AccountId);
            List<QuoteLineItem> pracas = pracasByOppId.get(opp.Id) != null ? pracasByOppId.get(opp.Id) : new List<QuoteLineItem>();
            List<QuoteLineItem> pecas = pecasByOppId.get(opp.Id) != null ? pecasByOppId.get(opp.Id) : new List<QuoteLineItem>();
            // List<QuoteLineItem> performance = performanceByOppId.get(opp.Id) != null ? performanceByOppId.get(opp.Id) : new List<QuoteLineItem>(); //'performance' adicionado em 28/05 por Bárbara Mór

            enviarDados(caso, opp, cliente, pracas, pecas);
        }
    }


    public static void enviarDados(Case caso, Opportunity opp, Account cliente, List<QuoteLineItem > pracas, List<QuoteLineItem> pecas) { //'performance' adicionado em 28/05 por Bárbara Mór

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('cliente', getClienteData(opp, cliente, caso));
        requestBody.put('pracas', getPracasData(pracas));
        requestBody.put('pecas', getPecasData(pecas));
        // requestBody.put('performance', getPerformanceData(performance));

        // Serializar o corpo da requisição para JSON
        String requestBodyJson = JSON.serialize(requestBody);
        requestAurea(requestBodyJson, caso.Id);
    }

    @future(callout=true)
    public static void requestAurea(String requestBodyJson, Id relatedRecordId) {
        try {
        IntegrationAurea__c rec = IntegrationAurea__c.getValues('AUREA');
        System.debug('Chamou o requestAurea');

        if (rec == null) {
            System.debug('O rec é nulo');
            return;
        }
        System.debug('O rec não é nulo');

        HttpRequest request = new HttpRequest();
        request.setEndpoint(rec.Endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBodyJson);
        request.setTimeout(120000);
        System.debug('X: request ' + request);
        System.debug('X: requestBodyJson ' + requestBodyJson);

        HttpResponse response = new Http().send(request);

            if (String.valueOf(response.getStatusCode()).startsWith('20')) {
                System.debug('Dados enviados com sucesso!');
                System.debug('StatusCode do if: ' + response.getStatusCode());
                LoggerUtility.createLogIntegrationSuccess(response, relatedRecordId, requestBodyJson, 'Aurea', 'Método: requestAurea');

            } else {
                System.debug('Mensagem do else: ' + response.getStatusCode());
                LoggerUtility.createLogIntegrationException(response, relatedRecordId, requestBodyJson, 'Aurea', 'Método: requestAurea');
            }

        } catch (Exception e) {
            System.debug('Mensagem da exceção: ' + e.getMessage());
            LoggerUtility.createLogException(e, relatedRecordId, 'Método: requestAurea');
        }
    }


    public static Map<String, Object> getClienteData(Opportunity opp, Account cliente, Case caso ) {
        Map<String, Object> clienteData = new Map<String, Object>();
        clienteData.put('razaoSocial', cliente.Name);
        clienteData.put('nomeFantasia', cliente.TradeName__c);
        clienteData.put('cnpj', cliente.CNPJ__c);
        clienteData.put('endereco', cliente.BillingStreet);
        clienteData.put('cep', cliente.BillingPostalCode);
        clienteData.put('bairro', cliente.BillingCity);
        clienteData.put('municipio', cliente.BillingState);
        clienteData.put('uf', cliente.BillingCountry);
        clienteData.put('email', opp.Emaill__c);
        clienteData.put('telefone', cliente.Phone);
        clienteData.put('instagram', cliente.Instagram__c);
        /*clienteData.put('dataEnvio', cliente.Data_de_Envio__c);
        clienteData.put('dataValidade', cliente.Data_de_Validade__c);*/
        clienteData.put('segmento', cliente.Segmento__c);
        clienteData.put('caso', caso.Id);

        // Incluir vendedor da oportunidade
        clienteData.put('vendedor', opp.Owner.Name);
        clienteData.put('linkSGC', opp.Link_Oportunidade_SGC__c);

        // Incluir contato do marketing
        Map<String, Object> contatoMarketing = new Map<String, Object>();

        contatoMarketing.put('nome', opp.ContatosMarketing__r.Name);
        contatoMarketing.put('telefone', opp.ContatosMarketing__r.MarketingContactPhone__c);
        contatoMarketing.put('email', opp.ContatosMarketing__r.email);
        clienteData.put('contatoMarketing', contatoMarketing);

        // Adicionar informações do contrato
        clienteData.put('dataInicioContrato', opp.ContractStartDate__c);
        clienteData.put('dataTerminoContrato', opp.EndOfContractDate__c);

        // Enviar clienteData para Aurea
        //AureaService.enviarProposta(clienteData);
        return clienteData;
    }

    public static List<Map<String, Object>> getPracasData(List<QuoteLineItem> pracas) {
        List<Map<String, Object>> pracasData = new List<Map<String, Object>>();
        for (QuoteLineItem praca : pracas) {
            Map<String, Object> pracaData = new Map<String, Object>();
            pracaData.put('celebridade', praca.Product2.Name );
            pracaData.put('uf', praca.Estado__c );
            pracaData.put('cidade', praca.Cidade__c );
            pracaData.put('mesesVeiculacao', praca.Meses__c );
            pracaData.put('segmento', praca.Segmento__c );
            pracaData.put('subsegmento', praca.Subsegmento__c );
            pracaData.put('regiao', praca.Regiao__c );
            pracaData.put('valor', praca.TotalPrice );
            pracasData.add(pracaData);
        }
        return pracasData;
    }

    public static List<Map<String, Object>> getPecasData(List<QuoteLineItem> pecas) {
        List<Map<String, Object>> pecasData = new List<Map<String, Object>>();
        for (QuoteLineItem peca : pecas) {
            Map<String, Object> pecaData = new Map<String, Object>();
            pecaData.put('nomePeça', peca.Product2.Name);
            pecaData.put('valorUnitario', peca.UnitPrice );
            pecaData.put('quantidade', peca.Quantity);
            pecaData.put('segmento', peca.Segmento__c);
            pecaData.put('subsegmento', peca.Subsegmento__c);
            pecaData.put('regiao', peca.Regiao__c);
            pecasData.add(pecaData);
        }
        return pecasData;
    }
    // /**
    //  * criado em 28/05/25 por Bárbara Mór
    //  */
    // // public static List<Map<String, Object>> getPerformanceData(List<QuoteLineItem> performances){
    // //     List<Map<String,Object>> performancesData = new List<Map<String,Object>>();

    // //     for(QuoteLineItem performance : performances){
    // //         Map<String,Object> perfData = new Map<String,Object>();
    // //         perfData.put('nomePerformance', performance.Product2.Name);
    // //         perfData.put('valorUnitario', performance.UnitPrice);
    // //         perfData.put('quantidade', performance.Quantity);
    // //         perfData.put('segmento', performance.Segmento__c);
    // //         perfData.put('subsegmento', performance.Subsegmento__c);
    // //         perfData.put('regiao', performance.Regiao__c);
    // //         performancesData.add(perfData);
    // //     }
    // //     return performancesData;
    // }
}