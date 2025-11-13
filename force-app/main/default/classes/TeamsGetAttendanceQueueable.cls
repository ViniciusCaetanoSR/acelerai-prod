public without sharing class TeamsGetAttendanceQueueable implements Queueable, Database.AllowsCallouts {
    private Event event;
    private String accessToken;
    private String onlinemeetingId;

    public TeamsGetAttendanceQueueable(Event event, String accessToken, String onlinemeetingId) {
        this.event = event;
        this.accessToken = accessToken;
        this.onlinemeetingId = onlinemeetingId;
    }

    public void execute(QueueableContext context) {
        try {
            if (accessToken != null && onlinemeetingId != null) {
                // ---** Attendance **---
                TeamsIntegrationService.getAttendanceRecordId(event, onlinemeetingId, accessToken);
            } else {
                System.debug('[TeamsGetAttendanceQueueable] Dados insuficientes para processar evento, event.Subject > ' + event.Subject + ' | onlinemeetingId: ' + onlinemeetingId + ' | accessToken: ' + accessToken);
            }
        } catch (Exception e) {
            System.debug('[EXCEPTION] TeamsGetAttendanceQueueable : ' + e.getMessage());
            LoggerUtility.createLogException(e, 'Event: ' + String.valueOf(event.Id), 'TeamsGetAttendanceQueueable');
        }
    }
}