/**
 * Antiga TeamsEventCalloutQueueable
 */
public class TeamsCreateEventQueueable implements Queueable, Database.AllowsCallouts {
    private Id eventId;
    private String accessToken;

    public TeamsCreateEventQueueable(Id evId, String token) {
        this.eventId = evId;
        this.accessToken = token;
    }

    public void execute(QueueableContext qc) {
        System.debug('~~ START > TeamsCreateEventQueueable');
        try{
            Event event = [
                SELECT Id, Subject, OwnerId, StartDateTime, EndDateTime, TeamsEventId__c, TeamsJoinURL__c, TeamsOnlineMeetingId__c, TeamsMeetingId__c FROM Event
                WHERE Id = :eventId LIMIT 1
            ];

            User owner = [SELECT Id, TeamsCalendarId__c, TeamsAccessToken__c FROM User WHERE Id = :event.OwnerId LIMIT 1];
            String calendarId = TeamsCalendarHelper.getOrCreateSalesforceCalendar(owner, accessToken);

            if(calendarId != null){
                System.enqueueJob(new TeamsCreateCalendarQueueable(event, accessToken, owner, calendarId));
            }

        } catch (Exception e){
            System.debug('~~ END [EXCEPTION] > TeamsCreateEventQueueable: '+ e.getMessage());
        }
    }
}