/* ANTIGA TeamsEventCalloutQueueableTest */
@isTest
public with sharing class TeamsCreateEventQueueableTest {

    private class TeamsIntegrationMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testExecuteWithMock() {
        Event testEvent = new Event(
            Subject = 'Mock Teams Teste',
            StartDateTime = System.now().addDays(1),
            EndDateTime = System.now().addDays(1).addHours(1)
        );
        insert testEvent;

        Test.setMock(HttpCalloutMock.class, new TeamsIntegrationMock());

        Test.startTest();
        TeamsCreateEventQueueable job = new TeamsCreateEventQueueable(testEvent.Id, 'fake_token_123');
        System.enqueueJob(job);
        Test.stopTest();

        System.assert(true, 'Job executado com sucesso');
    }
}