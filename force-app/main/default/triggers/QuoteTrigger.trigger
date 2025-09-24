trigger QuoteTrigger on Quote(before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            QuoteTriggerHandler.onBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            QuoteTriggerHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            QuoteTriggerHandler.OnAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            QuoteTriggerHandler.onAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            QuoteTriggerHandler.onAfterDelete(Trigger.oldMap);
        }
    }
}