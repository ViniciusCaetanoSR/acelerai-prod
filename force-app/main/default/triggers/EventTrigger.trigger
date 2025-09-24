trigger EventTrigger on Event (before insert, before update, after insert, after update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            EventTriggerHandler.onBeforeInsert(Trigger.new);
        }        
        if (Trigger.isUpdate) {
            EventTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            EventTriggerHandler.onAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {   
            EventTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}