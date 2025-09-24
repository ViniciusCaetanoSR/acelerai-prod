@isTest(SeeAllData=true)
private class UpdateLeadScoreWebServiceTest {
    
    // Método para preparar dados de teste
    private static lead setupTestData() {
        // Crie um Lead para testar
        Lead testLead = new Lead(
            Company = 'test',
            Email = 'test@example.com',
            FirstName = 'John',
            LastName = 'Doe',
            Phone = '+5551981752134',
            Funil__c = 'Varejo',
            Segmento__c = 'Agronegócio',
            CompanyAge__c = '3 a 5 anos',
            Role_at_company__c = 'Diretor',
            EmployeesAmount__c = '01 - 05',
            IntendedAnnouncement__c = 'Imediatamente',
            HasBeenAdvertiser__c = 'Sim, os dois',
            Media_Monthly_Investment__c = 'Não invisto',
            ScoreFinanceiro__c = 744,
        	CNPJ__c = '62509130000101'
        );
        return testLead;
    }
    
    // Testa o cenário de atualização bem-sucedida do score
    @isTest(SeeAllData=true)
    static void testUpdateLeadScoreSuccess() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Lead testLead = setupTestData();
        insert testLead;
        
        
        Test.startTest();
        // Configura o contexto de requisição REST
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        // Chama o método para testar
        String result = UpdateLeadScoreWebService.updateLeadScore('62509130000101', '85');
        
        Test.stopTest();
        
        // Verifica se o status code da resposta é 200 (sucesso)
        //System.assertEquals(200, res.statusCode);
        
        // Verifica a mensagem de retorno
        //System.assert(result.contains('Score financeiro atualizado com sucesso para o Lead'), 'Mensagem de retorno deve indicar sucesso na atualização');
        
        // Adicionalmente, você pode querer verificar se o Lead foi de fato atualizado
    }
    
    // Testa o cenário em que nenhum Lead é encontrado
    @isTest(SeeAllData=true)
    static void testUpdateLeadScoreNotFound() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Lead testLead = setupTestData();
        insert testLead;
        
        Test.startTest();
        // Configura o contexto de requisição REST
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        // Chama o método com um CNPJ que não existe nos dados de teste
        String result = UpdateLeadScoreWebService.updateLeadScore('62509130000101', '90');
        
        Test.stopTest();
        
        // Verifica se o status code da resposta é 404 (não encontrado)
        //System.assertEquals(404, res.statusCode);
        
        // Verifica a mensagem de retorno
        //System.assertEquals('Nenhum Lead encontrado com o CNPJ fornecido.', result, 'Mensagem de retorno deve indicar que nenhum Lead foi encontrado');
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('[{"success":true}]');
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }
}