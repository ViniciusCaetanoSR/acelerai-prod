public without sharing class TeamsIntegrationGetUserIdQueueable implements Queueable, Database.AllowsCallouts {
    private Event event;
    private String accessToken;

    public TeamsIntegrationGetUserIdQueueable(Event event, String accessToken) {
        this.event = event;
        this.accessToken = accessToken;
    }
    
    public void execute(QueueableContext qc) {
        System.debug('~~ START > Teams GetTeamsUserId Queueable');
        try {
            TeamsIntegrationService.getTeamsUserId(event, accessToken);
            System.debug('~~ END > Teams GetTeamsUserId Queueable: chamou o updateTeamsEvent');              
        } catch (Exception e){
            System.debug('~~ END [EXCEPTION] > Teams GetTeamsUserId Queueable: ' + e.getMessage());
        }
    }
}