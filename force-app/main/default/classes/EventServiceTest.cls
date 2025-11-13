@isTest
public class EventServiceTest {

    @isTest
    static void testCallScheduleReminderForTodayEvents() {
        Date tomorrow = Date.today().addDays(1);
        Time hour6AM = Time.newInstance(6, 0, 0, 0);
        Time hour6PM = Time.newInstance(18, 0, 0, 0);

        Event evt = new Event(
            Subject = 'Test Event *_*',
            StartDateTime = DateTime.newInstance(tomorrow, hour6PM),
            EndDateTime = DateTime.newInstance(tomorrow, hour6PM).addHours(1),
            ActivityDate = tomorrow
        );
        insert evt;

        EventService.today = tomorrow;

        Test.startTest();
        String result = EventService.callScheduleReminderForTodayEvents();
        Test.stopTest();

        Event updatedEvent = [SELECT Id, ScheduledJobId__c, StartDateTime FROM Event WHERE Id = :evt.Id];
        System.assertEquals('Job agendado', result, 'Deveria ter agendado um job para o evento');

        Datetime expectedReminderTime = updatedEvent.StartDateTime.addMinutes(-30);
        System.assert(expectedReminderTime > DateTime.newInstance(tomorrow, hour6AM), 'O reminder deveria estar agendado para depois das 6h');
    }

    @isTest
    static void testScheduleReminderForEvent() {
        Datetime now = Datetime.now();
        Event evt = new Event(
            Subject = 'Test Event',
            StartDateTime = now.addHours(1),
            EndDateTime = now.addHours(2),
            ActivityDate = Date.today()
        );
        insert evt;

        Test.startTest();
        EventService.scheduleReminderForEvent(evt, now.addMinutes(30));
        Test.stopTest();

        List<CronTrigger> scheduledJobs = [SELECT Id FROM CronTrigger WHERE State = 'WAITING'];
        System.assert(!scheduledJobs.isEmpty(), 'Nenhum job foi agendado');
    }

    @isTest
    static void testSendReminder() {
        User testUser = new User(
            Alias = 'tst',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser1703@example.com'
        );
        insert testUser;

        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Email = 'testcontact@example.com'
        );
        insert testContact;

        Event evt = new Event(
            Subject = 'Test Event',
            StartDateTime = Datetime.now().addHours(1),
            EndDateTime = Datetime.now().addHours(2),
            OwnerId = testUser.Id
        );
        insert evt;

        EventRelation eventRelation = new EventRelation(
            EventId = evt.Id,
            RelationId = testContact.Id
        );
        insert eventRelation;

        Test.startTest();
        String response = EventService.sendReminder(evt);
        System.debug(' response: ' + response);
        Test.stopTest();

        System.assertEquals('Lembrete enviado com sucesso', response);
    }

    @isTest
    static void testSendReminderNoEmails() {
        Event evt = new Event(
            Subject = 'Test Event',
            StartDateTime = Datetime.now().addHours(1),
            EndDateTime = Datetime.now().addHours(2)
        );
        insert evt;

        Test.startTest();
        EventService.sendReminder(evt);
        Test.stopTest();

        List<EmailMessage> sentEmails = [SELECT Id FROM EmailMessage WHERE Subject = 'Lembrete de Evento: Test Event'];
        System.assert(sentEmails.isEmpty(), 'E-mails foram enviados, mas não deveriam');
    }

    @isTest
    static void testCallScheduleReminderForTodayEvents_HandleInsert() {
        Datetime now = Datetime.now();
        List<Event> eventsToSchedule = new List<Event>();

        Event evt = new Event(
            Subject = 'Test Event',
            StartDateTime = now.addHours(1),
            EndDateTime = now.addHours(2),
            ActivityDate = Date.today()
        );
        eventsToSchedule.add(evt);
        insert eventsToSchedule;

        Test.startTest();
        EventService.callScheduleReminderForTodayEvents_handleInsert(eventsToSchedule);
        Test.stopTest();

        List<CronTrigger> scheduledJobs = [SELECT Id FROM CronTrigger WHERE State = 'WAITING'];
        System.assert(!scheduledJobs.isEmpty(), 'Nenhum job foi agendado');
    }

    @isTest
    static void testCallScheduleReminderForTodayEvents_HandleUpdate() {
        Datetime now = Datetime.now();
        Event evt = new Event(
            Subject = 'Test Event',
            StartDateTime = now.addHours(1),
            EndDateTime = now.addHours(2),
            ActivityDate = Date.today()
        );
        insert evt;

        Map<Id, Event> oldEventsMap = new Map<Id, Event>{
            evt.Id => new Event(
                Id = evt.Id,
                Subject = evt.Subject,
                StartDateTime = evt.StartDateTime,
                EndDateTime = evt.EndDateTime,
                ActivityDate = evt.ActivityDate
            )
        };

        evt.StartDateTime = now.addHours(3);
        evt.EndDateTime = now.addHours(4);
        update evt;

        List<Event> updatedEvents = new List<Event>{ evt };

        Test.startTest();
        EventService.callScheduleReminderForTodayEvents_handleUpdate(updatedEvents, oldEventsMap);
        Test.stopTest();

        List<CronTrigger> scheduledJobs = [SELECT Id FROM CronTrigger WHERE State = 'WAITING'];
        System.assert(!scheduledJobs.isEmpty(), 'Nenhum job foi agendado após a atualização do evento');
    }

    @isTest
    static void testHandleCreateTeamsEvent_Success() {
        Datetime now = Datetime.now();
        Event evt = new Event(
            Subject = 'Test Event',
            StartDateTime = now.addHours(1),
            EndDateTime = now.addHours(2),
            ActivityDate = Date.today()
        );
        insert evt;

        List<Event> eventss = new List<Event>{ evt };

        Test.startTest();
        Boolean result = EventService.handleCreateTeamsEvent(eventss);
        Test.stopTest();

        System.assert(result, 'handleCreateTeamsEvent NÃO enfileirou o job para criar o evento');
    }

    @isTest
    static void testHandleUpdateTeamsEvent_Success() {
        Datetime now = Datetime.now();
        Event evt = new Event(
            Subject = 'Test Event',
            StartDateTime = now.addHours(1),
            EndDateTime = now.addHours(2),
            ActivityDate = Date.today()
        );
        insert evt;

        Map<Id, Event> oldEventsMap = new Map<Id, Event>{
            evt.Id => new Event(
                Id = evt.Id,
                Subject = evt.Subject,
                StartDateTime = evt.StartDateTime,
                EndDateTime = evt.EndDateTime,
                ActivityDate = evt.ActivityDate
            )
        };

        evt.StartDateTime = now.addHours(3);
        evt.EndDateTime = now.addHours(4);
        update evt;

        List<Event> updatedEvents = new List<Event>{ evt };

        Test.startTest();
        Boolean result = EventService.handleUpdateTeamsEvent(updatedEvents, oldEventsMap);
        Test.stopTest();

        System.assert(result, 'HandleUpdateTeamsEvent NÃO enfileirou o job para atualização do evento');
    }

    @isTest
    static void handleFinishedEvent_TeamsIntegration_Success() {
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
            TeamsUserId__c = 'fakeTeamsUserId',
            HasTeamsConsent__c = true
        );
        insert u;

        Event event = new Event(
            Subject = 'Reunião BLABLABLA',
            StartDateTime = System.now().addMinutes(-90),
            EndDateTime = System.now().addMinutes(-30),
            TeamsOnlineMeetingId__c = 'JHDJNSYDELSHDYIkd',
            OwnerId = u.Id
        );
        insert event;

        Test.startTest();
            Boolean result = EventService.handleFinishedEvent_TeamsIntegration();
        Test.stopTest();

        System.assertEquals(true, result, 'Deveria retornar true pois jobs foram enfileirados');
    }

    @IsTest
    static void test_handleDeleteTeamsEvents_success() {
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
            TeamsUserId__c = 'fakeTeamsUserId',
            HasTeamsConsent__c = true
        );
        insert u;

        Event ev = new Event(
            Subject = 'Reunião de Teste',
            StartDateTime = System.now().addHours(-2),
            EndDateTime = System.now().addHours(-1),
            TeamsJoinURL__c = 'https://teams.microsoft.com/l/meetup-join/teste123',
            TeamsOnlineMeetingId__c = 'JHDJNSYDELSHDYIkd',
            TeamsAttendanceRecordId__c = null,
            TeamsShowStatus__c = false,
            OwnerId = u.Id,
            TeamsEventId__c = 'mockedTeamsEventId'
        );        
        insert ev;

        Test.startTest();
            Boolean result = EventService.handleDeleteTeamsEvents(new List<Event>{ev});
        Test.stopTest();

        System.assertEquals(true, result, 'Deveria retornar true pois houve callout');
    }
}