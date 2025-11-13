@isTest
private class TeamsEventQueueableTest {

    private class TeamsMockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody(JSON.serialize(new Map<String, Object>{
                'id' => 'evt123',
                'onlineMeeting' => new Map<String, Object>{
                    'joinUrl' => 'https://teams.microsoft.com/l/reuniao123'
                },
                'body' => new Map<String, Object>{
                    'content' => 'ID da Reunião: 987654321'
                }
            }));
            return res;
        }
    }

    @isTest
    static void testCreateTeamsEventJob() {
        User u = createUser(true);
        Event ev = createEvent(u.Id, null);

        Test.setMock(HttpCalloutMock.class, new TeamsMockHttpResponseGenerator());

        Test.startTest();
        new TeamsEventQueueable(ev.Id).execute(null);
        new TeamsCreateEventQueueable(ev.Id, 'fake_token').execute(null);
        Test.stopTest();

        Event evAfter = [SELECT Id, TeamsEventId__c, ProcessedByTeams__c FROM Event WHERE Id = :ev.Id];
        System.assertNotEquals(null, evAfter.TeamsEventId__c, 'TeamsEventId__c n foi preenchido');
    }

    @isTest
    static void testUpdateTeamsEventJob() {
        User u = createUser(true);
        Event ev = createEvent(u.Id, 'evt123'); // já tem TeamsEventId__c

        Test.setMock(HttpCalloutMock.class, new TeamsMockHttpResponseGenerator());

        Test.startTest();
        new TeamsEventQueueable(ev.Id).execute(null);
        new TeamsUpdateEventQueueable(ev.Id, 'fake_token').execute(null);
        Test.stopTest();

        Event evAfter = [SELECT Id, Subject, ProcessedByTeams__c FROM Event WHERE Id = :ev.Id];
        System.assertEquals('Evento Quick', evAfter.Subject, 'o subject está diferente');
        //System.assert(evAfter.ProcessedByTeams__c, 'o ProcessedByTeams__c nao foi marcado');
    }

    @isTest
    static void testNoConsent() {
        User u = createUser(false);
        Event ev = createEvent(u.Id, null);

        Test.startTest();
        new TeamsEventQueueable(ev.Id).execute(null);
        Test.stopTest();

        Event evAfter = [SELECT Id, TeamsEventId__c FROM Event WHERE Id = :ev.Id];
        System.assertEquals(null, evAfter.TeamsEventId__c, 'Não deveria ter sido preenchido sem consentimento');
    }

    private static User createUser(Boolean hasConsent) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'klamar',
            LastName = 'Lamar',
            Email = 'test' + Math.random() + '@kakakaka.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            UserName = 'test' + Math.random() + '@kakakaka.com',
            HasTeamsConsent__c = hasConsent,
            TeamsAccessToken__c = 'fake_token'
        );
        insert u;
        return u;
    }

    private static Event createEvent(Id ownerId, String teamsEventId) {
        Event ev = new Event(
            Subject = 'Evento Quick',
            StartDateTime = System.now().addDays(1),
            EndDateTime = System.now().addDays(1).addHours(1),
            OwnerId = ownerId,
            TeamsEventId__c = teamsEventId
        );
        insert ev;
        return ev;
    }
}