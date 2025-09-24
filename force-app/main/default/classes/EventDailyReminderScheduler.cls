/*Executa diariamente o método callScheduleReminderForTodayEvents() da EventService.
Roda uma vez por dia, as 6h, para verificar eventos do dia atual*/

public class EventDailyReminderScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        System.debug(' Chamou o execute do EventDAILYReminderScheduler, sc: ' + sc);
        EventService.callScheduleReminderForTodayEvents();
    }
}