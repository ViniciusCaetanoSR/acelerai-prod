/** Antiga TeamsEventUpdateQueueableTest*/
@isTest
public with sharing class TeamsUpdateEventQueueableTest {

    private class TeamsUpdateMockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{}'); 
            return res;
        }
    }

    @isTest
    static void testUpdateTeamsEventJob() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'klamar',
            LastName = 'Lamar',
            Email = 'kendricklamar' + Math.random() + '@huhuhu.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            UserName = 'test' + Math.random() + '@huhuhu.com',
            HasTeamsConsent__c = true,
            TeamsAccessToken__c = 'fake_token'
        );
        insert u;

        Event ev = new Event(
            Subject = 'Evento Update',
            StartDateTime = System.now().addDays(1),
            EndDateTime = System.now().addDays(1).addHours(1),
            OwnerId = u.Id,
            TeamsEventId__c = 'evt123'
        );
        insert ev;

        Test.setMock(HttpCalloutMock.class, new TeamsUpdateMockHttpResponse());

        Test.startTest();
        new TeamsUpdateEventQueueable(ev.Id, 'fake_token').execute(null);
        Test.stopTest();

        Event evAfter = [SELECT Id, ProcessedByTeams__c FROM Event WHERE Id = :ev.Id];
        System.assert(evAfter.ProcessedByTeams__c, 'O evento deveria estar marcado como processado após update');
    }
}