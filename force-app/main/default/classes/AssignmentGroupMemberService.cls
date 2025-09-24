public with sharing class AssignmentGroupMemberService {
    private static Map<Id, Lead> leadsToUpdateMap = new Map<Id, Lead>();
    private static Map<Id, AssignmentGroupMember__c> membersToUpdate = new Map<Id, AssignmentGroupMember__c>();

    public static AssignmentGroupMember__c getPriorityMember(List<AssignmentGroupMember__c> tempMembers) {
        AssignmentGroupMember__c priorityMember = new AssignmentGroupMember__c();
        Datetime lastAssignment = Datetime.Now();

        if (tempMembers.isEmpty()) {
            System.debug('Nenhum membro encontrado no grupo');
            return null;
        }

        List<AssignmentGroupMember__c> members = (List<AssignmentGroupMember__c>) JSON.deserialize(
            JSON.serialize(tempMembers),
            List<AssignmentGroupMember__c>.class
        );

        for (AssignmentGroupMember__c member : members) {
            if (member.LastAssignmentDate__c == null) {
                lastAssignment = member.LastAssignmentDate__c;
                member.LastAssignmentDate__c = Datetime.Now();
                priorityMember = member;
            } else if (member.LastAssignmentDate__c < lastAssignment) {
                lastAssignment = member.LastAssignmentDate__c;
                member.LastAssignmentDate__c = Datetime.Now();
                priorityMember = member;
            }
        }
        return priorityMember;
    }

    @InvocableMethod(label='AssignmentGroupMemberLead' description='The class assignment member to group')
    public static void assignmentGroupMemberLead(List<Lead> leads) {
        leadsToUpdateMap.clear();
        membersToUpdate.clear();

        try {
            //Grupos sem Campo Mídia preenchido
            List<AssignmentGroupMember__c> defaultMembers = [
                SELECT Id, User__c, User__r.Name, NumberRecordsAssigned__c, LastAssignmentDate__c, AssignmentGroup__c, AssignmentGroup__r.Media__c
                FROM AssignmentGroupMember__c
                WHERE AssignmentGroup__r.Object__c = 'Lead' AND AssignmentGroup__r.Media__c = NULL
            ];

            //Grupos com Campo Mídia preenchido
            List<AssignmentGroupMember__c> mediaMembers = [
                SELECT Id, User__c, User__r.Name, NumberRecordsAssigned__c, LastAssignmentDate__c, AssignmentGroup__c, AssignmentGroup__r.Media__c
                FROM AssignmentGroupMember__c
                WHERE AssignmentGroup__r.Object__c = 'Lead' AND AssignmentGroup__r.Media__c != NULL
            ];

            List<AssignmentGroup__c> allGroups = [SELECT Id, Media__c, Object__c, Name FROM AssignmentGroup__c WHERE Object__c = 'Lead'];

            // Consulta feita somente para pegar grupo de atribuição padrão;
            AssignmentGroup__c defaultGroup = [SELECT Id FROM AssignmentGroup__c WHERE Id = :defaultMembers[0].AssignmentGroup__c LIMIT 1];

            for (Lead lead : leads) {
                Boolean leadAssigned = false;

                for (AssignmentGroup__c ag : allGroups) {
                    if (leadAssigned) {
                        break;
                    }
                    //Caso encontre um Grupo de Atribuição onde o campo Mídia contém o campo Website do lead preenchido
                    if (!String.isEmpty(lead.Website__c) && !String.isEmpty(ag.Media__c) && lead.Website__c.containsIgnoreCase(ag.Media__c)) {
                        assignLeadToMember(lead, ag, mediaMembers);
                        leadAssigned = true;
                    }
                }
                //Grupo padrão (Grupo Lead com o campo Mídia Vazio)
                if (!leadAssigned) {
                    assignLeadToMember(lead, defaultGroup, defaultMembers);
                }
            }

            if (!leadsToUpdateMap.isEmpty()) {
                update leadsToUpdateMap.values();
            }

            if (!membersToUpdate.isEmpty()) {
                update membersToUpdate.values();
            }
        } catch (Exception e) {
            LoggerUtility.createLogException(e, null, 'assignmentGroupMemberLead');
        }
    }

    private static void assignLeadToMember(Lead currentLead, AssignmentGroup__c ag, List<AssignmentGroupMember__c> allMembers) {
        List<AssignmentGroupMember__c> filteredMembers = new List<AssignmentGroupMember__c>();

        for (AssignmentGroupMember__c member : allMembers) {
            if (member.AssignmentGroup__c == ag.Id) {
                filteredMembers.add(member);
            }
        }

        AssignmentGroupMember__c priorityMember = AssignmentGroupMemberService.getPriorityMember(filteredMembers);

        if (priorityMember != null) {
            for (AssignmentGroupMember__c member : filteredMembers) {
                //Após encontrar o membro prioritário irá atualizar a contagem e data de atribuição
                if (member.Id == priorityMember.Id && member.AssignmentGroup__c == ag.Id) {
                    member.LastAssignmentDate__c = priorityMember.LastAssignmentDate__c;
                    member.NumberRecordsAssigned__c = priorityMember.NumberRecordsAssigned__c + 1;
                    membersToUpdate.put(member.Id, member);
                }
            }
            //O usuário não pode ser uma fila, caso contrário irá atribuir para ninguém
            Id userId = (priorityMember.User__c != null && String.valueOf(priorityMember.User__c).startsWith('005')) ? priorityMember.User__c : null;

            if (userId != null && !String.isEmpty(userId) && !leadsToUpdateMap.containsKey(currentLead.Id)) {
                currentLead.OwnerId = priorityMember.User__c;
                leadsToUpdateMap.put(currentLead.Id, currentLead);
            }
        }
    }
}