@IsTest
private class IntegrationSGCConversationHistoryTest {
    @testSetup
    static void setup() {
        Account account = new Account(
            Name = 'Test Account',
            CNPJ__c = '42113212000125',
            BillingStreet = 'Rua das Flores, 123',
            BillingCity = 'São Paulo',
            BillingState = 'SP',
            BillingPostalCode = '01001-000',
            BillingCountry = 'Brasil',
            CompanyName__c = 'Test Account 1'
        );
        insert account;

        Contact contact = new Contact(LastName = 'Test Contact', Email = '6845387306452580136@test.com', Phone = '51981617948', AccountId = account.Id);
        insert contact;

        Opportunity opportunity = new Opportunity(
            Name = 'Opportunity da Conta 1',
            AccountId = account.Id,
            Telefone__c = '5551981617948',
            Segmento__c = 'Aplicativos',
            Tipo_de_cliente__c = 'Cliente Final',
            CloseDate = Date.today().addDays(5),
            StageName = 'Qualificação'
        );
        insert opportunity;
    }

    @IsTest
    static void testReceiveConversationHistorySuccess() {
        User userTest = [SELECT Id, Email, Name FROM User LIMIT 1];
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];

        String requestBody =
            '{"employee_email":"' +
            userTest.Email +
            '",' +
            '"opportunity_id":"' +
            opportunity.Id +
            '",' +
            '"lead_id":null,' +
            '"history":[{' +
            '"fromName":"vendedor",' +
            '"created_at":"2024-08-01",' +
            '"message":"Olá"}]}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ReceiveConversationHistory';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;

        String result = IntegrationSGCConversationHistory.receiveConversationHistory();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @IsTest
    static void testReceiveConversationHistoryInvalidLeadId() {
        User userTest = [SELECT Id, Email, Name FROM User LIMIT 1];
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];

        String requestBody =
            '{"employee_email":"' +
            userTest.Email +
            '",' +
            '"opportunity_id":"' +
            opportunity.Id +
            '",' +
            '"lead_id":"00Q000000000000",' +
            '"history":[{' +
            '"fromName":"vendedor",' +
            '"created_at":"2024-08-01",' +
            '"message":"Olá"}]}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ReceiveConversationHistory';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;

        String result = IntegrationSGCConversationHistory.receiveConversationHistory();

        System.assertEquals('ID de lead inválido', result, 'Lead ID should be invalid');
    }

    @IsTest
    static void testReceiveConversationHistoryEmptyHistory() {
        User userTest = [SELECT Id, Email, Name FROM User LIMIT 1];
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];

        String requestBody = '{"employee_email":"' + userTest.Email + '",' + '"opportunity_id":"' + opportunity.Id + '",' + '"lead_id":null,' + '"history":[]}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ReceiveConversationHistory';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;

        String result = IntegrationSGCConversationHistory.receiveConversationHistory();

        System.assertEquals('Histórico não fornecido', result, 'Empty history should return an error');
    }

    @IsTest
    static void testReceiveConversationHistoryMissingBody() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ReceiveConversationHistory';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;

        String result = IntegrationSGCConversationHistory.receiveConversationHistory();

        System.assertEquals('A requisição é inválida', result, 'Empty body should return an error');
    }

    @IsTest
    static void testReceiveConversationHistoryInvalidJSON() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ReceiveConversationHistory';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"employee_email":,}');
        RestContext.request = req;
        RestContext.response = res;

        try {
            IntegrationSGCConversationHistory.receiveConversationHistory();
            System.assert(false, 'Expected JSON exception');
        } catch (JSONException e) {
            System.assert(e.getMessage().contains('Erro ao deserializar JSON'), 'Expected JSON deserialization error');
        }
    }
}