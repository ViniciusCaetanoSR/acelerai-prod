/**
 * ANTIGA TeamsAttendanceRecordQueueable
 */
public class TeamsIntegGetOnlineMeetingIdQueueable implements Queueable, Database.AllowsCallouts {
    private Event event;
    private String accessToken;
    private String teamsUserId;

    public TeamsIntegGetOnlineMeetingIdQueueable(Event event, String accessToken, String teamsUserId) {
        this.event = event;
        this.accessToken = accessToken;
        this.teamsUserId = teamsUserId;
    }

    public void execute(QueueableContext context) {
        try {
            TeamsIntegrationService.getOnlineMeetingIdByJoinUrl(event, accessToken, teamsUserId);
            System.debug('[TeamsIntegration GetOnlineMeetingId (Queueable)] chamou o getOnlineMeetingIdByJoinUrl');
        } catch (Exception e) {
            System.debug('Erro ao buscar attendanceRecordId: ' + e.getMessage());
        }
    }
}