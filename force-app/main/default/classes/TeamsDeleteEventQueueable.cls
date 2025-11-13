public class TeamsDeleteEventQueueable implements Queueable, Database.AllowsCallouts {
    private String teamsEventId;
    private String accessToken;

    public TeamsDeleteEventQueueable(String teamsEventId, String accessToken) {
        this.teamsEventId = teamsEventId;
        this.accessToken = accessToken;
    }

    public void execute(QueueableContext qc) {
        System.debug('~~ START > TeamsDeleteEventQueueable. teamsEventId: ' + teamsEventId + ' . accessToken: ' + accessToken);
        try{            
            TeamsIntegrationService.deleteTeamsEvent(teamsEventId, accessToken);
            System.debug('~~ [END] TeamsDeleteEventQueueable: chamou a deleteTeamsEvent(callout)');
        } catch (Exception e){
            System.debug('~~ END [EXCEPTION] > TeamsDeleteEventQueueable: '+ e.getMessage());
        }
    }
}