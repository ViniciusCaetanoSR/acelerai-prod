public with sharing class EventTriggerHandler {

    public static void onBeforeInsert(List<Event> newEvents) {
    }

    public static void onBeforeUpdate(List<Event> newEvents, Map<Id, Event> oldEventsMap) {
    }

    public static void onAfterInsert(List<Event> newEvents) {
        EventService.callScheduleReminderForTodayEvents_handleInsert(newEvents);
    }    
    
    public static void onAfterUpdate(List<Event> newEvents, Map<Id, Event> oldEventsMap) {
        EventService.callScheduleReminderForTodayEvents_handleUpdate(newEvents, oldEventsMap);
    }    
}