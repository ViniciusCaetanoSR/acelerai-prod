trigger LeadEntryEventTrigger on LeadEntryEvent__e (after insert) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            LeadEntryEventTriggerHandler.onAfterInsert(Trigger.new);
        }
    }
}