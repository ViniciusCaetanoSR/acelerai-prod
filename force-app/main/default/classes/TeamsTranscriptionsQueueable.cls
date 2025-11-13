public with sharing class TeamsTranscriptionsQueueable implements Queueable, Database.AllowsCallouts{
    private Event event;
    private TeamsTranscriptionHistory__c transcriptionHistory;
    private User user;
    private String accessToken;

    public TeamsTranscriptionsQueueable(Event event, TeamsTranscriptionHistory__c transcriptionHistory, User user, String accessToken) {
        this.event = event;
        this.transcriptionHistory = transcriptionHistory;
        this.user = user;
        this.accessToken = accessToken;
    }

    public void execute(QueueableContext qc) {
        System.debug('~~ START > Teams Transcriptions Queueable');
        try {
            TeamsIntegrationService.getTeamsTranscriptions(event, transcriptionHistory, user, accessToken);
            System.debug('~~ END > Teams Transcriptions Queueable: chamou getTeamsTranscriptions');
        } catch (Exception e) {
            System.debug('~~ END [EXCEPTION] > Teams Transcriptions Queueable: ' + e.getMessage());
        }
    }
}