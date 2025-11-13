public with sharing class EventTriggerHandler {
    public static void onBeforeInsert(List<Event> newEvents) {}

    public static void onBeforeUpdate(List<Event> newEvents, Map<Id, Event> oldEventsMap) {}

    public static void onAfterInsert(List<Event> newEvents) {
        List<Event> eventsToProcess = new List<Event>();
        for (Event e : newEvents) {
            if (e.ProcessedByTeams__c == false) {
                eventsToProcess.add(e);
            }
        }

        if (!eventsToProcess.isEmpty()) {
            EventService.callScheduleReminderForTodayEvents_handleInsert(eventsToProcess);
            EventService.handleCreateTeamsEvent(eventsToProcess);
            System.debug('Event Trigger: onAfterInsert processou ' + eventsToProcess.size() + ' eventos');
        }
    }

    public static void onAfterUpdate(List<Event> newEvents, Map<Id, Event> oldEventsMap) {
        List<Event> eventsToProcess = new List<Event>();
        for (Event e : newEvents) {
            if (e.ProcessedByTeams__c == false) {
                eventsToProcess.add(e);
            }
        }

        if (!eventsToProcess.isEmpty()) {
            EventService.callScheduleReminderForTodayEvents_handleUpdate(eventsToProcess, oldEventsMap);
            EventService.handleUpdateTeamsEvent(eventsToProcess, oldEventsMap);
            System.debug('Event Trigger: onAfterUpdate processou ' + eventsToProcess.size() + ' eventos');
        }
    }

    //Comentado por Barbara em 25/09 - ficou para melhoria     
    public static void onAfterDelete(List<Event> oldEvents) {
        System.debug('onAfterDelete:' + oldEvents);
        EventService.handleDeleteTeamsEvents(oldEvents);
    }
}