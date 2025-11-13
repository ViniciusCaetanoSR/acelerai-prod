public with sharing class TeamsIntegrationService {
    @testVisible
    private static Boolean allowHttpCallout = true;

    public static void createTeamsEvent(Event event, String accessToken) {
        System.debug('~~ START [CREATE TeamsEvent]> ' + event + ' | ' + accessToken);
        String teamsMeetingId;
        String teamsEventId;

        try {            
            List<EventRelation> relations = [
                SELECT RelationId, EventId, IsInvitee
                FROM EventRelation
                WHERE EventId = :event.Id
            ];
            System.debug('~~ relations collected: ' + relations);

            List<Map<String, Object>> attendees = new List<Map<String, Object>>();

            Set<Id> userIds    = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            Set<Id> leadIds    = new Set<Id>();
            Set<Id> oppIds     = new Set<Id>();

            for (EventRelation rel : relations) {
                if (rel.RelationId == null) continue;
                String prefix = String.valueOf(rel.RelationId).substring(0,3);

                if (prefix == User.SObjectType.getDescribe().getKeyPrefix()) {
                    userIds.add(rel.RelationId);
                } else if (prefix == Contact.SObjectType.getDescribe().getKeyPrefix()) {
                    contactIds.add(rel.RelationId);
                } else if (prefix == Lead.SObjectType.getDescribe().getKeyPrefix()) {
                    leadIds.add(rel.RelationId);
                } else if (prefix == Opportunity.SObjectType.getDescribe().getKeyPrefix()) {
                    oppIds.add(rel.RelationId);
                }
            }

            for (User u : [SELECT Id, Name, Email FROM User WHERE Id IN :userIds]) {
                if (String.isNotBlank(u.Email)) {
                    attendees.add(new Map<String, Object>{
                        'emailAddress' => new Map<String, Object>{
                            'address' => u.Email,
                            'name'    => u.Name
                        },
                        'type' => 'required'
                    });
                }
            }

            for (Contact c : [SELECT Id, Name, Email FROM Contact WHERE Id IN :contactIds]) {
                if (String.isNotBlank(c.Email)) {
                    attendees.add(new Map<String, Object>{
                        'emailAddress' => new Map<String, Object>{
                            'address' => c.Email,
                            'name'    => c.Name
                        },
                        'type' => 'required'
                    });
                }
            }

            for (Lead l : [SELECT Id, Name, Email FROM Lead WHERE Id IN :leadIds]) {
                if (String.isNotBlank(l.Email)) {
                    attendees.add(new Map<String, Object>{
                        'emailAddress' => new Map<String, Object>{
                            'address' => l.Email,
                            'name'    => l.Name
                        },
                        'type' => 'required'
                    });
                }
            }

            for (Opportunity o : [SELECT Id, Name, Emaill__c FROM Opportunity WHERE Id IN :oppIds]) {
                if (String.isNotBlank(o.Emaill__c)) {
                    attendees.add(new Map<String, Object>{
                        'emailAddress' => new Map<String, Object>{
                            'address' => o.Emaill__c,
                            'name'    => o.Name
                        },
                        'type' => 'required'
                    });
                }
            }
            System.debug('~~ createTeamsEvent, attendees (final): ' + attendees);

            // ***montar eventbody
            Map<String, Object> eventBody = new Map<String, Object>{
                'subject' => event.Subject,
                'start' => new Map<String, Object>{
                    'dateTime' => event.StartDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss'),
                    'timeZone' => 'America/Sao_Paulo'
                },
                'end' => new Map<String, Object>{
                    'dateTime' => event.EndDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss'),
                    'timeZone' => 'America/Sao_Paulo'
                },
                'location' => new Map<String, Object>{
                    'displayName' => 'Evento criado via Salesforce'
                },
                'attendees' => attendees,
                'isOnlineMeeting' => true,
                'onlineMeetingProvider' => 'teamsForBusiness'
            };
            System.debug('~~ createTeamsEvent, eventBody: ' + eventBody);

            String jsonBody = JSON.serialize(eventBody);
            System.debug('~~ createTeamsEvent, jsonBody: ' + jsonBody);

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://graph.microsoft.com/v1.0/me/events');
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(jsonBody);

            HttpResponse res;
            if (allowHttpCallout) {
                Http http = new Http();
                res = http.send(req);
            } else {
                res = new HttpResponse();
                res.setStatusCode(201);
                res.setBody(JSON.serialize(new Map<String, Object>{
                    'id' => 'evt123',
                    'onlineMeeting' => new Map<String, Object>{
                        'joinUrl' => 'https://teams.microsoft.com/l/reuniao123'
                    },
                    'body' => new Map<String, Object>{
                        'content' => 'ID da Reunião: 987654321'
                    },
                    'organizer' => new Map<String, Object>{
                        'id' => 'ca18a820-29fc-4235-b7f1-1fab2b4f6ad3',
                        'emailAddress' => new Map<String, Object>{
                            'address' => 'barbara.mata@acelerai.com.br',
                            'name' => 'Bárbara Mata'
                        }
                    }
                }));
            }

            if (res.getStatusCode() == 201) {
                System.debug('Evento criado com sucesso no Teams!');

                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String prettyJson = JSON.serializePretty(JSON.deserializeUntyped(res.getBody()));

                if (responseMap.containsKey('onlineMeeting')) {
                    Map<String, Object> onlineMeeting = (Map<String, Object>) responseMap.get('onlineMeeting');
                    if (onlineMeeting.containsKey('joinUrl')) {
                        String joinUrl = (String) onlineMeeting.get('joinUrl');

                        String onlineMeetingId;
                        if (onlineMeeting.containsKey('id')) {
                            System.debug('DEBUG X: onlineMeeting containsKey "id"');
                            onlineMeetingId = (String) onlineMeeting.get('id');
                        }

                        if (responseMap.containsKey('body') && (responseMap.containsKey('id'))) {
                            Map<String, Object> bodyMap = (Map<String, Object>) responseMap.get('body');
                            teamsEventId = (String) responseMap.get('id');

                            String htmlContent = (String) bodyMap.get('content');

                            Pattern p = Pattern.compile('ID da Reunião:\\s*(\\d[\\d\\s]+)');
                            Matcher m = p.matcher(htmlContent);
                            if (m.find()) {
                                teamsMeetingId = m.group(1).trim();
                            }
                        }

                        try {
                            String descricao = '';
                            if (joinUrl != null) {
                                descricao += '🔗' + joinUrl + '\n';
                            }
                            Event createdEvent = TeamsIntegrationRepository.updateEventsFieldWithTeamsData(event, descricao, joinUrl, teamsMeetingId, teamsEventId);

                            System.enqueueJob(new TeamsIntegrationGetUserIdQueueable(createdEvent, accessToken));
                            System.debug('~~[CREATE TeamsEvent 200] Enfileirou a TeamsIntegration GetUserId Queueable');
                        } catch (Exception e) {
                            System.debug('~~[CREATE TeamsEvent 200] EXCEPTION: ' + e.getMessage());
                        }
                    } else {
                        System.debug('~~[CREATE TeamsEvent 200] Campo joinUrl ou meetingId não encontrados na resposta');
                    }
                } else {
                    System.debug('~~[CREATE TeamsEvent 200] Campo onlineMeeting não encontrado na resposta');
                }
            } else {
                System.debug('[CREATE TeamsEvent] ERRO ao criar evento no Teams. Status: ' + res.getStatusCode() + ' - Body: ' + res.getBody());
            }
        } catch (Exception e){
            System.debug('~~ END [CREATE TeamsEvent EXCEPTION]> ' + e.getMessage());
        }
    }   

    public static void updateTeamsEvent(Event event, String accessToken) {
        System.debug('~~ START < updateTeamsEvent');
        if (String.isBlank(event.TeamsEventId__c)) {
            System.debug('~~ END < Evento não possui TeamsEventId__c, não será atualizado no Teams');
            return;
        }

        Map<String, Object> eventBody = new Map<String, Object>{
            'subject' => event.Subject,
            'start' => new Map<String, Object>{
                'dateTime' => event.StartDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss'),
                'timeZone' => 'America/Sao_Paulo'
            },
            'end' => new Map<String, Object>{
                'dateTime' => event.EndDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss'),
                'timeZone' => 'America/Sao_Paulo'
            }
        };

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://graph.microsoft.com/v1.0/me/events/' + event.TeamsEventId__c);
        req.setMethod('PATCH');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(eventBody));

        HttpResponse res;
        if (allowHttpCallout) {
            Http http = new Http();
            res = http.send(req);
        } else {
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{}');
        }

        if (res.getStatusCode() == 200) {
            System.debug('~~ [200] END < Evento atualizado com sucesso no Teams! ');
            try {
                TeamsIntegrationRepository.updateProcessedByTeamsField(event);
                System.debug('~~ [200] Chamou o updateProcessedByTeamsField');
            } catch (Exception e) {
                System.debug('~~ [200] EXCEPTION ao marcar ProcessedByTeams__c: ' + e.getMessage());
            }
        } else {
            System.debug('~~[ERRO] Não atualizou o evento no Teams: ' + res.getBody());
        }
    }

    public static void deleteTeamsEvent(String teamsEventId, String accessToken) {
        try {          
            if (String.isBlank(accessToken) || String.isBlank(teamsEventId)) {
                System.debug('Sem accesstoken ou teamsEventId no deleteTeamsEvent(). O accessToken é: ' + accessToken + ' | O teamsEventId é: ' + teamsEventId);
                return;
            }

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://graph.microsoft.com/v1.0/me/events/' + teamsEventId);
            req.setMethod('DELETE');
            req.setHeader('Authorization', 'Bearer ' + accessToken);

            HttpResponse res;
            if (allowHttpCallout) {
                Http http = new Http();
                res = http.send(req);
            } else {
                res = new HttpResponse();
                res.setStatusCode(204);
                res.setBody('{}');
            }

            if (res.getStatusCode() == 204) {
                System.debug('Evento deletado no Teams com sucesso.');
                System.debug('[DELETE] TeamsIntegrationService. RES: ' + res.getBody());
            } else {
                System.debug('Erro ao deletar no Teams: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exceção ao tentar deletar evento no Teams: ' + e.getMessage());
        }
    }

    /** --- Obtem o USER_ID ---
     * Obs.: Usamos o endpoint calendar/events e o contexto porque não temos os escopos User.ReadAll, logo, precisamos do evento para acessar o contexto e obter o UserId */
    public static void getTeamsUserId(Event event, String accessToken) {
        if (String.isBlank(event.TeamsEventId__c)) {
            System.debug('~~ [getTeamsUserId] Evento ' + event.Subject);
            return;
        }

        try {
            String url = 'https://graph.microsoft.com/v1.0/me/calendar/events/' + event.TeamsEventId__c + '?%24select=organizer';

            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(url);
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Content-Type', 'application/json');

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('🧾 JSON formatado: \n' + JSON.serializePretty(body));

            // pega o userId do campo a partir do @odata.context
            String context = (String) body.get('@odata.context');
            Pattern p = Pattern.compile('users\\(\\\'([^\\\']+)\\\'\\)');
            Matcher m = p.matcher(context);

                if (m.find()) {
                    String userId = m.group(1);
                    System.debug('UserId extraído: ' + userId);

                    String updatedUserId = TeamsIntegrationRepository.updateUserIdWithTeamsData(event, userId);
                    System.debug('Chamou a updateUserIdWithTeamsData');

                    if(updatedUserId != null){
                    /**--- SALVAR TeamsOnlineMeetingId__c com base no JoinURL ---*/
                        System.enqueueJob(new TeamsIntegGetOnlineMeetingIdQueueable(event, accessToken, updatedUserId));
                        System.debug('~~[CREATE TeamsEvent 200] Enfileirou a TeamsIntegration GetOnlineMeetingId Queueable');
                    }
                } else {
                    System.debug('Não foi possível extrair o userId do @odata.context.');
                }
            } else {
                System.debug('Erro ao buscar getTeamsUserId: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exceção em getTeamsUserId: ' + e.getMessage());
        }
    }

    /** Obtem o ONLINEMEETING_ID | Usa o JOINURL */
    public static void getOnlineMeetingIdByJoinUrl(Event event, String accessToken, String teamsUserId) {
        if (String.isBlank(event.TeamsJoinURL__c)) {
            System.debug('~~ [getOnlineMeetingIdByJoinUrl] Evento ' + event.Id + ' sem TeamsJoinURL__c');
            return;
        }

        String encodedJoinUrl = EncodingUtil.urlEncode(event.TeamsJoinURL__c, 'UTF-8');

        String endpoint = 'https://graph.microsoft.com/v1.0/me/onlineMeetings?$filter=JoinWebUrl%20eq%20%27' + encodedJoinUrl + '%27';


        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res;

        try {
            res = http.send(req);
            System.debug('Status: ' + res.getStatusCode());
            System.debug('Body: ' + res.getBody());

            if (res.getStatusCode() == 200) {
                System.debug('DEBUG: SUCESSO: response.getBody: ' + res.getBody());

                Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> values = (List<Object>) body.get('value');

                if (values != null && !values.isEmpty()) {
                    Map<String, Object> first = (Map<String, Object>) values[0];
                    String onlineMeetingId = (String) first.get('id');

                    if (!String.isBlank(onlineMeetingId)) {
                        System.debug('TeamsOnlineMeetingId__c encontrado: ' + onlineMeetingId);

                        if (event.TeamsOnlineMeetingId__c == null || String.isBlank(event.TeamsOnlineMeetingId__c)) {
                            TeamsIntegrationRepository.updateTeamsOnlineMeetingId(event, onlineMeetingId);
                        }

                        /*if (event.TeamsOnlineMeetingId__c != null && !String.isBlank(event.TeamsOnlineMeetingId__c)) {
                            System.debug('SUCESS atualizou e Chamou a queueable');
                            System.enqueueJob(new TeamsAttendanceRecordQueueable(event.Id, onlineMeetingId, accessToken));
                        }*/

                    }
                } else {
                    System.debug('Nenhuma reunião encontrada com essa JoinWebUrl.');
                }
            } else {
                System.debug('Erro na requisição. StatusCode=' + res.getStatusCode());
                System.debug('Corpo da resposta: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }

    /** --- Obtem o ATTENDANCERECORD_ID | Usa o o USER_ID---*/
    public static void getAttendanceRecordId(Event event, String meetingId, String accessToken) {
        if (String.isBlank(meetingId)) {
            System.debug('DEBUG: meetingId inválido: ' + meetingId);
            return;
        }

        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://graph.microsoft.com/v1.0/me/onlineMeetings/' + meetingId + '/attendanceReports');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse response = http.send(req);

        if (response.getStatusCode() == 200) {
            System.debug('DEBUG: SUCESSO: response.getBody: ' + response.getBody());
            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> values = (List<Object>) body.get('value');

            if (values != null && !values.isEmpty()) {
                Map<String, Object> first = (Map<String, Object>) values[0];
                String attendanceRecordId = (String) first.get('id');
                if (!String.isBlank(attendanceRecordId)) {
                    if (event.TeamsAttendanceRecordId__c == null || String.isBlank(event.TeamsAttendanceRecordId__c)) {
                        TeamsIntegrationRepository.updateTeamsAttendanceRecordId(event, attendanceRecordId);
                    }
                }

                if (event.TeamsAttendanceRecordId__c != null && !String.isBlank(event.TeamsAttendanceRecordId__c)) {
                    System.debug('SUCESS  atualizou e Chamou a queueable');
                    System.enqueueJob(new TeamsMeetingParticipantsQueueable(event.Id, accessToken, meetingId, attendanceRecordId));
                }
            }

        } else {
            System.debug('DEBUG: ERRO: ' + response.getStatusCode() + ' - ' + response.getBody());
            return;
        }
    }

    /** --- Obtem o participantes | usa o ATTENDANCERECORD_ID e o ONLINEMEETING_ID ---*/
    public static void getAttendanceRecords(Event event, String meetingId, String accessToken) {
        if (String.isBlank(meetingId)) {
            System.debug('DEBUG: meetingId inválido: ' + meetingId);
            return;
        }

        if (event.TeamsAttendanceRecordId__c == null || String.isBlank(event.TeamsAttendanceRecordId__c)) {
            System.debug('DEBUG: TeamsAttendanceRecordId__c inválido: ' + event.TeamsAttendanceRecordId__c);
            return;
        }

        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://graph.microsoft.com/v1.0/me/onlineMeetings/' + event.TeamsOnlineMeetingId__c + '/attendanceReports/' + event.TeamsAttendanceRecordId__c + '?$expand=attendanceRecords');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse response = http.send(req);

        if (response.getStatusCode() == 200) {
            System.debug('DEBUG SUCESSO: ' + response.getBody());

            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> attendanceRecords = (List<Object>) body.get('attendanceRecords');

            if (attendanceRecords == null || attendanceRecords.isEmpty()) {
                System.debug('Nenhum registro de presença encontrado.');
                return;
            }

            Boolean guestAttended = false;
            List<String> presentersEmails = new List<String>();

            for (Object rec : attendanceRecords) {
                Map<String, Object> attendance = (Map<String, Object>) rec;
                String role = (String) attendance.get('role');
                String emailAddress = (String) attendance.get('emailAddress');

                System.debug('Role encontrado: ' + role);

               if (role == 'Presenter' && !String.isBlank(emailAddress)) {
                    presentersEmails.add(emailAddress);
                    guestAttended = true;
                }
            }

            if (!presentersEmails.isEmpty() && guestAttended) {
                System.debug('DEBUG X: guestAttended: ' + guestAttended);
                System.debug('DEBUG X: presenters encontrados: ' + String.join(presentersEmails, ', '));
                TeamsIntegrationRepository.updateTeamsPresenters(event, guestAttended, presentersEmails);
            }

        } else {
            System.debug('DEBUG: ERRO: ' + response.getStatusCode() + ' - ' + response.getBody());
        }
    }

    /** --- Obtem o TRANSCRIPT_ID | Usa o USER_ID, ONLINEMEETING_ID */
    public static void getTeamsTranscriptId(Event event, User user, String accessToken) {
        if (String.isBlank(event.TeamsOnlineMeetingId__c)) {
            System.debug('~~ [getTeamsTranscriptionId] Evento ' + event.Subject + ' sem TeamsOnlineMeetingId__c');
            return;
        } else if (String.isBlank(user.TeamsUserId__c)) {
            System.debug('TeamsUserId__c está nulo para o usuário: ' + user.Id);
            return;
        }

        try {
            String url = 'https://graph.microsoft.com/beta/users/' + user.TeamsUserId__c + '/onlineMeetings/' + event.TeamsOnlineMeetingId__c + '/transcripts';
            //System.debug('url:' + url);

            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(url);
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Content-Type', 'application/json');

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                System.debug('🧾 JSON formatado: \n' + JSON.serializePretty(body));

                Integer transcriptCount = (Integer) body.get('@odata.count');
                List<Object> transcripts = (List<Object>) body.get('value');

                if (!transcripts.isEmpty()) {
                    Map<String, Object> firstTranscript = (Map<String, Object>) transcripts[0];
                    String transcriptId = (String) firstTranscript.get('id');

                    System.debug('TranscriptId extraído: ' + transcriptId);
                    System.debug('TranscriptCount extraído: ' + transcriptCount);

                    TeamsTranscriptionHistory__c transcriptionHistory = TeamsIntegrationRepository.updateTeamsTranscriptId(event, String.valueOf(transcriptCount), transcriptId);
                    System.debug('Chamou o método updateTeamsTranscriptId para atualizar o TranscriptId');

                    if (transcriptionHistory != null) {
                        User ownerUser = [SELECT Id, TeamsUserId__c FROM User WHERE Id = :event.OwnerId LIMIT 1];
                        System.enqueueJob(new TeamsTranscriptionsQueueable(event, transcriptionHistory, ownerUser, accessToken));
                        System.debug('Enfileirou a TeamsTranscriptionsQueueable');
                    } else {
                        System.debug('Não foi possível enfileirar TeamsTranscriptionsQueueable porque transcriptionHistory é nulo');
                    }
                } else {
                    System.debug('Nenhum transcript encontrado para a reunião');
                }
            } else {
                System.debug('Erro ao buscar getTeamsTranscriptionId: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exceção em getTeamsTranscriptionId: ' + e.getMessage());
        }
    }

    /** --- Obtem as transcrições | Usa o USER_ID, ONLINEMEETING_ID e o TRANSCRIPT_ID */
    public static void getTeamsTranscriptions(Event event, TeamsTranscriptionHistory__c transcriptionHistory, User user, String accessToken) {
        if (String.isBlank(transcriptionHistory.TeamsTranscriptId__c)) {
            System.debug('~~ [getTeamsTranscriptions] TranscriptionHistory sem TranscriptId: ' + transcriptionHistory.Id);
            return;
        } else if (String.isBlank(user.TeamsUserId__c)) {
            System.debug('~~ [getTeamsTranscriptions] TeamsUserId__c null em: ' + user.Id);
            return;
        }

        try {
            String url = 'https://graph.microsoft.com/beta/users/' + user.TeamsUserId__c + '/onlineMeetings/' + event.TeamsOnlineMeetingId__c + '/transcripts/' + transcriptionHistory.TeamsTranscriptId__c + '/content';
            //System.debug('URL de conteúdo da transcrição: ' + url);

            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(url);
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Accept', 'text/vtt');

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                String transcriptContent = res.getBody();
                System.debug('Conteúdo da transcrição (VTT):\n' + transcriptContent);

                TeamsIntegrationRepository.saveTranscriptContent(transcriptionHistory, transcriptContent);
                System.debug('Conteúdo da transcrição salvo com sucesso');

                LoggerUtility.createLogIntegrationSuccess(res, 'Event: ' + String.valueOf(event.Id), String.valueOf(req), 'Teams', 'Método: getTeamsTranscriptions');
            } else {
                System.debug('Erro ao buscar conteúdo da transcrição: ' + res.getBody());
                LoggerUtility.createLogIntegrationException(res, 'Event: ' + String.valueOf(event.Id), String.valueOf(req), 'Teams', 'Método: getTeamsTranscriptions');
            }
        } catch (Exception e) {
            System.debug('Exceção em getTeamsTranscriptions: ' + e.getMessage());
            LoggerUtility.createLogException(e, 'Event: ' + String.valueOf(event.Id), 'Método: getTeamsTranscriptions');
        }
    }
}