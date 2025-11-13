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
            TeamsIntegrationService.createTeamsEvent(event, accessToken);
        } catch (Exception e){
            System.debug('~~ END [EXCEPTION] > TeamsCreateEventQueueable: '+ e.getMessage());
        }
    }
}