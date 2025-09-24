public class EventService {
    /**
     * retorno: condição ? valor_se_for_verdadeiro : valor_se_for_falso
    */
    public static Date today {
        get { return today != null ? today : Date.today(); }
        set;
    }

    public static String callScheduleReminderForTodayEvents() {
        System.debug('Chamou o callScheduleReminderForTodayEvents()');

        List<Event> todayEvents = [SELECT Id, OwnerId, Owner.Name, Subject, ScheduledJobId__c, StartDateTime, EndDateTime
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
        System.debug('Chamou o scheduleReminderForEvent(), evt.Subject: ' + evt.Subject + ' >> StartDateTime do evento é: ' + evt.StartDateTime);

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
                emailBody += 'Localização: ' + evt.Location + '\n\n';
                emailBody += 'Descrição: ' + evt.Description + '\n\n';

                mail.setPlainTextBody(emailBody);

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
}