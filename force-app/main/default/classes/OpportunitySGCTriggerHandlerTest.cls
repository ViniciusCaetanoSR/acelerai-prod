@isTest
private class OpportunitySGCTriggerHandlerTest {
    
    @isTest
    static void testProcessOpportunities() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account testAccount1 = VirtualTestData.createAccount('Test Account 1');
        Account testAccount2 = VirtualTestData.createAccount('Test Account 2');
        
        insert new List<Account> {
            testAccount1,
            testAccount2
        };

        Opportunity testOpportunity1 = VirtualTestData.createOpportunity('Test Opportunity 1', testAccount1.Id, '51981782234', 'Agronegócio', 'Agência', Date.today(), 'Aprovado');
        Opportunity testOpportunity2 = VirtualTestData.createOpportunity('Test Opportunity 2', testAccount1.Id, '51981782235', 'Agronegócio', 'Agência', Date.today(), 'Aprovado');

        insert new List<Opportunity> {
            testOpportunity1,
            testOpportunity2
        };
        
        Test.startTest();
        OpportunitySGCTriggerHandler.processOpportunities(new List<Id>{ testOpportunity1.Id, testOpportunity2.Id });
        Test.stopTest();
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