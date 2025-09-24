/**
 * @description       : Trigger for LeadEntry__c to handle lead creation and updates.
 * @author            : Vinícius Caetano
 * @last modified on  : 20-05-2025
 * @last modified by  : Vinícius Caetano
 **/
trigger LeadEntryTrigger on LeadEntry__c(before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            LeadEntryTriggerHandler.onBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            LeadEntryTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            LeadEntryTriggerHandler.onAfterInsert(Trigger.new, Trigger.old);
        }
        if (Trigger.isUpdate) {
            LeadEntryTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}