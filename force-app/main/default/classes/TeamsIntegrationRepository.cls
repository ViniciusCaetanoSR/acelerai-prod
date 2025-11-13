public with sharing class TeamsIntegrationRepository {

    public static Event updateEventsFieldWithTeamsData(Event event, String descricao, String joinUrl, String meetingId, String eventId) {
        try {
            event.Description = descricao;
            event.TeamsJoinURL__c = joinUrl;
            event.TeamsMeetingId__c = meetingId;
            event.TeamsEventId__c = eventId;
            update event;

            System.debug('~~ TeamsIntegrationRepository: Event atualizado com Description: ' + event.Description);
            System.debug('~~ TeamsIntegrationRepository: Event atualizado com TeamsMeetingId__c: ' + event.TeamsMeetingId__c);
            System.debug('~~ TeamsIntegrationRepository: Event atualizado com TeamsEventId__c: ' + event.TeamsEventId__c);
            System.debug('~~ TeamsIntegrationRepository: Event atualizado com TeamsJoinURL__c: ' + event.TeamsJoinURL__c);
            return event;
        } catch (Exception e){
            System.debug('Erro na TeamsIntegrationRepository. Método: updateEventsFieldWithTeamsData. Erro: ' + e.getMessage());
            return null;
        }
    }

    public static String updateUserIdWithTeamsData(Event event, String userId){
        try {
            User user = [SELECT Id, TeamsUserId__c FROM User WHERE Id = :event.OwnerId LIMIT 1];

            user.TeamsUserId__c = userId;
            update user;

            System.debug('Sucesso na TeamsIntegrationRepository. Método: updateUserIdWithTeamsData. UserId: ' +  user.TeamsUserId__c);
            return user.TeamsUserId__c;
        } catch (Exception e){
            System.debug('Erro na TeamsIntegrationRepository. Método: updateUserIdWithTeamsData. Erro: ' + e.getMessage());
            return null;
        }
    }

    public static void updateProcessedByTeamsField(Event event){
        try{
            event.ProcessedByTeams__c = true;
            update event;
            System.debug('~~ [200] Event marcado como processado após update no Teams.');
        } catch (Exception e){
            System.debug('Erro na TeamsIntegrationRepository. Método: updateUserIdWithTeamsData. Erro: ' + e.getMessage());
        }
    }

    public static void updateTeamsAttendanceRecordId(Event event, String attendanceRecordId) {
        try {
            event.TeamsAttendanceRecordId__c = attendanceRecordId;
            update event;
            System.debug('Sucesso na TeamsIntegrationRepository. Método: updateTeamsAttendanceRecordId. Event.TeamsAttendanceRecordId__c: ' +  event.TeamsAttendanceRecordId__c);
        } catch (Exception e) {
            System.debug('Erro na TeamsIntegrationRepository. Método: updateTeamsAttendanceRecordId. Erro: ' + e.getMessage());
        }
    }

    public static void updateTeamsOnlineMeetingId(Event event, String onlineMeetingId) {
        try {
            event.TeamsOnlineMeetingId__c = onlineMeetingId;
            update event;
            System.debug('Sucesso na TeamsIntegrationRepository. Método: updateTeamsOnlineMeetingId. Event.TeamsOnlineMeetingId: ' +  event.TeamsOnlineMeetingId__c);
        } catch (Exception e) {
            System.debug('Erro na TeamsIntegrationRepository. Método: updateTeamsOnlineMeetingId. Erro: ' + e.getMessage());
        }
    }

    //antigo updateTeamsGuestAttended
    public static void updateTeamsPresenters(Event event, Boolean guestAtended, List<String> presentersEmails) {
        try {
            event.TeamsShowStatus__c = guestAtended;
            event.TeamsPresentersEmails__c = String.join(presentersEmails, '; ');
            update event;
            System.debug('Sucesso na TeamsIntegrationRepository. Método: updateTeamsPresenters. Event.TeamsShowStatus__c: ' +  event.TeamsShowStatus__c);
        } catch (Exception e) {
            System.debug('Erro na TeamsIntegrationRepository. Método: updateTeamsPresenters. Erro: ' + e.getMessage());
        }
    }

    public static TeamsTranscriptionHistory__c updateTeamsTranscriptId(Event event, String transcriptionCount, String transcriptId) {
        System.debug('updateTeamsTranscriptId. TeamsTranscriptCount__c: ' + transcriptionCount + '. transcriptId: ' + transcriptId);

        try {
            Event eventWithTranscriptId = [
                SELECT Id, Subject, TeamsTranscriptionHistoryRelated__c, WhatId
                FROM Event
                WHERE Id = :event.Id
                LIMIT 1
            ];

            TeamsTranscriptionHistory__c transcriptionHistory = null;

            if (transcriptionHistory == null) {
                transcriptionHistory = new TeamsTranscriptionHistory__c();
                transcriptionHistory.Name = 'Transcrição do evento ' + eventWithTranscriptId.Subject;
                transcriptionHistory.RelatedOpp__c = eventWithTranscriptId.WhatId;
                transcriptionHistory.RelatedEvent__c = 'https://aceleraibr.lightning.force.com/lightning/r/Event/' + eventWithTranscriptId.Id + '/view';

                insert transcriptionHistory;
                System.debug('TranscriptionHistory criado com ID: ' + transcriptionHistory.Id);

                if (transcriptionHistory.Id == null) {
                    System.debug('Falha ao criar TranscriptionHistory. Registro sem ID.');
                    return null;
                }

                eventWithTranscriptId.TeamsTranscriptionHistoryRelated__c = transcriptionHistory.Id;
                update eventWithTranscriptId;
            }

            transcriptionHistory.Name = 'Transcrição do evento ' + eventWithTranscriptId.Subject;
            transcriptionHistory.TeamsTranscriptCount__c = transcriptionCount;
            transcriptionHistory.TeamsTranscriptId__c = transcriptId;

            update transcriptionHistory;
            System.debug('Sucesso no updateTeamsTranscriptId. TeamsTranscriptCount__c: ' + transcriptionHistory.TeamsTranscriptCount__c + '. Transcription Name: ' + transcriptionHistory.Name);

            return transcriptionHistory;
        } catch (Exception e) {
            System.debug('Erro na TeamsIntegrationRepository. Método: updateTeamsTranscriptId. Erro: ' + e.getMessage());
            return null;
        }
    }

    public static void saveTranscriptContent(TeamsTranscriptionHistory__c transcriptionHistory, String transcriptContent) {
        System.debug('~~ [saveTranscriptContent] Salvando conteúdo da transcrição para: ' + transcriptionHistory.Id);

        try {
            transcriptionHistory.TeamsTranscriptContent__c = transcriptContent;
            update transcriptionHistory;

            System.debug('Conteúdo da transcrição salvo com sucesso em TeamsTranscriptContent__c: ' +  transcriptionHistory.TeamsTranscriptContent__c);
        } catch (Exception e) {
            System.debug('Erro ao salvar conteúdo da transcrição: ' + e.getMessage());
        }
    }
}