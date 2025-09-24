@isTest
private class IntegrationAureaConversationHistoryTest {

    @TestSetup
    static void setup() {
        IntegrationAurea__c aurea = new IntegrationAurea__c(
           Name = 'Aurea',
            endPoint__c = 'https://dev.api.aurea'
        );
        insert aurea;

        Case testCase = new Case(
            Status = 'Prazo',
            PrimeiroContato__c = Date.valueOf('2025-05-05'),
            PrimeiroAcesso__c = Date.valueOf('2025-05-06'),
            FinalizouFormulario__c = Date.valueOf('2025-05-07'),
            CelebridadePreAprovado__c = Date.valueOf('2025-05-07'),
            EntregaRoteiro__c = Date.valueOf('2025-05-08'),
            AprovouRoteiro__c = Date.valueOf('2025-05-09'),
            StartProducao__c = Date.valueOf('2025-05-10'),
            AprovouCampanha__c = Date.valueOf('2025-05-11'),
            CelebridadeAprovou__c = Date.valueOf('2025-05-12'),
            Finalizado__c = Date.valueOf('2025-05-13'),
            Subject = 'Test Case'
        );
        insert testCase;
    }

    @isTest
    static void testEmptyRequestBody() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/aurea/conversation/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        String result = IntegrationAureaConversationHistory.updateCaseFromConversation();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('A requisição é inválida', result);
    }

    @isTest
    static void testBlankId() {
        IntegrationAureaConversationHistory.ConversationRequestBody body =
            new IntegrationAureaConversationHistory.ConversationRequestBody();
        body.id = '';
        body.status = 'In Progress';

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/aurea/conversation/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        String result = IntegrationAureaConversationHistory.updateCaseFromConversation();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('Campo Id é obrigatório', result);
    }

    @isTest
    static void testBlankStatus() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        IntegrationAureaConversationHistory.ConversationRequestBody body =
            new IntegrationAureaConversationHistory.ConversationRequestBody();
        body.id = testCase.Id;
        body.status = '';

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/aurea/conversation/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        String result = IntegrationAureaConversationHistory.updateCaseFromConversation();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('Campo Status é obrigatório', result);
    }

    @isTest
    static void testCaseNotFound() {
        IntegrationAureaConversationHistory.ConversationRequestBody body =
            new IntegrationAureaConversationHistory.ConversationRequestBody();
        body.id = '500000000000000';
        body.status = 'In Progress';

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/aurea/conversation/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        String result = IntegrationAureaConversationHistory.updateCaseFromConversation();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('Caso não encontrado para o Id informado', result);
    }

    @isTest
    static void testInvalidJson() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/aurea/conversation/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"invalid_json":}');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        String result = IntegrationAureaConversationHistory.updateCaseFromConversation();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(result.startsWith('Erro: Formato de JSON inválido'));
    }

    @isTest
    static void testSuccessfulUpdate() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        IntegrationAureaConversationHistory.ConversationRequestBody body =
            new IntegrationAureaConversationHistory.ConversationRequestBody();
        body.id = testCase.Id;
        body.status = 'Completed';
        body.primeiroContato = Date.valueOf('2025-06-01');
        body.primeiroAcesso = Date.valueOf('2025-06-02');
        body.finalizouFormulario = Date.valueOf('2025-06-03');
        body.celebridadePreAprovado = Date.valueOf('2025-06-04');
        body.entregaRoteiro = Date.valueOf('2025-06-05');
        body.aprovouRoteiro = Date.valueOf('2025-06-06');
        body.startProducao = Date.valueOf('2025-06-07');
        body.aprovouCampanha = Date.valueOf('2025-06-08');
        body.celebridadeAprovou = Date.valueOf('2025-06-09');
        body.finalizado = Date.valueOf('2025-06-10');

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/aurea/conversation/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        String result = IntegrationAureaConversationHistory.updateCaseFromConversation();

        System.assertEquals(201, RestContext.response.statusCode);
        System.assertEquals('Atualizado com sucesso', result);

    }
}