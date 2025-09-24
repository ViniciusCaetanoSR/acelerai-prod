trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {

    if (Trigger.isBefore) {

        if (Trigger.isUpdate) {
            OpportunityTriggerHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap, Trigger.new, Trigger.old);
        }

        if (Trigger.isInsert) {
            OpportunityTriggerHandler.onBeforeInsert(Trigger.newMap, Trigger.oldMap, Trigger.new, Trigger.old);
        }

        for (Opportunity opp : trigger.new) {
            opp.CreatedDate__c = Datetime.now();
            opp.LastModifiedDate__c = Datetime.now();
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            OpportunityTriggerHandler.onAfterInsert(Trigger.newMap, Trigger.oldMap, Trigger.new, Trigger.old);
        }
        if(Trigger.isUpdate){
            OpportunityTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap, Trigger.new, Trigger.old);
        }
    }
}