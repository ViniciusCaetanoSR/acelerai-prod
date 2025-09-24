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
}