public with sharing class LeadEntryEventTriggerHandler {

    public static void onAfterInsert(List<LeadEntryEvent__e> newLee) {
        System.debug('Chamou o onAfterInsert da LeadEntryEventTriggerHandler');
        LeadEntryEventService.queuesLeadsToBeCreated(newLee);        
    }
}