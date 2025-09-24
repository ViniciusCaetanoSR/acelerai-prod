@isTest
private class IntegrationAureaServiceTest {

    @isTest
    static void testBuscarEnviarDados() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        // Criar dados de teste
        Account cliente = VirtualTestData.createAccount('Teste Cliente');
        insert cliente;

        Opportunity opp = VirtualTestData.createOpportunity('Opportunity Test', cliente.Id, '+5551981752134', 'Agronegócio', 'Agência', Date.today(), 'Qualificação');
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;

        // Criar múltiplos casos para testar a lista de caseIds
        List<Case> casos = new List<Case>();
        for (Integer i = 0; i < 3; i++) {
            casos.add(VirtualTestData.createCase(cliente.Id, opp.Id, 'Primeiro Contato ' + i));
        }
        insert casos;

        // Coletar os IDs dos casos
        List<Id> caseIds = new List<Id>();
        for (Case caso : casos) {
            caseIds.add(caso.Id);
        }

        Product2 produtoPraca = new Product2(Name = 'Produto de Praça', Tipo__c = 'Direito de Uso', IsActive = true);
        Product2 produtoPeca = new Product2(Name = 'Produto de Peça', Tipo__c = 'Peça', IsActive = true);
        Product2 produtoPerformance = new Product2(Name = 'Produto Performance', Tipo__c = 'Performance', IsActive = true);
        insert new List<Product2> { produtoPraca, produtoPeca, produtoPerformance };

        PricebookEntry pbePraca = new PriceBookEntry(
            Product2Id = produtoPraca.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 1000,
            IsActive = true
        );
        PricebookEntry pbePeca = new PriceBookEntry(
            Product2Id = produtoPeca.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 50,
            IsActive = true
        );
        PricebookEntry pbePerformance = new PriceBookEntry(
            Product2Id = produtoPerformance.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 1,
            IsActive = true
        );
        insert new List<PricebookEntry> { pbePraca, pbePeca, pbePerformance };

        Quote quote = VirtualTestData.createQuote('Teste Quote', opp.Id);
        insert quote;

        QuoteLineItem praca = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pbePraca.Id,
            Quantity = 1,
            UnitPrice = 1000
        );
        QuoteLineItem peca = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pbePeca.Id,
            Quantity = 2,
            UnitPrice = 50
        );
        QuoteLineItem performance = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pbePerformance.Id,
            Quantity = 1,
            UnitPrice = 10
        );
        insert new List<QuoteLineItem> { praca, peca, performance };

        IntegrationAurea__c rec = new IntegrationAurea__c(Name = 'AUREA', Endpoint__c = 'https://blabla.com/aurea');
        insert rec;

        Integer logsBefore = [SELECT COUNT() FROM Log__c];

        // Chamar o método com a lista de caseIds
        IntegrationAureaService.buscarEnviarDados(caseIds);
        Test.stopTest();

        // Verificar os logs gerados
        List<Log__c> logs = [SELECT Id, StatusLog__c FROM Log__c];
        for (Log__c log : logs) {
            System.debug('Status do log: ' + log.StatusLog__c);
        }
        // Ajustar a asserção para o número de logs esperado
        System.assertEquals(logsBefore + (2 * caseIds.size()), logs.size(), 'Dois logs de sucesso deveriam ter sido criados por caso para código 200');
    }

    @isTest
    static void testRequestAureaErrorLogCreation() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorWithError());

        IntegrationAurea__c rec = new IntegrationAurea__c(Name = 'AUREA', Endpoint__c = 'https://blabla.com/aurea');
        insert rec;

        Account cliente = VirtualTestData.createAccount('Teste Cliente');
        insert cliente;

        Opportunity opp = VirtualTestData.createOpportunity('Opportunity Test', cliente.Id, '+5551981752134', 'Agronegócio', 'Agência', Date.today(), 'Qualificação');
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;

        Case caso = VirtualTestData.createCase(cliente.Id, opp.Id, 'Primeiro Contato');
        insert caso;

        String requestBodyJson = '{"cliente": {}, "pracas": [], "pecas": [], "performance": []}';

        Test.startTest();
        IntegrationAureaService.requestAurea(requestBodyJson, caso.Id);
        Test.stopTest();

        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assert(logs.size() == 1 || logs.size() == 2, 'O número de logs deve ser 1 ou 2');
        System.debug('LogSize tamanho: ' + logs.size());
    }

    @isTest
    static void testRequestAureaWithNullConfiguration() {
        Test.startTest();
        IntegrationAureaService.requestAurea('{"cliente": {}, "pracas": [], "pecas": [], "performance": []}', '500N400000NadVRIAZ');
        Test.stopTest();

        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assertEquals(0, logs.size(), 'nenhum log deveria ter sido criado, devido à configuração nula');
    }

    // Mock de Resposta de Sucesso
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('[{"success":true}]');
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }

    // Mock de Resposta de Erro
    public class MockHttpResponseGeneratorWithError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Erro ao processar a solicitação');
            return res;
        }
    }
}