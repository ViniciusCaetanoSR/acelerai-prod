@IsTest
private class EventDailyReminderSchedulerTest {
    
    @TestSetup
    static void setup() {
        Date amanha = Date.today().addDays(1);
        Time horaEvento = Time.newInstance(18, 0, 0, 0); 

        Event testEvent = new Event(
            Subject = 'Test Event T__T ',
            StartDateTime = DateTime.newInstance(amanha, horaEvento), 
            EndDateTime = DateTime.newInstance(amanha, horaEvento).addHours(1), 
            ActivityDate = amanha 
        );        
        insert testEvent;

        Event testEvent2 = new Event(
            Subject = 'Test Event T__T ',
            StartDateTime = DateTime.newInstance(amanha, horaEvento), 
            EndDateTime = DateTime.newInstance(amanha, horaEvento).addHours(1), 
            ActivityDate = amanha 
        );        
        insert testEvent2;

        List<Event> insertedEvents = [SELECT Id, Subject, StartDateTime, ActivityDate, ScheduledJobId__c FROM Event];
        for(Event evt : insertedEvents) {
            System.debug('insertedEvents evt.Subject: ' + evt.Subject + '| insertedEvents evt.ScheduledJobId__c: ' + evt.ScheduledJobId__c + '| insertedEvents evt.StartDateTime: ' + evt.StartDateTime + '| insertedEvents evt.ActivityDate: ' + evt.ActivityDate);

            System.assertEquals(null, evt.ScheduledJobId__c, 'Correto: Evento futuro não deve ter job agendado ainda');
        }
    }    
    
    @IsTest
    static void testSchedulerExecution() {
        Date tomorrow = Date.today().addDays(1);
        
        Test.startTest();
        //Mock no today da EventService, para retornar amanhã, e o teste funcionar como se fosse amanhã
        EventService.today = tomorrow;
        System.debug('Mock de EventService.today: ' + EventService.today);

        EventDailyReminderScheduler scheduler = new EventDailyReminderScheduler();
        scheduler.execute(null);        
        Test.stopTest();
        
        List<Event> updatedEvents = [SELECT Id, ScheduledJobId__c, StartDateTime FROM Event];
        System.assertEquals(2, updatedEvents.size(), 'Deveria ter 2 eventos');
        
        for(Event evt : updatedEvents) {            
            Datetime reminderTime = evt.StartDateTime.addMinutes(-30);
            System.debug('O reminder deveria estar 30min no futuro: reminderTime: ' + reminderTime + ' | evt.StartDateTime: ' + evt.StartDateTime);

            System.assert(reminderTime > Datetime.now(), 'O reminder deveria estar 30min depois');
        }
        
        List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob WHERE JobType = 'ScheduledApex'];
        System.debug('jobs.size(): ' + jobs.size());

        System.assertEquals(updatedEvents.size(), jobs.size(), 'Deveria ter um job agendado por evento');
    }
}