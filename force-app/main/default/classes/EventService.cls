public class EventService {
    public static Boolean throwTestException = false; //usado para mockar Exception em testes

    /**
     * retorno: condição ? valor_se_for_verdadeiro : valor_se_for_falso
    */
    public static Date today {
        get { return today != null ? today : Date.today(); }
        set;
    }

    public static String callScheduleReminderForTodayEvents() {
        System.debug('Chamou o callScheduleReminderForTodayEvents()');

        List<Event> todayEvents = [SELECT Id, OwnerId, Owner.Name, Subject, ScheduledJobId__c, StartDateTime, EndDateTime, Description
            FROM Event
            WHERE ActivityDate = :today
            AND StartDateTime != null
        ];

        if (!todayEvents.isEmpty()) {
            for (Event evt : todayEvents) {
                Datetime reminderTime = evt.StartDateTime.addMinutes(-30);

                String jobId = scheduleReminderForEvent(evt, reminderTime);
                evt.ScheduledJobId__c = jobId;
            }
            update todayEvents;
            return 'Job agendado';
        } else {
            System.debug(' --------------Saiu do callScheduleReminderForTodayEvents()');
            return 'Job não foi agendado';
        }
    }

    public static String scheduleReminderForEvent(Event evt, Datetime reminderTime) {

        if (reminderTime < Datetime.now()) {
            System.debug('Já passou o momento (hr) de enviar o reminder: ' + reminderTime);
            return null;
        }

        String cron = String.format('{0} {1} {2} {3} {4} ? {5}',
            new List<String>{
                String.valueOf(reminderTime.second()),
                String.valueOf(reminderTime.minute()),
                String.valueOf(reminderTime.hour()),
                String.valueOf(reminderTime.day()),
                String.valueOf(reminderTime.month()),
                String.valueOf(reminderTime.year())
        });

        String jobName = 'EventReminder__' + evt.Id + '_' + reminderTime.getTime();
        String jobId = System.schedule(jobName, cron, new EventReminderScheduler(evt));

        System.debug(' [scheduleReminderForEvent()] Job agendado com ID: ' + jobId);
        System.debug(' --------------Saiu do scheduleReminderForEvent()');

        return jobId;
    }

    public static String sendReminder(Event evt) {
        System.debug(' Chamou o sendReminder(), evt.Subject: ' + evt.Subject);

        List<String> attendeesEmails = new List<String>();
        Set<Id> contactIds = new Set<Id>();

        List<EventRelation> eventRelations = [SELECT Id, EventId, Relation.Name, RelationId, Relation.Type
            FROM EventRelation WHERE EventId = :evt.Id
        ];

        if (!eventRelations.isEmpty()) {
            for (EventRelation relation : eventRelations) {
                if (relation.Relation.Type == 'Contact') {
                    contactIds.add(relation.RelationId);
                } else {
                    System.debug('No sendReminder(), O Relation.Type não é contato, ele é: ' + relation.Relation.Type);
                }
            }
        } else {
            System.debug('A lista de eventRelations está vazia no sendReminder(): ' + eventRelations);
        }

        if (evt.OwnerId != null) {
            User eventOwner = [SELECT Id, Email, Name FROM User WHERE Id = :evt.OwnerId LIMIT 1];

            if (eventOwner.Email != null) {
                attendeesEmails.add(eventOwner.Email);
            } else {
                System.debug('No sendReminder(), o OwnerId não tem e-mail: ' + eventOwner.Email);
            }
        } else {
            System.debug('No sendReminder(), o evento não tem OwnerId definido');
        }

        if (!contactIds.isEmpty()) {
            List<Contact> contacts = [SELECT Id, Email, Name FROM Contact WHERE Id IN :contactIds];

            for (Contact contact : contacts) {
                if (contact.Email != null) {
                    attendeesEmails.add(contact.Email);
                } else {
                    System.debug('Problema no sendReminder(). Não há email associado ao contato: ' + contact.Email);
                }
            }
        }

        //Adicionar os "Name(WhoId)" aos attendees, para receberem email:
        //List<Id> whoId = [SELECT Id, WhoId FROM Event WHERE  Id = :evt.Id LIMIT 1];

        if (!attendeesEmails.isEmpty()) {
            try {
                OrgWideEmailAddress owea = [SELECT Id, Address  FROM OrgWideEmailAddress LIMIT 1];
                String formattedTime = evt.StartDateTime.format('hh:mm a', 'America/Sao_Paulo');

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setOrgWideEmailAddressId(owea.Id);
                mail.setBccAddresses(attendeesEmails);
                mail.setSubject('Lembrete de Evento: ' + evt.Subject + ' às ' + formattedTime);

                String emailBody = 'Você tem um evento agendado:\n\n';
                emailBody += 'Evento: ' + evt.Subject + '\n';
                emailBody += 'Início: ' + evt.StartDateTime.format('dd/MM/yyyy HH:mm') + '\n';
                emailBody += 'Término: ' + evt.EndDateTime.format('dd/MM/yyyy HH:mm') + '\n\n';
                //emailBody += 'Localização: ' + evt.TeamsJoinURL__c + '\n\n';
                emailBody += 'Link da reunião Teams: ' + evt.Description + '\n\n';

                //mail.setPlainTextBody(emailBody);

                String htmlBody = '<p>Você tem um evento agendado:</p>';
                htmlBody += '<p><strong>Evento:</strong> ' + evt.Subject + '<br>';
                htmlBody += '<strong>Início:</strong> ' + evt.StartDateTime.format('dd/MM/yyyy HH:mm') + '<br>';
                htmlBody += '<strong>Término:</strong> ' + evt.EndDateTime.format('dd/MM/yyyy HH:mm') + '</p>';

                if (evt.Description != null) {
                    htmlBody += '<p><strong>Link da reunião Teams:</strong><br>';

                    Pattern p = Pattern.compile('https?://[\\S]+');
                    Matcher m = p.matcher(evt.Description);
                    if (m.find()) {
                        String link = m.group(0);
                        htmlBody += '<a href="' + link + '">' + link + '</a>';
                    } else {
                        htmlBody += evt.Description; // fallback
                    }
                    htmlBody += '</p>';
                }

                mail.setHtmlBody(htmlBody);

                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
                System.debug(' *-* Email enviado *-*');
            } catch (Exception e) {
                System.debug('Erro ao enviar e-mail: ' + e.getMessage());
                throw e;
            }

            String returnMessage = 'Lembrete enviado com sucesso';
            System.debug(' --------------Saiu do sendReminder(), evt.Subject: ' + evt.Subject);

            return returnMessage;
        } else {
            System.debug('No sendReminder(), não há e-mail válido encontrado para enviar o lembrete');
            String returnMessage = 'Lembrete NÃO enviado';
            return returnMessage;
        }
    }

    public static void callScheduleReminderForTodayEvents_handleInsert(List<Event> newEvents) {
        System.debug('Chamou o agendador de eventos [HandleINSERT]');

        Date today = Date.today();
        List<Event> eventsToUpdate = new List<Event>();

        for (Event evt : newEvents) {
            if (evt.ActivityDate == today) {
                Datetime reminderTime = evt.StartDateTime.addMinutes(-30);
                String jobId = scheduleReminderForEvent(evt, reminderTime);

                eventsToUpdate.add(new Event(
                    Id = evt.Id,
                    ScheduledJobId__c = jobId
                ));

                System.debug('[HandleINSERT] Evento agendado para hoje: ' + evt.Subject);
            } else {
                if (evt.ActivityDate != today) {
                    System.debug('[HandleINSERT] A data do evento não é hoje: ' + evt.ActivityDate);
                }
            }
        }

        if (!eventsToUpdate.isEmpty()) {
            try {
                update eventsToUpdate;
                System.debug('[HandleINSERT] Total de eventos atualizados com Job IDs: ' + eventsToUpdate.size());
            } catch(DmlException e) {
                System.debug('[HandleINSERT] Erro ao atualizar eventos: ' + e.getMessage());
            }
        }
        System.debug(' --------------Saiu do HANDLE_INSERT');
    }

    public static void callScheduleReminderForTodayEvents_handleUpdate(List<Event> updatedEvents, Map<Id, Event> oldEventsMap) {
        System.debug('Chamou o agendador de eventos [HandleUPDATE]');

        Date today = Date.today();
        List<Event> eventsToUpdate = new List<Event>();

        for (Event evt : updatedEvents) {
            System.debug(' [HandleUPDATE] Id do job agendado antes: ' + evt.ScheduledJobId__c);

            Event oldEvent = oldEventsMap.get(evt.Id);

            if ((evt.ActivityDate != oldEvent.ActivityDate || evt.StartDateTime != oldEvent.StartDateTime)
                && evt.ActivityDate == today) {

                try {

                    if (evt.ScheduledJobId__c != null) {
                        System.abortJob(evt.ScheduledJobId__c);
                    }
                    System.debug(' [HandleUPDATE] Id do job depois de cancelar: ' + evt.ScheduledJobId__c);

                    Datetime reminderTime = evt.StartDateTime.addMinutes(-30);
                    String jobId = scheduleReminderForEvent(evt, reminderTime);

                    eventsToUpdate.add(new Event(
                        Id = evt.Id,
                        ScheduledJobId__c = jobId
                    ));

                    System.debug(' [HandleUPDATE] Novo jobId agendado para evento: ' + evt.Id);

                } catch(Exception e) {
                    System.debug(' [HandleUPDATE] Erro ao processar evento ' + evt.Id + ': ' + e.getMessage());
                }
            } else {
                if (evt.ActivityDate != today) {
                    System.debug(' [HandleUPDATE] Evento não é para hoje: ' + evt.ActivityDate);
                }
            }
        }

        if (!eventsToUpdate.isEmpty()) {
            try {
                update eventsToUpdate;
                System.debug('  [HandleUPDATE] Eventos atualizados com novos Job IDs: ' + eventsToUpdate.size());
            } catch(DmlException e) {
                System.debug(' [HandleUPDATE] Erro ao atualizar eventos: ' + e.getMessage());
            }
        }
        System.debug(' --------------Saiu do HANDLE_update');
    }

    public static Boolean handleCreateTeamsEvent(List<Event> newEvents) {
        System.debug('~~ START> handleCreateTeamsEvent: ' + ' newEvents.size(): ' + newEvents.size());
        if (newEvents.isEmpty()){
            System.debug('~~ START> handleUpdateTeamsEvent, newEvents vazia: ' + newEvents.size());
            return false;
        }

        Boolean queuedJob = false;
        for (Event e : newEvents) {
            if(e.AgendaPessoal__c){
            	System.debug('É agenda pessoal');
                return false;
            }
            
            if (e.ProcessedByTeams__c == false) {
                System.enqueueJob(new TeamsEventQueueable(e.Id));
                queuedJob = true;
            }
            System.debug('~~ END> handleCreateTeamsEvent enfileirou o job: ' + e.Subject + ' para CRIAR o Evento no Teams');
        }
        return queuedJob;
    }

    public static Boolean handleUpdateTeamsEvent(List<Event> newEvents, Map<Id, Event> oldEventsMap){
        System.debug('~~ START> handleUpdateTeamsEvent: ' + ' newEvents.size(): ' + newEvents.size());
        
        if (newEvents.isEmpty()){
            System.debug('~~ START> handleUpdateTeamsEvent, newEvents vazia: ' + newEvents.size());
            return false;
        }

        Boolean queuedJob = false;
        for (Event e : newEvents) {
            if(e.AgendaPessoal__c){
            	System.debug('É agenda pessoal');
                return false;
            }
            
            Event oldEv = oldEventsMap.get(e.Id);
            if (e.Subject != oldEv.Subject || e.StartDateTime != oldEv.StartDateTime || e.EndDateTime != oldEv.EndDateTime) {
                if (e.ProcessedByTeams__c == false) {
                    System.enqueueJob(new TeamsEventQueueable(e.Id));
                    queuedJob = true;
                    System.debug('~~ END> handleUpdateTeamsEvent enfileirou o job: ' + e.Subject + ' para ATUALIZAR o Evento no Teams'); 
                }
            }
        }
        return queuedJob;
    }

    public static Boolean handleDeleteTeamsEvents(List<Event> oldEvents) {        
        System.debug('~~ START> handleDeleteTeamsEvents, oldEvents:' + oldEvents);

        if (oldEvents.isEmpty()) {
            System.debug('~~ [END] handleDeleteTeamsEvents: oldEvents vazia');
            return false;
        }

        Set<Id> ownerIds = new Set<Id>();
        for (Event oldE : oldEvents) {
            if (oldE.OwnerId != null) {
                ownerIds.add(oldE.OwnerId);
            }
        }

        Map<Id, User> ownersById = new Map<Id, User>(
            [SELECT Id, Name, TeamsAccessToken__c, TeamsConsentCode__c,
                    TeamsRefreshToken__c, HasTeamsConsent__c, TeamsTokenExpiresAt__c
            FROM User
            WHERE Id IN :ownerIds]
        );

        Boolean hasCallout = false;
        for (Event oldE : oldEvents) {
            if(oldE.AgendaPessoal__c){
            	System.debug('Era agenda pessoal');
                return false;
            }
            
            if (oldE.TeamsEventId__c != null) {
                User owner = ownersById.get(oldE.OwnerId);
                if (owner != null && owner.HasTeamsConsent__c) {
                    Boolean validAccessToken = TeamsOAuth_Helper.handleTokenExpiration(owner);

                    if (validAccessToken) {
                        System.enqueueJob(new TeamsDeleteEventQueueable(oldE.TeamsEventId__c, owner.TeamsAccessToken__c));
                        hasCallout = true;
                        System.debug('~~ [END] handleDeleteTeamsEvents: enfileirou a TeamsDeleteEventQueueable() para o evento ' + oldE.Subject);
                    } else {
                        System.debug('~~ [END] handleDeleteTeamsEvents: token inválido para usuário ' + owner.Id);
                    }
                } else {
                    System.debug('~~ [END] handleDeleteTeamsEvents: usuário sem consentimento ou não encontrado para evento ' + oldE.Id);
                }
            }
        }

        return hasCallout;
    }

    public static Boolean handleFinishedEvent_TeamsIntegration() {        
        if (throwTestException) {
            throw new AuraHandledException('Erro simulado para teste');
        }
        
        Boolean queuedJobs;
        try {
            List<Event> eventsToProcess = [
                SELECT Id, OwnerId, Subject, TeamsOnlineMeetingId__c, TeamsJoinURL__c, TeamsEventId__c, TeamsAttendanceRecordId__c, TeamsShowStatus__c, ProcessedByTeams__c
                FROM Event
                WHERE TeamsOnlineMeetingId__c != null
                AND TeamsAttendanceRecordId__c = null
                AND EndDateTime >= :System.now().addMinutes(-60)
                AND EndDateTime <= :System.now()
                LIMIT 10
            ];
            System.debug('[handleFinishedEvent_TeamsIntegration] eventsToProcess: ' + eventsToProcess.size());

            if (eventsToProcess.isEmpty()) {
                System.debug('[handleFinishedEvent_TeamsIntegration] Nenhum evento para processar.');
                return false;
            }

            Set<Id> ownerIds = new Set<Id>();
            for (Event ev : eventsToProcess) {
                ownerIds.add(ev.OwnerId);
            }

            Map<Id, User> userMap = new Map<Id, User>([
                SELECT Id, Name, TeamsAccessToken__c, TeamsUserId__c
                FROM User
                WHERE Id IN :ownerIds
            ]);

            for (Event ev : eventsToProcess) {

                User owner = userMap.get(ev.OwnerId);
                String accessToken = owner != null ? owner.TeamsAccessToken__c : null;
                String onlinemeetingId = ev.TeamsOnlineMeetingId__c;

                if (accessToken != null && onlinemeetingId != null) {
                    // ---** Attendance **---
                    System.enqueueJob(new TeamsGetAttendanceQueueable(ev, accessToken, onlinemeetingId));
                    System.debug('Enfileirou a TeamsGetAttendanceQueueable');

                    // ---** Transcript **---
                    System.enqueueJob(new TeamsGetTranscriptionQueueable(ev, accessToken, owner));
                    System.debug('Enfileirou a TeamsGetTranscriptionQueueable');
                    queuedJobs = true;
                } else {
                    System.debug('[handleFinishedEvent_TeamsIntegration] Dados insuficientes para processar evento, ev.Subject > ' + ev.Subject + ' | onlinemeetingId: ' + onlinemeetingId + ' | accessToken: ' + accessToken + ' | owner: ' + owner);
                    queuedJobs = false;
                }
            }
        } catch (Exception e) {
            System.debug('[ERRO] EventService.handleFinishedEvent_TeamsIntegration: ' + e.getMessage());
            return false;
        }
        return queuedJobs;
    }
}