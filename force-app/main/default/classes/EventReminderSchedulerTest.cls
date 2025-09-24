@isTest
private class EventReminderSchedulerTest {

    @isTest
    static void testExecute_WithResponse() {
        Event testEvent = new Event(
            Subject = 'Test Event',
            StartDateTime = Datetime.now().addHours(1),
            EndDateTime = Datetime.now().addHours(2),
            ScheduledJobId__c = 'TEST_JOB_ID'
        );
        insert testEvent;
    
        EventReminderScheduler scheduler = new EventReminderScheduler(testEvent);
    
        Test.startTest();
        scheduler.execute(null);
        String response = scheduler.getResponse(); 
        Test.stopTest();
    
        System.assertEquals('Lembrete enviado com sucesso', response, 'Erro na resposta do scheduler');
    }

    @isTest
    static void testExecute_EventNotFound() {
        Event testEvent = new Event(
            Subject = 'Test Event',
            StartDateTime = Datetime.now().addHours(1),
            EndDateTime = Datetime.now().addHours(2),
            ScheduledJobId__c = 'TEST_JOB_ID'
        );

        EventReminderScheduler scheduler = new EventReminderScheduler(testEvent);

        Test.startTest();
        scheduler.execute(null);
        String response = scheduler.getResponse(); 
        Test.stopTest();

        System.assertEquals('Erro no execute()', response, 'Erro na resposta do scheduler');
    }
}