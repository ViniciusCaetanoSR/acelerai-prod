@isTest
private class UpdateLeadScoreTest {

    @isTest
    static void testUpdateLeadScore() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead testLead = VirtualTestData.createLead('Jonh Doe', 'Pré Cadastro', 'Test', 'test@example.com', '+5551981752134');
        testLead.Segmento__c = 'Agronegócio';
        testLead.CompanyAge__c = '3 a 5 anos';
        testLead.Role_at_company__c = 'Diretor';
        testLead.EmployeesAmount__c = '01 - 05';
        testLead.IntendedAnnouncement__c = 'Imediatamente';
        testLead.HasBeenAdvertiser__c = 'Sim, os dois';
        testLead.Media_Monthly_Investment__c = 'Não invisto';
        testLead.ScoreFinanceiro__c = 744;
        insert testLead;
    
        testLead.HasBeenAdvertiser__c = 'Não';
        testLead.CNPJ__c = '09.877.750/0001-10';
        update testLead;
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