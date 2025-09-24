@isTest(SeeAllData=true)
private class IntegrationSGCFlowServiceTest {
    @isTest(SeeAllData=true)
    static void testSendOpportunityData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        IntegrationSGCFlowService.sgcRequest request = new IntegrationSGCFlowService.sgcRequest();
        request.type = 'Test Type';
        request.payload = new List<sObject>{ new Opportunity(Name = 'Test Opportunity') };

        List<IntegrationSGCFlowService.sgcRequest> requests = new List<IntegrationSGCFlowService.sgcRequest>{ request };

        Test.startTest();
        IntegrationSGCFlowService.sendOpportunityData(requests);
        Test.stopTest();
    }

    @isTest
    static void testSendData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        LeadUtils.generateLeads(2);

        List<Lead> leads = [
            SELECT Id, Name, Phone, Email, Owner.Email, Status, Company, Segmento__c, WhatsYourInstagram__c, City, State
            FROM Lead
            LIMIT 2
        ];

        if (!leads.isEmpty()) {
            Test.startTest();
            IntegrationSGCFlowService.sendData(leads, 'Lead');
            Test.stopTest();
        }
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('[{"success":true}]');
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }
}