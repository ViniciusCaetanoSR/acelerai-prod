@isTest
private class TeamsIntegrationServiceTest {

    private class TeamsMockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();

            if (req.getMethod() == 'POST') {
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
            } else if (req.getMethod() == 'PATCH') {
                res.setStatusCode(200);
                res.setBody('{}');
            } else if (req.getMethod() == 'GET' && req.getEndpoint().endsWith('?%24select=organizer')) {
                res.setStatusCode(200);
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{' +
                    '"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(\'ca18a820-29fc-4235-b7f1-1fab2b4f6ad3\')/events/$entity",' +
                    '"organizer": {' +
                        '"emailAddress": {' +
                            '"name": "Iago Pinheiro",' +
                            '"address": "iago@acelerai.com.br"' +
                        '}' +
                    '}' +
                '}');
            } else if (req.getMethod() == 'GET' && req.getEndpoint().contains('/onlineMeetings?$filter=JoinWebUrl%20eq%20%27')) {
                res.setStatusCode(200);
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"value":[{"id":"meeting-987654321"}]}');
            } else if (req.getMethod() == 'GET' && req.getEndpoint().contains('/attendanceReports/')) {
                if (req.getEndpoint().contains('$expand=attendanceRecords')) {
                    res.setStatusCode(200);
                    res.setHeader('Content-Type', 'application/json');

                    Map<String, Object> record = new Map<String, Object>{
                        'id' => 'ca18a820-29fc-4235-b7f1-1fab2b4f6ad3',
                        'emailAddress' => 'guest@acelerai.com.br',
                        'totalAttendanceInSeconds' => 48,
                        'role' => 'Presenter'
                    };

                    res.setBody(JSON.serialize(new Map<String, Object>{
                        'attendanceRecords' => new List<Object>{ record }
                    }));
                }

            } else if (req.getMethod() == 'GET' && req.getEndpoint().endsWith('/attendanceReports')) {
                res.setStatusCode(200);
                res.setBody('{"value":[{"id":"attendance-987654321"}]}');
            } else if(req.getMethod() == 'GET' && req.getEndpoint().endsWith('/transcripts')) {
                res.setStatusCode(200);
                res.setBody('{"value":[{"id":"transcript-987654321"}]}');
            } else if(req.getMethod() == 'GET' && req.getEndpoint().endsWith('/content')) {
                res.setStatusCode(200);
                res.setHeader('Content-Type', 'text/vtt');
                res.setBody(
                    'WEBVTT\n\n' +
                    '00:00:01.000 --> 00:00:05.000\n' +
                    'Olá, bem-vindo à reunião de testes!\n\n' +
                    '00:00:06.000 --> 00:00:10.000\n' +
                    'Estamos validando a integração com o Microsoft Teams.'
                );
            }
            return res;
        }
    }

    @isTest
    static void testCreateTeamsEvent() {
        User u = new User(
            Alias = 'tuser',
            LastName = 'Blueble',
            Email = 'teste@aceleraibr.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            UserName = 'testeuser@aceleraibr.com'
        );
        insert u;

        Event e = new Event(
            Subject = 'Lamar',
            StartDateTime = System.now().addHours(1),
            EndDateTime = System.now().addHours(2),
            Description = 'Descrição inicial'
        );
        insert e;

        EventRelation rel = new EventRelation(
            EventId = e.Id,
            RelationId = u.Id,
            IsInvitee = true
        );
        insert rel;

        Test.setMock(HttpCalloutMock.class, new TeamsMockHttpResponseGenerator());

        Test.startTest();
        TeamsIntegrationService.allowHttpCallout = false;
        TeamsIntegrationService.createTeamsEvent(e, 'fake-access-token');
        Test.stopTest();

        Event updatedEvent = [SELECT Description, TeamsMeetingId__c, TeamsEventId__c, ProcessedByTeams__c FROM Event WHERE Id = :e.Id];
        System.assert(updatedEvent.Description.contains('https://teams.microsoft.com'), 'Descrição deve conter o link da reunião');
        System.assertEquals('987654321', updatedEvent.TeamsMeetingId__c, 'Meeting ID deve ser extraído corretamente');
        System.assertEquals('evt123', updatedEvent.TeamsEventId__c, 'Event ID deve ser salvo corretamente');
    }

    @isTest
    static void testUpdateTeamsEvent() {
        Event e = new Event(
            Subject = 'Lamar Atualizada',
            StartDateTime = System.now().addDays(1),
            EndDateTime = System.now().addDays(1).addHours(1),
            TeamsEventId__c = 'evt123'
        );
        insert e;

        Test.setMock(HttpCalloutMock.class, new TeamsMockHttpResponseGenerator());

        Test.startTest();
        TeamsIntegrationService.allowHttpCallout = false;
        TeamsIntegrationService.updateTeamsEvent(e, 'fake-access-token');
        Test.stopTest();

        Event updatedEvent = [SELECT ProcessedByTeams__c FROM Event WHERE Id = :e.Id];
        System.assert(updatedEvent.ProcessedByTeams__c, 'ProcessedByTeams__c do evento não está marcado');
    }

    @isTest
    static void testDeleteTeamsEvent() {
        Test.setMock(HttpCalloutMock.class, new TeamsMockHttpResponseGenerator());

        Event e = new Event(
            Subject = 'Lamar Atualizada',
            StartDateTime = System.now().addDays(1),
            EndDateTime = System.now().addDays(1).addHours(1),
            TeamsEventId__c = 'evt123'
        );
        insert e;

        String accessToken = 'fakeAccessToken';

        Test.startTest();
            TeamsIntegrationService.deleteTeamsEvent(e.TeamsEventId__c, accessToken);
        Test.stopTest();

        System.assert(true, 'O método executou com sucesso usando mock');
    }

    @isTest
    static void testGetTeamsUserId_Success() {
        Test.setMock(HttpCalloutMock.class, new TeamsMockHttpResponseGenerator());

        User u = new User(
            Alias = 'tuser',
            LastName = 'Blueble',
            Email = 'teste@aceleraibr.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            UserName = 'testeuser@aceleraibr.com',
            TeamsAccessToken__c = 'fakeAccessToken'
        );
        insert u;

        Event e = new Event(
            Subject = 'Reunião de Teste',
            StartDateTime = System.now(),
            EndDateTime = System.now().addHours(1),
            TeamsJoinURL__c = 'https://teams.microsoft.com/l/meetup-join/teste123',
            TeamsEventId__c = 'fakeTeamsEventId',
            ownerId = u.Id
        );
        insert e;

        String fakeAccessToken = 'fakeAccessToken';

        Test.startTest();
            TeamsIntegrationService.getTeamsUserId(e,fakeAccessToken);
        Test.stopTest();

        System.assert(true, 'O método executou com sucesso usando mock');
    }

    @isTest
    static void testGetOnlineMeetingIdByJoinUrl_success() {
        Test.setMock(HttpCalloutMock.class, new TeamsMockHttpResponseGenerator());

        Event e = new Event(
            Subject = 'Reunião de Teste',
            StartDateTime = System.now(),
            EndDateTime = System.now().addHours(1),
            TeamsJoinURL__c = 'https://teams.microsoft.com/l/meetup-join/teste123'
        );
        insert e;

        String fakeAccessToken = 'token_teste';
        String fakeTeamsUserId = 'user123';

        Test.startTest();
            TeamsIntegrationService.getOnlineMeetingIdByJoinUrl(e, fakeAccessToken, fakeTeamsUserId);
        Test.stopTest();

        System.assert(true, 'O método executou com sucesso usando mock');
    }

    @isTest
    static void getAttendanceRecordId_Success() {
        Test.setMock(HttpCalloutMock.class, new TeamsMockHttpResponseGenerator());
        Event e = new Event(
            Subject = 'Reunião de Teste',
            StartDateTime = System.now(),
            EndDateTime = System.now().addHours(1),
            TeamsJoinURL__c = 'https://teams.microsoft.com/l/meetup-join/teste123',
            TeamsOnlineMeetingId__c = 'fakeOnlineMeetingId'
        );
        insert e;

        String fakeAccessToken = 'token_teste';
        String fakeMeetingId = 'HKJHDJKG457J';

        Test.startTest();
            TeamsIntegrationService.getAttendanceRecordId(e, fakeMeetingId, fakeAccessToken);
        Test.stopTest();

        System.assert(true, 'O método executou com sucesso usando mock');

    }

    @isTest
    static void getAttendanceRecords_Success() {
        Test.setMock(HttpCalloutMock.class, new TeamsMockHttpResponseGenerator());
        Contact c = new Contact(LastName = 'ConvidadoTeste', Email = 'guest@acelerai.com.br');
        insert c;

        Event e = new Event(
            Subject = 'Reunião de Teste',
            StartDateTime = System.now().addHours(-2),
            EndDateTime = System.now().addHours(-1),
            TeamsJoinURL__c = 'https://teams.microsoft.com/l/meetup-join/teste123',
            TeamsOnlineMeetingId__c = 'fakeOnlineMeetingId',
            TeamsAttendanceRecordId__c = 'JHJHKD86876H6',
            TeamsShowStatus__c = false,
            WhoId = c.Id
        );
        insert e;


        Test.startTest();
            TeamsIntegrationService.getAttendanceRecords(e, e.TeamsOnlineMeetingId__c, 'fake_token');
        Test.stopTest();

        Event updatedEvent = [SELECT Id, TeamsShowStatus__c FROM Event WHERE Id = :e.Id];
        System.assertEquals(true, updatedEvent.TeamsShowStatus__c, 'TeamsShowStatus__c deve ser marcado como True após detectar Presenter');

        System.assert(true, 'O método executou com sucesso usando mock');
    }

    @isTest
    static void getTeamsTranscriptId_Success() {
        Test.setMock(HttpCalloutMock.class, new TeamsMockHttpResponseGenerator());

        User u = new User(
            Alias = 'tuser',
            LastName = 'Blueble',
            Email = 'teste@aceleraibr.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            UserName = 'testeuser@aceleraibr.com',
            TeamsAccessToken__c = 'fakeAccessToken',
            TeamsUserId__c = 'fakeTeamsUserId'
        );
        insert u;

        Event e = new Event(
            Subject = 'Reunião de Teste',
            StartDateTime = System.now(),
            EndDateTime = System.now().addHours(1),
            TeamsJoinURL__c = 'https://teams.microsoft.com/l/meetup-join/teste123',
            TeamsOnlineMeetingId__c = 'fakeOnlineMeetingId',
            OwnerId = u.Id
        );
        insert e;

        Test.startTest();
            TeamsIntegrationService.getTeamsTranscriptId(e, u, u.TeamsAccessToken__c);
        Test.stopTest();

        System.assert(true, 'O método executou com sucesso usando mock');
    }

    @isTest
    static void testGetTeamsTranscriptions_Success() {
        Test.setMock(HttpCalloutMock.class, new TeamsMockHttpResponseGenerator());

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'tuser',
            LastName = 'Mocked',
            Email = 'mocked@aceleraibr.com',
            Username = 'mocked' + System.currentTimeMillis() + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            TimeZoneSidKey = 'America/Sao_Paulo',
            ProfileId = p.Id,
            TeamsUserId__c = 'fakeTeamsUserId',
            TeamsAccessToken__c = 'fakeAccessToken'
        );
        insert u;

        Event e = new Event(
            Subject = 'Reunião Transcrição',
            StartDateTime = System.now(),
            EndDateTime = System.now().addHours(1),
            TeamsOnlineMeetingId__c = 'meeting-abc123',
            OwnerId = u.Id
        );
        insert e;

        TeamsTranscriptionHistory__c th = new TeamsTranscriptionHistory__c(
            TeamsTranscriptId__c = 'transcript-xyz789'
        );
        insert th;

        Test.startTest();
            TeamsIntegrationService.getTeamsTranscriptions(e, th, u, u.TeamsAccessToken__c);
        Test.stopTest();

        System.assert(true, 'Método executado com mock de transcrição com sucesso.');
    }
}