public without sharing class TeamsCreateCalendarQueueable implements Queueable, Database.AllowsCallouts {
    private Event event;
    private User owner;
    private String accessToken;
    private String calendarId;

    public TeamsCreateCalendarQueueable(Event event, String token, User owner, String calendarId) {
        this.event = event;
        this.owner = owner;
        this.accessToken = token;
        this.calendarId = calendarId;
    }

    public void execute(QueueableContext qc) {
        System.debug('~~ START > TeamsCreateCalendarQueueable');
        try {
            TeamsIntegrationService.createTeamsEventInCalendar(event, accessToken, owner, calendarId);
            System.debug('~~ END > TeamsCreateCalendarQueueable : chamou o createTeamsEventInCalendar');
        } catch (Exception e){
            System.debug('~~ END [EXCEPTION] > TeamsCreateCalendarQueueable: '+ e.getMessage());
        }     
    }
}