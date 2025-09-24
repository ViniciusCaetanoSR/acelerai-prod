trigger LeadTrigger on Lead(before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            LeadTriggerHandler.onBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            LeadTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            LeadTriggerHandler.onAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            LeadTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}