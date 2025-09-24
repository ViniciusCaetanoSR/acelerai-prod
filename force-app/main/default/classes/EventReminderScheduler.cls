/* É chamado para enviar o lembrete 30 minutos antes do evento - que é agendado pelo método scheduleReminderForEvent() da EventService.
Quando chega a hora, o método execute() daqui chama o método sendReminder() da EventService para enviar o e-mail
*/

public class EventReminderScheduler implements Schedulable {
    private Id eventId;
    public String response; 

    public EventReminderScheduler(Event evt) {
        this.eventId = evt.Id;
    }

    public void execute(SchedulableContext sc) {
        try {
            Event evt = [SELECT Id, OwnerId, Subject, ScheduledJobId__c, StartDateTime, EndDateTime, Location, Description,
                    (SELECT Id, RelationId, Relation.Type 
                     FROM EventRelations 
                     WHERE Relation.Type IN ('Contact', 'User'))
                FROM Event 
                WHERE Id = :this.eventId
                LIMIT 1
            ];

            if (evt == null) {
                this.response = 'Evento não encontrado';
                return;
            }

            this.response = EventService.sendReminder(evt);

            evt.ScheduledJobId__c = null;
            update evt;
        } catch (Exception e) {
            this.response = 'Erro no execute()';
            System.debug('Erro: ' + e.getMessage());
        }
    }

    public String getResponse() {
        return this.response;
    }
}