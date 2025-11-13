/* Antiga TeamsEventUpdateQueueable */
public without sharing class TeamsUpdateEventQueueable implements Queueable, Database.AllowsCallouts {
    private Id eventId;
    private String accessToken;

    public TeamsUpdateEventQueueable(Id evId, String token) {
        this.eventId = evId;
        this.accessToken = token;       
    }

    public void execute(QueueableContext qc) {
        System.debug('~~ START > TeamsUpdateEventQueueable');
        try {
            Event event = [SELECT Id, Subject, StartDateTime, EndDateTime, OwnerId, TeamsEventId__c FROM Event WHERE Id = :eventId LIMIT 1];           

            TeamsIntegrationService.updateTeamsEvent(event, accessToken);
            System.debug('~~ END > TeamsUpdateEventQueueable: chamou o updateTeamsEvent');                
            
        } catch (Exception e){
            System.debug('~~ END [EXCEPTION] > TeamsUpdateEventQueueable: ' + e.getMessage());
        }
    }
}