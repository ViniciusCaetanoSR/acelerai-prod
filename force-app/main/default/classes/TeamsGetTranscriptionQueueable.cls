public without sharing class TeamsGetTranscriptionQueueable implements Queueable, Database.AllowsCallouts {
    private Event event;
    private String accessToken;
    private User owner_user;

    public TeamsGetTranscriptionQueueable(Event event, String accessToken, User owner_user) {
        this.event = event;
        this.accessToken = accessToken;
        this.owner_user = owner_user;
    }

    public void execute(QueueableContext context) {
        try {
            if (accessToken != null && owner_user != null) {
                // ---** Transcript **---
                TeamsIntegrationService.getTeamsTranscriptId(event, owner_user, accessToken);
            } else {
                System.debug('[TeamsGetTranscriptionQueueable] Dados insuficientes para processar evento, event.Subject > ' + event.Subject + ' | owner_user: ' + owner_user + ' | accessToken: ' + accessToken);
            }
        } catch (Exception e) {
            System.debug('[EXCEPTION] TeamsGetTranscriptionQueueable : ' + e.getMessage());
            LoggerUtility.createLogException(e, 'Event: ' + String.valueOf(event.Id), 'TeamsGetTranscriptionQueueable');
        }
    }
}