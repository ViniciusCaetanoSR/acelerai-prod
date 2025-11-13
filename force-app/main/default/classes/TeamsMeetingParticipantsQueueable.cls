public with sharing class TeamsMeetingParticipantsQueueable implements Queueable, Database.AllowsCallouts {
    private Id eventId;
    private String accessToken;
    private String onlineMeetingId;
    private String attendanceRecordId;

    public TeamsMeetingParticipantsQueueable(Id eventId, String accessToken , String onlineMeetingId, String attendanceRecordId) {
        this.eventId = eventId;
        this.accessToken = accessToken;
        this.onlineMeetingId = onlineMeetingId;
        this.attendanceRecordId = attendanceRecordId;
    }

    public void execute(QueueableContext context) {
        try {
            Event ev = [SELECT Id, TeamsAttendanceRecordId__c, TeamsOnlineMeetingId__c FROM Event WHERE Id = :eventId LIMIT 1];

            TeamsIntegrationService.getAttendanceRecords(ev, ev.TeamsOnlineMeetingId__c, accessToken);

        } catch (Exception e) {
            System.debug('Erro ao buscar participantes: ' + e.getMessage());
        }
    }
}