public with sharing class AssignmentGroupMemberTriggerHandler {

    public static void updateAssigmentGroup(List<AssignmentGroupMember__c> newAssignmentGroupMembers) {

        Set<Id> assignmentGroupIds = new Set<Id>();
        List<AssignmentGroupMember__c> assignGroupMembs = new List<AssignmentGroupMember__c>();

        for(AssignmentGroupMember__c assignGroupMem : newAssignmentGroupMembers){
            assignmentGroupIds.add(assignGroupMem.AssignmentGroup__c);
        }

        for(AssignmentGroupMember__c assignGroupMem : [SELECT Id FROM AssignmentGroupMember__c WHERE AssignmentGroup__c IN :assignmentGroupIds]){
            assignGroupMem.LastAssignmentDate__c = null;
            assignGroupMem.NumberRecordsAssigned__c = 0.0;

            assignGroupMembs.add(assignGroupMem);
        }

        System.debug('X: assignGroupMembs ' + assignGroupMembs);
        
        if(assignGroupMembs.size() > 0){

            try{
                update assignGroupMembs;
            } catch (DmlException e){
                System.debug('Erro ao atualizar AssignmentGroupMembers: ' + e.getMessage());
            }
        }
    } 
}