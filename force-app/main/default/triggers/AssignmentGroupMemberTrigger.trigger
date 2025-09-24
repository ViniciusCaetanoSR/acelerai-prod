trigger AssignmentGroupMemberTrigger on AssignmentGroupMember__c (before insert, before update, after insert, after update, before Delete) {

    if (trigger.isAfter){
        if(trigger.isInsert) {
            AssignmentGroupMemberTriggerHandler.updateAssigmentGroup(Trigger.new);
        }
    }
    if (trigger.isBefore){
        if(trigger.isDelete) {
            AssignmentGroupMemberTriggerHandler.updateAssigmentGroup(Trigger.old);
        }
    }
}