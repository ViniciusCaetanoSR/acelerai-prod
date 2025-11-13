public with sharing class AssignmentGroupMemberSelector {

    public static List<AssignmentGroup__c> selectAllGroupsOfLeads(){
        List<AssignmentGroup__c> allGroups =  [SELECT Id, Media__c, Object__c, Name FROM AssignmentGroup__c WHERE Object__c = 'Lead'];
        return allGroups;
    }

    public static List<AssignmentGroup__c> selectAllGroupsOfOpportunity(){
        List<AssignmentGroup__c> allGroups =  [SELECT Id, Media__c, Object__c, Name FROM AssignmentGroup__c WHERE Object__c = 'Opportunity'];
        return allGroups;
    }

     public static List<AssignmentGroupMember__c> selectMembersGroupAgencia(){
        List<AssignmentGroupMember__c> assignmentGroupMemberAgencia = [
            SELECT Id, User__c, User__r.Name, NumberRecordsAssigned__c, LastAssignmentDate__c, AssignmentGroup__c, AssignmentGroup__r.Media__c
            FROM AssignmentGroupMember__c
            WHERE AssignmentGroup__r.Object__c = 'Opportunity' AND AssignmentGroup__r.Name = 'Oportunidades Parcerias Top Vendedores'
        ];
        return assignmentGroupMemberAgencia;
    }

    public static List<AssignmentGroupMember__c> selectMembersGroupOpportunityMentoria(){
        List<AssignmentGroupMember__c> assignmentGroupMemberAgencia = [
            SELECT Id, User__c, User__r.Name, NumberRecordsAssigned__c, LastAssignmentDate__c, AssignmentGroup__c, AssignmentGroup__r.Media__c
            FROM AssignmentGroupMember__c
            WHERE AssignmentGroup__r.Object__c = 'Opportunity' AND AssignmentGroup__r.Name = 'Opportunity Mentoria'
        ];
        return assignmentGroupMemberAgencia;
    }

    public static List<User> getUserRotearOportunidadeEqualsTrue(Set<Id> leadOwnerIds) {
        List<User> users = [SELECT Id, Name, RotearOportunidade__c FROM User WHERE Id IN :leadOwnerIds AND RotearOportunidade__c = true];
        return users;
    }

    public static List<AssignmentGroupMember__c> selectMediaMembersLead(){
       List<AssignmentGroupMember__c> membersMedia = [
            SELECT Id, User__c, User__r.Name, NumberRecordsAssigned__c, LastAssignmentDate__c, AssignmentGroup__c, AssignmentGroup__r.Media__c
            FROM AssignmentGroupMember__c
            WHERE AssignmentGroup__r.Object__c = 'Lead' AND AssignmentGroup__r.Media__c != NULL
        ];
        return membersMedia;
    }

    public static List<AssignmentGroupMember__c> selectDefaultMembersLead(){
       List<AssignmentGroupMember__c> membersDefault = [
                SELECT Id, User__c, User__r.Name, NumberRecordsAssigned__c, LastAssignmentDate__c, AssignmentGroup__c, AssignmentGroup__r.Media__c
                FROM AssignmentGroupMember__c
                WHERE AssignmentGroup__r.Object__c = 'Lead' AND AssignmentGroup__r.Media__c = NULL
            ];
        return membersDefault;
    }

}